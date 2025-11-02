# Pantri

Pantri is a tiny, local-first pantry tracker that runs entirely in your browser. Keep tabs on what is on hand, text your grocery list in seconds, and stay productive even offline.

## Getting started

```bash
npm install
npm run dev
```

- Development server is available at <http://localhost:5173>.
- Build for production with `npm run build`.
- Preview a production build locally with `npm run preview`.

## Features

- Add, edit, archive, or delete pantry items with categories, notes, and on-hand counts.
- Quick add bar, search, category filter, and sorting options.
- Multi-select items and compose an SMS-ready grocery message with copy/Open SMS actions.
- Local persistence via `localStorage` with seed data and optional import/export JSON.
- Installable Progressive Web App that works offline.

## SMS behaviour

- On iOS and Android, tapping **Open SMS** launches your default messaging app with the list pre-filled.
- On desktop browsers the app falls back to copying the message to your clipboard and lets you paste it where you need it.

## Add to home screen

1. Visit the app in your browser.
2. Open the browser menu and choose **Add to Home Screen** (wording varies per platform).
3. Launch Pantri from your home screen and enjoy the offline-ready experience.

## Testing

Run unit tests with Vitest:

```bash
npm run test
```

## Demo script

Use these beats to record a short walkthrough video:

1. Open Pantri and show the seeded pantry list.
2. Use the quick add bar to add “apples”.
3. Edit an item to adjust category, notes, and on-hand quantity.
4. Select a few items and open **Text My List**, then copy the generated SMS.
5. Archive an item and toggle the archived filter to show it.
6. Export the pantry data, then import it back in.
7. Highlight the **Add to Home Screen** tip for offline access.
