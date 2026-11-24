local _, A = ...
if A.traceLoad then A.traceLoad("module.begin", "Orders.lua") end
local orderLifetime = 7 * 86400
local pending, cursor, heard, syncAt
local previews, pendingOffers

local integer; integer = A.traceCallback("Orders.lua:7:integer", function(value, min, max)
    local number = tonumber(value)
    if number and number % 1 == 0 and number >= min and number <= max then return number end
end)

local orderOwner; orderOwner = A.traceCallback("Orders.lua:12:orderOwner", function(id)
    if not id then return end
    local owner, stamp = id:match("^(.+):(%d+)$")
    local now = GetServerTime()
    local created = stamp and math.floor(tonumber(stamp) / 100)
    if created and created <= now + 120 and created + orderLifetime > now and A.members[owner] then
        return owner, created
    end
end)

local orderPacket; orderPacket = A.traceCallback("Orders.lua:22:orderPacket", function(order, closing, completed)
    local packet = {"OR", order.id, (closing or order.closed) and 1 or 0, order.spell,
        order.item, order.quantity, order.materials and 1 or 0, order.name}
    if completed or order.completed then packet[9] = "DONE" end
    return packet
end)

local previewPacket; previewPacket = A.traceCallback("Orders.lua:29:previewPacket", function(order)
    return {"OC", order.id, 0, order.spell, order.item, order.quantity, order.materials and 1 or 0, order.name}
end)

A.resetOrders = A.traceCallback("Orders.lua:33:A.resetOrders", function()
    pending, cursor, heard, syncAt = nil, nil, nil, nil
    previews, pendingOffers = {}, {}
    if not A.db then return end
    A.db.orders, A.db.offers = A.db.orders or {}, A.db.offers or {}
    A.db.orderPreviews = A.db.orderPreviews or {}
    A.db.orderCopyClosed = A.db.orderCopyClosed or {}
    previews = A.db.orderPreviews
    for _, data in ipairs({previews, A.db.orderCopyClosed}) do
        for id in pairs(data) do
            local stamp = id:match(":(%d+)$")
            if not stamp or math.floor(tonumber(stamp) / 100) + orderLifetime <= GetServerTime() then data[id] = nil end
        end
    end
    for id in pairs(A.db.orders) do
        local stamp = id:match(":(%d+)$")
        if not stamp or math.floor(tonumber(stamp) / 100) + orderLifetime <= GetServerTime() then
            A.db.orders[id], A.db.offers[id] = nil, nil
        end
    end
    if A.db.orderProtocol ~= 2 then
        for id, order in pairs(A.db.orders) do
            if order.owner ~= A.self then
                if not order.closed then order.unverified = true; previews[id] = order end
                A.db.orders[id] = nil
            end
        end
        A.db.offers = {}
        A.db.orderProtocol = 2
    end
end)

local verifyOffer; verifyOffer = A.traceCallback("Orders.lua:65:verifyOffer", function(id, crafter)
    local order = A.db.orders[id] or previews[id]
    if order and order.unverified and A.db.orderCopyClosed[id] then return end
    if not orderOwner(id) or not A.members[crafter] or order and order.closed then return end
    if not order then return false end
    if not A.knowsRecipe(crafter, order.spell) then return false end
    local offers = A.db.offers[id] or {}
    offers[crafter] = true
    A.db.offers[id] = offers
    return true
end)

A.verifyOrderOffers = A.traceCallback("Orders.lua:77:A.verifyOrderOffers", function(crafter)
    local offers = pendingOffers and pendingOffers[crafter]
    if not offers then return end
    local changed
    for id in pairs(offers) do
        local verified = verifyOffer(id, crafter)
        if verified ~= false then offers[id] = nil end
        if verified then changed = true end
    end
    if not next(offers) then pendingOffers[crafter] = nil end
    if changed then A.invalidate("orders") end
end)

local applyOrder; applyOrder = A.traceCallback("Orders.lua:90:applyOrder", function(order, closed, completed)
    local id = order.id
    local old = A.db.orders[id]
    if old and (not closed or old.closed and (old.completed or not completed)) then return end
    order.closed, order.completed = closed, completed
    previews[id] = nil
    A.db.orders[id] = order
    for crafter, offers in pairs(pendingOffers) do
        if offers[id] then
            local verified = verifyOffer(id, crafter)
            if verified ~= false then offers[id] = nil end
            if not next(offers) then pendingOffers[crafter] = nil end
        end
    end
    A.invalidate("orders")
    return true
end)

