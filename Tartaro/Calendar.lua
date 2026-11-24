local _, A = ...
if A.traceLoad then A.traceLoad("module.begin", "Calendar.lua") end
local Calendar = {}
A.Calendar = Calendar
local monthNames = {"Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"}
local monthDays = {31,28,31,30,31,30,31,31,30,31,30,31}
local weekdays = {"Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"}
local leap; leap = A.traceCallback("Calendar.lua:8:leap", function(year) return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0) end)
local days; days = A.traceCallback("Calendar.lua:9:days", function(year, month) return month == 2 and leap(year) and 29 or monthDays[month] end)
local shift; shift = A.traceCallback("Calendar.lua:10:shift", function(year, month, delta)
    month = month + delta
    if month < 1 then year, month = year-1, 12 elseif month > 12 then year, month = year+1, 1 end
    return year, month
end)
local key; key = A.traceCallback("Calendar.lua:15:key", function(year, month, day) return ("%04d-%02d-%02d"):format(year, month, day) end)
Calendar.dayKey = A.traceCallback("Calendar.lua:16:Calendar.dayKey", function(when)
    local parts = date("*t", when)
    return key(parts.year, parts.month, parts.day), parts
end)
Calendar.month = A.traceCallback("Calendar.lua:20:Calendar.month", function(year, month)
    local prior = year-1
    local absolute = 365*prior + math.floor(prior/4) - math.floor(prior/100) + math.floor(prior/400)
    for m=1,month-1 do absolute = absolute + days(year,m) end
    local offset = (absolute+1) % 7
    local y,m,d = year,month,1-offset
    if d < 1 then y,m = shift(year,month,-1); d = days(y,m)+d end
    local cells = {}
    for index=1,42 do
        cells[index] = {year=y,month=m,day=d,key=key(y,m,d),current=m == month and y == year}
        d = d+1
        if d > days(y,m) then d=1; y,m=shift(y,m,1) end
    end
    return cells
end)
Calendar.group = A.traceCallback("Calendar.lua:35:Calendar.group", function(events)
    local grouped = {}
    for _, event in pairs(events) do
        local day = Calendar.dayKey(event.when)
        grouped[day] = grouped[day] or {}
        grouped[day][#grouped[day]+1] = event
    end
    for _, list in pairs(grouped) do
        table.sort(list, A.traceCallback("Calendar.lua:43:callback", function(a,b) return a.when < b.when or a.when == b.when and a.id < b.id end))
    end
    return grouped
end)
Calendar.create = A.traceCallback("Calendar.lua:47:Calendar.create", function(parent, button, text)
    local frame = CreateFrame("Frame", "TartaroCalendar", parent)
    frame:SetSize(650,537)
    frame:Hide()
    local cells, caption = {}, text(frame,"","GameFontNormalLarge")
    caption:SetPoint("TOP",0,-6)
    local fresh; fresh = A.traceCallback("Calendar.lua:53:fresh", function(context)
        return frame.options and frame.options.context == context and frame.options.isCurrent()
    end)
    local notify; notify = A.traceCallback("Calendar.lua:56:notify", function(id)
        frame.selectedId = id
        frame.options.onSelect(id)
    end)
    frame.Reset = A.traceCallback("Calendar.lua:60:frame:Reset", function(self)
        self.context, self.selectedId, self.lastWhen, self.selectedDay, self.year, self.month = nil,nil,nil,nil,nil,nil
    end)
    frame.SelectEvent = A.traceCallback("Calendar.lua:63:frame:SelectEvent", function(self, id)
        if not self.options or not fresh(self.context) then return end
        local event = self.events[id]
        if not event then return end
        local day, parts = Calendar.dayKey(event.when)
        self.year,self.month,self.selectedDay = parts.year,parts.month,day
        notify(id)
    end)
    frame.MoveMonth = A.traceCallback("Calendar.lua:71:frame:MoveMonth", function(self, delta)
        if not self.options or not fresh(self.context) then return end
        local year, month = shift(self.year,self.month,delta)
        if year < 1 or year > 9999 then return end
        self.year,self.month,self.selectedDay = year,month,key(year,month,1)
        notify(nil)
    end)
    local previous = button(frame); previous:SetSize(28,28); previous:SetPoint("TOPLEFT",0,0); previous:SetText("<"); previous:SetStyle(false)
    previous:SetScript("OnClick",A.traceCallback("Calendar.lua:79:callback", function() frame:MoveMonth(-1) end))
    local nextMonth = button(frame); nextMonth:SetSize(28,28); nextMonth:SetPoint("LEFT",previous,"RIGHT",5,0); nextMonth:SetText(">"); nextMonth:SetStyle(false)
    nextMonth:SetScript("OnClick",A.traceCallback("Calendar.lua:81:callback", function() frame:MoveMonth(1) end))
    local today = button(frame); today:SetSize(52,28); today:SetPoint("LEFT",nextMonth,"RIGHT",8,0); today:SetText("Hoy"); today:SetStyle(false)
    today:SetScript("OnClick",A.traceCallback("Calendar.lua:83:callback", function()
        if not frame.options or not fresh(frame.context) then return end
        local day, parts = Calendar.dayKey(GetServerTime())
        frame.year,frame.month,frame.selectedDay = parts.year,parts.month,day
        notify(nil)
    end))
    local create = button(frame); create:SetSize(126,28); create:SetPoint("TOPRIGHT"); create:SetText("Nuevo evento"); create:SetStyle(false)
    create:SetScript("OnClick",A.traceCallback("Calendar.lua:90:callback", function()
        if frame.options and fresh(frame.context) and frame.options.canCreate() then frame.options.onCreate() end
    end))
    for i, name in ipairs(weekdays) do
        local label = text(frame,name); label:SetPoint("TOPLEFT",(i-1)*(650+4)/7, -38); label:SetWidth(650/7-4); label:SetJustifyH("CENTER")
    end
    for index=1,42 do
        local cell = button(frame); cell:SetText(""); cell.number=text(cell,""); cell.number:SetPoint("TOPLEFT",4,-3)
        cell.entries={}; cells[index]=cell
        cell.more=button(cell); cell.more:SetText(""); cell.more:SetStyle(false)
    end
    frame.DayEvents = A.traceCallback("Calendar.lua:101:frame:DayEvents", function(self) return self.grouped and self.grouped[self.selectedDay] or {} end)
    frame.Display = A.traceCallback("Calendar.lua:102:frame:Display", function(self, events, selectedId, options)
        local context = options.context
        self.options,self.events,self.grouped = options,events,Calendar.group(events)
        if self.context ~= context then
            self:Reset(); self.context=context
            local day, parts = Calendar.dayKey(GetServerTime())
            self.year,self.month,self.selectedDay = parts.year,parts.month,day
        end
        local external = selectedId and events[selectedId]
        if external and (self.selectedId ~= selectedId or self.lastWhen ~= external.when) then
            local day,parts = Calendar.dayKey(external.when)
            self.year,self.month,self.selectedDay = parts.year,parts.month,day
            self.selectedId = selectedId
        end
        local dayEvents = self:DayEvents()
        local current = self.selectedId and events[self.selectedId]
        if not current or Calendar.dayKey(current.when) ~= self.selectedDay then current=dayEvents[1] end
        self.selectedId,self.lastWhen = current and current.id,current and current.when
        caption:SetText(monthNames[self.month] .. " " .. self.year)
        create:SetShown(options.canCreate())
        local width,height = self:GetSize()
        local cw,ch = (width-24)/7,(height-80)/6
        local slots = math.max(1,math.floor((ch-38)/30))
        local todayKey = Calendar.dayKey(GetServerTime())
        for index, day in ipairs(Calendar.month(self.year,self.month)) do
            local cell = cells[index]
            cell:ClearAllPoints(); cell:SetPoint("TOPLEFT",(index-1)%7*(cw+4),-60-math.floor((index-1)/7)*(ch+4)); cell:SetSize(cw,ch)
            cell.day=day.key; cell.number:SetText(day.day)
            cell.number:SetTextColor(day.key == todayKey and 1 or day.current and 0.96 or 0.55,day.key == todayKey and 0.72 or day.current and 0.9 or 0.52,day.current and 0.82 or 0.5)
            cell:SetStyle(self.selectedDay == day.key)
            local selectDay; selectDay = A.traceCallback("Calendar.lua:132:selectDay", function()
                if not fresh(context) or day.year < 1 or day.year > 9999 then return end
                self.year,self.month,self.selectedDay=day.year,day.month,day.key
                notify(nil)
            end)
            cell:SetScript("OnClick",selectDay)
            local list = self.grouped[day.key] or {}
            for i=1,math.min(slots,#list) do
                local event = list[i]
                local control = cell.entries[i]
                if not control then control=button(cell); cell.entries[i]=control end
                control:ClearAllPoints(); control:SetPoint("TOPLEFT",3,-18-(i-1)*30); control:SetSize(cw-6,28)
                control:SetText(date("%H:%M",event.when) .. " " .. event.title)
                local label = control:GetFontString(); label:ClearAllPoints(); label:SetPoint("TOPLEFT",3,-2); label:SetPoint("BOTTOMRIGHT",-3,2)
                label:SetWidth(cw-12); label:SetMaxLines(2); label:SetJustifyH("LEFT"); label:SetJustifyV("TOP"); label:SetWordWrap(true); label:SetNonSpaceWrap(true)
                control:SetStyle(event.id == self.selectedId)
                if event.when <= GetServerTime() then label:SetTextColor(0.65,0.62,0.58) end
                control.eventId=event.id
                control:SetScript("OnClick",A.traceCallback("Calendar.lua:150:callback", function() if fresh(context) then self:SelectEvent(event.id) end end))
                control:SetScript("OnEnter",A.traceCallback("Calendar.lua:151:callback", function(owner)
                    if not fresh(context) or not self.events[event.id] then return end
                    local value=self.events[event.id]
                    GameTooltip:SetOwner(owner,"ANCHOR_RIGHT"); GameTooltip:SetText(value.title)
                    GameTooltip:AddLine(date("%d/%m/%Y %H:%M",value.when) .. " (hora local)")
                    if value.when <= GetServerTime() then GameTooltip:AddLine("Evento vencido · solo lectura") end
                    GameTooltip:Show()
                end))
                control:SetScript("OnLeave",A.traceCallback("Calendar.lua:159:callback", function() GameTooltip:Hide() end))
                control:Show()
            end
            for i=math.min(slots,#list)+1,#cell.entries do cell.entries[i]:Hide() end
            cell.more:ClearAllPoints(); cell.more:SetPoint("BOTTOMLEFT",3,2); cell.more:SetSize(cw-6,16)
            cell.more:SetText(#list > slots and ("+ " .. (#list-slots) .. " más") or "")
            cell.more:SetScript("OnClick",selectDay); cell.more:SetShown(#list > slots)
        end
        return current
    end)
    return frame
end)
if A.traceLoad then A.traceLoad("module.end", "Calendar.lua") end
