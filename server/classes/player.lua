-- LcCore Server Class - Player (ESX-style)
-- All character methods are accessible directly on the player object.
-- Delegates to the active character internally.
-- State Bags: chaque setter sync automatiquement vers le client via Player state.
-- Events: emettent le charId (identifiant permanent), jamais la source.

---@param source number
---@param discord string
---@param characters table
---@return table
function LcCore.CreatePlayer(source, discord, characters)
    local self = {}

    self.source     = source
    self.discord    = discord
    self.characters = characters or {}
    self.char       = nil

    --- Helper: set a state bag on the player entity
    ---@param key string
    ---@param value any
    local function setState(key, value)
        Player(self.source).state:set(key, value, true)
    end

    -------------------------------------------------
    -- Identity
    -------------------------------------------------

    function self.getSource()
        return self.source
    end

    function self.getDiscord()
        return self.discord
    end

    function self.getName()
        if not self.char then return '' end
        return self.char.firstname .. ' ' .. self.char.lastname
    end

    function self.getFirstname()
        return self.char and self.char.firstname or ''
    end

    function self.getLastname()
        return self.char and self.char.lastname or ''
    end

    function self.getCharId()
        return self.char and self.char.charId or 0
    end

    -------------------------------------------------
    -- Group
    -------------------------------------------------

    function self.getGroup()
        return self.char and self.char.group or Config.DefaultGroup
    end

    ---@param group string
    function self.setGroup(group)
        if not self.char then return end
        self.char.group = group
        setState('group', group)
        TriggerEvent('lc:groupChanged', self.char.charId, group)
    end

    -------------------------------------------------
    -- Job (JSON: {name, grade, label})
    -------------------------------------------------

    ---@return table
    function self.getJob()
        if not self.char then return { name = Config.DefaultJob, grade = Config.DefaultJobGrade, label = Config.DefaultJobLabel } end
        return self.char.job
    end

    ---@param name string
    ---@param grade number
    ---@param label string?
    function self.setJob(name, grade, label)
        if not self.char then return end
        local old = self.char.job
        self.char.job = { name = name, grade = grade or 0, label = label or name }
        setState('job', self.char.job)
        TriggerEvent('lc:jobChanged', self.char.charId, self.char.job, old)
    end

    -------------------------------------------------
    -- Gang
    -------------------------------------------------

    function self.getGang()
        return self.char and self.char.gang or Config.DefaultGang
    end

    ---@param gang string
    function self.setGang(gang)
        if not self.char then return end
        self.char.gang = gang
        setState('gang', gang)
        TriggerEvent('lc:gangChanged', self.char.charId, gang)
    end

    -------------------------------------------------
    -- Money
    -------------------------------------------------

    ---@return number
    function self.getMoney()
        return self.char and self.char.money or 0
    end

    ---@param amount number
    function self.addMoney(amount)
        if not self.char then return end
        self.char.money = self.char.money + amount
        setState('money', self.char.money)
        TriggerEvent('lc:moneyChanged', self.char.charId, 'money', amount, 'add')
    end

    ---@param amount number
    ---@return boolean
    function self.removeMoney(amount)
        if not self.char or self.char.money < amount then return false end
        self.char.money = self.char.money - amount
        setState('money', self.char.money)
        TriggerEvent('lc:moneyChanged', self.char.charId, 'money', amount, 'remove')
        return true
    end

    -------------------------------------------------
    -- Gold
    -------------------------------------------------

    ---@return number
    function self.getGold()
        return self.char and self.char.gold or 0
    end

    ---@param amount number
    function self.addGold(amount)
        if not self.char then return end
        self.char.gold = self.char.gold + amount
        setState('gold', self.char.gold)
        TriggerEvent('lc:moneyChanged', self.char.charId, 'gold', amount, 'add')
    end

    ---@param amount number
    ---@return boolean
    function self.removeGold(amount)
        if not self.char or self.char.gold < amount then return false end
        self.char.gold = self.char.gold - amount
        setState('gold', self.char.gold)
        TriggerEvent('lc:moneyChanged', self.char.charId, 'gold', amount, 'remove')
        return true
    end

    -------------------------------------------------
    -- Inventory
    -------------------------------------------------

    ---@return table
    function self.getInventory()
        return self.char and self.char.inventory or {}
    end

    ---@param item string
    ---@param count number
    function self.addItem(item, count)
        if not self.char then return end
        local inv = self.char.inventory
        for _, v in ipairs(inv) do
            if v.name == item then
                v.count = v.count + count
                setState('inventory', inv)
                TriggerEvent('lc:itemChanged', self.char.charId, item, v.count, 'add')
                return
            end
        end
        inv[#inv + 1] = { name = item, count = count }
        setState('inventory', inv)
        TriggerEvent('lc:itemChanged', self.char.charId, item, count, 'add')
    end

    ---@param item string
    ---@param count number
    ---@return boolean
    function self.removeItem(item, count)
        if not self.char then return false end
        local inv = self.char.inventory
        for i, v in ipairs(inv) do
            if v.name == item then
                if v.count < count then return false end
                v.count = v.count - count
                if v.count <= 0 then
                    table.remove(inv, i)
                end
                setState('inventory', inv)
                TriggerEvent('lc:itemChanged', self.char.charId, item, count, 'remove')
                return true
            end
        end
        return false
    end

    ---@param item string
    ---@return number
    function self.getItemCount(item)
        if not self.char then return 0 end
        for _, v in ipairs(self.char.inventory) do
            if v.name == item then return v.count end
        end
        return 0
    end

    ---@return number
    function self.getSlots()
        return self.char and self.char.slots or Config.DefaultInventorySlots
    end

    ---@param amount number
    function self.addSlots(amount)
        if not self.char then return end
        self.char.slots = self.char.slots + amount
        setState('slots', self.char.slots)
    end

    -------------------------------------------------
    -- Coords
    -------------------------------------------------

    ---@return vector3
    function self.getCoords()
        return self.char and self.char.coords or Config.DefaultSpawn
    end

    ---@param coords vector3
    function self.setCoords(coords)
        if not self.char then return end
        self.char.coords = coords
    end

    -------------------------------------------------
    -- Status
    -------------------------------------------------

    ---@return boolean
    function self.isDead()
        return self.char and self.char.isDead or false
    end

    ---@param state boolean
    function self.setDead(state)
        if not self.char then return end
        self.char.isDead = state
        setState('isDead', state)
    end

    ---@return number
    function self.getXP()
        return self.char and self.char.xp or 0
    end

    ---@param amount number
    function self.addXP(amount)
        if not self.char then return end
        self.char.xp = self.char.xp + amount
        setState('xp', self.char.xp)
    end

    -------------------------------------------------
    -- Skin
    -------------------------------------------------

    ---@return table
    function self.getSkin()
        return self.char and self.char.skin or {}
    end

    ---@param skin table
    function self.setSkin(skin)
        if not self.char then return end
        self.char.skin = skin
    end

    -------------------------------------------------
    -- Character Management
    -------------------------------------------------

    ---@return table
    function self.getCharacters()
        return self.characters
    end

    ---@return number
    function self.getCharCount()
        local count = 0
        for _ in pairs(self.characters) do count = count + 1 end
        return count
    end

    ---@param char table
    function self.addCharacter(char)
        self.characters[char.charId] = char
    end

    ---@param charId number
    function self.removeCharacter(charId)
        self.characters[charId] = nil
        if self.char and self.char.charId == charId then
            self.char = nil
        end
    end

    ---@param charId number
    ---@return boolean
    function self.setActiveChar(charId)
        if self.characters[charId] then
            self.char = self.characters[charId]
            -- Sync all state bags on char select
            setState('charId', self.char.charId)
            setState('name', self.char.firstname .. ' ' .. self.char.lastname)
            setState('group', self.char.group)
            setState('job', self.char.job)
            setState('gang', self.char.gang)
            setState('money', self.char.money)
            setState('gold', self.char.gold)
            setState('inventory', self.char.inventory)
            setState('slots', self.char.slots)
            setState('isDead', self.char.isDead)
            setState('xp', self.char.xp)
            return true
        end
        return false
    end

    ---@return table?
    function self.getActiveChar()
        return self.char
    end

    return self
end
