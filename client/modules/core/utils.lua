-- LcCore Client Module - Utilities

---@param model string|number
---@return boolean
function LcCore.LoadModel(model)
    local hash = type(model) == 'string' and GetHashKey(model) or model
    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) and timeout < 5000 do
        Wait(10)
        timeout = timeout + 10
    end
    return HasModelLoaded(hash)
end

---@param dict string
---@return boolean
function LcCore.LoadAnimDict(dict)
    RequestAnimDict(dict)
    local timeout = 0
    while not HasAnimDictLoaded(dict) and timeout < 5000 do
        Wait(10)
        timeout = timeout + 10
    end
    return HasAnimDictLoaded(dict)
end
