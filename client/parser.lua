-- Turns a prompt (plain string or structured table) into lines of segments the UI renders.
-- Strings keep working as every textui has always taken them: '[E] Open', '[E] - Open',
-- '[E] Smoke · [H] Stop', '[E] Open | [G] Lock' and 'Press [E] to open' all get key badges.

Parser = {}

local SEPARATOR = '·'

-- GTA colour codes (~r~ etc.) mapped to UI colour names. ~s~ and ~w~ reset, ~h~ toggles bold.
local COLORS = {
    r = 'red', g = 'green', b = 'blue', y = 'yellow', o = 'orange', p = 'purple', c = 'grey', m = 'grey',
}

---@param text string
---@return string
local function trim(text)
    return (text:gsub('^%s+', ''):gsub('%s+$', ''))
end

---Appends styled text runs for **bold** and ~x~ colour codes.
---@param text string
---@param segments table
local function addRuns(text, segments)
    local bold, color = false, nil
    local buffer = {}

    local function flush()
        if #buffer == 0 then return end
        segments[#segments + 1] = { t = 'text', v = table.concat(buffer), b = bold or nil, c = color }
        buffer = {}
    end

    local i, len = 1, #text
    while i <= len do
        local code = text:match('^~(%a)~', i)
        if text:sub(i, i + 1) == '**' then
            flush()
            bold = not bold
            i = i + 2
        elseif code then
            flush()
            code = code:lower()
            if code == 'h' then
                bold = not bold
            elseif code == 's' or code == 'w' then
                color = nil
            elseif COLORS[code] then
                color = COLORS[code]
            end
            i = i + 3
        else
            buffer[#buffer + 1] = text:sub(i, i)
            i = i + 1
        end
    end
    flush()
end

---Appends text, turning each ' · ' into a separator segment.
---@param text string
---@param segments table
local function addText(text, segments)
    local start = 1
    while true do
        local s, e = text:find(SEPARATOR, start, true)
        local piece = trim(text:sub(start, s and s - 1 or #text))
        if piece ~= '' then addRuns(piece, segments) end
        if not s then break end
        local last = segments[#segments]
        if last and last.t ~= 'sep' then segments[#segments + 1] = { t = 'sep' } end
        start = e + 1
    end
end

---@param line string
---@return table segments
local function parseLine(line)
    local segments = {}
    local pos = 1
    local afterKey = false

    while true do
        local s, e, key = line:find('%[([^%[%]]+)%]', pos)
        local text = line:sub(pos, s and s - 1 or #line)
        -- '[E] - Open' and '[E]: Open' read as '[E] Open'
        if afterKey then text = text:gsub('^%s*[%-:]%s+', '') end
        addText(text, segments)
        if not s then break end

        local segment = Keys.segment(key)
        if segment then segments[#segments + 1] = segment end
        pos = e + 1
        afterKey = true
    end

    if segments[#segments] and segments[#segments].t == 'sep' then segments[#segments] = nil end
    return segments
end

---@param text string
---@param lines table
local function addLines(text, lines)
    text = text:gsub('~n~', '\n'):gsub('<br%s*/?>', '\n')
    for raw in text:gmatch('[^\n|]+') do
        local segments = parseLine(raw)
        if #segments > 0 then lines[#lines + 1] = segments end
    end
end

---@param message string|table|nil
---@return table model { title?, icon?, lines }
function Parser.build(message)
    local model = { lines = {} }

    if type(message) ~= 'table' then
        if message ~= nil then addLines(tostring(message), model.lines) end
        return model
    end

    if message.title ~= nil then model.title = tostring(message.title) end
    if type(message.icon) == 'string' and message.icon ~= '' then model.icon = message.icon end

    local text = message.text or message.message
    if text ~= nil then addLines(tostring(text), model.lines) end

    for _, key in ipairs(type(message.keys) == 'table' and message.keys or {}) do
        local segment = type(key) == 'table' and Keys.segment(key.key, key.control)
        if segment then
            local line = { segment }
            if key.label ~= nil then addText(tostring(key.label), line) end
            model.lines[#model.lines + 1] = line
        end
    end

    return model
end