A.receiveOrder = A.traceCallback("Orders.lua:108:A.receiveOrder", function(action, member, a, b, c, d, e, f, g, h)
    if action == "OR" or action == "OC" or action == "OX" then
        local owner, created = orderOwner(a)
        local spell, item, quantity = integer(c, 1, 2147483647), integer(d, 0, 2147483647), integer(e, 1, 999)
        local old = a and A.db.orders[a]
        if not owner or (b ~= "0" and b ~= "1") or not spell or not item or not quantity
            or (f ~= "0" and f ~= "1") or not g or g == "" or #g > 120 then return end
        local completed = b == "1" and h == "DONE"
        local order = {id = a, owner = owner, created = created,
            spell = spell, item = item, quantity = quantity, materials = f == "1", name = A.clean(g)}
        if order.name == "" then return end
        if action == "OX" then
            if b ~= "1" or owner == A.self or owner == member.id then return end
            order.closed, order.completed = true, completed
            A.db.orderCopyClosed[a] = order
            previews[a] = nil
            A.invalidate("orders")
            return
        elseif action == "OC" then
            if b ~= "0" or owner == A.self or owner == member.id or A.db.orderCopyClosed[a] then return end
            if heard then heard[table.concat(previewPacket(order), "\t")] = true end
            if old or previews[a] then return end
            order.unverified, order.sharedBy = true, member.id
            previews[a] = order
            for crafter in pairs(pendingOffers) do A.verifyOrderOffers(crafter) end
            A.invalidate("orders")
            return
        end
        if owner ~= member.id then return end
        return applyOrder(order, b == "1", completed)
    elseif action == "OF" then
        local owner = orderOwner(a)
        local crafter = member.id
        if not owner or owner == crafter or (b and b ~= crafter) or (A.db.offers[a] or {})[crafter] then return end
        local verified = verifyOffer(a, crafter)
        if verified == false then
            local offers = pendingOffers[crafter] or {}
            offers[a] = true
            pendingOffers[crafter] = offers
        end
        if not verified then return end
    end
    A.invalidate("orders")
end)

A.createOrder = A.traceCallback("Orders.lua:153:A.createOrder", function(recipe, amount, materials)
    if not A.db then return end
    local quantity = integer(amount, 1, 999)
    if not quantity then return nil, "Ingresá una cantidad de 1 a 999." end
    local now = GetServerTime()
    local stamp = math.max(now * 100, (A.db.orderClock or 0) + 1)
    while A.db.orders[A.self .. ":" .. stamp] do stamp = stamp + 1 end
    local id = A.self .. ":" .. stamp
    local owner, created = orderOwner(id)
    if not owner then return nil, "No se pudo asignar una fecha al pedido. Volvé a intentar." end
    local order = {id = id, owner = owner, created = created,
        spell = recipe.spell, item = recipe.item, quantity = quantity, materials = materials,
        name = A.clean(recipe.object or recipe.name)}
    if #order.name > 120 or not A.send(unpack(orderPacket(order))) then
        return nil, "No se pudo publicar el pedido. Volvé a intentar."
    end
    A.db.orderClock = stamp
    return applyOrder(order, false, false)
end)

A.closeOrder = A.traceCallback("Orders.lua:173:A.closeOrder", function(order, completed)
    if not A.db or A.db.orders[order.id] ~= order or order.owner ~= A.self or order.closed or not orderOwner(order.id) then return end
    if not A.send(unpack(orderPacket(order, true, completed))) then return end
    return applyOrder(order, true, completed == true)
end)

A.canCraftOrder = A.traceCallback("Orders.lua:179:A.canCraftOrder", function(order)
    return A.db and order and not order.closed and not (order.unverified and A.db.orderCopyClosed[order.id])
        and A.knowsRecipe(A.self, order.spell)
end)

A.offerOrder = A.traceCallback("Orders.lua:184:A.offerOrder", function(order)
    if not A.db or (A.db.orders[order.id] or previews[order.id]) ~= order or order.closed or order.owner == A.self
        or not orderOwner(order.id) or not A.canCraftOrder(order) or not A.send("OF", order.id) then return end
    A.receiveOrder("OF", A.me, order.id)
    return true
end)

