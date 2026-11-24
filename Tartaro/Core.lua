local _, A = ...
if A.traceLoad then A.traceLoad("module.begin", "Core.lua") end
local prefix = "TARTARO01"
local queue, queued = {}, {}
local replayQueue, replayCursor
local pendingLocation, retryLocationAt
local lastLocationPacket
local locationHeartbeat = 8
A.members, A.ranks, A.positions = {}, {}, {}
A.calls = {}
local memberAliases = {}

local readable; readable = A.traceCallback("Core.lua:13:readable", function(value)
    return not issecretvalue or not issecretvalue(value)
end)

local key; key = A.traceCallback("Core.lua:17:key", function(name)
    if not readable(name) or type(name) ~= "string" then return end
    return name:lower():gsub("%s+", "-")
end)
A.key = key

local regionalName; regionalName = A.traceCallback("Core.lua:23:regionalName", function(id)
    return id:match("^([^-]+%-[^-]+)")
end)

A.member = A.traceCallback("Core.lua:27:A.member", function(name)
    local id = key(name)
    if not id then return end
    if A.members[id] then return A.members[id] end
    for candidate, member in pairs(A.members) do
        if id == candidate .. "-" .. A.realm or candidate == id .. "-" .. A.realm then
            return member
        end
    end
    return memberAliases[regionalName(id)] or nil
end)

A.canManagePermissions = A.traceCallback("Core.lua:39:A.canManagePermissions", function(member)
    return A.db ~= nil and member ~= nil and (member.rank == 0 or member.rank == 1)
end)

A.eventOwner = A.traceCallback("Core.lua:43:A.eventOwner", function(event)
    local id = type(event) == "table" and event.id or event
    return type(id) == "string" and id:match("^(.+):%d+$") or nil
end)

A.canEditEvent = A.traceCallback("Core.lua:48:A.canEditEvent", function(member, event)
    return A.db ~= nil and member ~= nil and
        (member.rank == 0 or member.rank == 1 or A.eventOwner(event) == member.id) or false
end)

A.can = A.traceCallback("Core.lua:53:A.can", function(member, permission)
    if not member or not A.db then return false end
    if member.rank == 0 then return true end
    local grant = A.db.grants[member.rank]
    if permission == "group" then
        return not grant or grant.name ~= member.rankName or grant.group ~= false
    end
    if not grant then return permission ~= "call" and member.rank == 1 end
    return grant and grant.name == member.rankName and grant[permission] or false
end)

local roster; roster = A.traceCallback("Core.lua:64:roster", function()
    local guild, rankName, rank, realm = GetGuildInfo("player")
    local pending = not readable(guild) or not readable(rank) or not readable(rankName) or not readable(realm)
        or IsInGuild() and not guild
    A.guildStatus = pending and "pending" or guild == "Tartaro" and "allowed" or "denied"
    if pending or guild ~= "Tartaro" then
        A.guild, A.db, A.me = nil, nil, nil
        A.members, A.ranks, memberAliases = {}, {}, {}
        return
    end
    local me, playerRealm = UnitFullName("player")
    if not readable(me) or not readable(playerRealm) or not me then
        A.guildStatus = "pending"
        A.guild, A.db, A.me = nil, nil, nil
        A.members, A.ranks, memberAliases = {}, {}, {}
        return
    end
    A.realm = key(realm or playerRealm or GetNormalizedRealmName()) or ""
    local fullName = playerRealm and playerRealm ~= "" and me .. "-" .. playerRealm or me
    A.self = key(fullName)
    A.guild = guild and (guild .. "-" .. A.realm)
    A.db = nil
    A.me = nil
    A.ranks, A.members = {}, {}
    memberAliases = {}
    if not guild then return end
    TartaroDB.guilds[A.guild] = TartaroDB.guilds[A.guild] or {
        notices = {}, events = {}, signups = {}, grants = {},
    }
    A.db = TartaroDB.guilds[A.guild]
    A.db.addonSeen = A.db.addonSeen or {}
    A.db.deletedEvents = A.db.deletedEvents or {}
    A.db.eventReminders = A.db.eventReminders or {}
    A.db.professions = A.db.professions or {}
    A.db.honor = A.db.honor or {}
    A.db.honorWeekly = A.db.honorWeekly or {}
    A.db.roles = A.db.roles or {}
    A.me = { id = A.self, name = fullName, rank = rank, rankName = rankName, online = true }
    for index = 1, GetNumGuildMembers() do
        local name, title, order, level, _, _, _, _, online, _, class = GetGuildRosterInfo(index)
        local id = key(name)
        if id and readable(title) and readable(order) and type(order) == "number" then
            A.members[id] = { id = id, name = name, rank = order, rankName = title }
            if readable(online) then A.members[id].online = online end
            if readable(class) then A.members[id].class = class end
            if readable(level) and type(level) == "number" and level > 0 then A.members[id].level = level end
            A.ranks[order] = title
            local alias = regionalName(id)
            if alias then
                if memberAliases[alias] == nil then
                    memberAliases[alias] = A.members[id]
                else
                    memberAliases[alias] = false
                end
            end
        end
    end
    local current = A.member(fullName)
    if current then
        A.me, A.self = current, current.id
    elseif type(rank) == "number" then
        A.members[A.self] = A.me
    end
    A.me.online = true
    local ownLevel = UnitLevel("player")
    if readable(ownLevel) and type(ownLevel) == "number" and ownLevel > 0 then A.me.level = ownLevel end
    A.db.addonSeen[A.self] = GetServerTime()
    local rankCount = GuildControlGetNumRanks and GuildControlGetNumRanks()
    if readable(rankCount) and type(rankCount) == "number" and GuildControlGetRankName then
        for index = 1, rankCount do
            local title = GuildControlGetRankName(index)
            if readable(title) and title then A.ranks[index - 1] = title end
        end
    end
end)

