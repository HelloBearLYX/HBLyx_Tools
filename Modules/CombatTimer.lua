---@class CombatTimer
CombatTimer = {
    frame = nil,
    updateTimer = nil,
    startTime = 0,
}

local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local MOD_KEY = "CombatTimer"

-- MARK: Initialize

---Intialize(Constructor)
---@return CombatTimer CombatTimer a CombatTimer object
function CombatTimer:Initialize()
    if not addon.db[MOD_KEY]["Enabled"] then
        return nil
    end

    self.frame = CreateFrame("Frame", ADDON_NAME .. "TimerFrame", UIParent)
    self.frame:SetFrameStrata("BACKGROUND")
    self.frame:SetSize(100, 40)

    self.frame.text = self.frame:CreateFontString(nil, "OVERLAY")
    self.frame.text:SetAllPoints()

    if addon.db[MOD_KEY]["CombatShow"] then
       self.frame:Hide()
    else
       self.frame:Show()
    end

    self:UpdateStyle()

    self.frame.text:SetText(string.format("%02d:%02d", 0, 0))

    self.updateTimer = nil
    self.startTime = GetTime()

    return self
end

-- private methods

---Set Combat Timer display
---@param self CombatTimer self
---@param min number minutes to show
---@param sec number seconds to show
local function SetDisplay(self, min, sec)
    self.frame.text:SetText(string.format("%02d:%02d", min, sec))
end

---Get combat duration
---@param self CombatTimer self
---@return string durationStr a string formatted as MM:SS for duration
local function GetDuration(self)
    return self.frame.text:GetText()
end

-- MARK: Handler

---Handler for CombatTimer
---@param self CombatTimer self
local function Handler(self)
    if addon.inCombat then
        self.startTime = GetTime()
        self.frame:Show()
        -- update every 1 sec instead of 1 frame to improve the performance
        self.updateTimer = C_Timer.NewTicker(1, function()
            local elapsed = GetTime() - self.startTime
            SetDisplay(self, math.floor(elapsed / 60), math.floor(elapsed % 60))
        end)
    else
        if self.updateTimer then
            self.updateTimer:Cancel()
        end

        if addon.db[MOD_KEY]["PrintEnabled"] then
            addon.Utilities:print(string.format(L["TimerPrintTextIntro"] .. GetDuration(self)))
        end

        if addon.db[MOD_KEY]["CombatShow"] then
            self.frame:Hide()
        end
    end
end

-- public methods
-- MARK: UpdateStyle

---Update style settings and render it in-game for CombatTimer
function CombatTimer:UpdateStyle()
    self.frame:SetPoint("CENTER", UIParent, "CENTER", addon.db[MOD_KEY]["X"], addon.db[MOD_KEY]["Y"])
    self.frame.text:SetFont(
        addon.LSM:Fetch("font", addon.db[MOD_KEY]["Font"]) or "Fonts\\FRIZQT__.TTF",
        addon.db[MOD_KEY]["FontSize"],
        "OUTLINE"
    )
end

-- MARK: Test

---Test mode for CombatTimer
---@param on boolean turn the Test mod on or off
function CombatTimer:Test(on)
    if on then
		self.frame:Show()

        addon.Utilities:MakeFrameDragPosition(self.frame, MOD_KEY, "X", "Y")
    else
        if addon.db[MOD_KEY]["CombatShow"] then
			self.frame:Hide()
		end
    end
end

--MARK: Register Event

---Register events needed by CombatTimer on addon.EventsHandler
function CombatTimer:RegisterEvents()
    local Handle = function () Handler(self) end

    addon.eventsHandler:Register(Handle, "PLAYER_REGEN_DISABLED")
    addon.eventsHandler:Register(Handle, "PLAYER_REGEN_ENABLED")
end