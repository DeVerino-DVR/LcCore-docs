---@diagnostic disable: undefined-global
-- LcCore Client Module - Notifications (natives RDR3)
-- Utilise les notifications natives de Red Dead Redemption 2.
--
-- Usage:
--   LcCore.Notify.Tip('Message', 3000)
--   LcCore.Notify.Left('Titre', 'Sous-titre', 'generic_textures', 'tick', 3000, 'COLOR_WHITE')
--   LcCore.Notify.Center('Message', 3000)
--   LcCore.Notify.Right('Message', 3000)
--   LcCore.Notify.Bottom('Message', 3000)
--   LcCore.Notify.Advanced('Text', 'generic_textures', 'tick', 'COLOR_WHITE', 3000)
--   LcCore.Notify.Top('Message', 'Lieu', 3000)

LcCore.Notify = {}

-------------------------------------------------
-- Helpers
-------------------------------------------------

local function bigInt(text)
    local buf = DataView.ArrayBuffer(16)
    buf:SetInt64(0, text)
    return buf:GetInt64(0)
end

local function loadTexture(dict)
    if not HasStreamedTextureDictLoaded(dict) then
        RequestStreamedTextureDict(dict, true)
        local timeout = 0
        repeat Wait(0); timeout = timeout + 1 until HasStreamedTextureDictLoaded(dict) or timeout > 500
    end
end

local function releaseTexture(dict)
    Citizen.InvokeNative(0x4ACA10A91F66F1E2, dict)
end

-------------------------------------------------
-- Tip (haut droite, simple)
-------------------------------------------------
---@param message string
---@param duration number?
function LcCore.Notify.Tip(message, duration)
    local cfg = DataView.ArrayBuffer(8 * 7)
    cfg:SetInt32(8 * 0, tonumber(duration or 3000))
    cfg:SetInt32(8 * 1, 0)
    cfg:SetInt32(8 * 2, 0)
    cfg:SetInt32(8 * 3, 0)

    local data = DataView.ArrayBuffer(8 * 3)
    data:SetUint64(8 * 1, bigInt(VarString(10, "LITERAL_STRING", message)))

    Citizen.InvokeNative(0x049D5C615BD38BAD, cfg:Buffer(), data:Buffer(), 1)
end

-------------------------------------------------
-- Right (tip droite)
-------------------------------------------------
---@param message string
---@param duration number?
function LcCore.Notify.Right(message, duration)
    local cfg = DataView.ArrayBuffer(8 * 7)
    cfg:SetInt32(8 * 0, tonumber(duration or 3000))

    local data = DataView.ArrayBuffer(8 * 3)
    data:SetInt64(8 * 1, bigInt(VarString(10, "LITERAL_STRING", message)))

    Citizen.InvokeNative(0xB2920B9760F0F36B, cfg:Buffer(), data:Buffer(), 1)
end

-------------------------------------------------
-- Left (avec icone)
-------------------------------------------------
---@param title string
---@param subtitle string
---@param dict string
---@param icon string
---@param duration number?
---@param color string?
function LcCore.Notify.Left(title, subtitle, dict, icon, duration, color)
    loadTexture(dict)

    local cfg = DataView.ArrayBuffer(8 * 7)
    cfg:SetInt32(8 * 0, tonumber(duration or 3000))

    local data = DataView.ArrayBuffer(8 * 8)
    data:SetInt64(8 * 1, bigInt(VarString(10, "LITERAL_STRING", title)))
    data:SetInt64(8 * 2, bigInt(VarString(10, "LITERAL_STRING", subtitle)))
    data:SetInt32(8 * 3, 0)
    data:SetInt64(8 * 4, bigInt(joaat(dict)))
    data:SetInt64(8 * 5, bigInt(joaat(icon)))
    data:SetInt64(8 * 6, bigInt(joaat(color or "COLOR_WHITE")))

    Citizen.InvokeNative(0x26E87218390E6729, cfg:Buffer(), data:Buffer(), 1, 1)
    releaseTexture(dict)
end

-------------------------------------------------
-- Top (haut centre avec lieu)
-------------------------------------------------
---@param message string
---@param location string
---@param duration number?
function LcCore.Notify.Top(message, location, duration)
    local cfg = DataView.ArrayBuffer(8 * 7)
    cfg:SetInt32(8 * 0, tonumber(duration or 3000))

    local data = DataView.ArrayBuffer(8 * 5)
    data:SetInt64(8 * 1, bigInt(VarString(10, "LITERAL_STRING", location)))
    data:SetInt64(8 * 2, bigInt(VarString(10, "LITERAL_STRING", message)))

    Citizen.InvokeNative(0xD05590C1AB38F068, cfg:Buffer(), data:Buffer(), 0, 1)
