import { describe, expect, it, beforeEach } from 'vitest';
import { getState, saveState } from './storage';
import { PantriState } from '../types';

describe('storage', () => {
  beforeEach(() => {
    window.localStorage.clear();
  });

  it('returns seed data when empty', () => {
    const state = getState();
    expect(state.items.length).toBeGreaterThan(0);
  });

  it('persists and loads state', () => {
    const state = getState();
    const next: PantriState = {
      ...state,
      items: state.items.map((item) => ({ ...item, name: `${item.name}!` }))
    };
    saveState(next);
    const rehydrated = getState();
    expect(rehydrated.items[0].name.endsWith('!')).toBe(true);
  });
});
