-- Key badges: the label a badge shows, and which physical key or game control lights it up.

Keys = {}

-- Windows virtual-key codes read by IsRawKeyDown, by badge label.
local NAMED_KEYS = {
    SPACE = 0x20, ENTER = 0x0D, RETURN = 0x0D, BACKSPACE = 0x08, BACK = 0x08, TAB = 0x09,
    ESC = 0x1B, SHIFT = 0x10, CTRL = 0x11, ALT = 0x12, CAPS = 0x14,
    UP = 0x26, DOWN = 0x28, LEFT = 0x25, RIGHT = 0x27,
    INS = 0x2D, DEL = 0x2E, HOME = 0x24, END = 0x23, PGUP = 0x21, PGDN = 0x22,
}

-- Watch ids are 'c<control>' for game controls and 'k<virtual key>' for raw keys.
local watched = {}   -- [watchId] = { control = n } | { raw = n }
local held = {}      -- [watchId] = true while down

---@param label string
---@return number|nil
local function virtualKey(label)
    if NAMED_KEYS[label] then return NAMED_KEYS[label] end
    if label:match('^[A-Z0-9]$') then return label:byte() end
    local fn = tonumber(label:match('^F(%d%d?)$'))
    if fn and fn >= 1 and fn <= 12 then return 0x6F + fn end
end

-- GetControlInstructionalButton gives 't_E' (or 'T_'/'w_') for keys with a printable name and
-- 'b_<n>' for glyph-only keys; several bindings are joined with '%'.
---@param control number
---@return string|nil
local function controlLabel(control)
    local ok, button = pcall(GetControlInstructionalButton, 0, control, true)
    if not ok or type(button) ~= 'string' then return nil end
    local label = button:match('^[tTw]_([^%%]+)')
    return label and label:upper() or nil
end

---@param id string
---@return table
local function sourceOf(id)
    local code = tonumber(id:sub(2))
    if id:sub(1, 1) == 'c' then return { control = code } end
    return { raw = code }
end

---Builds a key segment. With a control, the badge shows the player's current binding for it.
---@param name string|nil label written by the caller, e.g. 'E'
---@param control number|nil game control index, e.g. 38
---@return table|nil segment { t = 'key', v = label, k = watchId }
function Keys.segment(name, control)
    control = tonumber(control)
    local label = control and controlLabel(control)
    if not label and name then
        label = tostring(name):gsub('^%s+', ''):gsub('%s+$', ''):upper()
    end
    if not label or label == '' then return nil end

    local watch
    if control then
        watch = 'c' .. control
    elseif IsRawKeyDown then
        local vk = virtualKey(label)
        watch = vk and ('k' .. vk)
    end

    return { t = 'key', v = label, k = watch }
end

---Limits polling to the badges currently on screen. Badges that leave while held are released.
---@param ids table<string, true>
---@param onChange fun(id: string, down: boolean)
function Keys.setVisible(ids, onChange)
    local nextWatched = {}
    for id in pairs(ids) do
        nextWatched[id] = watched[id] or sourceOf(id)
    end
    for id in pairs(held) do
        if not ids[id] then
            held[id] = nil
            onChange(id, false)
        end
    end
    watched = nextWatched
end

---Calls onChange(watchId, isDown) for every visible badge whose key changed state.
---@param onChange fun(id: string, down: boolean)
function Keys.poll(onChange)
    for id, source in pairs(watched) do
        local down
        if source.control then
            down = IsDisabledControlPressed(0, source.control)
        else
            down = IsRawKeyDown(source.raw)
        end
        down = down == true or down == 1
        if (held[id] or false) ~= down then
            held[id] = down or nil
            onChange(id, down)
        end
    end
end
