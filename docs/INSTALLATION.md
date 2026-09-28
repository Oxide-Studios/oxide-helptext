# Installation Guide

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation Steps](#installation-steps)
- [Start Order](#start-order)
- [ox_lib Compatibility](#ox_lib-compatibility)
- [o-link Setup](#o-link-setup)
- [Building from Source](#building-from-source)
- [Verification](#verification)
- [Updating](#updating)
- [Next Steps](#next-steps)

## Prerequisites

oxide-helptext has no dependencies. It runs on its own, on any framework (QBCore, ESX, QBX or none at all), because it never talks to your framework.

These two resources are optional:

| Resource | Minimum Version | Purpose |
|----------|----------------|---------|
| [ox_lib](https://github.com/overextended/ox_lib) | - | Lets scripts that call `lib.showTextUI` show their prompts through oxide-helptext. See [ox_lib Compatibility](#ox_lib-compatibility). |
| [o-link](https://github.com/Oxide-Studios/o-link) | 1.9.2 | Bridge that lets o-link scripts show prompts through oxide-helptext. See [o-link Setup](#o-link-setup). |

## Installation Steps

1. **Download the release zip.** Go to the [latest release](https://github.com/Oxide-Studios/oxide-helptext/releases/latest). Under **Assets**, click `oxide-helptext.zip`.

   > **Use the release zip, not the repository.** The green **Code > Download ZIP** button and `git clone` give you the source code without the built UI (the `web/dist` folder is not stored in the repository). The resource starts, but no prompt ever appears. If you want to use the source anyway, see [Building from Source](#building-from-source).

2. **Extract it into your resources.** Open the zip and copy the `oxide-helptext` folder into your server's `resources` folder. You can put it in a sub-folder such as `resources/[standalone]/`.

   Check two things:
   - The folder is named exactly `oxide-helptext`. Not `oxide-helptext-main` or `oxide-helptext-1.0.0`. The ox_lib line and o-link both look for this exact name.
   - `fxmanifest.lua` sits directly inside it: `resources/oxide-helptext/fxmanifest.lua`. Not `resources/oxide-helptext/oxide-helptext/fxmanifest.lua`.

3. **Add it to your `server.cfg`.** `server.cfg` is the text file that tells your server which resources to start. It is usually in your server data folder, next to the `resources` folder. Open it and add this line near the top, as described in [Start Order](#start-order):
   ```cfg
   ensure oxide-helptext
   ```

4. **Optional: set up ox_lib.** If your server runs ox_lib, follow [ox_lib Compatibility](#ox_lib-compatibility). Most servers want this, because most scripts show their prompts through ox_lib.

5. **Save and restart.** Save every file you changed, then fully restart your server.

## Start Order

oxide-helptext must start **before ox_lib** and **before o-link**. The simplest way is to make it the first `ensure` line in your `server.cfg`:

```cfg
# 1. oxide-helptext - first, before ox_lib, o-link and anything that needs ox_lib
ensure oxide-helptext

# 2. ox_lib
ensure ox_lib

# 3. Your framework and your other scripts
# ...

# 4. o-link (only if you use it), before the scripts that use it
ensure o-link
```

Why this order matters:
- **ox_lib** reads the compatibility file from oxide-helptext when ox_lib starts. If ox_lib starts first, the file is not there yet, and ox_lib prompts keep ox_lib's own look.
- **o-link** checks which text UI resource is running at the moment it starts. If oxide-helptext is not running yet, o-link picks a different one.

**Watch out for resources that pull ox_lib in early.** When a resource depends on ox_lib, your server starts ox_lib the moment that resource starts, even if `ensure ox_lib` comes later in the file. Maps and MLOs often do this. If one of them sits above `ensure oxide-helptext`, ox_lib starts too early. Keep `ensure oxide-helptext` above all of them.

## ox_lib Compatibility

Most scripts show prompts with ox_lib's `lib.showTextUI`. One line in ox_lib sends all of those prompts through oxide-helptext, with no change to the scripts themselves.

1. Open your ox_lib folder and open `fxmanifest.lua` in a text editor (Notepad++ or VS Code work well). This file lists the scripts ox_lib loads.
2. Scroll to the very end of the file.
3. Add this line on a new line of its own:
   ```lua
   client_script '@oxide-helptext/compat/ox_lib.lua'
   ```
4. Save the file.
5. Fully restart your server.

What changes:
- Every `lib.showTextUI` prompt now appears as an oxide-helptext prompt, owned by the script that showed it.
- `lib.hideTextUI` hides only the calling script's ox_lib prompt. Its other prompts stay.
- Prompts from several ox_lib scripts can be on screen at once instead of replacing each other.
- Nothing else in ox_lib changes.
- If oxide-helptext is stopped, ox_lib's own text UI takes over again. The ox_lib prompt that is open at that moment moves across automatically when oxide-helptext stops or starts.

> **Every ox_lib update removes this line.** Updating ox_lib replaces its `fxmanifest.lua` with a fresh copy. After each ox_lib update, add the line again and restart your server.

The line belongs in **ox_lib's** `fxmanifest.lua` only. If it is added to any other resource, it does nothing and prints a warning (see [Troubleshooting](TROUBLESHOOTING.md#console-messages)). If you ever remove oxide-helptext from your server, remove this line from ox_lib too.

## o-link Setup

With o-link 1.9.2 or newer, nothing needs to be configured. As long as oxide-helptext starts before o-link, o-link uses it for every `olink.helptext` prompt.

If you also run another text UI resource that o-link supports (for example okokTextUI or jg-textui), tell o-link to use oxide-helptext:

1. Open `o-link/config.lua`.
2. Find this line inside `Config.Overrides`:
   ```lua
   -- HelpText          = 'ox_lib',
   ```
3. Remove the `--` at the start and change the value, so the line reads:
   ```lua
   HelpText          = 'oxide-helptext',
   ```
4. Save the file and restart your server.

## Building from Source

You only need this if you downloaded the repository instead of the release zip, or if you changed the UI yourself.

1. Install [Node.js](https://nodejs.org/). The release build uses Node.js 20.
2. Open a terminal (command prompt) in the `oxide-helptext/web` folder.
3. Run these two commands, one after the other:
   ```bash
   npm ci
   npm run build
   ```
4. Check that `oxide-helptext/web/dist/index.html` now exists.
5. Restart oxide-helptext, or your server.

`npm ci` creates a `web/node_modules` folder. The server does not use it, so you can delete it after the build.

## Verification

1. **Start your server.** The server console should show `Started resource oxide-helptext`.
2. **Join and open the client console.** Press **F8** in game. Look for any yellow lines that start with `[oxide-helptext]`. If there are none, that is good. If there are, see [Console Messages](TROUBLESHOOTING.md#console-messages).
3. **Find a prompt.** Walk up to anything that shows an interaction prompt, such as a door, a shop or a vehicle. You should see a dark card with the key in a small red-edged badge, in the middle of the right edge of the screen unless the script or your config picked another position. If you added the ox_lib line, prompts from ox_lib scripts should look like this too.
4. **Hold the key.** The badge lights up while you hold it.
5. **Open the pause menu.** The prompt fades out, then comes back when you close the menu.

## Updating

1. Back up `oxide-helptext/shared/config.lua` if you changed it.
2. Download the new `oxide-helptext.zip` from the [latest release](https://github.com/Oxide-Studios/oxide-helptext/releases/latest).
3. Replace your `oxide-helptext` folder with the new one.
4. Re-apply your settings in the new `shared/config.lua`. Do not copy the old file over it, in case the new version added options.
5. Restart your server.

Updating oxide-helptext does not touch ox_lib, so the ox_lib line stays in place.

## Next Steps

- [Configuration](CONFIGURATION.md) - change the default position, stacking, pause-menu hiding and sounds
- [API Reference](API.md) - show prompts from your own scripts
- [Troubleshooting](TROUBLESHOOTING.md) - fix prompts that do not appear, do not hide or keep ox_lib's look
