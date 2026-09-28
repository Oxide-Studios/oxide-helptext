Config = {}

-- Where a prompt appears when the script showing it doesn't pick a position.
-- right-center, left-center, top-center, bottom-center, top-left, top-right, bottom-left, bottom-right
-- The short names left, right, top and bottom also work.
Config.DefaultPosition = 'right-center'

-- Set to a position to draw every prompt there, whatever position a script asks for.
Config.ForcePosition = false

-- Most prompts shown at once in one position. When more are active, the newest ones show.
Config.MaxVisible = 4

-- Hide prompts while the pause menu is open.
Config.HideInPauseMenu = true

-- Light up a key badge while the player holds that key down.
Config.KeyFeedback = true

-- Play a sound when a new prompt appears (not when an open prompt changes).
Config.Sound = {
    enabled = false,
    name = 'HIGHLIGHTED_DEFAULT',
    set = 'HUD_FRONTEND_DEFAULT_SOUNDSET',
}
