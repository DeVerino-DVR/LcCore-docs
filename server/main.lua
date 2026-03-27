-- LcCore Server - Entry Point

LcCore.Players = {}          -- [source] = Player
LcCore._charIndex = {}       -- [charId] = source  (lookup O(1))
LcCore._discordIndex = {}    -- [discord] = source  (lookup O(1))

-------------------------------------------------
-- Init
-------------------------------------------------
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    print('[LcCore] ^2Server initialized^0')

    for _, playerId in ipairs(GetPlayers()) do
        local src <const> = tonumber(playerId)
        if src then
            LcCore.InitPlayer(src)
        end
    end
end)

-------------------------------------------------
-- Get Discord ID from identifiers
-------------------------------------------------
---@param source number
---@return string?
function LcCore.GetDiscordId(source)
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if string.find(id, 'discord:') then
            return (string.gsub(id, 'discord:', ''))
        end
    end
    return nil
end

-------------------------------------------------
-- Index management (O(1) lookups)
-------------------------------------------------

local function indexPlayer(source, player)
    local discord <const> = player.getDiscord()
    LcCore._discordIndex[discord] = source
end

local function indexChar(source, charId)
    LcCore._charIndex[charId] = source
end

local function cleanupIndex(source)
    local player = LcCore.Players[source]
    if not player then return end

    LcCore._discordIndex[player.getDiscord()] = nil

    local charId = player.getCharId()
    if charId > 0 then
        LcCore._charIndex[charId] = nil
    end
end

-------------------------------------------------
-- Init player (connect or resource restart)
-------------------------------------------------
---@param source number
function LcCore.InitPlayer(source)
    local discord = LcCore.GetDiscordId(source)
    if not discord then
        DropPlayer(tostring(source), 'Discord non detecte. Lance Discord avant de te connecter.')
        return
    end

    if LcCore.Players[source] then
        LcCore.SavePlayer(source)
        cleanupIndex(source)
        LcCore.Players[source] = nil
    end

    local charRows = MySQL.query.await('SELECT * FROM lc_characters WHERE discord = ?', { discord })
    local characters = {}

    for _, row in ipairs(charRows or {}) do
        local coords = Config.DefaultSpawn
        if row.coords then
            local c = type(row.coords) == 'string' and json.decode(row.coords) or row.coords
            if c then coords = vector3(c.x, c.y, c.z) end
        end

        local job = { name = Config.DefaultJob, grade = Config.DefaultJobGrade, label = Config.DefaultJobLabel }
        if row.job then
            job = type(row.job) == 'string' and json.decode(row.job) or row.job
        end

        local inventory = {}
        if row.inventory then
            inventory = type(row.inventory) == 'string' and json.decode(row.inventory) or row.inventory
        end

        local skin = {}
        if row.skin then
            skin = type(row.skin) == 'string' and json.decode(row.skin) or row.skin
        end

        local char <const> = LcCore.CreateCharacter({
            charId    = row.id,
            discord   = discord,
            group     = row.group,
            firstname = row.firstname,
            lastname  = row.lastname,
            job       = job,
            gang      = row.gang,
            money     = row.money,
            gold      = row.gold,
            coords    = coords,
            inventory = inventory,
            slots     = row.slots,
            isDead    = row.isdead == 1,
            skin      = skin,
            xp        = row.xp,
        })
        characters[char.charId] = char
    end

    local player <const> = LcCore.CreatePlayer(source, discord, characters)
    LcCore.Players[source] = player
    indexPlayer(source, player)

    local charCount <const> = player.getCharCount()

    if charCount == 0 then
        TriggerClientEvent('lc:createCharacter', source)
    elseif charCount == 1 then
        local _, firstChar = next(characters)
        if firstChar then
            player.setActiveChar(firstChar.charId)
            indexChar(source, firstChar.charId)
            TriggerClientEvent('lc:spawn', source, {
                charId    = firstChar.charId,
                firstname = firstChar.firstname,
                lastname  = firstChar.lastname,
                coords    = firstChar.coords,
                skin      = firstChar.skin,
                isDead    = firstChar.isDead,
            })
        end
    else
        local charList = {}
        for charId, char in pairs(characters) do
            charList[#charList + 1] = {
                charId    = charId,
                firstname = char.firstname,
                lastname  = char.lastname,
                job       = char.job,
                money     = char.money,
                gold      = char.gold,
            }
        end
        TriggerClientEvent('lc:selectCharacter', source, charList)
    end

    LcCore.Print('Player initialized:', discord, '| Chars:', charCount)
end

