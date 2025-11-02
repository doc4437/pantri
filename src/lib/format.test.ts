import { describe, expect, it } from 'vitest';
import { buildShareText } from './format';
import { PantriItem } from '../types';

const baseItem = (overrides: Partial<PantriItem> = {}): PantriItem => ({
  id: '1',
  name: 'eggs',
  updatedAt: Date.now(),
  ...overrides
});

describe('buildShareText', () => {
  it('includes title line', () => {
    const text = buildShareText([baseItem()], { title: 'Pantri list:' });
    expect(text.startsWith('Pantri list:')).toBe(true);
  });

  it('formats unit and notes', () => {
    const text = buildShareText([
      baseItem({ name: 'eggs', unit: 'dozen', notes: 'pasture raised' })
    ]);
    expect(text).toContain('• eggs (dozen) — pasture raised');
  });

  it('adds need count when below par', () => {
    const text = buildShareText([
      baseItem({ name: 'milk', par: 2, onHand: 1, unit: 'gallon' })
    ]);
    expect(text).toContain('need 1');
  });

  it('omits archived items by default', () => {
    const text = buildShareText([
      baseItem({ name: 'hidden', archived: true })
    ]);
    expect(text).not.toContain('hidden');
  });
});
