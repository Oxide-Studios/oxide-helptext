# Troubleshooting

## Table of Contents
- [Where to Find Messages](#where-to-find-messages)
- [Console Messages](#console-messages)
- [Prompts Do Not Appear at All](#prompts-do-not-appear-at-all)
- [Prompts Still Look Like ox_lib's](#prompts-still-look-like-ox_libs)
- [o-link Prompts Lose Their Title or Replace Each Other](#o-link-prompts-lose-their-title-or-replace-each-other)
- [Icons Are Missing](#icons-are-missing)
- [A Prompt Will Not Hide](#a-prompt-will-not-hide)
- [Positions Are Ignored](#positions-are-ignored)
- [Some Prompts Are Missing When Several Are Open](#some-prompts-are-missing-when-several-are-open)
- [Key Badges Do Not Light Up](#key-badges-do-not-light-up)
- [Prompts Disappear After Restarting oxide-helptext](#prompts-disappear-after-restarting-oxide-helptext)
- [Getting Help](#getting-help)

## Where to Find Messages

oxide-helptext has no debug mode. It prints a few warnings, each only once, in yellow, in the **client console**, not the server console. To open it, press **F8** in game. Every message starts with `[oxide-helptext]`.

## Console Messages

| Message | What it means | What to do |
|---------|---------------|------------|
| `[oxide-helptext] The UI never loaded, so prompts cannot be drawn. Build web/ (npm run build) or install the release zip.` | A script tried to show a prompt, and 10 seconds later the prompt screen still had not loaded. This almost always means the built UI (`web/dist`) is missing | See [Prompts Do Not Appear at All](#prompts-do-not-appear-at-all) |
| `[oxide-helptext] Config.DefaultPosition "<value>" is not a valid position and is ignored` | `Config.DefaultPosition` in `shared/config.lua` is not a position name. Prompts without a position use `right-center` | Fix the value. See [Positions](CONFIGURATION.md#positions) for the valid names |
| `[oxide-helptext] Config.ForcePosition "<value>" is not a valid position and is ignored` | `Config.ForcePosition` is not `false` and not a position name (for example `true` or a typo). Prompts are not forced anywhere | Set it to `false` or to a valid position name |
| `[oxide-helptext] Config.MaxVisible "<value>" must be a whole number of 1 or more; using 4` | `Config.MaxVisible` is missing, not a number, or below 1 | Set it to a whole number such as `4` |
| `[oxide-helptext] compat/ox_lib.lua belongs in ox_lib's fxmanifest.lua, not <resource>'s` | The ox_lib line was added to the `fxmanifest.lua` of `<resource>` instead of ox_lib's. It does nothing there | Remove the line from that resource and add it to ox_lib's `fxmanifest.lua`. See [ox_lib Compatibility](INSTALLATION.md#ox_lib-compatibility) |
| `[oxide-helptext] a <resource> prompt fell back to ox_lib's text UI: <error>` | An ox_lib prompt from `<resource>` could not be handed to oxide-helptext, so ox_lib showed it with its own look instead. Each different error is printed once | [Report it](#getting-help) with the full line |

## Prompts Do Not Appear at All

**Symptoms**:
- No prompt shows anywhere, from any script.
- After you added the ox_lib line, prompts from ox_lib scripts disappeared too.
- The F8 console shows `The UI never loaded, so prompts cannot be drawn.`

**Solutions**:

1. **Install the release zip.** The most common cause is a copy of the repository without the built UI, from the green **Code > Download ZIP** button or `git clone`. Check that this file exists:
   ```
   resources/oxide-helptext/web/dist/index.html
   ```
   If it is missing, download `oxide-helptext.zip` from the [latest release](https://github.com/Oxide-Studios/oxide-helptext/releases/latest), replace the folder, and restart your server. If you want to use the source, [build it](INSTALLATION.md#building-from-source) instead.

   While the UI is missing, ox_lib prompts vanish too if you added the ox_lib line, because they are handed to oxide-helptext. Stopping oxide-helptext brings back ox_lib's own text UI until you fix it.

2. **Check the resource is running.** Type `ensure oxide-helptext` in your server console. If the console says it cannot find the resource, check the folder:
   - It must be named exactly `oxide-helptext`, not `oxide-helptext-main`.
   - `fxmanifest.lua` must sit directly inside it, not in a second `oxide-helptext` folder inside the first.

3. **Close the pause menu.** Prompts fade out while the pause menu is open. This is normal, and controlled by `Config.HideInPauseMenu`.

4. **Check the script sends something.** A prompt with no text and no keys (only an icon, for example) is treated as "hide". If only one script's prompts are missing, contact that script's author.

## Prompts Still Look Like ox_lib's

**Symptoms**:
- Prompts from ox_lib scripts still use ox_lib's own style, while o-link scripts or direct calls use oxide-helptext.

**Solutions**:

1. **Check the ox_lib line.** Open `ox_lib/fxmanifest.lua` and check that the end of the file contains:
   ```lua
   client_script '@oxide-helptext/compat/ox_lib.lua'
   ```
   If it is missing, add it, save, and restart your server.

2. **Did you update ox_lib?** Every ox_lib update replaces its `fxmanifest.lua` and removes the line. Add it again after each update.

3. **Check the start order.** `ensure oxide-helptext` must come before `ensure ox_lib` in `server.cfg`. It must also come before any resource that depends on ox_lib, such as some maps and MLOs, because those start ox_lib early. See [Start Order](INSTALLATION.md#start-order).

4. **Restart the whole server.** ox_lib only reads its `fxmanifest.lua` when it starts. After adding the line, a full server restart is the safest way to make sure it is picked up.

5. **Check the F8 console.** If you see `compat/ox_lib.lua belongs in ox_lib's fxmanifest.lua, not <resource>'s`, the line is in the wrong file. If you see `a <resource> prompt fell back to ox_lib's text UI`, see [Getting Help](#getting-help).

**Notes**:
- The ox_lib line only covers scripts that call `lib.showTextUI`. A script that draws its own prompt UI, or uses a different text UI resource, keeps its own look.

## o-link Prompts Lose Their Title or Replace Each Other

**Symptoms**:
- Prompts from o-link scripts have no title or icon.
- Prompts from different o-link scripts replace each other instead of stacking.

**Solutions**:

1. **Check the start order.** o-link picks its text UI when it starts. If oxide-helptext was not running yet, o-link chose another one. Put `ensure oxide-helptext` above `ensure o-link` (and above ox_lib) and restart your server.

2. **Check your o-link version.** o-link needs version 1.9.2 or newer to use oxide-helptext. Update o-link if it is older.

3. **Another text UI is running.** If you also run a text UI resource that o-link supports, such as okokTextUI or jg-textui, set `HelpText = 'oxide-helptext'` in o-link's `config.lua`. See [o-link Setup](INSTALLATION.md#o-link-setup).

## Icons Are Missing

**Symptoms**:
- A prompt shows an empty square where the icon should be, or no icon at all.

**Solutions**:

1. **Use the full icon class.** Icons need a style and a name, such as `'fa-solid fa-car'` or `'fas fa-car'`. A bare `'car'` shows nothing. (Only prompts coming from ox_lib accept short names, because they are converted.)

2. **Use a free icon.** The UI includes Font Awesome Free 7 (solid, regular and brands). Pro icons are not included. Search the icon on [fontawesome.com](https://fontawesome.com/icons) with the Free filter turned on to check it exists.

3. **Text prompts have no icon.** A plain string such as `'[E] Open'` cannot carry an icon. The script must send a [structured prompt](API.md#structured-prompts) with an `icon` field.

## A Prompt Will Not Hide

**Symptoms**:
- A prompt stays on screen after you walk away or finish the action.

**Solutions**:

1. **Restart the script that owns it.** Every prompt belongs to the resource that showed it, and it is removed when that resource stops. `restart <resource>` in your server console clears it. As a last resort, `restart oxide-helptext` clears every prompt.

2. **For developers: hide from the same resource.** `Hide` only reaches the calling resource's own prompts. Calling it from a different resource does nothing to them.

3. **For developers: match the id.** A prompt shown with `id = 'trunk'` is hidden by `Hide('trunk')` or `Hide()`. `Hide('other')` does not touch it.

4. **For developers: stop showing it.** A loop that keeps calling `Show` after `Hide` brings the prompt straight back on the next frame.

**Notes**:
- With the ox_lib line, `lib.hideTextUI` only hides the calling script's ox_lib prompt. Prompts from other scripts stay on purpose.

## Positions Are Ignored

**Symptoms**:
- Every prompt appears in the same place, whatever position scripts ask for.
- A script's prompt shows on the right instead of where the script says.

**Solutions**:

1. **Check `Config.ForcePosition`.** In `shared/config.lua`, anything other than `false` sends every prompt to one position. Set it back to `false`:
   ```lua
   Config.ForcePosition = false
   ```

2. **Check the position name.** An unknown position name silently falls back to `Config.DefaultPosition`. Only the names listed in [Positions](CONFIGURATION.md#positions) work. If the typo is in your config file, the F8 console shows `Config.DefaultPosition "<value>" is not a valid position and is ignored`.

3. **For developers: the table wins.** In a structured prompt, the table's own `position` field replaces the `position` argument.

4. **Another text UI is showing it.** If the prompt goes through o-link to a different text UI resource, that resource decides where it goes. See [o-link Prompts Lose Their Title or Replace Each Other](#o-link-prompts-lose-their-title-or-replace-each-other).

## Some Prompts Are Missing When Several Are Open

**Symptoms**:
- With many prompts open in one spot, some do not show, then appear when others close.

**Solutions**:

1. **This is `Config.MaxVisible`.** Each position shows at most `Config.MaxVisible` prompts (default `4`), newest first. The others wait and come back when a newer prompt closes. Raise the number if you want more:
   ```lua
   Config.MaxVisible = 6
   ```

## Key Badges Do Not Light Up

**Symptoms**:
- Holding a key does not light up its badge.

**Solutions**:

1. **Check `Config.KeyFeedback`.** It must be `true` in `shared/config.lua`.

2. **Check the label.** Only letters, numbers, `F1` to `F12` and a fixed list of named keys light up. Labels such as `LMB` or `HOLD E` show but never light. See [Key Badges](API.md#key-badges) for the full list.

3. **Rebound keys.** A plain `[E]` badge lights up on the physical E key, not on whatever key the player bound to the action. Scripts can fix this with a key row that has a `control` (see [Key Badges](API.md#key-badges)).

## Prompts Disappear After Restarting oxide-helptext

**Symptoms**:
- After `restart oxide-helptext`, some prompts are gone until you walk away and come back.

**Solutions**:

1. **This is expected.** Restarting oxide-helptext clears every prompt. Scripts that show their prompt in a loop bring it back at once, and an open ox_lib prompt moves back on its own. A prompt that a script showed only once returns the next time that script shows it. Walking away and back usually does it. Otherwise restart that script, or reconnect.

## Getting Help

If none of the above fixes your problem:

1. Press **F8** in game and copy every line that starts with `[oxide-helptext]`.
2. Note the order of `ensure oxide-helptext`, `ensure ox_lib` and `ensure o-link` in your `server.cfg`, and whether you added the ox_lib line.
3. Note your oxide-helptext version (the `version` line in `fxmanifest.lua`) and, if you use them, your ox_lib and o-link versions.
4. Open an issue on [GitHub](https://github.com/Oxide-Studios/oxide-helptext/issues) with all of the above.

## Next Steps

- [Installation](INSTALLATION.md) - start order, ox_lib and o-link setup
- [Configuration](CONFIGURATION.md) - every option in `shared/config.lua`
- [API Reference](API.md) - prompt formats, ownership and exports
