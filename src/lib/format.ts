import { PantriItem, ShareOptions } from '../types';

type FormatOptions = ShareOptions & {
  includeArchived?: boolean;
};

export const buildShareText = (
  items: PantriItem[],
  options: FormatOptions = {}
): string => {
  const { title = 'Pantri list:', includeArchived = false } = options;
  const lines: string[] = [];

  if (title) {
    lines.push(title.trim());
  }

  items
    .filter((item) => (includeArchived ? true : !item.archived))
    .forEach((item) => {
      const parts = [`• ${item.name}`];
      if (item.unit) {
        parts[0] += ` (${item.unit})`;
      }
      if (typeof item.par === 'number' && typeof item.onHand === 'number') {
        const need = item.par - item.onHand;
        if (need > 0) {
          parts.push(`need ${need}`);
        }
      }
      if (item.notes) {
        parts.push(item.notes);
      }
      lines.push(parts.join(' — '));
    });

  return lines.join('\n');
};
