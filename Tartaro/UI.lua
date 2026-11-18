local _, A = ...
local crest = "Interface\\AddOns\\Tartaro\\Crest"
local skull = "Interface\\AddOns\\Tartaro\\HeaderSkull"
local icon = "Interface\\AddOns\\Tartaro\\MinimapIcon"
local backdrop = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 2,
}

local function surface(name, width, height, y)
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
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -3, -3)
    frame.closeButton = close
    frame:Hide()
    return frame
end

local function text(parent, value, font)
    local label = parent:CreateFontString(nil, "ARTWORK", font or "GameFontHighlight")
    label:SetJustifyH("LEFT")
    label:SetText(value)
    return label
end

local function badge(parent, size)
    local image = parent:CreateTexture(nil, "ARTWORK")
    image:SetTexture(crest)
    image:SetSize(size, size)
    image:SetPoint("TOPLEFT", 15, -12)
    return image
end

local function copperButton(parent)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetBackdrop(backdrop)
    button:SetNormalFontObject(GameFontHighlight)
    button:SetDisabledFontObject(GameFontDisable)
    button:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD")
    button:GetHighlightTexture():SetVertexColor(0.34, 0.18, 0.09, 0.28)
    function button:SetStyle(selected, primary)
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
    end
    return button
end

local sidebarWidth = 152
local win = surface("TartaroWindow", 620 + sidebarWidth, 497, -20)
local inCombat
local function combatWindowsBlocked()
    return TartaroDB and TartaroDB.hideWindowsInCombat ~= false
        and (inCombat or InCombatLockdown and InCombatLockdown())
end
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
local heading = text(win, "TÁRTARO", "GameFontNormalHuge")
heading:SetPoint("CENTER", win, "TOP", 0, -101)
heading:SetJustifyH("CENTER")
heading:SetTextColor(1, 0.87, 0.72)
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

local page, selectedEvent = "home", nil
local professionView = "recipes"
local rows, activeRows, y = {}, 0, 0
local eventDivider = content:CreateTexture(nil, "BACKGROUND")
eventDivider:SetPoint("TOPLEFT", 186, 0)
eventDivider:SetPoint("BOTTOMLEFT", 186, 0)
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
local column, columnWidth = 0, 570

local function row()
    activeRows = activeRows + 1
    if not rows[activeRows] then
        local frame = CreateFrame("Frame", nil, content)
        frame.label = text(frame, "")
        frame.label:SetPoint("TOPLEFT", 0, -3)
        frame.button = copperButton(frame)
        frame.button:SetPoint("TOPLEFT")
        frame.check = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
        frame.check:SetPoint("TOPLEFT", 0, 2)
        frame.checkText = text(frame.check, "")
        frame.checkText:SetPoint("LEFT", frame.check, "RIGHT", 4, 0)
        rows[activeRows] = frame
    end
    local frame = rows[activeRows]
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", column, -y)
    frame:SetWidth(columnWidth)
    frame.label:SetWidth(columnWidth - 8)
    frame.label:Hide()
    frame.button:Hide()
    if frame.participantMenu then frame.participantMenu:Hide() end
    if frame.detail then frame.detail:Hide() end
    if frame.memberCells then
        for _, cell in ipairs(frame.memberCells) do cell:Hide() end
        frame.memberBackground:Hide()
        if frame.memberSort then frame.memberSort:Hide() end
    end
    if frame.honorCells then
        for _, cell in ipairs(frame.honorCells) do cell:Hide() end
    end
    frame.check:Hide()
    frame:Show()
    return frame
end

local function line(value, color, compact)
    local frame = row()
    frame.label:SetText(value)
    frame.label:SetTextColor(unpack(color or {0.96, 0.90, 0.82}))
    frame.label:Show()
    local height = math.max(compact and 17 or 23, frame.label:GetStringHeight() + (compact and 4 or 10))
    frame:SetHeight(height)
    y = y + height
    return frame
end

local function button(label, callback, primary, width)
    local frame = row()
    frame.button:SetSize(math.min(columnWidth - 8, width or 228), 27)
    frame.button:SetText(label)
    frame.button:GetFontString():SetWidth(frame.button:GetWidth() - 10)
    frame.button:GetFontString():SetMaxLines(1)
    frame.button:SetStyle(false, primary)
    frame.button:SetScript("OnClick", callback)
    frame.button:Show()
    frame:SetHeight(35)
    y = y + 35
end

local function check(label, enabled, callback)
    local frame = row()
    frame.checkText:SetText(label)
    frame.check:SetChecked(enabled)
    frame.check:SetScript("OnClick", function(self) callback(self:GetChecked() and true or false) end)
    frame.check:Show()
    frame:SetHeight(32)
    y = y + 32
end

local editor = surface("TartaroEditor", 450, 445, 20)
tinsert(UISpecialFrames, "TartaroEditor")
local editorTitle = text(editor, "", "GameFontNormalLarge")
editorTitle:SetPoint("TOPLEFT", 18, -18)
local function field(label, yOffset, maxChars)
    local caption = text(editor, label)
    caption:SetPoint("TOPLEFT", 18, yOffset)
    local field = CreateFrame("EditBox", nil, editor, "InputBoxTemplate")
    field:SetPoint("TOPLEFT", 24, yOffset - 22)
    field:SetSize(402, 25)
    field:SetAutoFocus(false)
    field:SetMaxLetters(maxChars)
    field:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    return caption, field
end

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

local function selectKind(kind)
    selectedKind = kind
    for value, checkButton in pairs(kindChecks) do checkButton:SetChecked(kind == value) end
end

for index, kind in ipairs(kinds) do
    local value = kind
    local checkButton = CreateFrame("CheckButton", nil, kindPicker, "UICheckButtonTemplate")
    checkButton:SetSize(24, 24)
    checkButton:SetPoint("TOPLEFT", ((index - 1) % 2) * 199, -17 - math.floor((index - 1) / 2) * 25)
    checkButton:SetHitRectInsets(0, -160, 0, 0)
    local label = text(checkButton, A.kinds[value])
    label:SetPoint("LEFT", checkButton, "RIGHT", 3, 0)
    checkButton:SetScript("OnClick", function() selectKind(value) end)
    kindChecks[value] = checkButton
end

StaticPopupDialogs["TARTARO_DELETE_EVENT"] = {
    text = "¿Eliminar el evento «%s»? También se quitarán sus inscripciones.",
    button1 = "Eliminar",
    button2 = "Cancelar",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnAccept = function(_, data)
        if not editor:IsShown() or A.db ~= data.db or not editing or editing.id ~= data.id then return end
        local ok, err = A.deleteEvent(data.id)
        if not ok then errorLabel:SetText(err); return end
        if selectedEvent == data.id then selectedEvent = nil end
        editor:Hide()
    end,
}
delete:SetScript("OnClick", function()
    if editing and editingGuild == A.db then
        StaticPopup_Show("TARTARO_DELETE_EVENT", editing.title, nil, {id = editing.id, db = editingGuild})
    end
end)

local function openEditor(typeOfEdit, event)
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
    win:Hide()
    editor:Show()
    editor:Raise()
end

editor:SetScript("OnHide", function()
    titleField:ClearFocus()
    dateField:ClearFocus()
    timeField:ClearFocus()
    detailField:ClearFocus()
    for _, fields in ipairs(editor.capFields) do fields[2]:ClearFocus() end
    if editor.resumeAfterCombat then return end
    win:Show()
    A.refresh()
    A.showEventNotification()
end)

local function parseDate(value)
    local day, month, year, hour, minute = value:match("^(%d%d)/(%d%d)/(%d%d%d%d) (%d%d):(%d%d)$")
    if not year then return end
    local ok, when = pcall(time, {year = tonumber(year), month = tonumber(month), day = tonumber(day), hour = tonumber(hour), min = tonumber(minute), sec = 0})
    if ok and when and when > 0 and date("%d/%m/%Y %H:%M", when) == value then return when end
end

local function announceGuild(message, fallback)
    local send = C_ChatInfo and C_ChatInfo.SendChatMessage or SendChatMessage
    local locked = C_ChatInfo and C_ChatInfo.InChatMessagingLockdown and C_ChatInfo.InChatMessagingLockdown()
    local canSpeak = not C_GuildInfo or not C_GuildInfo.CanSpeakInGuildChat or C_GuildInfo.CanSpeakInGuildChat()
    if send and not locked and canSpeak then
        local ok, result = pcall(send, message, "GUILD")
        if ok and result ~= false then return end
    end
    if ChatFrame_OpenChat then
        ChatFrame_OpenChat("/g " .. message)
        print("Tártaro: " .. fallback .. " Presioná Enter para enviar el anuncio a la hermandad.")
    else
        print("Tártaro: " .. fallback .. " El anuncio quedó sin enviar.")
    end
end

local function shortenChat(value, limit)
    if #value <= limit then return value end
    local cut = limit - 2
    while value:byte(cut) >= 128 and value:byte(cut) < 192 do cut = cut - 1 end
    return value:sub(1, cut - 1) .. "…"
end

