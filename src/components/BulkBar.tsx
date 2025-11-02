import { useState } from 'react';
import { PlusIcon } from '@heroicons/react/24/outline';

type BulkBarProps = {
  onQuickAdd: (name: string) => void;
  selectionCount: number;
  totalCount: number;
  onToggleAll: (checked: boolean) => void;
  onOpenAdd: () => void;
};

const BulkBar = ({ onQuickAdd, selectionCount, totalCount, onToggleAll, onOpenAdd }: BulkBarProps) => {
  const [quickName, setQuickName] = useState('');

  const handleSubmit = (event: React.FormEvent) => {
    event.preventDefault();
    onQuickAdd(quickName);
    setQuickName('');
  };

  return (
    <section className="flex flex-col gap-3 rounded-xl bg-white p-4 shadow-sm sm:flex-row sm:items-center sm:justify-between">
      <form onSubmit={handleSubmit} className="flex flex-1 items-center gap-2">
        <PlusIcon className="h-5 w-5 text-leaf-500" />
        <input
          value={quickName}
          onChange={(event) => setQuickName(event.target.value)}
          placeholder="+ Add: milk"
          className="flex-1 rounded-lg border border-leaf-200 px-3 py-2 text-sm focus:border-leaf-500 focus:outline-none focus:ring-2 focus:ring-leaf-200"
        />
        <button
          type="submit"
          className="rounded-full bg-leaf-600 px-4 py-2 text-sm font-semibold text-white shadow transition hover:bg-leaf-500 focus:outline-none focus-visible:ring-2 focus-visible:ring-leaf-400 focus-visible:ring-offset-2"
        >
          Add
        </button>
      </form>
      <div className="flex items-center justify-between gap-3 text-sm text-leaf-600 sm:justify-end">
        <label className="flex items-center gap-2">
          <input
            type="checkbox"
            checked={selectionCount > 0 && selectionCount === totalCount && totalCount > 0}
            onChange={(event) => onToggleAll(event.target.checked)}
            className="h-4 w-4 rounded border-leaf-300 text-leaf-600 focus:ring-leaf-500"
          />
          Select all ({selectionCount}/{totalCount})
        </label>
        <button
          onClick={() => onToggleAll(false)}
          className="text-sm font-medium text-leaf-500 underline-offset-4 hover:underline"
        >
          Clear
        </button>
        <button
          onClick={onOpenAdd}
          className="rounded-full border border-leaf-300 px-3 py-1 text-sm font-semibold text-leaf-700 hover:border-leaf-400 hover:text-leaf-900"
        >
          Open form
        </button>
      </div>
    </section>
  );
};

export default BulkBar;
