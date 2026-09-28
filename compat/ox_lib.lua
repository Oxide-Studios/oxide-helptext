--[[
    ox_lib text UI compatibility.

    Add this line to ox_lib's fxmanifest.lua and every script that calls lib.showTextUI /
    lib.hideTextUI shows its prompt through oxide-helptext, with no change to those scripts:

        client_script '@oxide-helptext/compat/ox_lib.lua'

    It runs inside ox_lib and takes over the text UI messages ox_lib sends to its own UI. The
    export order doesn't matter this way, and ox_lib keeps its own state (lib.isTextUIOpen).
    While oxide-helptext isn't running, ox_lib's text UI works exactly as before.
]]

if IsDuplicityVersion() then return end

if GetCurrentResourceName() ~= 'ox_lib' then
    print(('^3[oxide-helptext] compat/ox_lib.lua belongs in ox_lib\'s fxmanifest.lua, not %s\'s^0')
        :format(GetCurrentResourceName()))
    return
end

local HELPTEXT = 'oxide-helptext'
local PROMPT_ID = 'ox_lib'   -- ox_lib prompts get their own slot, so lib.hideTextUI leaves a script's other prompts alone
local sendNui = SendNUIMessage
local current   -- { data = ox_lib's text UI payload, owner = resource that showed it }

local ICON_STYLES = { fas = 'fa-solid', far = 'fa-regular', fab = 'fa-brands' }

-- ox_lib icons come as 'hand', 'fa-hand', 'fas fa-hand' or { 'fas', 'hand' }.
---@param icon any
---@return string|nil
local function iconClass(icon)
    if type(icon) == 'table' then
        return icon[2] and ('%s fa-%s'):format(ICON_STYLES[icon[1]] or 'fa-solid', icon[2]) or nil
    end
    if type(icon) ~= 'string' or icon == '' then return nil end
    if icon:find(' ', 1, true) then return icon end
    return 'fa-solid fa-' .. (icon:gsub('^fa%-', ''))
end

local function running()
    return GetResourceState(HELPTEXT) == 'started'
end

-- A failed hand-off falls back to ox_lib's UI; report each distinct error once so a real bug
-- isn't hidden behind the fallback.
local reported = {}

local function reportFallback(err, owner)
    err = tostring(err)
    if reported[err] then return end
    reported[err] = true
    print(('^3[oxide-helptext] a %s prompt fell back to ox_lib\'s text UI: %s^0'):format(owner, err))
end

---@param prompt table
local function forward(prompt)
    local data = prompt.data
    exports[HELPTEXT]:Show({ id = PROMPT_ID, text = data.text, icon = iconClass(data.icon) }, data.position, prompt.owner)
end

-- The invoking resource is the script that called lib.showTextUI / lib.hideTextUI, so each
-- script owns its prompt in oxide-helptext.
SendNUIMessage = function(message)
    local action = type(message) == 'table' and message.action

    if action == 'textUi' then
        current = { data = message.data or {}, owner = GetInvokingResource() or 'ox_lib' }
        if running() then
            local ok, err = pcall(forward, current)
            if ok then return end
            reportFallback(err, current.owner)
        end
    elseif action == 'textUiHide' then
        current = nil
        if running() then pcall(function() exports[HELPTEXT]:Hide(PROMPT_ID, GetInvokingResource() or 'ox_lib') end) end
    end

    return sendNui(message)
end

-- ox_lib keeps a prompt open until it's hidden, so move it across when oxide-helptext starts or stops.
AddEventHandler('onClientResourceStart', function(resource)
    if resource ~= HELPTEXT or not current then return end
    if pcall(forward, current) then sendNui({ action = 'textUiHide' }) end
end)

AddEventHandler('onClientResourceStop', function(resource)
    if resource ~= HELPTEXT or not current then return end
    sendNui({ action = 'textUi', data = current.data })
end)
