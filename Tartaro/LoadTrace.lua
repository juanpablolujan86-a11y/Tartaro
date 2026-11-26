local addon, A = ...
local expected = {"Core.lua", "Replication.lua", "Map.lua", "Professions.lua", "RecipeCatalog.lua",
    "Honor.lua", "Roles.lua", "Activities.lua", "GroupFinder.lua", "GroupAttendance.lua", "Orders.lua",
    "Donations.lua", "Cleanup.lua", "Audio.lua", "Version.lua", "UIComponents.lua", "Calendar.lua", "UI.lua"}
local run = {schema=1, build="menu-runtime-trace-2", phase="loading", modules={}, entries={}, errors=0,
    started=GetServerTime(), monotonicStart=GetTime()}
local developmentBuild = false
local enabled, capturing, previous, handler = true, true
local runtimeEnabled, bootFinished = developmentBuild, false
local session = {schema=1, build=run.build, started=run.started, entries={}, errors={}, counts={}, sequence=0, limit=1000}
local summaryKeys={"id","owner","spell","item","quantity","when","rank","closed","count","rows","view","selected","fits","enabled","played","reason","mode","year","month","day","width","height"}
local function limited(value, maximum)
    if #value <= maximum then return value end
    local cut=maximum+1
    while cut>1 and value:byte(cut)>=128 and value:byte(cut)<192 do cut=cut-1 end
    return value:sub(1,cut-1).."..."