local function announceEvent(event)
    local prefix = "[Tártaro] Nuevo evento: "
    local suffix = (" (%s) · %s UTC."):format(A.kinds[event.kind], date("!%d/%m/%Y %H:%M", event.when))
    announceGuild(prefix .. shortenChat(event.title, 250 - #prefix - #suffix) .. suffix, "El evento se guardó.")
end

local function announceGroup(group)
    local format = "[Tártaro] Busco grupo para %s. Roles que faltan: %s."
    local message = format:format(group.activity, group.needs)
    if #message > 250 then
        message = format:format(shortenChat(group.activity, 100), shortenChat(group.needs, 100))
    end
    announceGuild(message, "La búsqueda se publicó en Tártaro.")
end

save:SetScript("OnClick", function()
    local success, err, newEvent
    if not A.db or A.db ~= editingGuild then errorLabel:SetText("Cambió la hermandad activa."); return end
    if mode == "event" then
        local when = parseDate(dateField:GetText() .. " " .. timeField:GetText())
        if not when then errorLabel:SetText("Ingresá la fecha en DD/MM/AAAA y la hora en HH:MM."); return end
        local values, hasCaps = {}, false
        for i, fields in ipairs(editor.capFields) do
            local value = fields[2]:GetText()
            hasCaps = hasCaps or value ~= ""
            values[i] = value == "" and "0" or value
        end
        local caps = hasCaps and A.eventCaps(unpack(values))
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
end)

local function positionNotice(popup, rightOffset, topOffset, allowOverlap)
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
end

local daily = surface("TartaroDaily", 550, 146, 205)
daily:SetBackdropColor(0.095, 0.075, 0.078, 1)
badge(daily, 72)
local dailyTitle = text(daily, "Mensaje del día", "GameFontNormalLarge")
dailyTitle:SetPoint("TOPLEFT", 103, -18)
local dailyBody = text(daily, "")
dailyBody:SetPoint("TOPLEFT", 103, -47)
dailyBody:SetWidth(393)

local function dailyMessage()
    if A.db.daily then return A.db.daily.text, A.db.daily.rev end
    local motd = (C_GuildInfo and C_GuildInfo.GetMOTD) or GetGuildRosterMOTD
    local value = motd and motd()
    if (issecretvalue and issecretvalue(value)) or type(value) ~= "string" then return "" end
    return A.clean(value), 0
end

local dailyState = {dismissed = {}}
local eventPopup
local noticeAnchor = CreateFrame("Frame", nil, UIParent)
noticeAnchor:SetMovable(true)
noticeAnchor:SetClampedToScreen(true)

local function layoutNotices()
    local showDaily = daily:IsShown()
    local showEvent = eventPopup and eventPopup:IsShown()
    local showMain = win:IsShown()
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
        if not win.stackPoint then win.stackPoint = {win:GetPoint(1)} end
    elseif win.stackPoint then
        win:ClearAllPoints()
        win:SetPoint(unpack(win.stackPoint))
        win.stackPoint = nil
    end
    if not stackMain then win:SetScale(win.normalScale or 1) end
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
        x = math.max(stackWidth / 2, math.min(width - stackWidth / 2, width * x))
        y = math.max(stackHeight, math.min(height, height * y))
        if not saved then y = height - margin end
        noticeAnchor:ClearAllPoints()
        noticeAnchor:SetPoint("TOP", UIParent, "BOTTOMLEFT", x, y)
    end
    local offset = 0
    local function place(frame)
        frame:SetScale(scale)
        frame:ClearAllPoints()
        frame:SetPoint("TOP", noticeAnchor, "TOP", 0, -offset)
        offset = offset + frame:GetHeight() + gap
    end
    if showDaily then place(daily) end
    if showEvent then place(eventPopup) end
    if stackMain then
        offset = offset + skullHeight
        place(win)
    end
end

local function stopNoticeDrag(frame)
    local target = frame.dragTarget
    if not target then return end
    frame.dragTarget = nil
    target:StopMovingOrSizing()
    if target ~= noticeAnchor then return end
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
end

local function enableNoticeDrag(frame)
    frame:SetScript("OnDragStart", function(self)
        local target = self == win and not win.stackPoint and win or noticeAnchor
        if target == noticeAnchor then noticeAnchor.dragging = true end
        self.dragTarget = target
        target:StartMoving()
    end)
    frame:SetScript("OnDragStop", stopNoticeDrag)
    frame:HookScript("OnHide", stopNoticeDrag)
end

local function showDaily()
    if dailyState.db ~= A.db then
        dailyState = {db = A.db, dismissed = {}}
        if A.db then
            local state = dailyState
            C_Timer.After(6, function()
                if dailyState ~= state or A.db ~= state.db then return end
                state.ready = true
                showDaily()
            end)
        end
    end
    if not A.db or not dailyState.ready or combatWindowsBlocked() then
        daily:Hide()
        layoutNotices()
        return
    end
    local day = date("%Y-%m-%d", GetServerTime())
    if dailyState.day ~= day then
        dailyState.day = day
        dailyState.dismissed = {}
    end
    local value = dailyMessage()
    if not value or value == "" then daily:Hide(); layoutNotices(); return end
    local key = value:gsub("%s+", " ")
    if dailyState.dismissed[key] or editor:IsShown() then
        daily:Hide()
        layoutNotices()
        return
    end
    if dailyState.body ~= value then
        dailyState.body = value
        dailyBody:SetText(value)
        daily:SetHeight(math.max(110, dailyBody:GetStringHeight() + 66))
    end
    dailyState.visibleKey = key
    if not daily:IsShown() then daily:Show() end
    layoutNotices()
end

enableNoticeDrag(daily)
enableNoticeDrag(win)
daily.closeButton:HookScript("OnClick", function()
    if dailyState.visibleKey then dailyState.dismissed[dailyState.visibleKey] = true end
    layoutNotices()
end)
win:HookScript("OnHide", function() C_Timer.After(0, showDaily) end)
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
local offeredEvents, scheduledReminders = {}, {}
local reminderLead = 30 * 60

local function pendingEvent(id)
    if not A.db then return end
    local event = A.db.events[id]
    if not event or event.when <= GetServerTime() then return end
    local signups = A.db.signups[id]
    local mine = signups and signups[A.self]
    if not (mine and mine.joined) then return event end
end

local function noticeEvent(notice)
    if not notice or A.db ~= notice.db then return end
    if not notice.reminderAt then
        local event = pendingEvent(notice.id)
        if event and scheduledReminders[notice.id] ~= event.when then return event end
        return
    end
    local event = A.db.events[notice.id]
    local remaining = event and event.when - GetServerTime()
    if event and event.when == notice.reminderAt and remaining > 0 and remaining <= reminderLead then
        return event, remaining
    end
end

local function setPopupBody(event, remaining)
    local timing = ""
    if remaining then
        local minutes = math.ceil(remaining / 60)
        timing = "\nEmpieza en " .. minutes .. (minutes == 1 and " minuto." or " minutos.")
    end
    popupBody:SetText(event.title .. "\n" .. A.kinds[event.kind] .. " · "
        .. date("%d/%m/%Y %H:%M", event.when) .. " (hora local)" .. timing)
end

function A.showEventNotification()
    if eventPopup:IsShown() or editor:IsShown() or combatWindowsBlocked() then return end
    while #pendingEvents > 0 do
        local notice = table.remove(pendingEvents, 1)
        local event, remaining = noticeEvent(notice)
        if event then
            activeNotice = notice
            if notice.reminderAt then
                local records = A.db.eventReminders[notice.id] or {}
                A.db.eventReminders[notice.id] = records
                records[A.self] = event.when
                popupTitle:SetText("El evento empieza pronto")
            else
                popupTitle:SetText(notice.isNew and "Nuevo evento de hermandad" or "Evento pendiente")
            end
            setPopupBody(event, remaining)
            eventPopup:SetHeight(math.max(138, popupBody:GetStringHeight() + 104))
            eventPopup:Show()
            return
        end
    end
end

function A.notifyEvent(id, isNew)
    if offeredEvents[id] or not pendingEvent(id) then return end
    offeredEvents[id] = true
    pendingEvents[#pendingEvents + 1] = {id = id, db = A.db, isNew = isNew}
    A.showEventNotification()
end

local function sortEvents(events)
    table.sort(events, function(left, right)
        return left.when < right.when or (left.when == right.when and left.id < right.id)
    end)
end

local function checkEventReminders()
    if not A.db then return end
    if activeNotice and activeNotice.reminderAt then
        local event, remaining = noticeEvent(activeNotice)
        if event then setPopupBody(event, remaining) else eventPopup:Hide() end
    end
    local due, now = {}, GetServerTime()
    for id, event in pairs(A.db.events) do
        local records = A.db.eventReminders[id]
        if event.when > now and event.when - now <= reminderLead and scheduledReminders[id] ~= event.when
            and (not records or records[A.self] ~= event.when) then
            due[#due + 1] = event
            scheduledReminders[id] = event.when
        end
    end
    if #due == 0 then return end
    sortEvents(due)
    for index, event in ipairs(due) do
        table.insert(pendingEvents, index, {id = event.id, db = A.db, reminderAt = event.when})
    end
    if activeNotice and not activeNotice.reminderAt then
        if not scheduledReminders[activeNotice.id] then
            pendingEvents[#pendingEvents + 1] = activeNotice
        end
        eventPopup:Hide()
    end
    A.showEventNotification()
end
C_Timer.NewTicker(5, checkEventReminders)

function A.queuePendingEvents()
    pendingEvents, offeredEvents, scheduledReminders = {}, {}, {}
    if eventPopup:IsShown() then eventPopup:Hide() end
    if not A.db then return end
    local events = {}
    for id in pairs(A.db.events) do
        local event = pendingEvent(id)
        if event then events[#events + 1] = event end
    end
    sortEvents(events)
    checkEventReminders()
    for _, event in ipairs(events) do A.notifyEvent(event.id, false) end
end

eventPopup:SetScript("OnHide", function()
    activeNotice = nil
    A.showEventNotification()
    showDaily()
end)
enableNoticeDrag(eventPopup)
viewEvent:SetScript("OnClick", function()
    if editor:IsShown() then return end
    local notice = activeNotice
    eventPopup:Hide()
    if notice and A.db == notice.db then
        page, selectedEvent = "calendar", notice.id
        win:Show()
        scroll:SetVerticalScroll(0)
        A.refresh()
    end
end)

local accent = {1, 0.72, 0.46}

local function home()
    local now, nextEvent = GetServerTime()
    for _, event in pairs(A.db.events) do
        if event.when > now and (not nextEvent or event.when < nextEvent.when
            or event.when == nextEvent.when and event.id < nextEvent.id) then
            nextEvent = event
        end
    end
    win.nextEventAt = nextEvent and nextEvent.when
    columnWidth = 318
    line("Próximo evento", accent)
    if nextEvent then
        line(nextEvent.title)
        line(date("%d/%m/%Y · %H:%M", nextEvent.when) .. " (hora local)")
        if nextEvent.detail ~= "" then line(nextEvent.detail) end
        button("Ver evento", function()
            page, selectedEvent = "calendar", nextEvent.id
            scroll:SetVerticalScroll(0)
            A.refresh()
        end, true)
    else
        line("No hay eventos próximos.")
    end
    local eventHeight = y
    column, columnWidth, y = 334, 236, 0
    line("Mensaje del día", accent)
    local message = dailyMessage()
    line(message ~= "" and message or "Todavía no hay mensaje del día.")
    button("Ver avisos", function()
        page = "notices"
        scroll:SetVerticalScroll(0)
        A.refresh()
    end)
    local ordersTop = math.max(y, eventHeight)
    homeDivider:SetHeight(ordersTop)
    homeRule:SetPoint("TOPLEFT", 0, -(ordersTop + 7))
    column, columnWidth, y = 0, 570, ordersTop + 17
    line("Pedidos de fabricación", accent)
    local orders = A.listOrders()
    local requested, crafting = {}, {}
    for _, order in ipairs(orders) do
        local offers = A.db.offers[order.id] or {}
        if order.owner == A.self then
            local count = 0
            for id in pairs(offers) do
                if A.members[id] then count = count + 1 end
            end
            local status = count == 0 and "Esperando fabricante" or count == 1 and "1 oferta" or count .. " ofertas"
            requested[#requested + 1] = ("%d × %s · %s"):format(order.quantity, order.name, status)
        elseif offers[A.self] then
            crafting[#crafting + 1] = ("%d × %s · Para %s"):format(order.quantity, order.name, A.members[order.owner].name)
        end
    end
    local listTop = y
    columnWidth = 318
    line("Mis pedidos pendientes", accent)
    if #requested == 0 then line("No tenés pedidos pendientes.") end
    for _, summary in ipairs(requested) do line(summary) end
    local requestedHeight = y
    column, columnWidth, y = 334, 236, listTop
    line("Pedidos que me ofrecí a fabricar", accent)
    if #crafting == 0 then line("Todavía no te ofreciste para ningún pedido pendiente.") end
    for _, summary in ipairs(crafting) do line(summary) end
    column, columnWidth, y = 0, 570, math.max(y, requestedHeight)
    homeOrdersDivider:SetPoint("TOPLEFT", 319, -listTop)
    homeOrdersDivider:SetHeight(y - listTop)
    button("Ver pedidos", function()
        page, professionView = "professions", "orders"
        scroll:SetVerticalScroll(0)
        A.refresh()
    end)
end

local function eventParticipant(event, entry, label)
    local frame = line(label)
    if entry.id == A.self then return end
    if not frame.participantMenu then
        local control = CreateFrame("Button", nil, frame)
        control:SetAllPoints(frame)
        control:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        control:SetScript("OnEnter", function() frame.label:SetTextColor(unpack(accent)) end)
        control:SetScript("OnLeave", function() frame.label:SetTextColor(0.96, 0.90, 0.82) end)
        frame.participantMenu = control
    end
    local db, id, eventId = A.db, entry.id, event.id
    local function currentParticipant()
        if A.db ~= db or not A.can(A.me, "event") then return end
        local current = db.events[eventId]
        local signups = db.signups[eventId]
        if not current or current.when <= GetServerTime() or not signups or not signups[id] or not signups[id].joined then return end
        return A.members[id]
    end
    frame.participantMenu:SetScript("OnClick", function(owner)
        local member = currentParticipant()
        if not member then return end
        MenuUtil.CreateContextMenu(owner, function(_, root)
            root:CreateTitle(member.name)
            local inRaid = IsInRaid()
            local invite = root:CreateButton(inRaid and "Invitar a la banda" or "Invitar al grupo", function()
                local target = currentParticipant()
                if not target or target.online == false then return end
                local send = C_PartyInfo and C_PartyInfo.InviteUnit or InviteUnit
                if send then
                    local ok, result = pcall(send, target.name)
                    if ok and result ~= false then return end
                end
                if ChatFrame_OpenChat then
                    ChatFrame_OpenChat("/invite " .. target.name)
                else
                    print("Tártaro: WoW no pudo enviar la invitación.")
                end
            end)
            invite:SetEnabled(member.online ~= false)
            local convert = C_PartyInfo and C_PartyInfo.ConvertToRaid or ConvertToRaid
            local isLeader = IsInGroup() and UnitIsGroupLeader("player")
            if convert and not inRaid and (not issecretvalue or not issecretvalue(isLeader)) and isLeader then
                root:CreateButton("Convertir grupo en banda", function()
                    if not currentParticipant() or IsInRaid() or not IsInGroup() then return end
                    local leader = UnitIsGroupLeader("player")
                    if (not issecretvalue or not issecretvalue(leader)) and leader then convert() end
                end)
            end
        end)
    end)
    frame.participantMenu:Show()
end

local function calendar()
    local allowed = A.can(A.me, "event")
    local events = {}
    for _, event in pairs(A.db.events) do
        if event.when > GetServerTime() then events[#events + 1] = event end
    end
    table.sort(events, function(left, right) return left.when < right.when or left.when == right.when and left.id < right.id end)
    win.nextEventAt = events[1] and events[1].when
    local current = A.db.events[selectedEvent or ""]
    if not current or current.when <= GetServerTime() then current = events[1] end
    columnWidth = 178
    if allowed then button("Nuevo evento", function() openEditor("event") end) end
    for _, event in ipairs(events) do
        local id = event.id
        local frame = row()
        frame.button:SetSize(170, 53)
        frame.button:SetText(date("%d/%m · %H:%M", event.when) .. "\n" .. event.title)
        frame.button:GetFontString():SetWidth(156)
        frame.button:GetFontString():SetMaxLines(2)
        frame.button:SetStyle(id == current.id)
        frame.button:SetScript("OnClick", function()
            selectedEvent = id
            scroll:SetVerticalScroll(0)
            A.refresh()
        end)
        frame.button:Show()
        frame:SetHeight(61)
        y = y + 61
    end
    local listHeight = y
    column, columnWidth, y = 205, 365, 0
    if not current then line("No hay eventos próximos."); return end
    line(current.title, accent)
    line(A.kinds[current.kind] .. " · " .. date("%d/%m/%Y %H:%M", current.when) .. " (hora local)")
    if current.detail ~= "" then line(current.detail) end
    local signups = A.db.signups[current.id] or {}
    local mine = signups[A.self]
    local entries, counts, status = A.eventAttendance(current)
    if current.caps then
        for i, role in ipairs(A.eventRoleOrder) do
            if current.caps[i] > 0 then
                line(("%s · %d/%d"):format(A.eventRoles[role], math.min(counts[role], current.caps[i]), current.caps[i]), accent)
                if counts[role] > current.caps[i] then line(("Suplentes · %d"):format(counts[role] - current.caps[i])) end
                if not mine or not mine.joined or mine.role ~= role then
                    local choice = role
                    button((mine and mine.joined and "Cambiar a " or "Anotarme como ") .. A.eventRoles[choice], function()
                        A.signup(current.id, choice)
                        A.refresh()
                    end, not (mine and mine.joined))
                end
            end
        end
    end
    if mine and mine.joined then
        if current.caps then line("Tu inscripción · " .. (status[A.self] or "Elegí un rol"), accent) end
        button("Quitar mi inscripción", function() A.signup(current.id); A.refresh() end)
    elseif not current.caps then
        button("Quiero participar", function() A.signup(current.id); A.refresh() end, true)
    end
    line("Anotados: " .. #entries, accent)
    if allowed then
        for _, entry in ipairs(entries) do
            local signup = entry.signup
            local suffix = current.caps and (" · " .. (A.eventRoles[signup.role] or "Sin rol")
                .. " · " .. (status[entry.id] or "Pendiente")) or ""
            eventParticipant(current, entry, signup.name .. suffix)
        end
        button("Editar evento", function() openEditor("event", current) end)
    end
    y = math.max(y, listHeight)
end

local function notices()
    local allowed = A.can(A.me, "notice")
    line("Mensaje del día", accent)
    local value = dailyMessage()
    line(value ~= "" and value or "Todavía no hay mensaje del día.")
    if allowed then
        button("Editar mensaje del día", function() openEditor("daily") end)
        button("Publicar aviso", function() openEditor("notice") end)
    end
    line("Avisos de la hermandad", accent)
    local records = {}
    for _, notice in pairs(A.db.notices) do records[#records + 1] = notice end
    table.sort(records, function(left, right) return left.when > right.when end)
    if #records == 0 then line("Todavía no hay avisos.") end
    for _, notice in ipairs(records) do
        line(date("%d/%m %H:%M", notice.when) .. " · " .. notice.name, accent)
        line(notice.text)
    end
end

local function permissions()
    line("Permisos por rango", accent)
    if not A.canManagePermissions(A.me) then line("El líder y los sublíderes administran los permisos."); return end
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
        local labels = {notice = "Publicar avisos", event = "Crear y editar eventos",
            call = "Lanzar llamados a las armas", group = "Publicar búsquedas de grupo"}
        for _, permission in ipairs({"notice", "event", "call", "group"}) do
            local field = permission
            check(labels[field], A.can(member, field), function(enabled)
                A.setGrant(index, field, enabled)
                A.refresh()
            end)
        end
    end
end

local function callVolume()
    local saved = TartaroDB and TartaroDB.callSoundVolume
    if type(saved) == "number" and saved >= 0 and saved <= 100 and saved % 20 == 0 then return saved end
    return TartaroDB and TartaroDB.callSound == false and 0 or 100
end

local callSounds = {
    {id = "tartaro", label = "Tambores y doble grito", file = "CallToArms", duration = 4.15},
    {id = "nature", label = "Nature", file = "CallNature", duration = 4.65},
}

local function selectedCallSound()
    return TartaroDB and TartaroDB.callSoundChoice == "nature" and callSounds[2] or callSounds[1]
end

function A.playCallSound(isAlert)
    local volume = callVolume()
    if volume == 0 or not PlaySoundFile then return false end
    local suffix = volume == 100 and "" or tostring(volume)
    local sound = selectedCallSound()
    local path = "Interface\\AddOns\\Tartaro\\" .. sound.file .. suffix .. ".mp3"
    if isAlert then return A.playCallAlert(path, sound.duration) end
    return PlaySoundFile(path, "SFX")
end

local optionsPanel = CreateFrame("Frame", nil, win)
optionsPanel:SetPoint("TOPLEFT", 18 + sidebarWidth, -(headerHeight + 20))
optionsPanel:SetSize(550, 224)
optionsPanel:Hide()
do
    local title = text(optionsPanel, "Llamado a las armas", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT")
    local versionLabel = text(optionsPanel, "")
    versionLabel:SetPoint("TOPRIGHT")
    function A.updateVersionLabel()
        local label = A.addonVersion and ("Versión " .. A.addonVersion) or "Versión sin datos"
        if A.newerAddonVersion then label = label .. " · Detectada " .. A.newerAddonVersion end
        versionLabel:SetText(label)
    end
    A.updateVersionLabel()
    local handle
    local function stopPreview()
        if handle and StopSound then StopSound(handle) end
        handle = nil
    end
    local soundButtons = {}
    local function showSoundChoice()
        local selected = selectedCallSound().id
        for id, control in pairs(soundButtons) do control:SetStyle(id == selected) end
    end
    for index, sound in ipairs(callSounds) do
        local id = sound.id
        local control = copperButton(optionsPanel)
        control:SetPoint("TOPLEFT", index == 1 and 0 or 198, -34)
        control:SetSize(index == 1 and 188 or 114, 27)
        control:SetText(sound.label)
        control:SetScript("OnClick", function()
            stopPreview()
            TartaroDB.callSoundChoice = id
            showSoundChoice()
        end)
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
    preview:SetText("▶ Probar")
    preview:SetScript("OnClick", function()
        stopPreview()
        local played
        played, handle = A.playCallSound()
        if not played then print("Tártaro: WoW no pudo reproducir el sonido del llamado.") end
    end)
    local combat = CreateFrame("CheckButton", nil, optionsPanel, "UICheckButtonTemplate")
    combat:SetPoint("TOPLEFT", -4, -146)
    local combatLabel = text(combat, "Ocultar ventanas de Tártaro durante el combate")
    combatLabel:SetPoint("LEFT", combat, "RIGHT", 4, 0)
    combat:SetScript("OnClick", function(self)
        TartaroDB.hideWindowsInCombat = self:GetChecked() and true or false
        A.updateCombatWindows()
    end)
    local reset = copperButton(optionsPanel)
    reset:SetPoint("TOPLEFT", 0, -188)
    reset:SetSize(220, 28)
    reset:SetText("Restablecer configuración")
    reset:SetStyle(false)
    reset:SetScript("OnClick", function() StaticPopup_Show("TARTARO_RESET_OPTIONS") end)
    local function showVolume(volume)
        value:SetText("Volumen del llamado · " .. (volume == 0 and "Silenciado" or volume .. "%"))
        preview:SetEnabled(volume ~= 0)
        preview:SetStyle(false, volume ~= 0)
    end
    slider:SetScript("OnValueChanged", function(_, volume)
        TartaroDB.callSoundVolume = volume
        showVolume(volume)
        stopPreview()
    end)
    local function syncOptions()
        local volume = callVolume()
        slider:SetValue(volume)
        showVolume(volume)
        showSoundChoice()
        combat:SetChecked(TartaroDB.hideWindowsInCombat ~= false)
    end
    optionsPanel.sync = syncOptions
    optionsPanel:SetScript("OnShow", syncOptions)
end

local function settings()
    line("Ajustes de mapa", accent)
    line("Los marcadores aparecen en el mapa del mundo de WoW.")
    check("Compartir mi ubicación con la hermandad", TartaroDB.shareLocation ~= false, A.setSharing)
    line("Podés seguir viendo a tus compañeros con esta opción desactivada.")
    line(A.locationStatus(), accent)
    local live = 0
    for _, position in pairs(A.positions) do
        if position.expires > GetTime() then live = live + 1 end
    end
    line("Ubicaciones recientes recibidas: " .. live)
    if A.worldMapStatus then line("Último mapa del mundo: " .. A.worldMapStatus) end
    for _, call in pairs(A.calls) do
        if call.expires > GetServerTime() then
            line(call.name .. " · " .. A.callLocation(call), accent)
            button("Ver llamado", function() A.showCall(call) end)
            if call.author == A.self then
                local names = {}
                for id in pairs(A.callRequests) do
                    if A.members[id] then names[#names + 1] = A.members[id].name end
                end
                table.sort(names)
                line("Pedidos de grupo · " .. #names, accent)
                for _, name in ipairs(names) do line(name) end
                button("Cerrar llamado", function() A.closeCall(call) end)
            end
        end
    end
end

local memberColumns = {10, 164, 207, 367, 470, 570}
local detectedFirst

local function memberRow(values, index, role, online, detected, class)
    local frame = row()
    if not frame.memberCells then
        frame.memberCells = {}
        frame.memberBackground = frame:CreateTexture(nil, "BACKGROUND")
        frame.memberBackground:SetAllPoints()
        for i = 1, #memberColumns - 1 do
            local cell = text(frame, "")
            cell:SetPoint("LEFT", memberColumns[i], 0)
            cell:SetWidth(memberColumns[i + 1] - memberColumns[i] - 8)
            cell:SetMaxLines(1)
            frame.memberCells[i] = cell
        end
    end
    local muted = {0.7, 0.65, 0.61}
    local green = {0.55, 0.82, 0.65}
    local classColor = class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
    local colors = {
        classColor and {classColor.r, classColor.g, classColor.b}, nil, role == "TANK" and {0.54, 0.74, 0.96}
            or role == "HEALER" and green or role == "DAMAGER" and accent
            or role and role:find("/", 1, true) and accent or muted,
        online and green or muted, detected and green or muted,
    }
    for i, cell in ipairs(frame.memberCells) do
        cell:SetText(values[i])
        cell:SetTextColor(unpack(index == 0 and accent or colors[i] or {0.96, 0.90, 0.82}))
        cell:Show()
    end
    if index == 0 then
        if not frame.memberSort then
            local control = CreateFrame("Button", nil, frame)
            control:SetPoint("LEFT", memberColumns[5], 0)
            control:SetSize(memberColumns[6] - memberColumns[5] - 8, 23)
            local label = text(control, "Tártaro")
            label:SetPoint("LEFT")
            label:SetTextColor(unpack(accent))
            control:SetScript("OnClick", function()
                detectedFirst = not detectedFirst
                scroll:SetVerticalScroll(0)
                A.refresh()
            end)
            control:SetScript("OnEnter", function(self)
                label:SetTextColor(1, 0.92, 0.80)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(detectedFirst == true and "Mostrar primero a los miembros sin detectar"
                    or "Mostrar primero a los miembros con Tártaro detectado")
                GameTooltip:Show()
            end)
            control:SetScript("OnLeave", function()
                label:SetTextColor(unpack(accent))
                GameTooltip:Hide()
            end)
            frame.memberSort = control
        end
        frame.memberCells[5]:Hide()
        frame.memberSort:Show()
    end
    local shade = index == 0 and 0.23 or index % 2 == 0 and 0.135 or 0.17
    frame.memberBackground:SetColorTexture(shade, shade * 0.76, shade * 0.68, 1)
    frame.memberBackground:Show()
    frame:SetHeight(27)
    y = y + 29
end

local function members()
    local list = {}
    for _, member in pairs(A.members) do list[#list + 1] = member end
    table.sort(list, function(left, right)
        if detectedFirst ~= nil then
            local leftDetected, rightDetected = A.hasUsedAddon(left), A.hasUsedAddon(right)
            if leftDetected ~= rightDetected then return leftDetected == detectedFirst end
        end
        if (left.online == true) ~= (right.online == true) then return left.online == true end
        return left.name < right.name
    end)
    line("Miembros de la hermandad", accent)
    memberRow({"Personaje", "Nivel", "Rol", "Conexión"}, 0)
    for index, member in ipairs(list) do
        local role = A.db.roles[member.id]
        local detected = A.hasUsedAddon(member)
        local connection = member.online == true and "Conectado"
            or member.online == false and "Desconectado" or "Sin datos"
        memberRow({
            member.name, member.level and tostring(member.level) or "—", A.roleLabel(role, member.class),
            connection, detected and "Detectado" or "Sin detectar",
        }, index, role, member.online, detected, member.class)
    end
    if #list == 0 then line("Esperando la lista de la hermandad.") end
    line("La detección de Tártaro se guarda entre sesiones.")
end

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
recipeSearch:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
local recipeLabel = text(professionControls, "Receta, objeto o fabricante")
recipeLabel:SetPoint("TOPLEFT", 1, -34)
local professionButtons = {}
for index, option in ipairs({{"recipes", "Buscar recetas"}, {"orders", "Pedidos"}}) do
    local key = option[1]
    local control = copperButton(professionControls)
    control:SetPoint("TOPLEFT", (index - 1) * 141, 0)
    control:SetSize(133, 26)
    control:SetText(option[2])
    control:SetScript("OnClick", function()
        professionView = key
        recipeSearch:ClearFocus()
        scroll:SetVerticalScroll(0)
        A.refresh()
    end)
    professionButtons[key] = control
end
recipeSearch:SetScript("OnTextChanged", function()
    recipePage, selectedRecipe = 1, nil
    scroll:SetVerticalScroll(0)
    A.invalidate("recipes")
end)

local function whisperTarget(name)
    local character, suffix = name:match("^(.-)%-([^%-]+)$")
    if character and suffix and A.key(suffix) == A.realm then return character end
    return name
end

local function openWhisperDraft(target, draft)
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
end

local function whisperRecipe(member, recipe)
    openWhisperDraft(whisperTarget(member.name), "Hola, ¿me podrías fabricar " .. recipe .. "?")
end

local function sendGroupWhisper(name, draft)
    local target = whisperTarget(name)
    local send = C_ChatInfo and C_ChatInfo.SendChatMessage or SendChatMessage
    local blocked = C_ChatInfo and C_ChatInfo.InChatMessagingLockdown and C_ChatInfo.InChatMessagingLockdown()
    if send and not blocked then
        local ok, result = pcall(send, draft, "WHISPER", nil, target)
        if ok and result ~= false then return "Solicitud enviada" end
    end
    if openWhisperDraft(target, draft) then return "Borrador en el chat" end
end

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
        box:SetScript("OnEscapePressed", function() form:Hide() end)
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
    local recipe, guild
    local function updateReagents()
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
    end
    form.updateReagents = updateReagents
    inputs[1][2]:SetScript("OnTextChanged", updateReagents)
    form:SetScript("OnShow", updateReagents)
    local function openForm(selected)
        if not A.db then return end
        recipe, guild = selected, A.db
        title:SetText(recipe and ("Pedir " .. (recipe.object or recipe.name)) or "Estoy armando grupo")
        title:SetWidth(350)
        title:SetMaxLines(2)
        local captions = recipe and {"Cantidad"} or {"Actividad", "Lugar", "Roles que faltan"}
        inputs[1][2]:SetNumeric(recipe ~= nil)
        inputs[1][2]:SetMaxLetters(recipe and 3 or 55)
        for i, input in ipairs(inputs) do
            input[1]:SetShown(captions[i] ~= nil)
            input[2]:SetShown(captions[i] ~= nil)
            input[1]:SetText(captions[i] or "")
            input[2]:SetText(recipe and i == 1 and "1" or "")
        end
        materials:SetShown(recipe ~= nil)
        reagents:SetShown(recipe ~= nil)
        reagentScroll:SetVerticalScroll(0)
        materials:SetChecked(false)
        errorText:SetText("")
        form:SetHeight(recipe and 378 or 275)
        form:Show()
        updateReagents()
        form:Raise()
    end
    function A.openOrderForm(recipe) openForm(recipe) end
    function A.openGroupForm() openForm() end
    publish:SetScript("OnClick", function()
        if A.db ~= guild then form:Hide(); return end
        local ok, err
        if recipe then
            ok, err = A.createOrder(recipe, inputs[1][2]:GetText(), materials:GetChecked() and true or false)
        else
            ok, err = A.publishGroup(inputs[1][2]:GetText(), inputs[2][2]:GetText(), inputs[3][2]:GetText())
        end
        if not ok then errorText:SetText(err or "No se pudo publicar."); return end
        if recipe then
            professionView = "orders"
            scroll:SetVerticalScroll(0)
        else
            announceGroup(ok)
        end
        form:Hide()
        A.refresh()
    end)
    form:SetScript("OnHide", function()
        for _, input in ipairs(inputs) do input[2]:ClearFocus() end
    end)
end

local callPopup = surface("TartaroCallNotification", 386, 146, 0)
callPopup:SetFrameStrata("FULLSCREEN_DIALOG")
callPopup:SetBackdropColor(0.095, 0.075, 0.078, 1)
callPopup:ClearAllPoints()
callPopup:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -34, -112)
local callMoved
callPopup:HookScript("OnDragStop", function() callMoved = true end)

local function positionCall()
    if not callMoved then positionNotice(callPopup, 34, 112, true) end
end

win:HookScript("OnDragStop", function()
    if callPopup:IsShown() then positionCall() end
end)
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

local function currentCall()
    if not visibleCall or A.calls[visibleCall.author] ~= visibleCall or visibleCall.expires <= GetServerTime() then return end
    if not A.can(A.members[visibleCall.author], "call") then return end
    return visibleCall
end

local function updateRequestButton(call)
    local own = call.author == A.self
    requestGroup:SetText(own and "Cerrar llamado" or call.requestState or "Pedir grupo")
    requestGroup:SetEnabled(own or not call.requestState)
    requestGroup:SetStyle(false, own or not call.requestState)
end

local function callMessage(call, separator)
    return call.name .. " pide refuerzos para PvP de mundo." .. separator .. A.callLocation(call)
end

function A.showCall(call)
    visibleCall = call
    if not currentCall() or combatWindowsBlocked() then return end
    callBody:SetText(callMessage(call, "\n"))
    callPopup:SetHeight(math.max(144, callBody:GetStringHeight() + 91))
    updateRequestButton(call)
    callPopup:Show()
    positionCall()
    callPopup:Raise()
end

callMap:SetScript("OnClick", function()
    local call = currentCall()
    if call then A.openCallMap(call) end
end)

requestGroup:SetScript("OnClick", function()
    local call = currentCall()
    if not call then return end
    if call.author == A.self then A.closeCall(call); return end
    if call.requestState then return end
    local tracked = A.send("CTJ", call.author, call.when)
    local draft = "Me sumo al PvP de mundo en " .. A.callLocation(call) .. ". ¿Me invitás al grupo?"
    call.requestState = sendGroupWhisper(call.name, draft)
    if not call.requestState and tracked then call.requestState = "Solicitud registrada" end
    updateRequestButton(call)
end)

C_Timer.NewTicker(1, function()
    if callPopup:IsShown() and not currentCall() then callPopup:Hide() end
end)

StaticPopupDialogs["TARTARO_CONFIRM_CALL"] = {
    text = "¿Pedir refuerzos para PvP de mundo en %s?",
    button1 = "Lanzar llamado",
    button2 = "Cancelar",
    timeout = 0,
    hideOnEscape = true,
    OnAccept = function(_, data)
        if A.db ~= data.db then return end
        local success, err = A.sendCall(data.position)
        if not success then print("Tártaro: " .. err); return end
        local call = A.calls[A.self]
        A.showCall(call)
        announceGuild(callMessage(call, " "), "El llamado se publicó en Tártaro.")
        A.refresh()
    end,
}

function A.confirmCall()
    local position, err = A.prepareCall()
    if not position then print("Tártaro: " .. err); return end
    StaticPopup_Show("TARTARO_CONFIRM_CALL", A.callLocation(position), nil, {db = A.db, position = position})
end

local callLauncher = copperButton(Minimap)
callLauncher:SetSize(148, 25)
function callLauncher:ResetPosition()
    self:ClearAllPoints()
    self:SetPoint("TOP", Minimap, "BOTTOM", 0, -9)
end
callLauncher:ResetPosition()
callLauncher:SetFrameLevel(Minimap:GetFrameLevel() + 8)
callLauncher:SetText("Llamado a las armas")
callLauncher:SetStyle(false, true)
callLauncher:SetMovable(true)
callLauncher:SetClampedToScreen(true)
callLauncher:RegisterForClicks("LeftButtonUp")
callLauncher:RegisterForDrag("LeftButton")
callLauncher:Hide()

do
    local dragged, moving
    local function place(x, y)
        local scale = UIParent:GetEffectiveScale() / callLauncher:GetEffectiveScale()
        callLauncher:ClearAllPoints()
        callLauncher:SetPoint("CENTER", UIParent, "BOTTOMLEFT",
            x * UIParent:GetWidth() * scale, y * UIParent:GetHeight() * scale)
    end

    local function stopDrag(self)
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
    end

    callLauncher:RegisterEvent("PLAYER_LOGIN")
    callLauncher:SetScript("OnEvent", function()
        local saved = TartaroDB and TartaroDB.callLauncherPosition
        if type(saved) == "table" and type(saved.x) == "number" and type(saved.y) == "number"
            and saved.x >= 0 and saved.x <= 1 and saved.y >= 0 and saved.y <= 1 then
            place(saved.x, saved.y)
        end
    end)
    callLauncher:SetScript("OnMouseDown", function() dragged = false end)
    callLauncher:SetScript("OnDragStart", function(self)
        dragged, moving = true, true
        self:StartMoving()
    end)
    callLauncher:SetScript("OnDragStop", stopDrag)
    callLauncher:SetScript("OnHide", stopDrag)
    callLauncher:SetScript("OnClick", function()
        if not dragged then A.confirmCall() end
    end)
end

local function memberOrder(left, right)
    if (left.online == true) ~= (right.online == true) then return left.online == true end
    return left.name < right.name
end

local function professionMembers()
    local members = {}
    for id, profile in pairs(A.db.professions) do
        local member = A.members[id]
        if member and next(profile.list) then members[#members + 1] = member end
    end
    table.sort(members, memberOrder)
    return members
end

local function level(profession)
    return profession.rank .. "/" .. profession.maximum
end

local function connection(member)
    if member.id == A.self or member.online == true then return "En línea" end
    return member.online == false and "Desconectado" or "Estado desconocido"
end

local rarityNames = {
    [0] = "Pobre", [1] = "Común", [2] = "Poco común", [3] = "Raro", [4] = "Épico", [5] = "Legendario",
}
local filters = {}
local function refreshFilters()
    recipePage, selectedRecipe = 1, nil
    scroll:SetVerticalScroll(0)
    A.refresh()
end

local function addRecipeFilter(x, width, label, callback)
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
end

local function filterMenu(owner, title, options, field)
    MenuUtil.CreateContextMenu(owner, function(_, root)
        root:CreateTitle(title)
        if root.SetScrollMode and #options > 9 then root:SetScrollMode(240) end
        root:CreateRadio(options.all, function() return recipeFilters[field] == nil end, function()
            recipeFilters[field], recipeFilters[field .. "Label"] = nil, nil
            refreshFilters()
        end)
        for _, option in ipairs(options) do
            local value, label = option[1], option[2]
            root:CreateRadio(label, function() return recipeFilters[field] == value end, function()
                recipeFilters[field], recipeFilters[field .. "Label"] = value, label
                refreshFilters()
            end)
        end
    end)
end

local memberFilter = addRecipeFilter(235, 117, "Todos los miembros", function(self)
    local options = {all = "Todos los miembros", {"online", "En línea"}, {"offline", "Desconectados"}}
    for _, member in ipairs(professionMembers()) do options[#options + 1] = {member.id, member.name} end
    filterMenu(self, "Fabricantes", options, "member")
end)
local professionFilter = addRecipeFilter(362, 168, "Todas las profesiones", function(self)
    local options, names = {all = "Todas las profesiones"}, {}
    for _, member in ipairs(professionMembers()) do
        for id, prof in pairs(A.db.professions[member.id].list) do
            if prof.recipes and next(prof.recipes) then names[id] = names[id] or prof.name end
        end
    end
    for id, name in pairs(names) do options[#options + 1] = {id, name} end
    table.sort(options, function(left, right) return left[2] < right[2] end)
    filterMenu(self, "Profesión", options, "profession")
end)
local rarityFilter = addRecipeFilter(540, 130, "Todas las rarezas", function(self)
    local options = {all = "Todas las rarezas"}
    for rarity = 0, 5 do options[#options + 1] = {rarity, rarityNames[rarity]} end
    filterMenu(self, "Rareza", options, "rarity")
end)
local boundFilter = addRecipeFilter(680, 86, "Ocultar BoP", function()
    recipeFilters.hideBound = not recipeFilters.hideBound
    refreshFilters()
end)
addRecipeFilter(776, 68, "Limpiar", function()
    recipeFilters = {hideBound = false}
    recipeSearch:SetText("")
    refreshFilters()
end)

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

local function changePage(delta)
    recipePage = math.max(1, math.min(pages, recipePage + delta))
    selectedRecipe = nil
    scroll:SetVerticalScroll(0)
    A.refresh()
end

local function pageButton(label, offset, delta)
    local control = copperButton(recipeList)
    control:SetSize(34, 24)
    control:SetPoint("BOTTOMRIGHT", offset, 2)
    control:SetText(label)
    control:SetStyle(false)
    control:SetScript("OnClick", function() changePage(delta) end)
    return control
end
local previousPage, nextPage = pageButton("‹", -55, -1), pageButton("›", -14, 1)

local function itemHover(frame, item)
    if not item or item == 0 then return end
    GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink("item:" .. item)
    GameTooltip:Show()
end

local function recipeRow(index, result)
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
        control:SetScript("OnEnter", function(self) itemHover(self, self.item) end)
        control:SetScript("OnLeave", function() GameTooltip:Hide() end)
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
    control:SetScript("OnClick", function()
        selectedRecipe = result.spell
        scroll:SetVerticalScroll(0)
        A.refresh("recipeDetail")
    end)
    control:Show()
end

local function updatePage(first, last, count)
    for index = last - first + 2, #recipeRows do recipeRows[index]:Hide() end
    pageLabel:SetText(count > 0 and (first .. "–" .. last .. " de " .. count .. " recetas") or "Sin recetas")
    previousPage:SetEnabled(recipePage > 1 and count > 0)
    nextPage:SetEnabled(recipePage < pages and count > 0)
end

local function recipeDetail(title, subtitle, texture, item, action, color)
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
        detail:SetScript("OnEnter", function(self) itemHover(self, self.item) end)
        detail:SetScript("OnLeave", function() GameTooltip:Hide() end)
        frame.detail = detail
    end
    local detail = frame.detail
    detail.icon:SetTexture(texture)
    detail.icon:SetShown(texture ~= nil)
    detail.name:ClearAllPoints()
    detail.name:SetPoint("LEFT", texture and 37 or 8, 0)
    detail.name:SetPoint("RIGHT", action and -210 or -100, 0)
    detail.name:SetText(title)
    detail.name:SetTextColor(unpack(color or {0.96, 0.90, 0.82}))
    detail.meta:ClearAllPoints()
    detail.meta:SetPoint("RIGHT", action and -105 or -9, 0)
    detail.meta:SetText(subtitle or "")
    detail.action:SetShown(action ~= nil)
    detail.action:SetScript("OnClick", action)
    detail.item = item
    detail:EnableMouse(item ~= nil and item > 0)
    frame:SetHeight(28)
    detail:Show()
    y = y + 31
end

local function renderRecipeDetails(selected)
    recipeDetail(selected.object or selected.name, "", selected.icon, selected.item, nil, accent)
    line(selected.profession)
    button("Lo necesito fabricar", function() A.openOrderForm(selected) end, true)
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
            recipeDetail(name or ("Objeto " .. item), A.professionItemCount(item) .. "/" .. materials[item], texture, item)
        end
    end
    line("Fabricantes · " .. #selected.crafters, accent)
    for _, crafter in ipairs(selected.crafters) do
        local member, profession = crafter.member, crafter.profession
        local action
        if member.id ~= A.self then action = function() whisperRecipe(member, selected.object or selected.name) end end
        local class = member.class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[member.class]
        local color = class and {class.r, class.g, class.b}
        recipeDetail(member.name, connection(member) .. " · " .. level(profession), nil, nil, action, color)
    end
end

local lastDrawnRecipes
local function recipeResults(onlyDetail)
    local results, bySpell = A.searchRecipes(recipeSearch:GetText(), recipeFilters)
    onlyDetail = onlyDetail and lastDrawnRecipes == results
    lastDrawnRecipes = results
    pages = math.ceil(#results / pageSize)
    if pages == 0 then updatePage(1, 0, 0); line("No se encontraron recetas."); return end
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
end

local orderCards = {}
local function renderOrder(order)
    local owner = A.members[order.owner]
    local own = order.owner == A.self
    line(("%d × %s"):format(order.quantity, order.name), accent, true)
    line(own and "Mi pedido" or owner.name, nil, true)
    line(order.materials and (own and "Ya tengo los materiales" or "Ya tiene los materiales")
        or "Necesita materiales", order.materials and {0.68, 0.83, 0.69} or nil, true)
    if order.unverified then line("Copia pendiente de confirmar", nil, true); return end
    if own then
        local offers = {}
        for id in pairs(A.db.offers[order.id] or {}) do
            if A.members[id] then offers[#offers + 1] = A.members[id] end
        end
        table.sort(offers, memberOrder)
        for _, crafter in ipairs(offers) do
            button(crafter.name .. " · Susurrar", function()
                openWhisperDraft(whisperTarget(crafter.name), "Hola, ¿coordinamos mi pedido de " .. order.name .. "?")
            end)
        end
        local actionX, actionY, actionWidth = column, y, columnWidth
        button("Marcar como completado", function()
            if not A.closeOrder(order, true) then print("Tártaro: no se pudo completar el pedido.") end
        end, true, 166)
        column, columnWidth, y = actionX + 172, actionWidth - 172, actionY
        button("Cancelar", function()
            if not A.closeOrder(order) then print("Tártaro: no se pudo cancelar el pedido.") end
        end)
        column, columnWidth = actionX, actionWidth
    elseif A.db.offers[order.id] and A.db.offers[order.id][A.self] then
        line("Te ofreciste para fabricar este pedido.")
        button("Susurrar al solicitante", function()
            openWhisperDraft(whisperTarget(owner.name), "Hola, puedo fabricar tu pedido de " .. order.name .. ".")
        end, false, 165)
    elseif A.canCraftOrder(order) then
        button("Puedo fabricarlo", function() A.offerOrder(order) end, true, 138)
    end
end

local function orderGrid(orders)
    local maxWidth = columnWidth
    local gap, pad = 10, 9
    local cardWidth = (maxWidth - gap) / 2
    for first = 1, #orders, 2 do
        local top, bottom = y, y
        local last = math.min(first + 1, #orders)
        for index = first, last do
            local left = (index - first) * (cardWidth + gap)
            column, columnWidth, y = left + pad, cardWidth - 2 * pad, top + pad
            renderOrder(orders[index])
            bottom = math.max(bottom, y + pad)
            if not orderCards[index] then
                orderCards[index] = content:CreateTexture(nil, "BACKGROUND")
                orderCards[index]:SetColorTexture(0.15, 0.105, 0.095, 1)
            end
            local card = orderCards[index]
            card:ClearAllPoints()
            card:SetPoint("TOPLEFT", left, -top)
            card:Show()
        end
        for index = first, last do orderCards[index]:SetSize(cardWidth, bottom - top) end
        y = bottom + gap
    end
    column, columnWidth = 0, maxWidth
end

local function professions(onlyDetail)
    if professionView == "orders" then
        line("Pedidos de fabricación", accent)
        local orders, completed = A.listOrders()
        if #orders == 0 then line("No hay pedidos pendientes.") end
        orderGrid(orders)
        if #completed > 0 then
            line("Pedidos completados", accent)
            for _, order in ipairs(completed) do
                line(("%d × %s · %s"):format(order.quantity, order.name, A.members[order.owner].name))
            end
        end
        return
    end
    recipeResults(onlyDetail)
end

function A.renderGroups()
    line("Buscar grupo", accent)
    if A.can(A.me, "group") then button("Estoy armando grupo", A.openGroupForm, true) end
    local active = {}
    for id, group in pairs(A.groups) do
        if group.version == 1 and group.when + 1800 > GetServerTime() and A.can(A.members[id], "group")
            and (A.members[id].online ~= false or id == A.self) then
            active[#active + 1] = group
        end
    end
    table.sort(active, function(left, right) return left.when > right.when end)
    if #active == 0 then line("No hay grupos buscando gente.") end
    for _, group in ipairs(active) do
        local owner = A.members[group.owner]
        line(group.activity .. " · " .. owner.name, accent)
        line(group.location .. " · Faltan " .. group.needs)
        if group.owner == A.self then
            button("Cerrar búsqueda", function() A.closeGroup(group) end)
        else
            if group.requestState then
                line(group.requestState)
            else
                button("Pedir grupo", function()
                    if A.groups[owner.id] ~= group or group.when + 1800 <= GetServerTime()
                        or not A.can(A.members[owner.id], "group") then A.refresh(); return end
                    group.requestState = sendGroupWhisper(owner.name, "Hola, ¿me invitás a tu grupo para " .. group.activity .. "?")
                    A.refresh()
                end)
            end
        end
    end
end

local honorByTotal
local function honorRow(values, color)
    local frame = row()
    if not frame.honorCells then
        frame.honorCells = {}
        local columns = {8, 65, 305, 430, 570}
        for i = 1, #columns - 1 do
            local cell = text(frame, "")
            cell:SetPoint("LEFT", columns[i], 0)
            cell:SetWidth(columns[i + 1] - columns[i] - 8)
            cell:SetMaxLines(1)
            frame.honorCells[i] = cell
        end
    end
    for index, cell in ipairs(frame.honorCells) do
        cell:SetText(values[index])
        cell:SetTextColor(unpack(color or {0.96, 0.90, 0.82}))
        cell:Show()
    end
    frame:SetHeight(26)
    y = y + 26
end

local function honorRanking()
    line("Ranking de honor", accent)
    line("El honor semanal se reinicia el jueves a las 00:00, hora del reino.")
    button(honorByTotal and "Ordenar por honor semanal" or "Ordenar por honor total", function()
        honorByTotal = not honorByTotal
        scroll:SetVerticalScroll(0)
        A.refresh()
    end)
    local week = A.honorWeek()
    local ranking = {}
    for id, total in pairs(A.db.honor) do
        local member = A.members[id]
        if member then
            local weekly = A.weeklyHonor(id, week)
            ranking[#ranking + 1] = {member = member, total = total, weekly = weekly, score = honorByTotal and total or weekly}
        end
    end
    table.sort(ranking, function(left, right)
        if left.score ~= right.score then return left.score > right.score end
        return left.member.name < right.member.name
    end)
    if #ranking == 0 then line("Todavía no se registraron puntos de honor."); return end
    honorRow({"Puesto", "Personaje", "Honor semanal", "Honor total"}, accent)
    local position, previous
    local formatPoints = BreakUpLargeNumbers or tostring
    for index, entry in ipairs(ranking) do
        if entry.score ~= previous then position, previous = index, entry.score end
        local name = entry.member.name .. (entry.member.id == A.self and " (vos)" or "")
        honorRow({entry.score > 0 and tostring(position) or "—", name,
            week and formatPoints(entry.weekly) or "Sin datos", formatPoints(entry.total)},
            entry.score > 0 and position == 1 and accent or nil)
    end
end

local tabs = {
    {"home", "Inicio", home},
    {"calendar", "Calendario", calendar},
    {"groups", "Buscar grupo", A.renderGroups},
    {"notices", "Avisos", notices},
    {"professions", "Profesiones", professions},
    {"honor", "Honor", honorRanking},
    {"members", "Miembros", members},
    {"map", "Mapa", settings},
    {"permissions", "Permisos", permissions},
    {"options", "Opciones", function() end},
}
local renderers = {}
for index, tab in ipairs(tabs) do
    local id = tab[1]
    renderers[id] = tab[3]
    local control = copperButton(win)
    control:SetSize(sidebarWidth - 24, 29)
    control:SetPoint("TOPLEFT", 12, -(headerHeight + 16 + (index - 1) * 32))
    control:SetText(tab[2])
    control:SetScript("OnClick", function()
        page = id
        recipeSearch:ClearFocus()
        scroll:SetVerticalScroll(0)
        A.refresh()
    end)
    tab.control = control
end

function A.refresh(detail)
    callLauncher:SetShown(A.can(A.me, "call"))
    if activeNotice and not noticeEvent(activeNotice) then eventPopup:Hide() end
    if callPopup:IsShown() and not currentCall() then callPopup:Hide() end
    if not win:IsShown() then showDaily(); return end
    local professionPage = A.db ~= nil and page == "professions"
    local showSearch = professionPage and professionView == "recipes"
    local width = showSearch and 422 or 570
    local displayWidth, displayHeight = UIParent:GetSize()
    local view = professionPage and professionView or page
    local layoutChanged = win.layoutView ~= view or win.layoutDB ~= A.db
        or win.displayWidth ~= displayWidth or win.displayHeight ~= displayHeight
    if layoutChanged then
        win.layoutView, win.layoutDB = view, A.db
        win.displayWidth, win.displayHeight = displayWidth, displayHeight
        optionsPanel:SetShown(page == "options")
        professionControls:SetShown(professionPage)
        recipeList:SetShown(showSearch)
        recipeSearch:SetShown(showSearch)
        recipeLabel:SetShown(showSearch)
        for _, control in ipairs(filters) do control:SetShown(showSearch) end
        for id, control in pairs(professionButtons) do control:SetStyle(id == professionView) end
        local windowWidth = sidebarWidth + (showSearch and 890 or 620)
        local windowHeight = showSearch and 648 or 497
        win:SetSize(windowWidth, windowHeight)
        win.normalScale = math.min(1, displayWidth / (windowWidth + 20), displayHeight / (windowHeight + 98))
        professionControls:SetWidth(showSearch and 852 or 570)
        scroll:SetPoint("TOPLEFT", sidebarWidth + (showSearch and 436 or 18),
            -(headerHeight + (showSearch and 104 or professionPage and 53 or 18)))
        content:SetWidth(width)
        eventDivider:SetShown(A.db ~= nil and page == "calendar")
        homeDivider:SetShown(A.db ~= nil and page == "home")
        homeRule:SetShown(A.db ~= nil and page == "home")
        homeOrdersDivider:SetShown(A.db ~= nil and page == "home")
        for _, tab in ipairs(tabs) do tab.control:SetStyle(tab[1] == page) end
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
    y, activeRows, column, columnWidth = 0, 0, 0, width
    for _, card in ipairs(orderCards) do card:Hide() end
    if page ~= "options" then
        if A.db then renderers[page](detail == "recipeDetail" and not layoutChanged)
        else line("Entrá a una hermandad para usar Tártaro.") end
    end
    for index = activeRows + 1, #rows do rows[index]:Hide() end
    content:SetHeight(math.max(y, scroll:GetHeight()))
    if scroll.ScrollBar then scroll.ScrollBar:SetShown(y > scroll:GetHeight()) end
end

local pendingSections
function A.invalidate(section)
    if section == "permissions" or section == "roster" then
        callLauncher:SetShown(A.can(A.me, "call") == true)
    end
    if pendingSections then pendingSections[section] = true; return end
    pendingSections = {[section] = true}
    C_Timer.After(0.08, function()
        local dirty = pendingSections
        pendingSections = nil
        local visible = page == "professions" and professionView or page
        if dirty.recipeDetail then TartaroActivityForm.updateReagents() end
        local chrome = dirty.daily or dirty.events or dirty.permissions or dirty.roster or dirty.map
        local changed = dirty[visible] or dirty.roster and visible ~= "options"
            or dirty.events and (visible == "home" or visible == "calendar")
            or dirty.orders and visible == "home"
            or dirty.daily and (visible == "home" or visible == "notices")
            or dirty.permissions and (visible == "calendar" or visible == "notices" or visible == "groups" or visible == "map")
        if win:IsShown() and changed then
            if chrome then A.refresh() else A.refresh("page") end
        elseif win:IsShown() and visible == "recipes" and dirty.recipeDetail then
            A.refresh("recipeDetail")
        elseif chrome then
            callLauncher:SetShown(A.can(A.me, "call"))
            if activeNotice and not noticeEvent(activeNotice) then eventPopup:Hide() end
            if callPopup:IsShown() and not currentCall() then callPopup:Hide() end
            if dirty.daily or dirty.roster then showDaily() end
        end
    end)
end

function A.refreshProfessions(detail)
    A.invalidate(detail and "recipeDetail" or "recipes")
    if not detail then A.invalidate("orders") end
end

function A.refreshHonor()
    A.invalidate("honor")
end

function A.refreshMembers()
    A.invalidate("members")
end
C_Timer.NewTicker(5, function()
    if not win:IsShown() then return end
    if page == "map" or page == "groups" then A.invalidate(page) end
    if (page == "calendar" or page == "home") and win.nextEventAt and win.nextEventAt <= GetServerTime() then
        A.invalidate("events")
    end
    if page == "professions" and professionView == "orders" then A.invalidate("orders") end
end)

local function toggle()
    if combatWindowsBlocked() then return end
    if editor:IsShown() then editor:Hide(); return end
    if win:IsShown() then win:Hide(); return end
    win:Show()
    A.refresh()
end

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

local function placeLauncher()
    local radius = math.min(Minimap:GetWidth(), Minimap:GetHeight()) * 0.51
    launcher:ClearAllPoints()
    launcher:SetPoint("CENTER", Minimap, "CENTER", radius * math.cos(launcherAngle), radius * math.sin(launcherAngle))
end

local function followCursor()
    local centerX, centerY = Minimap:GetCenter()
    if not centerX or not centerY then return end
    local cursorX, cursorY = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    local dx, dy = cursorX / scale - centerX, cursorY / scale - centerY
    if dx == 0 and dy == 0 then return end
    launcherAngle = math.atan2(dy, dx)
    placeLauncher()
end

launcher:RegisterEvent("PLAYER_LOGIN")
launcher:SetScript("OnEvent", function(self)
    local saved = TartaroDB and TartaroDB.minimapAngle
    if type(saved) == "number" and saved >= -math.pi and saved <= math.pi then launcherAngle = saved end
    placeLauncher()
    self:UnregisterEvent("PLAYER_LOGIN")
end)
Minimap:HookScript("OnSizeChanged", placeLauncher)
placeLauncher()

launcher:SetScript("OnMouseDown", function() dragged = false end)
launcher:SetScript("OnClick", function()
    if not dragged then toggle() end
end)
launcher:SetScript("OnDragStart", function(self)
    dragged = true
    GameTooltip:Hide()
    self:SetScript("OnUpdate", followCursor)
end)
launcher:SetScript("OnDragStop", function(self)
    followCursor()
    self:SetScript("OnUpdate", nil)
    if TartaroDB then TartaroDB.minimapAngle = launcherAngle end
end)
launcher:SetScript("OnHide", function(self)
    self:SetScript("OnUpdate", nil)
end)
local emblem = launcher:CreateTexture(nil, "BACKGROUND")
emblem:SetTexture(icon)
emblem:SetSize(24, 24)
emblem:SetPoint("CENTER")
local rim = launcher:CreateTexture(nil, "OVERLAY")
rim:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
rim:SetSize(53, 53)
rim:SetPoint("TOPLEFT")
launcher:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
launcher:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("Tártaro", 1, 0.79, 0.53)
    GameTooltip:AddLine("Clic para abrir o cerrar", 1, 1, 1)
    GameTooltip:AddLine("Arrastrá con clic izquierdo para mover", 1, 1, 1)
    GameTooltip:Show()
end)
launcher:SetScript("OnLeave", function() GameTooltip:Hide() end)

function A.updateCombatWindows()
    if combatWindowsBlocked() then
        local form = TartaroActivityForm
        if form:IsShown() then form.resumeAfterCombat = true; form:Hide() end
        if editor:IsShown() then editor.resumeAfterCombat = true; editor:Hide() end
        if win:IsShown() then win.resumeAfterCombat = true; win:Hide() end
        if activeNotice and eventPopup:IsShown() then table.insert(pendingEvents, 1, activeNotice) end
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
end

local combatEvents = CreateFrame("Frame")
combatEvents:RegisterEvent("PLAYER_REGEN_DISABLED")
combatEvents:RegisterEvent("PLAYER_REGEN_ENABLED")
combatEvents:SetScript("OnEvent", function(_, event)
    inCombat = event == "PLAYER_REGEN_DISABLED"
    A.updateCombatWindows()
end)

StaticPopupDialogs["TARTARO_RESET_OPTIONS"] = {
    text = "¿Restablecer las posiciones y opciones personales de Tártaro?",
    button1 = "Restablecer",
    button2 = "Cancelar",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnAccept = function()
        if TartaroDB.shareLocation == false then A.setSharing(true) end
        for _, key in ipairs({"shareLocation", "callSound", "callSoundVolume", "callSoundChoice", "hideWindowsInCombat",
            "minimapAngle", "callLauncherPosition", "noticePosition"}) do
            TartaroDB[key] = nil
        end
        launcherAngle = defaultAngle
        placeLauncher()
        callLauncher:ResetPosition()
        win.stackPoint = nil
        win:ClearAllPoints()
        win:SetPoint("CENTER", UIParent, "CENTER", 0, -20)
        editor:ClearAllPoints()
        editor:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
        TartaroActivityForm:ClearAllPoints()
        TartaroActivityForm:SetPoint("CENTER", UIParent, "CENTER", 0, 25)
        callMoved = nil
        positionCall()
        detectedFirst = nil
        honorByTotal = nil
        recipeSearch:SetText("")
        recipeFilters = {hideBound = false}
        recipePage, selectedRecipe = 1, nil
        optionsPanel.sync()
        A.updateCombatWindows()
    end,
}
