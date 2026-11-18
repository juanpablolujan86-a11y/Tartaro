local addonName, A = ...
local metadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
A.addonVersion = metadata and metadata(addonName, "Version")

local function versionNumber(value)
    if type(value) ~= "string" then return end
    local major, minor, patch = value:match("^(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)$")
    if major then return tonumber(major) * 1000000 + tonumber(minor) * 1000 + tonumber(patch) end
end

local installed = versionNumber(A.addonVersion)
local state = {}

function A.shareVersion()
    if installed then A.send("V", A.addonVersion) end
end

function A.resetVersionNotice()
    state = {}
    A.newerAddonVersion = nil
    A.updateVersionLabel()
end

function A.receiveVersion(value)
    local reported = versionNumber(value)
    if not installed or not reported or reported <= (state.highest or installed) then return end
    state.highest = reported
    A.newerAddonVersion = value
    A.updateVersionLabel()
    if state.pending then return end
    state.pending = true
    local current = state
    C_Timer.After(0.5, function()
        if state ~= current then return end
        state.pending = nil
        print(("Tártaro: un miembro de la hermandad está usando la versión %s. Tu versión es %s.")
            :format(A.newerAddonVersion, A.addonVersion))
    end)
end
