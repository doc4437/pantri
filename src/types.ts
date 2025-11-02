export type PantriItem = {
  id: string;
  name: string;
  category?: string;
  unit?: string;
  notes?: string;
  onHand?: number;
  par?: number;
  archived?: boolean;
  updatedAt: number;
};

export type PantriPreferences = {
  autoresetAfterShare: boolean;
  showArchived?: boolean;
};

export type PantriState = {
  items: PantriItem[];
  selectedIds: string[];
  preferences: PantriPreferences;
};

export type ShareOptions = {
  title?: string;
};
