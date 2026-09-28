-- Every prompt belongs to the resource that showed it, so one resource's Hide() never clears
-- another's, and a resource's prompts go away when it stops. A resource can hold several prompts
-- at once by giving each an id; without one it has a single default prompt.

local RESOURCE = GetCurrentResourceName()

local POSITIONS = {
    ['right-center'] = true, ['left-center'] = true, ['top-center'] = true, ['bottom-center'] = true,
    ['top-left'] = true, ['top-right'] = true, ['bottom-left'] = true, ['bottom-right'] = true,
}

local ALIASES = { left = 'left-center', right = 'right-center', top = 'top-center', bottom = 'bottom-center' }

local prompts = {}   -- [slot] = { slot, owner, id, model, raw, rawPosition, sig, order }
local counter = 0
local nuiReady = false
local watching = false
local pausedHidden = false

---@param position any
---@return string|nil
local function normalizePosition(position)
    position = type(position) == 'string' and position:lower() or nil
    position = ALIASES[position] or position
    return POSITIONS[position] and position or nil
end

---@param position any
---@return string
local function resolvePosition(position)
    return normalizePosition(Config.ForcePosition)
        or normalizePosition(position)
        or normalizePosition(Config.DefaultPosition)
        or 'right-center'
end

---@param owner string|nil
---@return string
local function resolveOwner(owner)
    return owner or GetInvokingResource() or RESOURCE
end

---@param owner string
---@param id any
---@return string
local function slotOf(owner, id)
    return owner .. ':' .. (id ~= nil and tostring(id) or '')
end

local function sendKeyState(id, down)
    SendNUIMessage({ action = 'keyState', data = { id = id, down = down } })
end

---Newest Config.MaxVisible prompts per position, oldest first.
---@return table
local function visiblePrompts()
    local ordered = {}
    for _, prompt in pairs(prompts) do ordered[#ordered + 1] = prompt end
    table.sort(ordered, function(a, b) return a.order < b.order end)

    local perPosition, visible = {}, {}
    for i = #ordered, 1, -1 do
        local position = ordered[i].model.position
        perPosition[position] = (perPosition[position] or 0) + 1
        if perPosition[position] <= Config.MaxVisible then
            table.insert(visible, 1, ordered[i])
        end
    end
    return visible
end

local startWatcher

local function sync()
    local payload, keyIds = {}, {}
    for i, prompt in ipairs(visiblePrompts()) do
        local model = prompt.model
        payload[i] = {
            uid = prompt.slot,
            position = model.position,
            title = model.title,
            icon = model.icon,
            lines = model.lines,
        }
        for _, line in ipairs(model.lines) do
            for _, segment in ipairs(line) do
                if segment.k then keyIds[segment.k] = true end
            end
        end
    end

    Keys.setVisible(keyIds, sendKeyState)
    if nuiReady then SendNUIMessage({ action = 'setPrompts', data = payload }) end
    if #payload > 0 then startWatcher() end
end

-- Runs only while a prompt is open: pause-menu hiding and key badge feedback.
function startWatcher()
    if watching then return end
    watching = true
    CreateThread(function()
        while next(prompts) do
            if Config.HideInPauseMenu then
                local paused = IsPauseMenuActive()
                paused = paused == true or paused == 1
                if paused ~= pausedHidden then
                    pausedHidden = paused
                    SendNUIMessage({ action = 'setVisible', data = { visible = not paused } })
                end
            end
            if Config.KeyFeedback and not pausedHidden then
                Keys.poll(sendKeyState)
                Wait(0)
            else
                Wait(250)
            end
        end
        watching = false
        if pausedHidden then
            pausedHidden = false
            SendNUIMessage({ action = 'setVisible', data = { visible = true } })
        end
    end)
end

---Removes the owner's prompt with this id, or every prompt the owner holds when id is nil.
---@param id any
---@param owner string|nil defaults to the calling resource
local function Hide(id, owner)
    owner = resolveOwner(owner)
    local changed = false
    if id ~= nil then
        local slot = slotOf(owner, id)
        if prompts[slot] then
            prompts[slot] = nil
            changed = true
        end
    else
        for slot, prompt in pairs(prompts) do
            if prompt.owner == owner then
                prompts[slot] = nil
                changed = true
            end
        end
    end
    if changed then sync() end
end

---Shows or updates a prompt. Showing the same thing again costs nothing, so callers may call it
---every frame. An empty message hides the prompt.
---@param message string|table '[E] Open' or { id?, title?, icon?, text?, keys? = { { key, label, control? } }, position? }
---@param position string|nil ignored when message.position is set
---@param owner string|nil defaults to the calling resource
local function Show(message, position, owner)
    owner = resolveOwner(owner)
    local id = type(message) == 'table' and message.id or nil
    local slot = slotOf(owner, id)
    local existing = prompts[slot]

    if existing and type(message) ~= 'table' and existing.raw == message and existing.rawPosition == position then
        return
    end

    local model = Parser.build(message)
    if not model.title and #model.lines == 0 then
        return Hide(id, owner)
    end
    model.position = resolvePosition(type(message) == 'table' and message.position or position)

    local sig = json.encode(model)
    if existing and existing.sig == sig then return end

    if not existing then
        counter = counter + 1
        if Config.Sound.enabled then
            PlaySoundFrontend(-1, Config.Sound.name, Config.Sound.set, true)
        end
    end

    prompts[slot] = {
        slot = slot,
        owner = owner,
        id = id,
        model = model,
        raw = type(message) ~= 'table' and message or nil,
        rawPosition = position,
        sig = sig,
        order = existing and existing.order or counter,
    }
    sync()
end

local function HideAll()
    if not next(prompts) then return end
    prompts = {}
    sync()
end

---@param id any
---@param owner string|nil defaults to the calling resource
---@return boolean
local function IsOpen(id, owner)
    owner = resolveOwner(owner)
    if id ~= nil then return prompts[slotOf(owner, id)] ~= nil end
    for _, prompt in pairs(prompts) do
        if prompt.owner == owner then return true end
    end
    return false
end

exports('Show', Show)
exports('Hide', Hide)
exports('HideAll', HideAll)
exports('IsOpen', IsOpen)

RegisterNetEvent('oxide:helptext:show', function(message, position, owner)
    Show(message, position, owner or RESOURCE)
end)

RegisterNetEvent('oxide:helptext:hide', function(id, owner)
    Hide(id, owner or RESOURCE)
end)

RegisterNetEvent('oxide:helptext:hideAll', function()
    HideAll()
end)

RegisterNUICallback('ready', function(_, cb)
    nuiReady = true
    sync()
    cb('ok')
end)

AddEventHandler('onClientResourceStop', function(resource)
    if resource == RESOURCE then return end
    Hide(nil, resource)
end)
