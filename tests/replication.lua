-- Persistent snapshots, the real Core queue/receiver, duplicated packets and an offline author.
local clients, tickers, wire, current = {}, {}, {}, nil
local clock, now = 20, 1800000000
GetTime = function() return clock end
GetServerTime = function() return now end
GameTooltip = nil
local function noop() end
CreateFrame = function()
    return {RegisterEvent = noop, SetScript = function(self, event, fn) self[event] = fn end}
end
strsplit = function(separator, text)
    local fields = {}
    for value in (text .. separator):gmatch("(.-)" .. separator) do fields[#fields + 1] = value end
    return unpack(fields)
end
C_Timer = {After = noop, NewTicker = function(_, fn) tickers[#tickers + 1] = {client = current, fn = fn} end}
C_ChatInfo = {SendAddonMessage = function(prefix, packet, channel)
    assert(prefix == "TARTARO01" and channel == "GUILD" and #packet <= 250)
    wire[#wire + 1] = {sender = current.name, data = packet}
    return 0
end}
C_Item = {GetItemInfo = function() return "Material", nil, 1, 1, 1, nil, nil, 200, nil, 1, 0, 7, 0, 0, 0, nil, true end}
local function upvalue(fn, wanted)
    for i = 1, 50 do
        local name, value = debug.getupvalue(fn, i)
        if name == wanted then return value end
    end
    error("Missing upvalue " .. wanted)
end
local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for k, v in pairs(value) do result[k] = copy(v) end
    return result
end
local function spawn(name, saved)
    local ctx = {name = name, online = true, saved = saved or {guilds = {}, recipeMaterials = {}}}
    current, TartaroDB = ctx, ctx.saved
    local A = {}
    ctx.A = A
    local function load(file) assert(loadfile("Tartaro/" .. file .. ".lua"))("Tartaro", A) end
    local lastFrame
    local create = CreateFrame
    CreateFrame = function(...) lastFrame = create(...); return lastFrame end
    load("Core")
    ctx.frame = lastFrame
    CreateFrame = create
    A.realm, A.guild, A.self = "realm", "Tartaro-realm", name
    A.members = {}
    for _, id in ipairs({"author", "relay", "fresh", "late", "leader", "sub", "officer", "stress"}) do
        local rank = id == "leader" and 0 or id == "sub" and 1 or (id == "author" or id == "officer") and 2 or 3
        A.members[id] = {id = id, name = id, rank = rank, rankName = "Rank" .. rank, online = true}
    end
    A.me = A.members[name]
    ctx.saved.guilds[A.guild] = ctx.saved.guilds[A.guild] or {events = {}, notices = {}, signups = {},
        grants = {[2] = {name = "Rank2", event = true}}, deletedEvents = {}, eventReminders = {}, addonSeen = {}, professions = {}}
    A.db = ctx.saved.guilds[A.guild]
    for _, method in ipairs({"broadcastPosition", "shareRole", "shareVersion", "shareHonor", "invalidate",
        "invalidateMap", "refreshMembers"}) do A[method] = noop end
    ctx.notifications = {}
    A.notifyEvent = function(id) ctx.notifications[id] = (ctx.notifications[id] or 0) + 1 end
    load("Activities"); A.resetActivities()
    load("Replication")
    load("Professions")
    A.professionItem = function() return "Material" end
    load("Orders"); A.resetOrders()
    load("Donations"); A.resetDonations()
    ctx.flush = upvalue(ctx.frame.OnEvent, "flush")
    ctx.replay = upvalue(upvalue(ctx.frame.OnEvent, "receive"), "replay")
    clients[name] = ctx
    return ctx
end
local function run(fn, ctx, ...)
    current, TartaroDB = ctx, ctx.saved
    return fn(...)
end
local function settle(steps)
    for _ = 1, steps or 100 do
        clock = clock + 0.4
        for _, timer in ipairs(tickers) do if timer.client.online then run(timer.fn, timer.client) end end
        for _, ctx in pairs(clients) do if ctx.online then run(ctx.flush, ctx) end end
        local messages = wire; wire = {}
        for _, message in ipairs(messages) do
            for id, ctx in pairs(clients) do
                if ctx.online and id ~= message.sender then
                    for _ = 1, 2 do -- delivery duplication must be harmless
                        run(ctx.frame.OnEvent, ctx, ctx.frame, "CHAT_MSG_ADDON", "TARTARO01", message.data, "GUILD", message.sender)
                    end
                end
            end
        end
    end
end
local function replay(ctx)
    run(ctx.replay, ctx)
    run(ctx.A.syncOrders, ctx)
    run(ctx.A.syncDonations, ctx)
    settle(160)
end
local function count(t) local n = 0; for _ in pairs(t) do n = n + 1 end; return n end
local author, relay = spawn("author"), spawn("relay")
local event = assert(run(author.A.saveEvent, author, nil, now + 3600, "PVP", "Original %09 event", string.rep("x", 110)))
assert(run(author.A.createOrder, author, {spell = 7420, item = 0, name = "Enchant"}, "1", false))
local donation = assert(run(author.A.createDonation, author, 1, 12))
settle(100)
assert(relay.A.db.events[event] and not relay.A.db.signups[event]) -- not signed up, still cached
assert(count(relay.A.db.orders) == 1 and count(relay.A.db.donations) == 1)
author.online = false
local saved = copy(relay.saved)
relay.online = false
relay = spawn("relay", saved) -- a new namespace using only its persisted data
local fresh = spawn("fresh")
replay(relay)
assert(count(fresh.A.db.events) == 1 and fresh.A.db.events[event].shared)
assert(fresh.A.db.events[event].title == "Original %09 event")
assert(fresh.notifications[event] == 1)
assert(#run(fresh.A.listOrders, fresh) == 1 and run(fresh.A.listOrders, fresh)[1].unverified)
assert(#run(fresh.A.listDonations, fresh) == 1 and fresh.A.db.donations[donation.id].unverified)
run(fresh.A.signup, fresh, event)
settle(100)
assert(relay.A.db.signups[event].fresh.joined and not relay.A.db.signups[event].fresh.shared)
for _ = 1, 3 do replay(relay) end
assert(count(fresh.A.db.events) == 1 and count(relay.A.db.signups[event]) == 1)
assert(#run(fresh.A.listOrders, fresh) == 1 and #run(fresh.A.listDonations, fresh) == 1)
assert(fresh.notifications[event] == 1)
fresh.online = false
fresh = spawn("fresh", copy(fresh.saved))
assert(fresh.A.db.events[event] and fresh.A.db.signups[event].fresh.joined)
assert(#run(fresh.A.listOrders, fresh) == 1 and #run(fresh.A.listDonations, fresh) == 1)
local late = spawn("late")
replay(fresh)
assert(late.A.db.events[event] and late.A.db.signups[event].fresh.joined)
assert(#run(late.A.listOrders, late) == 1 and #run(late.A.listDonations, late) == 1)
assert(not run(fresh.A.saveEvent, fresh, event, now + 4000, "PVP", "Unauthorized", ""))
local officer = spawn("officer")
assert(not officer.A.canEditEvent(officer.A.me, event)) -- creation grant does not grant editing another author's event
assert(author.A.canEditEvent(author.A.members.sub, event) and author.A.canEditEvent(author.A.members.leader, event))
author.online = true
replay(author)
assert(not fresh.A.db.events[event].shared)
local confirmed = fresh.A.db.events[event]
local confirmedClock = fresh.A.db.clock
local relayed = relay.A.db.events[event]
local originalTitle, originalRev = relayed.title, relayed.rev
relayed.title, relayed.rev = "Altered relay copy", relayed.rev + 500
replay(relay)
assert(fresh.A.db.events[event] == confirmed and confirmed.title == "Original %09 event")
assert(fresh.A.db.clock == confirmedClock) -- unconfirmed revisions never advance the authoritative clock
relayed.title, relayed.rev = originalTitle, originalRev
local order = run(author.A.listOrders, author)[1]
assert(run(author.A.closeOrder, author, order))
assert(run(author.A.closeDonation, author, donation.id))
assert(run(author.A.deleteEvent, author, event))
settle(100)
author.online = false
late.online = false
local clean = spawn("late")
replay(relay)
assert(not clean.A.db.events[event] and clean.A.db.sharedEventDeletes[event])
assert(#run(clean.A.listOrders, clean) == 0 and #run(clean.A.listDonations, clean) == 0)
replay(fresh)
assert(not clean.A.db.events[event] and #run(clean.A.listOrders, clean) == 0)
assert(count(relay.A.db.signups[event] or {}) == 0)
-- More relay fragments than the Core's 160-message limit must drain without omissions.
author.online = true
for i = 1, 180 do
    assert(run(author.A.saveEvent, author, nil, now + 7200, "PVP", "Bulk " .. i, string.rep("z", 110)))
    settle(2)
end
settle(100)
assert(count(relay.A.db.events) == 180)
author.online, fresh.online, clean.online, officer.online = false, false, false, false
local stress = spawn("stress")
run(relay.replay, relay)
settle(1200)
assert(count(stress.A.db.events) == 180)
for _, value in pairs(stress.notifications) do assert(value == 1) end
print("Replication: offline author, unjoined cache/reload, three relay hops, duplicate delivery, unique signups, permissions and closure tombstones passed.")
print("Replication queue: 180 cached events recovered once each, despite more than 160 relay fragments.")
