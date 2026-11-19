local A = {}
local now, tick = 1800000000, 0
local frames, timers, packets = {}, {}, {}
GetServerTime = function() return now end
GetTime = function() return tick end
C_Timer = {
    After = function(delay, fn) timers[#timers + 1] = fn end,
    NewTicker = function(delay, fn) end,
}
CreateFrame = function()
    local frame = {scripts = {}}
    function frame:RegisterEvent() end
    function frame:SetScript(event, fn) self.scripts[event] = fn end
    frames[#frames + 1] = frame
    return frame
end
local function load(name) assert(loadfile("Tartaro/" .. name .. ".lua"))("Tartaro", A) end
local function noop() end
load("Core")
local core = frames[1]
local guild = "Other"
GetGuildInfo = function() return guild, "Leader", 0, "Realm" end
IsInGuild = function() return true end
UnitFullName = function() return "Alice", "Realm" end
GetNormalizedRealmName = function() return "Realm" end
GetNumGuildMembers = function() return 2 end
GetGuildRosterInfo = function(i)
    return i == 1 and "Alice-Realm" or "Bob-Realm", "Leader", 0, 60, nil, nil, nil, nil, true, nil, "WARRIOR"
end
UnitLevel = function() return 60 end
TartaroDB = {guilds = {preserved = {sentinel = true}}, recipeMaterials = {}}
for _, name in ipairs({"resetActivities", "resetOrders", "resetDonations", "resetVersionNotice", "requestOrders",
    "shareRole", "shareVersion", "queuePendingEvents", "professionGuildChanged", "invalidateMap", "invalidate",
    "invalidateRecipeSearch", "broadcastPosition", "drawPositions", "drawMinimapPositions"}) do A[name] = noop end
C_ChatInfo = {RegisterAddonMessagePrefix = noop}
core.scripts.OnEvent(core, "PLAYER_LOGIN")
assert(A.guildStatus == "denied" and not A.db and not A.send("Q"))
assert(TartaroDB.guilds.preserved.sentinel and not TartaroDB.guilds["Other-realm"])
guild = "Tartaro"
core.scripts.OnEvent(core, "GUILD_ROSTER_UPDATE")
assert(A.db and A.guild == "Tartaro-realm" and A.can(A.me, "group"))
local saved = A.db
guild = nil
core.scripts.OnEvent(core, "GUILD_ROSTER_UPDATE")
assert(A.guildStatus == "pending" and not A.db and not A.guild and not next(A.members))
guild = "Tartaro"
core.scripts.OnEvent(core, "GUILD_ROSTER_UPDATE")
assert(A.db == saved)
guild = "Tártaro"
core.scripts.OnEvent(core, "GUILD_ROSTER_UPDATE")
assert(A.guildStatus == "denied" and not A.db and TartaroDB.guilds["Tartaro-realm"] == saved)
guild = "Tartaro"
core.scripts.OnEvent(core, "GUILD_ROSTER_UPDATE")

load("Activities")
load("GroupFinder")
C_QuestLog = {
    GetNumQuestLogEntries = function() return 3 end,
    GetInfo = function(i) return i == 1 and {isHeader = true} or {questID = 42, title = "Test mission"} end,
}
GetQuestLink = function(id) assert(id == 42); return "|cffffff00|Hquest:42:60|h[Test mission]|h|r" end
A.send = function(...) local p = {...}; assert(#table.concat(p, "\t") <= 250); packets[#packets + 1] = p; return true end
A.resetActivities()
assert(#A.groupDestinations("QUEST") == 1)
local group, err = A.publishGroupSelection("QUEST", 42, "", "Here", "1", "0", "2")
assert(group, err)
assert(group.questLink == GetQuestLink(42) and group.activity:find("Test mission", 1, true))
C_QuestLog.GetInfo = function() return {isHeader = true} end
assert(not A.publishGroupSelection("QUEST", 42, "", "Here", "1", "0", "2"))
GetNumBattlegroundTypes = function() return 1 end
GetBattlegroundInfo = function() return "Cuenca de Arathi", nil, nil, nil, nil, nil, nil, 15 end
assert(A.groupDestinations("BG")[1].maximum == 15)
assert(not A.publishGroupSelection("BG", "bg:Cuenca de Arathi", "", "Here", "2", "2", "12"))
now = now + 1
local bg = A.publishGroupSelection("BG", "bg:Cuenca de Arathi", "", "Here", "2", "2", "6")
assert(bg and bg.slots.maximum == 15)
C_LFGList = {GetAvailableActivities = function(id) return {id * 10} end,
    GetActivityInfoTable = function(id) return {categoryID = id / 10, fullName = "Destination " .. id} end}
assert(A.groupDestinations("DUNGEON")[1].id == 20)
assert(A.groupDestinations("RAID")[1].id == 30)
assert(not A.publishGroupSelection("OTHER", nil, "Test", "Here", "0", "0", "0"))

local metadataLoaded = true
C_Item = {GetItemInfo = function(item)
    if not metadataLoaded then return end
    return "Material " .. item, "link", 1, 1, 1, "Trade", "Cloth", 200, "", 1, 0, 7, 0, 0, 0, nil, item == 1
end}
load("Professions")
load("Donations")
A.resetDonations()
A.sendProfessionPart = A.send
local function create(item, quantity)
    local result, message = A.createDonation(item, quantity)
    assert(result, message)
    return result
end
local first = create("|cffffffff|Hitem:1:0|h[Cloth]|h|r", "12")
assert(first.created == now and #A.listDonations() == 1)
assert(not A.createDonation(1, 12))
assert(not A.createDonation(2, 12))
assert(not A.createDonation(3, 1.5))
assert(not A.createDonation(3, 1000001))
TartaroDB.recipeMaterials[25] = {[2] = 4}
local ingredient = create(2, 4)
metadataLoaded = false
assert(not A.createDonation(3, 1))
metadataLoaded = true
TartaroDB.recipeMaterials[25][3] = 1
assert(create(3, 1))
local bob = A.member("Bob-Realm")
local alice = A.me
A.receiveDonation(bob, first.id, 1, 12, "1")
assert(not first.closed)
A.receiveDonation(bob, bob.id .. ":" .. now * 100, 1, 5, "0")
bob.online = false
assert(#A.donationNames(1) == 2 and #A.listDonations() == 4)
assert(A.closeDonation(first.id))
A.receiveDonation(alice, first.id, 1, 12, "0")
assert(first.closed and #A.donationNames(1) == 1)
local second = create(1, 7)
assert(second.id ~= first.id)
local tombstone = alice.id .. ":" .. (now * 100 + 50)
A.receiveDonation(alice, tombstone, 9, 1, "1")
A.receiveDonation(alice, tombstone, 9, 1, "0")
assert(A.db.donations[tombstone].closed)
A.resetDonations()
assert(first.closed and A.db.donations[first.id].closed)
strsplit = function(separator, value)
    local fields = {}
    for part in (value .. separator):gmatch("(.-)" .. separator) do fields[#fields + 1] = part end
    return unpack(fields)
end
local dispatched = bob.id .. ":" .. (now * 100 + 55)
core.scripts.OnEvent(core, "CHAT_MSG_ADDON", "TARTARO01", "DN\t" .. dispatched .. "\t6\t3\t0", "GUILD", bob.name)
assert(A.db.donations[dispatched] and A.db.donations[dispatched].quantity == 3)
core.scripts.OnEvent(core, "CHAT_MSG_ADDON", "TARTARO01", "DN\t" .. dispatched .. "\t6\t3\t1", "GUILD", alice.name)
assert(not A.db.donations[dispatched].closed)
A.syncDonations()
now = now + 7 * 86400
assert(#A.listDonations() == 0 and not A.donationNames(1))
-- A failed enqueue never creates or closes local state.
A.send = function() return false end
assert(not A.createDonation(1, 10))
assert(#A.listDonations() == 0)
print("Guild eligibility, quest selection, BG capacities and donation lifecycle passed.")
