local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class RangeAlert
---@field frame frame RangeAlert frame
---@field ticker C_Timer ticker used to poll the current range at a fixed interval
---@field modName string module name for registering in core
local RangeAlert = {
    modName = "RangeAlert",
    frame = nil,
    ticker = nil,
}

local LRC = LibStub("LibRangeCheck-3.0", true)

-- MARK: Constants

-- Hard-coded "out of range" distance(yards) per specialization: {specID = range}
-- Any spec not listed here falls back to DEFAULT_RANGE_THRESHOLD
-- e.g. [253] = 40, -- Beast Mastery Hunter
local SPEC_RANGE_THRESHOLDS = {
    -- Death Knight
    [250] = 5, -- Blood
    [251] = 5, -- Frost
    [252] = 5, -- Unholy
    -- Demon Hunter
    [577] = 5, -- Havoc
    [581] = 5, -- Vengeance
    [1456] = 25, -- Devourer
    -- Druid
    [102] = 40, -- Balance
    [103] = 5, -- Feral
    [104] = 5, -- Guardian
    [105] = 40, -- Restoration
    -- Evoker
    [1467] = 25, -- Devastation
    [1468] = 25, -- Preservation
    [1473] = 25, -- Augmentation
    -- Hunter
    [253] = 40, -- Beast Mastery
    [254] = 40, -- Marksmanship
    [255] = 5, -- Survival
    -- Mage
    [62] = 40, -- Arcane
    [63] = 40, -- Fire
    [64] = 40, -- Frost
    -- Monk
    [268] = 5, -- Brewmaster
    [269] = 5, -- Windwalker
    [270] = 5, -- Mistweaver
    -- Paladin
    [65] = 5, -- Holy
    [66] = 5, -- Protection
    [70] = 5, -- Retribution
    -- Priest
    [256] = 40, -- Discipline
    [257] = 40, -- Holy
    [258] = 40, -- Shadow
    -- Rogue
    [259] = 5, -- Assassination
    [260] = 5, -- Outlaw
    [261] = 5, -- Subtlety
    -- Shaman
    [262] = 40, -- Elemental
    [263] = 5, -- Enhancement
    [264] = 40, -- Restoration
    -- Warlock
    [265] = 40, -- Affliction
    [266] = 40, -- Demonology
    [267] = 40, -- Destruction
    -- Warrior
    [71] = 5, -- Arms
    [72] = 5, -- Fury
    [73] = 5, -- Protection
}
local DEFAULT_RANGE_THRESHOLD = 40
local UPDATE_INTERVAL = 0.3
local FRAME_STRATA = "BACKGROUND"

-- Distance brackets(yards) for the optional range display; "min" decides which bracket a given minRange falls
-- into (checked from largest to smallest), "key" is both the label shown in the config panel and the db key
-- used to look up its customizable color
local RANGE_DISPLAY_BRACKETS = {
    { key = "40+", min = 40 },
    { key = "30-40", min = 30 },
    { key = "20-30", min = 20 },
    { key = "10-20", min = 10 },
    { key = "5-10", min = 5 },
    { key = "0-5", min = 0 },
}

-- private methods

local function CreateRAFrame()
    local frame = CreateFrame("Frame", ADDON_NAME .. "_RangeAlert", UIParent)
    frame:SetFrameStrata(FRAME_STRATA)
    frame:Hide()

    frame.text = frame:CreateFontString(nil, "OVERLAY")
    frame.text:SetAllPoints()

    return frame
end

---Get the hard-coded out-of-range threshold(yards) for the current specialization
---@return number threshold distance in yards at which the reminder shows
local function GetRangeThreshold()
    return SPEC_RANGE_THRESHOLDS[addon.states.playerSpec] or DEFAULT_RANGE_THRESHOLD
end

---Get the customizable display color for a given minRange, keyed by distance bracket
---@param self RangeAlert self
---@param minRange number? the minimum possible distance to the target
---@return number r
---@return number g
---@return number b
local function GetRangeDisplayColor(self, minRange)
    local colors = addon.db[self.modName]["RangeDisplayColors"]

    if minRange then
        for _, bracket in ipairs(RANGE_DISPLAY_BRACKETS) do
            if minRange >= bracket.min then
                return addon.Utilities:HexToRGB(colors[bracket.key])
            end
        end
    end

    return addon.Utilities:HexToRGB(colors["0-5"])
