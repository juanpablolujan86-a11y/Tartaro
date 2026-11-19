-- Issue #6: three simulated clients, real Orders/Professions modules and packet delivery.
local now, clock = 1800000000, 50
GetServerTime = function() return now end
GetTime = function() return clock end
local timers, clients, wire = {}, {}, {}
C_Timer = {After = function() end, NewTicker = function(_, fn) timers[#timers + 1] = fn end}
local function client(id)
    local A = {self = id, guild = "Tartaro-realm", members = {}}
    assert(loadfile("Tartaro/Core.lua"))("Tartaro", A)
    A.self, A.guild = id, "Tartaro-realm"
    for _, name in ipairs({"owner", "crafter", "other"}) do A.members[name] = {id = name, name = name, online = true} end
    A.me = A.members[id]
    A.db = {orders = {}, offers = {}, orderProtocol = 2, professions = {}}
    for _, name in ipairs({"owner", "crafter", "other"}) do
        A.db.professions[name] = {list = {[333] = {recipes = {[7420] = 0, [1001] = 55}}}}
    end
    A.invalidate = function() end
    A.send = function(...)
        local packet = {...}
        for i, value in ipairs(packet) do packet[i] = tostring(value) end
        wire[#wire + 1] = {sender = id, packet = packet}
        return true
    end
    A.sendProfessionPart = A.send
    assert(loadfile("Tartaro/Professions.lua"))("Tartaro", A)
    assert(loadfile("Tartaro/Orders.lua"))("Tartaro", A)
    A.resetOrders()
    clients[id] = A
    return A
end
local owner, crafter, other = client("owner"), client("crafter"), client("other")
local function deliver()
    local messages = wire
    wire = {}
    for _, message in ipairs(messages) do
        for id, A in pairs(clients) do
            if id ~= message.sender then
                A.receiveOrder(message.packet[1], A.members[message.sender], unpack(message.packet, 2))
            end
        end
    end
end
for _, recipe in ipairs({{spell = 7420, item = 0, name = "Enchant chest"},
    {spell = 1001, item = 55, name = "Crafted item"}}) do
    assert(owner.createOrder(recipe, "1", false))
    deliver()
    local order = assert(owner.listOrders()[1])
    local id, created = order.id, order.created
    assert(crafter.offerOrder(crafter.db.orders[id]))
    deliver()
    assert(other.offerOrder(other.db.orders[id]))
    deliver()
    for _, A in pairs(clients) do
        assert(#A.listOrders() == 1 and not A.db.orders[id].closed)
        assert(A.db.offers[id].crafter and A.db.offers[id].other)
        assert(A.db.orders[id].item == recipe.item and A.db.orders[id].created == created)
        A.receiveOrder("OF", A.members.crafter, id)
        A.receiveOrder("OR", A.members.crafter, id, "1", tostring(recipe.spell), tostring(recipe.item), "1", "0", recipe.name)
        assert(not A.db.orders[id].closed)
        A.resetOrders() -- simulate the order module's reconnect/reload initialization
        assert(#A.listOrders() == 1 and A.db.offers[id].crafter)
        A.syncOrders()
    end
    clock = clock + 20
    for _ = 1, 5 do for _, fn in ipairs(timers) do fn() end; deliver() end
    for _, A in pairs(clients) do assert(#A.listOrders() == 1 and not A.db.orders[id].closed) end
    assert(owner.closeOrder(owner.db.orders[id], true))
    deliver()
    for _, A in pairs(clients) do
        assert(#A.listOrders() == 0 and A.db.orders[id].completed)
        A.receiveOrder("OR", A.members.owner, id, "0", tostring(recipe.spell), tostring(recipe.item), "1", "0", recipe.name)
        assert(A.db.orders[id].closed) -- old open replay cannot undo a legitimate completion
    end
    now = now + 1
end
print("Issue #6 packet flow: two crafters preserve open enchantment/item orders across offers, replay and reload; only owner closes.")
