-- Server-side relay: shows or hides a prompt on one player's screen. The calling resource is
-- sent along so the prompt is owned by it, exactly as if its own client script had shown it.

---@param source number
---@param message string|table
---@param position string|nil
local function Show(source, message, position)
    TriggerClientEvent('oxide:helptext:show', source, message, position, GetInvokingResource())
end

---@param source number
---@param id any hides every prompt the calling resource holds when nil
local function Hide(source, id)
    TriggerClientEvent('oxide:helptext:hide', source, id, GetInvokingResource())
end

---@param source number
local function HideAll(source)
    TriggerClientEvent('oxide:helptext:hideAll', source)
end

exports('Show', Show)
exports('Hide', Hide)
exports('HideAll', HideAll)
