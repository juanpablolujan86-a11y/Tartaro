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
local state = {}

A.shareVersion = A.traceCallback("Version.lua:15:A.shareVersion", function()
    if installed then A.send("V", A.addonVersion) end
end)

A.resetVersionNotice = A.traceCallback("Version.lua:19:A.resetVersionNotice", function()
    state = {}
    A.newerAddonVersion = nil
    A.updateVersionLabel()
end)

A.receiveVersion = A.traceCallback("Version.lua:25:A.receiveVersion", function(value)
    local reported = versionNumber(value)
    if not installed or not reported or reported <= (state.highest or installed) then return end
    state.highest = reported
    A.newerAddonVersion = value
    A.updateVersionLabel()
    if state.pending then return end
    state.pending = true
    local current = state
    C_Timer.After(0.5, A.traceCallback("Version.lua:34:callback", function()
        if state ~= current then return end
        state.pending = nil
        print(("Tártaro: un miembro de la hermandad está usando la versión %s. Tu versión es %s.")
            :format(A.newerAddonVersion, A.addonVersion))
    end))
end)
if A.traceLoad then A.traceLoad("module.end", "Version.lua") end
