-- LcCore Server Module - Cron (style ox_lib)
-- Systeme de taches planifiees sans while-true loops.
--
-- Usage:
--   LcCore.Cron.New('*/5 * * * *', function() print('toutes les 5 min') end)
--   LcCore.Cron.New('0 * * * *', function() print('chaque heure') end)
--   LcCore.Cron.New('0 0 * * *', function() print('chaque minuit') end)
--
-- Format: minute hour day month weekday
--   * = tous, */N = chaque N, N = exact, N-M = range, N,M = liste

LcCore.Cron = {}

local tasks = {}
local taskId = 0

-------------------------------------------------
-- Parse cron expression
-------------------------------------------------

local function parseField(field, min, max)
    local values = {}

    for part in string.gmatch(field, '[^,]+') do
        if part == '*' then
            for i = min, max do values[i] = true end
        elseif string.find(part, '*/') then
            local step = tonumber(string.match(part, '*/(%d+)'))
            if step then
                for i = min, max, step do values[i] = true end
            end
        elseif string.find(part, '-') then
            local lo, hi = string.match(part, '(%d+)-(%d+)')
            lo, hi = tonumber(lo), tonumber(hi)
            if lo and hi then
                for i = lo, hi do values[i] = true end
            end
        else
            local num = tonumber(part)
            if num then values[num] = true end
        end
    end

    return values
end

local function parseCron(expression)
    local parts = {}
    for part in string.gmatch(expression, '%S+') do
        parts[#parts + 1] = part
    end

    if #parts ~= 5 then
        print('[LcCore] ^1Invalid cron expression:^0', expression)
        return nil
    end

    return {
        minutes  = parseField(parts[1], 0, 59),
        hours    = parseField(parts[2], 0, 23),
        days     = parseField(parts[3], 1, 31),
        months   = parseField(parts[4], 1, 12),
        weekdays = parseField(parts[5], 0, 6),
    }
end

-------------------------------------------------
-- Calculate next execution time
-------------------------------------------------

local function getNextTime(schedule)
    local now = os.time()
    local t = os.date('*t', now + 60) -- start from next minute
    t.sec = 0

    -- Try up to 366 days ahead
    for _ = 1, 527040 do -- 366 * 24 * 60
        if schedule.months[t.month]
            and schedule.days[t.day]
            and schedule.weekdays[t.wday - 1] -- os.date wday is 1-7 (Sun=1)
            and schedule.hours[t.hour]
            and schedule.minutes[t.min]
        then
            return os.time(t)
        end

        -- Advance 1 minute
        t.min = t.min + 1
        local ts = os.time(t)
        t = os.date('*t', ts)
        t.sec = 0
    end

    return nil
end

-------------------------------------------------
-- Create a cron task
-------------------------------------------------

---@param expression string -- cron expression: "*/5 * * * *"
---@param callback function
---@param label string? -- optional label for debug
---@return number taskId
function LcCore.Cron.New(expression, callback, label)
    local schedule = parseCron(expression)
    if not schedule then return -1 end

    taskId = taskId + 1
    local id = taskId

    tasks[id] = {
        id         = id,
        expression = expression,
        schedule   = schedule,
        callback   = callback,
        label      = label or ('cron_' .. id),
        active     = true,
    }

    Citizen.CreateThread(function()
        while tasks[id] and tasks[id].active do
            local nextTime = getNextTime(schedule)
            if not nextTime then
                LcCore.Print('Cron task', tasks[id].label, 'could not find next execution time')
                break
            end

            local sleepMs = (nextTime - os.time()) * 1000
            if sleepMs > 0 then
                Citizen.Wait(sleepMs)
            end

            -- Double check task is still active after sleep
            if tasks[id] and tasks[id].active then
                local ok, err = pcall(callback)
                if not ok then
                    print('[LcCore] ^1Cron error^0 (' .. (tasks[id].label) .. '):', err)
                end
            end
        end
    end)

    LcCore.Print('Cron registered:', expression, '(' .. tasks[id].label .. ')')
    return id
end

---@param id number
function LcCore.Cron.Stop(id)
    if tasks[id] then
        tasks[id].active = false
        tasks[id] = nil
    end
end

function LcCore.Cron.StopAll()
    for id in pairs(tasks) do
        LcCore.Cron.Stop(id)
    end
end