end

-------------------------------------------------
-- Center (centre ecran)
-------------------------------------------------
---@param text string
---@param duration number?
---@param color string?
function LcCore.Notify.Center(text, duration, color)
    local cfg = DataView.ArrayBuffer(8 * 7)
    cfg:SetInt32(8 * 0, tonumber(duration or 3000))

    local data = DataView.ArrayBuffer(8 * 4)
    data:SetInt64(8 * 1, bigInt(VarString(10, "LITERAL_STRING", text)))
    data:SetInt64(8 * 2, bigInt(joaat(color or "COLOR_PURE_WHITE")))

    Citizen.InvokeNative(0x893128CDB4B81FBB, cfg:Buffer(), data:Buffer(), 1)
end

-------------------------------------------------
-- Bottom (objectif, bas droite)
-------------------------------------------------
---@param message string
---@param duration number?
function LcCore.Notify.Bottom(message, duration)
    Citizen.InvokeNative(0xDD1232B332CBB9E7, 3, 1, 0)

    local cfg = DataView.ArrayBuffer(8 * 7)
    cfg:SetInt32(8 * 0, tonumber(duration or 3000))

    local data = DataView.ArrayBuffer(8 * 3)
    data:SetInt64(8 * 1, bigInt(VarString(10, "LITERAL_STRING", message)))

    Citizen.InvokeNative(0xCEDBF17EFCC0E4A4, cfg:Buffer(), data:Buffer(), 1)
end

-------------------------------------------------
-- BottomRight
-------------------------------------------------
---@param text string
---@param duration number?
function LcCore.Notify.BottomRight(text, duration)
    local cfg = DataView.ArrayBuffer(8 * 7)
    cfg:SetInt32(8 * 0, tonumber(duration or 3000))

    local data = DataView.ArrayBuffer(8 * 5)
    data:SetInt64(8 * 1, bigInt(VarString(10, "LITERAL_STRING", text)))

    Citizen.InvokeNative(0x2024F4F333095FB1, cfg:Buffer(), data:Buffer(), 1)
end

-------------------------------------------------
-- Advanced (droite avec icone et qualite)
-------------------------------------------------
---@param text string
---@param dict string
---@param icon string
---@param color string?
---@param duration number?
---@param quality number?
---@param showQuality boolean?
function LcCore.Notify.Advanced(text, dict, icon, color, duration, quality, showQuality)
    loadTexture(dict)

    local cfg = DataView.ArrayBuffer(8 * 7)
    cfg:SetInt32(8 * 0, tonumber(duration or 3000))
    cfg:SetInt64(8 * 1, bigInt(VarString(10, "LITERAL_STRING", "Transaction_Feed_Sounds")))
    cfg:SetInt64(8 * 2, bigInt(VarString(10, "LITERAL_STRING", "Transaction_Positive")))

    local data = DataView.ArrayBuffer(8 * 10)
    data:SetInt64(8 * 1, bigInt(VarString(10, "LITERAL_STRING", text)))
    data:SetInt64(8 * 2, bigInt(VarString(10, "LITERAL_STRING", dict)))
    data:SetInt64(8 * 3, bigInt(joaat(icon)))
    data:SetInt64(8 * 5, bigInt(joaat(color or "COLOR_WHITE")))
    if showQuality then
        data:SetInt32(8 * 6, quality or 1)
    end

    Citizen.InvokeNative(0xB249EBCB30DD88E0, cfg:Buffer(), data:Buffer(), 1)
    releaseTexture(dict)
end

-------------------------------------------------
-- SimpleTop (titre + sous-titre en haut)
-------------------------------------------------
---@param title string
---@param subtitle string
---@param duration number?
function LcCore.Notify.SimpleTop(title, subtitle, duration)
    local cfg = DataView.ArrayBuffer(8 * 7)
    cfg:SetInt32(8 * 0, tonumber(duration or 3000))

    local data = DataView.ArrayBuffer(8 * 7)
    data:SetInt64(8 * 1, bigInt(VarString(10, "LITERAL_STRING", title)))
    data:SetInt64(8 * 2, bigInt(VarString(10, "LITERAL_STRING", subtitle)))

    Citizen.InvokeNative(0xA6F4216AB10EB08E, cfg:Buffer(), data:Buffer(), 1, 1)
end

