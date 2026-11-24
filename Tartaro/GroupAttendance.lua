local _, A = ...
if A.traceLoad then A.traceLoad("module.begin", "GroupAttendance.lua") end
local records = {}
local outgoing, outgoingIndex
local pendingRequests = {}

local current; current = A.traceCallback("GroupAttendance.lua:7:current", function(owner, when)
    local group = A.groups[owner]
    if group and group.when == tonumber(when) and group.version == 1 and group.slots
        and group.when + 1800 > GetServerTime() and A.can(A.members[owner], "group") then return group end
end)

local state; state = A.traceCallback("GroupAttendance.lua:13:state", function(group)
    local data = records[group.owner]
    if not data or data.when ~= group.when or data.db ~= A.db then
        data = {when = group.when, db = A.db, members = {}, serial = 0}
        records[group.owner] = data
    end
    return data
end)

A.groupAttendance = A.traceCallback("GroupAttendance.lua:22:A.groupAttendance", function(group)
    local counts, total, members = {T = 0, H = 0, D = 0}, 0, {}
    for id, entry in pairs(state(group).members) do
        if A.members[id] and A.eventRoles[entry.role] then
            counts[entry.role] = counts[entry.role] + 1
            total = total + 1
            members[id] = entry.role
        end
    end
    return counts, total, members
end)

A.shareGroupAttendance = A.traceCallback("GroupAttendance.lua:34:A.shareGroupAttendance", function(group)
    if group.owner ~= A.self or not current(group.owner, group.when) then return end
    if outgoing then return end
    outgoing, outgoingIndex = {}, 1
    for id in pairs(state(group).members) do outgoing[#outgoing + 1] = id end
    outgoing.group = group
    outgoing.db = A.db
end)

A.receiveGroupAttendance = A.traceCallback("GroupAttendance.lua:43:A.receiveGroupAttendance", function(action, sender, a, b, c, d)
    if action == "GJ" then
        local group = a == A.self and current(A.self, b)
        if not group or (c ~= "-" and not A.eventRoles[c]) then return end
        local counts, total, members = A.groupAttendance(group)
        local existing = members[sender.id]
        local data = state(group)
        local old = data.members[sender.id]
        if existing == c or c == "-" and not existing then
            if old then A.send("GA", group.when, old.serial, sender.id, old.role) end
            return
        end
        if c ~= "-" then
            local index = c == "T" and 1 or c == "H" and 2 or 3
            if counts[c] >= group.slots.roles[index] or not existing and total >= group.slots.maximum then
                A.send("GA", group.when, 0, sender.id, "FULL")
                return
            end
        end
        local serial = data.serial + 1
        if not A.send("GA", group.when, serial, sender.id, c) then return end
        data.serial = serial
        data.members[sender.id] = {serial = serial, role = c}
        A.invalidate("groups")
    elseif action == "GA" then
        local group = current(sender.id, a)
        local serial = tonumber(b)
        if not group or not A.members[c] or not serial or serial % 1 ~= 0 or serial < 0 or serial > 1000000 then return end
        if d == "FULL" then
            if serial == 0 and c == A.self then
                pendingRequests[sender.id] = nil
                print("Tártaro: ese rol ya está completo. Elegí otro cupo disponible.")
            end
            return
        end
        if serial == 0 or (d ~= "-" and not A.eventRoles[d]) then return end
        local data = state(group)
        local old = data.members[c]
        if old and old.serial >= serial then return end
        data.members[c] = {serial = serial, role = d}
        if c == A.self then pendingRequests[sender.id] = nil end
        A.invalidate("groups")
    end
end)

A.requestGroupRole = A.traceCallback("GroupAttendance.lua:88:A.requestGroupRole", function(group, role)
    if not current(group.owner, group.when) then return end
    if group.owner == A.self then
        A.receiveGroupAttendance("GJ", A.me, A.self, tostring(group.when), role)
    elseif A.send("GJ", group.owner, group.when, role) then
        pendingRequests[group.owner] = {group = group, role = role, sent = GetTime(), db = A.db}
        A.invalidate("groups")
    end
end)

A.groupRequestPending = A.traceCallback("GroupAttendance.lua:98:A.groupRequestPending", function(group)
    local pending = pendingRequests[group.owner]
    return pending and pending.group == group and pending.db == A.db
end)

C_Timer.NewTicker(0.7, A.traceCallback("GroupAttendance.lua:103:callback", function()
    if not outgoing then return end
    local group = outgoing.group
    if outgoing.db ~= A.db or A.groups[A.self] ~= group or not current(A.self, group.when) then outgoing = nil; return end
    local id = outgoing[outgoingIndex]
    if not id then outgoing = nil; return end
    local entry = state(group).members[id]
    if not entry or A.sendProfessionPart("GA", group.when, entry.serial, id, entry.role) then outgoingIndex = outgoingIndex + 1 end
end))

C_Timer.NewTicker(5, A.traceCallback("GroupAttendance.lua:113:callback", function()
    for owner, pending in pairs(pendingRequests) do
        if pending.db ~= A.db or A.groups[owner] ~= pending.group or not current(owner, pending.group.when) then
            pendingRequests[owner] = nil
        elseif GetTime() - pending.sent >= 5 then
            if A.send("GJ", owner, pending.group.when, pending.role) then pending.sent = GetTime() end
        end
    end
end))
if A.traceLoad then A.traceLoad("module.end", "GroupAttendance.lua") end
