-- LcCore Server - API / Exports
-- L'API publique utilise le charId comme identifiant joueur.
-- La source est un detail interne, jamais expose aux scripts externes.

local Core <const> = {}

-- Getters (charId-based, O(1))
Core.GetPlayer          = LcCore.GetPlayer          -- par source (interne)
Core.GetPlayers         = LcCore.GetPlayers
Core.GetPlayerByDiscord = LcCore.GetPlayerByDiscord  -- par discord
Core.GetPlayerByCharId  = LcCore.GetPlayerByCharId   -- par charId (principal)
Core.GetSourceByCharId  = LcCore.GetSourceByCharId

-- Systems
Core.Callback           = LcCore.Callback
Core.Economy            = LcCore.Economy
Core.Admin              = LcCore.Admin
Core.Commands           = LcCore.Commands
Core.Cron               = LcCore.Cron

-- Saves
Core.SavePlayer         = LcCore.SavePlayer
Core.SaveAll            = LcCore.SaveAll

exports('GetCore', function()
    return Core
end)
