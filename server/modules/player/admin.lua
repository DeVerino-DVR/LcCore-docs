-- LcCore Server Module - Admin
-- Toutes les fonctions prennent un charId, pas une source.

LcCore.Admin = {}

---@param charId number
---@return boolean
function LcCore.Admin.IsAdmin(charId)
    local player = LcCore.GetPlayerByCharId(charId)
    if not player then return false end
    local group = player.getGroup()
    return group == LcCore.Groups.ADMIN or group == LcCore.Groups.SUPERADMIN
end

---@param charId number
---@param group string
function LcCore.Admin.SetGroup(charId, group)
    local player = LcCore.GetPlayerByCharId(charId)
    if not player then return end
    player.setGroup(group)
end

---@param charId number
---@param reason string?
function LcCore.Admin.Kick(charId, reason)
    local source = LcCore.GetSourceByCharId(charId)
    if not source then return end
    DropPlayer(tostring(source), reason or 'Kicked by admin')
end

---@param charId number
---@param reason string?
---@param duration number?
---@param adminCharId number?
function LcCore.Admin.Ban(charId, reason, duration, adminCharId)
    local player = LcCore.GetPlayerByCharId(charId)
    if not player then return end

    local discord <const> = player.getDiscord()
    local expire = duration and os.date('%Y-%m-%d %H:%M:%S', os.time() + duration) or nil
    local adminDiscord = nil

    if adminCharId then
        local admin = LcCore.GetPlayerByCharId(adminCharId)
        if admin then adminDiscord = admin.getDiscord() end
    end

    MySQL.insert('INSERT INTO lc_bans (discord, reason, expire, banned_by) VALUES (?, ?, ?, ?)', {
        discord, reason, expire, adminDiscord
    })

    LcCore.Admin.Kick(charId, reason or 'Banni')
end

---@param discord string
function LcCore.Admin.Unban(discord)
    MySQL.query('DELETE FROM lc_bans WHERE discord = ?', { discord })
end
