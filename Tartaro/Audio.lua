local _, A = ...
if A.traceLoad then A.traceLoad("module.begin", "Audio.lua") end
local channels = {"Sound_SFXVolume", "Sound_MusicVolume", "Sound_AmbienceVolume", "Sound_DialogVolume"}
local paused

local restoreAudio; restoreAudio = A.traceCallback("Audio.lua:6:restoreAudio", function()
    if not paused then return end
    local previous = paused
    paused = nil
    for channel, volume in pairs(previous.volumes) do
        local ok, current = A.debugPcall("Audio.lua:11:pcall", previous.get, channel)
        if ok and tonumber(current) == 0 then A.debugPcall("Audio.lua:12:pcall", previous.set, channel, volume) end
    end
end)

A.stopCallAlert = A.traceCallback("Audio.lua:16:A.stopCallAlert", function()
    if paused and paused.handle and StopSound then A.debugPcall("Audio.lua:17:pcall", StopSound, paused.handle) end
    restoreAudio()
end)

A.playCallAlert = A.traceCallback("Audio.lua:21:A.playCallAlert", function(file, duration)
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
            local ok, volume = A.debugPcall("Audio.lua:35:pcall", get, channel)
            if ok and tonumber(volume) and tonumber(volume) > 0 then
                paused.volumes[channel] = volume
                A.debugPcall("Audio.lua:38:pcall", set, channel, "0")
            end
        end
    end

    local ok, played, handle = A.debugPcall("Audio.lua:43:pcall", PlaySoundFile, file, "Master")
    if not ok or not played then
        if fresh then restoreAudio() end
        return false
    end
    local previousHandle = paused.handle
    paused.handle = handle
    if previousHandle and previousHandle ~= handle and StopSound then A.debugPcall("Audio.lua:50:pcall", StopSound, previousHandle) end
    local timerToken = {}
    paused.timerToken = timerToken
    C_Timer.After(duration, A.traceCallback("Audio.lua:53:callback", function()
        if paused and paused.timerToken == timerToken then restoreAudio() end
    end))
    return played, handle
end)

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", restoreAudio)
if A.traceLoad then A.traceLoad("module.end", "Audio.lua") end
