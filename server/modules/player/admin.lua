-- LcCore Server Module - Admin

LcCore.Admin = {}

---@param source number
---@return boolean
function LcCore.Admin.IsAdmin(source)
    local player = LcCore.GetPlayer(source)
    if not player then return false end
    local group = player.getGroup()
    return group == LcCore.Groups.ADMIN or group == LcCore.Groups.SUPERADMIN
end

---@param source number
---@param group string
function LcCore.Admin.SetGroup(source, group)
    local player = LcCore.GetPlayer(source)
    if not player then return end
    player.setGroup(group)
end

---@param source number
---@param reason string?
function LcCore.Admin.Kick(source, reason)
    DropPlayer(source, reason or 'Kicked by admin')
end

---@param source number
---@param reason string?
---@param duration number? -- seconds, nil = permanent
---@param bannedBy number? -- source of admin
function LcCore.Admin.Ban(source, reason, duration, bannedBy)
    local player = LcCore.GetPlayer(source)
    if not player then return end

    local discord = player.getDiscord()
    local expire = duration and os.date('%Y-%m-%d %H:%M:%S', os.time() + duration) or nil
    local adminDiscord = nil

    if bannedBy then
        local admin = LcCore.GetPlayer(bannedBy)
        if admin then adminDiscord = admin.getDiscord() end
    end

    MySQL.insert('INSERT INTO lc_bans (discord, reason, expire, banned_by) VALUES (?, ?, ?, ?)', {
        discord, reason, expire, adminDiscord
    })

    LcCore.Admin.Kick(source, reason or 'Banni')
end

---@param discord string
function LcCore.Admin.Unban(discord)
    MySQL.query('DELETE FROM lc_bans WHERE discord = ?', { discord })
end
