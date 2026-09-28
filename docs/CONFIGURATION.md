# Configuration

## Table of Contents
- [Config File: shared/config.lua](#config-file-sharedconfiglua)
  - [All Settings](#all-settings)
  - [Positions](#positions)
  - [Stacking](#stacking)
  - [Pause Menu and Key Feedback](#pause-menu-and-key-feedback)
  - [Sound](#sound)
- [Next Steps](#next-steps)

## Config File: shared/config.lua

Every setting lives in `oxide-helptext/shared/config.lua`. Open it in any text editor, change the values, and save.

Changes take effect after oxide-helptext restarts. Type `restart oxide-helptext` in your server console, or restart the server. Prompts on screen disappear for a moment during the restart. Scripts that show their prompt in a loop bring it back straight away, and an open ox_lib prompt moves back on its own. A prompt that a script showed only once stays gone until that script shows it again.

### All Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `Config.DefaultPosition` | string | `'right-center'` | Where a prompt appears when the script showing it does not pick a position, or picks one that does not exist |
| `Config.ForcePosition` | `false` or string | `false` | Set to a position to draw every prompt there, whatever position a script asks for |
| `Config.MaxVisible` | number | `4` | Most prompts shown at once in one position. When more are open, the newest ones show |
| `Config.HideInPauseMenu` | boolean | `true` | Hide prompts while the pause menu is open |
| `Config.KeyFeedback` | boolean | `true` | Light up a key badge while the player holds that key |
| `Config.Sound.enabled` | boolean | `false` | Play a sound when a new prompt appears |
| `Config.Sound.name` | string | `'HIGHLIGHTED_DEFAULT'` | GTA frontend sound name to play |
| `Config.Sound.set` | string | `'HUD_FRONTEND_DEFAULT_SOUNDSET'` | GTA sound set the sound name belongs to |

The default file:

```lua
Config = {}

Config.DefaultPosition = 'right-center'
Config.ForcePosition = false
Config.MaxVisible = 4
Config.HideInPauseMenu = true
Config.KeyFeedback = true

Config.Sound = {
    enabled = false,
    name = 'HIGHLIGHTED_DEFAULT',
    set = 'HUD_FRONTEND_DEFAULT_SOUNDSET',
}
```

### Positions

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `Config.DefaultPosition` | string | `'right-center'` | Position used when a script does not choose one, or chooses a name that is not in the list below |
| `Config.ForcePosition` | `false` or string | `false` | `false` lets each script choose. A position name sends every prompt from every script to that position |

These are the positions you can use:

| Position | Where it appears |
|----------|------------------|
| `right-center` | Middle of the right edge (the default) |
| `left-center` | Middle of the left edge |
| `top-center` | Top of the screen, centred |
| `bottom-center` | Bottom of the screen, centred |
| `top-left` | Top-left corner |
| `top-right` | Top-right corner |
| `bottom-left` | Left side, raised so it sits above the default minimap |
| `bottom-right` | Bottom-right corner |

The short names `left`, `right`, `top` and `bottom` also work. They mean `left-center`, `right-center`, `top-center` and `bottom-center`. Upper or lower case does not matter.

```lua
Config.DefaultPosition = 'bottom-center'  -- prompts without a position go to the bottom middle
Config.ForcePosition = 'right'            -- every prompt goes to the middle of the right edge
```

If either setting holds something that is not a position (a typo, or `true` for `Config.ForcePosition`), the setting is ignored and each player's F8 console shows a warning when the resource starts:

```
[oxide-helptext] Config.ForcePosition "true" is not a valid position and is ignored
```

An ignored `Config.DefaultPosition` falls back to `right-center`.

### Stacking

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `Config.MaxVisible` | number | `4` | Most prompts shown at the same time in one position. Use a whole number of 1 or more; anything else prints a warning and uses `4` |

When several prompts share a position, they stack in a column, older prompts above newer ones. The limit counts each position on its own: with the default of `4`, a player can see four prompts on the right and four more at the top at the same time.

When more prompts are open in a position than the limit allows, the newest ones show. The older ones are kept, not thrown away. They come back as soon as a newer prompt closes. "Newest" means the prompt that first appeared most recently. A script that changes the text of an open prompt does not move it up.

```lua
Config.MaxVisible = 2  -- never more than two prompts in the same spot
```

### Pause Menu and Key Feedback

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `Config.HideInPauseMenu` | boolean | `true` | `true` fades prompts out while the pause menu is open and brings them back when it closes. `false` leaves them on screen over the pause menu |
| `Config.KeyFeedback` | boolean | `true` | `true` lights up a badge while the player holds its key. `false` keeps badges unlit |

Both settings only do work while at least one prompt is open. With `Config.KeyFeedback = true`, oxide-helptext checks the keys of the badges on screen every frame. With `false`, it only checks the pause menu four times a second. Turn key feedback off if you want the lightest possible setup.

Which badges can light up is explained in the [API Reference](API.md#key-badges).

```lua
Config.HideInPauseMenu = true
Config.KeyFeedback = false  -- badges never light up
```

### Sound

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `Config.Sound.enabled` | boolean | `false` | `true` plays a sound when a new prompt appears |
| `Config.Sound.name` | string | `'HIGHLIGHTED_DEFAULT'` | Name of a GTA V frontend sound |
| `Config.Sound.set` | string | `'HUD_FRONTEND_DEFAULT_SOUNDSET'` | Sound set that the sound name belongs to |

The sound plays when a prompt appears. It does not play when a script changes the text of a prompt that is already open, or when a script repeats the same prompt. A prompt that is hidden and then shown again counts as new, so walking away from a door and back plays the sound again.

`name` and `set` must be a matching GTA V frontend sound and sound set. If the pair does not exist, no sound plays.

```lua
Config.Sound = {
    enabled = true,                          -- turn the sound on
    name = 'HIGHLIGHTED_DEFAULT',
    set = 'HUD_FRONTEND_DEFAULT_SOUNDSET',
}
```

## Next Steps

- [API Reference](API.md) - how scripts choose positions, ids and key badges
- [Troubleshooting](TROUBLESHOOTING.md) - positions ignored, prompts missing and console warnings
- [Installation](INSTALLATION.md) - start order, ox_lib and o-link setup
