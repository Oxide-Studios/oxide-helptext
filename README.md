# oxide-helptext

On-screen interaction prompts for FiveM, such as **[E] Open Trunk**. Your scripts keep sending the text they already send, and oxide-helptext draws it as a clean card with key badges. It is free, standalone and works with any framework.

---

## Features

### Prompts
- **Key badges from plain text** - Strings such as `[E] Open`, `[E] - Open`, `Press [E] to open` and `[E] Smoke · [H] Stop` get key badges with no change to the script that sends them.
- **Prompts stack** - Prompts from different scripts show together instead of replacing each other.
- **Per-script ownership** - A script can only hide its own prompts, and its prompts disappear when it stops.
- **Structured prompts** - An optional title, icon, body text and a list of key rows.
- **Eight screen positions** - With a server-wide default and an option to force every prompt into one position.

### Key Badges
- **Live feedback** - A badge lights up while the player holds that key.
- **The player's own bindings** - Tie a key row to a game control and the badge shows whatever key the player has bound to it.

### Safe and Light
- **Text only** - No HTML is ever rendered. `**bold**`, GTA colour codes (`~g~`, `~r~` and so on) and line breaks work.
- **Idle when nothing is shown** - No per-frame work while no prompt is open. Prompts hide while the pause menu is open.
- **Works offline** - The font and the Font Awesome icons ship inside the resource, so nothing loads from the internet.

### Compatibility
- **ox_lib** - One line in ox_lib's `fxmanifest.lua` sends every `lib.showTextUI` prompt through oxide-helptext.
- **o-link** - Picked automatically as the helptext provider of [o-link](https://github.com/Oxide-Studios/o-link).

## Quick Start

1. **Download** `oxide-helptext.zip` from the [latest release](https://github.com/Oxide-Studios/oxide-helptext/releases/latest). Do not use the green **Code > Download ZIP** button: that copy has no built UI and prompts will not appear.
2. **Extract** the `oxide-helptext` folder into your server's `resources` folder.
3. **Add it to `server.cfg`** as the first `ensure` line, above ox_lib, o-link and anything that needs ox_lib:
   ```cfg
   ensure oxide-helptext
   ensure ox_lib
   ```
4. **Optional: add the ox_lib line** below, so scripts that use ox_lib's text UI show their prompts through oxide-helptext.
5. **Restart your server.**

The full walkthrough is in the [Installation Guide](docs/INSTALLATION.md).

## ox_lib Compatibility

Most scripts show prompts with `lib.showTextUI`. To send those through oxide-helptext as well, add this line to the very end of **ox_lib's** `fxmanifest.lua`:

```lua
client_script '@oxide-helptext/compat/ox_lib.lua'
```

Each script's ox_lib prompt then belongs to that script, and `lib.hideTextUI` only hides that script's prompt. When oxide-helptext is stopped, ox_lib's own text UI takes over again.

Updating ox_lib replaces its `fxmanifest.lua`, so add the line again after every ox_lib update.

## Usage

Through [o-link](https://github.com/Oxide-Studios/o-link), which keeps your script working with other text UI resources too:

```lua
olink = exports['o-link']:olink()

olink.helptext.Show('[E] Open Trunk')
olink.helptext.Hide()
```

With the export directly:

```lua
exports['oxide-helptext']:Show({
    id = 'trunk',                  -- optional: lets one script keep several prompts open
    title = 'Vehicle',
    icon = 'fa-solid fa-car',
    keys = {
        { key = 'E', label = 'Open Trunk', control = 38 },  -- badge shows the player's binding
        { key = 'G', label = 'Lock' },
    },
})

exports['oxide-helptext']:Hide('trunk')
```

Calling `Show` again with the same prompt does nothing, so it is safe inside a loop that runs every frame. Every export, format and rule is in the [API Reference](docs/API.md).

## Documentation

| Document | Description |
|----------|-------------|
| [Installation](docs/INSTALLATION.md) | Download, start order, ox_lib and o-link setup |
| [Configuration](docs/CONFIGURATION.md) | Every option in `shared/config.lua` |
| [API Reference](docs/API.md) | Prompt formats, exports, o-link and ox_lib behaviour |
| [Troubleshooting](docs/TROUBLESHOOTING.md) | Console messages and common problems |

## Dependencies

| Resource | Required | Purpose |
|----------|----------|---------|
| [ox_lib](https://github.com/overextended/ox_lib) | No | Only needed if you want `lib.showTextUI` prompts to use oxide-helptext |
| [o-link](https://github.com/Oxide-Studios/o-link) | No | Bridge that lets o-link scripts show prompts through oxide-helptext (1.9.2 or newer) |

oxide-helptext itself needs nothing else to run.

## Building from Source

The built UI (`web/dist`) is not stored in this repository. The release zip already contains it. To build it yourself, install [Node.js](https://nodejs.org/) (the release build uses version 20), then run:

```bash
cd web
npm ci
npm run build
```

The UI is written to `web/dist`. See [Building from Source](docs/INSTALLATION.md#building-from-source) for details.

## License

MIT. Copyright (c) 2026 Oxide Studios. See [LICENSE](LICENSE).
