-- LcCore Client Module - KVP (Key-Value Pairs)
-- Pour stocker des preferences/settings non-critiques cote client.
-- Pas de DB, pas de reseau, stocke localement sur la machine du joueur.
--
-- Usage:
--   LcCore.KVP.Set('hud_visible', true)
--   local visible = LcCore.KVP.Get('hud_visible', true)  -- default = true
--   LcCore.KVP.SetFloat('volume', 0.8)
--   LcCore.KVP.Delete('old_key')

LcCore.KVP = {}

local PREFIX = 'lc:'

---@param key string
---@param value string|boolean|number
function LcCore.KVP.Set(key, value)
    local t = type(value)
    if t == 'string' then
        SetResourceKvp(PREFIX .. key, value)
    elseif t == 'number' then
        if math.floor(value) == value then
            SetResourceKvpInt(PREFIX .. key, math.floor(value))
        else
            SetResourceKvpFloat(PREFIX .. key, value + 0.0)
        end
    elseif t == 'boolean' then
        SetResourceKvpInt(PREFIX .. key, value and 1 or 0)
    elseif t == 'table' then
        SetResourceKvp(PREFIX .. key, json.encode(value))
    end
end

---@param key string
---@param default any?
---@return string?
function LcCore.KVP.GetString(key, default)
    return GetResourceKvpString(PREFIX .. key) or default
end

---@param key string
---@param default number?
---@return number
function LcCore.KVP.GetInt(key, default)
    local val = GetResourceKvpInt(PREFIX .. key)
    if val == 0 and not GetResourceKvpString(PREFIX .. key) then
        return default or 0
    end
    return val
end

---@param key string
---@param default number?
---@return number
function LcCore.KVP.GetFloat(key, default)
    local val = GetResourceKvpFloat(PREFIX .. key)
    if val == 0.0 and not GetResourceKvpString(PREFIX .. key) then
        return default or 0.0
    end
    return val
end

---@param key string
---@param default boolean?
---@return boolean
function LcCore.KVP.GetBool(key, default)
    local val = GetResourceKvpInt(PREFIX .. key)
    if val == 0 and not GetResourceKvpString(PREFIX .. key) then
        return default or false
    end
    return val == 1
end

---@param key string
---@param default table?
---@return table
function LcCore.KVP.GetJSON(key, default)
    local raw = GetResourceKvpString(PREFIX .. key)
    if raw then
        return json.decode(raw) or default or {}
    end
    return default or {}
end

---@param key string
function LcCore.KVP.Delete(key)
    DeleteResourceKvp(PREFIX .. key)
end
