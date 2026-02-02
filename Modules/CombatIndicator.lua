---@class CombatIndicator
---@field frame frame CombatIndicator frame
---@field timer C_Timer timer to keep track of fade time
CombatIndicator = {
    frame = nil,
    timer = nil,
}

local ADDON_NAME, addon = ...
local MOD_KEY = "CombatIndicator"

--MARK: Initialize
---Initialzie(Constructor)
---@return CombatIndicator CombatIndicator a CombatIndicator object
function CombatIndicator:Initialize()
    if not addon.db[MOD_KEY]["Enabled"] then
        return nil
    end

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
local function SetDisplay(self, text, color)
    self.frame.text:SetText(text)
    self.frame.text:SetTextColor(addon.Utilities:HexToRGB(color))
end


--MARK: Handler

---Handler for CombatIndicator
local function Handler(self)
    -- local startTime = GetTime()
    local text, color
    if addon.inCombat then
        text = addon.db[MOD_KEY]["InCombatText"]
        color = addon.db[MOD_KEY]["InCombatColor"]
    else
        text = addon.db[MOD_KEY]["OutCombatText"]
        color = addon.db[MOD_KEY]["OutCombatColor"]
    end

    SetDisplay(self, text, color)
    self.frame:Show()

    if not addon.db[MOD_KEY]["Mute"] then
        if addon.inCombat then
            PlaySoundFile(addon.LSM:Fetch("sound", addon.db[MOD_KEY]["InCombatSoundMeida"]), "Master")
        else
            PlaySoundFile(addon.LSM:Fetch("sound", addon.db[MOD_KEY]["OutCombatSoundMedia"]), "Master")
        end
    end

    if self.timer then -- if we got overlapped timer, we cancel last one
        self.timer:Cancel()
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
        SetDisplay(self, addon.db[MOD_KEY]["InCombatText"], addon.db[MOD_KEY]["InCombatColor"])
        self.frame:Show()

        addon.Utilities:MakeFrameDragPosition(self.frame, MOD_KEY, "X", "Y")
    else
        self.frame:Hide()
    end
end

--MARK: Register Event

---Register events for CombatIndicator on EventsHandler
function CombatIndicator:RegisterEvents()
    local HandleActive = function () Handler(self) end

    addon.eventsHandler:Register(HandleActive, "PLAYER_REGEN_DISABLED")
    addon.eventsHandler:Register(HandleActive, "PLAYER_REGEN_ENABLED")
end