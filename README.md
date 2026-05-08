# Pantri

Pantri is a small SwiftUI iPhone app for keeping a running pantry restock queue.

## Current app state

As of the current local repo state, Pantri already has:

- a browsable pantry organized into categories
- tap-to-queue restock selection from the main pantry view
- a persistent restock queue that stays intact until items are removed or the queue is cleared
- a dedicated restock list screen with shareable text output
- a pantry management surface for:
  - adding categories
  - renaming categories
  - adding items
  - editing items, including moving them between categories
  - deleting items
  - resetting back to the built-in starter pantry

## Architecture snapshot

- UI: SwiftUI, currently centered in `Pantri/ContentView.swift`
- State owner: `Pantri/Store/PantryStore.swift`
- Seed data: `Pantri/Data/PantrySeed.swift`
- Models:
  - `PantryCategory`
  - `PantryItem`
  - `PantryRestockEntry`
- Share text builder: `Pantri/Services/PromptBuilder.swift`

## Persistence truth

Pantri is **not** stateless.

Current persistence is already implemented in `PantryStore` using a `UserDefaults` snapshot (`Pantri.PantryStore.snapshot.v2`). The store also includes a legacy read path for the older category-only storage key (`Pantri.PantryStore.categories`).

That means stale descriptions like these should be avoided:

- "Pantri does not persist yet"
- "Persistence is the first thing the app needs before it is usable"
- "The restock queue resets every launch"

A more accurate description is:

> Pantri already has simple local persistence. Future persistence work, if we do it, would be about making the storage model richer and more durable rather than adding persistence from scratch.

## Current constraints

A few things are true in the current codebase and worth keeping documented:

- persistence is simple snapshot-based local storage, not SwiftData
- most UI lives in one large `ContentView.swift`, so view decomposition is still an open cleanup opportunity
- there is no dedicated test target yet in this local repo state
- this repo currently does not have much product or engineering documentation, so this file is the baseline source of truth

## Documentation hygiene note

When the app changes meaningfully, update this file in the same pass if any of the following change:

- persistence model
- user-visible pantry management capabilities
- share/export behavior
- major architectural ownership of state
