import { ListBulletIcon, ClockIcon, ArrowDownCircleIcon } from '@heroicons/react/24/outline';
import type { ReactNode } from 'react';

export type FilterState = {
  search: string;
  category: string;
  sort: 'az' | 'category' | 'updated';
};

type FiltersProps = {
  filters: FilterState;
  categories: string[];
  showArchived: boolean;
  onChange: (filters: FilterState) => void;
  onToggleArchived: () => void;
};

const sortOptions: { value: FilterState['sort']; label: string; icon: ReactNode }[] = [
  { value: 'updated', label: 'Recently touched', icon: <ClockIcon className="h-4 w-4" /> },
  { value: 'az', label: 'A → Z', icon: <ListBulletIcon className="h-4 w-4" /> },
  { value: 'category', label: 'By category', icon: <ArrowDownCircleIcon className="h-4 w-4" /> }
];

const Filters = ({ filters, categories, showArchived, onChange, onToggleArchived }: FiltersProps) => {
  return (
    <section className="flex flex-wrap items-center gap-3 rounded-xl bg-white p-4 shadow-sm">
      <input
        value={filters.search}
        onChange={(event) => onChange({ ...filters, search: event.target.value })}
        placeholder="Search pantry"
        className="w-full flex-1 rounded-lg border border-leaf-200 px-3 py-2 text-sm shadow-inner focus:border-leaf-500 focus:outline-none focus:ring-2 focus:ring-leaf-200"
      />
      <select
        value={filters.category}
        onChange={(event) => onChange({ ...filters, category: event.target.value })}
        className="rounded-lg border border-leaf-200 px-3 py-2 text-sm focus:border-leaf-500 focus:outline-none focus:ring-2 focus:ring-leaf-200"
      >
        <option value="all">All categories</option>
        {categories.map((category) => (
          <option key={category} value={category}>
            {category}
          </option>
        ))}
      </select>
      <div className="flex items-center gap-2">
        {sortOptions.map((option) => (
          <button
            key={option.value}
            onClick={() => onChange({ ...filters, sort: option.value })}
            className={`flex items-center gap-1 rounded-full border px-3 py-1 text-sm transition focus:outline-none focus-visible:ring-2 focus-visible:ring-leaf-400 focus-visible:ring-offset-2 ${
              filters.sort === option.value
                ? 'border-leaf-500 bg-leaf-500/10 text-leaf-700'
                : 'border-leaf-200 text-leaf-500 hover:border-leaf-300 hover:text-leaf-700'
            }`}
          >
            {option.icon}
            {option.label}
          </button>
        ))}
      </div>
      <label className="flex items-center gap-2 text-sm font-medium text-leaf-700">
        <input
          type="checkbox"
          checked={showArchived}
          onChange={onToggleArchived}
          className="h-4 w-4 rounded border-leaf-300 text-leaf-600 focus:ring-leaf-500"
        />
        Show archived
      </label>
    </section>
  );
};

export default Filters;