A.listOrders = A.traceCallback("Orders.lua:191:A.listOrders", function()
    local active, completed = {}, {}
    for _, order in pairs(A.db.orders) do
        if orderOwner(order.id) then
            if not order.closed then
                active[#active + 1] = order
            elseif order.completed and (order.owner == A.self or (A.db.offers[order.id] or {})[A.self]) then
                completed[#completed + 1] = order
            end
        end
    end
    for id, order in pairs(previews) do
        if orderOwner(id) and not A.db.orderCopyClosed[id] and not A.db.orders[id] then active[#active + 1] = order end
    end
    local newest; newest = A.traceCallback("Orders.lua:205:newest", function(left, right)
        return left.created > right.created or left.created == right.created and left.id > right.id
    end)
    table.sort(active, newest)
    table.sort(completed, newest)
    return active, completed
end)

A.orderOfferSummary = A.traceCallback("Orders.lua:213:A.orderOfferSummary", function(id)
    local offers=A.db and A.db.offers[id] or {}
    local result={members={},own=not not offers[A.self],any=false}
    for crafter,offered in pairs(offers) do
        local member=A.members[crafter]
        if member then
            result.members[#result.members+1]=member
            if offered then result.any=true end
        end
    end
    return result
end)

A.listVisibleOrders = A.traceCallback("Orders.lua:226:A.listVisibleOrders", function()
    local active, completed = A.listOrders()
    local visible = {}
    for _, order in ipairs(active) do
        local summary=A.orderOfferSummary(order.id)
        if order.owner == A.self or summary.own or (not summary.any and A.knowsRecipe(A.self, order.spell)) then
            visible[#visible + 1] = order
        end
    end
    return visible, completed
end)

A.requestOrders = A.traceCallback("Orders.lua:238:A.requestOrders", function()
    local db = A.db
    if not db then return end
    for _, delay in ipairs({3, 18}) do
        C_Timer.After(delay, A.traceCallback("Orders.lua:242:callback", function()
            if A.db == db then A.send("AQ") end
        end))
    end
    A.syncOrders()
end)

A.syncOrders = A.traceCallback("Orders.lua:249:A.syncOrders", function()
    if not A.db or pending then return end
    pending, cursor, heard, syncAt = {}, 1, {}, GetTime() + math.random(1, 10)
    for id, order in pairs(A.db.orders) do
        if orderOwner(id) then
            if order.owner == A.self then
                pending[#pending + 1] = orderPacket(order)
            elseif not order.closed then
                pending[#pending + 1] = previewPacket(order)
            else
                local packet = orderPacket(order)
                packet[1] = "OX"
                pending[#pending + 1] = packet
            end
        end
    end
    for id, order in pairs(previews) do
        if not A.db.orders[id] and not A.db.orderCopyClosed[id] and orderOwner(id) then
            pending[#pending + 1] = previewPacket(order)
        end
    end
    for id, order in pairs(A.db.orderCopyClosed) do
        if type(order) == "table" and not A.db.orders[id] and orderOwner(id) then
            local packet = orderPacket(order)
            packet[1] = "OX"
            pending[#pending + 1] = packet
        end
    end
    for id, offers in pairs(A.db.offers) do
        local order = A.db.orders[id] or previews[id]
        if offers[A.self] and order and not order.closed and orderOwner(id) and A.canCraftOrder(order) then
            pending[#pending + 1] = {"OF", id}
        end
    end
end)

A.purgeOrderState = A.traceCallback("Orders.lua:285:A.purgeOrderState", function()
    if not A.db then return 0 end
    local now, removed = GetServerTime(), 0
    local expired; expired = A.traceCallback("Orders.lua:288:expired", function(id)
        local stamp = type(id) == "string" and id:match(":(%d+)$")
        return stamp and math.floor(tonumber(stamp) / 100) + orderLifetime <= now
    end)
    for _, data in ipairs({A.db.orders, A.db.orderPreviews, A.db.orderCopyClosed, A.db.offers}) do
        for id in pairs(data or {}) do
            if expired(id) then data[id] = nil; removed = removed + 1 end
        end
    end
    for crafter, offers in pairs(pendingOffers or {}) do
        for id in pairs(offers) do if expired(id) then offers[id] = nil end end
        if not next(offers) then pendingOffers[crafter] = nil end
    end
    if removed > 0 then A.invalidate("orders") end
    return removed
end)

C_Timer.NewTicker(0.7, A.traceCallback("Orders.lua:305:callback", function()
    if not pending or GetTime() < syncAt then return end
    local packet = pending[cursor]
    while packet do
        local order = A.db.orders[packet[2]] or previews[packet[2]] or A.db.orderCopyClosed[packet[2]]
        if order and orderOwner(order.id) then
            if packet[1] == "OR" and order.owner == A.self then
                packet = orderPacket(order)
                break
            elseif packet[1] == "OX" and order.closed then
                break
            elseif not order.closed and not heard[table.concat(packet, "\t")] then
                break
            end
        end
        cursor = cursor + 1
        packet = pending[cursor]
    end
    if not packet then pending, heard = nil, nil; return end
    if A.sendProfessionPart(unpack(packet)) then cursor = cursor + 1 end
end))
if A.traceLoad then A.traceLoad("module.end", "Orders.lua") end