-------------------------------------------------
-- Player connecting (ban check)
-------------------------------------------------
AddEventHandler('playerConnecting', function(_, _, deferrals)
    local source <const> = source
    deferrals.defer()
    Wait(0)
    deferrals.update('Chargement...')

    local discord = LcCore.GetDiscordId(source)
    if not discord then
        deferrals.done('Discord non detecte. Lance Discord avant de te connecter.')
        return
    end

    local ban = MySQL.single.await('SELECT * FROM lc_bans WHERE discord = ? AND (expire IS NULL OR expire > NOW())', { discord })
    if ban then
        deferrals.done('Tu es banni: ' .. (ban.reason or 'Aucune raison'))
        return
    end

    deferrals.done()
end)

-------------------------------------------------
-- Player fully joined -> init
-------------------------------------------------
RegisterNetEvent('lc:playerJoined', function()
    local source <const> = source
    LcCore.InitPlayer(source)
end)

-------------------------------------------------
-- Player selects a character
-------------------------------------------------
RegisterNetEvent('lc:charSelected', function(charId)
    local source <const> = source
    local player = LcCore.GetPlayer(source)
    if not player then return end

    if not player.setActiveChar(charId) then return end
    indexChar(source, charId)

    local char <const> = player.getActiveChar()
    TriggerClientEvent('lc:spawn', source, {
        charId    = char.charId,
        firstname = char.firstname,
        lastname  = char.lastname,
        coords    = char.coords,
        skin      = char.skin,
        isDead    = char.isDead,
    })
end)

-------------------------------------------------
-- Player creates a character
-------------------------------------------------
RegisterNetEvent('lc:charCreate', function(data)
    local source <const> = source
    local player = LcCore.GetPlayer(source)
    if not player then return end

    if player.getCharCount() >= Config.MaxCharacters then
        TriggerClientEvent('lc:notify', source, 'Tip', 'Nombre max de personnages atteint', 3000)
        return
    end

    local discord <const> = player.getDiscord()
    local defaultJob <const> = json.encode({ name = Config.DefaultJob, grade = Config.DefaultJobGrade, label = Config.DefaultJobLabel })
    local defaultCoords <const> = json.encode({ x = Config.DefaultSpawn.x, y = Config.DefaultSpawn.y, z = Config.DefaultSpawn.z })

    local charId <const> = MySQL.insert.await(
        'INSERT INTO lc_characters (discord, firstname, lastname, job, gang, money, gold, coords, inventory, skin, slots, xp) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        {
            discord,
            data.firstname,
            data.lastname,
            defaultJob,
            Config.DefaultGang,
            Config.DefaultMoney,
            Config.DefaultGold,
            defaultCoords,
            '[]',
            data.skin or '{}',
            Config.DefaultInventorySlots,
            0,
        }
    )

    local char <const> = LcCore.CreateCharacter({
        charId    = charId,
        discord   = discord,
        firstname = data.firstname,
        lastname  = data.lastname,
    })

    player.addCharacter(char)
    player.setActiveChar(charId)
    indexChar(source, charId)

    TriggerClientEvent('lc:spawn', source, {
        charId    = charId,
        firstname = char.firstname,
        lastname  = char.lastname,
        coords    = Config.DefaultSpawn,
        skin      = char.skin,
        isDead    = false,
    })
end)

-------------------------------------------------
-- Player disconnect -> save & cleanup
-------------------------------------------------
AddEventHandler('playerDropped', function()
    local source <const> = source
    LcCore.SavePlayer(source)
    cleanupIndex(source)
    LcCore.Players[source] = nil
end)

-------------------------------------------------
-- Getters (tous O(1), zero boucle)
-------------------------------------------------

--- Get player by source
---@param source number
---@return table?
function LcCore.GetPlayer(source)
    return LcCore.Players[source]
end

--- Get all players
---@return table
function LcCore.GetPlayers()
    return LcCore.Players
end

--- Get player by charId (O(1) via index)
---@param charId number
---@return table?
function LcCore.GetPlayerByCharId(charId)
    local source = LcCore._charIndex[charId]
    if source then return LcCore.Players[source] end
    return nil
end

--- Get player by Discord ID (O(1) via index)
---@param discord string
---@return table?
function LcCore.GetPlayerByDiscord(discord)
    local source = LcCore._discordIndex[discord]
    if source then return LcCore.Players[source] end
    return nil
end

--- Get source from charId (O(1))
---@param charId number
---@return number?
function LcCore.GetSourceByCharId(charId)
    return LcCore._charIndex[charId]
end
