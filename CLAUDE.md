# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
npm run dev          # Dev server at http://localhost:5173
npm run dev:open     # Dev server + auto-open browser
npm run build        # Production build to /dist
npm run lint         # ESLint (zero-warning policy, React plugins)
npm run preview      # Preview production build locally
```

No test runner is configured.

## What This App Does

**Prompt Fill** (提示詞填空器) is a structured AI prompt generator. Users define templates with `{{variable}}` placeholders (e.g., `"A {{mood}} {{character}} in {{setting}}"`), then fill them via color-coded interactive dropdowns backed by curated word banks.

Core data model:
- **Categories** — groupings with a color (e.g., "character", "style")
- **Banks** — vocabulary lists keyed to a category; options can be plain strings or `{ "zh-tw": "...", en: "..." }` objects
- **Templates** — prompt text with `{{variable}}` syntax; `{{color}}` appearing twice becomes independent instances `color-0`, `color-1`

All data persists in LocalStorage (no backend). The app is offline-first and supports import/export as compressed JSON.

## Architecture

**`src/App.jsx`** is the monolithic state owner (~3000+ LOC). It holds all categories, banks, templates, and selection state. Every major action (add/edit/delete template, fill variable, export) lives here. Child components receive state and callbacks as props.

**Key component roles:**
- `VisualEditor.jsx` — syntax-highlighting editor that colorizes `{{variable}}` tokens by category color in real time
- `Variable.jsx` — interactive dropdown for a single `{{variable}}` instance during fill mode
- `DiscoveryView.jsx` — masonry waterfall gallery of templates (conditionally unmounted when editing to reduce GPU load)
- `TemplatesSidebar.jsx` / `BanksSidebar.jsx` — management panels for templates and word banks respectively

**`src/hooks/useStickyState.js`** — wraps `useState` with LocalStorage persistence and quota-exceeded error handling. Every top-level data collection uses this hook.

**`src/utils/merge.js`** — smart merge logic for syncing upstream template/bank updates without overwriting user customizations. Called when the user accepts a system data update.

**`src/data/templates.js` and `src/data/banks.js`** — the bundled default dataset. Upstream sync pulls from `upstream-data.json` and diffing logic in merge.js determines what to update.

**`src/contexts/ToastContext.jsx`** — global toast notification system (auto-dismiss 4s). The only React Context in the app; import `useToast()` to push notifications.

**`src/constants/translations.js`** — all UI strings keyed by language code (`zh-tw`, `en`). Use `getLocalized(obj, lang)` from `src/utils/helpers.js` to resolve bilingual objects.

## Localization Pattern

Bilingual strings appear throughout data files as `{ "zh-tw": "角色", en: "Character" }`. The helper `getLocalized(value, lang)` normalizes both plain strings and these objects. UI language is stored in state and passed down as `lang` prop; do not access `navigator.language` directly.

## Image Export

`html2canvas` renders the filled prompt card as a high-resolution image. Theme color for the export background is auto-extracted from the template's preview image via canvas pixel sampling (`src/utils/imageUtils.js`). Images stored in LocalStorage are compressed with `lz-string` to avoid quota limits.

## Tauri Desktop Build

`src-tauri/` is gitignored. Tauri CLI is listed as a dev dependency. `vite.config.js` sets `server.port: 1420` and `server.strictPort: true` to match Tauri's expected dev port. The web build is the primary target; Tauri wraps it for desktop.
