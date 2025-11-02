import { useEffect, useMemo, useRef, useState } from 'react';
import { ArrowPathIcon } from '@heroicons/react/24/outline';
import Header from './components/Header';
import Filters, { FilterState } from './components/Filters';
import BulkBar from './components/BulkBar';
import PantryList from './components/PantryList';
import ShareDrawer from './components/ShareDrawer';
import AddEditModal, { ItemDraft } from './components/AddEditModal';
import ToastHost, { useToastQueue } from './components/Toast';
import { buildShareText } from './lib/format';
import { buildSmsLink, canUseSms } from './lib/sms';
import { createId } from './lib/id';
import { getState, saveState } from './lib/storage';
import { PantriItem, PantriState } from './types';

const usePersistentState = () => {
  const [state, setState] = useState<PantriState>(() => getState());
  const timer = useRef<NodeJS.Timeout>();

  useEffect(() => {
    if (timer.current) clearTimeout(timer.current);
    timer.current = setTimeout(() => {
      saveState(state);
    }, 250);
    return () => {
      if (timer.current) clearTimeout(timer.current);
    };
  }, [state]);

  return [state, setState] as const;
};

const App = () => {
  const [state, setState] = usePersistentState();
  const [filters, setFilters] = useState<FilterState>({
    search: '',
    category: 'all',
    sort: 'updated'
  });
  const [isShareOpen, setShareOpen] = useState(false);
  const [draft, setDraft] = useState<ItemDraft | null>(null);
  const [showModal, setShowModal] = useState(false);
  const fileInputRef = useRef<HTMLInputElement | null>(null);
  const toast = useToastQueue();

  const categories = useMemo(() => {
    const cats = new Set<string>();
    state.items.forEach((item) => {
      if (item.category) cats.add(item.category);
    });
    return Array.from(cats).sort((a, b) => a.localeCompare(b));
  }, [state.items]);

  const filteredItems = useMemo(() => {
    return state.items
      .filter((item) => (state.preferences.showArchived ? true : !item.archived))
      .filter((item) =>
        filters.category === 'all'
          ? true
          : (item.category ?? 'Uncategorized') === filters.category
      )
      .filter((item) =>
        filters.search.trim()
          ? item.name.toLowerCase().includes(filters.search.trim().toLowerCase()) ||
            (item.notes ?? '').toLowerCase().includes(filters.search.trim().toLowerCase())
          : true
      )
      .sort((a, b) => {
        if (filters.sort === 'az') {
          return a.name.localeCompare(b.name);
        }
        if (filters.sort === 'category') {
          return (a.category ?? 'Uncategorized').localeCompare(b.category ?? 'Uncategorized');
        }
        return b.updatedAt - a.updatedAt;
      });
  }, [state.items, filters, state.preferences.showArchived]);

  const toggleSelect = (id: string) => {
    setState((prev) => {
      const selected = prev.selectedIds.includes(id)
        ? prev.selectedIds.filter((x) => x !== id)
        : [...prev.selectedIds, id];
      return { ...prev, selectedIds: selected };
    });
  };

  const updateItem = (id: string, updates: Partial<PantriItem>) => {
    setState((prev) => ({
      ...prev,
      items: prev.items.map((item) =>
        item.id === id ? { ...item, ...updates, updatedAt: Date.now() } : item
      )
    }));
  };

  const deleteItem = (id: string) => {
    setState((prev) => ({
      ...prev,
      items: prev.items.filter((item) => item.id !== id),
      selectedIds: prev.selectedIds.filter((selected) => selected !== id)
    }));
  };

  const openEditor = (item?: PantriItem) => {
    setDraft(
      item
        ? {
            id: item.id,
            name: item.name,
            category: item.category ?? '',
            unit: item.unit ?? '',
            notes: item.notes ?? '',
            onHand: item.onHand ?? 0,
            par: item.par ?? undefined
          }
        : {
            id: null,
            name: '',
            category: '',
            unit: '',
            notes: '',
            onHand: 0,
            par: undefined
          }
    );
    setShowModal(true);
  };

  const closeEditor = () => {
    setShowModal(false);
    setDraft(null);
  };

  const handleSave = (itemDraft: ItemDraft) => {
    if (!itemDraft.name.trim()) {
      toast.push({ type: 'error', title: 'Name is required' });
      return;
    }
    const now = Date.now();
    if (itemDraft.id) {
      updateItem(itemDraft.id, {
        name: itemDraft.name.trim(),
        category: itemDraft.category?.trim() || undefined,
        unit: itemDraft.unit?.trim() || undefined,
        notes: itemDraft.notes?.trim() || undefined,
        onHand: itemDraft.onHand ?? 0,
        par: itemDraft.par,
        updatedAt: now
      });
      toast.push({ type: 'success', title: 'Item updated' });
    } else {
      const newItem: PantriItem = {
        id: createId(),
        name: itemDraft.name.trim(),
        category: itemDraft.category?.trim() || undefined,
        unit: itemDraft.unit?.trim() || undefined,
        notes: itemDraft.notes?.trim() || undefined,
        onHand: itemDraft.onHand ?? 0,
        par: itemDraft.par,
        archived: false,
        updatedAt: now
      };
      setState((prev) => ({
        ...prev,
        items: [newItem, ...prev.items]
      }));
      toast.push({ type: 'success', title: 'Item added' });
    }
    closeEditor();
  };

  const quickAdd = (name: string) => {
    const trimmed = name.trim();
    if (!trimmed) return;
    const newItem: PantriItem = {
      id: createId(),
      name: trimmed,
      category: 'Uncategorized',
      onHand: 0,
      updatedAt: Date.now()
    };
    setState((prev) => ({
      ...prev,
      items: [newItem, ...prev.items]
    }));
    toast.push({ type: 'success', title: `${trimmed} added` });
  };

  const toggleArchive = (id: string) => {
    const item = state.items.find((it) => it.id === id);
    if (!item) return;
    updateItem(id, { archived: !item.archived });
    toast.push({
      type: 'info',
      title: item.archived ? 'Item restored' : 'Item archived'
    });
  };

  const shareItems = state.items.filter((item) => state.selectedIds.includes(item.id));
  const shareText = buildShareText(shareItems);

  const handleShared = () => {
    if (state.preferences.autoresetAfterShare) {
      setState((prev) => ({ ...prev, selectedIds: [] }));
    }
  };

  const toggleAllSelection = (checked: boolean) => {
    if (checked) {
      setState((prev) => ({
        ...prev,
        selectedIds: filteredItems.map((item) => item.id)
      }));
    } else {
      setState((prev) => ({ ...prev, selectedIds: [] }));
    }
  };

  const exportData = () => {
    const blob = new Blob([JSON.stringify(state, null, 2)], {
      type: 'application/json'
    });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `pantri-export-${new Date().toISOString().slice(0, 10)}.json`;
    link.click();
    URL.revokeObjectURL(url);
    toast.push({ type: 'success', title: 'Exported pantry' });
  };

  const importData = async (file: File) => {
    const text = await file.text();
    const parsed = JSON.parse(text) as PantriState;
    const incomingNames = new Map(
      parsed.items.map((item) => [item.name.trim().toLowerCase(), item])
    );
    const merged: PantriItem[] = [];

    state.items.forEach((item) => {
      const incoming = incomingNames.get(item.name.trim().toLowerCase());
      if (!incoming) {
        merged.push(item);
        return;
      }
      if (window.confirm(`Replace “${item.name}” with imported version?`)) {
        merged.push({ ...incoming, id: createId(), updatedAt: Date.now() });
      } else if (window.confirm('Keep both copies?')) {
        merged.push(item);
        merged.push({ ...incoming, id: createId(), name: `${incoming.name} (imported)` });
      } else {
        merged.push(item);
      }
      incomingNames.delete(item.name.trim().toLowerCase());
    });

    incomingNames.forEach((item) => {
      merged.push({ ...item, id: createId(), updatedAt: Date.now() });
    });

    setState((prev) => ({
      ...prev,
      items: merged
    }));
    toast.push({ type: 'success', title: 'Import complete' });
  };

  const handleFileChange = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;
    try {
      await importData(file);
    } catch (error) {
      console.error(error);
      toast.push({ type: 'error', title: 'Import failed' });
    } finally {
      event.target.value = '';
    }
  };

  return (
    <div className="min-h-screen bg-leaf-50">
      <Header onImport={() => fileInputRef.current?.click()} onExport={exportData} />
      <main className="mx-auto flex max-w-5xl flex-col gap-4 px-4 pb-24 pt-6">
        <BulkBar
          onQuickAdd={quickAdd}
          selectionCount={state.selectedIds.length}
          totalCount={filteredItems.length}
          onToggleAll={toggleAllSelection}
          onOpenAdd={() => openEditor()}
        />
        <Filters
          filters={filters}
          categories={categories}
          showArchived={state.preferences.showArchived ?? false}
          onChange={setFilters}
          onToggleArchived={() =>
            setState((prev) => ({
              ...prev,
              preferences: {
                ...prev.preferences,
                showArchived: !prev.preferences.showArchived
              }
            }))
          }
        />
        <PantryList
          items={filteredItems}
          selectedIds={state.selectedIds}
          onToggleSelect={toggleSelect}
          onQuickAdjust={(id, delta) => {
            const item = state.items.find((it) => it.id === id);
            if (!item) return;
            const next = Math.max(0, (item.onHand ?? 0) + delta);
            updateItem(id, { onHand: next });
          }}
          onEdit={openEditor}
          onArchive={toggleArchive}
          onDelete={(id) => {
            if (window.confirm('Delete this item?')) {
              deleteItem(id);
              toast.push({ type: 'info', title: 'Item deleted' });
            }
          }}
        />
      </main>

      <button
        onClick={() => setShareOpen(true)}
        className="fixed bottom-6 right-6 flex items-center gap-2 rounded-full bg-leaf-600 px-5 py-3 text-white shadow-lg transition hover:bg-leaf-500 focus:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-leaf-700"
      >
        <ArrowPathIcon className="h-5 w-5" />
        Text My List
      </button>

      <ShareDrawer
        open={isShareOpen}
        onClose={() => setShareOpen(false)}
        items={shareItems}
        autoreset={state.preferences.autoresetAfterShare}
        onToggleAutoreset={(value) =>
          setState((prev) => ({
            ...prev,
            preferences: { ...prev.preferences, autoresetAfterShare: value }
          }))
        }
        onCopy={(message) => {
          navigator.clipboard.writeText(message).then(() => {
            toast.push({ type: 'success', title: 'Copied to clipboard' });
            handleShared();
          });
        }}
        onSms={(message) => {
          const link = buildSmsLink(message);
          if (canUseSms()) {
            window.location.href = link;
            handleShared();
          } else {
            navigator.clipboard.writeText(message).then(() => {
              toast.push({
                type: 'info',
                title: 'SMS not supported, text copied instead'
              });
              handleShared();
            });
          }
        }}
        shareText={shareText}
      />

      {draft && (
        <AddEditModal
          open={showModal}
          draft={draft}
          categories={categories}
          onClose={closeEditor}
          onSave={handleSave}
        />
      )}

      <input
        ref={fileInputRef}
        type="file"
        accept="application/json"
        hidden
        onChange={handleFileChange}
      />

      <ToastHost queue={toast.queue} onDismiss={toast.shift} />
    </div>
  );
};

export default App;
