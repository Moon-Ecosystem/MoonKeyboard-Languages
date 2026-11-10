# Moon Keyboard Languages

Language packs for [Moon Keyboard](https://github.com/Moon-Ecosystem/MoonKeyboard), the fully offline Android keyboard. English is built into the app; every other language is a pack you add yourself.

## Languages

| Language | Layout | Needs app version | Licence |
|---|---|---|---|
| Deutsch (German) | QWERTZ with ü ö ä | 0.8 or newer | CC BY 4.0 |
| Français (French) | AZERTY | 0.8 or newer | CC BY 4.0 |
| Italiano (Italian) | QWERTY | 0.8 or newer | CC BY 4.0 |

## Installing a pack

1. Download the language's `.mkpack` file from [Releases](https://github.com/Moon-Ecosystem/MoonKeyboard-Languages/releases).
2. Open it with Moon Keyboard, or use **Languages → Import from file** in the app.

The app has no internet permission, so it never downloads anything itself. It only installs packs signed by Moon Keyboard, and checks every file before using it. To update a language, install its newer pack the same way.

## What's in this repo

Each language has a folder:

- `pack/`: what goes into the pack besides the dictionary: `pack.json` (name, version, layout and language rules), the layout, and the pack's `NOTICE.txt`.
- `fetch-data.sh`: downloads the source word lists and sentences and builds the signed pack, using the app repo's tools.
- `eval/`: held-out sentences the dictionary never saw, for measuring typing accuracy.

Each pack's data has its own licence, listed in its `NOTICE.txt`. The scripts and layouts are MIT.
