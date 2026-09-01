local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class Countdown
local Countdown = {
    modName = "Countdown",
}

-- MARK: Constants
local M_PLUS_START_TIMER = 9 -- the duration of the countdown when a Mythic+ dungeon starts

-- MARK: Initialize

---Initialize (Constructor)
---@return Countdown Countdown a Countdown object
function Countdown:Initialize()
    self.frame = CreateFrame("Frame", ADDON_NAME .. self.modName, UIParent)
    self.frame.text = self.frame:CreateFontString(nil, "OVERLAY")
    self.frame.text:SetAllPoints()
    self.timer = nil

    -- hide Blizzard's default countdown frame
    TimerTracker:Hide()

    -- register "/pull num" command
    SLASH_HBES_PULL1 = "/pull"
    SlashCmdList["HBLYX_PULL"] = function(message)
        local num = tonumber(message)
        if num then
            C_PartyInfo.DoCountdown(num)
        end
    end
 
    return self
end

-- MARK: Victory Sound
local function PlayVictorySound()
    local sound = addon.LSM:Fetch("sound", addon.db.Countdown.VictorySound)
    if sound then
        PlaySoundFile(sound, addon.db.Countdown.SoundChannel or "Master")
    end
end

-- MARK: Countdown Sound

--- Play countdown sound based on the remaining duration
--- @param duration number the remaining duration of the countdown in seconds
--- @return boolean whether a sound was played
local function PlayCountdownSound(duration)
    if duration == 5 then
        local sound = addon.LSM:Fetch("sound", addon.db.Countdown.FiveSound)
        if sound then
            PlaySoundFile(sound, addon.db.Countdown.SoundChannel or "Master")
        end
    elseif duration == 4 then
        local sound = addon.LSM:Fetch("sound", addon.db.Countdown.FourSound)
        if sound then
            PlaySoundFile(sound, addon.db.Countdown.SoundChannel or "Master")
        end
    elseif duration == 3 then
        local sound = addon.LSM:Fetch("sound", addon.db.Countdown.ThreeSound)
        if sound then
            PlaySoundFile(sound, addon.db.Countdown.SoundChannel or "Master")
        end
    elseif duration == 2 then
        local sound = addon.LSM:Fetch("sound", addon.db.Countdown.TwoSound)
        if sound then
            PlaySoundFile(sound, addon.db.Countdown.SoundChannel or "Master")
        end
    elseif duration == 1 then
        local sound = addon.LSM:Fetch("sound", addon.db.Countdown.OneSound)
        if sound then
            PlaySoundFile(sound, addon.db.Countdown.SoundChannel or "Master")
        end
    else
        return false
    end

    return true
end

-- MARK: Countdown Text

local function GetCountdownText(duration)
    if duration > 60 then
        local minutes = math.floor(duration / 60)
        local seconds = duration % 60
        return string.format("%d:%02d", minutes, seconds)
    else
        return tostring(duration)
    end
end

-- MARK: Simple CD

--- Simple countdown
--- @param duration number the duration of the countdown in seconds
local function SimpleCountdown(self, duration)
    self.frame:Show()
    self.frame.text:SetText(GetCountdownText(duration))
    local sound = addon.LSM:Fetch("sound", addon.db.Countdown.StartSound)
    if sound then
        PlaySoundFile(sound, addon.db.Countdown.SoundChannel or "Master")
    end

    self.timer = C_Timer.NewTicker(1, function()
        duration = duration - 1
        if duration <= 0 then
            self.frame:Hide()
            self.timer:Cancel()
            self.timer = nil
        else
            self.frame.text:SetText(GetCountdownText(duration))
            PlayCountdownSound(duration)
        end
    end, math.ceil(duration))
end

-- MARK: Test CD

--- Test countdown (loops from 10 to 1 for testing purposes)
local function TestCountdown(self)
    local duration = 10
    self.frame:Show()
    self.frame.text:SetText(tostring(duration))
    self.timer = C_Timer.NewTicker(1, function()
        duration = duration - 1
        if duration <= 0 then
            -- loop the countdown for testing purposes
            duration = 11
        else
            self.frame.text:SetText(tostring(duration))
            -- PlayCountdownSound(duration) -- disable sound in test mode to avoid spamming
        end
    end)
end

-- MARK: Countdown API

--- Countdown API
--- @param duration number the duration of the countdown in seconds
--- @param type string|nil the type of countdown, nil for default "SIMPLE"
--- @return boolean whether the countdown was successfully started
function Countdown:countdown(duration, type)
    -- if duration is zero or negative, hide the frame and cancel any existing timer
    if duration <= 0 then
        self.frame:Hide()
        if self.timer then
            self.timer:Cancel()
            self.timer = nil
        end
        return true
    end

    if not type then -- if type is not provided, default to "SIMPLE"
        type = "SIMPLE"
    end

    -- if there is an existing timer, cancel it before starting a new one
    if self.timer then
        self.timer:Cancel()
        self.timer = nil
    end

    if type == "SIMPLE" then
        SimpleCountdown(self, duration)
    elseif type == "TEST" then
        TestCountdown(self)
    else
        addon:debug("Unsupported countdown type: " .. tostring(type))
        return false
    end

    return true
end

-- MARK: UpdateStyle

---Update style settings and render them in-game for CustomTracker
function Countdown:UpdateStyle()
    self.frame:SetSize(math.max(addon.db[self.modName]["FontSize"] * 2, 60), math.max(addon.db[self.modName]["FontSize"], 30))
    self.frame:SetPoint("CENTER", UIParent, "CENTER", addon.db[self.modName]["X"], addon.db[self.modName]["Y"])
    self.frame.text:SetFont(addon.LSM:Fetch("font", addon.db[self.modName]["Font"]) or "Fonts\\FRIZQT__.TTF", addon.db[self.modName]["FontSize"], "OUTLINE")
    self.frame.text:SetTextColor(addon.Utilities:HexToRGB(addon.db[self.modName]["FontColor"]))
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function Countdown:Test(on)
    if not addon.db[self.modName]["Enabled"] then -- if the module is not enabled, do not allow test mode
        return
    end

    if on then
        addon.Utilities:ShowDragRegion(self.frame, L["CountdownSettings"])
        addon.Utilities:MakeFrameDragPosition(self.frame, self.modName, "X", "Y")
        self:countdown(10, "TEST") -- start a 10-second countdown for testing
    else
        addon.Utilities:HideDragRegion(self.frame)
        self:countdown(0) -- stop the countdown
    end
end

-- MARK: RegisterEvents

--- Register events
function Countdown:RegisterEvents()
    addon.core:RegisterEvent("START_PLAYER_COUNTDOWN", self.frame, self.modName)
    addon.core:RegisterEvent("CANCEL_PLAYER_COUNTDOWN", self.frame, self.modName)
    addon.core:RegisterEvent("CHALLENGE_MODE_RESET", self.frame, self.modName)

    self.frame:SetScript("OnEvent", function(_, event, ...)
        if event == "START_PLAYER_COUNTDOWN" then
            local duration = select(3, ...)
            self:countdown(duration)
        elseif event == "CANCEL_PLAYER_COUNTDOWN" then
            self:countdown(0)
        elseif event == "CHALLENGE_MODE_RESET" then
            self:countdown(M_PLUS_START_TIMER) -- start a 9-second countdown when a Mythic+ dungeon starts
        end
    end)

    addon.core:RegisterStateMonitor("encounterInfo", self.modName, function()
        if addon.states["encounterInfo"].success == 1 then
            PlayVictorySound()
        end
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(Countdown.modName, function() return Countdown:Initialize() end)
