# oxide-helptext

On-screen interaction prompts ("[E] Open Trunk") for FiveM. Standalone, and the `helptext`
provider for o-link.

- Key badges from the strings scripts already send: `[E] Open`, `[E] - Open`,
  `[E] Smoke · [H] Stop`, `[E] Open | [G] Lock`, `Press [E] to open`.
- Prompts from different resources stack instead of replacing each other. Each resource can only
  hide its own prompts, and a resource's prompts disappear when it stops.
- A badge lights up while the player holds its key.
- Optional title, icon and a list of key rows per prompt.
- A key tied to a game control shows the player's own binding for that control.
- Safe text: no HTML is ever rendered. `**bold**` and GTA colour codes (`~g~`, `~r~`, ...) work.
- No work while no prompt is open. Hidden while the pause menu is open.

## Installation

Start it **before** o-link, so o-link picks it as the helptext provider:

```cfg
ensure ox_lib
ensure oxide-helptext
ensure o-link
```

It has no dependencies of its own.

## Usage

Through o-link (recommended, keeps your resource framework-agnostic):

```lua
olink.helptext.Show('[E] Open Trunk')
olink.helptext.Hide()
```

Structured prompt:

```lua
olink.helptext.Show({
    id = 'trunk',                   -- optional: several prompts per resource
    title = 'Vehicle',              -- optional
    icon = 'fa-solid fa-car',       -- optional, Font Awesome 6 class
    text = 'Parked outside',        -- optional
    keys = {
        { key = 'E', label = 'Open Trunk', control = 38 },
        { key = 'G', label = 'Lock' },
    },
    position = 'right-center',      -- optional
})

olink.helptext.Hide('trunk')        -- hide one prompt
olink.helptext.Hide()               -- hide every prompt this resource shows
```

Calling `Show` again with the same content does nothing, so it is safe inside a per-frame loop.
Showing an empty message hides the prompt.

### Direct exports

Client:

| Export | Description |
|--------|-------------|
| `Show(message, position?)` | Show or update a prompt |
| `Hide(id?)` | Hide one prompt, or all of the calling resource's prompts |
| `HideAll()` | Hide every prompt from every resource |
| `IsOpen(id?)` | Whether the calling resource has that prompt (or any prompt) open |

Server:

| Export | Description |
|--------|-------------|
| `Show(source, message, position?)` | Show a prompt on one player's screen |
| `Hide(source, id?)` | Hide the calling resource's prompt(s) for that player |
| `HideAll(source)` | Hide every prompt for that player |

### Positions

`right-center` (default), `left-center`, `top-center`, `bottom-center`, `top-left`, `top-right`,
`bottom-left`, `bottom-right`. The short names `left`, `right`, `top` and `bottom` also work.

## Configuration

`shared/config.lua`:

| Option | Default | Description |
|--------|---------|-------------|
| `DefaultPosition` | `'right-center'` | Position when a script doesn't choose one |
| `ForcePosition` | `false` | Set a position to draw every prompt there |
| `MaxVisible` | `4` | Most prompts shown at once per position; the newest win |
| `HideInPauseMenu` | `true` | Hide prompts while the pause menu is open |
| `KeyFeedback` | `true` | Light up a badge while its key is held |
| `Sound` | off | Sound played when a new prompt appears |

## Building the UI

```bash
cd web
npm install
npm run build
```