-------------------------------------------------
-- Fail (mission echouee)
-------------------------------------------------
---@param title string
---@param subtitle string
---@param duration number?
function LcCore.Notify.Fail(title, subtitle, duration)
    local cfg = DataView.ArrayBuffer(8 * 5)

    local data = DataView.ArrayBuffer(8 * 9)
    data:SetInt64(8 * 1, bigInt(VarString(10, "LITERAL_STRING", title)))
    data:SetInt64(8 * 2, bigInt(VarString(10, "LITERAL_STRING", subtitle)))

    local result = Citizen.InvokeNative(0x9F2CC2439A04E7BA, cfg:Buffer(), data:Buffer(), 1)
    Wait(duration or 3000)
    Citizen.InvokeNative(0x00A15B94CBA4F76F, result)
end

-------------------------------------------------
-- Dead (notification de mort)
-------------------------------------------------
---@param title string
---@param audioRef string
---@param audioName string
---@param duration number?
function LcCore.Notify.Dead(title, audioRef, audioName, duration)
    local cfg = DataView.ArrayBuffer(8 * 5)

    local data = DataView.ArrayBuffer(8 * 9)
    data:SetInt64(8 * 1, bigInt(VarString(10, "LITERAL_STRING", title)))
    data:SetInt64(8 * 2, bigInt(VarString(10, "LITERAL_STRING", audioRef)))
    data:SetInt64(8 * 3, bigInt(VarString(10, "LITERAL_STRING", audioName)))

    local result = Citizen.InvokeNative(0x815C4065AE6E6071, cfg:Buffer(), data:Buffer(), 1)
    Wait(duration or 3000)
    Citizen.InvokeNative(0x00A15B94CBA4F76F, result)
end

-------------------------------------------------
-- Update (mission update)
-------------------------------------------------
---@param title string
---@param message string
---@param duration number?
function LcCore.Notify.Update(title, message, duration)
    local cfg = DataView.ArrayBuffer(8 * 5)

    local data = DataView.ArrayBuffer(8 * 9)
    data:SetInt64(8 * 1, bigInt(VarString(10, "LITERAL_STRING", title)))
    data:SetInt64(8 * 2, bigInt(VarString(10, "LITERAL_STRING", message)))

    local result = Citizen.InvokeNative(0x339E16B41780FC35, cfg:Buffer(), data:Buffer(), 1)
    Wait(duration or 3000)
    Citizen.InvokeNative(0x00A15B94CBA4F76F, result)
end

-------------------------------------------------
-- Warning
-------------------------------------------------
---@param title string
---@param message string
---@param audioRef string?
---@param audioName string?
---@param duration number?
function LcCore.Notify.Warning(title, message, audioRef, audioName, duration)
    local cfg = DataView.ArrayBuffer(8 * 5)

    local data = DataView.ArrayBuffer(8 * 9)
    data:SetInt64(8 * 1, bigInt(VarString(10, "LITERAL_STRING", title)))
    data:SetInt64(8 * 2, bigInt(VarString(10, "LITERAL_STRING", message)))
    if audioRef then
        data:SetInt64(8 * 3, bigInt(VarString(10, "LITERAL_STRING", audioRef)))
    end
    if audioName then
        data:SetInt64(8 * 4, bigInt(VarString(10, "LITERAL_STRING", audioName)))
    end

    local result = Citizen.InvokeNative(0x339E16B41780FC35, cfg:Buffer(), data:Buffer(), 1)
    Wait(duration or 3000)
    Citizen.InvokeNative(0x00A15B94CBA4F76F, result)
end

-------------------------------------------------
-- LeftRank (avec icone, style rank up)
-------------------------------------------------
---@param title string
---@param subtitle string
---@param dict string
---@param texture string
---@param duration number?
---@param color string?
function LcCore.Notify.LeftRank(title, subtitle, dict, texture, duration, color)
    loadTexture(dict)
    duration = duration or 5000

    local cfg = DataView.ArrayBuffer(8 * 8)
    cfg:SetInt32(8 * 0, duration)

    local data = DataView.ArrayBuffer(8 * 10)
    data:SetInt64(8 * 1, bigInt(VarString(10, "LITERAL_STRING", title)))
    data:SetInt64(8 * 2, bigInt(VarString(10, "LITERAL_STRING", subtitle)))
    data:SetInt64(8 * 4, bigInt(joaat(dict)))
    data:SetInt64(8 * 5, bigInt(joaat(texture)))
    data:SetInt64(8 * 6, bigInt(joaat(color or "COLOR_WHITE")))
    data:SetInt32(8 * 7, 1)

    Citizen.InvokeNative(0x3F9FDDBA79117C69, cfg:Buffer(), data:Buffer(), 1, 1)
    releaseTexture(dict)
end

-------------------------------------------------
-- Event handler (pour notifier depuis le server)
-------------------------------------------------
RegisterNetEvent('lc:notify', function(type, ...)
    if LcCore.Notify[type] then
        LcCore.Notify[type](...)
    else
        LcCore.Notify.Tip(tostring(type), 3000)
    end
end)
