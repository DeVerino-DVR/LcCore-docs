-- LcCore Client Module - State Bags (lecture)
-- Les state bags sont set cote server (player.lua) et lisibles ici cote client.
-- Mis a jour en temps reel automatiquement par FiveM/RedM.
--
-- Usage:
--   local money = LcCore.State.Get('money')
--   local job   = LcCore.State.Get('job')  -- { name, grade, label }
--   LcCore.State.OnChange('money', function(value) print('Nouvel argent:', value) end)

LcCore.State = {}

local watchers = {}

--- Get a state bag value for the local player
---@param key string
---@return any
function LcCore.State.Get(key)
    return LocalPlayer.state[key]
end

--- Watch for state bag changes on the local player
---@param key string
---@param cb function(value: any)
function LcCore.State.OnChange(key, cb)
    if not watchers[key] then
        watchers[key] = {}
    end
    watchers[key][#watchers[key] + 1] = cb
end

-- Listen for all player state changes
AddStateBagChangeHandler(nil, 'player:' .. tostring(PlayerId()), function(bagName, key, value)
    if watchers[key] then
        for _, cb in ipairs(watchers[key]) do
            cb(value)
        end
    end
end)