end
local function describe(value, maximum)
    if issecretvalue and issecretvalue(value) then return "<secret>" end
    local kind=type(value)
    if kind=="string" then return "string:"..limited(value,maximum) end
    if kind=="table" then
        local fields={}
        if getmetatable(value)==nil then fields[#fields+1]="length="..#value end
        for index=1,3 do
            local entry=rawget(value,index)
            if entry~=nil and (not issecretvalue or not issecretvalue(entry))
                and (type(entry)=="string" or type(entry)=="number" or type(entry)=="boolean") then
                fields[#fields+1]=index.."="..limited(tostring(entry),60)
            end
        end
        for _,key in ipairs(summaryKeys) do
            local entry=rawget(value,key)
            if entry~=nil and (not issecretvalue or not issecretvalue(entry))
                and (type(entry)=="string" or type(entry)=="number" or type(entry)=="boolean") then
                fields[#fields+1]=key.."="..limited(tostring(entry),90)
            end
        end
        if type(value.GetName)=="function" then
            local name=value:GetName()
            if name and (not issecretvalue or not issecretvalue(name)) then fields[#fields+1]="frame="..tostring(name) end
        end
        if type(value.GetText)=="function" then
            local text=value:GetText()
            if type(text)=="string" and (not issecretvalue or not issecretvalue(text)) then fields[#fields+1]="text="..limited(text,90) end
        end
        return "table:"..limited(table.concat(fields,","),maximum)
    end
    return kind..":"..tostring(value)
end
local function write(kind, operation, related, ...)
    if not runtimeEnabled then return end
    session.sequence=session.sequence+1
    local values={}
    for index=1,math.min(select("#",...),10) do
        local argument=select(index,...)
        local ok,value=pcall(describe,argument,(kind=="error" or kind=="caught.error") and 2400 or 300)
        values[index]=ok and value or "<unavailable>"
    end
    local entry={sequence=session.sequence,at=GetServerTime(),elapsed=GetTime()-run.monotonicStart,
        kind=kind,operation=operation,related=related,argumentCount=select("#",...),values=values}
    session.entries[(session.sequence-1)%session.limit+1]=entry
    session.overwritten=math.max(0,session.sequence-session.limit)
    local counts=session.counts[operation] or {}
    session.counts[operation]=counts
    counts[kind]=(counts[kind] or 0)+1
    if kind=="enter" then counts.lastEnter=entry elseif kind=="return" then counts.lastReturn=entry end
    if kind=="error" or kind=="caught.error" then
        if #session.errors>=30 then table.remove(session.errors,1); session.errorsOverwritten=(session.errorsOverwritten or 0)+1 end
        session.errors[#session.errors+1]=entry
    end
    return entry.sequence
end
function A.debugLog(kind, operation, ...) return write(kind,operation,nil,...) end
function A.isDebugEnabled() return runtimeEnabled end
local function finish(operation, sequence, ...)
    write("return",operation,sequence,...)
    return ...
end
function A.traceCallback(operation, callback)
    if callback==nil then return nil end
    return function(...)
        if not runtimeEnabled then return callback(...) end
        local sequence=write("enter",operation,nil,...)
        return finish(operation,sequence,callback(...))
    end
end
local function protectedResult(operation, ...)
    if not select(1,...) then write("caught.error",operation,nil,select(2,...)) end
    return ...
end
function A.debugPcall(operation, callback, ...)
    return protectedResult(operation,pcall(callback,...))
end
local function mark(kind, module, detail)
    if kind == "module.begin" then run.modules[module] = "started"
    elseif kind == "module.end" then run.modules[module] = "loaded" end
    if kind == "core.login.end" then run.coreLoginCompleted = true end
    if not enabled then return end
    if #run.entries >= 160 then run.dropped=(run.dropped or 0)+1; return end
    run.entries[#run.entries+1] = {sequence=#run.entries+1, at=GetServerTime(), elapsed=GetTime()-run.monotonicStart,
        kind=kind, module=module, detail=detail and tostring(detail):sub(1,2400)}
end
A.traceLoad = mark
local function persist()
    TartaroDB = TartaroDB or {}
    runtimeEnabled = TartaroDB.debugMode == true or TartaroDB.debugMode == nil and developmentBuild
    enabled = runtimeEnabled and TartaroDB.debugLoad ~= false
    if not session.preferencesRead and not runtimeEnabled then
        session.entries,session.errors,session.counts,session.sequence={}, {}, {}, 0
        session.overwritten,session.errorsOverwritten=0,0
    end
    session.preferencesRead=true
    session.enabled = runtimeEnabled
    if enabled then TartaroDB.loadTrace = run end
    if runtimeEnabled then TartaroDB.debugTrace = session end
end
local function stop()
    capturing = false
    if handler and geterrorhandler and seterrorhandler and geterrorhandler() == handler then seterrorhandler(previous) end
end
local function capture(message)
    local value = tostring(message)
    local frames = {}
    for line in (debugstack and debugstack(2,12,0) or "Stack no disponible"):gmatch("[^\n]+") do
        if not line:find("LoadTrace.lua",1,true) then frames[#frames+1] = line end
    end
    local stack = table.concat(frames,"\n")
    if (value .. "\n" .. stack):lower():gsub("\\", "/"):find("interface/addons/tartaro/",1,true) then
        if not bootFinished then run.errors=run.errors+1; run.phase="failed" end
        mark("lua.error", bootFinished and "runtime" or "load", value .. "\n" .. stack)
        write("error","Lua",nil,limited(value,700),limited(stack,2000))
    end
end
if type(geterrorhandler)=="function" and type(seterrorhandler)=="function" then previous=geterrorhandler() end
if type(previous)=="function" then
    handler = function(message, ...)
        if capturing and (enabled and not bootFinished or runtimeEnabled) then
            local ok=pcall(capture,message)
            if not ok then session.captureFailures=(session.captureFailures or 0)+1 end
        end
        return previous(message, ...)
    end
    seterrorhandler(handler)
    run.errorCapture = true
else run.errorCapture = false end
mark("trace.begin", "LoadTrace.lua")
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" then
        if name ~= addon then return end
        persist()
        run.addonLoaded = true
        frame:UnregisterEvent("ADDON_LOADED")
        run.missing = {}
        for _, module in ipairs(expected) do
            if run.modules[module] ~= "loaded" then run.missing[#run.missing+1] = module end
        end
        run.phase = #run.missing == 0 and run.errors == 0 and "loaded" or "failed"
        mark("addon.loaded", addon, run.phase)
    elseif event == "PLAYER_LOGIN" then
        frame:UnregisterEvent("PLAYER_LOGIN")
        mark("login.observed", addon)
        C_Timer.After(0, function()
            persist()
            run.commandReady = SlashCmdList and type(SlashCmdList.TARTARO) == "function" or false
            run.uiReady = TartaroWindow ~= nil and TartaroMinimapButton ~= nil and type(A.refresh) == "function"
            if not run.addonLoaded or not run.coreLoginCompleted or not run.commandReady or not run.uiReady
                or run.errors > 0 or run.phase == "failed" then run.phase="failed"
            else run.phase="initialized" end
            mark("login.checked", addon, run.phase)
            bootFinished=true
        end)
    elseif event == "PLAYER_LOGOUT" then
        mark("logout", addon)
        persist()
        C_Timer.After(0,stop)
    end
end)
if SlashCmdList then
    SLASH_TARTARODEBUG1="/tartarodebug"
    SlashCmdList.TARTARODEBUG=function(command)
        command=(command or ""):lower():match("^%s*(.-)%s*$")
        if command=="on" or command=="off" then
            if command=="off" then write("mode","debug",nil,command) end
            TartaroDB=TartaroDB or {}
            TartaroDB.debugMode=command=="on"
            TartaroDB.debugLoad=command=="on"
            persist()
            if command=="on" then write("mode","debug",nil,command) end
        end
        print("Tártaro debug: "..(runtimeEnabled and "activo" or "inactivo").."; registros="..session.sequence.."; reemplazados="..(session.overwritten or 0)..". Datos: TartaroDB.debugTrace.")
    end
end
