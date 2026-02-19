local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class CombatIndicator
---@field frame frame CombatIndicator frame
---@field timer C_Timer timer to keep track of fade time
---@field modName string module name for registering in core
local CombatIndicator = {
    modName = "CombatIndicator",
    frame = CreateFrame("Frame", ADDON_NAME .. "_CombatIndicator", UIParent),
}

--MARK: Initialize
---Initialzie(Constructor)
---@return CombatIndicator CombatIndicator a CombatIndicator object
function CombatIndicator:Initialize()
    self.frame:SetFrameStrata("BACKGROUND")
    self.frame:SetSize(300, 40)
    self.frame:Hide()

    self.frame.text = self.frame:CreateFontString(nil, "OVERLAY")
    self.frame.text:SetAllPoints()

    return self
end

--private methods

---Set the text and color of CombatIndicator
---@param self CombatIndicator self
---@param text string text to show
---@param color string hex string of color(6 or 8)
local function SetIndicator(self, inCombat)
    if inCombat then
        self.frame.text:SetText(addon.db[self.modName]["InCombatText"])
        self.frame.text:SetTextColor(addon.Utilities:HexToRGB(addon.db[self.modName]["InCombatColor"]))
    else
        self.frame.text:SetText(addon.db[self.modName]["OutCombatText"])
        self.frame.text:SetTextColor(addon.Utilities:HexToRGB(addon.db[self.modName]["OutCombatColor"]))
    end
end

--MARK: Handler

---Handler for CombatIndicator
local function Handler(self)
    SetIndicator(self, addon.states["inCombat"])
    self.frame:Show()

    if not addon.db[self.modName]["Mute"] then
        if addon.states["inCombat"] then
            PlaySoundFile(addon.LSM:Fetch("sound", addon.db[self.modName]["InCombatSoundMedia"]), addon.db[self.modName]["SoundChannel"])
        else
            PlaySoundFile(addon.LSM:Fetch("sound", addon.db[self.modName]["OutCombatSoundMedia"]), addon.db[self.modName]["SoundChannel"])
        end
    end

    if self.timer then -- if we got overlapped timer, we cancel last one
        self.timer:Cancel()
        self.timer = nil
    end

    self.timer = C_Timer.NewTimer(addon.db[self.modName]["FadeTime"], function ()
        self.frame:Hide()
    end)
end

--public methods
--MARK: UpdateStyle

---Update style settings and render it in-game for CombatIndicator
function CombatIndicator:UpdateStyle()
    self.frame:SetPoint("CENTER", UIParent, "CENTER", addon.db[self.modName]["X"], addon.db[self.modName]["Y"])
    self.frame.text:SetFont(
        addon.LSM:Fetch("font", addon.db[self.modName]["Font"]) or "Fonts\\FRIZQT__.TTF",
        addon.db[self.modName]["FontSize"],
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
        self.timer = C_Timer.NewTicker(5, function ()
            if self.frame.text:GetText() == addon.db[self.modName]["InCombatText"] then
                SetIndicator(self, false)
            else
                SetIndicator(self, true)
            end
        end)

        self.frame:Show()

        addon.Utilities:ShowDragRegion(self.frame, L["CombatSettings"])
        addon.Utilities:MakeFrameDragPosition(self.frame, self.modName, "X", "Y")
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
    local OnStateUpdate = function () Handler(self) end
    addon.core:RegisterStateMonitor("inCombat", self.modName, OnStateUpdate)
end

-- MARK: Register Module
addon.core:RegisterModule(CombatIndicator.modName, function() return CombatIndicator:Initialize() end)