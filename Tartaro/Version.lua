local addonName, A = ...
if A.traceLoad then A.traceLoad("module.begin", "Version.lua") end
local metadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
A.addonVersion = metadata and metadata(addonName, "Version")

local versionNumber; versionNumber = A.traceCallback("Version.lua:6:versionNumber", function(value)
    if type(value) ~= "string" then return end
    local major, minor, patch = value:match("^(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)$")
    if major then return tonumber(major) * 1000000 + tonumber(minor) * 1000 + tonumber(patch) end
end)

local installed = versionNumber(A.addonVersion)
local state = {reports={}}

local reportVersion; reportVersion = A.traceCallback("Version.reportVersion", function(value)
    if type(value) == "string" and #value > 0 and #value <= 32 and value:match("^[%w%._%-]+$") then return value end
end)

local localOverlord; localOverlord = A.traceCallback("Version.localOverlord", function()
    local exists
    if C_AddOns and C_AddOns.DoesAddOnExist then exists = C_AddOns.DoesAddOnExist("Overlord")
    elseif C_AddOns and C_AddOns.GetAddOnInfo then exists = C_AddOns.GetAddOnInfo("Overlord") ~= nil
    elseif GetAddOnInfo then exists = GetAddOnInfo("Overlord") ~= nil end
    if exists == nil then return "U" end
    if not exists then return "N" end
    local value = metadata and reportVersion(metadata("Overlord", "Version"))
    local isLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
    if isLoaded then
        local loading, loaded = isLoaded("Overlord")
        if loaded == true or loaded == nil and loading then return "L", value end
    end
    local enabled
    if C_AddOns and C_AddOns.GetAddOnEnableState then
        enabled = C_AddOns.GetAddOnEnableState("Overlord", UnitName("player"))
    elseif GetAddOnEnableState then enabled = GetAddOnEnableState(UnitName("player"), "Overlord") end
    if enabled == 0 then return "D", value end
    if type(enabled) == "number" and enabled > 0 then return "E", value end
    return "I", value
end)

A.memberAddonReport = A.traceCallback("Version.memberAddonReport", function(member)
    if not A.db or not member then return end
    local report = A.db.memberAddons and A.db.memberAddons[member.id]
    local confirmation = state.reports[member.id]
    return report, report ~= nil and confirmation ~= nil and confirmation.report == report
        and A.addonPresence(member, confirmation.at) == "active"
end)

A.resetMemberAddonReport = A.traceCallback("Version.resetMemberAddonReport", function(id)
    state.reports[id] = nil
end)

A.shareVersion = A.traceCallback("Version.lua:53:A.shareVersion", function()
    if not installed or not A.db then return end
    local overlord, value = localOverlord()
    A.receiveVersion(A.addonVersion, A.self, overlord, value)
    return A.send("V", A.addonVersion, overlord, value or "")
end)

A.resetVersionNotice = A.traceCallback("Version.lua:60:A.resetVersionNotice", function()
    state = {reports={}}
    A.newerAddonVersion = nil
    A.updateVersionLabel()
end)

A.receiveVersion = A.traceCallback("Version.lua:66:A.receiveVersion", function(value, author, overlord, overlordVersion)
    local reported = versionNumber(value)
    if reported and author and A.db and A.members[author] then
        A.db.memberAddons = A.db.memberAddons or {}
        local previous = A.db.memberAddons[author]
        local _, current = A.memberAddonReport(A.members[author])
        local addon
        if overlord == "L" or overlord == "D" or overlord == "E" or overlord == "I" or overlord == "N" or overlord == "U" then
            addon = {state=overlord, version=overlord ~= "N" and overlord ~= "U" and reportVersion(overlordVersion) or nil}
        end
        local report = {version=value, overlord=addon, at=GetServerTime()}
        A.db.memberAddons[author] = report
        state.reports[author] = {report=report, at=GetTime()}
        local old = previous and previous.overlord
        if not current or previous.version ~= value or (old and old.state) ~= (addon and addon.state)
            or (old and old.version) ~= (addon and addon.version) then
            A.debugLog("addons.report", "Version.receive", author, value, addon and addon.state, addon and addon.version)
            if A.refreshMembers then A.refreshMembers() end
        end
    end
    if not installed or not reported or reported <= (state.highest or installed) then return end
    state.highest = reported
    A.newerAddonVersion = value
    A.updateVersionLabel()
    if state.pending then return end
    state.pending = true
    local current = state
    C_Timer.After(0.5, A.traceCallback("Version.lua:93:callback", function()
        if state ~= current then return end
        state.pending = nil
        print(("Tártaro: un miembro de la hermandad está usando la versión %s. Tu versión es %s.")
            :format(A.newerAddonVersion, A.addonVersion))
    end))
end)
if A.traceLoad then A.traceLoad("module.end", "Version.lua") end
