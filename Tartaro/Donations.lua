local _, A = ...
local lifetime = 7 * 86400
local index, indexDB, expires, outgoing, cursor, requestedAt, syncAt
local function integer(value, maximum)
    local n = tonumber(value)
    return n and n == math.floor(n) and n > 0 and n <= maximum and n or nil
end
local function changed()
    index = nil
    A.invalidate("donations")
end
A.invalidateDonations = changed
local function active(request, now)
    return not request.closed and request.created <= now + 60 and request.created + lifetime > now
end
local function records()
    if not A.db then return end
    A.db.donations = A.db.donations or {}
    return A.db.donations
end
local function packet(request, closed)
    return {"DN", request.id, request.item, request.quantity, (closed or request.closed) and 1 or 0}
end

function A.resetDonations()
    if A.clearDonationTooltip then A.clearDonationTooltip() end
    index, indexDB, expires, outgoing, cursor, requestedAt, syncAt = nil, nil, nil, nil, nil, nil, nil
    local list = records()
    for id, request in pairs(list or {}) do
        if type(request) ~= "table" or type(request.created) ~= "number"
            or request.created + lifetime <= GetServerTime() then list[id] = nil end
    end
end

function A.donationMaterial(item)
    if not A.db or not integer(item, 2147483647) then return nil, "Objeto no válido." end
    local name = A.professionItem(item)
    if not name then return nil, "Cargando los datos del objeto. Volvé a intentar en unos segundos." end
    local getInfo = C_Item and C_Item.GetItemInfo or GetItemInfo
    local ok, reagent = pcall(function() return select(17, getInfo(item)) end)
    if ok and (not issecretvalue or not issecretvalue(reagent)) and reagent == true then return true end
    -- A material already read from a real recipe is also valid, including legacy cloth and herbs.
    for _, materials in pairs(TartaroDB.recipeMaterials or {}) do
        if type(materials) == "table" and materials[item] then return true end
    end
    return nil, "El cliente no identifica este objeto como material de fabricación."
end

