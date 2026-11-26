local _, A = ...
if A.traceLoad then A.traceLoad("module.begin", "Map.lua") end
local pins = {}
local nativePins = {}
local minimapPins = {}
local hookedMap
local hookedOpenMap
local mapUpdatePending, mapUpdateSerial = nil, 0
local cachedGroup, groupUntil
local locationLifetime = 75
local dotTexture = "Interface\\AddOns\\Tartaro\\MapDot"
local nativeTemplate = "TartaroWorldMapPinTemplate"
TartaroWorldMapPinMixin = {}

local readable; readable = A.traceCallback("Map.lua:15:readable", function(value)
    return not issecretvalue or not issecretvalue(value)
end)

local number; number = A.traceCallback("Map.lua:19:number", function(value)
    return readable(value) and type(value) == "number" and value > -math.huge and value < math.huge
end)

local coordinate; coordinate = A.traceCallback("Map.lua:23:coordinate", function(value)
    return number(value) and value >= 0 and value <= 1
end)

A.invalidateMap = A.traceCallback("Map.lua:27:A.invalidateMap", function(groupChanged)
    if groupChanged then cachedGroup = nil end
    if mapUpdatePending or not WorldMapFrame or not WorldMapFrame:IsShown() then return end
    mapUpdateSerial = mapUpdateSerial + 1
    local token = mapUpdateSerial
    mapUpdatePending = token
    C_Timer.After(0.12, A.traceCallback("Map.lua:33:callback", function()
        if mapUpdatePending ~= token then return end
        mapUpdatePending = nil
        A.drawPositions()
    end))
end)

A.receivePosition = A.traceCallback("Map.lua:40:A.receivePosition", function(member, mapID, x, y)
    if not mapID or mapID <= 0 or mapID % 1 ~= 0 or not coordinate(x) or not coordinate(y) then return end
    local position = A.positions[member.id]
    local changed = not position or position.mapID ~= mapID or position.x ~= x or position.y ~= y or position.name ~= member.name
    if not position then position = {}; A.positions[member.id] = position end
    position.mapID, position.x, position.y, position.name = mapID, x, y, member.name
    position.expires = GetTime() + locationLifetime
    if changed then A.invalidateMap() end
end)

local mapViewChanged; mapViewChanged = A.traceCallback("Map.viewChanged", function() A.invalidateMap() end)

local ownPosition; ownPosition = A.traceCallback("Map.lua:52:ownPosition", function()
    if IsInInstance() then return end
    local mapID = C_Map.GetBestMapForUnit("player")
    if not readable(mapID) or not mapID then return end
    local position = C_Map.GetPlayerMapPosition(mapID, "player")
    if not readable(position) or not position then return end
    local x, y = position:GetXY()
    if coordinate(x) and coordinate(y) and (x ~= 0 or y ~= 0) then
        return mapID, x, y
    end
end)

local wireCoordinate; wireCoordinate = A.traceCallback("Map.lua:64:wireCoordinate", function(value)
    local scaled = math.floor(value * 100000 + 0.5)
    return ("%d.%05d"):format(math.floor(scaled / 100000), scaled % 100000)
end)

local callLifetime, callCooldown = 300, 30

local callRestriction; callRestriction = A.traceCallback("Map.lua:71:callRestriction", function()
    if UnitIsGhost("player") then return "No podés lanzar el llamado como fantasma." end
    if IsInInstance() then return "El llamado solo se puede lanzar en PvP de mundo, fuera de instancias." end
    if not A.can(A.me, "call") then return "Tu rango no puede lanzar llamados." end
end)

A.prepareCall = A.traceCallback("Map.lua:77:A.prepareCall", function()
    local reason = callRestriction()
    if reason then return nil, reason end
    local mapID, x, y = ownPosition()
    if not mapID then return nil, "El llamado requiere una ubicación al aire libre." end
    return {mapID = mapID, x = x, y = y}
end)

A.callLocation = A.traceCallback("Map.lua:85:A.callLocation", function(call)
    local info = C_Map.GetMapInfo(call.mapID)
    local name = info and readable(info.name) and info.name or ("Zona " .. call.mapID)
    return ("%s · %.0f, %.0f"):format(name, call.x * 100, call.y * 100)
end)

local groupedMembers
local callParty, callPartyDB

