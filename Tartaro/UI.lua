local _, A = ...
if A.traceLoad then A.traceLoad("module.begin", "UI.lua") end
local crest = "Interface\\AddOns\\Tartaro\\Crest"
local skull = "Interface\\AddOns\\Tartaro\\HeaderSkull"
local icon = "Interface\\AddOns\\Tartaro\\MinimapIcon"
local backdrop = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 2,
}

local surface; surface = A.traceCallback("UI.lua:12:surface", function(name, width, height, y)
    local frame = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    frame:SetSize(width, height)
    frame:SetPoint("CENTER", 0, y)
    frame:SetFrameStrata("DIALOG")
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(0.095, 0.075, 0.078, 1)
    frame:SetBackdropBorderColor(0.54, 0.31, 0.19, 1)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", A.traceCallback("UI.drag.start", frame.StartMoving))
    frame:SetScript("OnDragStop", A.traceCallback("UI.drag.stop", frame.StopMovingOrSizing))
    frame:HookScript("OnShow", A.traceCallback("UI.window.show", function() A.debugLog("window.show","UI.surface",name) end))
    frame:HookScript("OnHide", A.traceCallback("UI.window.hide", function() A.debugLog("window.hide","UI.surface",name) end))
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -3, -3)
    frame.closeButton = close
    frame:Hide()
    return frame
end)

local text; text = A.traceCallback("UI.lua:35:text", function(parent, value, font)
    local label = parent:CreateFontString(nil, "ARTWORK", font or "GameFontHighlight")
    label:SetJustifyH("LEFT")
    label:SetText(value)
    return label
end)

local badge; badge = A.traceCallback("UI.lua:42:badge", function(parent, size)
    local image = parent:CreateTexture(nil, "ARTWORK")
    image:SetTexture(crest)
    image:SetSize(size, size)
    image:SetPoint("TOPLEFT", 15, -12)
    return image
end)

local copperButton; copperButton = A.traceCallback("UI.lua:50:copperButton", function(parent)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetBackdrop(backdrop)
    local label = button:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    label:SetPoint("CENTER")
    label:SetJustifyH("CENTER")
    button:SetFontString(label)
    button:SetNormalFontObject(GameFontHighlight)
    button:SetDisabledFontObject(GameFontDisable)
    button:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD")
    button:GetHighlightTexture():SetVertexColor(0.34, 0.18, 0.09, 0.28)
    button.SetStyle = A.traceCallback("UI.lua:61:button:SetStyle", function(self, selected, primary)
        if primary then
            self:SetBackdropColor(0.99, 0.72, 0.47, 1)
            self:SetBackdropBorderColor(1, 0.61, 0.34, 1)
            self:GetFontString():SetTextColor(0.16, 0.08, 0.04)
        elseif selected then
            self:SetBackdropColor(0.28, 0.16, 0.12, 1)
            self:SetBackdropBorderColor(0.67, 0.42, 0.28, 1)
            self:GetFontString():SetTextColor(1, 0.76, 0.52)
        else
            self:SetBackdropColor(0.18, 0.13, 0.12, 1)
            self:SetBackdropBorderColor(0.40, 0.26, 0.20, 1)
            self:GetFontString():SetTextColor(0.96, 0.90, 0.82)
        end
    end)
    return button
end)

local sidebarWidth = 152
local win = surface("TartaroWindow", 620 + sidebarWidth, 497, -20)
win.LocalTimeOffset = A.traceCallback("UI.localTimeOffset", function(_, when)
    local localTime, utcTime = date("*t",when), date("!*t",when)
    return (localTime.hour*60+localTime.min-utcTime.hour*60-utcTime.min)%1440
end)
local inCombat
local combatWindowsBlocked; combatWindowsBlocked = A.traceCallback("UI.lua:86:combatWindowsBlocked", function()
    return TartaroDB and TartaroDB.hideWindowsInCombat ~= false
        and (inCombat or InCombatLockdown and InCombatLockdown())
end)
tinsert(UISpecialFrames, "TartaroWindow")
win:SetClampRectInsets(0, 0, 79, 0)
local headerHeight = 132
local header = win:CreateTexture(nil, "BACKGROUND", nil, 1)
header:SetPoint("TOPLEFT", 2, -2)
header:SetPoint("TOPRIGHT", -2, -2)
header:SetHeight(headerHeight)
header:SetColorTexture(1, 1, 1, 1)
header:SetGradient("VERTICAL", CreateColor(0.10, 0.08, 0.09, 1), CreateColor(0.25, 0.14, 0.12, 1))
local skullArt = win:CreateTexture(nil, "ARTWORK")
skullArt:SetTexture(skull)
skullArt:SetSize(142, 145)
skullArt:SetPoint("TOP", win, "TOP", 0, 79)
win.CaptureResizeOrigin = A.traceCallback("UI.window.captureResizeOrigin", function(self, keep, moved)
    if not TartaroDB or TartaroDB.centerWindowOnResize ~= true or self.resizeDragging
        or (keep or self.stackPoint and not moved) and self.resizeOrigin then return end
    local x, y = skullArt:GetCenter()
    local scale = self:GetEffectiveScale() / UIParent:GetEffectiveScale()
    if not x or not y or scale <= 0 then return end
    local point = self.resizeOrigin and self.resizeOrigin.point or self.stackPoint and self.stackPoint[1] or self:GetPoint(1)
    self.resizeOrigin = {x=x*scale, y=y*scale, point=point,
        offset=select(5, skullArt:GetPoint(1))-skullArt:GetHeight()/2}
end)
win.ApplyResizeOrigin = A.traceCallback("UI.window.applyResizeOrigin", function(self)
    if not TartaroDB or TartaroDB.centerWindowOnResize ~= true or self.resizeDragging then return end
    local origin = self.resizeOrigin
    local scale = self:GetEffectiveScale() / UIParent:GetEffectiveScale()
    if not origin or scale <= 0 then return end
    self:SetUserPlaced(false)
    self:ClearAllPoints()
    self:SetPoint("TOP", UIParent, "BOTTOMLEFT", origin.x/scale, origin.y/scale-origin.offset)
end)
win.SavePosition = A.traceCallback("UI.window.savePosition", function(self, stable)
    if not TartaroDB or not self.positionReady or self.resizeDragging then return end
    local width, height = UIParent:GetSize()
    if width <= 0 or height <= 0 then return end
    local origin = TartaroDB.centerWindowOnResize == true and self.resizeOrigin
    if self.stackPoint and not stable then
        local saved = TartaroDB.windowPosition
        if origin and saved then
            saved.crestX, saved.crestY = origin.x/width, origin.y/height
        end
        return
    end
    local point = origin and origin.point or self:GetPoint(1)
    if not point then return end
    local x, y = self:GetCenter()
    if point:find("LEFT",1,true) then x=self:GetLeft()
    elseif point:find("RIGHT",1,true) then x=self:GetRight() end
    if point:find("TOP",1,true) then y=self:GetTop()
    elseif point:find("BOTTOM",1,true) then y=self:GetBottom() end
    local crestX, crestY = skullArt:GetCenter()
    if not x or not y or not crestX or not crestY then return end
    local scale = self:GetEffectiveScale()/UIParent:GetEffectiveScale()
    TartaroDB.windowPosition = {point=point, x=x*scale/width, y=y*scale/height,
        crestX=(origin and origin.x or crestX*scale)/width,
        crestY=(origin and origin.y or crestY*scale)/height}
    self:SetUserPlaced(false)
end)
win.RestorePosition = A.traceCallback("UI.window.restorePosition", function(self)
    if self.positionReady or not TartaroDB then return end
    self.positionReady = true
    local saved = TartaroDB.windowPosition
    local anchors = {TOPLEFT=true, TOP=true, TOPRIGHT=true, LEFT=true, CENTER=true,
        RIGHT=true, BOTTOMLEFT=true, BOTTOM=true, BOTTOMRIGHT=true}
    if type(saved) ~= "table" or not anchors[saved.point] then return end
    for _, key in ipairs({"x","y","crestX","crestY"}) do
        local value = saved[key]
        if type(value) ~= "number" or value ~= value or math.abs(value) == math.huge then return end
    end
    local width, height = UIParent:GetSize()
    local scale = self:GetEffectiveScale()/UIParent:GetEffectiveScale()
    if width <= 0 or height <= 0 or scale <= 0 then self.positionReady=nil; return end
    self:SetUserPlaced(false)
    self:ClearAllPoints()
    self:SetPoint(saved.point,UIParent,"BOTTOMLEFT",saved.x*width/scale,saved.y*height/scale)
    if TartaroDB.centerWindowOnResize == true then
        self.resizeOrigin = {point=saved.point, x=saved.crestX*width, y=saved.crestY*height,
            offset=select(5,skullArt:GetPoint(1))-skullArt:GetHeight()/2}
        self:ApplyResizeOrigin()
    end
end)
win:RegisterEvent("PLAYER_LOGIN")
win:RegisterEvent("PLAYER_LOGOUT")
win:SetScript("OnEvent", A.traceCallback("UI.window.positionEvent", function(self, event)
    if event == "PLAYER_LOGIN" then self:RestorePosition(); self:UnregisterEvent(event)
    else self:SavePosition() end
end))
win:HookScript("OnHide", A.traceCallback("UI.window.positionHide", function(self)
    self:SavePosition()
    self.mapCalls = nil
end))
do
    local banner = win:CreateTexture(nil, "BACKGROUND", nil, 2)
    banner:SetPoint("TOPLEFT", 2, -2)
    banner:SetPoint("TOPRIGHT", -2, -2)
    banner:SetHeight(headerHeight - 4)
    banner:SetColorTexture(0.24, 0.015, 0.02, 1)

    local cloth = win:CreateTexture(nil, "BACKGROUND", nil, 3)
    cloth:SetAllPoints(banner)
    cloth:SetColorTexture(1, 1, 1, 1)
    cloth:SetGradient("HORIZONTAL", CreateColor(0.32, 0.02, 0.025, 1), CreateColor(0.12, 0.008, 0.01, 1))
    local emblem = win:CreateTexture(nil, "BACKGROUND", nil, 4)
    emblem:SetSize(headerHeight - 4, headerHeight - 4)
    emblem:SetPoint("LEFT", banner, "LEFT")
    emblem:SetTexture("Interface\\Timer\\Horde-Logo")
    emblem:SetAlpha(0.45)

    if C_Texture and type(C_Texture.GetAtlasInfo) == "function" then
        local ok, info = A.debugPcall("UI.header.clothAtlas", C_Texture.GetAtlasInfo, "AllianceScenario-TitleBG")
        local file = ok and type(info) == "table" and (info.file or info.filename)
        if file then
            cloth:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 1), CreateColor(1, 1, 1, 1))
            cloth:SetTexture(file)
            cloth:ClearAllPoints()
            cloth:SetPoint("TOPLEFT", emblem, "TOPRIGHT")
            cloth:SetPoint("BOTTOMRIGHT", banner, "BOTTOMRIGHT")
            cloth:SetTexCoord(395 / 512, 250 / 512, 291 / 512, 360 / 512)
            cloth:SetVertexColor(0.70, 0.70, 0.70, 1)
            emblem:SetTexture(file)
            emblem:SetSize((headerHeight - 4) * 90 / 69, headerHeight - 4)
            emblem:SetTexCoord(485 / 512, 395 / 512, 291 / 512, 360 / 512)
            emblem:SetVertexColor(0.70, 0.70, 0.70, 1)
            emblem:SetAlpha(1)
        end

        local valid, trim = A.debugPcall("UI.header.hordeFrameAtlas", C_Texture.GetAtlasInfo,
            "perks-theme-hordevsalliance-tp-topbig")
        if valid and type(trim) == "table" and (trim.file or trim.filename)
            and type(trim.width) == "number" and trim.width > 0
            and type(trim.height) == "number" and trim.height > 0
            and type(trim.leftTexCoord) == "number" and type(trim.rightTexCoord) == "number"
            and type(trim.topTexCoord) == "number" and type(trim.bottomTexCoord) == "number" then
            local unit = trim.width / 527 * 0.668
            local height = trim.height * 0.668
            local rise = height * 50 / 108
            local span = trim.rightTexCoord - trim.leftTexCoord
            for side = -1, 1, 2 do
                local parts = {}
                for index, columns in ipairs({{527, 350}, {344, 264}, {348, 346}}) do
                    local first, last = columns[1], columns[2]
                    if side == 1 then first, last = last, first end
                    local part = win:CreateTexture(nil, "ARTWORK", nil, -1)
                    part:SetTexture(trim.file or trim.filename)
                    part:SetTexCoord(trim.leftTexCoord + span * first / 527,
                        trim.leftTexCoord + span * last / 527, trim.topTexCoord, trim.bottomTexCoord)
                    if index < 3 then
                        part:SetSize(math.abs(last - first) * unit, height)
                        if index == 1 then
                            part:SetPoint(side == -1 and "TOPLEFT" or "TOPRIGHT", win,
                                side == -1 and "TOPLEFT" or "TOPRIGHT", side * 6, rise)
                        else
                            part:SetPoint(side == -1 and "TOPRIGHT" or "TOPLEFT", win, "TOP", 0, rise)
                        end
                    elseif side == -1 then
                        part:SetPoint("TOPLEFT", parts[1], "TOPRIGHT")
                        part:SetPoint("BOTTOMRIGHT", parts[2], "BOTTOMLEFT")
                    else
                        part:SetPoint("TOPLEFT", parts[2], "TOPRIGHT")
                        part:SetPoint("BOTTOMRIGHT", parts[1], "BOTTOMLEFT")
                    end
                    parts[index] = part
                end
            end
        end
    end

    local title = win:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("TOPLEFT", banner, "TOPLEFT", 94, -75)
    title:SetPoint("TOPRIGHT", banner, "TOPRIGHT", -94, -75)
    title:SetJustifyH("CENTER")
    title:SetText("Tartaro")
    title:SetTextColor(1, 0.82, 0.28)
    title:SetShadowColor(0, 0, 0, 1)
    title:SetShadowOffset(1, -1)
    local motto = win:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    motto:SetPoint("BOTTOMLEFT", banner, "BOTTOMLEFT", 94, 10)
    motto:SetPoint("BOTTOMRIGHT", banner, "BOTTOMRIGHT", -94, 10)
    motto:SetJustifyH("CENTER")
    motto:SetText("For The Horde!")
    motto:SetTextColor(1, 0.87, 0.65)
    motto:SetShadowColor(0, 0, 0, 1)
    motto:SetShadowOffset(1, -1)
