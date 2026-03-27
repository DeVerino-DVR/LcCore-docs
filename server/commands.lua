-- LcCore Server - Commands
-- Le callback recoit le charId au lieu de la source.

LcCore.Commands = {}

---@param name string
---@param group string|table
---@param cb function -- cb(charId, args, rawCommand)
---@param suggestion table?
function LcCore.Commands.Register(name, group, cb, suggestion)
    RegisterCommand(name, function(source, args, rawCommand)
        local player = LcCore.GetPlayer(source)
        if not player then return end

        local playerGroup <const> = player.getGroup()
        local charId <const> = player.getCharId()
        local allowed = false

        if type(group) == 'table' then
            for _, g in ipairs(group) do
                if playerGroup == g then
                    allowed = true
                    break
                end
            end
        else
            allowed = (playerGroup == group) or (group == LcCore.Groups.USER)
        end

        if not allowed then return end
        cb(charId, args, rawCommand)
    end, false)

    if suggestion then
        TriggerEvent('chat:addSuggestion', '/' .. name, suggestion.help, suggestion.params)
    end
end