local inCallParty; inCallParty = A.traceCallback("Map.lua:94:inCallParty", function(grouped, now, previousCalls)
    local active = false
    for id in pairs(grouped) do
        if id ~= A.self then
            local call = previousCalls[id] or previousCalls[A.self]
            if callPartyDB == A.db and callParty and callParty[id] or call and call.expires > now then
                active = true
                break
            end
        end
    end
    callParty, callPartyDB = active and grouped or nil, A.db
    return active
end)

A.receiveCall = A.traceCallback("Map.lua:109:A.receiveCall", function(member, when, mapID, x, y)
    local now = GetServerTime()
    if not number(when) or when % 1 ~= 0 or when > now + 5 or now - when >= callLifetime
        or not number(mapID) or mapID <= 0 or mapID % 1 ~= 0 or not coordinate(x) or not coordinate(y) then return end
    local previous = A.calls[member.id]
    if (A.closedCalls[member.id] or 0) >= when then return end
    if previous and when - previous.when < callCooldown then return end
    local call = {author = member.id, name = member.name, when = when, expires = when + callLifetime, mapID = mapID, x = x, y = y}
    local grouped = groupedMembers()
    local quiet = inCallParty(grouped, now, A.calls) and grouped[member.id]
    A.calls[member.id] = call
    inCallParty(grouped, now, A.calls)
    if member.id == A.self then A.callRequests = {} end
    A.invalidateMap()
    if member.id ~= A.self and not quiet and not IsInInstance() then
        A.showCall(call)
        A.playCallSound(true)
    end
end)

A.sendCall = A.traceCallback("Map.lua:129:A.sendCall", function(position)
    local reason = callRestriction()
    if reason then return nil, reason end
    local now = GetServerTime()
    local previous = A.calls[A.self]
    local last = math.max(previous and previous.when or 0, A.closedCalls[A.self] or 0)
    if now - last < callCooldown then return nil, "Esperá 30 segundos entre llamados." end
    if not A.send("CTA", now, position.mapID, wireCoordinate(position.x), wireCoordinate(position.y)) then
        return nil, "No se pudo enviar el llamado. Volvé a intentar."
    end
    A.receiveCall(A.me, now, position.mapID, position.x, position.y)
    return true
end)

A.openCallMap = A.traceCallback("Map.lua:143:A.openCallMap", function(call)
    local map = WorldMapFrame
    if not map then return end
    ShowUIPanel(map)
    map:SetMapID(call.mapID)
    local api = OpenMapAPI
    if api and api.major == 1 and api.IsStitched and api.IsStitched() and api.WorldFromMap and api.ShowWorld then
        local u, v = api.WorldFromMap(call.mapID, call.x, call.y)
        if number(u) and number(v) then api.ShowWorld(u, v) end
    end
    A.drawPositions()
end)

A.broadcastPosition = A.traceCallback("Map.lua:156:A.broadcastPosition", function()
    if not A.guild or TartaroDB.shareLocation == false then return end
    A.clearPendingPosition()
    local mapID, x, y = ownPosition()
    if mapID then A.send("P", mapID, wireCoordinate(x), wireCoordinate(y)) end
end)

A.locationStatus = A.traceCallback("Map.lua:163:A.locationStatus", function()
    if TartaroDB.shareLocation == false then return "Tu ubicación está desactivada." end
    if not ownPosition() then return "WoW no proporciona coordenadas para tu ubicación actual." end
    if not A.locationSent or GetTime() - A.locationSent > locationLifetime then return "Esperando poder enviar tu ubicación." end
    return "Tu ubicación se está enviando."
end)

A.setSharing = A.traceCallback("Map.lua:170:A.setSharing", function(enabled)
    TartaroDB.shareLocation = enabled
    A.clearPendingPosition()
    if enabled then A.broadcastPosition() else A.send("X") end
end)

groupedMembers = A.traceCallback("Map.lua:176:callback", function()
    local now = GetTime()
    if cachedGroup and now < groupUntil then return cachedGroup end
    local grouped = {}
    local raid = IsInRaid()
    for index = 1, raid and GetNumGroupMembers() or GetNumSubgroupMembers() do
        local name, realm = UnitFullName((raid and "raid" or "party") .. index)
        if readable(name) and readable(realm) and name then
            local member = A.member(realm and realm ~= "" and name .. "-" .. realm or name)
            if member then grouped[member.id] = true end
        end
    end
    cachedGroup, groupUntil = grouped, now + 1
    return grouped
end)

