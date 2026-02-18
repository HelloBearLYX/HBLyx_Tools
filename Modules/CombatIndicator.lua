---@class CombatIndicator
---@field frame frame CombatIndicator frame
---@field timer C_Timer timer to keep track of fade time
CombatIndicator = {
    frame = nil,
    timer = nil,
}

local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local MOD_KEY = "CombatIndicator"

--MARK: Initialize
---Initialzie(Constructor)
---@return CombatIndicator CombatIndicator a CombatIndicator object
function CombatIndicator:Initialize()
    self.frame = CreateFrame("Frame", ADDON_NAME .. "_CommbatIndicator", UIParent)
    self.frame:SetFrameStrata("BACKGROUND")
    self.frame:SetSize(300, 40)
    self.frame:Hide()

    self.frame.text = self.frame:CreateFontString(nil, "OVERLAY")
    self.frame.text:SetAllPoints()

    self:UpdateStyle()

    return self
end

--private methods

---Set the text and color of CombatIndicator
---@param self CombatIndicator self
---@param text string text to show
---@param color string hex string of color(6 or 8)
local function SetIndicator(self, inCombat)
    if inCombat then
        self.frame.text:SetText(addon.db[MOD_KEY]["InCombatText"])
        self.frame.text:SetTextColor(addon.Utilities:HexToRGB(addon.db[MOD_KEY]["InCombatColor"]))
    else
        self.frame.text:SetText(addon.db[MOD_KEY]["OutCombatText"])
        self.frame.text:SetTextColor(addon.Utilities:HexToRGB(addon.db[MOD_KEY]["OutCombatColor"]))
    end
end

--MARK: Handler

---Handler for CombatIndicator
local function Handler(self)
    SetIndicator(self, addon.states["inCombat"])
    self.frame:Show()

    if not addon.db[MOD_KEY]["Mute"] then
        if addon.states["inCombat"] then
            PlaySoundFile(addon.LSM:Fetch("sound", addon.db[MOD_KEY]["InCombatSoundMedia"]), addon.db[MOD_KEY]["SoundChannel"])
        else
            PlaySoundFile(addon.LSM:Fetch("sound", addon.db[MOD_KEY]["OutCombatSoundMedia"]), addon.db[MOD_KEY]["SoundChannel"])
        end
    end

    if self.timer then -- if we got overlapped timer, we cancel last one
        self.timer:Cancel()
        self.timer = nil
    end

    self.timer = C_Timer.NewTimer(addon.db[MOD_KEY]["FadeTime"], function ()
        self.frame:Hide()
    end)
end

--public methods
--MARK: UpdateStyle

---Update style settings and render it in-game for CombatIndicator
function CombatIndicator:UpdateStyle()
    self.frame:SetPoint("CENTER", UIParent, "CENTER", addon.db[MOD_KEY]["X"], addon.db[MOD_KEY]["Y"])
    self.frame.text:SetFont(
        addon.LSM:Fetch("font", addon.db[MOD_KEY]["Font"]) or "Fonts\\FRIZQT__.TTF",
        addon.db[MOD_KEY]["FontSize"],
        "OUTLINE"
    )
end

--MARK: Test

---Test mode for CombatIndicator
---@param on boolean turn the Test mode on or off
function CombatIndicator:Test(on)
    if on then
        if self.timer then -- if there is a active timer, we cancel it to prevent unexpected hiding
            self.timer:Cancel()
            self.timer = nil
        end

        SetIndicator(self, true)
        self.timer = C_Timer.NewTicker(addon.db[MOD_KEY]["FadeTime"], function ()
            if self.frame.text:GetText() == addon.db[MOD_KEY]["InCombatText"] then
                SetIndicator(self, false)
            else
                SetIndicator(self, true)
            end
        end)

        self.frame:Show()

        addon.Utilities:ShowDragRegion(self.frame, L["CombatSettings"])
        addon.Utilities:MakeFrameDragPosition(self.frame, MOD_KEY, "X", "Y")
    else
        addon.Utilities:HideDragRegion(self.frame)

        if self.timer then
            self.timer:Cancel()
            self.timer = nil
        end

        self.frame:Hide()
    end
end

--MARK: Register Event

---Register events for CombatIndicator on EventsHandler
function CombatIndicator:RegisterEvents()
    local HandleActive = function () Handler(self) end
    addon.core:RegisterStateMonitor("inCombat", MOD_KEY, HandleActive)
end

-- MARK: Register Module
addon.core:RegisterModule(MOD_KEY, function() return CombatIndicator:Initialize() end, function() CombatIndicator:RegisterEvents() end)