end

---Format the live range display text, e.g. "15 - 20", or "40+" when the max range is unknown
---@param minRange number
---@param maxRange number?
---@return string
local function FormatRangeText(minRange, maxRange)
    if not maxRange then
        return string.format("%d+", minRange)
    end

    return string.format("%d - %d", minRange, maxRange)
end

-- MARK: Handler

---Handler for RangeAlert
---@param self RangeAlert self
local function Handler(self)
    if addon.core:IsTestOn() then -- test mode always shows the alert, skip the normal show/hide logic
        return
    end

    -- only evaluate attackable targets: a non-attackable unit(e.g. friendly/neutral) has no "harm" spell
    -- checkers to use, so LRC would otherwise fall back to coarse interact-distance checks
    if not UnitExists("target") or not UnitCanAttack("player", "target") then
        self.frame:Hide()
        return
    end

    local minRange, maxRange = LRC:GetRange("target")
    local outOfRange = minRange ~= nil and minRange >= GetRangeThreshold()

    if outOfRange then
        self.frame.text:SetText(addon.db[self.modName]["AlertText"])
        self.frame.text:SetTextColor(addon.Utilities:HexToRGB(addon.db[self.modName]["Color"]))
        self.frame:Show()
    elseif addon.db[self.modName]["ShowRangeDisplay"] then
        if minRange then
            self.frame.text:SetText(FormatRangeText(minRange, maxRange))
            self.frame.text:SetTextColor(GetRangeDisplayColor(self, minRange))
            self.frame:Show()
        else
            self.frame:Hide()
        end
    else
        self.frame:Hide()
    end
end

-- MARK: Initialize

---Initialize(Constructor)
---@return RangeAlert? RangeAlert a RangeAlert object, or nil if LibRangeCheck-3.0 is missing
function RangeAlert:Initialize()
    if not LRC then
        addon.Utilities:print("|cffff0000" .. L["RangeAlertLibMissing"] .. "|r")
        return nil
    end

    self.frame = CreateRAFrame()

    return self
end

-- MARK: UpdateStyle

---Update style settings and render it in-game for RangeAlert
function RangeAlert:UpdateStyle()
    self.frame:SetFrameStrata(addon.db[self.modName]["FrameStrata"] or FRAME_STRATA)
    self.frame:SetPoint("CENTER", UIParent, "CENTER", addon.db[self.modName]["X"], addon.db[self.modName]["Y"])
    self.frame:SetSize(300, addon.db[self.modName]["FontSize"] * 1.5)

    local font = addon.LSM:Fetch("font", addon.db[self.modName]["Font"]) or addon.DEFAULTS.font
    local fontSize = addon.db[self.modName]["FontSize"] or 24
    self.frame.text:SetFont(font, fontSize, "OUTLINE")
    self.frame.text:SetTextColor(addon.Utilities:HexToRGB(addon.db[self.modName]["Color"]))
    self.frame.text:SetText(addon.db[self.modName]["AlertText"])
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function RangeAlert:Test(on)
    if on then
        self.frame:Show()
        addon.Utilities:ShowEditFrame(self.frame, addon.db[self.modName], "X", "Y", nil, L["RangeAlertSettings"], self.modName)
    else
        addon.Utilities:HideEditFrame(self.frame)
        self.frame:Hide()
        Handler(self)
    end
end

-- MARK: RegisterEvents

---Register events needed by RangeAlert
function RangeAlert:RegisterEvents()
    local function OnEvent()
        Handler(self)
    end

    addon.core:RegisterEvent("PLAYER_TARGET_CHANGED", self.frame, self.modName)
    self.frame:SetScript("OnEvent", OnEvent)

    -- the range to a standing target can change without any event firing, so poll it on an interval
    self.ticker = C_Timer.NewTicker(UPDATE_INTERVAL, function() Handler(self) end)
end

---Unregister events needed by RangeAlert
function RangeAlert:UnregisterEvents()
    addon.core:UnregisterEvent("PLAYER_TARGET_CHANGED", self.frame, self.modName)

    if self.ticker then
        self.ticker:Cancel()
        self.ticker = nil
    end
end

-- MARK: Register Module
addon.core:RegisterModule(RangeAlert.modName, L["RangeAlertSettings"], function() return RangeAlert:Initialize() end)
