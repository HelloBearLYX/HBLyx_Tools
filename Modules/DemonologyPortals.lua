local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class DemonologyPortals
local DemonologyPortals = {
    modName = "DemonologyPortals",
    frame = nil,
}

-- MARK: Constants
local PORTAL_ACTIVE_DURATION = 25
local DEMONOLOGY_SPEC_ID = 266
local TYRANT_ID = 265187
local HANDOFGULDAN_ID = 105174
local PORTAL_TEXTURE = 7636567
local SPLITTER = "-"

-- MARK: Initialize

---Initialize (Constructor)
---@return DemonologyPortals DemonologyPortals a DemonologyPortals object
function DemonologyPortals:Initialize()
    self.frame = CreateFrame("Frame", ADDON_NAME .. "_DemonologyPortalsFrame", UIParent)
    self.frame.cooldown = CreateFrame("Cooldown", nil, self.frame, "CooldownFrameTemplate")
    self.frame.cooldown:SetAllPoints()
    self.frame.cooldown:SetReverse(true)
    self.frame.cooldown:SetDrawEdge(false)
    self.frame.icon = self.frame:CreateTexture(nil, "BACKGROUND")
    self.frame.icon:SetAllPoints()
    self.frame.icon:SetTexture(PORTAL_TEXTURE)
    self.frame.icon:SetDesaturated(true) -- start with desaturated icon since there is no active portal at the beginning
    self.frame.border = CreateFrame("Frame", nil, self.frame, "BackdropTemplate")
    self.frame.border:SetAllPoints()
    self.frame.border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    self.frame.border:SetBackdropBorderColor(0, 0, 0, 1)
    self.frame.text = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.frame.text:SetTextColor(1, 1, 1, 1)

    self.frame.active = false
    self.frame.timer = nil
    self.frame.count = 0

    return self
end

-- MARK: Spec Activate
---Activate the module when the player is in Demonology spec
local function SpecActivate(self)
    if addon.db[self.modName]["Enabled"] and addon.states["playerSpec"] == DEMONOLOGY_SPEC_ID and not addon.db[self.modName]["HideWhenInactive"] then
        self.frame:Show()
    else
        self.frame:Hide()
    end
end

-- MARK: Compute Count
---Compute the count of the number of portals based on the spell casts
---@param count number the current count of the number of portals
local function ComputeCount(count)
    local summoned = math.floor(count / 2)
    local pending = count % 2
    local output = string.format("%d%s%d", summoned, SPLITTER, pending)
    return output
end

-- MARK: Deactivate Count
---Deactivate the count of the number of portals
local function DeactivateCount(self)
    self.frame.active = false
    self.frame.icon:SetDesaturated(true)
    if addon.db[self.modName]["PrintToChat"] then
        local message = string.format(L["PortalExpiredMessage"], ComputeCount(self.frame.count))
        addon.Utilities:print(message)
    end
    if addon.db[self.modName]["HideWhenInactive"] then
        self.timer = C_Timer.After(addon.db[self.modName]["HideDelay"] or 5, function()
            if not self.frame.active then
                self.frame:Hide()
            end
        end)
    end
end

-- MARK: Activate Count
---Start the count of the number of portals
local function ActivateCount(self)
    self.frame:Show()
    self.frame.active = true
    self.frame.count = 0
    self.frame.text:SetText("")
    self.frame.icon:SetDesaturated(false)
    self.frame.cooldown:SetCooldownDuration(PORTAL_ACTIVE_DURATION)
    self.frame.timer = C_Timer.After(PORTAL_ACTIVE_DURATION, function()
        DeactivateCount(self)
    end)
end

-- MARK: Increment Count
---Increment the count of the number of portals
local function IncrementCount(self)
    if self.frame.active then
        self.frame.count = self.frame.count + 1
        self.frame.text:SetText(ComputeCount(self.frame.count))
    end
end

-- MARK: Test Simulation
---Simulate the count of the number of portals for testing
local function SimulateCount(self, on)
    if on then
        self.frame.active = true
        self.frame.count = 11
        self.frame.text:SetText(ComputeCount(self.frame.count))
        self.frame.icon:SetDesaturated(false)
        self.frame.cooldown:SetCooldownDuration(50)
    else
        self.frame.active = false
        self.frame.count = 0
        self.frame.text:SetText("")
        self.frame.icon:SetDesaturated(true)
        self.frame.cooldown:Clear()
    end
end

-- MARK: UpdateStyle

---Update style settings and render them in-game for CustomTracker
function DemonologyPortals:UpdateStyle()
    self.frame:SetFrameStrata(addon.db[self.modName]["FrameStrata"] or "MEDIUM")
    self.frame:SetSize(addon.db[self.modName]["IconSize"], addon.db[self.modName]["IconSize"])
    self.frame:SetPoint("CENTER", UIParent, "CENTER", addon.db[self.modName]["X"], addon.db[self.modName]["Y"])

    self.frame.cooldown:SetScale(addon.db[self.modName]["TimeFontScale"])
    self.frame.icon:SetTexCoord(addon.db[self.modName]["IconZoom"], 1 - addon.db[self.modName]["IconZoom"], addon.db[self.modName]["IconZoom"], 1 - addon.db[self.modName]["IconZoom"])
    self.frame.text:SetFont(
        addon.LSM:Fetch("font", addon.db[self.modName]["CountFont"] or "Fonts\\FRIZQT__.TTF"),
        addon.db[self.modName]["CountFontSize"],
        "OUTLINE"
    )
    local anchorFrom = addon.Utilities:GetAnchorFrom(addon.db[self.modName]["CountAnchor"])
    self.frame.text:SetPoint(anchorFrom, self.frame, addon.db[self.modName]["CountAnchor"], addon.db[self.modName]["CountFontOffsetX"], addon.db[self.modName]["CountFontOffsetY"])
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function DemonologyPortals:Test(on)
    if not addon.db[self.modName]["Enabled"] then -- if the module is not enabled, do not allow test mode
        return
    end

    if on then
        self.frame:Show()
        SimulateCount(self, true)
        addon.Utilities:MakeFrameDragPosition(self.frame, self.modName, "X", "Y")
    else
        SimulateCount(self, false)
        SpecActivate(self)
    end
end

-- MARK: RegisterEvents

---Register events
function DemonologyPortals:RegisterEvents()
    addon.core:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self.frame, self.modName, "player")
    addon.core:RegisterStateMonitor("playerSpec", self.modName, function()
        SpecActivate(self)
    end)

    self.frame:SetScript("OnEvent", function(_, event, ...)
        if event == "UNIT_SPELLCAST_SUCCEEDED" then
            local spellID = select(3, ...)
            if spellID == TYRANT_ID then
                ActivateCount(self)
            elseif spellID == HANDOFGULDAN_ID then
                IncrementCount(self)
            end
        end
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(DemonologyPortals.modName, function() return DemonologyPortals:Initialize() end)
