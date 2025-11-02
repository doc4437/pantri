import PantryRow from './PantryRow';
import { PantriItem } from '../types';

type PantryListProps = {
  items: PantriItem[];
  selectedIds: string[];
  onToggleSelect: (id: string) => void;
  onQuickAdjust: (id: string, delta: number) => void;
  onEdit: (item: PantriItem) => void;
  onArchive: (id: string) => void;
  onDelete: (id: string) => void;
};

const PantryList = ({
  items,
  selectedIds,
  onToggleSelect,
  onQuickAdjust,
  onEdit,
  onArchive,
  onDelete
}: PantryListProps) => {
  if (items.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center rounded-xl border border-dashed border-leaf-200 bg-white p-12 text-center text-leaf-500">
        <p className="text-lg font-semibold text-leaf-700">Your pantry is blissfully empty.</p>
        <p className="mt-2 text-sm">Add a few staples to get started.</p>
        <pre className="mt-4 rounded-lg bg-leaf-50 px-4 py-3 text-xs text-leaf-400">
          {`    (\_/)
     ( •_•)
    / >🍞`}
        </pre>
      </div>
    );
  }

  return (
    <ul className="flex flex-col divide-y divide-leaf-100 overflow-hidden rounded-xl bg-white shadow-sm">
      {items.map((item) => (
        <PantryRow
          key={item.id}
          item={item}
          selected={selectedIds.includes(item.id)}
          onToggleSelect={() => onToggleSelect(item.id)}
          onQuickAdjust={onQuickAdjust}
          onEdit={() => onEdit(item)}
          onArchive={() => onArchive(item.id)}
          onDelete={() => onDelete(item.id)}
        />
      ))}
    </ul>
  );
};

export default PantryList;