local groupEvents = CreateFrame("Frame")
groupEvents:RegisterEvent("GROUP_ROSTER_UPDATE")
groupEvents:SetScript("OnEvent", A.traceCallback("Map.lua:194:callback", function()
    A.invalidateMap(true)
    if A.db then inCallParty(groupedMembers(), GetServerTime(), A.calls) end
end))

local stitchedCoordinates; stitchedCoordinates = A.traceCallback("Map.lua:199:stitchedCoordinates", function(api, position, mapID)
    if api.CanvasFromWorldPos and C_Map.GetWorldPosFromMapPos then
        local continent, world = C_Map.GetWorldPosFromMapPos(position.mapID, CreateVector2D(position.x, position.y))
        if continent and world then
            local x, y = world:GetXY()
            local mx, my = api.CanvasFromWorldPos(continent, x, y)
            if number(mx) and number(my) then return mx, my end
        end
    end
    if api.WorldFromMap and api.MapFromWorld then
        local u, v = api.WorldFromMap(position.mapID, position.x, position.y)
        if number(u) and number(v) then return api.MapFromWorld(mapID, u, v) end
    end
end)

local mapRect; mapRect = A.traceCallback("Map.lua:214:mapRect", function(inner, outer)
    if not C_Map.GetMapRectOnMap then return end
    local left, right, top, bottom = C_Map.GetMapRectOnMap(inner, outer)
    if coordinate(left) and coordinate(right) and coordinate(top) and coordinate(bottom)
        and right > left and bottom > top then
        return left, right, top, bottom
    end
end)

local mapCoordinates; mapCoordinates = A.traceCallback("Map.lua:223:mapCoordinates", function(position, mapID, stitched)
    if stitched then return stitchedCoordinates(stitched, position, mapID) end
    if mapID == position.mapID then return position.x, position.y end
    local left, right, top, bottom = mapRect(position.mapID, mapID)
    if left then
        return left + (right - left) * position.x, top + (bottom - top) * position.y
    end
    left, right, top, bottom = mapRect(mapID, position.mapID)
    if left then
        return (position.x - left) / (right - left), (position.y - top) / (bottom - top)
    end
    local continent, world = C_Map.GetWorldPosFromMapPos(position.mapID, CreateVector2D(position.x, position.y))
    if not continent or not world then return end
    local targetContinent = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0.5, 0.5))
    if targetContinent ~= continent then return end
    local projectedMap, projected = C_Map.GetMapPosFromWorldPos(continent, world, mapID)
    if (projectedMap == mapID or projectedMap == nil) and projected then return projected:GetXY() end
end)

local colorPin; colorPin = A.traceCallback("Map.lua:242:colorPin", function(pin, member, isCall)
    local class = member and member.class
    local color = class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
    local r = isCall and 1 or color and color.r or 0.85
    local g = isCall and 1 or color and color.g or 0.85
    local b = isCall and 1 or color and color.b or 0.85
    if pin.tartaroR ~= r or pin.tartaroG ~= g or pin.tartaroB ~= b then
        pin.dot:SetVertexColor(r,g,b)
        pin.tartaroR, pin.tartaroG, pin.tartaroB = r,g,b
    end
end)

local placePin; placePin = A.traceCallback("Map.placePin", function(pin, parent, anchor, x, y)
    if pin:GetParent() ~= parent then
        pin:SetParent(parent)
        pin.tartaroX = nil
    end
    if pin.tartaroX ~= x or pin.tartaroY ~= y or pin.tartaroAnchor ~= anchor then
        pin:ClearAllPoints()
        pin:SetPoint("CENTER",parent,anchor,x,y)
        pin.tartaroX, pin.tartaroY, pin.tartaroAnchor = x,y,anchor
    end
end)

local newPin; newPin = A.traceCallback("Map.lua:266:newPin", function(canvas)
    local pin = CreateFrame("Frame", nil, canvas)
    pin:SetSize(11, 11)
    pin:SetFrameStrata(canvas:GetFrameStrata())
    pin.dot = pin:CreateTexture(nil, "ARTWORK")
    pin.dot:SetAllPoints()
    pin.dot:SetTexture(dotTexture)
    if pin.EnableMouseMotion and pin.EnableMouseClicks then
        pin:EnableMouseClicks(false)
        pin:EnableMouseMotion(true)
    end
    pin:SetScript("OnEnter", A.traceCallback("Map.lua:277:callback", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.character, 1, 0.8, 0.55)
        GameTooltip:Show()
    end))
    pin:SetScript("OnLeave", A.traceCallback("Map.lua:282:callback", function() GameTooltip:Hide() end))
    return pin
