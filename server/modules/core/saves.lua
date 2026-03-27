-- LcCore Server Module - Auto Save (Cron + txAdmin hooks)

--- Save a single player to DB
---@param source number
function LcCore.SavePlayer(source)
    local player = LcCore.GetPlayer(source)
    if not player then return end

    local char = player.getActiveChar()
    if not char then return end

    local coords = char.coords
    local coordsJson = json.encode({ x = coords.x, y = coords.y, z = coords.z })

    MySQL.update.await(
        'UPDATE lc_characters SET `group` = ?, job = ?, gang = ?, money = ?, gold = ?, coords = ?, inventory = ?, skin = ?, slots = ?, isdead = ?, xp = ? WHERE id = ?',
        {
            char.group,
            json.encode(char.job),
            char.gang,
            char.money,
            char.gold,
            coordsJson,
            json.encode(char.inventory),
            json.encode(char.skin),
            char.slots,
            char.isDead and 1 or 0,
            char.xp,
            char.charId,
        }
    )

    LcCore.Print('Saved player', source, '(charId:', char.charId, ')')
end

--- Save all online players
function LcCore.SaveAll()
    for src, _ in pairs(LcCore.Players) do
        LcCore.SavePlayer(src)
    end
    LcCore.Print('All players saved')
end

-------------------------------------------------
-- Auto-save via Cron (pas de while true)
-------------------------------------------------
Citizen.CreateThread(function()
    -- Wait for cron module to be ready
    while not LcCore.Cron do Wait(100) end

    -- Auto-save toutes les 5 minutes: "*/5 * * * *"
    local interval = Config.AutoSaveInterval or 300
    local minutes = math.max(1, math.floor(interval / 60))
    local cronExpr = '*/' .. minutes .. ' * * * *'

    LcCore.Cron.New(cronExpr, function()
        LcCore.SaveAll()
    end, 'auto-save')
end)

-------------------------------------------------
-- txAdmin hooks: save on server shutdown/restart
-------------------------------------------------

-- txAdmin scheduled restart warning
AddEventHandler('txAdmin:events:scheduledRestart', function(data)
    if data.secondsRemaining <= 60 then
        print('[LcCore] ^3txAdmin restart imminent, saving all players...^0')
        LcCore.SaveAll()
    end
end)

-- txAdmin server shutting down
AddEventHandler('txAdmin:events:serverShuttingDown', function()
    print('[LcCore] ^3Server shutting down, saving all players...^0')
    LcCore.SaveAll()
end)

-- Resource stop (ensure LcCore or server stop)
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    print('[LcCore] ^3Resource stopping, saving all players...^0')
    LcCore.SaveAll()
end)
