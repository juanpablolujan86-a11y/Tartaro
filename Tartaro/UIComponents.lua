local _, A = ...
if A.traceLoad then A.traceLoad("module.begin", "UIComponents.lua") end
local Components = {}
A.UIComponents = Components

Components.create = A.traceCallback("UIComponents.lua:6:Components.create", function(options)
    local content, scroll, header = options.content, options.scroll, options.header
    local rows, cards, parts, active = {}, {}, {}, 0
    local parent = content
    local layout = {x=0, width=570, y=0}
    local view = {layout=layout}
    view.Attach = A.traceCallback("UIComponents.lua:12:view.Attach", function(frame, part)
        parts[frame] = parts[frame] or {}
        parts[frame][#parts[frame]+1] = part
        return part
    end)
    view.Row = A.traceCallback("UIComponents.lua:17:view.Row", function()
        active = active+1
        local frame=rows[active]
        if not frame then
            frame=CreateFrame("Frame",nil,content)
            frame.label=view.Attach(frame,options.text(frame,"")); frame.label:SetPoint("TOPLEFT",0,-3)
            frame.button=view.Attach(frame,options.button(frame)); frame.button:SetPoint("TOPLEFT")
            frame.check=view.Attach(frame,CreateFrame("CheckButton",nil,frame,"UICheckButtonTemplate")); frame.check:SetPoint("TOPLEFT",0,2)
            frame.checkText=options.text(frame.check,""); frame.checkText:SetPoint("LEFT",frame.check,"RIGHT",4,0)
            rows[active]=frame
        end
        frame:SetParent(parent)
        frame:ClearAllPoints(); frame:SetPoint("TOPLEFT",layout.x,-layout.y); frame:SetWidth(layout.width)
        frame.label:SetWidth(layout.width-8)
        for _, part in ipairs(parts[frame]) do part:Hide() end
        frame:Show()
        return frame
    end)
    view.Line = A.traceCallback("UIComponents.lua:35:view.Line", function(value,color,compact,font)
        local frame=view.Row()
        frame.label:SetFontObject(font or GameFontHighlight)
        frame.label:SetText(value); frame.label:SetTextColor(unpack(color or {0.96,0.9,0.82})); frame.label:Show()
        local height=math.max(compact and 17 or 23,frame.label:GetStringHeight()+(compact and 4 or 10))
        frame:SetHeight(height); layout.y=layout.y+height
        return frame
    end)
    view.Button = A.traceCallback("UIComponents.lua:43:view.Button", function(label,callback,primary,width)
        local frame=view.Row()
        frame.button:SetSize(math.min(layout.width-8,width or 228),27)
        frame.button:SetText(label); frame.button:GetFontString():SetWidth(frame.button:GetWidth()-10); frame.button:GetFontString():SetMaxLines(1)
        frame.button:SetStyle(false,primary); frame.button:SetScript("OnClick",callback); frame.button:Show()
        frame:SetHeight(35); layout.y=layout.y+35
    end)
    view.Check = A.traceCallback("UIComponents.lua:50:view.Check", function(label,enabled,callback)
        local frame=view.Row()
        frame.checkText:SetText(label); frame.check:SetChecked(enabled)
        frame.check:SetScript("OnClick",A.traceCallback("UIComponents.lua:53:callback", function(self) callback(self:GetChecked() and true or false) end))
        frame.check:Show(); frame:SetHeight(32); layout.y=layout.y+32
    end)
    view.TableRow = A.traceCallback("UIComponents.lua:56:view.TableRow", function(values,columns,height,gap,colors)
        local frame=view.Row(); frame.tableCells=frame.tableCells or {}
        for i=1,#columns-1 do
            local cell=frame.tableCells[i]
            if not cell then cell=view.Attach(frame,options.text(frame,"")); cell:SetMaxLines(1); frame.tableCells[i]=cell end
            cell:ClearAllPoints(); cell:SetPoint("LEFT",columns[i],0); cell:SetWidth(columns[i+1]-columns[i]-8)
            cell:SetText(values[i]); cell:SetTextColor(unpack(colors and colors[i] or {0.96,0.9,0.82})); cell:Show()
        end
        frame:SetHeight(height); layout.y=layout.y+height+gap
        return frame
    end)
    view.Card = A.traceCallback("UIComponents.lua:67:view.Card", function(index,left,top,width,height,selected)
        local card=cards[index]
        if not card then card=content:CreateTexture(nil,"BACKGROUND"); cards[index]=card end
        if selected then card:SetColorTexture(0.28,0.16,0.12,1) else card:SetColorTexture(0.15,0.105,0.095,1) end
        card:ClearAllPoints(); card:SetPoint("TOPLEFT",left,-top); card:SetSize(width,height); card:Show()
    end)
    view.Grid = A.traceCallback("UIComponents.lua:73:view.Grid", function(records,render,focus)
        local width=layout.width
        local gap,pad=10,9
        local cardWidth=(width-gap)/2
        local focusedTop
        for first=1,#records,2 do
            local top,bottom=layout.y,layout.y
            local last=math.min(first+1,#records)
            for index=first,last do
                local left=(index-first)*(cardWidth+gap)
                layout.x,layout.width,layout.y=left+pad,cardWidth-2*pad,top+pad
                render(records[index])
                bottom=math.max(bottom,layout.y+pad)
                local selected=focus~=nil and records[index].id==focus
                if selected then focusedTop=top end
                view.Card(index,left,top,cardWidth,1,selected)
            end
            for index=first,last do cards[index]:SetSize(cardWidth,bottom-top) end
            layout.y=bottom+gap
        end
        layout.x,layout.width=0,width
        return focusedTop
    end)
    view.Begin = A.traceCallback("UIComponents.lua:96:view.Begin", function(width,fixed)
        layout.x,layout.width,layout.y,active=0,width,0,0
        header:SetShown(fixed); header:SetWidth(width)
        parent=fixed and header or content
        for _,card in ipairs(cards) do card:Hide() end
    end)
    view.BeginTable = A.traceCallback("UIComponents.lua:102:view.BeginTable", function()
        header:SetHeight(layout.y); options.onHeaderHeight(layout.y)
        parent=content; layout.y=0
    end)
    view.Finish = A.traceCallback("UIComponents.lua:106:view.Finish", function()
        for index=active+1,#rows do rows[index]:Hide() end
        parent=content
        content:SetHeight(math.max(layout.y,scroll:GetHeight()))
        if scroll.ScrollBar then scroll.ScrollBar:SetShown(layout.y>scroll:GetHeight()) end
        if header:IsShown() then scroll:SetVerticalScroll(math.max(0,math.min(scroll:GetVerticalScroll(),content:GetHeight()-scroll:GetHeight()))) end
    end)
    view.Hide = A.traceCallback("UIComponents.lua:113:view.Hide", function()
        parent=content; header:Hide()
        for _,frame in ipairs(rows) do frame:Hide() end
        for _,card in ipairs(cards) do card:Hide() end
    end)
    view.Rows = A.traceCallback("UIComponents.lua:118:view.Rows", function() return rows,active end)
    view.Count = A.traceCallback("UIComponents.lua:119:view.Count", function() return active end)
    return view
end)
if A.traceLoad then A.traceLoad("module.end", "UIComponents.lua") end