end)

local releaseNativePins; releaseNativePins = A.traceCallback("Map.lua:286:releaseNativePins", function(map)
    for id, pin in pairs(nativePins) do
        if pin:GetMap() == map then map:RemovePin(pin) end
        nativePins[id] = nil
    end
end)

local nativePin; nativePin = A.traceCallback("Map.lua:293:nativePin", function(map, id)
    local pin = nativePins[id]
    if pin and pin:GetMap() == map then return pin end
    pin = map:AcquirePin(nativeTemplate)
    pin.tartaroTexture = nil
    pin.tartaroR, pin.tartaroG, pin.tartaroB = nil, nil, nil
    nativePins[id] = pin
    return pin
end)

local prepareNativeTemplate; prepareNativeTemplate = A.traceCallback("Map.lua:303:prepareNativeTemplate", function()
    if not MapCanvasPinMixin then return false end
    if not TartaroWorldMapPinMixin.SetOwningMap then
        Mixin(TartaroWorldMapPinMixin, MapCanvasPinMixin)
        TartaroWorldMapPinMixin.OnLoad = A.traceCallback("Map.lua:307:TartaroWorldMapPinMixin:OnLoad", function(self)
            self:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI", 12)
            self:SetScalingLimits(1, 1, 1)
        end)
        TartaroWorldMapPinMixin.OnMouseEnter = A.traceCallback("Map.lua:311:TartaroWorldMapPinMixin:OnMouseEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.character, 1, 0.8, 0.55)
            GameTooltip:Show()
        end)
        TartaroWorldMapPinMixin.OnMouseLeave = A.traceCallback("Map.lua:316:TartaroWorldMapPinMixin:OnMouseLeave", function(self)
            GameTooltip:Hide()
        end)
    end
    return true
end)

A.drawPositions = A.traceCallback("Map.lua:323:A.drawPositions", function()
    mapUpdatePending = nil
    local api = OpenMapAPI
    if api and api.major == 1 and api.RegisterCallback and hookedOpenMap ~= api then
        hookedOpenMap = api
        api.RegisterCallback(A, "OpenMap_ViewChanged", mapViewChanged)
        api.RegisterCallback(A, "OpenMap_StitchedChanged", mapViewChanged)
    end
    local map = WorldMapFrame
    if not map or not map.GetCanvas then return end
    if hookedMap ~= map then
        hookedMap = map
        map:HookScript("OnShow", A.drawPositions)
        map:HookScript("OnHide", releaseNativePins)
        if map.OnMapChanged then hooksecurefunc(map, "OnMapChanged", mapViewChanged) end
        if map.OnCanvasScaleChanged then hooksecurefunc(map, "OnCanvasScaleChanged", mapViewChanged) end
    end
    if not map:IsShown() then return end
    local canvas, mapID = map:GetCanvas(), map:GetMapID()
    if not canvas or not mapID then return end
    local stitched = api and api.major == 1 and api.IsStitched and api.IsStitched() and api
    local useNative = not stitched and map.AcquirePin and map.RemovePin and prepareNativeTemplate()
    if not useNative then releaseNativePins(map) end
    local level = canvas:GetFrameLevel() + 200
    local artTop = stitched and stitched.ArtTopLevel and stitched.ArtTopLevel()
    if artTop then level = math.max(level, artTop + 10) end
    local scale = map:GetEffectiveScale() / canvas:GetEffectiveScale()
    local grouped, used, placed, count = groupedMembers(), 0, {}, 0
    local draw; draw = A.traceCallback("Map.lua:351:draw", function(id, position, isCall)
        local x, y = mapCoordinates(position, mapID, stitched)
        local valid = stitched and number or coordinate
        if valid(x) and valid(y) then
            local pin
            if useNative then
                pin = nativePin(map, id)
                pin:SetPosition(x, y)
                placed[id] = true
            else
                used = used + 1
                pin = pins[used] or newPin(canvas)
                pins[used] = pin
                if pin:GetScale() ~= scale then pin:SetScale(scale) end
                placePin(pin,canvas,"TOPLEFT",x * canvas:GetWidth() / scale,-y * canvas:GetHeight() / scale)
                if pin:GetFrameLevel() ~= level then pin:SetFrameLevel(level) end
            end
            local texture = isCall and "Interface\\AddOns\\Tartaro\\CallSwords" or dotTexture
            local size = isCall and 18 or 11
            if pin.tartaroTexture ~= texture then
                pin.dot:SetTexture(texture)
                pin.tartaroTexture = texture
            end
            colorPin(pin,A.members[id],isCall)
            if pin:GetWidth() ~= size or pin:GetHeight() ~= size then pin:SetSize(size,size) end
            pin.character = isCall and ("Llamado a las armas · " .. position.name) or (position.name .. " · Hermandad")
            pin:Show()
            count = count + 1
        end
    end)
    for id, position in pairs(A.positions) do
        if position.expires <= GetTime() or not A.members[id] then
            A.positions[id] = nil
        elseif not grouped[id] then
            draw(id, position, false)
        end
    end
    for id, call in pairs(A.calls) do
        if call.expires <= GetServerTime() or not A.can(A.members[id], "call") then
            A.calls[id] = nil
        else
            draw("call:" .. id, call, true)
        end
    end
    for index = used + 1, #pins do pins[index]:Hide() end
    for id, pin in pairs(nativePins) do
        if not placed[id] then
            if pin:GetMap() == map then map:RemovePin(pin) end
            nativePins[id] = nil
        end
    end
    local info = C_Map.GetMapInfo(mapID)
    local name = info and info.name
    A.worldMapStatus = ("%s · %d marcadores"):format(readable(name) and name or tostring(mapID), count)
end)

