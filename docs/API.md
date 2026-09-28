# API Reference

This page is for developers who want to show prompts from their own scripts. Server owners only need [Installation](INSTALLATION.md) and [Configuration](CONFIGURATION.md).

## Table of Contents
- [Quick Start](#quick-start)
- [Text Prompts](#text-prompts)
- [Formatting](#formatting)
- [Structured Prompts](#structured-prompts)
- [Key Badges](#key-badges)
- [Positions](#positions)
- [Ownership and IDs](#ownership-and-ids)
- [Repeating, Updating and Hiding](#repeating-updating-and-hiding)
- [Stacking](#stacking)
- [Client Exports](#client-exports)
- [Server Exports](#server-exports)
- [Using o-link](#using-o-link)
- [ox_lib Compatibility](#ox_lib-compatibility)
- [Integration Examples](#integration-examples)
- [Next Steps](#next-steps)

## Quick Start

```lua
-- client
exports['oxide-helptext']:Show('[E] Open Trunk')
exports['oxide-helptext']:Hide()

-- server
exports['oxide-helptext']:Show(source, '[E] Open Trunk')
exports['oxide-helptext']:Hide(source)
```

A prompt is either a **string** or a **structured table**. Both can be sent from the client or the server, directly or through [o-link](#using-o-link).

## Text Prompts

A string prompt uses the format most text UI scripts already send. Anything in square brackets becomes a key badge.

| You send | On screen |
|----------|-----------|
| `'[E] Open Trunk'` | Badge **E**, then "Open Trunk" |
| `'[E] - Open Trunk'` | Same as above. A `-` or `:` right after a badge is dropped when a space follows it |
| `'[E]: Open Trunk'` | Same as above |
| `'Press [E] to open'` | "Press", badge **E**, "to open" on one line |
| `'[E] Smoke · [H] Stop'` | Both on one line, with a thin divider between them |
| `'[E] Open \| [G] Lock'` | Two lines: **E** Open, then **G** Lock |
| `'[E] Open~n~[G] Lock'` | Two lines, same as above |

Rules:
- **Badges** - The text inside `[...]` is trimmed and upper-cased, so `[e]` shows as **E**. Any text works (`[LMB]`, `[F5]`), but brackets cannot be nested.
- **Dividers** - `·` (the middle dot, U+00B7) draws a divider on the same line. A divider at the start or end of a line is dropped, and several in a row count as one.
- **New lines** - `|`, `~n~`, a newline character (`\n`) and `<br>` (also `<br/>` and `<br />`) each start a new line. Because `|` always starts a new line, a prompt cannot show a literal `|`.
- **Empty lines** are skipped.

## Formatting

Text can use bold and GTA colour codes:

| Code | Effect |
|------|--------|
| `**text**` | Bold |
| `~h~` | Turns bold on or off |
| `~r~` | Red |
| `~g~` | Green |
| `~b~` | Blue |
| `~y~` | Yellow |
| `~o~` | Orange |
| `~p~` | Purple |
| `~c~` or `~m~` | Grey |
| `~s~` or `~w~` | Back to the normal colour |

- Codes work in upper or lower case (`~G~` is the same as `~g~`).
- Any other single-letter code, such as `~u~`, is removed and has no effect.
- Longer GTA tokens such as `~INPUT_CONTEXT~` are **not** converted and show exactly as typed. Use `[E]`, or a `keys` row with a `control` (see [Key Badges](#key-badges)).
- **Formatting resets at every badge, divider and new line.** Put the codes inside each piece of text:
  ```lua
  exports['oxide-helptext']:Show('[E] ~g~Buy~s~ · [G] ~r~Sell')
  ```
- **HTML is never rendered.** Tags show as plain text, except `<br>`, which starts a new line.

## Structured Prompts

A table gives you a title, an icon and key rows:

```lua
exports['oxide-helptext']:Show({
    id = 'trunk',
    title = 'Vehicle',
    icon = 'fa-solid fa-car',
    text = 'Parked outside',
    keys = {
        { key = 'E', label = 'Open Trunk', control = 38 },
        { key = 'G', label = 'Lock' },
    },
    position = 'right-center',
})
```

| Field | Type | Description |
|-------|------|-------------|
| `id` | any | Optional. Lets one resource keep several prompts open. See [Ownership and IDs](#ownership-and-ids) |
| `title` | string | Optional. A small heading, shown in capitals above the rest. Plain text: formatting codes and badges are not read |
| `icon` | string | Optional. A Font Awesome class string, shown in a square on the left of the card |
| `text` | string | Optional. Body text in the [text prompt](#text-prompts) format: badges, formatting and new lines all work |
| `message` | string | Optional. Used instead of `text` when `text` is not set |
| `keys` | table | Optional. A list of key rows, described below |
| `position` | string | Optional. Takes the place of the `position` argument. When set, the argument is ignored, even if this value is not a valid position |

Each entry in `keys` becomes its own line, below the text, in list order:

| Field | Type | Description |
|-------|------|-------------|
| `key` | string | The badge label, such as `'E'`. Upper-cased. Also the fallback label when `control` is set |
| `label` | string | Optional. Text after the badge. Formatting codes and `·` dividers work. Badges and new lines are not read |
| `control` | number | Optional. A [game control](https://docs.fivem.net/docs/game-references/controls/) index, such as `38`. The badge shows the player's own binding and lights up with that control |

A row that ends up with no badge is skipped. That happens when `key` is missing and `control` has no printable binding.

**Icons.** The UI bundles Font Awesome Free 7 (solid, regular and brands styles), so icons work without internet access. Pass the full class string: `'fa-solid fa-car'`, `'fas fa-car'`, `'fa-regular fa-bell'` or `'fa-brands fa-discord'`. A bare name such as `'car'` shows nothing, and Font Awesome Pro icons are not included.

**Empty prompts.** A structured prompt with no title, no text lines and no key rows has nothing to show, so it hides instead (see [Repeating, Updating and Hiding](#repeating-updating-and-hiding)). An icon alone does not count.

## Key Badges

**The label.** A badge shows the text from `[...]` or from `key`, in capitals. When a key row has a `control`, the badge shows the key the player has bound to that control instead, read each time the prompt is built. If that binding has no printable name (a mouse button, or a controller glyph), the badge falls back to `key`. Always pass `key` together with `control`.

**Lighting up.** While `Config.KeyFeedback` is `true`, a badge lights up while the player holds its key:

- **With a `control`**, the badge lights while that game control is pressed, whatever key it is bound to. It still lights while your script has the control disabled.
- **Without a `control`**, the badge lights while the physical key with that label is held. These labels light up:
  - `A` to `Z`
  - `0` to `9` (the number row)
  - `F1` to `F12`
  - `SPACE`, `ENTER`, `RETURN`, `BACKSPACE`, `BACK`, `TAB`, `ESC`, `SHIFT`, `CTRL`, `ALT`, `CAPS`
  - `UP`, `DOWN`, `LEFT`, `RIGHT`
  - `INS`, `DEL`, `HOME`, `END`, `PGUP`, `PGDN`
- **Any other label** (`LMB`, `RMB`, `SCROLL`, `HOLD E`) shows normally but never lights up.

A plain `[E]` lights up on the physical E key, even if the player has moved that action to another key. When the action is a game control, use a key row with `control` so both the label and the lighting follow the player's binding.

Only badges that are on screen are checked. Nothing is checked while no prompt is open or while the pause menu hides the prompts.

## Positions

| Position | Short name |
|----------|------------|
| `right-center` | `right` |
| `left-center` | `left` |
| `top-center` | `top` |
| `bottom-center` | `bottom` |
| `top-left` | - |
| `top-right` | - |
| `bottom-left` | - |
| `bottom-right` | - |

- Names are not case-sensitive.
- A missing or unknown position uses `Config.DefaultPosition`. No warning is printed for a position sent by a script.
- When `Config.ForcePosition` is set, every prompt goes there and the position you send is ignored.
- A structured prompt's `position` field takes the place of the `position` argument.

## Ownership and IDs

Every prompt belongs to the resource that showed it, its **owner**.

- Each owner has one **default slot** (no `id`) and one slot for each `id` it uses. String prompts always use the default slot.
- `Show` without an `id` replaces the owner's default prompt. `Show` with an `id` replaces only the prompt with that `id`.
- `Hide(id)` hides the owner's prompt with that `id`. `Hide()` with no id hides **all** of the owner's prompts, including the ones with ids.
- A resource cannot hide another resource's prompts with `Hide`. Only [`HideAll`](#hideall) clears everything.
- When a resource stops, all of its prompts are removed.
- An `id` is compared as a string, so `1` and `'1'` are the same prompt.

**Server prompts.** A prompt shown with a server export belongs to the server resource that called the export. A resource has the same name on the client and the server, so its client scripts can hide prompts its server scripts showed, and the other way round.

**The `owner` parameter.** The client exports take an optional last parameter, `owner`, which is the resource the prompt belongs to. It exists for bridges: o-link and the ox_lib compatibility file use it to pass along the script that called them, so ownership, `Hide` and stop cleanup follow that script instead of the bridge. Normal scripts should leave it out.

## Repeating, Updating and Hiding

- **Repeating is free.** Calling `Show` again with the same prompt redraws nothing and plays no sound, so it is safe to call every frame.
- **Updating.** Calling `Show` with new content for the same slot updates the prompt in place. It keeps its place in the stack, and the sound does not play again.
- **An empty message hides.** `Show('')`, `Show(nil)`, or a structured prompt with nothing to show, hides the prompt in that slot instead of showing:
  - Without an `id`, it hides only the calling resource's default prompt. Prompts it showed with an `id` stay.
  - With an `id`, it hides only that `id`.

## Stacking

- Prompts in the same position stack in a column, older above newer.
- Each position shows at most `Config.MaxVisible` prompts (default `4`). When more are open, the newest show. The rest wait and come back when a newer prompt closes.
- "Newest" means the prompt that first appeared most recently. Updating an open prompt does not move it.
- `IsOpen` returns `true` for a waiting prompt too. It reports that the prompt is open, not that it is on screen.

---

## Client Exports

### Show

Shows or updates a prompt owned by the calling resource.

```lua
exports['oxide-helptext']:Show(message, position, owner)
```

**Parameters**:
| Name | Type | Description |
|------|------|-------------|
| message | string \| table | A [text prompt](#text-prompts) or a [structured prompt](#structured-prompts). Empty hides (see [above](#repeating-updating-and-hiding)) |
| position | string \| nil | Optional. See [Positions](#positions). Ignored when `message` is a table with a `position` field |
| owner | string \| nil | Optional. Defaults to the calling resource. For bridges only (see [Ownership and IDs](#ownership-and-ids)) |

**Returns**: nothing

---

### Hide

Hides one of the calling resource's prompts, or all of them.

```lua
exports['oxide-helptext']:Hide(id, owner)
```

**Parameters**:
| Name | Type | Description |
|------|------|-------------|
| id | any | Optional. The prompt's `id`. When left out, every prompt the resource holds is hidden |
| owner | string \| nil | Optional. Defaults to the calling resource. For bridges only |

**Returns**: nothing

---

### HideAll

Hides every prompt on this player's screen, from every resource, including ox_lib prompts.

```lua
exports['oxide-helptext']:HideAll()
```

**Returns**: nothing

This does not block new prompts. A script that calls the export every frame shows its prompt again on the next frame. An ox_lib prompt stays hidden until its script hides it and shows it again, or shows different text, because ox_lib skips repeated calls with the same text (see [ox_lib Compatibility](#ox_lib-compatibility)).

---

### IsOpen

Checks whether the calling resource has a prompt open.

```lua
local open = exports['oxide-helptext']:IsOpen(id, owner)
```

**Parameters**:
| Name | Type | Description |
|------|------|-------------|
| id | any | Optional. The prompt's `id`. When left out, checks whether the resource has any prompt open |
| owner | string \| nil | Optional. Defaults to the calling resource. For bridges only |

**Returns**: `boolean` - `true` if the prompt is open. The prompt may still be off screen because of `Config.MaxVisible` or the pause menu.

---

## Server Exports

The server exports send the prompt to one player. The prompt belongs to the server resource that called the export. Pass `-1` as `source` to send to every player.

### Show

```lua
exports['oxide-helptext']:Show(source, message, position)
```

**Parameters**:
| Name | Type | Description |
|------|------|-------------|
| source | number | The player's server id |
| message | string \| table | A [text prompt](#text-prompts) or a [structured prompt](#structured-prompts) |
| position | string \| nil | Optional. See [Positions](#positions) |

**Returns**: nothing

---

### Hide

```lua
exports['oxide-helptext']:Hide(source, id)
```

**Parameters**:
| Name | Type | Description |
|------|------|-------------|
| source | number | The player's server id |
| id | any | Optional. The prompt's `id`. When left out, every prompt the calling resource holds on that player's screen is hidden |

**Returns**: nothing

---

### HideAll

Hides every prompt on that player's screen, from every resource.

```lua
exports['oxide-helptext']:HideAll(source)
```

**Parameters**:
| Name | Type | Description |
|------|------|-------------|
| source | number | The player's server id |

**Returns**: nothing

There is no server version of `IsOpen`. The server exports travel to the client through the events `oxide:helptext:show`, `oxide:helptext:hide` and `oxide:helptext:hideAll`. Use the exports rather than triggering these events yourself, so the prompt is owned by your resource.

---

## Using o-link

[o-link](https://github.com/Oxide-Studios/o-link) 1.9.2 and newer use oxide-helptext as their `helptext` provider when oxide-helptext is running before o-link starts. Scripts written against o-link keep working on servers that use a different text UI.

```lua
olink = exports['o-link']:olink()

-- client
olink.helptext.Show('[E] Open Trunk')
olink.helptext.Show({ id = 'trunk', title = 'Vehicle', keys = { { key = 'E', label = 'Open Trunk' } } })
olink.helptext.Hide('trunk')   -- one prompt
olink.helptext.Hide()          -- all of this resource's prompts

-- server
olink.helptext.Show(source, '[E] Open Trunk')
olink.helptext.Hide(source)
```

| Side | Function |
|------|----------|
| Client | `olink.helptext.Show(message, position?)`, `olink.helptext.Hide(id?)` |
| Server | `olink.helptext.Show(src, message, position?)`, `olink.helptext.Hide(src, id?)` |

- o-link passes your resource along as the owner, so ownership, ids and stop cleanup work exactly as with the direct exports. Server calls are owned by the calling server resource.
- `HideAll` and `IsOpen` are not available through o-link.
- **Other providers.** When o-link uses a different text UI, a structured prompt is flattened into one string, for example `Vehicle: Parked outside  |  [E] Open Trunk  |  [G] Lock`. The icon is dropped. Those providers show one prompt at a time, and `Hide(id)` hides whatever is showing.

## ox_lib Compatibility

With the line `client_script '@oxide-helptext/compat/ox_lib.lua'` at the end of ox_lib's `fxmanifest.lua` (see [Installation](INSTALLATION.md#ox_lib-compatibility)), ox_lib's text UI is routed through oxide-helptext:

- **`lib.showTextUI(text, options)`** shows an oxide-helptext prompt owned by the script that called it. It uses its own slot (the id `'ox_lib'`), so it never replaces that script's other oxide-helptext prompts.
- **`lib.hideTextUI()`** hides only the calling script's ox_lib prompt.
- **Options carried over**: `text`, `position` and `icon`. ox_lib icon formats are converted to Font Awesome classes: `'hand'`, `'fa-hand'` and `{ 'fas', 'hand' }` all become `'fa-solid fa-hand'`, and `'fas fa-hand'` is used as-is. `iconColor`, `style` and `alignIcon` are not used; the prompt uses oxide-helptext's look.
- **Markdown**: only `**bold**` is read. Other markdown shows as typed.
- **`lib.isTextUIOpen()`** still answers from ox_lib's own record. ox_lib keeps one record for all scripts, so it does not know about the separate per-script prompts. For example, after one script calls `lib.hideTextUI()`, it returns `false` even while another script's ox_lib prompt is still on screen.
- ox_lib skips a `lib.showTextUI` call whose text matches the last text it showed, from any script. Two scripts showing the exact same text at the same moment can therefore end up with one prompt between them.
- **When oxide-helptext is not running**, ox_lib's own text UI shows the prompt as usual. When oxide-helptext starts while an ox_lib prompt is open, the most recent one moves across. When oxide-helptext stops, ox_lib's own UI shows it again.
- If handing a prompt to oxide-helptext fails, the prompt falls back to ox_lib's own UI and the error is printed once. See [Console Messages](TROUBLESHOOTING.md#console-messages).

## Integration Examples

### Prompt near a point, shown every frame

`Show` is free to repeat, so a proximity loop can call it every frame without tracking state for the show side.

```lua
local trunk = vec3(215.8, -810.1, 30.7)
local shown = false

CreateThread(function()
    while true do
        local sleep = 500
        local distance = #(GetEntityCoords(PlayerPedId()) - trunk)

        if distance < 2.0 then
            sleep = 0
            exports['oxide-helptext']:Show('[E] Open Trunk')
            shown = true

            if IsControlJustPressed(0, 38) then  -- 38 = E by default
                print('trunk opened')
            end
        elseif shown then
            exports['oxide-helptext']:Hide()
            shown = false
        end

        Wait(sleep)
    end
end)
```

### Two prompts from one resource

Ids let one resource keep separate prompts open and hide them one at a time.

```lua
exports['oxide-helptext']:Show({
    id = 'engine',
    icon = 'fa-solid fa-key',
    keys = { { key = 'Y', label = 'Toggle Engine' } },
})

exports['oxide-helptext']:Show({
    id = 'seatbelt',
    keys = { { key = 'B', label = 'Seatbelt ~r~off' } },
}, 'bottom-right')

exports['oxide-helptext']:Hide('seatbelt')  -- the engine prompt stays
exports['oxide-helptext']:Hide()            -- hides the engine prompt too
```

### Badge that follows the player's binding

```lua
exports['oxide-helptext']:Show({
    title = 'Garage',
    keys = {
        { key = 'E', label = 'Store Vehicle', control = 38 },   -- INPUT_PICKUP
        { key = 'H', label = 'Open Garage', control = 74 },     -- INPUT_VEH_HEADLIGHT
    },
})
```

If the player moved `INPUT_PICKUP` to F, the first badge shows **F** and lights up when F is pressed.

### Showing a prompt from the server

```lua
RegisterNetEvent('myjob:server:enteredDepot', function()
    local src = source
    exports['oxide-helptext']:Show(src, {
        id = 'depot',
        title = 'Depot',
        text = 'Deliveries waiting: **3**',
        keys = { { key = 'E', label = 'Start Shift' } },
    })
end)

RegisterNetEvent('myjob:server:leftDepot', function()
    exports['oxide-helptext']:Hide(source, 'depot')
end)
```

## Next Steps

- [Configuration](CONFIGURATION.md) - default and forced positions, stacking limit, key feedback and sound
- [Troubleshooting](TROUBLESHOOTING.md) - console messages and common problems
- [Installation](INSTALLATION.md) - start order, ox_lib and o-link setup
