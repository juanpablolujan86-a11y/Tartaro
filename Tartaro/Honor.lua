local _, A = ...
if A.traceLoad then A.traceLoad("module.begin", "Honor.lua") end
local honorCurrency = 1792
local maximumTotal = 1000000000
local scheduled
local monthStart = {0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334}

A.honorWeek = A.traceCallback("Honor.lua:8:A.honorWeek", function()
    local calendar = C_DateAndTime and C_DateAndTime.GetCurrentCalendarTime
    local now = calendar and calendar()
    if not now or not now.year or not monthStart[now.month] or not now.monthDay or not now.weekday then return end
    local priorYear = now.year - 1
    local leap = now.year % 4 == 0 and (now.year % 100 ~= 0 or now.year % 400 == 0)
    local day = 365 * priorYear + math.floor(priorYear / 4) - math.floor(priorYear / 100)
        + math.floor(priorYear / 400) + monthStart[now.month] + now.monthDay - 1
    if leap and now.month > 2 then day = day + 1 end
    -- Calendar weekdays are Sunday = 1. Wednesday at 24:00 is Thursday = 5.
    return day - (now.weekday - 5) % 7
end)

A.weeklyHonor = A.traceCallback("Honor.lua:21:A.weeklyHonor", function(id, week)
    local entry = A.db.honorWeekly[id]
    return week and entry and entry.week == week and entry.points or 0
end)

local validPoints; validPoints = A.traceCallback("Honor.lua:26:validPoints", function(points)
    return (not issecretvalue or not issecretvalue(points))
        and type(points) == "number" and points > 0 and points <= maximumTotal and points % 1 == 0
end)

A.shareHonor = A.traceCallback("Honor.lua:31:A.shareHonor", function()
    local points = A.db and A.db.honor[A.self]
    if not points then return end
    local week = A.honorWeek()
    if week then A.send("HP", points, week, A.weeklyHonor(A.self, week))
    else A.send("HP", points) end
end)

A.receiveHonor = A.traceCallback("Honor.lua:39:A.receiveHonor", function(author, points, week, weekly)
    if not validPoints(points) then return end
    local changed
    if points > (A.db.honor[author] or 0) then
        A.db.honor[author] = points
        changed = true
    end
    if week and week == A.honorWeek() and validPoints(weekly) and weekly <= points
        and weekly > A.weeklyHonor(author, week) then
        A.db.honorWeekly[author] = {week = week, points = weekly}
        changed = true
    end
    if changed then A.refreshHonor() end
end)

local frame = CreateFrame("Frame")
frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
frame:SetScript("OnEvent", A.traceCallback("Honor.lua:56:callback", function(_, _, currency, _, change)
    if not A.db or (issecretvalue and issecretvalue(currency)) or currency ~= honorCurrency or not validPoints(change) then return end
    local total = (A.db.honor[A.self] or 0) + change
    if total > maximumTotal then return end
    A.db.honor[A.self] = total
    local week = A.honorWeek()
    if week then A.db.honorWeekly[A.self] = {week = week, points = A.weeklyHonor(A.self, week) + change} end
    A.refreshHonor()
    if not scheduled then
        scheduled = true
        C_Timer.After(3, A.traceCallback("Honor.lua:66:callback", function()
            scheduled = false
            A.shareHonor()
        end))
    end
end))

local lastWeek
C_Timer.NewTicker(5, A.traceCallback("Honor.lua:74:callback", function()
    if not A.db then return end
    local week = A.honorWeek()
    if week ~= lastWeek then
        lastWeek = week
        A.refreshHonor()
    end
end))
if A.traceLoad then A.traceLoad("module.end", "Honor.lua") end
