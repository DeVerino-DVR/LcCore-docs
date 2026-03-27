-- LcCore Client - API / Exports

local Core = {}

Core.Callback        = LcCore.Callback
Core.State           = LcCore.State
Core.KVP             = LcCore.KVP
Core.Notify          = LcCore.Notify
Core.Menu            = LcCore.Menu
Core.IsReady         = LcCore.IsReady
Core.GetActiveCharId = LcCore.GetActiveCharId

exports('GetCore', function()
    return Core
end)
