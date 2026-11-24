local _, A = ...
local channels = {"Sound_SFXVolume", "Sound_MusicVolume", "Sound_AmbienceVolume", "Sound_DialogVolume"}
local paused

local function restoreAudio()
    if not paused then return end
    local previous = paused
    paused = nil
    for channel, volume in pairs(previous.volumes) do
        local ok, current = pcall(previous.get, channel)
        if ok and tonumber(current) == 0 then pcall(previous.set, channel, volume) end
    end
end

function A.stopCallAlert()
    if paused and paused.handle and StopSound then pcall(StopSound, paused.handle) end
    restoreAudio()
end

function A.playCallAlert(file, duration)
    local get = C_CVar and C_CVar.GetCVar or GetCVar
    local set = C_CVar and C_CVar.SetCVar or SetCVar
    if not get or not set then
        A.stopCallAlert()
        local played, handle = PlaySoundFile(file, "SFX")
        if played then paused = {handle = handle, volumes = {}} end
        return played, handle
    end

    local fresh = not paused
    if fresh then
        paused = {get = get, set = set, volumes = {}}
        for _, channel in ipairs(channels) do
            local ok, volume = pcall(get, channel)
            if ok and tonumber(volume) and tonumber(volume) > 0 then
                paused.volumes[channel] = volume
                pcall(set, channel, "0")
            end
        end
    end

    local ok, played, handle = pcall(PlaySoundFile, file, "Master")
    if not ok or not played then
        if fresh then restoreAudio() end
        return false
    end
    local previousHandle = paused.handle
    paused.handle = handle
    if previousHandle and previousHandle ~= handle and StopSound then pcall(StopSound, previousHandle) end
    local timerToken = {}
    paused.timerToken = timerToken
    C_Timer.After(duration, function()
        if paused and paused.timerToken == timerToken then restoreAudio() end
    end)
    return played, handle
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", restoreAudio)
