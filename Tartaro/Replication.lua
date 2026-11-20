local _, A = ...
local transfers, serial = {}, 0
local session = tostring(GetServerTime()) .. "-" .. tostring(math.random(1, 999999))
local history = 30 * 86400
local function integer(value)
    local n = tonumber(value)
    return n and n > 0 and n % 1 == 0 and n < 9007199254740991 and n or nil
end
local function revision(value)
    local n = integer(value)
    return n and math.floor(n / 100) <= GetServerTime() + 60 and n or nil
end
local function sendCopy(packets, data)
    local payload = table.concat(data, "\t"):gsub("%%", "%%25"):gsub("\t", "%%09")
    if #payload > 1280 then return end
    serial = serial + 1
    local token, total = session .. "-" .. tostring(serial), math.ceil(#payload / 160)
    for index = 1, total do
        packets[#packets + 1] = {"RP", token, index, total, payload:sub((index - 1) * 160 + 1, index * 160)}
    end
end

function A.resetSharedTransfers() transfers = {} end

function A.addSharedReplay(packets, eventPacket)
    if not A.db then return end
    for id, deletion in pairs(A.db.deletedEvents) do
        if deletion.author ~= A.self then
            sendCopy(packets, {"K", id, deletion.rev, deletion.when, deletion.author})
        end
    end
    for id, deletion in pairs(A.db.sharedEventDeletes or {}) do
        if not A.db.deletedEvents[id] then
            sendCopy(packets, {"K", id, deletion.rev, deletion.when, deletion.author})
        end
    end
    for id, event in pairs(A.db.events) do
        if event.editor ~= A.self or event.shared then
            local packet = eventPacket(event)
            packet[8], packet[9] = packet[8] or "", event.editor or A.eventOwner(event)
            sendCopy(packets, packet)
        end
        for author, signup in pairs(A.db.signups[id] or {}) do
            if author ~= A.self then
                sendCopy(packets, {"S", id, signup.rev, author, signup.joined and 1 or 0, signup.role or ""})
            end
        end
    end
end

local function apply(member, payload)
    local action, id, b, c, d, e, f, g, h = strsplit("\t", payload)
    local db, now = A.db, GetServerTime()
    local owner = A.eventOwner(id)
    if not db or not owner then return end
    db.sharedEventDeletes = db.sharedEventDeletes or {}
    if action == "E" then
        local rev, when = revision(b), integer(c)
        local editor = A.members[h or ""]
        local old, deleted = db.events[id], db.sharedEventDeletes[id]
        if not rev or not when or when < now - history or when >= now + 370 * 86400
            or not A.kinds[d] or not e or e == "" or f == nil or not editor or not A.canEditEvent(editor, id)
            or db.deletedEvents[id] or deleted or old and (not old.shared or old.rev >= rev) then return end
        local flag, t, heal, damage = (g or ""):match("^(%u*):(%d+):(%d+):(%d+)$")
        db.events[id] = {id = id, rev = rev, when = when, kind = d, title = A.clean(e), detail = A.clean(f),
            editor = h, caps = flag and A.eventCaps(t, heal, damage) or nil, shared = true, sharedBy = member.id}
        if not old and when > now then A.notifyEvent(id, false) end
    elseif action == "K" then
        local rev, when = revision(b), integer(c)
        local editor, old = A.members[d or ""], db.events[id]
        local previous = db.sharedEventDeletes[id]
        if not rev or not when or when >= now + 370 * 86400 or math.max(when, math.floor(rev / 100)) < now - history
            or not editor or not A.canEditEvent(editor, id) or previous and previous.rev >= rev then return end
        if old and not old.shared then return end
        -- A relay can retire an unconfirmed copy, never change an authoritative event.
        db.sharedEventDeletes[id] = {rev = rev, when = when, author = d}
        if old and old.shared and rev >= old.rev then
            db.events[id], db.signups[id], db.eventReminders[id] = nil, nil, nil
        end
    elseif action == "S" then
        local rev, player = revision(b), A.members[c or ""]
        if not rev or not player or player.id == A.self or not db.events[id] or d ~= "1" and d ~= "0" then return end
        local signups = db.signups[id] or {}
        local old = signups[player.id]
        if old and (not old.shared or old.rev >= rev) then return end
        signups[player.id] = {rev = rev, joined = d == "1", name = player.name,
            role = A.eventRoles[e] and e or nil, shared = true, sharedBy = member.id}
        db.signups[id] = signups
    else return end
    A.invalidate("events")
end

function A.receiveSharedPart(member, token, part, count, data)
    if not A.db or not token or not token:match("^%d+%-%d+%-%d+$") or #token > 40 or type(data) ~= "string" or #data > 160 then return end
    part, count = integer(part), integer(count)
    if not part or not count or count > 8 or part > count then return end
    local now, keys = GetTime(), 0
    for key, transfer in pairs(transfers) do
        if transfer.expires < now or transfer.db ~= A.db then transfers[key] = nil else keys = keys + 1 end
    end
    local key = member.id .. ":" .. token
    local transfer = transfers[key]
    if not transfer then
        if keys >= 64 then return end
        transfer = {db = A.db, count = count, parts = {}, received = 0, expires = now + 30}
        transfers[key] = transfer
    end
    if transfer.count ~= count or transfer.parts[part] then return end
    transfer.parts[part], transfer.received = data, transfer.received + 1
    if transfer.received == count then
        transfers[key] = nil
        apply(member, table.concat(transfer.parts):gsub("%%09", "\t"):gsub("%%25", "%%"))
    end
end
