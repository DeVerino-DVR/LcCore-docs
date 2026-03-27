-- LcCore Server Module - Economy & Taxes par Comte
--
-- Systeme de taxes par comte. Chaque comte a un maire et un taux de taxe.
-- Quand un script demande un prix, il passe par LcCore.Economy.GetPrice()
-- qui applique automatiquement la taxe du comte.
--
-- Usage:
--   local prixFinal = LcCore.Economy.GetPrice(basePrice, countyId)
--   local taxInfo = LcCore.Economy.GetCounty('new_hanover')
--   LcCore.Economy.SetTax('new_hanover', 15) -- 15%
--   LcCore.Economy.SetMayor('new_hanover', charId)

LcCore.Economy = {}

-- Cache des comtes (charge depuis DB au start)
local counties = {}

-------------------------------------------------
-- Init : charger les comtes depuis la DB
-------------------------------------------------
Citizen.CreateThread(function()
    local rows = MySQL.query.await('SELECT * FROM lc_counties')
    if rows then
        for _, row in ipairs(rows) do
            counties[row.id] = {
                id    = row.id,
                name  = row.name,
                label = row.label,
                tax   = row.tax or 0.0,
                mayor = row.mayor, -- charId du maire ou nil
            }
        end
    end
    LcCore.Print('Counties loaded:', #rows or 0)
end)

-------------------------------------------------
-- Getters
-------------------------------------------------

--- Get all counties
---@return table
function LcCore.Economy.GetCounties()
    return counties
end

--- Get a county by id
---@param countyId string
---@return table?
function LcCore.Economy.GetCounty(countyId)
    return counties[countyId]
end

--- Calculate final price with county tax applied
--- Usage dans n'importe quel script:
---   local prix = LcCore.Economy.GetPrice(10.0, 'new_hanover') -- 10 + taxe du comte
---@param basePrice number
---@param countyId string?
---@return number finalPrice
---@return number taxAmount
function LcCore.Economy.GetPrice(basePrice, countyId)
    if not countyId or not counties[countyId] then
        return basePrice, 0
    end
    local tax = counties[countyId].tax or 0
    local taxAmount = basePrice * (tax / 100)
    return basePrice + taxAmount, taxAmount
end

-------------------------------------------------
-- Setters (pour le panel maire)
-------------------------------------------------

--- Set the tax rate for a county (appele depuis le panel NUI)
---@param countyId string
---@param taxRate number -- pourcentage (ex: 15 = 15%)
function LcCore.Economy.SetTax(countyId, taxRate)
    if not counties[countyId] then return end
    counties[countyId].tax = taxRate
    MySQL.update('UPDATE lc_counties SET tax = ? WHERE id = ?', { taxRate, countyId })
    TriggerEvent('lc:taxChanged', countyId, taxRate)
    LcCore.Print('Tax updated for', countyId, ':', taxRate .. '%')
end

--- Set the mayor of a county
---@param countyId string
---@param charId number? -- nil to remove mayor
function LcCore.Economy.SetMayor(countyId, charId)
    if not counties[countyId] then return end
    counties[countyId].mayor = charId
    MySQL.update('UPDATE lc_counties SET mayor = ? WHERE id = ?', { charId, countyId })
    TriggerEvent('lc:mayorChanged', countyId, charId)
end

--- Get the mayor charId for a county
---@param countyId string
---@return number?
function LcCore.Economy.GetMayor(countyId)
    if not counties[countyId] then return nil end
    return counties[countyId].mayor
end

--- Check if a player is mayor of a county
---@param source number
---@param countyId string?
---@return boolean
function LcCore.Economy.IsMayor(source, countyId)
    local player = LcCore.GetPlayer(source)
    if not player then return false end
    local charId = player.getCharId()

    if countyId then
        local county = counties[countyId]
        return county and county.mayor == charId
    end

    -- Check if mayor of any county
    for _, county in pairs(counties) do
        if county.mayor == charId then return true end
    end
    return false
end

-------------------------------------------------
-- Callbacks pour le panel NUI
-------------------------------------------------

LcCore.Callback.Register('lc:economy:getCounties', function(source)
    return counties
end)

LcCore.Callback.Register('lc:economy:setTax', function(source, countyId, taxRate)
    if not LcCore.Economy.IsMayor(source, countyId) then
        local player = LcCore.GetPlayer(source)
        if not player or player.getGroup() == LcCore.Groups.USER then
            return false, 'Non autorise'
        end
    end
    LcCore.Economy.SetTax(countyId, taxRate)
    return true
end)
