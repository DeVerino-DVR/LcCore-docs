-- LcCore Server Module - Economy & Taxes par Comte
--
-- Usage:
--   local prixFinal = LcCore.Economy.GetPrice(basePrice, countyId)
--   LcCore.Economy.SetTax('new_hanover', 15)
--   LcCore.Economy.SetMayor('new_hanover', charId)
--   LcCore.Economy.IsMayor(charId, 'new_hanover')

LcCore.Economy = {}

local counties = {}

-------------------------------------------------
-- Init
-------------------------------------------------
CreateThread(function()
    local rows = MySQL.query.await('SELECT * FROM lc_counties')
    if rows then
        for _, row in ipairs(rows) do
            counties[row.id] = {
                id    = row.id,
                name  = row.name,
                label = row.label,
                tax   = row.tax or 0.0,
                mayor = row.mayor,
            }
        end
    end
    LcCore.Print('Counties loaded:', #rows or 0)
end)

-------------------------------------------------
-- Getters
-------------------------------------------------

---@return table
function LcCore.Economy.GetCounties()
    return counties
end

---@param countyId string
---@return table?
function LcCore.Economy.GetCounty(countyId)
    return counties[countyId]
end

---@param basePrice number
---@param countyId string?
---@return number finalPrice
---@return number taxAmount
function LcCore.Economy.GetPrice(basePrice, countyId)
    if not countyId or not counties[countyId] then
        return basePrice, 0
    end
    local tax <const> = counties[countyId].tax or 0
    local taxAmount <const> = basePrice * (tax / 100)
    return basePrice + taxAmount, taxAmount
end

-------------------------------------------------
-- Setters
-------------------------------------------------

---@param countyId string
---@param taxRate number
function LcCore.Economy.SetTax(countyId, taxRate)
    if not counties[countyId] then return end
    counties[countyId].tax = taxRate
    MySQL.update('UPDATE lc_counties SET tax = ? WHERE id = ?', { taxRate, countyId })
    TriggerEvent('lc:taxChanged', countyId, taxRate)
    LcCore.Print('Tax updated for', countyId, ':', taxRate .. '%')
end

---@param countyId string
---@param charId number?
function LcCore.Economy.SetMayor(countyId, charId)
    if not counties[countyId] then return end
    counties[countyId].mayor = charId
    MySQL.update('UPDATE lc_counties SET mayor = ? WHERE id = ?', { charId, countyId })
    TriggerEvent('lc:mayorChanged', countyId, charId)
end

---@param countyId string
---@return number?
function LcCore.Economy.GetMayor(countyId)
    if not counties[countyId] then return nil end
    return counties[countyId].mayor
end

---@param charId number
---@param countyId string?
---@return boolean
function LcCore.Economy.IsMayor(charId, countyId)
    if countyId then
        local county = counties[countyId]
        return county and county.mayor == charId or false
    end

    for _, county in pairs(counties) do
        if county.mayor == charId then return true end
    end
    return false
end

-------------------------------------------------
-- Callbacks
-------------------------------------------------

LcCore.Callback.Register('lc:economy:getCounties', function(_)
    return counties
end)

LcCore.Callback.Register('lc:economy:setTax', function(source, countyId, taxRate)
    local player = LcCore.GetPlayer(source)
    if not player then return false end

    local charId <const> = player.getCharId()
    if not LcCore.Economy.IsMayor(charId, countyId) then
        if player.getGroup() == LcCore.Groups.USER then
            return false, 'Non autorise'
        end
    end

    LcCore.Economy.SetTax(countyId, taxRate)
    return true
end)