A.drawMinimapPositions = A.traceCallback("Map.lua:407:A.drawMinimapPositions", function()
    local minimap = Minimap
    local used = 0
    if next(A.positions) and minimap and minimap:IsVisible() and C_Minimap and C_Minimap.GetViewRadius then
        local mapID, playerX, playerY = ownPosition()
        local radius = C_Minimap.GetViewRadius()
        local mapWidth, mapHeight
        if mapID then mapWidth, mapHeight = C_Map.GetMapWorldSize(mapID) end
        if number(radius) and radius > 0 and number(mapWidth) and mapWidth > 0
            and number(mapHeight) and mapHeight > 0 then
            local facing = 0
            local getCVarBool = (C_CVar and C_CVar.GetCVarBool) or GetCVarBool
            local rotates = getCVarBool and getCVarBool("rotateMinimap")
            if readable(rotates) and rotates and not (C_Minimap.IsRotateMinimapIgnored and C_Minimap.IsRotateMinimapIgnored()) then
                facing = GetPlayerFacing()
            end
            if number(facing) then
                local sin, cos = math.sin(facing), math.cos(facing)
                local grouped, now = groupedMembers(), GetTime()
                local width, height = minimap:GetWidth() / 2, minimap:GetHeight() / 2
                for id, position in pairs(A.positions) do
                    local member = A.members[id]
                    if member and member.online ~= false and position.expires > now and not grouped[id] then
                        local x, y = mapCoordinates(position, mapID)
                        if number(x) and number(y) then
                            local east = (x - playerX) * mapWidth / radius
                            local south = (y - playerY) * mapHeight / radius
                            if east * east + south * south <= 0.9 ^ 2 then
                                used = used + 1
                                local pin = minimapPins[used] or newPin(minimap)
                                minimapPins[used] = pin
                                local level = minimap:GetFrameLevel() + 5
                                if pin:GetFrameLevel() ~= level then pin:SetFrameLevel(level) end
                                pin.character = position.name .. " · Hermandad"
                                colorPin(pin, member)
                                placePin(pin,minimap,"CENTER",(east * cos - south * sin) * width,
                                    -(east * sin + south * cos) * height)
                                pin:Show()
                            end
                        end
                    end
                end
            end
        end
    end
    for index = used + 1, #minimapPins do minimapPins[index]:Hide() end
end)
A.updateMap = A.traceCallback("Map.updateMap", function()
    if not WorldMapFrame or not WorldMapFrame:IsShown() then
        local now, serverNow = GetTime(), GetServerTime()
        for id, position in pairs(A.positions) do
            if position.expires <= now or not A.members[id] then A.positions[id] = nil end
        end
        for id, call in pairs(A.calls) do
            if call.expires <= serverNow or not A.can(A.members[id],"call") then A.calls[id] = nil end
        end
    end
    A.drawPositions()
end)
if A.traceLoad then A.traceLoad("module.end", "Map.lua") end
