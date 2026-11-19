local _, A = ...
local groupLifetime = 30 * 60
A.eventRoleOrder = {"T", "H", "D"}
A.eventRoles = {T = "Tanque", H = "Sanador", D = "DPS"}

local function integer(value, min, max)
    local number = tonumber(value)
    if number and number % 1 == 0 and number >= min and number <= max then return number end
end

function A.eventCaps(tanks, healers, damage)
    local t, h, d = integer(tanks, 0, 40), integer(healers, 0, 40), integer(damage, 0, 40)
    if t and h and d and t + h + d > 0 and t + h + d <= 40 then return {t, h, d} end
end

function A.eventAttendance(event)
    local entries, counts, status = {}, {}, {}
    for id, signup in pairs(A.db.signups[event.id] or {}) do
        if signup.joined and A.members[id] then entries[#entries + 1] = {id = id, signup = signup} end
    end
    table.sort(entries, function(left, right)
        if left.signup.rev ~= right.signup.rev then return left.signup.rev < right.signup.rev end
        return left.id < right.id
    end)
    if event.caps then
        for index, role in ipairs(A.eventRoleOrder) do
            counts[role] = 0
            local capacity = event.caps[index]
            for _, entry in ipairs(entries) do
                if entry.signup.role == role then
                    counts[role] = counts[role] + 1
                    status[entry.id] = counts[role] <= capacity and "Confirmado" or "Suplente"
                end
            end
        end
    end
    return entries, counts, status
end

function A.resetActivities()
    A.groups, A.closedCalls, A.callRequests = {}, {}, {}
end

function A.receiveActivity(action, member, a, b, c, d, e, f)
    local now = GetServerTime()
    if action == "GR" then
        local when = integer(a, now - groupLifetime + 1, now + 5)
        local version = integer(b, 1, 2)
        local old = A.groups[member.id]
        if not when or not version or version == 1 and not A.can(member, "group")
            or old and (old.when > when or old.when == when and old.version >= version)
            or not c or c == "" or not d or d == "" or not e or e == "" then return end
        local slots
        if f and f ~= "" then
            local max, t, h, damage = f:match("^(%d+):(%d+):(%d+):(%d+)$")
            local roles = max and A.eventCaps(t, h, damage)
            max = integer(max, 1, 40)
            if not max or not roles or roles[1] + roles[2] + roles[3] > max then return end
            slots = {maximum = max, roles = roles}
        end
        A.groups[member.id] = {owner = member.id, when = when, version = version, slots = slots,
            activity = A.clean(c), location = A.clean(d), needs = A.clean(e)}
        if A.groupsChanged then A.groupsChanged() end
    elseif action == "CTX" then
        local when = integer(a, now - 299, now + 5)
        if not when then return end
        A.closedCalls[member.id] = math.max(A.closedCalls[member.id] or 0, when)
        local call = A.calls[member.id]
        if call and call.when <= when then
            A.calls[member.id] = nil
            A.invalidateMap()
        end
    elseif action == "CTJ" then
        local call = A.calls[A.self]
        if not call or call.expires <= now or a ~= A.self or tonumber(b) ~= call.when then return end
        A.callRequests[member.id] = true
    end
    A.invalidate(action == "GR" and "groups" or "map")
end

function A.publishGroup(activity, location, needs, slots)
    if not A.can(A.me, "group") then return nil, "Tu rango no puede publicar búsquedas de grupo." end
    activity, location, needs = A.clean(activity), A.clean(location), A.clean(needs)
    if activity == "" or location == "" or needs == "" then return nil, "Completá la actividad, el lugar y los roles." end
    local when = GetServerTime()
    local previous = A.groups[A.self]
    if previous and previous.when >= when then return nil, "Esperá un segundo y volvé a intentar." end
    local extra = slots and (slots.maximum .. ":" .. table.concat(slots.roles, ":")) or ""
    if not A.send("GR", when, 1, activity, location, needs, extra) then return nil, "Acortá los textos o volvé a intentar." end
    A.receiveActivity("GR", A.me, tostring(when), "1", activity, location, needs, extra)
    return A.groups[A.self]
end

function A.closeGroup(group)
    if not A.db or A.groups[A.self] ~= group or group.version ~= 1 then return end
    if A.send("GR", group.when, 2, group.activity, group.location, group.needs) then
        A.receiveActivity("GR", A.me, tostring(group.when), "2", group.activity, group.location, group.needs)
    end
end

function A.closeCall(call)
    if not A.db or A.calls[A.self] ~= call or call.expires <= GetServerTime() then return end
    if A.send("CTX", call.when) then A.receiveActivity("CTX", A.me, tostring(call.when)) end
end

function A.replayActivities()
    local group = A.groups[A.self]
    if group and group.when + groupLifetime > GetServerTime() and (group.version == 2 or A.can(A.me, "group")) then
        local extra = group.slots and (group.slots.maximum .. ":" .. table.concat(group.slots.roles, ":")) or ""
        A.send("GR", group.when, group.version, group.activity, group.location, group.needs, extra)
        if group.slots then
            A.shareGroupAttendance(group)
        end
    end
    local closed = A.closedCalls[A.self]
    if closed and closed + 300 > GetServerTime() then A.send("CTX", closed) end
end

