import { Dialog, Transition } from '@headlessui/react';
import { Fragment, useEffect, useState } from 'react';

export type ItemDraft = {
  id: string | null;
  name: string;
  category?: string;
  unit?: string;
  notes?: string;
  onHand?: number;
  par?: number;
};

type AddEditModalProps = {
  open: boolean;
  draft: ItemDraft;
  categories: string[];
  onClose: () => void;
  onSave: (draft: ItemDraft) => void;
};

const numberOrUndefined = (value: string) => {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : undefined;
};

const AddEditModal = ({ open, draft, categories, onClose, onSave }: AddEditModalProps) => {
  const [localDraft, setLocalDraft] = useState<ItemDraft>(draft);

  useEffect(() => {
    setLocalDraft(draft);
  }, [draft]);

  return (
    <Transition show={open} as={Fragment} appear>
      <Dialog as="div" className="relative z-50" onClose={onClose}>
        <Transition.Child
          as={Fragment}
          enter="ease-out duration-200"
          enterFrom="opacity-0"
          enterTo="opacity-100"
          leave="ease-in duration-150"
          leaveFrom="opacity-100"
          leaveTo="opacity-0"
        >
          <div className="fixed inset-0 bg-black/30" />
        </Transition.Child>

        <div className="fixed inset-0 overflow-y-auto">
          <div className="flex min-h-full items-center justify-center p-4">
            <Transition.Child
              as={Fragment}
              enter="ease-out duration-200"
              enterFrom="opacity-0 scale-95"
              enterTo="opacity-100 scale-100"
              leave="ease-in duration-150"
              leaveFrom="opacity-100 scale-100"
              leaveTo="opacity-0 scale-95"
            >
              <Dialog.Panel className="w-full max-w-lg transform overflow-hidden rounded-2xl bg-white p-6 shadow-xl transition-all">
                <Dialog.Title className="text-lg font-semibold text-leaf-800">
                  {localDraft.id ? 'Edit item' : 'Add item'}
                </Dialog.Title>
                <form
                  className="mt-4 flex flex-col gap-4"
                  onSubmit={(event) => {
                    event.preventDefault();
                    onSave(localDraft);
                  }}
                >
                  <label className="text-sm font-medium text-leaf-700">
                    Name
                    <input
                      value={localDraft.name}
                      onChange={(event) =>
                        setLocalDraft((prev) => ({ ...prev, name: event.target.value }))
                      }
                      required
                      className="mt-1 w-full rounded-lg border border-leaf-200 px-3 py-2 focus:border-leaf-500 focus:outline-none focus:ring-2 focus:ring-leaf-200"
                    />
                  </label>
                  <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                    <label className="text-sm font-medium text-leaf-700">
                      Category
                      <input
                        list="pantri-categories"
                        value={localDraft.category ?? ''}
                        onChange={(event) =>
                          setLocalDraft((prev) => ({ ...prev, category: event.target.value }))
                        }
                        placeholder="Produce, Dairy, ..."
                        className="mt-1 w-full rounded-lg border border-leaf-200 px-3 py-2 focus:border-leaf-500 focus:outline-none focus:ring-2 focus:ring-leaf-200"
                      />
                    </label>
                    <label className="text-sm font-medium text-leaf-700">
                      Unit / size
                      <input
                        value={localDraft.unit ?? ''}
                        onChange={(event) =>
                          setLocalDraft((prev) => ({ ...prev, unit: event.target.value }))
                        }
                        placeholder="dozen, 16 oz"
                        className="mt-1 w-full rounded-lg border border-leaf-200 px-3 py-2 focus:border-leaf-500 focus:outline-none focus:ring-2 focus:ring-leaf-200"
                      />
                    </label>
                  </div>
                  <label className="text-sm font-medium text-leaf-700">
                    Notes
                    <textarea
                      value={localDraft.notes ?? ''}
                      onChange={(event) =>
                        setLocalDraft((prev) => ({ ...prev, notes: event.target.value }))
                      }
                      rows={3}
                      className="mt-1 w-full rounded-lg border border-leaf-200 px-3 py-2 focus:border-leaf-500 focus:outline-none focus:ring-2 focus:ring-leaf-200"
                    />
                  </label>
                  <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                    <label className="text-sm font-medium text-leaf-700">
                      On hand
                      <input
                        type="number"
                        min={0}
                        value={localDraft.onHand ?? 0}
                        onChange={(event) =>
                          setLocalDraft((prev) => ({
                            ...prev,
                            onHand: Number(event.target.value)
                          }))
                        }
                        className="mt-1 w-full rounded-lg border border-leaf-200 px-3 py-2 focus:border-leaf-500 focus:outline-none focus:ring-2 focus:ring-leaf-200"
                      />
                    </label>
                    <label className="text-sm font-medium text-leaf-700">
                      Par
                      <input
                        type="number"
                        min={0}
                        value={localDraft.par ?? ''}
                        onChange={(event) =>
                          setLocalDraft((prev) => ({
                            ...prev,
                            par: numberOrUndefined(event.target.value)
                          }))
                        }
                        placeholder="Optional"
                        className="mt-1 w-full rounded-lg border border-leaf-200 px-3 py-2 focus:border-leaf-500 focus:outline-none focus:ring-2 focus:ring-leaf-200"
                      />
                    </label>
                  </div>
                  <div className="mt-2 flex justify-end gap-2">
                    <button
                      type="button"
                      onClick={onClose}
                      className="rounded-full border border-leaf-200 px-4 py-2 text-sm font-semibold text-leaf-600 hover:border-leaf-400"
                    >
                      Cancel
                    </button>
                    <button
                      type="submit"
                      className="rounded-full bg-leaf-600 px-4 py-2 text-sm font-semibold text-white hover:bg-leaf-500"
                    >
                      Save
                    </button>
                  </div>
                </form>
                <datalist id="pantri-categories">
                  {categories.map((category) => (
                    <option key={category} value={category} />
                  ))}
                </datalist>
              </Dialog.Panel>
            </Transition.Child>
          </div>
        </div>
      </Dialog>
    </Transition>
  );
};

export default AddEditModal;