end
local divider = win:CreateTexture(nil, "ARTWORK")
divider:SetPoint("TOPLEFT", 2, -headerHeight)
divider:SetPoint("TOPRIGHT", -2, -headerHeight)
divider:SetHeight(1)
divider:SetColorTexture(0.40, 0.26, 0.20, 1)
local sidebarDivider = win:CreateTexture(nil, "ARTWORK")
sidebarDivider:SetPoint("TOPLEFT", sidebarWidth + 2, -headerHeight)
sidebarDivider:SetPoint("BOTTOMLEFT", sidebarWidth + 2, 2)
sidebarDivider:SetWidth(1)
sidebarDivider:SetColorTexture(0.33, 0.22, 0.17, 1)
local scroll = CreateFrame("ScrollFrame", nil, win, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", 18 + sidebarWidth, -(headerHeight + 18))
scroll:SetPoint("BOTTOMRIGHT", -32, 17)
local content = CreateFrame("Frame", nil, scroll)
content:SetSize(570, 1)
scroll:SetScrollChild(content)
content.sectionHeader = CreateFrame("Frame", "TartaroTableHeader", win)
content.sectionHeader:SetPoint("TOPLEFT", 18 + sidebarWidth, -(headerHeight + 18))
content.sectionHeader:SetSize(570, 1)
content.sectionHeader:Hide()

local page, selectedEvent = "home", nil
local professionView = "recipes"
local components = A.UIComponents.create({content=content,scroll=scroll,header=content.sectionHeader,
    text=text,button=copperButton,onHeaderHeight=A.traceCallback("UI.lua:299:callback", function(height)
        scroll:SetPoint("TOPLEFT",page == "calendar" and sidebarWidth+698 or sidebarWidth+18,-(headerHeight+18+height))
    end)})
local layout = components.layout
local row,line,tableRow,button,check = components.Row,components.Line,components.TableRow,components.Button,components.Check
local recordCard = components.Card
local calendarPanel = A.Calendar.create(win, copperButton, text)
calendarPanel:SetPoint("TOPLEFT", 18 + sidebarWidth, -(headerHeight + 18))
calendarPanel:SetPoint("BOTTOMLEFT", 18 + sidebarWidth, 17)
local eventDivider = win:CreateTexture(nil, "BACKGROUND")
eventDivider:SetPoint("TOPLEFT", 682 + sidebarWidth, -(headerHeight + 18))
eventDivider:SetPoint("BOTTOMLEFT", 682 + sidebarWidth, 17)
eventDivider:SetWidth(1)
eventDivider:SetColorTexture(0.33, 0.22, 0.17, 1)
local homeDivider = content:CreateTexture(nil, "BACKGROUND")
homeDivider:SetPoint("TOPLEFT", 319, 0)
homeDivider:SetWidth(1)
homeDivider:SetColorTexture(0.33, 0.22, 0.17, 1)
local homeRule = content:CreateTexture(nil, "BACKGROUND")
homeRule:SetSize(563, 1)
homeRule:SetColorTexture(0.40, 0.26, 0.20, 1)
local homeOrdersDivider = content:CreateTexture(nil, "BACKGROUND")
homeOrdersDivider:SetWidth(1)
homeOrdersDivider:SetColorTexture(0.33, 0.22, 0.17, 1)
local editor = surface("TartaroEditor", 450, 445, 20)
tinsert(UISpecialFrames, "TartaroEditor")
local editorTitle = text(editor, "", "GameFontNormalLarge")
editorTitle:SetPoint("TOPLEFT", 18, -18)
local field; field = A.traceCallback("UI.lua:327:field", function(label, yOffset, maxChars)
    local caption = text(editor, label)
    caption:SetPoint("TOPLEFT", 18, yOffset)
    local field = CreateFrame("EditBox", nil, editor, "InputBoxTemplate")
    field:SetPoint("TOPLEFT", 24, yOffset - 22)
    field:SetSize(402, 25)
    field:SetAutoFocus(false)
    field:SetMaxLetters(maxChars)
    field:SetScript("OnEscapePressed", A.traceCallback("UI.lua:335:callback", function(self) self:ClearFocus() end))
    return caption, field
end)

local titleLabel, titleField = field("Título", -54, 65)
local dateLabel, dateField = field("Fecha · DD/MM/AAAA", -108, 10)
local timeLabel, timeField = field("Hora local · HH:MM", -108, 5)
dateField:SetWidth(177)
timeLabel:ClearAllPoints()
timeLabel:SetPoint("TOPLEFT", 220, -108)
timeField:ClearAllPoints()
timeField:SetPoint("TOPLEFT", 226, -130)
timeField:SetWidth(195)
local detailLabel, detailField = field("Descripción", -302, 195)
local kindPicker = CreateFrame("Frame", nil, editor)
kindPicker:SetPoint("TOPLEFT", 18, -161)
kindPicker:SetSize(414, 76)
local kindLabel = text(kindPicker, "Tipo de evento")
kindLabel:SetPoint("TOPLEFT")
local errorLabel = text(editor, "")
errorLabel:SetPoint("TOPLEFT", 18, -365)
errorLabel:SetWidth(414)
errorLabel:SetTextColor(1, 0.65, 0.45)
local save = copperButton(editor)
save:SetPoint("BOTTOMRIGHT", -18, 15)
save:SetSize(120, 26)
save:SetText("Guardar")
save:SetStyle(false, true)
local delete = copperButton(editor)
delete:SetPoint("BOTTOMLEFT", 18, 15)
delete:SetSize(146, 26)
delete:SetText("Eliminar evento")
delete:SetStyle(false)
local mode, editing, editingGuild, selectedKind
local updateEditorLength
local kinds = {"BG", "RAID", "PVP", "OTHER"}
local kindChecks = {}
editor.capFields = {}
editor.capLabel = text(editor, "Cupos por rol (opcional)", "GameFontNormalSmall")
editor.capLabel:SetPoint("TOPLEFT", 18, -238)
for i, role in ipairs(A.eventRoleOrder) do
    local label, input = field(A.eventRoles[role], -232, 2)
    local offset = (i - 1) * 136
    label:ClearAllPoints()
    label:SetPoint("TOPLEFT", 18 + offset, -254)
    input:ClearAllPoints()
    input:SetPoint("TOPLEFT", 24 + offset, -272)
    input:SetWidth(117)
    input:SetNumeric(true)
    editor.capFields[i] = {label, input}
end

local selectKind; selectKind = A.traceCallback("UI.lua:387:selectKind", function(kind)
    selectedKind = kind
    for value, checkButton in pairs(kindChecks) do checkButton:SetChecked(kind == value) end
    if updateEditorLength then updateEditorLength() end
end)

for index, kind in ipairs(kinds) do
    local value = kind
    local checkButton = CreateFrame("CheckButton", nil, kindPicker, "UICheckButtonTemplate")
    checkButton:SetSize(24, 24)
    checkButton:SetPoint("TOPLEFT", ((index - 1) % 2) * 199, -17 - math.floor((index - 1) / 2) * 25)
    checkButton:SetHitRectInsets(0, -160, 0, 0)
    local label = text(checkButton, A.kinds[value])
    label:SetPoint("LEFT", checkButton, "RIGHT", 3, 0)
    checkButton:SetScript("OnClick", A.traceCallback("UI.lua:401:callback", function() selectKind(value) end))
    kindChecks[value] = checkButton
end

StaticPopupDialogs["TARTARO_DELETE_EVENT"] = {
    text = "¿Eliminar el evento «%s»? También se quitarán sus inscripciones.",
    button1 = "Eliminar",
    button2 = "Cancelar",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnAccept = A.traceCallback("UI.lua:412:callback", function(_, data)
        if A.db ~= data.db then return end
        local current = A.db.events[data.id]
        if not current or current.rev ~= data.rev then
            print("Tártaro: el evento cambió o ya no está disponible. Volvé a confirmar su eliminación.")
            return
        end
        local ok, err = A.deleteEvent(data.id)
        if not ok then print("Tártaro: " .. err); return end
        if selectedEvent == data.id then selectedEvent = nil end
        if editor:IsShown() and editing and editing.id == data.id then editor:Hide() end
        A.refresh()
    end),
}
win.ConfirmDeleteEvent = A.traceCallback("UI.event.confirmDelete", function(_, event)
    if not A.db or A.db.events[event.id] ~= event or not A.canEditEvent(A.me, event) then return end
    StaticPopup_Show("TARTARO_DELETE_EVENT", event.title, nil, {id=event.id, rev=event.rev, db=A.db})
end)

delete:SetScript("OnClick", A.traceCallback("UI.lua:431:callback", function()
    if editing and editingGuild == A.db then
        win:ConfirmDeleteEvent(editing)
    end
end))

local openEditor; openEditor = A.traceCallback("UI.lua:437:openEditor", function(typeOfEdit, event)
    mode, editing, editingGuild = typeOfEdit, event, A.db
    local isEvent = mode == "event"
    editorTitle:SetText(isEvent and (event and "Editar evento" or "Nuevo evento")
        or mode == "daily" and "Mensaje del día" or "Publicar aviso")
    for _, control in ipairs({titleLabel, titleField, dateLabel, dateField, timeLabel, timeField, kindPicker}) do
        control:SetShown(isEvent)
    end
    titleField:SetText(event and event.title or "")
    local when = event and event.when or GetServerTime() + 3600
    dateField:SetText(date("%d/%m/%Y", when))
    timeField:SetText(date("%H:%M", when))
    selectKind(event and event.kind or "BG")
    editor:SetHeight(isEvent and 445 or 382)
    editor.capLabel:SetShown(isEvent)
    errorLabel:SetPoint("TOPLEFT", 18, isEvent and -365 or -297)
    for index, fields in ipairs(editor.capFields) do
        fields[1]:SetShown(isEvent)
        fields[2]:SetShown(isEvent)
        fields[2]:SetText(event and event.caps and tostring(event.caps[index]) or "")
    end
    delete:SetShown(isEvent and event ~= nil)
    detailLabel:SetText(isEvent and "Descripción" or "Texto")
    detailLabel:ClearAllPoints()
    detailLabel:SetPoint("TOPLEFT", 18, isEvent and -302 or -60)
    detailField:ClearAllPoints()
    detailField:SetPoint("TOPLEFT", detailLabel, "BOTTOMLEFT", 6, -4)
    detailField:SetText(event and event.detail or mode == "daily" and A.db.daily and A.db.daily.text or "")
    errorLabel:SetText("")
    save:SetText(isEvent and not event and "Crear y anunciar" or "Guardar")
    save:SetStyle(false, true)
    updateEditorLength()
    win:Hide()
    editor:Show()
    editor:Raise()
end)

editor:SetScript("OnHide", A.traceCallback("UI.lua:474:callback", function()
    titleField:ClearFocus()
    dateField:ClearFocus()
    timeField:ClearFocus()
    detailField:ClearFocus()
    for _, fields in ipairs(editor.capFields) do fields[2]:ClearFocus() end
    if editor.resumeAfterCombat or not A.db or A.db ~= editingGuild then return end
    win:Show()
    A.refresh()
    A.showEventNotification()
end))

local parseDate; parseDate = A.traceCallback("UI.lua:486:parseDate", function(value)
    local day, month, year, hour, minute = value:match("^(%d%d)/(%d%d)/(%d%d%d%d) (%d%d):(%d%d)$")
    if not year then return end
    local ok, when = A.debugPcall("UI.lua:489:pcall", time, {year = tonumber(year), month = tonumber(month), day = tonumber(day), hour = tonumber(hour), min = tonumber(minute), sec = 0})
    if ok and when and when > 0 and date("%d/%m/%Y %H:%M", when) == value then return when end
end)

local readEditorCaps; readEditorCaps = A.traceCallback("UI.lua:493:readEditorCaps", function()
    local values,hasCaps={},false
    for index,fields in ipairs(editor.capFields) do
        local value=fields[2]:GetText()
        hasCaps=hasCaps or value~=""
        values[index]=value=="" and "0" or value
    end
    return hasCaps and A.eventCaps(unpack(values)),hasCaps
end)

local lengthError = "El texto es demasiado largo. Acortalo para poder enviarlo."
updateEditorLength = A.traceCallback("UI.lua:504:callback", function()
    if not mode or A.db ~= editingGuild then return end
    local caps = readEditorCaps()
    local fits = A.editorMessageFits(mode, editing and editing.id,
        parseDate(dateField:GetText() .. " " .. timeField:GetText()), selectedKind,
        titleField:GetText(), detailField:GetText(), caps)
    save:SetEnabled(fits)
    if A.isDebugEnabled() then
        A.debugLog("observation", "editor.length", {mode=mode, fits=fits, enabled=not not save:IsEnabled(),
            titleBytes=#titleField:GetText(), detailBytes=#detailField:GetText()},
            "Guardar habilitado exactamente cuando cabe el mensaje", tostring(save:IsEnabled()), (not not save:IsEnabled()) == fits)
    end
    if not fits then errorLabel:SetText(lengthError)
    elseif errorLabel:GetText() == lengthError then errorLabel:SetText("") end
end)
for _, input in ipairs({titleField, dateField, timeField, detailField}) do
    input:SetScript("OnTextChanged", updateEditorLength)
end
for _, fields in ipairs(editor.capFields) do fields[2]:SetScript("OnTextChanged", updateEditorLength) end

local announceGuild; announceGuild = A.traceCallback("UI.lua:524:announceGuild", function(message, fallback)
    local send = C_ChatInfo and C_ChatInfo.SendChatMessage or SendChatMessage
    local locked = C_ChatInfo and C_ChatInfo.InChatMessagingLockdown and C_ChatInfo.InChatMessagingLockdown()
    local canSpeak = not C_GuildInfo or not C_GuildInfo.CanSpeakInGuildChat or C_GuildInfo.CanSpeakInGuildChat()
    if send and not locked and canSpeak then
        local ok, result = A.debugPcall("UI.lua:529:pcall", send, message, "GUILD")
        if ok and result ~= false then return end
    end
    if ChatFrame_OpenChat then
        ChatFrame_OpenChat("/g " .. message)
        print("Tártaro: " .. fallback .. " Presioná Enter para enviar el anuncio a la hermandad.")
    else
        print("Tártaro: " .. fallback .. " El anuncio quedó sin enviar.")
    end
end)

local shortenChat; shortenChat = A.traceCallback("UI.lua:540:shortenChat", function(value, limit)
    if #value <= limit then return value end
    local cut = limit - 2
    while value:byte(cut) >= 128 and value:byte(cut) < 192 do cut = cut - 1 end
    return value:sub(1, cut - 1) .. "..."
end)

local announceEvent; announceEvent = A.traceCallback("UI.lua:547:announceEvent", function(event)
    local prefix = "[Tártaro] Nuevo evento: "
    local suffix = (" (%s) · %s UTC."):format(A.kinds[event.kind], date("!%d/%m/%Y %H:%M", event.when))
    announceGuild(prefix .. shortenChat(event.title, 250 - #prefix - #suffix) .. suffix, "El evento se guardó.")
end)

local announceGroup; announceGroup = A.traceCallback("UI.lua:553:announceGroup", function(group, remaining)
    local needs = remaining or group.needs
    if group.questLink then
        local prefix, suffix = "[Tártaro] Busco grupo: ", ". Faltan: "
        local budget = 250 - #prefix - #suffix - #group.questLink
        announceGuild(prefix .. group.questLink .. suffix .. shortenChat(needs, budget),
            "La búsqueda se publicó en Tártaro.")
        return
    end
    local format = "[Tártaro] Busco grupo para %s. Roles que faltan: %s."
    local message = format:format(group.activity, needs)
    if #message > 250 then
        message = format:format(shortenChat(group.activity, 100), shortenChat(needs, 100))
    end
    announceGuild(message, "La búsqueda se publicó en Tártaro.")
end)

A.repostGroup = A.traceCallback("UI.lua:570:A.repostGroup", function(group)
    if combatWindowsBlocked() then return nil, "Esperá a salir de combate para volver a publicar." end
    local needs, err = A.groupAnnouncementNeeds(group)
    if not needs then return nil, err end
    announceGroup(group, needs)
    return true
end)

save:SetScript("OnClick", A.traceCallback("UI.lua:578:callback", function()
    local success, err, newEvent
    if not A.db or A.db ~= editingGuild then errorLabel:SetText("Cambió la hermandad activa."); return end
    updateEditorLength()
    if errorLabel:GetText() == lengthError then return end
    if mode == "event" then
        local when = parseDate(dateField:GetText() .. " " .. timeField:GetText())
        if not when then errorLabel:SetText("Ingresá la fecha en DD/MM/AAAA y la hora en HH:MM."); return end
        local caps,hasCaps=readEditorCaps()
        if hasCaps and not caps then errorLabel:SetText("Ingresá entre 1 y 40 cupos en total, o dejalos vacíos."); return end
        success, err = A.saveEvent(editing and editing.id, when, selectedKind, titleField:GetText(), detailField:GetText(), caps)
        if success then
            selectedEvent = success
            if not editing then
                newEvent = success
                announceEvent(A.db.events[success])
            end
        end
    else
        success, err = A.publish(detailField:GetText(), mode == "daily")
    end
    if not success then errorLabel:SetText(err); return end
    editor:Hide()
    if newEvent then A.notifyEvent(newEvent, true) end
end))

local positionNotice; positionNotice = A.traceCallback("UI.lua:604:positionNotice", function(popup, rightOffset, topOffset, allowOverlap)
    local left, bottom, width, height = UIParent:GetRect()
    if not left or not bottom or not width or not height then return false end
    local parentScale = UIParent:GetEffectiveScale()
    local popupScale = popup:GetEffectiveScale() / parentScale
    local popupWidth, popupHeight = popup:GetWidth() * popupScale, popup:GetHeight() * popupScale
    local margin = 12
    local x = math.max(margin, rightOffset and width - popupWidth - rightOffset or (width - popupWidth) / 2)
    local top = math.max(popupHeight + margin, height - topOffset)
    local windowLeft, windowBottom, windowWidth, windowHeight
    if win:IsShown() then windowLeft, windowBottom, windowWidth, windowHeight = win:GetRect() end
    if windowLeft then
        local scale = win:GetEffectiveScale() / parentScale
        local panelLeft = windowLeft * scale - left
        local panelBottom = windowBottom * scale - bottom
        local panelRight = panelLeft + windowWidth * scale
        local panelTop = panelBottom + (windowHeight + 79) * scale
        if x < panelRight + margin and x + popupWidth > panelLeft - margin
            and top > panelBottom - margin and top - popupHeight < panelTop + margin then
            if panelRight + 2 * margin + popupWidth <= width then
                x = panelRight + margin
            elseif panelLeft >= popupWidth + 2 * margin then
                x = panelLeft - margin - popupWidth
            elseif panelTop + 2 * margin + popupHeight <= height then
                top = panelTop + margin + popupHeight
            elseif panelBottom >= popupHeight + 2 * margin then
                top = panelBottom - margin
            elseif not allowOverlap then
                return false
            end
        end
    end
    popup:ClearAllPoints()
    popup:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x / popupScale, (top - height) / popupScale)
    return true
end)

local daily = surface("TartaroDaily", 550, 146, 205)
daily.NotificationsBlocked = A.traceCallback("UI.notificationsBlocked", function()
    local inside, kind = IsInInstance()
    return inCombat or InCombatLockdown and InCombatLockdown()
        or UnitAffectingCombat and UnitAffectingCombat("player")
        or inside and (kind == "party" or kind == "raid" or kind == "pvp" or kind == "arena")
end)
daily:SetBackdropColor(0.095, 0.075, 0.078, 1)
badge(daily, 72)
local dailyTitle = text(daily, "Mensaje del día", "GameFontNormalLarge")
dailyTitle:SetPoint("TOPLEFT", 103, -18)
local dailyBody = text(daily, "")
dailyBody:SetPoint("TOPLEFT", 103, -47)
dailyBody:SetWidth(393)

local dailyMessage; dailyMessage = A.traceCallback("UI.lua:656:dailyMessage", function()
    if A.db.daily then return A.db.daily.text, A.db.daily.rev end
    local motd = (C_GuildInfo and C_GuildInfo.GetMOTD) or GetGuildRosterMOTD
    local value = motd and motd()
    if (issecretvalue and issecretvalue(value)) or type(value) ~= "string" then return "" end
    return A.clean(value), 0
end)

local dailyState = {}
local notificationHistory; notificationHistory = A.traceCallback("UI.notificationHistory", function()
    if not A.db or not A.self then return end
    local day = A.Calendar.dayKey(GetServerTime())
    A.db.notificationHistory = A.db.notificationHistory or {}
    local history = A.db.notificationHistory[A.self]
    if not history or history.day ~= day then
        history = {day=day, events={}}
        A.db.notificationHistory[A.self] = history
    end
    return history
end)
local eventPopup
local noticeAnchor = CreateFrame("Frame", nil, UIParent)
noticeAnchor:SetMovable(true)
noticeAnchor:SetClampedToScreen(true)

local layoutNotices; layoutNotices = A.traceCallback("UI.lua:681:layoutNotices", function()
    local showDaily = daily:IsShown()
    local showEvent = eventPopup and eventPopup:IsShown()
    local showMain = win:IsShown()
    if showMain then win:CaptureResizeOrigin(true) end
    local stackMain = showMain and (showDaily or showEvent)
    local width, height = UIParent:GetWidth(), UIParent:GetHeight()
    local margin, gap, skullHeight = 16, 10, 79
    local total, widest = 0, 0
    if showDaily then total, widest = daily:GetHeight(), daily:GetWidth() end
    if showEvent then
        total = total + (total > 0 and gap or 0) + eventPopup:GetHeight()
        widest = math.max(widest, eventPopup:GetWidth())
    end
    if stackMain then
        total = total + gap + win:GetHeight() + skullHeight
        widest = math.max(widest, win:GetWidth())
        if not win.stackPoint then
            win:SavePosition()
            win.stackPoint = {win:GetPoint(1)}
        end
    elseif win.stackPoint then
        win:ClearAllPoints()
        win:SetPoint(unpack(win.stackPoint))
        win.stackPoint = nil
    end
    if not stackMain then
        win:SetScale(win.normalScale or 1)
        if showMain then win:ApplyResizeOrigin() end
    end
    if total == 0 then return end
    if width <= 2 * margin or height <= 2 * margin then return end
    local scale = math.min(1, (width - 2 * margin) / widest, (height - 2 * margin) / total)
    local stackWidth, stackHeight = widest * scale, total * scale
    noticeAnchor:SetSize(stackWidth, stackHeight)
    if not noticeAnchor.dragging then
        local saved = TartaroDB and TartaroDB.noticePosition
        if type(saved) ~= "table" or type(saved.x) ~= "number" or type(saved.y) ~= "number" then saved = nil end
        local x = saved and saved.x or 0.5
        local y = saved and saved.y or 1
        if stackMain and TartaroDB.centerWindowOnResize == true and win.resizeOrigin then
            local origin = win.resizeOrigin
            x, y = origin.x, origin.y+(total-win:GetHeight()-origin.offset)*scale
            x = math.max(stackWidth / 2, math.min(width - stackWidth / 2, x))
            y = math.max(stackHeight, math.min(height, y))
        else
            x = math.max(stackWidth / 2, math.min(width - stackWidth / 2, width * x))
            y = math.max(stackHeight, math.min(height, height * y))
            if not saved then y = height - margin end
        end
        noticeAnchor:ClearAllPoints()
        noticeAnchor:SetPoint("TOP", UIParent, "BOTTOMLEFT", x, y)
    end
    local offset = 0
    local place; place = A.traceCallback("UI.lua:735:place", function(frame)
        frame:SetScale(scale)
        frame:ClearAllPoints()
        frame:SetPoint("TOP", noticeAnchor, "TOP", 0, -offset)
        offset = offset + frame:GetHeight() + gap
    end)
    if showDaily then place(daily) end
    if showEvent then place(eventPopup) end
    if stackMain then
        offset = offset + skullHeight
        place(win)
    end
end)

local stopNoticeDrag; stopNoticeDrag = A.traceCallback("UI.lua:749:stopNoticeDrag", function(frame)
    local target = frame.dragTarget
    if not target then return end
    frame.dragTarget = nil
    target:StopMovingOrSizing()
    win.resizeDragging = nil
    win:CaptureResizeOrigin(false,true)
    if target ~= noticeAnchor then win:ApplyResizeOrigin(); win:SavePosition(); return end
    noticeAnchor.dragging = nil
    noticeAnchor:SetUserPlaced(false)
    local x = noticeAnchor:GetCenter()
    local top = noticeAnchor:GetTop()
    local left, bottom, width, height = UIParent:GetRect()
    if TartaroDB and x and top and left and bottom and width and height and width > 0 and height > 0 then
        TartaroDB.noticePosition = {
            x = math.max(0, math.min(1, (x - left) / width)),
            y = math.max(0, math.min(1, (top - bottom) / height)),
        }
    end
    layoutNotices()
    win:SavePosition()
end)

local enableNoticeDrag; enableNoticeDrag = A.traceCallback("UI.lua:772:enableNoticeDrag", function(frame)
    frame:SetScript("OnDragStart", A.traceCallback("UI.lua:773:callback", function(self)
        local target = self == win and not win.stackPoint and win or noticeAnchor
        if target == noticeAnchor then noticeAnchor.dragging = true end
        self.dragTarget = target
        if TartaroDB and TartaroDB.centerWindowOnResize == true then win.resizeDragging = true end
        target:StartMoving()
    end))
    frame:SetScript("OnDragStop", stopNoticeDrag)
    frame:HookScript("OnHide", stopNoticeDrag)
end)

local showDaily; showDaily = A.traceCallback("UI.lua:784:showDaily", function()
    if dailyState.db ~= A.db then
        dailyState = {db = A.db}
        if A.db then
            local state = dailyState
            C_Timer.After(6, A.traceCallback("UI.lua:789:callback", function()
                if dailyState ~= state or A.db ~= state.db then return end
                state.ready = true
                showDaily()
            end))
        end
    end
    if not A.db or not dailyState.ready or daily.NotificationsBlocked() then
        daily:Hide()
        layoutNotices()
        return
    end
    local history = notificationHistory()
    if not history then return end
    local value = dailyMessage()
    if not value or value == "" then history.daily = nil; daily:Hide(); layoutNotices(); return end
    if editor:IsShown() or history.daily == value and (not daily:IsShown() or dailyState.body ~= value) then
        daily:Hide()
        layoutNotices()
        return
    end
    if dailyState.body ~= value then
        dailyState.body = value
        dailyBody:SetText(value)
        daily:SetHeight(math.max(110, dailyBody:GetStringHeight() + 66))
    end
    if history.daily ~= value then
        history.daily = value
        if A.isDebugEnabled() then
            A.debugLog("notification.shown", "UI.daily", {day=history.day})
        end
    end
    if not daily:IsShown() then daily:Show() end
    layoutNotices()
end)

enableNoticeDrag(daily)
enableNoticeDrag(win)
daily.closeButton:HookScript("OnClick", A.traceCallback("UI.lua:827:callback", function()
    layoutNotices()
end))
win:HookScript("OnHide", A.traceCallback("UI.lua:830:callback", function() C_Timer.After(0, showDaily) end))
win:HookScript("OnDragStop", showDaily)
editor:HookScript("OnShow", showDaily)

eventPopup = surface("TartaroEventNotification", 390, 160, 0)
eventPopup:HookScript("OnShow", showDaily)
eventPopup:ClearAllPoints()
eventPopup:SetPoint("TOP", UIParent, "TOP", 0, -48)
badge(eventPopup, 47)
local popupTitle = text(eventPopup, "Nuevo evento de hermandad", "GameFontNormalLarge")
popupTitle:SetPoint("TOPLEFT", 75, -18)
local popupBody = text(eventPopup, "")
popupBody:SetPoint("TOPLEFT", 75, -46)
popupBody:SetWidth(280)
local viewEvent = copperButton(eventPopup)
viewEvent:SetSize(166, 27)
viewEvent:SetPoint("BOTTOMRIGHT", -16, 14)
viewEvent:SetText("Ver en el calendario")
viewEvent:SetStyle(false, true)
local pendingEvents, activeNotice = {}, nil
local eventNotices = {offered={}, scheduled={}, chat={}, lead=30*60}

A.invalidateEventNotices = A.traceCallback("UI.invalidateEventNotices", function()
    eventNotices.events, eventNotices.nextCheck = nil, nil
end)

local pendingEvent; pendingEvent = A.traceCallback("UI.pendingEvent", function(id)
    if not A.db then return end
    local event = A.db.events[id]
    local now = GetServerTime()
    if not event or event.when <= now or A.Calendar.dayKey(event.when) ~= A.Calendar.dayKey(now)
        or event.when - now <= eventNotices.lead then return end
    local signups = A.db.signups[id]
    local mine = signups and signups[A.self]
    if not (mine and mine.joined) then return event end
end)

local noticeEvent; noticeEvent = A.traceCallback("UI.noticeEvent", function(notice)
    if not notice or A.db ~= notice.db then return end
    local history = notificationHistory()
    if not history or notice.day ~= history.day then return end
    local receipt = history.events[notice.id] or {}
    local kind = notice.reminderAt and "reminder" or "daily"
    if receipt[kind] and notice ~= activeNotice then return end
    if not notice.reminderAt then return pendingEvent(notice.id) end
    local event = A.db.events[notice.id]
    local remaining = event and event.when - GetServerTime()
    if event and event.when == notice.reminderAt and remaining >= -eventNotices.lead and remaining <= eventNotices.lead then
        return event, remaining
    end
end)

local setPopupBody; setPopupBody = A.traceCallback("UI.setPopupBody", function(event, remaining)
    local timing = ""
    if remaining then
        if remaining > 0 then
            local minutes = math.ceil(remaining / 60)
            timing = "\nEmpieza en " .. minutes .. (minutes == 1 and " minuto." or " minutos.")
        else
            local minutes = math.floor(-remaining / 60)
            timing = minutes == 0 and "\nEl evento acaba de comenzar."
                or "\nComenzó hace " .. minutes .. (minutes == 1 and " minuto." or " minutos.")
        end
    end
    popupBody:SetText(event.title .. "\n" .. A.kinds[event.kind] .. " · "
        .. date("%d/%m/%Y %H:%M", event.when) .. " (hora local)" .. timing)
end)

A.showEventNotification = A.traceCallback("UI.showEventNotification", function()
    if eventPopup:IsShown() or editor:IsShown() or daily.NotificationsBlocked() then return end
    while #pendingEvents > 0 do
        local notice = table.remove(pendingEvents, 1)
        local event, remaining = noticeEvent(notice)
        if event then
            local history = notificationHistory()
            local receipt = history.events[notice.id] or {}
            history.events[notice.id] = receipt
            receipt.daily = true
            activeNotice = notice
            if notice.reminderAt then
                receipt.reminder = true
                local records = A.db.eventReminders[notice.id] or {}
                A.db.eventReminders[notice.id] = records
                records[A.self] = event.when
                popupTitle:SetText(remaining > 0 and "El evento empieza pronto" or "El evento ya comenzó")
            else
                popupTitle:SetText("Evento de hoy")
            end
            if A.isDebugEnabled() then
                A.debugLog("notification.shown", "UI.event", {id=event.id, when=event.when, day=history.day,
                    kind=notice.reminderAt and "reminder" or "daily"})
            end
            setPopupBody(event, remaining)
            eventPopup:SetHeight(math.max(138, popupBody:GetStringHeight() + 104))
            eventPopup:Show()
            return
        end
    end
end)

A.notifyEvent = A.traceCallback("UI.notifyEvent", function(id, isNew)
    local history = notificationHistory()
    if not history or eventNotices.offered[id] == history.day or not pendingEvent(id)
        or history.events[id] and history.events[id].daily then return end
    eventNotices.offered[id] = history.day
    pendingEvents[#pendingEvents + 1] = {id=id, db=A.db, isNew=isNew, day=history.day}
    A.showEventNotification()
end)

local sortEvents; sortEvents = A.traceCallback("UI.lua:939:sortEvents", function(events)
    table.sort(events, A.traceCallback("UI.lua:940:callback", function(left, right)
        return left.when < right.when or (left.when == right.when and left.id < right.id)
    end))
end)

local checkEventReminders; checkEventReminders = A.traceCallback("UI.checkEventReminders", function()
    if not A.db then return end
    if daily.NotificationsBlocked() then return end
    local history = notificationHistory()
    if not history then return end
    showDaily()
    if activeNotice then
        local event, remaining = noticeEvent(activeNotice)
        if not event then
            eventPopup:Hide()
        elseif activeNotice.reminderAt then
            popupTitle:SetText(remaining > 0 and "El evento empieza pronto" or "El evento ya comenzó")
            setPopupBody(event, remaining)
        end
    end
    local now = GetServerTime()
    local offset = win:LocalTimeOffset(now)
    if eventNotices.offset ~= offset or eventNotices.history ~= history then
        eventNotices.offset, eventNotices.history, eventNotices.nextCheck = offset, history, nil
    end
    if eventNotices.chatContext ~= A.db or eventNotices.chatDay ~= history.day then
        eventNotices.chat, eventNotices.chatContext, eventNotices.chatDay = {}, A.db, history.day
        eventNotices.offered, eventNotices.scheduled = {}, {}
        A.invalidateEventNotices()
    end
    if eventNotices.checkedAt and now < eventNotices.checkedAt then eventNotices.nextCheck = nil end
    eventNotices.checkedAt = now
    if eventNotices.nextCheck and now < eventNotices.nextCheck then
        A.showEventNotification()
        return
    end
    if not eventNotices.events then
        local events = {}
        for _, event in pairs(A.db.events) do events[#events + 1] = event end
        sortEvents(events)
        eventNotices.events = events
        A.debugLog("notifications.index", "UI.checkEventReminders", #events)
    end
    local events, due = eventNotices.events
    eventNotices.nextCheck = math.huge
    for _, event in ipairs(events) do
        local id = event.id
        local records = A.db.eventReminders[id]
        local receipt = history.events[id]
        local remaining = event.when - now
        if remaining > eventNotices.lead then
            eventNotices.nextCheck = math.min(eventNotices.nextCheck,event.when-eventNotices.lead)
        end
        if remaining >= -eventNotices.lead and remaining <= eventNotices.lead and eventNotices.scheduled[id] ~= event.when
            and (not records or records[A.self] ~= event.when) and (not receipt or not receipt.reminder) then
            due = due or {}
            due[#due + 1] = event
            eventNotices.scheduled[id] = event.when
        end
    end
    if due then
        for index, event in ipairs(due) do
            table.insert(pendingEvents, index, {id=event.id, db=A.db, reminderAt=event.when, day=history.day})
        end
        if activeNotice and not activeNotice.reminderAt then eventPopup:Hide() end
    end
    for _, event in ipairs(events) do
        if A.Calendar.dayKey(event.when) == history.day and not eventNotices.chat[event.id] then
            eventNotices.chat[event.id] = true
            print("Tártaro · Evento de hoy: " .. date("%H:%M", event.when) .. " · " .. event.title .. " (hora local)")
        end
        A.notifyEvent(event.id, false)
    end
    A.debugLog("notifications.scan","UI.checkEventReminders",#events,
        eventNotices.nextCheck == math.huge and "none" or eventNotices.nextCheck)
    A.showEventNotification()
end)
C_Timer.NewTicker(5, checkEventReminders)

A.queuePendingEvents = A.traceCallback("UI.queuePendingEvents", function()
    pendingEvents, eventNotices.offered, eventNotices.scheduled, activeNotice = {}, {}, {}, nil
    A.invalidateEventNotices()
    if eventPopup:IsShown() then eventPopup:Hide() end
    checkEventReminders()
end)

eventPopup:SetScript("OnHide", A.traceCallback("UI.lua:1026:callback", function()
    activeNotice = nil
    A.showEventNotification()
    showDaily()
end))
enableNoticeDrag(eventPopup)
viewEvent:SetScript("OnClick", A.traceCallback("UI.lua:1032:callback", function()
    if editor:IsShown() then return end
    local notice = activeNotice
    eventPopup:Hide()
    if notice and A.db == notice.db then
        page, selectedEvent = "calendar", notice.id
        win:Show()
        scroll:SetVerticalScroll(0)
        A.refresh()
    end
end))

local accent = {1, 0.72, 0.46}
local selectedOrder, pendingOrderScroll, orderFocusY, orderNotice

local openOrders; openOrders = A.traceCallback("UI.lua:1047:openOrders", function(id)
    if not A.db then return end
    selectedOrder, pendingOrderScroll, orderNotice = id, id ~= nil, nil
    page, professionView = "professions", "orders"
    scroll:SetVerticalScroll(0)
    A.refresh()
    if A.isDebugEnabled() then
        A.debugLog("observation", "order.open", {id=id, selected=selectedOrder, scroll=scroll:GetVerticalScroll(), notice=orderNotice},
            "Pedido seleccionado o explicación de indisponibilidad", selectedOrder or orderNotice or "sin selección",
            id == nil or selectedOrder == id or orderNotice ~= nil)
    end
end)

local orderShortcut; orderShortcut = A.traceCallback("UI.lua:1060:orderShortcut", function(order, summary)
    local frame = row("button")
    frame.button:SetWidth(layout.width - 8)
    frame.button:SetText(summary)
    local label = frame.button:GetFontString()
    label:SetWidth(layout.width - 24)
    label:SetMaxLines(0)
    local height = math.max(27, label:GetStringHeight() + 12)
    frame.button:SetHeight(height)
    frame.button:SetStyle(false)
    local db, id = A.db, order.id
    frame.button:SetScript("OnClick", A.traceCallback("UI.lua:1071:callback", function()
        if A.db == db then openOrders(id) end
    end))
    frame.button:Show()
    frame:SetHeight(height + 8)
    layout.y = layout.y + height + 8
end)

local home; home = A.traceCallback("UI.lua:1079:home", function()
    local now, nextEvent = GetServerTime()
    for _, event in pairs(A.db.events) do
        if event.when > now and (not nextEvent or event.when < nextEvent.when
            or event.when == nextEvent.when and event.id < nextEvent.id) then
            nextEvent = event
        end
    end
    win.nextEventAt = nextEvent and nextEvent.when
    layout.width = 318
    line("Próximo evento", accent)
    if nextEvent then
        line(nextEvent.title)
        line(date("%d/%m/%Y · %H:%M", nextEvent.when) .. " (hora local)")
        if nextEvent.detail ~= "" then line(nextEvent.detail) end
        button("Ver evento", A.traceCallback("UI.lua:1094:callback", function()
            page, selectedEvent = "calendar", nextEvent.id
            scroll:SetVerticalScroll(0)
            A.refresh()
        end), true)
    else
        line("No hay eventos próximos.")
    end
    local eventHeight = layout.y
    layout.x, layout.width, layout.y = 334, 236, 0
    line("Mensaje del día", accent)
    local message = dailyMessage()
    line(message ~= "" and message or "Todavía no hay mensaje del día.")
    button("Ver avisos", A.traceCallback("UI.lua:1107:callback", function()
        page = "notices"
        scroll:SetVerticalScroll(0)
        A.refresh()
    end))
    local ordersTop = math.max(layout.y, eventHeight)
    homeDivider:SetHeight(ordersTop)
    homeRule:SetPoint("TOPLEFT", 0, -(ordersTop + 7))
    layout.x, layout.width, layout.y = 0, 570, ordersTop + 17
    line("Pedidos de fabricación", accent)
    local orders, _, summaries = A.listVisibleOrders()
    local requested, crafting = {}, {}
    for _, order in ipairs(orders) do
        local summary=summaries[order.id]
        if order.owner == A.self then
            local count=#summary.members
            local status = count == 0 and "Esperando fabricante" or count == 1 and "1 oferta" or count .. " ofertas"
            requested[#requested + 1] = {order = order, text = ("%d × %s · %s"):format(order.quantity, order.name, status)}
        elseif summary.own then
            crafting[#crafting + 1] = {order = order, text = ("%d × %s · Para %s"):format(order.quantity, order.name, A.members[order.owner].name)}
        end
    end
    local listTop = layout.y
    layout.width = 318
    line("Mis pedidos pendientes", accent)
    if #requested == 0 then line("No tenés pedidos pendientes.") end
    for _, entry in ipairs(requested) do orderShortcut(entry.order, entry.text) end
    local requestedHeight = layout.y
    layout.x, layout.width, layout.y = 334, 236, listTop
    line("Pedidos que me ofrecí a fabricar", accent)
    if #crafting == 0 then line("Todavía no te ofreciste para ningún pedido pendiente.") end
    for _, entry in ipairs(crafting) do orderShortcut(entry.order, entry.text) end
    layout.x, layout.width, layout.y = 0, 570, math.max(layout.y, requestedHeight)
    homeOrdersDivider:SetPoint("TOPLEFT", 319, -listTop)
    homeOrdersDivider:SetHeight(layout.y - listTop)
    button("Ver pedidos", A.traceCallback("UI.lua:1142:callback", function()
        openOrders()
    end))
end)

local whisperTarget; whisperTarget = A.traceCallback("UI.lua:1147:whisperTarget", function(name)
    local character, suffix = name:match("^(.-)%-([^%-]+)$")
    if character and suffix and A.key(suffix) == A.realm then return character end
    return name
end)

local openWhisperDraft; openWhisperDraft = A.traceCallback("UI.lua:1153:openWhisperDraft", function(target, draft)
    local chat = ChatFrameUtil
    if chat and chat.OpenChat and chat.ChooseBoxForSend then
        chat.OpenChat("")
        local editBox = chat.ChooseBoxForSend()
        editBox:SetChatType("WHISPER")
        editBox:SetTellTarget(target)
        editBox:UpdateHeader()
        editBox:SetText(draft)
        return true
    elseif ChatFrame_OpenChat then
        ChatFrame_OpenChat("/w " .. target .. " " .. draft)
        return true
    end
end)

local canInviteMember; canInviteMember = A.traceCallback("UI.lua:1169:canInviteMember", function(member)
    if member.online ~= true then return false end
    if not IsInGroup() then return true end
    local leader = UnitIsGroupLeader("player")
    return (not issecretvalue or not issecretvalue(leader)) and leader == true
end)

local invitationActions; invitationActions = A.traceCallback("UI.lua:1176:invitationActions", function(root, currentParticipant, allowed)
    local member = currentParticipant()
    if not member then return end
    local canInvite; canInvite = A.traceCallback("UI.lua:1179:canInvite", function(target)
        return target and target.online ~= false and (not allowed or allowed(target))
    end)
    local inRaid = IsInRaid()
    local invite = root:CreateButton(inRaid and "Invitar a la banda" or "Invitar al grupo", A.traceCallback("UI.lua:1183:callback", function()
        local target = currentParticipant()
        if not canInvite(target) then return end
        local send = C_PartyInfo and C_PartyInfo.InviteUnit or InviteUnit
        if send then
            local ok, result = A.debugPcall("UI.lua:1188:pcall", send, target.name)
            if ok and result ~= false then return end
        end
        if ChatFrame_OpenChat then
            ChatFrame_OpenChat("/invite " .. target.name)
        else
            print("Tártaro: WoW no pudo enviar la invitación.")
        end
    end))
    invite:SetEnabled(canInvite(member) == true)
    local convert = C_PartyInfo and C_PartyInfo.ConvertToRaid or ConvertToRaid
    local isLeader = IsInGroup() and UnitIsGroupLeader("player")
    if convert and not inRaid and (not issecretvalue or not issecretvalue(isLeader)) and isLeader
        and (not allowed or allowed(member)) then
        root:CreateButton("Convertir grupo en banda", A.traceCallback("UI.lua:1202:callback", function()
            local target = currentParticipant()
            if not target or (allowed and not allowed(target)) or IsInRaid() or not IsInGroup() then return end
            local leader = UnitIsGroupLeader("player")
            if (not issecretvalue or not issecretvalue(leader)) and leader then convert() end
        end))
    end
end)

local participantActions; participantActions = A.traceCallback("UI.lua:1211:participantActions", function(id, label, currentParticipant, allowed)
    local frame = line(label)
    if id == A.self then return end
    if not frame.participantMenu then
        local control = CreateFrame("Button", nil, frame)
        control:SetAllPoints(frame)
        control:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        control:SetScript("OnEnter", A.traceCallback("UI.lua:1218:callback", function() frame.label:SetTextColor(unpack(accent)) end))
        control:SetScript("OnLeave", A.traceCallback("UI.lua:1219:callback", function() frame.label:SetTextColor(0.96, 0.90, 0.82) end))
        control:SetScript("OnHide", A.traceCallback("UI.participant.release", function(self) self:SetScript("OnClick",nil) end))
        frame.participantMenu = components.Attach(frame,control)
    end
    frame.participantMenu:SetScript("OnClick", A.traceCallback("UI.lua:1223:callback", function(owner)
        local member = currentParticipant()
        if not member then return end
        MenuUtil.CreateContextMenu(owner, A.traceCallback("UI.lua:1226:callback", function(_, root)
            root:CreateTitle(member.name)
            invitationActions(root, currentParticipant, allowed)
        end))
    end))
    frame.participantMenu:Show()
end)

local eventParticipant; eventParticipant = A.traceCallback("UI.lua:1234:eventParticipant", function(event, entry, label)
    local db, id, eventId = A.db, entry.id, event.id
    participantActions(id, label, A.traceCallback("UI.lua:1236:callback", function()
        if A.db ~= db or not A.canEditEvent(A.me, eventId) then return end
        local current = db.events[eventId]
        local signups = db.signups[eventId]
        if not current or current.when <= GetServerTime() or not signups or not signups[id] or not signups[id].joined then return end
        return A.members[id]
    end))
end)

local groupParticipant; groupParticipant = A.traceCallback("UI.lua:1245:groupParticipant", function(group, id, label)
    local db = A.db
    participantActions(id, label, A.traceCallback("UI.lua:1247:callback", function()
        if A.db ~= db or group.owner ~= A.self or A.groups[A.self] ~= group or group.version ~= 1
            or not group.slots or group.when + 1800 <= GetServerTime() or not A.can(A.me, "group") then return end
        local _, _, members = A.groupAttendance(group)
        if members[id] then return A.members[id] end
    end))
end)

calendarPanel.RenderEvent = A.traceCallback("UI.calendarEvent", function(current, index)
    local db = A.db
    local cardLeft, cardTop, cardWidth = layout.x, layout.y + 4, layout.width
    if current.id == selectedEvent then calendarPanel.focusY = cardTop end
    local finishCard; finishCard = A.traceCallback("UI.calendar.finishCard", function()
        recordCard(index, cardLeft, cardTop, cardWidth, layout.y - cardTop + 12, current.id == selectedEvent)
        layout.x, layout.width, layout.y = cardLeft, cardWidth, layout.y + 24
    end)
    layout.x, layout.width, layout.y = cardLeft + 12, cardWidth - 24, cardTop + 12
    line(current.title, accent, false, GameFontNormalLarge)
    line("Fecha: " .. date("%d/%m/%Y", current.when), nil, true)
    line("Hora local: " .. date("%H:%M", current.when), accent, true)
    line("Tipo: " .. A.kinds[current.kind], nil, true)
    if current.shared then line("Copia compartida · pendiente de confirmar por el creador o un líder.") end
    if current.detail ~= "" then
        layout.y = layout.y + 8
        line("Descripción", accent, true)
        line(current.detail)
    end
    layout.y = layout.y + 8
    if current.when <= GetServerTime() then
        line("Evento vencido · Inscripciones en solo lectura", accent)
        local registered = {}
        for id, signup in pairs(db.signups[current.id] or {}) do
            if signup.joined then registered[#registered+1]={id=id, signup=signup} end
        end
        table.sort(registered,A.traceCallback("UI.lua:1281:callback", function(a,b)
            if a.signup.rev ~= b.signup.rev then return (a.signup.rev or 0) < (b.signup.rev or 0) end
            return a.id < b.id
        end))
        line("Anotados: " .. #registered, accent)
        for _, entry in ipairs(registered) do
            local member=db and A.members[entry.id]
            line((entry.signup.name or member and member.name or entry.id)
                .. (A.eventRoles[entry.signup.role] and (" · " .. A.eventRoles[entry.signup.role]) or ""))
        end
        if A.canEditEvent(A.me, current) then
            button("Eliminar evento", A.traceCallback("UI.event.deleteExpired", function()
                win:ConfirmDeleteEvent(current)
            end))
        end
        finishCard()
        return
    end
    local signups = A.db.signups[current.id] or {}
    local mine = signups[A.self]
    local entries, counts, status = A.eventAttendance(current)
    if current.caps then
        line("Cupos", accent, true)
        for i, role in ipairs(A.eventRoleOrder) do
            if current.caps[i] > 0 then
                line(("%s · %d/%d"):format(A.eventRoles[role], math.min(counts[role], current.caps[i]), current.caps[i]), accent)
                if counts[role] > current.caps[i] then line(("Suplentes · %d"):format(counts[role] - current.caps[i])) end
            end
        end
        layout.y = layout.y + 8
    end
    line("Anotados: " .. #entries, accent)
    local canEdit = A.canEditEvent(A.me, current)
    if canEdit then
        for _, entry in ipairs(entries) do
            local signup = entry.signup
            local suffix = current.caps and (" · " .. (A.eventRoles[signup.role] or "Sin rol")
                .. " · " .. (status[entry.id] or "Pendiente")) or ""
            eventParticipant(current, entry, signup.name .. suffix)
        end
    end
    layout.y = layout.y + 8
    line("Acciones", accent, true)
    if current.caps then
        for i, role in ipairs(A.eventRoleOrder) do
            if current.caps[i] > 0 and (not mine or not mine.joined or mine.role ~= role) then
                local choice = role
                button((mine and mine.joined and "Cambiar a " or "Anotarme como ") .. A.eventRoles[choice], A.traceCallback("UI.lua:1328:callback", function()
                    A.signup(current.id, choice)
                    A.refresh()
                end), not (mine and mine.joined))
            end
        end
    end
    if mine and mine.joined then
        if current.caps then line("Tu inscripción · " .. (status[A.self] or "Elegí un rol"), accent) end
        button("Quitar mi inscripción", A.traceCallback("UI.lua:1337:callback", function() A.signup(current.id); A.refresh() end))
    elseif not current.caps then
        button("Quiero participar", A.traceCallback("UI.lua:1339:callback", function() A.signup(current.id); A.refresh() end), true)
    end
    if canEdit then
        button("Editar evento", A.traceCallback("UI.lua:1342:callback", function() openEditor("event", current) end))
        button("Eliminar evento", A.traceCallback("UI.event.delete", function() win:ConfirmDeleteEvent(current) end))
    end
    finishCard()
end)

local calendar; calendar = A.traceCallback("UI.lua:1348:calendar", function()
    local db = A.db
    local nextWhen
    for _, event in pairs(db.events) do
        if event.when > GetServerTime() and (not nextWhen or event.when < nextWhen) then nextWhen=event.when end
    end
    win.nextEventAt = nextWhen
    local current = calendarPanel:Display(db.events, selectedEvent, {
        context=db, isCurrent=A.traceCallback("UI.lua:1356:callback", function() return A.db == db end),
        canCreate=A.traceCallback("UI.lua:1357:callback", function() return A.can(A.me,"event") end),
        onCreate=A.traceCallback("UI.lua:1358:callback", function() openEditor("event") end),
        onSelect=A.traceCallback("UI.lua:1359:callback", function(id)
            if A.db ~= db then return end
            selectedEvent=id
            calendarPanel.pendingFocus = true
            A.refresh()
            if A.isDebugEnabled() then
                A.debugLog("observation", "calendar.select", {id=id, selected=selectedEvent, day=calendarPanel.selectedDay,
                    year=calendarPanel.year, month=calendarPanel.month, scroll=scroll:GetVerticalScroll()})
            end
        end),
    })
    selectedEvent=current and current.id or nil
    if selectedEvent ~= calendarPanel.renderedEvent then calendarPanel.pendingFocus = true end
    local dayEvents = calendarPanel:DayEvents()
    local year,month,day = calendarPanel.selectedDay:match("^(%d+)%-(%d+)%-(%d+)$")
    line(("Día %s/%s/%s"):format(day,month,year), accent)
    line("Eventos del día: " .. #dayEvents, nil, true)
    components.BeginTable()
    calendarPanel.focusY = 0
    if #dayEvents == 0 then line("No hay eventos para este día.") end
    for index, event in ipairs(dayEvents) do calendarPanel.RenderEvent(event, index) end
    calendarPanel.renderedEvent = selectedEvent
end)

local notices; notices = A.traceCallback("UI.lua:1383:notices", function()
    local allowed = A.can(A.me, "notice")
    line("Mensaje del día", accent)
    local value = dailyMessage()
    line(value ~= "" and value or "Todavía no hay mensaje del día.")
    if allowed then
        button("Editar mensaje del día", A.traceCallback("UI.lua:1389:callback", function() openEditor("daily") end))
        button("Publicar aviso", A.traceCallback("UI.lua:1390:callback", function() openEditor("notice") end))
    end
    line("Avisos de la hermandad", accent)
    local records = {}
    for _, notice in pairs(A.db.notices) do records[#records + 1] = notice end
    table.sort(records, A.traceCallback("UI.lua:1395:callback", function(left, right) return left.when > right.when end))
    if #records == 0 then line("Todavía no hay avisos.") end
    local maxWidth = layout.width
    for index, notice in ipairs(records) do
        local top = layout.y
        layout.x, layout.width, layout.y = 9, maxWidth - 18, top + 9
        line(date("%d/%m %H:%M", notice.when) .. " · " .. notice.name, accent)
        line(notice.text)
        recordCard(index, 0, top, maxWidth, layout.y + 9 - top)
        layout.x, layout.width, layout.y = 0, maxWidth, layout.y + 19
    end
end)

local permissions; permissions = A.traceCallback("UI.lua:1408:permissions", function()
    if not A.canManagePermissions(A.me) then return end
    line("Permisos por rango", accent)
    line("Crear eventos no permite editar eventos ajenos. Solo el creador, el líder y los sublíderes pueden editarlos.")
    local orders = {}
    for order in pairs(A.ranks) do
        if order > 0 then orders[#orders + 1] = order end
    end
    table.sort(orders)
    if #orders == 0 then
        line("Todavía no se cargaron los rangos de la hermandad.")
        return
    end
    for _, order in ipairs(orders) do
        local index = order
        local member = {rank = index, rankName = A.ranks[index]}
        line(member.rankName, accent)
        local labels = {notice = "Publicar avisos", event = "Crear eventos",
            call = "Lanzar llamados a las armas", group = "Publicar búsquedas de grupo"}
        for _, permission in ipairs({"notice", "event", "call", "group"}) do
            local field = permission
            check(labels[field], A.can(member, field), A.traceCallback("UI.lua:1429:callback", function(enabled)
                A.setGrant(index, field, enabled)
                A.refresh()
            end))
        end
    end
end)

local callVolume; callVolume = A.traceCallback("UI.lua:1437:callVolume", function()
    local saved = TartaroDB and TartaroDB.callSoundVolume
    if type(saved) == "number" and saved >= 0 and saved <= 100 and saved % 20 == 0 then return saved end
    return TartaroDB and TartaroDB.callSound == false and 0 or 100
end)

local callSounds = {
    {id = "tartaro", label = "Tambores y doble grito", file = "CallToArms", duration = 4.15},
    {id = "nature", label = "Nature", file = "CallNature", duration = 4.65},
}

local selectedCallSound; selectedCallSound = A.traceCallback("UI.lua:1448:selectedCallSound", function()
    return TartaroDB and TartaroDB.callSoundChoice == "nature" and callSounds[2] or callSounds[1]
end)

A.playCallSound = A.traceCallback("UI.lua:1452:A.playCallSound", function(isAlert)
    local volume = callVolume()
    if volume == 0 or not PlaySoundFile then return false end
    local suffix = volume == 100 and "" or tostring(volume)
    local sound = selectedCallSound()
    local path = "Interface\\AddOns\\Tartaro\\" .. sound.file .. suffix .. ".mp3"
    if A.isDebugEnabled() then
        A.debugLog("observation", "sound.request", {mode=isAlert and "alert" or "SFX", file=path, volume=volume})
    end
    local played, handle
    if isAlert then played, handle = A.playCallAlert(path, sound.duration)
    else played, handle = PlaySoundFile(path, "SFX") end
    if A.isDebugEnabled() then
        A.debugLog("observation", "sound.result", {mode=isAlert and "alert" or "SFX", file=path, volume=volume, played=not not played},
            "La API acepta reproducir el archivo; no demuestra que se oye", tostring(played), not not played)
    end
    return played, handle
end)

local optionsPanel = CreateFrame("Frame", nil, win)
optionsPanel:SetPoint("TOPLEFT", 18 + sidebarWidth, -(headerHeight + 20))
optionsPanel:SetSize(550, 345)
optionsPanel:Hide()
do
    local title = text(optionsPanel, "Llamado a las armas", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT")
    local versionLabel = text(optionsPanel, "")
    versionLabel:SetPoint("TOPRIGHT")
    A.updateVersionLabel = A.traceCallback("UI.lua:1480:A.updateVersionLabel", function()
        local label = A.addonVersion and ("Versión " .. A.addonVersion) or "Versión sin datos"
        if A.newerAddonVersion then label = label .. " · Detectada " .. A.newerAddonVersion end
        versionLabel:SetText(label)
    end)
    A.updateVersionLabel()
    A.callLauncherSize = A.traceCallback("UI.callLauncherSize", function(value)
        if value == nil then value = TartaroDB and TartaroDB.callLauncherSize end
        if type(value) ~= "number" or value ~= value then return 100 end
        return math.floor(math.max(50, math.min(150, value)) / 5 + 0.5) * 5
    end)
    local sizeValue = text(optionsPanel, "Tamaño del botón · 100%")
    sizeValue:SetPoint("TOPLEFT", 334, -34)
    sizeValue:SetWidth(210)
    local sizeSlider = CreateFrame("Slider", nil, optionsPanel)
    sizeSlider:SetPoint("TOPLEFT", 336, -62)
    sizeSlider:SetSize(200, 20)
    sizeSlider:SetOrientation("HORIZONTAL")
    sizeSlider:SetMinMaxValues(50, 150)
    sizeSlider:SetValueStep(5)
    sizeSlider:SetObeyStepOnDrag(true)
    sizeSlider:EnableMouse(true)
    local sizeTrack = sizeSlider:CreateTexture(nil, "BACKGROUND")
    sizeTrack:SetPoint("LEFT"); sizeTrack:SetPoint("RIGHT"); sizeTrack:SetHeight(5)
    sizeTrack:SetColorTexture(0.49, 0.30, 0.21, 1)
    local sizeThumb = sizeSlider:CreateTexture(nil, "OVERLAY")
    sizeThumb:SetSize(12, 20); sizeThumb:SetColorTexture(1, 0.68, 0.43, 1)
    sizeSlider:SetThumbTexture(sizeThumb)
    local sizeLimits = text(optionsPanel, "50% - 150%")
    sizeLimits:SetPoint("TOPLEFT", 334, -86)
    sizeLimits:SetWidth(210)
    sizeSlider:SetScript("OnValueChanged", A.traceCallback("UI.callLauncherSize.changed", function(_, value)
        local percent = A.setCallLauncherSize(value)
        if percent then sizeValue:SetText("Tamaño del botón · " .. percent .. "%") end
    end))
    local handle
    local stopPreview; stopPreview = A.traceCallback("UI.lua:1516:stopPreview", function()
        if handle and StopSound then StopSound(handle) end
        handle = nil
    end)
    local soundButtons = {}
    local showSoundChoice; showSoundChoice = A.traceCallback("UI.lua:1521:showSoundChoice", function()
        local selected = selectedCallSound().id
        for id, control in pairs(soundButtons) do control:SetStyle(id == selected) end
    end)
    for index, sound in ipairs(callSounds) do
        local id = sound.id
        local control = copperButton(optionsPanel)
        control:SetPoint("TOPLEFT", index == 1 and 0 or 198, -34)
        control:SetSize(index == 1 and 188 or 114, 27)
        control:SetText(sound.label)
        control:SetScript("OnClick", A.traceCallback("UI.lua:1531:callback", function()
            stopPreview()
            TartaroDB.callSoundChoice = id
            showSoundChoice()
        end))
        soundButtons[id] = control
    end
    local value = text(optionsPanel, "")
    value:SetPoint("TOPLEFT", 0, -78)
    local slider = CreateFrame("Slider", nil, optionsPanel)
    slider:SetPoint("TOPLEFT", 2, -106)
    slider:SetSize(294, 22)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(0, 100)
    slider:SetValueStep(20)
    slider:SetObeyStepOnDrag(true)
    slider:EnableMouse(true)
    local track = slider:CreateTexture(nil, "BACKGROUND")
    track:SetPoint("LEFT")
    track:SetPoint("RIGHT")
    track:SetHeight(5)
    track:SetColorTexture(0.49, 0.30, 0.21, 1)
    local thumb = slider:CreateTexture(nil, "OVERLAY")
    thumb:SetSize(12, 20)
    thumb:SetColorTexture(1, 0.68, 0.43, 1)
    slider:SetThumbTexture(thumb)
    local preview = copperButton(optionsPanel)
    preview:SetPoint("LEFT", slider, "RIGHT", 17, 0)
    preview:SetSize(130, 28)
    preview:SetText("Probar archivo")
    preview:SetScript("OnClick", A.traceCallback("UI.lua:1561:callback", function()
        stopPreview()
        local played
        played, handle = A.playCallSound()
        if not played then print("Tártaro: WoW no pudo reproducir el sonido del llamado.") end
    end))
    local previewHelp = text(optionsPanel, "Esta prueba usa efectos de sonido (SFX). No prueba el modo completo de alerta.")
    previewHelp:SetPoint("TOPLEFT", 0, -138)
    previewHelp:SetWidth(540)
    local alertHelp = text(optionsPanel, "La alerta intenta usar el volumen general (Master) y silenciar temporalmente otros canales; sin control de volumen usa SFX.")
    alertHelp:SetPoint("TOPLEFT", previewHelp, "BOTTOMLEFT", 0, -6)
    alertHelp:SetWidth(540)
    local combat = CreateFrame("CheckButton", nil, optionsPanel, "UICheckButtonTemplate")
    combat:SetPoint("TOPLEFT", alertHelp, "BOTTOMLEFT", -4, -12)
    local combatLabel = text(combat, "Ocultar ventanas de Tártaro durante el combate")
    combatLabel:SetPoint("LEFT", combat, "RIGHT", 4, 0)
    combat:SetScript("OnClick", A.traceCallback("UI.lua:1577:callback", function(self)
        TartaroDB.hideWindowsInCombat = self:GetChecked() and true or false
        A.updateCombatWindows()
    end))
    local resize = CreateFrame("CheckButton", nil, optionsPanel, "UICheckButtonTemplate")
    resize:SetPoint("TOPLEFT", combat, "BOTTOMLEFT", 0, -6)
    local resizeLabel = text(resize, "Mantener centro horizontal y crecer hacia abajo")
    resizeLabel:SetPoint("LEFT", resize, "RIGHT", 4, 0)
    resize:SetScript("OnClick", A.traceCallback("UI.window.resizeOption", function(self)
        TartaroDB.centerWindowOnResize = self:GetChecked() and true or false
        local origin = win.resizeOrigin
        if not TartaroDB.centerWindowOnResize and origin then
            local point = origin.point
            local x, y = win:GetCenter()
            if point:find("LEFT", 1, true) then x=win:GetLeft()
            elseif point:find("RIGHT", 1, true) then x=win:GetRight() end
            if point:find("TOP", 1, true) then y=win:GetTop()
            elseif point:find("BOTTOM", 1, true) then y=win:GetBottom() end
            if x and y then
                win:ClearAllPoints()
                win:SetPoint(point, UIParent, "BOTTOMLEFT", x, y)
                if win.stackPoint then win.stackPoint={win:GetPoint(1)} end
            end
        end
        win.resizeOrigin = nil
        win:CaptureResizeOrigin()
        win:SavePosition(true)
        A.refresh()
    end))
    local reset = copperButton(optionsPanel)
    reset:SetPoint("TOPLEFT", resize, "BOTTOMLEFT", 4, -14)
    reset:SetSize(220, 28)
    reset:SetText("Restablecer configuración")
    reset:SetStyle(false)
    reset:SetScript("OnClick", A.traceCallback("UI.lua:1611:callback", function() StaticPopup_Show("TARTARO_RESET_OPTIONS") end))
    local showVolume; showVolume = A.traceCallback("UI.lua:1612:showVolume", function(volume)
        value:SetText("Volumen del llamado · " .. (volume == 0 and "Silenciado" or volume .. "%"))
        preview:SetEnabled(volume ~= 0)
        preview:SetStyle(false, volume ~= 0)
    end)
    slider:SetScript("OnValueChanged", A.traceCallback("UI.lua:1617:callback", function(_, volume)
        TartaroDB.callSoundVolume = volume
        showVolume(volume)
        stopPreview()
    end))
    local syncOptions; syncOptions = A.traceCallback("UI.lua:1622:syncOptions", function()
        local volume = callVolume()
        slider:SetValue(volume)
        showVolume(volume)
        showSoundChoice()
        combat:SetChecked(TartaroDB.hideWindowsInCombat ~= false)
        resize:SetChecked(TartaroDB.centerWindowOnResize == true)
        local percent = A.callLauncherSize()
        sizeSlider:SetValue(percent)
        sizeValue:SetText("Tamaño del botón · " .. percent .. "%")
    end)
    optionsPanel.sync = syncOptions
    optionsPanel:SetScript("OnShow", syncOptions)
end

local settings; settings = A.traceCallback("UI.lua:1637:settings", function()
    line("Ajustes de mapa", accent)
    line("Ubicación", accent)
    line("Mapa y minimapa: aro de color de clase = hermandad fuera de tu grupo.")
    line("Tu grupo o banda usa los marcadores del juego.")
    check("Compartir mi ubicación con la hermandad", TartaroDB.shareLocation ~= false, A.setSharing)
    line("Podés seguir viendo a tus compañeros con esta opción desactivada.")
    line("Estado", accent)
    win.mapStatus = A.locationStatus()
    line(win.mapStatus, accent)
    local live = 0
    for _, position in pairs(A.positions) do
        if position.expires > GetTime() then live = live + 1 end
    end
    line("Ubicaciones recientes recibidas: " .. live)
    win.mapLive, win.mapWorldStatus = live, A.worldMapStatus
    win.mapCalls, win.mapCallCount = {}, 0
    if A.worldMapStatus then line("Último mapa del mundo: " .. A.worldMapStatus) end
    line("Llamados", accent)
    for _, call in pairs(A.calls) do
        if call.expires > GetServerTime() then
            local location = A.callLocation(call)
            win.mapCalls[call], win.mapCallCount = location, win.mapCallCount + 1
            line(call.name .. " · " .. location, accent)
            button("Ver llamado", A.traceCallback("UI.lua:1661:callback", function() A.showCall(call) end))
            if call.author == A.self then
                local db, character = A.db, A.self
                local names = {}
                for id in pairs(A.callRequests) do
                    if A.members[id] then names[#names + 1] = {id=id, name=A.members[id].name} end
                end
                table.sort(names, A.traceCallback("UI.lua:1668:callback", function(left, right) return left.name < right.name end))
                line("Pedidos de grupo · " .. #names, accent)
                for _, entry in ipairs(names) do
                    local id = entry.id
                    participantActions(id, entry.name, A.traceCallback("UI.lua:1672:callback", function()
                        if A.db ~= db or A.self ~= character or A.calls[character] ~= call or call.author ~= character
                            or call.expires <= GetServerTime() or not A.can(A.members[character], "call")
                            or not A.callRequests[id] then return end
                        return A.members[id]
                    end), canInviteMember)
                end
                button("Cerrar llamado", A.traceCallback("UI.lua:1679:callback", function() A.closeCall(call) end))
            end
        end
    end
end)

local memberColumns = {10, 164, 207, 367, 470, 580, 690}
local detectedFirst
local memberPresence = {}
local presenceLabels = {active="Activo", unconfirmed="Sin confirmar", historical="Histórico", undetected="Sin detectar"}
presenceLabels.overlord = {L="Cargado", D="Desactivado", E="Sin cargar", I="Instalado", N="No instalado", U="Sin datos"}

local memberRow; memberRow = A.traceCallback("UI.lua:1691:memberRow", function(values, index, role, online, detected, class, overlordLoaded)
    local muted = {0.7, 0.65, 0.61}
    local green = {0.55, 0.82, 0.65}
    local classColor = class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
    local colors = {
        classColor and {classColor.r, classColor.g, classColor.b}, nil, role == "TANK" and {0.54, 0.74, 0.96}
            or role == "HEALER" and green or role == "DAMAGER" and accent
            or role and role:find("/", 1, true) and accent or muted,
        online and green or muted, detected and green or muted,
        overlordLoaded and green or muted,
    }
    if index == 0 then
        for i = 1, #memberColumns - 1 do colors[i] = accent end
    end
    local frame = tableRow(values, memberColumns, 27, 2, colors)
    if not frame.memberBackground then
        frame.memberBackground = components.Attach(frame,frame:CreateTexture(nil, "BACKGROUND"))
        frame.memberBackground:SetAllPoints()
    end
    if index == 0 then
        if not frame.memberSort then
            local control = CreateFrame("Button", nil, frame)
            control:SetPoint("LEFT", memberColumns[5], 0)
            control:SetSize(memberColumns[6] - memberColumns[5] - 8, 23)
            local label = text(control, "Tártaro")
            label:SetPoint("LEFT")
            label:SetTextColor(unpack(accent))
            control:SetScript("OnClick", A.traceCallback("UI.lua:1718:callback", function()
                detectedFirst = not detectedFirst
                scroll:SetVerticalScroll(0)
                A.refresh()
            end))
            control:SetScript("OnEnter", A.traceCallback("UI.lua:1723:callback", function(self)
                label:SetTextColor(1, 0.92, 0.80)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(detectedFirst == true and "Mostrar primero a los miembros sin detección histórica"
                    or "Mostrar primero a los miembros con detección histórica de Tártaro")
                GameTooltip:Show()
            end))
            control:SetScript("OnLeave", A.traceCallback("UI.lua:1730:callback", function()
                label:SetTextColor(unpack(accent))
                GameTooltip:Hide()
            end))
            frame.memberSort = components.Attach(frame,control)
        end
        frame.tableCells[5]:Hide()
        frame.memberSort:Show()
    end
    local shade = index == 0 and 0.23 or index % 2 == 0 and 0.135 or 0.17
    frame.memberBackground:SetColorTexture(shade, shade * 0.76, shade * 0.68, 1)
    frame.memberBackground:Show()
    return frame
end)

local memberActions; memberActions = A.traceCallback("UI.lua:1745:memberActions", function(frame, id)
    if not frame.memberMenu then
        frame.memberMenu = components.Attach(frame,CreateFrame("Button", nil, frame))
        frame.memberMenu:SetAllPoints(frame)
        frame.memberMenu:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    end
    local db, character = A.db, A.self
    local currentMember; currentMember = A.traceCallback("UI.lua:1752:currentMember", function()
        if A.db == db and A.self == character and A.canManagePermissions(A.me) then return A.members[id] end
    end)
    frame.memberMenu:SetScript("OnEnter", A.traceCallback("UI.members.presenceTooltip", function(self)
        local member = currentMember()
        if not member then return end
        local presence, lastSeen = A.addonPresence(member)
        local report, current = A.memberAddonReport(member)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(member.name)
        GameTooltip:AddLine("Tártaro: " .. presenceLabels[presence], 1, 0.82, 0)
        GameTooltip:AddLine((member.id == A.self and "Versión instalada: " or "Última versión comunicada: ")
            .. ((member.id == A.self and A.addonVersion or report and report.version) or "Sin datos"), 0.96, 0.9, 0.82, true)
        if member.id == A.self then
            GameTooltip:AddLine("Tártaro está cargado en este personaje.", 0.96, 0.9, 0.82, true)
        elseif presence == "active" then
            GameTooltip:AddLine("Se recibió un mensaje de Tártaro en los últimos 150 segundos de esta sesión.", 0.96, 0.9, 0.82, true)
        elseif presence == "unconfirmed" then
            GameTooltip:AddLine("Personaje conectado; sin confirmación reciente de Tártaro en esta sesión. No demuestra desinstalación.", 0.96, 0.9, 0.82, true)
        elseif presence == "historical" then
            GameTooltip:AddLine("Tártaro fue detectado anteriormente. Su actividad actual no está confirmada.", 0.96, 0.9, 0.82, true)
        else
            GameTooltip:AddLine("Este cliente todavía no ha registrado mensajes de Tártaro de este personaje.", 0.96, 0.9, 0.82, true)
        end
        if type(lastSeen) == "number" then
            GameTooltip:AddLine((member.id == A.self and "Registro local: " or "Último mensaje recibido: ")
                .. date("%d/%m/%Y %H:%M:%S", lastSeen) .. " (hora local)", 0.96, 0.9, 0.82, true)
        end
        local overlord = report and report.overlord
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Overlord: " .. (overlord and presenceLabels.overlord[overlord.state] or "Sin datos"), 1, 0.82, 0)
        if overlord and overlord.state ~= "U" then
            if overlord.state ~= "N" then
                GameTooltip:AddLine("Versión: " .. (overlord.version or "No comunicada"), 0.96, 0.9, 0.82, true)
            end
            GameTooltip:AddLine(current and (member.id == A.self and "Comprobación local del cliente."
                or "Estado comunicado por el Tártaro de este personaje.")
                or "Dato histórico; el estado actual de Overlord no está confirmado.", 0.96, 0.9, 0.82, true)
        else
            GameTooltip:AddLine("Sin informe compatible de Overlord. No significa que no esté instalado.", 0.96, 0.9, 0.82, true)
        end
        if report and type(report.at) == "number" then
            GameTooltip:AddLine((member.id == A.self and "Comprobado: " or "Informe recibido: ")
                .. date("%d/%m/%Y %H:%M:%S", report.at) .. " (hora local)", 0.96, 0.9, 0.82, true)
        end
        GameTooltip:Show()
    end))
    frame.memberMenu:SetScript("OnLeave", A.traceCallback("UI.members.presenceTooltipLeave", function() GameTooltip:Hide() end))
    frame.memberMenu:SetScript("OnHide", A.traceCallback("UI.members.presenceTooltipHide", function(self)
        if GameTooltip:IsOwned(self) then GameTooltip:Hide() end
        self:SetScript("OnEnter",nil)
        self:SetScript("OnClick",nil)
    end))
    frame.memberMenu:SetScript("OnClick", A.traceCallback("UI.lua:1805:callback", function(owner)
        local member = currentMember()
        if not member or id == character then return end
        GameTooltip:Hide()
        MenuUtil.CreateContextMenu(owner, A.traceCallback("UI.lua:1809:callback", function(_, root)
            root:CreateTitle(member.name)
            local whisper = root:CreateButton("Susurrar", A.traceCallback("UI.lua:1811:callback", function()
                local target = currentMember()
                if target and target.online == true then openWhisperDraft(whisperTarget(target.name), "") end
            end))
            whisper:SetEnabled(member.online == true)
            invitationActions(root, currentMember, canInviteMember)
        end))
        if A.isDebugEnabled() then
            A.debugLog("observation", "member.menu", {id=id, online=member.online, invite=canInviteMember(member)})
        end
    end))
    frame.memberMenu:Show()
end)

local members; members = A.traceCallback("UI.lua:1825:members", function()
    if not A.canManagePermissions(A.me) then return end
    if detectedFirst ~= nil and A.isDebugEnabled() then A.debugLog("observation", "members.order", {detected=detectedFirst}) end
    local list = {}
    for _, member in pairs(A.members) do list[#list + 1] = member end
    table.sort(list, A.traceCallback("UI.lua:1830:callback", function(left, right)
        if detectedFirst ~= nil then
            local leftDetected, rightDetected = A.hasUsedAddon(left), A.hasUsedAddon(right)
            if leftDetected ~= rightDetected then return leftDetected == detectedFirst end
        end
        if (left.online == true) ~= (right.online == true) then return left.online == true end
        return left.name < right.name
    end))
    line("Miembros de la hermandad", accent)
    line("Orden actual: " .. (detectedFirst == nil and "conectados primero; luego, nombre."
        or detectedFirst and "detectados primero; luego, conexión y nombre."
        or "sin detectar primero; luego, conexión y nombre."))
    line("Pulsá un miembro para susurrar o invitar. Invitar en grupo requiere liderazgo.")
    line("Conexión informada por WoW. Pasá el mouse para ver versiones y fechas; Sin datos no implica que falte Overlord.")
    memberRow({"Personaje", "Nivel", "Rol", "Conexión", "Tártaro", "Overlord"}, 0)
    components.BeginTable()
    memberPresence = {}
    for index, member in ipairs(list) do
        local role = A.db.roles[member.id]
        local presence = A.addonPresence(member)
        local report, current = A.memberAddonReport(member)
        local overlord = report and report.overlord
        local overlordLabel
        if not overlord or overlord.state == "U" then overlordLabel = "Sin datos"
        else overlordLabel = current and presenceLabels.overlord[overlord.state] or "Histórico" end
        memberPresence[member.id] = presence .. (current and ":current" or ":historical")
        local connection = member.online == true and "Conectado"
            or member.online == false and "Desconectado" or "Sin datos"
        local frame = memberRow({
            member.name, member.level and tostring(member.level) or "-", A.roleLabel(role, member.class),
            connection, presenceLabels[presence], overlordLabel,
        }, index, role, member.online, presence == "active", member.class, current and overlord and overlord.state == "L")
        memberActions(frame, member.id)
    end
    if #list == 0 then line("Esperando la lista de la hermandad.") end
end)

local recipePage, selectedRecipe = 1, nil
local recipeFilters = {hideBound = false}
local pageSize = 8
local professionControls = CreateFrame("Frame", nil, win)
professionControls:SetPoint("TOPLEFT", 18 + sidebarWidth, -(headerHeight + 15))
professionControls:SetSize(570, 95)
professionControls:Hide()

local recipeSearch = CreateFrame("EditBox", nil, professionControls, "InputBoxTemplate")
recipeSearch:SetPoint("TOPLEFT", 6, -53)
recipeSearch:SetSize(218, 26)
recipeSearch:SetAutoFocus(false)
recipeSearch:SetMaxLetters(90)
recipeSearch:SetScript("OnEscapePressed", A.traceCallback("UI.lua:1880:callback", function(self) self:ClearFocus() end))
local recipeLabel = text(professionControls, "Receta, objeto o fabricante")
recipeLabel:SetPoint("TOPLEFT", 1, -34)
local professionButtons = {}
for index, option in ipairs({{"recipes", "Buscar recetas"}, {"orders", "Pedidos"},
    {"donations", "Listar Solicitud de Donacion"}}) do
    local key = option[1]
    local control = copperButton(professionControls)
    control:SetPoint("TOPLEFT", (index - 1) * 141, 0)
    control:SetSize(index == 3 and 282 or 133, 26)
    control:SetText(option[2])
    control:SetScript("OnClick", A.traceCallback("UI.lua:1891:callback", function()
        professionView = key
        recipeSearch:ClearFocus()
        scroll:SetVerticalScroll(0)
        A.refresh()
    end))
    professionButtons[key] = control
end
recipeSearch:SetScript("OnTextChanged", A.traceCallback("UI.lua:1899:callback", function()
    recipePage, selectedRecipe = 1, nil
    scroll:SetVerticalScroll(0)
    A.invalidate("recipes")
end))

local whisperRecipe; whisperRecipe = A.traceCallback("UI.lua:1905:whisperRecipe", function(member, recipe)
    openWhisperDraft(whisperTarget(member.name), "Hola, ¿me podrías fabricar " .. recipe .. "?")
end)

local sendGroupWhisper; sendGroupWhisper = A.traceCallback("UI.lua:1909:sendGroupWhisper", function(name, draft)
    local target = whisperTarget(name)
    local send = C_ChatInfo and C_ChatInfo.SendChatMessage or SendChatMessage
    local blocked = C_ChatInfo and C_ChatInfo.InChatMessagingLockdown and C_ChatInfo.InChatMessagingLockdown()
    if send and not blocked then
        local ok, result = A.debugPcall("UI.lua:1914:pcall", send, draft, "WHISPER", nil, target)
        if ok and result ~= false then return "Solicitud enviada" end
    end
    if openWhisperDraft(target, draft) then return "Borrador en el chat" end
end)

do
    local form = surface("TartaroActivityForm", 410, 275, 25)
    tinsert(UISpecialFrames, "TartaroActivityForm")
    form:SetFrameStrata("FULLSCREEN_DIALOG")
    local title = text(form, "", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -14)
    local inputs = {}
    for i = 1, 3 do
        local caption = text(form, "")
        caption:SetPoint("TOPLEFT", 16, -50 - (i - 1) * 48)
        local box = CreateFrame("EditBox", nil, form, "InputBoxTemplate")
        box:SetPoint("TOPLEFT", caption, "BOTTOMLEFT", 5, -4)
        box:SetSize(366, 23)
        box:SetAutoFocus(false)
        box:SetMaxLetters(55)
        box:SetScript("OnEscapePressed", A.traceCallback("UI.lua:1935:callback", function() form:Hide() end))
        inputs[i] = {caption, box}
    end
    local materials = CreateFrame("CheckButton", nil, form, "UICheckButtonTemplate")
    materials:SetPoint("TOPLEFT", 14, -100)
    local materialLabel = text(materials, "Ya tengo los materiales")
    materialLabel:SetPoint("LEFT", materials, "RIGHT", 2, 0)
    local reagents = CreateFrame("Frame", nil, form)
    reagents:SetPoint("TOPLEFT", 16, -137)
    reagents:SetSize(378, 152)
    local reagentTitle = text(reagents, "Materiales necesarios", "GameFontNormal")
    reagentTitle:SetPoint("TOPLEFT")
    local reagentScroll = CreateFrame("ScrollFrame", nil, reagents, "UIPanelScrollFrameTemplate")
    reagentScroll:SetPoint("TOPLEFT", 0, -21)
    reagentScroll:SetPoint("BOTTOMRIGHT", -24, 0)
    local reagentContent = CreateFrame("Frame", nil, reagentScroll)
    reagentContent:SetSize(350, 1)
    reagentScroll:SetScrollChild(reagentContent)
    local reagentText = text(reagentContent, "")
    reagentText:SetPoint("TOPLEFT")
    reagentText:SetWidth(346)
    local errorText = text(form, "")
    errorText:SetPoint("BOTTOMLEFT", 16, 56)
    errorText:SetWidth(375)
    errorText:SetTextColor(1, 0.62, 0.45)
    local publish = copperButton(form)
    publish:SetSize(154, 28)
    publish:SetPoint("BOTTOMRIGHT", -16, 14)
    publish:SetText("Publicar")
    publish:SetStyle(false, true)
    local groupControls = CreateFrame("Frame", nil, form)
    groupControls:SetAllPoints()
    groupControls:Hide()
    local categoryLabel = text(groupControls, "Tipo de actividad")
    categoryLabel:SetPoint("TOPLEFT", 16, -50)
    local categoryButton = copperButton(groupControls)
    categoryButton:SetPoint("TOPLEFT", 16, -70)
    categoryButton:SetSize(376, 27)
    local destinationLabel = text(groupControls, "Destino")
    destinationLabel:SetPoint("TOPLEFT", 16, -112)
    local destinationButton = copperButton(groupControls)
    destinationButton:SetPoint("TOPLEFT", 16, -132)
    destinationButton:SetSize(376, 27)
    destinationButton:SetText("Seleccionar destino")
    destinationButton:GetFontString():SetWidth(352)
    destinationButton:GetFontString():SetMaxLines(1)
    local description = CreateFrame("EditBox", nil, groupControls, "InputBoxTemplate")
    description:SetPoint("TOPLEFT", 22, -132)
    description:SetSize(366, 25)
    description:SetAutoFocus(false)
    description:SetMaxLetters(55)
    description:SetScript("OnEscapePressed", A.traceCallback("UI.lua:1986:callback", function() form:Hide() end))
    local destinationStatus = text(groupControls, "")
    destinationStatus:SetPoint("TOPLEFT", 16, -165)
    destinationStatus:SetWidth(376)
    local needsTitle = text(groupControls, "Jugadores que faltan · Vacío o 0 = ninguno")
    needsTitle:SetPoint("TOPLEFT", 16, -250)
    local needsFields = {}
    for index, role in ipairs(A.eventRoleOrder) do
        local label = text(groupControls, A.eventRoles[role])
        label:SetPoint("TOPLEFT", 16 + (index - 1) * 127, -272)
        local input = CreateFrame("EditBox", nil, groupControls, "InputBoxTemplate")
        input:SetPoint("TOPLEFT", 22 + (index - 1) * 127, -292)
        input:SetSize(108, 24)
        input:SetAutoFocus(false)
        input:SetNumeric(true)
        input:SetMaxLetters(2)
        input:SetScript("OnEscapePressed", A.traceCallback("UI.lua:2002:callback", function() form:Hide() end))
        needsFields[index] = input
    end
    local selectedCategory, selectedDestination
    local syncGroupControls; syncGroupControls = A.traceCallback("UI.lua:2006:syncGroupControls", function()
        local category = A.groupCategory(selectedCategory)
        local other = selectedCategory == "OTHER"
        categoryButton:SetText(category.label)
        categoryButton:SetStyle(false)
        destinationLabel:SetText(other and "Actividad" or "Destino")
        destinationButton:SetShown(not other)
        description:SetShown(other)
        destinationButton:SetText("Seleccionar destino")
        destinationButton:SetStyle(false)
        if other then destinationStatus:SetText(""); return end
        local list = A.groupDestinations(selectedCategory)
        local selected
        for _, entry in ipairs(list) do
            if entry.id == selectedDestination then selected = entry; break end
        end
        if selected then destinationButton:SetText(selected.name)
        else selectedDestination = nil end
        destinationStatus:SetText(selectedCategory == "BG" and selected and selected.maximum
            and ("Máximo de la BG: " .. selected.maximum .. " jugadores.")
            or #list == 0 and (selectedCategory == "QUEST" and "No hay misiones disponibles en tu diario."
                or "El cliente no ofrece destinos ahora. Abrí el buscador del juego y volvé a intentar.")
            or "Destinos disponibles según el cliente.")
    end)
    categoryButton:SetScript("OnClick", A.traceCallback("UI.lua:2030:callback", function(owner)
        MenuUtil.CreateContextMenu(owner, A.traceCallback("UI.lua:2031:callback", function(_, root)
            root:CreateTitle("Tipo de actividad")
            for _, category in ipairs(A.groupCategories) do
                local key = category.key
                root:CreateRadio(category.label, A.traceCallback("UI.lua:2035:callback", function() return selectedCategory == key end), A.traceCallback("UI.lua:2035:callback", function()
                    if selectedCategory ~= key then
                        selectedCategory, selectedDestination = key, nil
                        description:SetText("")
                    end
                    syncGroupControls()
                end))
            end
        end))
    end))
    destinationButton:SetScript("OnClick", A.traceCallback("UI.lua:2045:callback", function(owner)
        syncGroupControls()
        local list = A.groupDestinations(selectedCategory)
        MenuUtil.CreateContextMenu(owner, A.traceCallback("UI.lua:2048:callback", function(_, root)
            root:CreateTitle(A.groupCategory(selectedCategory).label)
            if root.SetScrollMode then root:SetScrollMode(260) end
            if #list == 0 then root:CreateTitle("Sin destinos disponibles") end
            for _, entry in ipairs(list) do
                local id = entry.id
                root:CreateRadio(entry.name, A.traceCallback("UI.lua:2054:callback", function() return selectedDestination == id end), A.traceCallback("UI.lua:2054:callback", function()
                    selectedDestination = id
                    syncGroupControls()
                end))
            end
        end))
    end))
    local recipe, guild, editingGroup
    local updateReagents; updateReagents = A.traceCallback("UI.lua:2062:updateReagents", function()
        if not recipe or A.db ~= guild or not form:IsShown() then return end
        local quantity = tonumber(inputs[1][2]:GetText())
        local list = A.recipeMaterials(recipe.spell)
        local rows = {}
        if not quantity or quantity % 1 ~= 0 or quantity < 1 or quantity > 999 then
            rows[1] = "Ingresá una cantidad de 1 a 999."
        elseif not list then
            rows[1] = "Esperando los datos de materiales de la receta."
        elseif not next(list) then
            rows[1] = "Sin materiales registrados."
        else
            for item, count in pairs(list) do
                local name = A.professionItem(item) or ("Objeto " .. item)
                rows[#rows + 1] = ("%s × %d"):format(name, count * quantity)
            end
            table.sort(rows)
        end
        reagentText:SetText(table.concat(rows, "\n"))
        reagentContent:SetHeight(math.max(1, reagentText:GetStringHeight() + 4))
    end)
    form.updateReagents = updateReagents
    inputs[1][2]:SetScript("OnTextChanged", updateReagents)
    form:SetScript("OnShow", updateReagents)
    local openForm; openForm = A.traceCallback("UI.lua:2086:openForm", function(selected, group)
        if not A.db then return end
        recipe, guild, editingGroup = selected, A.db, group
        title:SetText(recipe and ("Pedir " .. (recipe.object or recipe.name)) or "Estoy armando grupo")
        if group then title:SetText("Editar búsqueda de grupo") end
        needsTitle:SetText(group and group.slots and "Cupos por rol · Incluyen jugadores ya anotados"
            or "Jugadores que faltan · Vacío o 0 = ninguno")
        publish:SetText(group and "Guardar cambios" or "Publicar")
        title:SetWidth(350)
        title:SetMaxLines(2)
        local captions = recipe and {"Cantidad"} or {[2] = "Lugar"}
        inputs[2][1]:ClearAllPoints()
        inputs[2][1]:SetPoint("TOPLEFT", 16, -199)
        inputs[1][2]:SetNumeric(recipe ~= nil)
        inputs[1][2]:SetMaxLetters(recipe and 3 or 55)
        for i, input in ipairs(inputs) do
            input[1]:SetShown(captions[i] ~= nil)
            input[2]:SetShown(captions[i] ~= nil)
            input[1]:SetText(captions[i] or "")
            input[2]:SetText(recipe and i == 1 and "1" or "")
        end
        materials:SetShown(recipe ~= nil)
        groupControls:SetShown(recipe == nil)
        if not recipe then
            selectedCategory, selectedDestination = "DUNGEON", nil
            description:SetText("")
            for _, input in ipairs(needsFields) do input:SetText("") end
            if group then
                local selection = group.selection
                selectedCategory, selectedDestination = selection.category, selection.destination
                description:SetText(selection.description or "")
                inputs[2][2]:SetText(group.location)
                for i, input in ipairs(needsFields) do input:SetText(tostring(selection.counts[i])) end
            end
            syncGroupControls()
        end
        reagents:SetShown(recipe ~= nil)
        reagentScroll:SetVerticalScroll(0)
        materials:SetChecked(false)
        errorText:SetText("")
        form:SetHeight(recipe and 378 or 408)
        form:Show()
        updateReagents()
        form:Raise()
    end)
    A.openOrderForm = A.traceCallback("UI.lua:2131:A.openOrderForm", function(recipe) openForm(recipe) end)
    A.openGroupForm = A.traceCallback("UI.lua:2132:A.openGroupForm", function() openForm() end)
    A.editGroupForm = A.traceCallback("UI.lua:2133:A.editGroupForm", function(group) openForm(nil, group) end)
    publish:SetScript("OnClick", A.traceCallback("UI.lua:2134:callback", function()
        if A.db ~= guild then form:Hide(); return end
        local ok, err
        if recipe then
            ok, err = A.createOrder(recipe, inputs[1][2]:GetText(), materials:GetChecked() and true or false)
        else
            ok, err = A.publishGroupSelection(selectedCategory, selectedDestination, description:GetText(),
                inputs[2][2]:GetText(), needsFields[1]:GetText(), needsFields[2]:GetText(), needsFields[3]:GetText(), editingGroup)
        end
        if not ok then errorText:SetText(err or "No se pudo publicar."); return end
        if recipe then
            professionView = "orders"
            scroll:SetVerticalScroll(0)
        elseif not editingGroup then
            announceGroup(ok)
        end
        form:Hide()
        A.refresh()
    end))
    form:SetScript("OnHide", A.traceCallback("UI.lua:2153:callback", function()
        for _, input in ipairs(inputs) do input[2]:ClearFocus() end
        description:ClearFocus()
        for _, input in ipairs(needsFields) do input:ClearFocus() end
    end))
end

do
    local form = surface("TartaroDonationForm", 440, 305, 25)
    form:SetFrameStrata("FULLSCREEN_DIALOG")
    tinsert(UISpecialFrames, "TartaroDonationForm")
    local heading = text(form, "Solicitar donación", "GameFontNormalLarge")
    heading:SetPoint("TOPLEFT", 16, -18)
    local caption = text(form, "Material seleccionado")
    caption:SetPoint("TOPLEFT", 16, -58)
    local link = text(form, "")
    link:SetPoint("TOPLEFT", 22, -80)
    link:SetSize(394, 26)
    link:SetMaxLines(2)
    local amountCaption = text(form, "Cantidad solicitada")
    amountCaption:SetPoint("TOPLEFT", 16, -125)
    local quantity = CreateFrame("EditBox", nil, form, "InputBoxTemplate")
    quantity:SetPoint("TOPLEFT", 22, -147)
    quantity:SetSize(130, 26)
    quantity:SetAutoFocus(false)
    quantity:SetMaxLetters(7)
    quantity:SetNumeric(true)
    local status = text(form, "")
    status:SetPoint("TOPLEFT", 16, -192)
    status:SetWidth(405)
    local publish = copperButton(form)
    publish:SetText("Publicar solicitud")
    publish:SetStyle(false, true)
    publish:SetSize(190, 28)
    publish:SetPoint("BOTTOMRIGHT", -16, 15)
    local guild, selectedItem
    local identify; identify = A.traceCallback("UI.lua:2189:identify", function()
        if not selectedItem then return end
        link:SetText(A.professionItem(selectedItem) or ("Material " .. selectedItem))
        local valid, err = A.donationMaterial(selectedItem)
        status:SetText(valid and ((A.professionItem(selectedItem) or "Material") .. " · Vence en 7 días.") or err)
    end)
    quantity:SetScript("OnEscapePressed", A.traceCallback("UI.lua:2195:callback", function() form:Hide() end))
    form:SetScript("OnHide", A.traceCallback("UI.lua:2196:callback", function()
        quantity:ClearFocus()
        if not form.resumeAfterCombat and guild and A.db == guild then win:Show(); A.refresh() end
    end))
    A.openDonationForm = A.traceCallback("UI.lua:2200:A.openDonationForm", function(item)
        if not A.db or combatWindowsBlocked() or type(item) ~= "number" or item <= 0 or item % 1 ~= 0 then return end
        guild = A.db
        editor:Hide()
        TartaroActivityForm:Hide()
        selectedItem = item
        quantity:SetText("1")
        identify()
        win:Hide()
        form:Show()
        form:Raise()
        if A.isDebugEnabled() then
            A.debugLog("observation", "donation.open", {item=item, shown=form:IsShown(), quantity=tonumber(quantity:GetText())})
        end
    end)
    A.closeDonationForm = A.traceCallback("UI.lua:2215:A.closeDonationForm", function()
        form.resumeAfterCombat = nil
        guild, selectedItem = nil, nil
        form:Hide()
    end)
    A.updateDonationCombat = A.traceCallback("UI.lua:2220:A.updateDonationCombat", function(blocked)
        if blocked then
            if form:IsShown() then form.resumeAfterCombat = true; form:Hide() end
        elseif form.resumeAfterCombat then
            form.resumeAfterCombat = nil
            if A.db and A.db == guild then form:Show() end
        end
    end)
    publish:SetScript("OnClick", A.traceCallback("UI.lua:2228:callback", function()
        if not guild or A.db ~= guild then A.closeDonationForm(); return end
        local request, err = A.createDonation(selectedItem, quantity:GetText())
        if not request then status:SetText(err); return end
        form:Hide()
        professionView = "donations"
        scroll:SetVerticalScroll(0)
        A.refresh()
    end))
    local events = CreateFrame("Frame")
    events:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    events:SetScript("OnEvent", A.traceCallback("UI.lua:2239:callback", function()
        if form:IsShown() and A.db == guild then identify() end
        if A.db then A.invalidate("donations") end
    end))
end

local callPopup = surface("TartaroCallNotification", 386, 146, 0)
callPopup:SetFrameStrata("FULLSCREEN_DIALOG")
callPopup:SetBackdropColor(0.095, 0.075, 0.078, 1)
callPopup:ClearAllPoints()
callPopup:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -34, -112)
local callMoved
callPopup:HookScript("OnDragStop", A.traceCallback("UI.lua:2251:callback", function() callMoved = true end))

local positionCall; positionCall = A.traceCallback("UI.lua:2253:positionCall", function()
    if not callMoved then positionNotice(callPopup, 34, 112, true) end
end)

win:HookScript("OnDragStop", A.traceCallback("UI.lua:2257:callback", function()
    if callPopup:IsShown() then positionCall() end
end))
local callHeading = text(callPopup, "Llamado a las armas", "GameFontNormalLarge")
callHeading:SetPoint("TOPLEFT", 16, -16)
local callBody = text(callPopup, "")
callBody:SetPoint("TOPLEFT", 16, -42)
callBody:SetWidth(342)
local callMap = copperButton(callPopup)
callMap:SetSize(139, 27)
callMap:SetPoint("BOTTOMLEFT", 16, 13)
callMap:SetText("Ver en el mapa")
callMap:SetStyle(false)
local requestGroup = copperButton(callPopup)
requestGroup:SetSize(166, 27)
requestGroup:SetPoint("BOTTOMRIGHT", -16, 13)
local visibleCall

local currentCall; currentCall = A.traceCallback("UI.lua:2275:currentCall", function()
    if not visibleCall or A.calls[visibleCall.author] ~= visibleCall or visibleCall.expires <= GetServerTime() then return end
    if not A.can(A.members[visibleCall.author], "call") then return end
    return visibleCall
end)

local updateRequestButton; updateRequestButton = A.traceCallback("UI.lua:2281:updateRequestButton", function(call)
    local own = call.author == A.self
    requestGroup:SetText(own and "Cerrar llamado" or call.requestState or "Pedir grupo")
    requestGroup:SetEnabled(own or not call.requestState)
    requestGroup:SetStyle(false, own or not call.requestState)
end)

local callMessage; callMessage = A.traceCallback("UI.lua:2288:callMessage", function(call, separator)
    return call.name .. " pide refuerzos para PvP de mundo." .. separator .. A.callLocation(call)
end)

A.showCall = A.traceCallback("UI.lua:2292:A.showCall", function(call)
    if IsInInstance() then return end
    visibleCall = call
    if not currentCall() or combatWindowsBlocked() then return end
    callBody:SetText(callMessage(call, "\n"))
    callPopup:SetHeight(math.max(144, callBody:GetStringHeight() + 91))
    updateRequestButton(call)
    callPopup:Show()
    positionCall()
    callPopup:Raise()
end)

local callZone = CreateFrame("Frame")
callZone:RegisterEvent("PLAYER_ENTERING_WORLD")
callZone:RegisterEvent("ZONE_CHANGED_NEW_AREA")
callZone:SetScript("OnEvent", A.traceCallback("UI.lua:2307:callback", function()
    if IsInInstance() then
        visibleCall = nil
        callPopup:Hide()
        A.stopCallAlert()
    end
end))

callMap:SetScript("OnClick", A.traceCallback("UI.lua:2315:callback", function()
    local call = currentCall()
    if call then A.openCallMap(call) end
end))

requestGroup:SetScript("OnClick", A.traceCallback("UI.lua:2320:callback", function()
    local call = currentCall()
    if not call then return end
    if call.author == A.self then A.closeCall(call); return end
    if call.requestState then return end
    local tracked = A.send("CTJ", call.author, call.when)
    local draft = "Me sumo al PvP de mundo en " .. A.callLocation(call) .. ". ¿Me invitás al grupo?"
    call.requestState = sendGroupWhisper(call.name, draft)
    if not call.requestState and tracked then call.requestState = "Solicitud registrada" end
    updateRequestButton(call)
end))

C_Timer.NewTicker(1, A.traceCallback("UI.lua:2332:callback", function()
    if callPopup:IsShown() and not currentCall() then callPopup:Hide() end
end))

StaticPopupDialogs["TARTARO_CONFIRM_CALL"] = {
    whileDead = true,
    text = "¿Pedir refuerzos para PvP de mundo en %s?",
    button1 = "Lanzar llamado",
    button2 = "Cancelar",
    timeout = 0,
    hideOnEscape = true,
    OnAccept = A.traceCallback("UI.lua:2343:callback", function(_, data)
        if A.db ~= data.db then return end
        local success, err = A.sendCall(data.position)
        if not success then print("Tártaro: " .. err); return end
        local call = A.calls[A.self]
        A.showCall(call)
        announceGuild(callMessage(call, " "), "El llamado se publicó en Tártaro.")
        A.refresh()
    end),
}

A.confirmCall = A.traceCallback("UI.lua:2354:A.confirmCall", function()
    local position, err = A.prepareCall()
    if not position then print("Tártaro: " .. err); return end
    local location = A.callLocation(position)
    if position.corpse then location = "la ubicación de tu cadáver: " .. location end
    StaticPopup_Show("TARTARO_CONFIRM_CALL", location, nil, {db = A.db, position = position})
end)

local callLauncher = CreateFrame("Button", "TartaroCallLauncher", UIParent, "UIPanelButtonTemplate")
callLauncher:SetFrameStrata("HIGH")
callLauncher:SetSize(252, 42)
do
    local label = callLauncher:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    label:SetPoint("CENTER", 0, 1)
    label:SetWidth(228)
    label:SetMaxLines(1)
    label:SetJustifyH("CENTER")
    label:SetShadowColor(0, 0, 0, 1)
    label:SetShadowOffset(1, -1)
    callLauncher:SetFontString(label)
    callLauncher:SetNormalFontObject(GameFontNormalLarge)
    callLauncher:SetHighlightFontObject(GameFontNormalLarge)
    callLauncher:SetDisabledFontObject(GameFontDisable)
    local blades = "|TInterface\\AddOns\\Tartaro\\CallSwords:18:18|t"
    callLauncher:SetText(blades .. " Llamado a las Armas " .. blades)

    local rim = CreateFrame("Frame", nil, callLauncher, "BackdropTemplate")
    rim:SetPoint("TOPLEFT", -3, 3)
    rim:SetPoint("BOTTOMRIGHT", 3, -3)
    rim:SetBackdrop({edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", edgeSize=16})
    rim:SetBackdropBorderColor(0.85, 0.66, 0.34, 1)
    rim:EnableMouse(false)
end
callLauncher.ResetPosition = A.traceCallback("UI.lua:2387:callLauncher:ResetPosition", function(self)
    self:ClearAllPoints()
    if Minimap:IsVisible() then
        self:SetPoint("TOP", Minimap, "BOTTOM", 0, -9)
    else
        self:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -24, -180)
    end
end)
callLauncher:ResetPosition()
callLauncher:SetFrameLevel(Minimap:GetFrameLevel() + 8)
callLauncher:SetMovable(true)
callLauncher:SetClampedToScreen(true)
callLauncher:RegisterForClicks("LeftButtonUp")
callLauncher:RegisterForDrag("LeftButton")
callLauncher:Hide()

do
    local dragged, moving
    local place; place = A.traceCallback("UI.lua:2405:place", function(x, y)
        local scale = UIParent:GetEffectiveScale() / callLauncher:GetEffectiveScale()
        callLauncher:ClearAllPoints()
        callLauncher:SetPoint("CENTER", UIParent, "BOTTOMLEFT",
            x * UIParent:GetWidth() * scale, y * UIParent:GetHeight() * scale)
    end)
    A.setCallLauncherSize = A.traceCallback("UI.setCallLauncherSize", function(value)
        if not TartaroDB then return end
        local percent = A.callLauncherSize(value)
        TartaroDB.callLauncherSize = percent
        callLauncher:SetScale(percent / 100)
        local saved = TartaroDB.callLauncherPosition
        if type(saved) == "table" and type(saved.x) == "number" and type(saved.y) == "number"
            and saved.x >= 0 and saved.x <= 1 and saved.y >= 0 and saved.y <= 1 then
            place(saved.x, saved.y)
        end
        if A.isDebugEnabled() then
            A.debugLog("appearance.scale", "UI.callLauncher", percent, callLauncher:GetScale())
        end
        return percent
    end)

    local stopDrag; stopDrag = A.traceCallback("UI.lua:2427:stopDrag", function(self)
        if not moving then return end
        moving = false
        self:StopMovingOrSizing()
        self:SetUserPlaced(false)
        local x, y = self:GetCenter()
        local left, bottom, width, height = UIParent:GetRect()
        if not x or not y or not left or not bottom or not width or not height or width <= 0 or height <= 0 then return end
        local scale = self:GetEffectiveScale() / UIParent:GetEffectiveScale()
        x = math.max(0, math.min(1, (x * scale - left) / width))
        y = math.max(0, math.min(1, (y * scale - bottom) / height))
        TartaroDB.callLauncherPosition = {x = x, y = y}
        place(x, y)
    end)

    callLauncher:RegisterEvent("PLAYER_LOGIN")
    callLauncher:RegisterEvent("PLAYER_ENTERING_WORLD")
    callLauncher:SetScript("OnEvent", A.traceCallback("UI.lua:2444:callback", function()
        A.setCallLauncherSize(A.callLauncherSize())
        callLauncher:SetShown(A.can(A.me, "call"))
    end))
    callLauncher:SetScript("OnMouseDown", A.traceCallback("UI.lua:2448:callback", function() dragged = false end))
    callLauncher:SetScript("OnDragStart", A.traceCallback("UI.lua:2449:callback", function(self)
        dragged, moving = true, true
        self:StartMoving()
    end))
    callLauncher:SetScript("OnDragStop", stopDrag)
    callLauncher:SetScript("OnHide", stopDrag)
    callLauncher:SetScript("OnClick", A.traceCallback("UI.lua:2455:callback", function()
        if not dragged then A.confirmCall() end
    end))
end

local memberOrder; memberOrder = A.traceCallback("UI.lua:2460:memberOrder", function(left, right)
    if (left.online == true) ~= (right.online == true) then return left.online == true end
    return left.name < right.name
end)

local professionMembers; professionMembers = A.traceCallback("UI.lua:2465:professionMembers", function()
    local members = {}
    for id, profile in pairs(A.db.professions) do
        local member = A.members[id]
        if member and next(profile.list) then members[#members + 1] = member end
    end
    table.sort(members, memberOrder)
    return members
end)

local level; level = A.traceCallback("UI.lua:2475:level", function(profession)
    return profession.rank .. "/" .. profession.maximum
end)

local connection; connection = A.traceCallback("UI.lua:2479:connection", function(member)
    if member.id == A.self or member.online == true then return "En línea" end
    return member.online == false and "Desconectado" or "Estado desconocido"
end)

local rarityNames = {
    [0] = "Pobre", [1] = "Común", [2] = "Poco común", [3] = "Raro", [4] = "Épico", [5] = "Legendario",
}
local filters = {}
local refreshFilters; refreshFilters = A.traceCallback("UI.lua:2488:refreshFilters", function()
    recipePage, selectedRecipe = 1, nil
    scroll:SetVerticalScroll(0)
    A.refresh()
end)

local addRecipeFilter; addRecipeFilter = A.traceCallback("UI.lua:2494:addRecipeFilter", function(x, width, label, callback)
    local control = copperButton(professionControls)
    control:SetPoint("TOPLEFT", x, -53)
    control:SetSize(width, 26)
    control:SetText(label)
    control:GetFontString():SetWidth(width - 8)
    control:GetFontString():SetMaxLines(1)
    control:SetStyle(false)
    control:SetScript("OnClick", callback)
    filters[#filters + 1] = control
    return control
end)

local filterMenu; filterMenu = A.traceCallback("UI.lua:2507:filterMenu", function(owner, title, options, field)
    MenuUtil.CreateContextMenu(owner, A.traceCallback("UI.lua:2508:callback", function(_, root)
        root:CreateTitle(title)
        if root.SetScrollMode and #options > 9 then root:SetScrollMode(240) end
        root:CreateRadio(options.all, A.traceCallback("UI.lua:2511:callback", function() return recipeFilters[field] == nil end), A.traceCallback("UI.lua:2511:callback", function()
            recipeFilters[field], recipeFilters[field .. "Label"] = nil, nil
            refreshFilters()
        end))
        for _, option in ipairs(options) do
            local value, label = option[1], option[2]
            root:CreateRadio(label, A.traceCallback("UI.lua:2517:callback", function() return recipeFilters[field] == value end), A.traceCallback("UI.lua:2517:callback", function()
                recipeFilters[field], recipeFilters[field .. "Label"] = value, label
                refreshFilters()
            end))
        end
    end))
end)

local memberFilter = addRecipeFilter(235, 117, "Todos los miembros", A.traceCallback("UI.lua:2525:callback", function(self)
    local options = {all = "Todos los miembros", {"online", "En línea"}, {"offline", "Desconectados"}}
    for _, member in ipairs(professionMembers()) do options[#options + 1] = {member.id, member.name} end
    filterMenu(self, "Fabricantes", options, "member")
end))
local professionFilter = addRecipeFilter(362, 168, "Todas las profesiones", A.traceCallback("UI.lua:2530:callback", function(self)
    local options, names = {all = "Todas las profesiones"}, {}
    for _, member in ipairs(professionMembers()) do
        for id, prof in pairs(A.db.professions[member.id].list) do
            if prof.recipes and next(prof.recipes) then names[id] = names[id] or prof.name end
        end
    end
    for id, name in pairs(names) do options[#options + 1] = {id, name} end
    table.sort(options, A.traceCallback("UI.lua:2538:callback", function(left, right) return left[2] < right[2] end))
    filterMenu(self, "Profesión", options, "profession")
end))
local rarityFilter = addRecipeFilter(540, 130, "Todas las rarezas", A.traceCallback("UI.lua:2541:callback", function(self)
    local options = {all = "Todas las rarezas"}
    for rarity = 0, 5 do options[#options + 1] = {rarity, rarityNames[rarity]} end
    filterMenu(self, "Rareza", options, "rarity")
end))
local boundFilter = addRecipeFilter(680, 86, "Ocultar BoP", A.traceCallback("UI.lua:2546:callback", function()
    recipeFilters.hideBound = not recipeFilters.hideBound
    refreshFilters()
end))
addRecipeFilter(776, 68, "Limpiar", A.traceCallback("UI.lua:2550:callback", function()
    recipeFilters = {hideBound = false}
    recipeSearch:SetText("")
    refreshFilters()
end))

local recipeList = CreateFrame("Frame", nil, win)
recipeList:SetPoint("TOPLEFT", 18 + sidebarWidth, -(headerHeight + 104))
recipeList:SetPoint("BOTTOMRIGHT", win, "BOTTOMLEFT", 420 + sidebarWidth, 17)
recipeList:Hide()
local leftHeading = text(recipeList, "Recetas", "GameFontNormal")
leftHeading:SetPoint("TOPLEFT", 4, -1)
local pageLabel = text(recipeList, "")
pageLabel:SetPoint("BOTTOMLEFT", 4, 9)
local listDivider = recipeList:CreateTexture(nil, "ARTWORK")
listDivider:SetPoint("TOPRIGHT", 2, 0)
listDivider:SetPoint("BOTTOMRIGHT", 2, 0)
listDivider:SetWidth(1)
listDivider:SetColorTexture(0.35, 0.24, 0.20, 1)
local recipeRows, pages = {}, 0

local changePage; changePage = A.traceCallback("UI.lua:2571:changePage", function(delta)
    recipePage = math.max(1, math.min(pages, recipePage + delta))
    selectedRecipe = nil
    scroll:SetVerticalScroll(0)
    A.refresh()
end)

local pageButton; pageButton = A.traceCallback("UI.lua:2578:pageButton", function(label, offset, delta)
    local control = copperButton(recipeList)
    control:SetSize(34, 24)
    control:SetPoint("BOTTOMRIGHT", offset, 2)
    control:SetText(label)
    control:SetStyle(false)
    control:SetScript("OnClick", A.traceCallback("UI.lua:2584:callback", function() changePage(delta) end))
    return control
end)
local previousPage, nextPage = pageButton("<", -55, -1), pageButton(">", -14, 1)

local itemHover; itemHover = A.traceCallback("UI.lua:2589:itemHover", function(frame, item)
    if not item or item == 0 then return end
    GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink("item:" .. item)
    GameTooltip:Show()
    if A.isDebugEnabled() then
        A.debugLog("tooltip.item", "UI.itemHover", item, GameTooltip:IsShown())
    end
end)

local recipeRow; recipeRow = A.traceCallback("UI.lua:2599:recipeRow", function(index, result)
    local control = recipeRows[index]
    if not control then
        control = copperButton(recipeList)
        control:SetPoint("TOPLEFT", 3, -21 - (index - 1) * 38)
        control:SetPoint("TOPRIGHT", -13, -21 - (index - 1) * 38)
        control:SetHeight(35)
        control.icon = control:CreateTexture(nil, "ARTWORK")
        control.icon:SetPoint("LEFT", 5, 0)
        control.icon:SetSize(24, 24)
        control.name = text(control, "")
        control.name:SetPoint("TOPLEFT", 35, -6)
        control.name:SetPoint("TOPRIGHT", -126, -6)
        control.name:SetMaxLines(1)
        control.summary = text(control, "", "GameFontHighlightSmall")
        control.summary:SetPoint("BOTTOMLEFT", 35, 5)
        control.profession = text(control, "", "GameFontHighlightSmall")
        control.profession:SetPoint("TOPRIGHT", -8, -6)
        control.profession:SetWidth(118)
        control.profession:SetJustifyH("RIGHT")
        control.profession:SetMaxLines(1)
        control.online = text(control, "", "GameFontHighlightSmall")
        control.online:SetPoint("BOTTOMRIGHT", -8, 5)
        control.summary:SetMaxLines(1)
        control:SetText(" ")
        control:SetScript("OnEnter", A.traceCallback("UI.lua:2624:callback", function(self) itemHover(self, self.item) end))
        control:SetScript("OnLeave", A.traceCallback("UI.lua:2625:callback", function() GameTooltip:Hide() end))
        recipeRows[index] = control
    end
    control.recipeSpell = result.spell
    control:SetStyle(selectedRecipe == result.spell)
    local spellTexture = C_Spell and C_Spell.GetSpellTexture
    control.icon:SetTexture(result.icon or (spellTexture and spellTexture(result.spell)) or "Interface\\Icons\\INV_Misc_QuestionMark")
    control.name:SetText(result.object or result.name)
    control.summary:SetText(#result.crafters .. (#result.crafters == 1 and " fabricante" or " fabricantes"))
    control.profession:SetText(result.profession)
    control.online:SetText(result.online > 0 and (result.online .. " en línea") or "Desconectados")
    if result.online > 0 then control.online:SetTextColor(0.46, 0.77, 0.53) else control.online:SetTextColor(0.72, 0.68, 0.65) end
    control.item = result.item
    control:SetScript("OnClick", A.traceCallback("UI.lua:2638:callback", function()
        selectedRecipe = result.spell
        scroll:SetVerticalScroll(0)
        A.refresh("recipeDetail")
    end))
    control:Show()
end)

local updatePage; updatePage = A.traceCallback("UI.lua:2646:updatePage", function(first, last, count)
    for index = last - first + 2, #recipeRows do recipeRows[index]:Hide() end
    pageLabel:SetText(count > 0 and (first .. "-" .. last .. " de " .. count .. " recetas") or "Sin recetas")
    previousPage:SetEnabled(recipePage > 1 and count > 0)
    nextPage:SetEnabled(recipePage < pages and count > 0)
end)

local recipeDetail; recipeDetail = A.traceCallback("UI.lua:2653:recipeDetail", function(title, subtitle, texture, item, action, color, actionLabel)
    local frame = row()
    if not frame.detail then
        local detail = CreateFrame("Frame", nil, frame)
        detail:SetAllPoints()
        detail.background = detail:CreateTexture(nil, "BACKGROUND")
        detail.background:SetAllPoints()
        detail.background:SetColorTexture(1, 0.85, 0.68, 0.055)
        detail.icon = detail:CreateTexture(nil, "ARTWORK")
        detail.icon:SetSize(23, 23)
        detail.icon:SetPoint("LEFT", 7, 0)
        detail.name = text(detail, "")
        detail.name:SetMaxLines(1)
        detail.meta = text(detail, "", "GameFontHighlightSmall")
        detail.meta:SetPoint("RIGHT", -9, 0)
        detail.action = copperButton(detail)
        detail.action:SetPoint("RIGHT", -7, 0)
        detail.action:SetSize(88, 23)
        detail.action:SetText("Susurrar")
        detail.action:SetStyle(false)
        detail:SetScript("OnHide", A.traceCallback("UI.recipeDetail.release", function(self)
            self.action:SetScript("OnClick",nil)
            self.item = nil
        end))
        detail:SetScript("OnEnter", A.traceCallback("UI.lua:2677:callback", function(self) itemHover(self, self.item) end))
        detail:SetScript("OnLeave", A.traceCallback("UI.lua:2678:callback", function() GameTooltip:Hide() end))
        frame.detail = components.Attach(frame,detail)
    end
    local detail = frame.detail
    detail.icon:SetTexture(texture)
    detail.icon:SetShown(texture ~= nil)
    detail.name:ClearAllPoints()
    detail.name:SetPoint("LEFT", texture and 37 or 8, 0)
    detail.name:SetPoint("RIGHT", action and -210 or subtitle and subtitle ~= "" and -100 or -9, 0)
    detail.name:SetText(title)
    detail.name:SetTextColor(unpack(color or {0.96, 0.90, 0.82}))
    detail.meta:ClearAllPoints()
    detail.meta:SetPoint("RIGHT", action and -105 or -9, 0)
    detail.meta:SetText(subtitle or "")
    detail.action:SetShown(action ~= nil)
    detail.action:SetText(actionLabel or "Susurrar")
    detail.action:SetScript("OnClick", action)
    detail.item = item
    detail:EnableMouse(item ~= nil and item > 0)
    frame:SetHeight(28)
    detail:Show()
    layout.y = layout.y + 31
end)

local renderRecipeDetails; renderRecipeDetails = A.traceCallback("UI.lua:2702:renderRecipeDetails", function(selected)
    recipeDetail(selected.object or selected.name, "", selected.icon, selected.item, nil, accent)
    line(selected.profession)
    button("Lo necesito fabricar", A.traceCallback("UI.lua:2705:callback", function() A.openOrderForm(selected) end), true)
    line("Materiales · En bolsas / necesarios", accent)
    local materials = A.recipeMaterials(selected.spell)
    if not materials then
        line("Materiales todavía sin datos.")
    elseif not next(materials) then
        line("Sin materiales registrados.")
    else
        local ids = {}
        for item in pairs(materials) do ids[#ids + 1] = item end
        table.sort(ids)
        for _, item in ipairs(ids) do
            local name, _, texture = A.professionItem(item)
            local material = item
            recipeDetail(name or ("Objeto " .. item), A.professionItemCount(item) .. "/" .. materials[item], texture, item,
                A.traceCallback("UI.lua:2720:callback", function() A.openDonationForm(material) end), nil, "Solicitar")
        end
    end
    line("Fabricantes · " .. #selected.crafters, accent)
    for _, crafter in ipairs(selected.crafters) do
        local member, profession = crafter.member, crafter.profession
        local action
        if member.id ~= A.self then action = A.traceCallback("UI.lua:2727:callback", function() whisperRecipe(member, selected.object or selected.name) end) end
        local class = member.class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[member.class]
        local color = class and {class.r, class.g, class.b}
        recipeDetail(member.name, connection(member) .. " · " .. level(profession), nil, nil, action, color)
    end
end)

local lastDrawnRecipes
local recipeResults; recipeResults = A.traceCallback("UI.lua:2735:recipeResults", function(onlyDetail)
    local results, bySpell = A.searchRecipes(recipeSearch:GetText(), recipeFilters)
    if A.isDebugEnabled() then
        A.debugLog("observation", "recipes.results", {count=#results, query=recipeSearch:GetText(), queryBytes=#recipeSearch:GetText(),
            member=recipeFilters.member, profession=recipeFilters.profession, rarity=recipeFilters.rarity})
    end
    onlyDetail = onlyDetail and lastDrawnRecipes == results
    lastDrawnRecipes = results
    pages = math.ceil(#results / pageSize)
    if pages == 0 then
        updatePage(1, 0, 0)
        local state,reason=A.recipeSearchState()
        local messages={scan="Leyendo tus profesiones.",transfer="Recibiendo datos de profesiones de la hermandad.",
            items="Faltan datos de algunos objetos consultados. La búsqueda usa la información disponible."}
        if state == "loading" or state == "metadata" then line(messages[reason] or "Datos de profesiones pendientes.")
        elseif state == "empty" then
            line("Todavía no hay recetas disponibles en los datos recibidos.")
            line("Abrí tus profesiones para cargar recetas. Las de otros miembros aparecen cuando se reciben sus datos.")
        else
            line("No se encontraron recetas con esta búsqueda y estos filtros en los datos disponibles.")
        end
        return
    end
    recipePage = math.min(recipePage, pages)
    local first, last = (recipePage - 1) * pageSize + 1, math.min(recipePage * pageSize, #results)
    local selected = bySpell[selectedRecipe or 0] or results[first]
    selectedRecipe = selected.spell
    if onlyDetail then
        for _, control in ipairs(recipeRows) do
            if control:IsShown() then control:SetStyle(control.recipeSpell == selectedRecipe) end
        end
    else
        for index = first, last do recipeRow(index - first + 1, results[index]) end
        updatePage(first, last, #results)
    end
    renderRecipeDetails(selected)
end)

local renderOrder; renderOrder = A.traceCallback("UI.lua:2773:renderOrder", function(order, summary)
    local owner = A.members[order.owner]
    local own = order.owner == A.self
    local title = ("%d × %s"):format(order.quantity, order.name)
    if order.item > 0 then
        local _, _, texture = A.professionItem(order.item)
        recipeDetail(title, "", texture, order.item, nil, accent)
    else
        line(title, accent, true)
    end
    line(own and "Mi pedido" or owner.name, nil, true)
    line(order.materials and (own and "Ya tengo los materiales" or "Ya tiene los materiales")
        or "Necesita materiales", order.materials and {0.68, 0.83, 0.69} or nil, true)
    line("Publicado: " .. date("%d/%m/%Y %H:%M", order.created), nil, true)
    line("Caduca: " .. date("%d/%m/%Y %H:%M", order.created + 7 * 86400), nil, true)
    if order.unverified then
        line(own and "Copia de tu pedido · pendiente de recuperar o cancelar" or "Copia compartida del pedido", nil, true)
    end
    summary = summary or A.orderOfferSummary(order.id)
    if own then
        local offers=summary.members
        table.sort(offers, memberOrder)
        for _, crafter in ipairs(offers) do
            button(crafter.name .. " · Susurrar", A.traceCallback("UI.lua:2796:callback", function()
                openWhisperDraft(whisperTarget(crafter.name), "Hola, ¿coordinamos mi pedido de " .. order.name .. "?")
            end))
        end
        if order.unverified then
            button("Recuperar pedido", A.traceCallback("UI.orders.restore", function()
                local ok, err = A.restoreOrder(order)
                if not ok then print("Tártaro: " .. (err or "No se pudo recuperar el pedido.")) end
            end), true)
        else
            button("Marcar como completado", A.traceCallback("UI.orders.complete", function()
                if not A.closeOrder(order, true) then print("Tártaro: no se pudo completar el pedido.") end
            end), true)
        end
        button("Cancelar pedido", A.traceCallback("UI.orders.cancel", function()
            if not A.closeOrder(order) then print("Tártaro: no se pudo cancelar el pedido.") end
        end))
    elseif summary.own then
        line("Te ofreciste para fabricar este pedido.")
        button("Susurrar al solicitante", A.traceCallback("UI.lua:2815:callback", function()
            openWhisperDraft(whisperTarget(owner.name), "Hola, puedo fabricar tu pedido de " .. order.name .. ".")
        end), false, 165)
    elseif A.canCraftOrder(order) then
        button("Puedo fabricarlo", A.traceCallback("UI.lua:2819:callback", function()
            if not A.offerOrder(order) then print("Tártaro: no se pudo registrar la oferta. Volvé a intentar.") end
        end), true, 138)
    end
end)

local recordGrid = components.Grid

local professions; professions = A.traceCallback("UI.lua:2827:professions", function(onlyDetail)
    if professionView == "donations" then
        line("Solicitudes de donación", accent)
        local requests = A.listDonations()
        if #requests == 0 then
            line("No hay solicitudes activas.")
            line("Para solicitar una donación, elegí una receta en Buscar recetas y pulsá Solicitar en uno de sus materiales.")
            button("Buscar recetas", A.traceCallback("UI.lua:2834:callback", function()
                professionView = "recipes"
                scroll:SetVerticalScroll(0)
                A.refresh()
            end))
        end
        recordGrid(requests, A.traceCallback("UI.lua:2840:callback", function(request)
            local member = A.members[request.owner]
            local name, _, texture = A.professionItem(request.item)
            recipeDetail(request.quantity .. " × " .. (name or ("Objeto " .. request.item)), "", texture, request.item, nil, accent)
            line(member.name .. " · " .. connection(member), nil, true)
            if request.unverified then line("Copia compartida · pendiente de confirmar por su autor.", nil, true) end
            line("Publicado: " .. date("%d/%m/%Y %H:%M", request.created), nil, true)
            line("Caduca: " .. date("%d/%m/%Y %H:%M", request.created + 7 * 86400), nil, true)
            if request.owner == A.self then
                button("Cerrar solicitud", A.traceCallback("UI.lua:2849:callback", function()
                    local ok, err = A.closeDonation(request.id)
                    if not ok and err then print("Tártaro: " .. err) end
                end))
            end
        end))
        return
    end
    if professionView == "orders" then
        line("Pedidos de fabricación", accent)
        local orders, completed, summaries = A.listVisibleOrders()
        if A.isDebugEnabled() then
            A.debugLog("observation", "orders.rows", {count=#orders, completed=#completed})
        end
        if selectedOrder then
            local found
            for _, order in ipairs(orders) do
                if order.id == selectedOrder then found = true; break end
            end
            if not found then
                selectedOrder = nil
                orderNotice = "El pedido seleccionado ya no está disponible entre tus pedidos pendientes."
            end
        end
        if orderNotice then line(orderNotice, accent) end
        if #orders == 0 then line("No hay pedidos pendientes.") end
        local focusY = recordGrid(orders, A.traceCallback("UI.orders.render", function(order)
            renderOrder(order,summaries[order.id])
        end), selectedOrder)
        if pendingOrderScroll then orderFocusY=focusY end
        if #completed > 0 then
            line("Pedidos completados", accent)
            for _, order in ipairs(completed) do
                line(("%d × %s · %s"):format(order.quantity, order.name, A.members[order.owner].name))
            end
        end
        return
    end
    recipeResults(onlyDetail)
end)

A.renderGroups = A.traceCallback("UI.lua:2890:A.renderGroups", function()
    line("Buscar grupo", accent)
    if A.can(A.me, "group") then button("Estoy armando grupo", A.openGroupForm, true) end
    local active = {}
    for id, group in pairs(A.groups) do
        if group.version == 1 and group.when + 1800 > GetServerTime() and A.can(A.members[id], "group")
            and (A.members[id].online ~= false or id == A.self) then
            active[#active + 1] = group
        end
    end
    table.sort(active, A.traceCallback("UI.lua:2900:callback", function(left, right) return left.when > right.when end))
    if #active == 0 then line("No hay grupos buscando gente.") end
    recordGrid(active, A.traceCallback("UI.lua:2902:callback", function(group)
        local owner = A.members[group.owner]
        line(group.activity .. " · " .. owner.name, accent)
        local counts, total, members
        if group.slots then counts, total, members = A.groupAttendance(group) end
        local needs = A.groupRemainingNeeds(group,counts)
        if A.isDebugEnabled() then
            A.debugLog("observation", "group.needs", {owner=group.owner, needs=needs, activity=group.activity})
        end
        line(group.location .. (needs ~= "" and " · Faltan " .. needs or ""))
        if group.slots then
            local capacity = group.slots.roles[1] + group.slots.roles[2] + group.slots.roles[3]
            line(("Inscritos: %d/%d · Máximo de la BG: %d"):format(total, capacity, group.slots.maximum), accent)
            for index, role in ipairs(A.eventRoleOrder) do
                line(("%s: %d/%d"):format(A.eventRoles[role], counts[role], group.slots.roles[index]))
                if counts[role] < group.slots.roles[index] and members[A.self] ~= role
                    and (members[A.self] or total < group.slots.maximum) then
                    local choice = role
                    button("Participar como " .. A.eventRoles[choice], A.traceCallback("UI.lua:2920:callback", function() A.requestGroupRole(group, choice) end))
                end
            end
            if total >= capacity then line("Cupos completos", accent) end
            if A.groupRequestPending(group) then line("Esperando confirmación del organizador.") end
            if members[A.self] then
                line("Tu inscripción: " .. A.eventRoles[members[A.self]], accent)
                button("Quitar mi inscripción", A.traceCallback("UI.lua:2927:callback", function() A.requestGroupRole(group, "-") end))
                if group.owner ~= A.self then
                    button("Pedir invitación", A.traceCallback("UI.lua:2929:callback", function()
                        sendGroupWhisper(owner.name, "Me anoté como " .. A.eventRoles[members[A.self]]
                            .. " para " .. group.activity .. ". ¿Me invitás?")
                    end))
                end
            end
            if group.owner == A.self then
                local ids = {}
                for id in pairs(members) do ids[#ids + 1] = id end
                table.sort(ids)
                for _, id in ipairs(ids) do
                    groupParticipant(group, id, A.members[id].name .. " · " .. A.eventRoles[members[id]])
                end
            end
        end
        if group.owner == A.self then
            if group.selection then button("Editar búsqueda", A.traceCallback("UI.lua:2945:callback", function() A.editGroupForm(group) end)) end
            button("Volver a publicar", A.traceCallback("UI.lua:2946:callback", function()
                local ok, err = A.repostGroup(group)
                if not ok and err then print("Tártaro: " .. err) end
                A.refresh()
            end))
            button("Cerrar búsqueda", A.traceCallback("UI.lua:2951:callback", function() A.closeGroup(group) end))
        elseif not group.slots then
            if group.requestState then
                line(group.requestState)
            else
                button("Pedir grupo", A.traceCallback("UI.lua:2956:callback", function()
                    if A.groups[owner.id] ~= group or group.when + 1800 <= GetServerTime()
                        or not A.can(A.members[owner.id], "group") then A.refresh(); return end
                    group.requestState = sendGroupWhisper(owner.name, "Hola, ¿me invitás a tu grupo para " .. group.activity .. "?")
                    A.refresh()
                end))
            end
        end
    end))
end)

local honorByTotal
local honorRanking; honorRanking = A.traceCallback("UI.lua:2968:honorRanking", function()
    local columns = {8, 65, 305, 430, 570}
    local honorRow; honorRow = A.traceCallback("UI.lua:2970:honorRow", function(values, color)
        return tableRow(values, columns, 26, 0, {color, color, color, color})
    end)
    line("Ranking de honor", accent)
    line("El honor semanal se reinicia el jueves a las 00:00, hora del reino.")
    line("Orden actual: honor " .. (honorByTotal and "total" or "semanal") .. " de mayor a menor; empates por nombre.")
    button(honorByTotal and "Ordenar por honor semanal" or "Ordenar por honor total", A.traceCallback("UI.lua:2976:callback", function()
        honorByTotal = not honorByTotal
        scroll:SetVerticalScroll(0)
        A.refresh()
    end))
    local week = A.honorWeek()
    local ranking = {}
    for id, total in pairs(A.db.honor) do
        local member = A.members[id]
        if member then
            local weekly = A.weeklyHonor(id, week)
            ranking[#ranking + 1] = {member = member, total = total, weekly = weekly, score = honorByTotal and total or weekly}
        end
    end
    table.sort(ranking, A.traceCallback("UI.lua:2990:callback", function(left, right)
        if left.score ~= right.score then return left.score > right.score end
        return left.member.name < right.member.name
    end))
    if #ranking == 0 then
        line("Todavía no se registraron puntos de honor.")
        components.BeginTable()
        return
    end
    A.debugLog("honor.order", "UI.honorRanking", honorByTotal, #ranking)
    honorRow({"Puesto", "Personaje", "Honor semanal", "Honor total"}, accent)
    components.BeginTable()
    local position, previous
    local formatPoints = BreakUpLargeNumbers or tostring
    for index, entry in ipairs(ranking) do
        if entry.score ~= previous then position, previous = index, entry.score end
        local name = entry.member.name .. (entry.member.id == A.self and " (vos)" or "")
        honorRow({entry.score > 0 and tostring(position) or "-", name,
            week and formatPoints(entry.weekly) or "Sin datos", formatPoints(entry.total)},
            entry.score > 0 and position == 1 and accent or nil)
    end
end)

win.WatchRefreshTime = A.traceCallback("UI.view.watchTime", function(self, when, now)
    if when > now and (not self.nextRefreshAt or when < self.nextRefreshAt) then self.nextRefreshAt = when end
end)
win.CaptureRefreshDeadline = A.traceCallback("UI.view.captureDeadline", function(self, view, now)
    self.refreshView, self.nextRefreshAt, self.viewCheckedAt = view, nil, now
    self.viewOffset = self:LocalTimeOffset(now)
    if view ~= "map" then self.mapCalls = nil end
    if view == "orders" then
        for _, records in pairs({A.db.orders,A.db.orderPreviews,A.db.orderCopyClosed}) do
            for _, record in pairs(records) do
                if type(record) == "table" and type(record.created) == "number" then
                    self:WatchRefreshTime(record.created-120,now)
                    self:WatchRefreshTime(record.created+7*86400,now)
                end
            end
        end
    elseif view == "donations" then
        for _, request in pairs(A.db.donations or {}) do
            self:WatchRefreshTime(request.created-60,now)
            self:WatchRefreshTime(request.created+7*86400,now)
        end
    elseif view == "groups" then
        for _, group in pairs(A.groups) do self:WatchRefreshTime(group.when+1800,now) end
    end
end)
win.MapStatusChanged = A.traceCallback("UI.map.statusChanged", function(self)
    if self.mapStatus ~= A.locationStatus() or self.mapWorldStatus ~= A.worldMapStatus then return true end
    local live, count, now = 0, 0, GetTime()
    for _, position in pairs(A.positions) do if position.expires > now then live = live + 1 end end
    if live ~= self.mapLive then return true end
    now = GetServerTime()
    for _, call in pairs(A.calls) do
        if call.expires > now then
            count = count + 1
            if not self.mapCalls or self.mapCalls[call] ~= A.callLocation(call) then return true end
        end
    end
    return count ~= self.mapCallCount
end)

local tabs = {
    {"home", "Inicio", home},
    {"calendar", "Calendario", calendar},
    {"groups", "Buscar grupo", A.renderGroups},
    {"notices", "Avisos", notices},
    {"professions", "Profesiones", professions},
    {"honor", "Honor", honorRanking},
    {"members", "Miembros", members, A.canManagePermissions},
    {"map", "Mapa", settings},
    {"permissions", "Permisos", permissions, A.canManagePermissions},
    {"options", "Opciones", A.traceCallback("UI.lua:3063:callback", function() end)},
}
local renderers = {}
for index, tab in ipairs(tabs) do
    local id = tab[1]
    renderers[id] = tab[3]
    local control = copperButton(win)
    control:SetSize(sidebarWidth - 24, 29)
    control:SetPoint("TOPLEFT", 12, -(headerHeight + 16 + (index - 1) * 32))
    control:SetText(tab[2])
    control:SetShown(not tab[4] or tab[4](A.me))
    control:SetScript("OnClick", A.traceCallback("UI.lua:3074:callback", function()
        if tab[4] and not tab[4](A.me) then return end
        page = id
        recipeSearch:ClearFocus()
        scroll:SetVerticalScroll(0)
        if id == "calendar" then calendarPanel:Reset(); selectedEvent=nil end
        A.refresh()
    end))
    tab.control = control
end

win.RefreshNavigation = A.traceCallback("UI.navigation.refresh", function()
    local visible, redirected = 0, false
    for _, tab in ipairs(tabs) do
        local allowed = not tab[4] or tab[4](A.me)
        if tab.control.navigationAllowed ~= allowed then
            tab.control:SetShown(allowed)
            tab.control.navigationAllowed = allowed
        end
        if allowed then
            if tab.control.navigationIndex ~= visible then
                tab.control:ClearAllPoints()
                tab.control:SetPoint("TOPLEFT", 12, -(headerHeight + 16 + visible*32))
                tab.control.navigationIndex = visible
            end
            visible = visible + 1
        elseif page == tab[1] then
            page, redirected = "home", true
            scroll:SetVerticalScroll(0)
            components.Hide()
            GameTooltip:Hide()
        end
    end
    for _, tab in ipairs(tabs) do
        local selected = tab[1] == page
        if tab.control.navigationSelected ~= selected then
            tab.control:SetStyle(selected)
            tab.control.navigationSelected = selected
        end
    end
    win.navigationHeight = headerHeight + 16 + visible * 32 + 14
    return redirected
end)
win:RefreshNavigation()

A.refresh = A.traceCallback("UI.lua:3119:A.refresh", function(detail)
    win:RestorePosition()
    win:RefreshNavigation()
    if A.isDebugEnabled() then
        A.debugLog("view.request","UI.refresh",page,professionView,detail,A.guildStatus,win:IsShown())
    end
    if not A.db then
        A.debugLog("view.blocked","UI.refresh",A.guildStatus)
        components.Hide()
        scroll:SetPoint("TOPLEFT", sidebarWidth + 18, -(headerHeight + 18))
        scroll:SetVerticalScroll(0)
        optionsPanel:Hide()
        professionControls:Hide()
        recipeList:Hide()
        calendarPanel:Hide()
        eventDivider:Hide()
        for _, frame in ipairs({editor, TartaroActivityForm, daily, eventPopup, callPopup}) do frame:Hide() end
        callLauncher:Hide()
        if win:IsShown() then
            components.Begin(570,false)
            line(A.guildStatus == "pending" and "Esperando los datos de la hermandad."
                or "Usted no está en la Guild Tartaro")
        end
        return
    end
    callLauncher:SetShown(A.can(A.me, "call"))
    if activeNotice and not noticeEvent(activeNotice) then eventPopup:Hide() end
    if callPopup:IsShown() and not currentCall() then callPopup:Hide() end
    if not win:IsShown() then showDaily(); return end
    local professionPage = A.db ~= nil and page == "professions"
    local showSearch = professionPage and professionView == "recipes"
    local showCalendar = page == "calendar"
    calendarPanel:SetShown(showCalendar)
    eventDivider:SetShown(showCalendar)
    local width = showSearch and 422 or showCalendar and 320 or page == "members" and 690 or 570
    local displayWidth, displayHeight = UIParent:GetSize()
    local view = professionPage and professionView or page
    A.debugLog("render.begin", "UI.refresh", view)
    local layoutChanged = win.layoutView ~= view or win.layoutDB ~= A.db
        or win.displayWidth ~= displayWidth or win.displayHeight ~= displayHeight
        or win.layoutNavigationHeight ~= win.navigationHeight
    if layoutChanged then
        win.layoutView, win.layoutDB = view, A.db
        win.layoutNavigationHeight = win.navigationHeight
        win.displayWidth, win.displayHeight = displayWidth, displayHeight
        optionsPanel:SetShown(page == "options")
        professionControls:SetShown(professionPage)
        recipeList:SetShown(showSearch)
        recipeSearch:SetShown(showSearch)
        recipeLabel:SetShown(showSearch)
        for _, control in ipairs(filters) do control:SetShown(showSearch) end
        for id, control in pairs(professionButtons) do control:SetStyle(id == professionView) end
        local windowWidth = sidebarWidth + (showSearch and 890 or showCalendar and 1050 or page == "members" and 740 or 620)
        local windowHeight = showCalendar and 704 or showSearch and 648 or 497
        windowHeight = math.max(windowHeight, win.navigationHeight)
        win:CaptureResizeOrigin()
        win:SetSize(windowWidth, windowHeight)
        win.normalScale = math.min(1, displayWidth / (windowWidth + 20), displayHeight / (windowHeight + 98))
        professionControls:SetWidth(showSearch and 852 or 570)
        scroll:SetPoint("TOPLEFT", sidebarWidth + (showSearch and 436 or showCalendar and 698 or 18),
            -(headerHeight + (showSearch and 104 or professionPage and 53 or 18)))
        content.sectionHeader:SetPoint("TOPLEFT",sidebarWidth+(showCalendar and 698 or 18),-(headerHeight+18))
        content:SetWidth(width)
        homeDivider:SetShown(A.db ~= nil and page == "home")
        homeRule:SetShown(A.db ~= nil and page == "home")
        homeOrdersDivider:SetShown(A.db ~= nil and page == "home")
    end
    if showSearch and detail ~= "recipeDetail" then
        memberFilter:SetText(recipeFilters.memberLabel or "Miembros")
        professionFilter:SetText(recipeFilters.professionLabel or "Profesiones")
        rarityFilter:SetText(recipeFilters.rarityLabel or "Rarezas")
        boundFilter:SetStyle(recipeFilters.hideBound)
    end
    if layoutChanged or detail == nil then
        showDaily()
        if callPopup:IsShown() then positionCall() end
    end
    local renderStartedAt = GetServerTime()
    components.Begin(width,page == "honor" or page == "members" or page == "calendar")
    if page ~= "options" then
        if A.db then renderers[page](detail == "recipeDetail" and not layoutChanged)
        else line("Entrá a una hermandad para usar Tártaro.") end
    end
    components.Finish()
    win:CaptureRefreshDeadline(view,renderStartedAt)
    if page == "calendar" and calendarPanel.pendingFocus then
        scroll:SetVerticalScroll(math.max(0, math.min(calendarPanel.focusY or 0, content:GetHeight() - scroll:GetHeight())))
        calendarPanel.pendingFocus = nil
    end
    if pendingOrderScroll and page == "professions" and professionView == "orders" then
        scroll:SetVerticalScroll(math.max(0, math.min(orderFocusY or 0, content:GetHeight() - scroll:GetHeight())))
        pendingOrderScroll, orderFocusY = nil, nil
    end
    if A.isDebugEnabled() then
        A.debugLog("render.end", "UI.refresh", view, {width=content:GetWidth(), height=content:GetHeight(), rows=components.Count(),
            calendar=calendarPanel:IsShown(), recipes=recipeList:IsShown(), order=selectedOrder, recipe=selectedRecipe,
            scroll=scroll:GetVerticalScroll(), calendarMonth=calendarPanel.month, calendarYear=calendarPanel.year, calendarDay=calendarPanel.selectedDay,
            fixedHeader=content.sectionHeader:IsShown(), fixedHeight=content.sectionHeader:GetHeight()})
    end
end)

local pendingSections
A.invalidate = A.traceCallback("UI.lua:3221:A.invalidate", function(section)
    if section == "events" then A.invalidateEventNotices() end
    local navigationChanged = false
    if section == "permissions" or section == "roster" then
        navigationChanged = win:RefreshNavigation()
        callLauncher:SetShown(A.can(A.me, "call") == true)
    end
    if pendingSections then
        pendingSections[section] = true
        pendingSections.navigation = pendingSections.navigation or navigationChanged
        return
    end
    pendingSections = {[section] = true, navigation=navigationChanged}
    C_Timer.After(0.08, A.traceCallback("UI.lua:3234:callback", function()
        local dirty = pendingSections
        pendingSections = nil
        local visible = page == "professions" and professionView or page
        if dirty.recipeDetail then TartaroActivityForm.updateReagents() end
        local chrome = dirty.daily or dirty.events or dirty.permissions or dirty.roster or dirty.map
        local changed = dirty.navigation or dirty[visible] or dirty.roster and visible ~= "options"
            or dirty.events and (visible == "home" or visible == "calendar")
            or dirty.orders and visible == "home"
            or dirty.daily and (visible == "home" or visible == "notices")
            or dirty.permissions and (visible == "calendar" or visible == "notices" or visible == "groups" or visible == "map")
        if win:IsShown() and changed then
            if chrome then A.refresh() else A.refresh("page") end
        elseif win:IsShown() and visible == "recipes" and (dirty.recipeDetail or dirty.recipeStatus) then
            A.refresh("recipeDetail")
        elseif chrome then
            callLauncher:SetShown(A.can(A.me, "call"))
            if activeNotice and not noticeEvent(activeNotice) then eventPopup:Hide() end
            if callPopup:IsShown() and not currentCall() then callPopup:Hide() end
            if dirty.daily or dirty.roster then showDaily() end
        end
    end))
end)

A.refreshProfessions = A.traceCallback("UI.lua:3258:A.refreshProfessions", function(detail)
    A.invalidate(detail and "recipeDetail" or "recipes")
    if not detail then A.invalidate("orders") end
end)

A.refreshHonor = A.traceCallback("UI.lua:3263:A.refreshHonor", function()
    A.invalidate("honor")
end)

A.refreshMembers = A.traceCallback("UI.lua:3267:A.refreshMembers", function()
    A.invalidate("members")
end)
C_Timer.NewTicker(5, A.traceCallback("UI.lua:3270:callback", function()
    if not win:IsShown() or not A.db then return end
    if page == "members" and A.db then
        for id, member in pairs(A.members) do
            local _, current = A.memberAddonReport(member)
            local status = A.addonPresence(member) .. (current and ":current" or ":historical")
            if memberPresence[id] ~= status then
                A.debugLog("presence.changed", "UI.members", id, memberPresence[id], status)
                A.refreshMembers()
                break
            end
        end
    end
    local now = GetServerTime()
    local visible = page == "professions" and professionView or page
    if win.viewCheckedAt and now < win.viewCheckedAt
        or win.viewOffset ~= win:LocalTimeOffset(now) or win.refreshView ~= visible
        or win.nextRefreshAt and now >= win.nextRefreshAt then
        A.invalidate(visible)
    end
    win.viewCheckedAt = now
    if page == "map" and win:MapStatusChanged() then A.invalidate("map") end
    if (page == "calendar" or page == "home") and win.nextEventAt and win.nextEventAt <= GetServerTime() then
        A.invalidate("events")
    end
end))

local toggle; toggle = A.traceCallback("UI.lua:3297:toggle", function()
    if A.traceLoad then A.traceLoad("toggle.begin", "UI.lua") end
    if combatWindowsBlocked() then
        if A.traceLoad then A.traceLoad("toggle.blocked", "UI.lua", "combat") end
        return
    end
    if editor:IsShown() then
        editor:Hide()
        if A.traceLoad then A.traceLoad("toggle.end", "UI.lua", "editor.hidden") end
        return
    end
    if win:IsShown() then
        win:Hide()
        if A.traceLoad then A.traceLoad("toggle.end", "UI.lua", "window.hidden") end
        return
    end
    win:Show()
    A.refresh()
    if A.traceLoad then A.traceLoad("toggle.end", "UI.lua", "window.shown") end
end)

SLASH_TARTARO1 = "/tartaro"
SlashCmdList.TARTARO = toggle

local launcher = CreateFrame("Button", "TartaroMinimapButton", Minimap)
launcher:SetSize(32, 32)
launcher:SetFrameLevel(Minimap:GetFrameLevel() + 8)
launcher:RegisterForClicks("LeftButtonUp")
launcher:RegisterForDrag("LeftButton")
local defaultAngle = -3 * math.pi / 4
local launcherAngle = defaultAngle
local dragged = false

local placeLauncher; placeLauncher = A.traceCallback("UI.lua:3330:placeLauncher", function()
    local radius = math.min(Minimap:GetWidth(), Minimap:GetHeight()) * 0.51
    launcher:ClearAllPoints()
    launcher:SetPoint("CENTER", Minimap, "CENTER", radius * math.cos(launcherAngle), radius * math.sin(launcherAngle))
end)

local followCursor; followCursor = A.traceCallback("UI.lua:3336:followCursor", function()
    local centerX, centerY = Minimap:GetCenter()
    if not centerX or not centerY then return end
    local cursorX, cursorY = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    local dx, dy = cursorX / scale - centerX, cursorY / scale - centerY
    if dx == 0 and dy == 0 then return end
    launcherAngle = math.atan2(dy, dx)
    placeLauncher()
end)

launcher:RegisterEvent("PLAYER_LOGIN")
launcher:SetScript("OnEvent", A.traceCallback("UI.lua:3348:callback", function(self)
    local saved = TartaroDB and TartaroDB.minimapAngle
    if type(saved) == "number" and saved >= -math.pi and saved <= math.pi then launcherAngle = saved end
    placeLauncher()
    self:UnregisterEvent("PLAYER_LOGIN")
end))
Minimap:HookScript("OnSizeChanged", placeLauncher)
placeLauncher()

launcher:SetScript("OnMouseDown", A.traceCallback("UI.lua:3357:callback", function() dragged = false end))
launcher:SetScript("OnClick", A.traceCallback("UI.lua:3358:callback", function()
    if not dragged then toggle() end
end))
launcher:SetScript("OnDragStart", A.traceCallback("UI.lua:3361:callback", function(self)
    dragged = true
    GameTooltip:Hide()
    self:SetScript("OnUpdate", followCursor)
end))
launcher:SetScript("OnDragStop", A.traceCallback("UI.lua:3366:callback", function(self)
    followCursor()
    self:SetScript("OnUpdate", nil)
    if TartaroDB then TartaroDB.minimapAngle = launcherAngle end
end))
launcher:SetScript("OnHide", A.traceCallback("UI.lua:3371:callback", function(self)
    self:SetScript("OnUpdate", nil)
end))
local emblem = launcher:CreateTexture(nil, "BACKGROUND")
emblem:SetTexture(icon)
emblem:SetSize(24, 24)
emblem:SetPoint("CENTER")
local rim = launcher:CreateTexture(nil, "OVERLAY")
rim:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
rim:SetSize(53, 53)
rim:SetPoint("TOPLEFT")
launcher:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
launcher:SetScript("OnEnter", A.traceCallback("UI.lua:3383:callback", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("Tártaro", 1, 0.79, 0.53)
    GameTooltip:AddLine("Clic para abrir o cerrar", 1, 1, 1)
    GameTooltip:AddLine("Arrastrá con clic izquierdo para mover", 1, 1, 1)
    GameTooltip:Show()
end))
launcher:SetScript("OnLeave", A.traceCallback("UI.lua:3390:callback", function() GameTooltip:Hide() end))

A.resetGuildWindows = A.traceCallback("UI.lua:3392:A.resetGuildWindows", function()
    selectedEvent=nil
    win.mapCalls, win.nextRefreshAt, win.refreshView, win.viewCheckedAt, win.viewOffset = nil,nil,nil,nil,nil
    calendarPanel.pendingFocus, calendarPanel.focusY, calendarPanel.renderedEvent = nil, nil, nil
    calendarPanel:Reset()
    selectedOrder, pendingOrderScroll, orderFocusY, orderNotice = nil, nil, nil, nil
    pendingEvents, eventNotices.offered, eventNotices.scheduled, activeNotice = {}, {}, {}, nil
    A.invalidateEventNotices()
    dailyState = {}
    for _, frame in ipairs({win, editor, TartaroActivityForm, daily, eventPopup, callPopup}) do
        frame.resumeAfterCombat = nil
        frame:Hide()
    end
    if A.closeDonationForm then A.closeDonationForm() end
    callLauncher:Hide()
end)

A.updateCombatWindows = A.traceCallback("UI.lua:3409:A.updateCombatWindows", function()
    if not A.db then A.resetGuildWindows(); return end
    if daily.NotificationsBlocked() then
        eventPopup:Hide()
        daily:Hide()
    end
    if A.updateDonationCombat then A.updateDonationCombat(combatWindowsBlocked()) end
    if combatWindowsBlocked() then
        local form = TartaroActivityForm
        if form:IsShown() then form.resumeAfterCombat = true; form:Hide() end
        if editor:IsShown() then editor.resumeAfterCombat = true; editor:Hide() end
        if win:IsShown() then win.resumeAfterCombat = true; win:Hide() end
        eventPopup:Hide()
        daily:Hide()
        callPopup:Hide()
        layoutNotices()
        return
    end
    for _, frame in ipairs({win, editor, TartaroActivityForm}) do
        if frame.resumeAfterCombat then
            frame.resumeAfterCombat = nil
            frame:Show()
        end
    end
    A.showEventNotification()
    local call = currentCall()
    if call and not callPopup:IsShown() then A.showCall(call) end
    A.refresh()
end)

local combatEvents = CreateFrame("Frame")
combatEvents:RegisterEvent("PLAYER_REGEN_DISABLED")
combatEvents:RegisterEvent("PLAYER_REGEN_ENABLED")
combatEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
combatEvents:RegisterEvent("ZONE_CHANGED_NEW_AREA")
combatEvents:SetScript("OnEvent", A.traceCallback("UI.lua:3444:callback", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then inCombat = true
    elseif event == "PLAYER_REGEN_ENABLED" then inCombat = false end
    A.updateCombatWindows()
end))

StaticPopupDialogs["TARTARO_RESET_OPTIONS"] = {
    text = "¿Restablecer las posiciones y opciones personales de Tártaro?",
    button1 = "Restablecer",
    button2 = "Cancelar",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnAccept = A.traceCallback("UI.lua:3457:callback", function()
        if TartaroDB.shareLocation == false then A.setSharing(true) end
        for _, key in ipairs({"shareLocation", "callSound", "callSoundVolume", "callSoundChoice", "hideWindowsInCombat", "centerWindowOnResize",
            "minimapAngle", "callLauncherPosition", "callLauncherSize", "noticePosition", "windowPosition"}) do
            TartaroDB[key] = nil
        end
        launcherAngle = defaultAngle
        placeLauncher()
        A.setCallLauncherSize(100)
        callLauncher:ResetPosition()
        win.resizeOrigin, win.resizeDragging = nil, nil
        win.stackPoint = nil
        win:ClearAllPoints()
        win:SetPoint("CENTER", UIParent, "CENTER", 0, -20)
        editor:ClearAllPoints()
        editor:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
        TartaroActivityForm:ClearAllPoints()
        TartaroActivityForm:SetPoint("CENTER", UIParent, "CENTER", 0, 25)
        TartaroDonationForm:ClearAllPoints()
        TartaroDonationForm:SetPoint("CENTER", UIParent, "CENTER", 0, 25)
        callMoved = nil
        positionCall()
        detectedFirst = nil
        honorByTotal = nil
        recipeSearch:SetText("")
        recipeFilters = {hideBound = false}
        recipePage, selectedRecipe = 1, nil
        optionsPanel.sync()
        A.updateCombatWindows()
    end),
}
if A.traceLoad then A.traceLoad("module.end", "UI.lua") end
