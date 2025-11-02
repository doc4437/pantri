import { useState } from 'react';
import {
  ArchiveBoxIcon,
  PencilSquareIcon,
  TrashIcon,
  MinusSmallIcon,
  PlusSmallIcon
} from '@heroicons/react/24/outline';
import clsx from 'clsx';
import { PantriItem } from '../types';

type PantryRowProps = {
  item: PantriItem;
  selected: boolean;
  onToggleSelect: () => void;
  onQuickAdjust: (id: string, delta: number) => void;
  onEdit: () => void;
  onArchive: () => void;
  onDelete: () => void;
};

const PantryRow = ({
  item,
  selected,
  onToggleSelect,
  onQuickAdjust,
  onEdit,
  onArchive,
  onDelete
}: PantryRowProps) => {
  const [menuOpen, setMenuOpen] = useState(false);
  const onKeyDown: React.KeyboardEventHandler<HTMLLIElement> = (event) => {
    if (event.key === ' ') {
      event.preventDefault();
      onToggleSelect();
    }
  };

  return (
    <li
      tabIndex={0}
      onKeyDown={onKeyDown}
      className={clsx(
        'group flex flex-wrap items-center gap-3 px-4 py-3 transition focus:outline-none focus-visible:ring-2 focus-visible:ring-leaf-400',
        selected ? 'bg-leaf-50' : 'bg-white'
      )}
      onMouseLeave={() => setMenuOpen(false)}
    >
      <div className="flex items-center gap-3">
        <input
          type="checkbox"
          checked={selected}
          onChange={onToggleSelect}
          className="h-5 w-5 rounded border-leaf-300 text-leaf-600 focus:ring-leaf-500"
        />
        <div>
          <p className="text-sm font-semibold text-leaf-900">
            {item.name}
            {item.archived && <span className="ml-2 rounded-full bg-leaf-100 px-2 text-xs">Archived</span>}
          </p>
          <p className="text-xs text-leaf-500">
            {[item.category, item.unit].filter(Boolean).join(' • ')}
          </p>
          {item.notes && <p className="text-xs text-leaf-400">{item.notes}</p>}
        </div>
      </div>
      <div className="ml-auto flex items-center gap-2">
        <div className="flex items-center rounded-full border border-leaf-200 bg-leaf-50 text-sm">
          <button
            onClick={() => onQuickAdjust(item.id, -1)}
            className="rounded-l-full px-2 py-1 text-leaf-600 hover:bg-leaf-100"
          >
            <MinusSmallIcon className="h-4 w-4" />
          </button>
          <span className="w-10 text-center text-xs font-semibold text-leaf-700">
            {item.onHand ?? 0}
          </span>
          <button
            onClick={() => onQuickAdjust(item.id, 1)}
            className="rounded-r-full px-2 py-1 text-leaf-600 hover:bg-leaf-100"
          >
            <PlusSmallIcon className="h-4 w-4" />
          </button>
        </div>
        <div className="relative">
          <button
            onClick={() => setMenuOpen((value) => !value)}
            className="rounded-full border border-leaf-200 px-2 py-1 text-xs font-semibold uppercase tracking-wide text-leaf-600 hover:border-leaf-400"
          >
            Menu
          </button>
          {menuOpen && (
            <div className="absolute right-0 z-10 mt-2 w-36 rounded-lg border border-leaf-200 bg-white shadow-lg">
              <button
                onClick={() => {
                  onEdit();
                  setMenuOpen(false);
                }}
                className="flex w-full items-center gap-2 px-3 py-2 text-sm hover:bg-leaf-50"
              >
                <PencilSquareIcon className="h-4 w-4 text-leaf-500" /> Edit
              </button>
              <button
                onClick={() => {
                  onArchive();
                  setMenuOpen(false);
                }}
                className="flex w-full items-center gap-2 px-3 py-2 text-sm hover:bg-leaf-50"
              >
                <ArchiveBoxIcon className="h-4 w-4 text-leaf-500" />
                {item.archived ? 'Restore' : 'Archive'}
              </button>
              <button
                onClick={() => {
                  onDelete();
                  setMenuOpen(false);
                }}
                className="flex w-full items-center gap-2 px-3 py-2 text-sm text-red-600 hover:bg-red-50"
              >
                <TrashIcon className="h-4 w-4" /> Delete
              </button>
            </div>
          )}
        </div>
      </div>
    </li>
  );
};

export default PantryRow;