function A.listDonations()
    local result, now = {}, GetServerTime()
    for _, request in pairs(records() or {}) do
        if active(request, now) and A.members[request.owner] then result[#result + 1] = request end
    end
    table.sort(result, function(a, b) return a.created == b.created and a.id < b.id or a.created > b.created end)
    return result
end

function A.receiveDonation(member, id, item, quantity, closed)
    local list = records()
    if not list or type(id) ~= "string" or #id > 110 then return end
    local owner, stamp = id:match("^(.+):(%d+)$")
    stamp = integer(stamp, 9007199254740991)
    local created = stamp and math.floor(stamp / 100)
    item, quantity = integer(item, 2147483647), integer(quantity, 1000000)
    local now = GetServerTime()
    if not member or owner ~= member.id or not A.members[owner] or not item or not quantity
        or not created or created > now + 60 or created + lifetime <= now
        or closed ~= "0" and closed ~= "1" then return end
    local old = list[id]
    if old then
        if old.item ~= item or old.quantity ~= quantity or old.closed or closed == "0" then return end
        old.closed = true
    else
        -- Keep closure tombstones even when the original request has not arrived yet.
        local request = {id = id, owner = owner, item = item, quantity = quantity,
            created = created, closed = closed == "1"}
        if not request.closed then
            for _, other in pairs(list) do
                if other.owner == owner and other.item == item and active(other, now) then return end
            end
        end
        list[id] = request
    end
    changed()
end

function A.createDonation(selection, quantity)
    if not A.db or not A.me then return nil, "No hay una hermandad habilitada." end
    local item = type(selection) == "number" and integer(selection, 2147483647)
    if not item then return nil, "Seleccioná un ingrediente desde los materiales de una receta." end
    quantity = integer(quantity, 1000000)
    if not quantity then return nil, "La cantidad debe ser un entero entre 1 y 1000000." end
    local valid, err = A.donationMaterial(item)
    if not valid then return nil, err end
    for _, request in pairs(records()) do
        if request.owner == A.self and request.item == item and active(request, GetServerTime()) then
            return nil, "Ya tenés una solicitud activa de este material."
        end
    end
    A.db.donationClock = math.max(GetServerTime() * 100, (A.db.donationClock or 0) + 1)
    local id = A.self .. ":" .. string.format("%.0f", A.db.donationClock)
    local request = {id = id, item = item, quantity = quantity}
    if not A.send(unpack(packet(request))) then return nil, "La cola está llena. Volvé a intentar." end
    A.receiveDonation(A.me, id, item, quantity, "0")
    return records()[id]
end

function A.closeDonation(id)
    local request = records() and records()[id]
    if not request or request.owner ~= A.self or not active(request, GetServerTime()) then return end
    if not A.send(unpack(packet(request, true))) then return nil, "La cola está llena. Volvé a intentar." end
    A.receiveDonation(A.me, id, request.item, request.quantity, "1")
    return true
end

function A.syncDonations()
    if not A.db or outgoing or syncAt and GetTime() < syncAt then return end
    syncAt = GetTime() + 10
    outgoing, cursor = {db = A.db}, 1
    for _, request in pairs(records()) do
        if request.owner == A.self and request.created + lifetime > GetServerTime() then
            outgoing[#outgoing + 1] = packet(request)
        end
    end
end

C_Timer.NewTicker(0.7, function()
    if not A.db then return end
    if not requestedAt or GetTime() - requestedAt >= 60 then
        if A.send("DQ") then requestedAt = GetTime() end
    end
    if not outgoing then return end
    if outgoing.db ~= A.db then outgoing = nil; return end
    local nextPacket = outgoing[cursor]
    if not nextPacket then outgoing = nil
    elseif A.sendProfessionPart(unpack(nextPacket)) then cursor = cursor + 1 end
end)

function A.donationNames(item)
    local now = GetServerTime()
    if not index or indexDB ~= A.db or now >= expires then
        index, indexDB, expires = {}, A.db, now + lifetime
        local seen = {}
        for _, request in ipairs(A.listDonations()) do
            local token = request.item .. ":" .. request.owner
            if not seen[token] then
                seen[token] = true
                index[request.item] = index[request.item] or {}
                index[request.item][#index[request.item] + 1] = A.members[request.owner].name
            end
            expires = math.min(expires, request.created + lifetime)
        end
        for _, names in pairs(index) do table.sort(names) end
    end
    return index[item]
end

-- Reuse only our own lines; never clear or replace lines supplied by the game or another addon.
local tooltipState = setmetatable({}, {__mode = "k"})
function A.clearDonationTooltip()
    for tooltip, entries in pairs(tooltipState) do
        for _, entry in ipairs(entries) do
            local current = entry.label:GetText()
            if (not issecretvalue or not issecretvalue(current)) and current == entry.text then
                entry.label:SetText("")
                entry.label:Hide()
            end
        end
        tooltipState[tooltip] = nil
    end
end
local function tooltip(tooltip, data)
    if tooltip ~= GameTooltip then return end
    local previous, state = tooltipState[tooltip], {}
    if previous then
        for _, entry in ipairs(previous) do
            local current = entry.label:GetText()
            if (not issecretvalue or not issecretvalue(current)) and current == entry.text then
                entry.label:SetText("")
                entry.label:Hide()
                entry.text = ""
                state[#state + 1] = entry
            end
        end
    end
    tooltipState[tooltip] = state
    if not A.db then return end
    local item = data and data.id
    if not item then
        local _, link = tooltip:GetItem()
        item = type(link) == "string" and tonumber(link:match("item:(%d+)"))
    end
    if issecretvalue and issecretvalue(item) then return end
    local names = A.donationNames(item)
    if not names then return end
    local lines = {"Solicitado como donación por:"}
    for _, name in ipairs(names) do lines[#lines + 1] = name end
    for i, value in ipairs(lines) do
        local entry = state[i]
        if entry then entry.label:SetText(value); entry.label:Show(); entry.text = value
        else
            tooltip:AddLine(value, 1, 0.78, 0.52)
            local label = _G[tooltip:GetName() .. "TextLeft" .. tooltip:NumLines()]
            if label then state[i] = {label = label, text = value} end
        end
    end
    tooltip:Show()
end
if GameTooltip then
    GameTooltip:HookScript("OnTooltipCleared", function(self) tooltipState[self] = nil end)
    if TooltipDataProcessor and Enum and Enum.TooltipDataType then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, tooltip)
    else
        pcall(GameTooltip.HookScript, GameTooltip, "OnTooltipSetItem", tooltip)
    end
end
