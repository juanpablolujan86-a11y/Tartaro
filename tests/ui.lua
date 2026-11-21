-- Construct the real UI with strict font-string behavior, then exercise its forms.
local A, objects, deferred, tickers = {}, {}, {}, {}
local noop = function() end
local methods = {}
local function object(kind, name, parent)
    local result = setmetatable({kind = kind, name = name, parent = parent, scripts = {}, shown = true,
        width = 600, height = 400}, {__index = function(self, key)
        if methods[key] then return methods[key] end
        for _, prefix in ipairs({"Set", "Get", "Register", "Unregister", "Enable", "Disable", "Clear",
            "Start", "Stop", "Raise", "Highlight"}) do
            if key:sub(1, #prefix) == prefix then return noop end
        end
    end})
    objects[#objects + 1] = result
    if name then _G[name] = result end
    return result
end
function methods:SetText(value)
    self.value = tostring(value or "")
    if self.kind == "Button" and not self.font then self.font = object("FontString") end
    if self.scripts.OnTextChanged then self.scripts.OnTextChanged(self) end
end
function methods:GetText() return self.value or "" end
function methods:GetFontString() return self.font end
function methods:CreateFontString(name) return object("FontString", name, self) end
function methods:CreateTexture(name) return object("Texture", name, self) end
function methods:GetHighlightTexture() self.highlight = self.highlight or object("Texture"); return self.highlight end
function methods:SetSize(w, h) self.width, self.height = w, h end
function methods:SetWidth(w) self.width = w end
function methods:SetHeight(h) self.height = h end
function methods:GetSize() return self.width, self.height end
function methods:GetWidth() return self.width end
function methods:GetHeight() return self.height end
function methods:GetStringHeight() return 15 end
function methods:GetFrameLevel() return 1 end
function methods:GetScale() return 1 end
function methods:GetEffectiveScale() return 1 end
function methods:GetParent() return self.parent end
function methods:GetPoint() return "CENTER", UIParent, "CENTER", 0, 0 end
function methods:GetCenter() return 500, 400 end
function methods:GetRect() return 0, 0, 1600, 1000 end
function methods:GetName() return self.name end
function methods:GetChecked() return self.checked end
function methods:SetChecked(v) self.checked = v end
function methods:SetMaxLetters(v) self.maxLetters = v end
function methods:SetScript(event, fn) self.scripts[event] = fn end
function methods:HookScript(event, fn)
    local previous = self.scripts[event]
    self.scripts[event] = function(...) if previous then previous(...) end; fn(...) end
end
function methods:Show()
    local old = self.shown; self.shown = true
    if not old and self.scripts.OnShow then self.scripts.OnShow(self) end
end
function methods:Hide()
    local old = self.shown; self.shown = false
    if old and self.scripts.OnHide then self.scripts.OnHide(self) end
end
function methods:IsShown() return self.shown end
function methods:SetShown(v) if v then self:Show() else self:Hide() end end
function methods:NumLines() return self.lines or 0 end
function methods:AddLine(value)
    self.lines = (self.lines or 0) + 1
    _G[self.name .. "TextLeft" .. self.lines] = object("FontString")
    _G[self.name .. "TextLeft" .. self.lines]:SetText(value)
end
function methods:GetItem() return "Material", "|Hitem:1:0|h[Cloth]|h" end
CreateFrame = function(kind, name, parent) return object(kind, name, parent) end
UIParent = object("Frame", "UIParent"); UIParent:SetSize(1600, 1000)
Minimap = object("Frame", "Minimap")
GameTooltip = object("Frame", "GameTooltip"); GameTooltip.lines = 0
TooltipDataProcessor = {AddTooltipPostCall = function(_, fn) _G.tooltipPostCall = fn end}
Enum = {TooltipDataType = {Item = 1}}
UISpecialFrames, SlashCmdList, StaticPopupDialogs = {}, {}, {}
tinsert, date = table.insert, os.date
CreateColor = function(...) return {...} end
GetServerTime = function() return 1800000000 end
GetTime = function() return 20 end
InCombatLockdown = function() return false end
C_Timer = {After = function(_, fn) deferred[#deferred + 1] = fn end,
    NewTicker = function(_, fn) tickers[#tickers + 1] = fn end}
C_AddOns = {GetAddOnMetadata = function() return "0.1.54" end}
TartaroDB = {guilds = {}, recipeMaterials = {[7] = {[1] = 2}}}
C_Item = {GetItemInfo = function(id)
    return "Cloth", "|Hitem:" .. id .. ":0|h[Cloth]|h", 1, 1, 1, "Trade", "Cloth", 200, "", 1, 0, 7, 0, 0, 0, nil, true
end}
local function load(name) assert(loadfile("Tartaro/" .. name .. ".lua"))("Tartaro", A) end
for _, name in ipairs({"Core", "Professions", "RecipeCatalog", "Activities", "GroupFinder", "GroupAttendance",
    "Orders", "Donations", "Audio", "Version", "UI"}) do load(name) end
assert(StaticPopupDialogs.TARTARO_CONFIRM_CALL.whileDead, "La confirmación del llamado debe abrirse estando muerto")
do
    local actor = {can = function() return true end, calls = {}, closedCalls = {}, self = "alice",
        send = function() return true end, receiveCall = function() end}
    assert(loadfile("Tartaro/Map.lua"))("Tartaro", actor)
    actor.me = {id = actor.self, name = "Alice"}
    actor.invalidateMap = function() end
    local oldGhost, oldInstance, oldMap = UnitIsGhost, IsInInstance, C_Map
    UnitIsGhost = function() return false end
    IsInInstance = function() return false end
    C_Map = {GetBestMapForUnit = function() return 42 end,
        GetPlayerMapPosition = function() return {GetXY = function() return 0.2, 0.4 end} end}
    local position = assert(actor.prepareCall())
    assert(actor.sendCall(position))
    UnitIsGhost = function() return true end
    assert(not actor.prepareCall())
    assert(not actor.sendCall(position))
    UnitIsGhost, IsInInstance, C_Map = oldGhost, oldInstance, oldMap
end
A.invalidateMap = noop
A.realm, A.self, A.guild, A.guildStatus = "realm", "alice", "Tartaro-realm", "allowed"
A.me = {id = "alice", name = "Alice", rank = 0, rankName = "Leader", online = true}
A.members = {alice = A.me, bob = {id = "bob", name = "Bob", online = false}}
A.db = {grants = {}, notices = {}, events = {}, signups = {}, orders = {}, offers = {},
    professions = {}, addonSeen = {}, eventReminders = {}}
A.resetActivities(); A.resetOrders(); A.resetDonations()
local packets = {}
A.send = function(...) packets[#packets + 1] = {...}; return true end
A.sendProfessionPart = A.send
local function find(kind, value)
    for _, frame in ipairs(objects) do
        if frame.kind == kind and frame.value == value then return frame end
    end
    error("UI object not found: " .. value)
end
local function click(label)
    local control = find("Button", label)
    assert(control.scripts.OnClick, label)
    control.scripts.OnClick(control)
end
local function inputs(form)
    local result = {}
    for _, frame in ipairs(objects) do
        if frame.kind == "EditBox" and frame.parent == form then result[#result + 1] = frame end
    end
    return result
end
SlashCmdList.TARTARO()
assert(TartaroWindow:IsShown())
click("Profesiones")
click("Listar Solicitud de Donacion")
for _, frame in ipairs(objects) do assert(frame.value ~= "Solicitar un material") end
A.openDonationForm()
assert(not TartaroDonationForm:IsShown())
A.openDonationForm(1)
assert(TartaroDonationForm:IsShown())
local fields = inputs(TartaroDonationForm)
assert(#fields == 1)
fields[1]:SetText("0")
click("Publicar solicitud")
assert(TartaroDonationForm:IsShown() and #A.listDonations() == 0)
fields[1]:SetText("11")
click("Publicar solicitud")
assert(not TartaroDonationForm:IsShown() and #A.listDonations() == 1)
assert(A.listDonations()[1].quantity == 11)
-- Same entry through a recipe ingredient uses the same item and duplicate rule.
A.openDonationForm(1)
click("Publicar solicitud")
assert(TartaroDonationForm:IsShown() and #A.listDonations() == 1)
TartaroDonationForm:Hide()
click("Cerrar solicitud")
assert(#A.listDonations() == 0)
A.openDonationForm(2)
fields[1]:SetText("3")
click("Publicar solicitud")
assert(#A.listDonations() == 1 and A.listDonations()[1].item == 2)
assert(A.closeDonation(A.listDonations()[1].id))
-- Tooltip rebuilds reuse the addon block; offline names remain visible.
assert(A.createDonation(1, 4))
A.receiveDonation(A.members.bob, "bob:" .. GetServerTime() * 100, 1, 7, "0")
local before = #packets
tooltipPostCall(GameTooltip, {id = 1})
assert(GameTooltip:NumLines() == 3)
tooltipPostCall(GameTooltip, {id = 1})
assert(GameTooltip:NumLines() == 3 and #packets == before)
local own = A.listDonations()[1]
if own.owner ~= "alice" then own = A.listDonations()[2] end
assert(A.closeDonation(own.id))
tooltipPostCall(GameTooltip, {id = 1})
assert(GameTooltipTextLeft3:GetText() == "")
assert(GameTooltipTextLeft2:GetText() == "Bob")
tooltipPostCall(GameTooltip, {id = 999})
assert(GameTooltipTextLeft1:GetText() == "")
-- Do not erase a line another addon replaced after our hook.
GameTooltipTextLeft1:SetText("Other addon")
tooltipPostCall(GameTooltip, {id = 1})
assert(GameTooltipTextLeft1:GetText() == "Other addon")
GameTooltip.scripts.OnTooltipCleared(GameTooltip)
GameTooltip.lines = 0
tooltipPostCall(GameTooltip, {id = 1})
assert(GameTooltip:NumLines() == 2 and GameTooltipTextLeft2:GetText() == "Bob")
-- A real group form emits an intact quest hyperlink, within the chat budget.
local choices = {}
MenuUtil = {CreateContextMenu = function(_, build)
    choices = {}
    build(nil, {CreateTitle = noop, SetScrollMode = noop,
        CreateRadio = function(_, label, selected, action) choices[label] = action end})
end}
C_QuestLog = {GetNumQuestLogEntries = function() return 1 end,
    GetInfo = function() return {questID = 42, title = "Quest test"} end}
local questLink = "|cffffff00|Hquest:42:60|h[" .. string.rep("Q", 140) .. "]|h|r"
GetQuestLink = function(id) assert(id == 42); return questLink end
local announcement
C_ChatInfo = {SendChatMessage = function(message, channel)
    assert(channel == "GUILD" and #message <= 250)
    announcement = message
end}
A.openGroupForm()
click("Mazmorra")
assert(choices["Quest (Misiones)"])
choices["Quest (Misiones)"]()
click("Seleccionar destino")
choices["Quest test"]()
local groupFields = inputs(TartaroActivityForm)
groupFields[2]:SetText("Here")
for _, frame in ipairs(objects) do
    if frame.kind == "EditBox" and frame.maxLetters == 2 and frame.parent.parent == TartaroActivityForm then
        frame:SetText("1")
    end
end
click("Publicar")
assert(announcement and announcement:find(questLink, 1, true))
local original = A.groups[A.self]
local originalWhen = original.when
click("Buscar grupo")
announcement = nil
click("Volver a publicar")
assert(announcement and announcement:find(questLink, 1, true))
assert(A.groups[A.self] == original and original.when == originalWhen)
local draft
C_ChatInfo.InChatMessagingLockdown = function() return true end
ChatFrame_OpenChat = function(value) draft = value end
assert(A.repostGroup(original))
assert(draft and draft:find(questLink, 1, true))
C_ChatInfo.InChatMessagingLockdown = nil
GetServerTime = function() return originalWhen + 1800 end
assert(not A.repostGroup(original))
GetServerTime = function() return originalWhen end
A.resetActivities()
local bg = assert(A.publishGroup("BG test", "Here", "1 Tanque, 1 Sanador", {maximum = 15, roles = {1, 1, 0}}))
A.requestGroupRole(bg, "T")
assert(A.repostGroup(bg))
assert(announcement:find("1 Sanador", 1, true) and not announcement:find("Tanque", 1, true))
local _, total = A.groupAttendance(bg)
assert(total == 1 and A.groups[A.self] == bg and bg.when == originalWhen)
A.receiveGroupAttendance("GJ", A.members.bob, A.self, tostring(bg.when), "H")
assert(not A.repostGroup(bg))
A.requestGroupRole(bg, "-")
A.me.rank = 2
A.db.grants[2] = {name = A.me.rankName, group = false}
assert(not A.repostGroup(bg))
A.me.rank = 0
A.closeGroup(bg)
assert(not A.repostGroup(bg))
-- Issue #6: run the real offer button and deferred repaint with an enchantment (itemID 0).
do
    A.db.professions[A.self] = {list = {[333] = {recipes = {[7420] = 0, [1001] = 55}}}}
    A.members.bob.online = true
    local stamp = tostring(GetServerTime() * 100)
    local id = "bob:" .. stamp
    A.receiveOrder("OR", A.members.bob, id, "0", "7420", "0", "1", "0", "Enchant chest")
    local order = assert(A.db.orders[id])
    assert(A.canCraftOrder(order), "Known enchantment must be craftable")
    assert(#A.listOrders() == 1, "Open enchantment must be listed")
    TartaroWindow:Show()
    for _, control in ipairs(objects) do
        if control.kind == "Button" and control.value == "Profesiones" and control.parent == TartaroWindow then
            control.scripts.OnClick(control)
            break
        end
    end
    click("Pedidos")
    click("Puedo fabricarlo")
    assert(not order.closed and not order.completed and A.db.offers[id][A.self])
    local callbacks = deferred
    deferred = {}
    for _, callback in ipairs(callbacks) do callback() end
    A.refresh()
    local active = A.listOrders()
    assert(#active == 1 and active[1] == order)
    assert(find("FontString", "1 × Enchant chest"):IsShown())
    assert(find("FontString", "Te ofreciste para fabricar este pedido."):IsShown())
    assert(find("Button", "Susurrar al solicitante"):IsShown())
    -- Duplicate offers, open replay and a close forged by a crafter cannot hide the card.
    A.receiveOrder("OF", A.me, id)
    A.receiveOrder("OR", A.members.bob, id, "0", "7420", "0", "1", "0", "Enchant chest")
    A.receiveOrder("OR", A.me, id, "1", "7420", "0", "1", "0", "Enchant chest")
    A.refresh()
    assert(not A.db.orders[id].closed and #A.listOrders() == 1)
    -- Roster absence hides a still-open record; restoring the owner restores its card.
    local owner = A.members.bob
    A.members.bob = nil
    assert(#A.listOrders() == 0 and not A.db.orders[id].closed)
    A.members.bob = owner
    A.refresh()
    assert(#A.listOrders() == 1 and find("FontString", "1 × Enchant chest"):IsShown())
    -- An authenticated owner cancellation, unlike an offer, removes it from active orders.
    A.receiveOrder("OR", owner, id, "1", "7420", "0", "1", "0", "Enchant chest")
    A.refresh()
    assert(A.db.orders[id].closed and #A.listOrders() == 0)
    print("Issue #6 UI: itemID 0 offer remains visible after repaint and replay; owner closure and roster filtering verified.")
end
-- Losing eligibility closes active forms and cancels combat-resume flags.
A.openDonationForm(1)
TartaroDonationForm.resumeAfterCombat = true
A.db, A.guild, A.me, A.guildStatus = nil, nil, nil, "denied"
A.resetGuildWindows()
assert(not TartaroDonationForm:IsShown() and not TartaroDonationForm.resumeAfterCombat)
SlashCmdList.TARTARO()
assert(TartaroWindow:IsShown())
find("FontString", "Usted no está en la Guild Tartaro")
A.updateCombatWindows()
assert(not TartaroDonationForm:IsShown())
print("Real UI initialization, donation forms, tooltip deduplication and guild exit passed.")
