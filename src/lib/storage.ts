import { PantriItem, PantriState } from '../types';
import { createId } from './id';

const STORAGE_KEY = 'pantri:v1';
const STORAGE_VERSION = 1;

type PersistedState = PantriState & { version: number };

const clone = <T>(value: T): T => {
  if (typeof structuredClone === 'function') {
    return structuredClone(value);
  }
  return JSON.parse(JSON.stringify(value));
};

const seedItems: PantriItem[] = [
  {
    id: createId(),
    name: 'eggs',
    category: 'Dairy',
    unit: 'dozen',
    onHand: 1,
    par: 2,
    updatedAt: Date.now()
  },
  {
    id: createId(),
    name: 'milk',
    category: 'Dairy',
    unit: 'gallon',
    onHand: 0,
    par: 1,
    updatedAt: Date.now()
  },
  {
    id: createId(),
    name: 'coffee',
    category: 'Dry Goods',
    unit: 'beans, 12 oz',
    onHand: 1,
    par: 1,
    updatedAt: Date.now()
  },
  {
    id: createId(),
    name: 'chicken thighs',
    category: 'Meat',
    unit: '3–4 lb',
    onHand: 0,
    updatedAt: Date.now()
  },
  {
    id: createId(),
    name: 'cumin',
    category: 'Spices',
    notes: 'ground',
    onHand: 1,
    updatedAt: Date.now()
  }
];

const defaultState: PantriState = {
  items: seedItems,
  selectedIds: [],
  preferences: {
    autoresetAfterShare: true,
    showArchived: false
  }
};

export const getState = (): PantriState => {
  if (typeof window === 'undefined') {
    return clone(defaultState);
  }

  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) {
      return clone(defaultState);
    }
    const parsed = JSON.parse(raw) as PersistedState;
    return migrate(parsed);
  } catch (error) {
    console.error('Failed to load pantri state', error);
    return clone(defaultState);
  }
};

export const saveState = (state: PantriState) => {
  if (typeof window === 'undefined') return;
  const payload: PersistedState = { ...state, version: STORAGE_VERSION };
  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(payload));
};

export const migrate = (persisted: PersistedState): PantriState => {
  if (!persisted.version || persisted.version < STORAGE_VERSION) {
    // Add future migrations here
  }
  return {
    items: persisted.items ?? [],
    selectedIds: persisted.selectedIds ?? [],
    preferences: {
      autoresetAfterShare: persisted.preferences?.autoresetAfterShare ?? true,
      showArchived: persisted.preferences?.showArchived ?? false
    }
  };
};

export const resetState = () => {
  if (typeof window === 'undefined') return;
  window.localStorage.removeItem(STORAGE_KEY);
};