local clean; clean = A.traceCallback("Core.lua:140:clean", function(value)
    return tostring(value or ""):gsub("[%c|]", " "):match("^%s*(.-)%s*$")
end)
A.clean = clean

local maxPacketBytes=250
local packetFits; packetFits = A.traceCallback("Core.lua:146:packetFits", function(packet) return #packet <= maxPacketBytes end)

A.send = A.traceCallback("Core.lua:148:A.send", function(...)
    local packet = table.concat({...}, "\t")
    if not packetFits(packet) or not A.guild then return false end
    if packet == "X" or packet:sub(1, 2) == "P\t" then
        if packet == lastLocationPacket and A.locationSent and GetTime() - A.locationSent < locationHeartbeat then
            pendingLocation = nil
            return true
        end
        pendingLocation = packet
        return true
    end
    if #queue >= 160 then return false end
    if not queued[packet] then
        queue[#queue + 1] = packet
        queued[packet] = true
    end
    return true
end)

A.clearPendingPosition = A.traceCallback("Core.lua:167:A.clearPendingPosition", function()
    pendingLocation = nil
end)

A.sendProfessionPart = A.traceCallback("Core.lua:171:A.sendProfessionPart", function(...)
    return #queue < 8 and A.send(...)
end)

local pumpReplay; pumpReplay = A.traceCallback("Core.lua:175:pumpReplay", function()
    if not replayQueue or #queue >= 8 then return end
    while replayQueue[replayCursor] do
        local packet = replayQueue[replayCursor]
        -- Oversized records from older versions cannot be sent over this channel.
        if packetFits(table.concat(packet, "\t")) then
            if A.send(unpack(packet)) then replayCursor = replayCursor + 1 end
            return
        end
        replayCursor = replayCursor + 1
    end
    replayQueue, replayCursor = nil, nil
end)

local flush; flush = A.traceCallback("Core.lua:189:flush", function()
    if not A.guild then return end
    pumpReplay()
    local now = GetTime()
    local location = pendingLocation and (not retryLocationAt or now >= retryLocationAt)
    local packet = location and pendingLocation or queue[1]
    if not packet then return end
    if C_ChatInfo.InChatMessagingLockdown and C_ChatInfo.InChatMessagingLockdown() then
        A.debugLog("transport.blocked","Core.flush","chat.lockdown",packet)
        return
    end
    local enum = Enum and Enum.SendAddonMessageResult
    local send; send = A.traceCallback("Core.lua:201:send", function()
        return select(-1, C_ChatInfo.SendAddonMessage(prefix, packet, "GUILD"))
    end)
    local ok, result = A.debugPcall("Core.lua:204:pcall", send)
    A.debugLog("transport.result","Core.flush",packet,ok,result)
    if not ok or (result ~= true and result ~= (enum and enum.Success or 0)) then
        if location then retryLocationAt = now + 2 end
        return
    end
    if location then
        pendingLocation, retryLocationAt = nil, nil
        if packet == "X" then
            lastLocationPacket, A.locationSent = nil, nil
        else
            lastLocationPacket, A.locationSent = packet, now
        end
    else
        table.remove(queue, 1)
        queued[packet] = nil
    end
end)

local eventPacket; eventPacket = A.traceCallback("Core.lua:223:eventPacket", function(event, isNew)
    local flag = isNew and "NEW" or ""
    if event.caps then flag = flag .. ":" .. table.concat(event.caps, ":") end
    local packet = {"E", event.id, event.rev, event.when, event.kind, event.title, event.detail}
    if flag ~= "" then packet[8] = flag end
    return packet
end)

local ownId; ownId = A.traceCallback("Core.lua:231:ownId", function(id, author)
    return id and id:sub(1, #author + 1) == author .. ":"
end)

local validEventTime; validEventTime = A.traceCallback("Core.lua:235:validEventTime", function(value)
    return type(value) == "number" and value > 0 and value % 1 == 0
        and value < GetServerTime() + 370 * 86400
end)

local validRevision; validRevision = A.traceCallback("Core.lua:240:validRevision", function(value)
    return type(value) == "number" and value > 0 and value % 1 == 0
        and math.floor(value / 100) <= GetServerTime() + 60
end)

local nextRevision; nextRevision = A.traceCallback("Core.lua:245:nextRevision", function()
    local previous = A.db.clock
    return math.max(validRevision(previous) and previous + 1 or 0, GetServerTime() * 100)
end)

local revision; revision = A.traceCallback("Core.lua:250:revision", function()
    A.db.clock = nextRevision()
    return A.db.clock
end)

local newId; newId = A.traceCallback("Core.lua:255:newId", function(rev)
    return A.self .. ":" .. rev
end)

local publicationPacket; publicationPacket = A.traceCallback("Core.lua:259:publicationPacket", function(rev, text, daily, when)
    if daily then return {"D", rev, text} end
    return {"N", newId(rev), when, text}
end)

A.editorMessageFits = A.traceCallback("Core.lua:264:A.editorMessageFits", function(mode, id, when, kind, title, detail, caps)
    if not A.db or not A.self then return false end
    local rev = nextRevision()
    local packet
    if mode == "event" then
        packet = eventPacket({id = id or newId(rev), rev = rev, when = when or GetServerTime(),
            kind = kind or "BG", title = clean(title), detail = clean(detail), caps = caps}, id == nil)
    else
        packet = publicationPacket(rev, clean(detail), mode == "daily", GetServerTime())
    end
    return packetFits(table.concat(packet, "\t"))
end)

local historyDays = 30 * 86400
local addonActions = {Q = true, H = true, V = true, P = true, X = true, R = true, N = true, D = true, E = true, S = true, K = true,
    F = true, FQ = true, FM = true, FR = true, HP = true, CTA = true,
    CTX = true, CTJ = true, GR = true, OR = true, OF = true, OC = true, AQ = true,
    GJ = true, GA = true, DQ = true, DN = true, DC = true, RP = true, OX = true}

A.hasUsedAddon = A.traceCallback("Core.lua:283:A.hasUsedAddon", function(member)
    return A.db and A.db.addonSeen[member.id] ~= nil
end)

local grantPacket; grantPacket = A.traceCallback("Core.lua:287:grantPacket", function(order, grant)
    return {"R", grant.rev, order, grant.notice and 1 or 0, grant.event and 1 or 0, grant.name,
        grant.call and 1 or 0, grant.editor or "", grant.group ~= false and 1 or 0}
end)

local replay; replay = A.traceCallback("Core.lua:292:replay", function()
    if not A.db or replayQueue then return end
    A.broadcastPosition()
    A.shareRole(true)
    A.shareVersion()
    A.shareHonor()
    A.replayActivities()
    local packets = {}
    if A.canManagePermissions(A.me) then
        for order, grant in pairs(A.db.grants) do
            if validRevision(grant.rev) then packets[#packets + 1] = grantPacket(order, grant) end
        end
    end
    do
        for id, deletion in pairs(A.db.deletedEvents) do
            if deletion.author == A.self and validRevision(deletion.rev) then
                packets[#packets + 1] = {"K", id, deletion.rev, deletion.when}
            end
        end
        for _, event in pairs(A.db.events) do
            if not event.shared and event.editor == A.self and validRevision(event.rev) then packets[#packets + 1] = eventPacket(event) end
        end
    end
    for id in pairs(A.db.events) do
        local signup = A.db.signups[id] and A.db.signups[id][A.self]
        if signup and not signup.shared and validRevision(signup.rev) then
            packets[#packets + 1] = {"S", id, signup.rev, signup.joined and 1 or 0, signup.role or ""}
        end
    end
    if A.can(A.me, "notice") then
        local daily = A.db.daily
        if daily and daily.author == A.self and validRevision(daily.rev) then packets[#packets + 1] = {"D", daily.rev, daily.text} end
        for id, notice in pairs(A.db.notices) do
            if notice.author == A.self then packets[#packets + 1] = {"N", id, notice.when, notice.text} end
        end
    end
    if A.addSharedReplay then A.addSharedReplay(packets, eventPacket) end
    if #packets > 0 then replayQueue, replayCursor = packets, 1 end
end)

local trim; trim = A.traceCallback("Core.lua:332:trim", function()
    if not A.db then return end
    local cutoff = GetServerTime() - historyDays
    for id, item in pairs(A.db.notices) do
        if item.when < cutoff then A.db.notices[id] = nil end
    end
    for id, item in pairs(A.db.events) do
        if item.when < cutoff then A.db.events[id], A.db.signups[id], A.db.eventReminders[id] = nil, nil, nil end
    end
    for id, deletion in pairs(A.db.deletedEvents) do
        if math.max(deletion.when, math.floor(deletion.rev / 100)) < cutoff then A.db.deletedEvents[id] = nil end
    end
end)

local newer; newer = A.traceCallback("Core.lua:346:newer", function(old, rev, author, ownerField)
    return not old or not validRevision(old.rev) or rev > old.rev or (rev == old.rev and author > old[ownerField])
end)

local observeRevision; observeRevision = A.traceCallback("Core.lua:350:observeRevision", function(rev)
    local previous = A.db.clock
    A.db.clock = math.max(validRevision(previous) and previous or 0, rev)
end)

local recordDeletion; recordDeletion = A.traceCallback("Core.lua:355:recordDeletion", function(id, rev, when, author)
    A.db.deletedEvents[id] = {rev = rev, when = when, author = author}
    A.db.events[id], A.db.signups[id], A.db.eventReminders[id] = nil, nil, nil
    observeRevision(rev)
end)

local receive; receive = A.traceCallback("Core.lua:361:receive", function(message, sender)
    if not A.db or not readable(message) then return end
    local member = A.member(sender)
    if not member or member.id == A.self then return end
    local action, a, b, c, d, e, f, g, h = strsplit("\t", message)
    A.debugLog("transport.receive","Core.receive",sender,action,#message)
    local author = member.id
    if not addonActions[action] then return end
    local wasDetected = A.hasUsedAddon(member)
    A.db.addonSeen[author] = GetServerTime()
    if not wasDetected and A.refreshMembers then A.refreshMembers() end
    local rev = tonumber(a)
    local validRev = validRevision(rev)
    if action == "Q" then
        if not A.replayAfter or GetTime() >= A.replayAfter then
            A.replayAfter = GetTime() + 10
            local guild = A.guild
            C_Timer.After(math.random(1, 4), A.traceCallback("Core.lua:378:callback", function()
                if A.guild == guild then replay() end
            end))
        end
        return
    elseif action == "RP" then
        if A.receiveSharedPart then A.receiveSharedPart(member, a, b, c, d) end
        return
    elseif action == "FQ" then
        A.shareProfessions()
        return
    elseif action == "F" then
        A.receiveProfessions(author, tonumber(a), tonumber(b), tonumber(c), d)
        return
    elseif action == "FM" then
        A.shareRecipeMaterials(tonumber(a))
        return
    elseif action == "FR" then
        A.receiveRecipeMaterials(author, tonumber(a), b)
        return
    elseif action == "HP" then
        A.receiveHonor(author, tonumber(a), tonumber(b), tonumber(c))
        return
    elseif action == "H" then
        A.receiveRole(author, a, b)
        return
    elseif action == "V" then
        A.receiveVersion(a)
        return
    elseif action == "P" then
        A.receivePosition(member, tonumber(a), tonumber(b), tonumber(c))
        return
    elseif action == "X" then
        A.positions[author] = nil
        A.invalidateMap()
        return
    elseif action == "R" and A.canManagePermissions(member) and validRev then
        local order = tonumber(b)
        if not order or order < 1 or order % 1 ~= 0 or not e then return end
        local grant = A.db.grants[order]
        local editor = g and g ~= "" and g or author
        local previousRev = grant and validRevision(grant.rev) and grant.rev or 0
        local group
        if h == "0" or h == "1" then group = h == "1" end
        if previousRev > rev or previousRev == rev and (grant.editor or "") >= editor then
            if previousRev == rev and grant.name == e and grant.group == nil and group ~= nil then
                grant.group = group
                A.invalidate("permissions")
            end
            return
        end
        if group == nil and grant and grant.name == e then group = grant.group end
        A.db.grants[order] = { name = e, notice = c == "1", event = d == "1", call = f == "1",
            group = group, rev = rev, editor = editor }
        observeRevision(rev)
    elseif action == "CTA" and A.can(member, "call") then
        A.receiveCall(member, tonumber(a), tonumber(b), tonumber(c), tonumber(d))
        return
    elseif action == "AQ" then
        A.syncOrders()
        return
    elseif action == "DQ" then
        A.syncDonations()
        return
    elseif action == "DN" or action == "DC" then
        A.receiveDonation(member, a, b, c, d, action == "DC")
        return
    elseif action == "OR" or action == "OF" or action == "OC" or action == "OX" then
        A.receiveOrder(action, member, a, b, c, d, e, f, g, h)
        return
    elseif action == "CTX" or action == "CTJ" or action == "GR" then
        A.receiveActivity(action, member, a, b, c, d, e, f, g)
        return
    elseif action == "GJ" or action == "GA" then
        A.receiveGroupAttendance(action, member, a, b, c, d, e)
        return
    elseif action == "N" and A.can(member, "notice") then
        local when = tonumber(b)
        local now = GetServerTime()
        if not ownId(a, author) or not when or when % 1 ~= 0 or when < now - historyDays or when > now + 60
            or not c or c == "" or A.db.notices[a] then return end
        A.db.notices[a] = { author = author, name = member.name, when = when, text = clean(c) }
    elseif action == "D" and validRev and b and A.can(member, "notice") then
        if not newer(A.db.daily, rev, author, "author") then return end
        A.db.daily = { author = author, rev = rev, text = clean(b) }
        observeRevision(rev)
    elseif action == "E" and a and A.canEditEvent(member, a) then
        local eventRev, when = tonumber(b), tonumber(c)
        local old = A.db.events[a]
        local deletion = A.db.deletedEvents[a]
        if not old and member.rank ~= 0 and member.rank ~= 1 and not A.can(member, "event") then return end
        if not validRevision(eventRev) or not validEventTime(when)
            or when < GetServerTime() - historyDays or not A.kinds[d] or not e or e == "" or f == nil
            or deletion and validRevision(deletion.rev) or old and not old.shared and not newer(old, eventRev, author, "editor") then return end
        A.db.deletedEvents[a] = nil
        local flag, tanks, healers, damage = (g or ""):match("^(%u*):(%d+):(%d+):(%d+)$")
        local caps = flag and A.eventCaps(tanks, healers, damage)
        A.db.events[a] = { id = a, rev = eventRev, when = when, kind = d, title = clean(e), detail = clean(f), editor = author, caps = caps }
        observeRevision(eventRev)
        local now = GetServerTime()
        if not old and when > now then
            local isNew = (flag or g) == "NEW" and ownId(a, author) and math.abs(now - math.floor(eventRev / 100)) <= 120
            A.notifyEvent(a, isNew)
        end
    elseif action == "K" and a and A.canEditEvent(member, a) then
        local deleteRev, when = tonumber(b), tonumber(c)
        local deletedAt = deleteRev and math.floor(deleteRev / 100)
        if not validRevision(deleteRev) or not validEventTime(when)
            or math.max(when, deletedAt) < GetServerTime() - historyDays
            or not newer(A.db.deletedEvents[a], deleteRev, author, "author") then return end
        recordDeletion(a, deleteRev, when, author)
    elseif action == "S" and a and (c == "1" or c == "0") then
        local deletion = A.db.deletedEvents[a]
        if deletion and validRevision(deletion.rev) then return end
        local signupRev = tonumber(b)
        local signups = A.db.signups[a] or {}
        local previous = signups[author]
        if not validRevision(signupRev) or previous and not previous.shared and validRevision(previous.rev) and previous.rev >= signupRev then return end
        A.db.signups[a] = signups
        signups[author] = { rev = signupRev, joined = c == "1", name = member.name, role = A.eventRoles[d] and d or nil }
    else
        return
    end
    if action == "R" then A.invalidate("permissions")
    elseif action == "D" then A.invalidate("daily")
    elseif action == "N" then A.invalidate("notices")
    else A.invalidate("events") end
end)

A.kinds = { BG = "Campos de batalla", RAID = "Raid", PVP = "PvP mundial", OTHER = "Otro" }

A.saveEvent = A.traceCallback("Core.lua:509:A.saveEvent", function(id, when, kind, title, detail, caps)
    if not (id and A.canEditEvent(A.me, id) or not id and A.can(A.me, "event")) then
        return nil, "Solo el creador, el líder y los sublíderes pueden editar este evento."
    end
    if id and not A.db.events[id] then return nil, "El evento ya no está disponible." end
    if not validEventTime(when) or when <= GetServerTime() then return nil, "Ingresá una fecha y hora futuras." end
    title, detail = clean(title), clean(detail)
    if title == "" then return nil, "Ingresá un título." end
    local rev = revision()
    local isNew = id == nil
    id = id or newId(rev)
    local event = { id = id, rev = rev, when = when, kind = kind, title = title, detail = detail, editor = A.self, caps = caps }
    if not A.send(unpack(eventPacket(event, isNew))) then return nil, "Acortá el texto o volvé a intentar en unos segundos." end
    A.db.events[id] = event
    return id
end)

A.deleteEvent = A.traceCallback("Core.lua:526:A.deleteEvent", function(id)
    if not A.canEditEvent(A.me, id) then return nil, "No tenés permiso para eliminar este evento." end
    local event = A.db.events[id]
    if not event then return nil, "El evento ya no está disponible." end
    local rev = revision()
    if not A.send("K", id, rev, event.when) then return nil, "Volvé a intentar en unos segundos." end
    recordDeletion(id, rev, event.when, A.self)
    return true
end)

A.publish = A.traceCallback("Core.lua:536:A.publish", function(text, daily)
    if not A.can(A.me, "notice") then return nil, "Tu rango no puede publicar avisos." end
    text = clean(text)
    if text == "" and not daily then return nil, "Escribí un aviso." end
    local rev = revision()
    local when = GetServerTime()
    if not A.send(unpack(publicationPacket(rev, text, daily, when))) then
        return nil, "Acortá el texto o volvé a intentar en unos segundos."
    end
    if daily then
        A.db.daily = { author = A.self, rev = rev, text = text }
    else
        local id = newId(rev)
        A.db.notices[id] = { author = A.self, name = A.me.name, when = when, text = text }
    end
    return true
end)

A.signup = A.traceCallback("Core.lua:554:A.signup", function(id, role)
    if not A.db or not A.db.events[id] or A.db.events[id].when <= GetServerTime() then return end
    local signups = A.db.signups[id] or {}
    local old = signups[A.self]
    local joined = role ~= nil or not (old and old.joined)
    local caps = A.db.events[id].caps
    if role and not A.eventRoles[role] or joined and caps and not role then return end
    if caps and role then
        for index, value in ipairs(A.eventRoleOrder) do
            if value == role and caps[index] == 0 then return end
        end
    end
    local rev = revision()
    if not A.send("S", id, rev, joined and 1 or 0, role or "") then return end
    A.db.signups[id] = signups
    signups[A.self] = { rev = rev, joined = joined, name = A.me.name, role = role }
end)

A.setGrant = A.traceCallback("Core.lua:572:A.setGrant", function(order, permission, enabled)
    if not A.canManagePermissions(A.me) or not A.ranks[order] or order == 0 then return end
    if permission ~= "notice" and permission ~= "event" and permission ~= "call" and permission ~= "group" then return end
    local name = A.ranks[order]
    local old = A.db.grants[order]
    if old and old.name ~= name then old = nil end
    local grant = { name = name, rev = revision(), editor = A.self }
    if not old and order == 1 then grant.notice, grant.event = true, true end
    if old then grant.notice, grant.event, grant.call, grant.group = old.notice, old.event, old.call, old.group end
    grant[permission] = enabled
    if not A.send(unpack(grantPacket(order, grant))) then return end
    A.db.grants[order] = grant
    A.invalidate("permissions")
end)

local request; request = A.traceCallback("Core.lua:587:request", function()
    if A.guild then A.send("Q") end
end)

local refreshRoster; refreshRoster = A.traceCallback("Core.lua:591:refreshRoster", function()
    local previous = A.guild
    local previousStatus = A.guildStatus
    local members, ranks = A.members, A.ranks
    roster()
    if A.guild ~= previous or A.guildStatus ~= previousStatus then
        queue, queued, A.positions, A.calls = {}, {}, {}, {}
        replayQueue, replayCursor, A.replayAfter = nil, nil, nil
        pendingLocation, retryLocationAt, lastLocationPacket = nil, nil, nil
        A.locationSent = nil
        A.resetActivities()
        A.resetOrders()
        A.resetDonations()
        if A.purgeExpired then A.purgeExpired() end
        if A.resetSharedTransfers then A.resetSharedTransfers() end
        A.resetVersionNotice()
        if A.resetGuildWindows then A.resetGuildWindows() end
        trim()
        request()
        A.requestOrders()
        A.shareRole(true)
        A.shareVersion()
        A.queuePendingEvents()
        A.professionGuildChanged()
        A.invalidateMap(true)
        A.invalidate("roster")
        return
    end
    local changed
    for id, member in pairs(A.members) do
        local old = members[id]
        if not old or member.name ~= old.name or member.rank ~= old.rank or member.rankName ~= old.rankName
            or member.online ~= old.online or member.class ~= old.class or member.level ~= old.level then
            changed = true
            break
        end
    end
    if not changed then
        for id in pairs(members) do if not A.members[id] then changed = true; break end end
    end
    if not changed then
        for order, name in pairs(A.ranks) do if ranks[order] ~= name then changed = true; break end end
    end
    if not changed then
        for order in pairs(ranks) do if not A.ranks[order] then changed = true; break end end
    end
    if changed then
        if A.invalidateDonations then A.invalidateDonations() end
        A.invalidateRecipeSearch()
        A.invalidate("roster")
        A.invalidateMap(true)
    end
end)

local requestRoster; requestRoster = A.traceCallback("Core.lua:645:requestRoster", function()
    if C_GuildInfo and C_GuildInfo.GuildRoster then
        C_GuildInfo.GuildRoster()
    elseif GuildRoster then
        GuildRoster()
    end
end)

local frame = CreateFrame("Frame")
for _, event in ipairs({"PLAYER_LOGIN", "PLAYER_GUILD_UPDATE", "GUILD_ROSTER_UPDATE", "CHAT_MSG_ADDON", "GUILD_MOTD"}) do
    frame:RegisterEvent(event)
end
frame:SetScript("OnEvent", A.traceCallback("Core.lua:657:callback", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        if A.traceLoad then A.traceLoad("core.login.begin", "Core.lua") end
        TartaroDB = TartaroDB or {}
        TartaroDB.guilds = TartaroDB.guilds or {}
        C_ChatInfo.RegisterAddonMessagePrefix(prefix)
        refreshRoster()
        requestRoster()
        C_Timer.After(5, request)
        C_Timer.NewTicker(60, request)
        C_Timer.NewTicker(0.35, flush)
        C_Timer.NewTicker(2, A.broadcastPosition)
        C_Timer.NewTicker(1, A.drawPositions)
        C_Timer.NewTicker(0.25, A.drawMinimapPositions)
        if A.traceLoad then A.traceLoad("core.login.end", "Core.lua") end
    elseif event == "CHAT_MSG_ADDON" then
        local tag, message, channel, sender = ...
        if readable(tag) and readable(channel) and tag == prefix and channel == "GUILD" then receive(message, sender) end
    elseif TartaroDB then
        refreshRoster()
        if event == "GUILD_MOTD" then A.invalidate("daily") end
        if event == "PLAYER_GUILD_UPDATE" then requestRoster() end
    end
end))
if A.traceLoad then A.traceLoad("module.end", "Core.lua") end
