local ADDON_NAME, addon = ...

---@class BattleRes
---@field frame frame BattleRes frame
---@field modName string module name for registering in core
local BattleRes = {
    modName = "BattleRes",
    frame = nil,
    active = false,
    db = nil,
}

--MARK: Constants
local BATTLE_RES_ID = 20484
local BATTLE_RES_TEXTURE = 136080


-- private methods

local function CreateBRFrame(self)
    local frame = CreateFrame("Frame", ADDON_NAME .. "_BattleRes", UIParent, "BackdropTemplate")
    frame:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    frame:SetBackdropBorderColor(0, 0, 0, 1)

    local icon = frame:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints()
    icon:SetTexture(BATTLE_RES_TEXTURE)
    frame.icon = icon

    local cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    cooldown:SetAllPoints()
    cooldown:SetDrawEdge(false)
    cooldown:SetReverse(true)
    cooldown:SetCountdownAbbrevThreshold(600)
    frame.cooldown = cooldown

    local charge = frame:CreateFontString(nil, "OVERLAY")
    charge:SetPoint("CENTER", frame, "BOTTOM", 0, 0)
    charge:SetTextColor(1, 1, 1, 1)
    charge:SetFont(
        addon.LSM:Fetch("font", self.db["Font"]) or "Fonts\\FRIZQT__.TTF",
        self.db["ChargeFontSize"],
        "OUTLINE"
    )
    frame.charge = charge

    return frame
end

-- MARK: Handler

local function Reset(self)
    self.frame.charge:SetText("")
    self.frame.cooldown:SetCooldownDuration(0)
    self.active = false
end

local function ApplyVisibility(self)
    -- if active, always show the frame, otherwise, show or hide the frame based on the HideInactive settings
    if self.active then
        self.frame:Show()
    else
        if addon.db[self.modName]["HideInactive"] then
            self.frame:Hide()
        else
            self.frame:Show()
        end
    end
end

---Handler for BattleRes
---@param self BattleRes self
local function Handler(self)
    if self.active then
        local chargeCount = C_Spell.GetSpellDisplayCount(BATTLE_RES_ID)
        self.frame.charge:SetText(chargeCount or "")

        if chargeCount and chargeCount > 0 then
            self.frame.icon:SetDesaturated(false)
        else
            self.frame.icon:SetDesaturated(true)
        end

        local durationObj = C_Spell.GetSpellChargeDuration(BATTLE_RES_ID)
        self.frame.cooldown:SetCooldownDuration((durationObj and durationObj:GetRemainingDuration()) or 0)
    else
        Reset(self)
    end

    ApplyVisibility(self)
end

--MARK: Initialize

---Initialize(Constructor)
---@return BattleRes BattleRes a BattleRes object
function BattleRes:Initialize()
    self.active = false
    self.db = addon.db[self.modName]
    self.frame = CreateBRFrame(self)

    return self
end

-- public methods
-- MARK: UpdateStyle

---Update style settings and render it in-game for BattleRes
function BattleRes:UpdateStyle()
    self.frame:SetFrameStrata(self.db["FrameStrata"] or "BACKGROUND")
    self.frame:SetSize(self.db["IconSize"], self.db["IconSize"])

    self.frame.icon:SetTexCoord(self.db["IconZoom"], 1 - self.db["IconZoom"], self.db["IconZoom"], 1 - self.db["IconZoom"])

    self.frame:SetPoint("CENTER", UIParent, "CENTER", self.db["X"], self.db["Y"])

    self.frame.cooldown:SetScale(self.db["TimeFontScale"])

    self.frame.charge:SetFont(
        addon.LSM:Fetch("font", self.db["Font"]) or "Fonts\\FRIZQT__.TTF",
        self.db["ChargeFontSize"],
        "OUTLINE"
    )

    ApplyVisibility(self)
end

-- MARK: Test

---Test mode of BattleRes
---@param Test boolean turn the Test mod on or off
function BattleRes:Test(Test)
    if Test then
        -- make a demo for testMode
        self.frame.charge:SetText("5")
        self.frame.cooldown:SetCooldown(GetTime(), 90)
        self.frame.icon:SetDesaturated(false)
        self.active = true

        addon.Utilities:MakeFrameDragPosition(self.frame, self.modName, "X", "Y")
    else
        -- reset all data
        self.frame.charge:SetText("")
        self.frame.cooldown:SetCooldown(0, 0)
        self.frame.icon:SetDesaturated(false)
        self.active = false
    end

    ApplyVisibility(self)
end

--MARK: Register Event

---Register events needed
function BattleRes:RegisterEvents()
    local function OnEvent(event, ...)
        if addon.core.testMode then
            return
        end

        if event == "ENCOUNTER_START" or event == "CHALLENGE_MODE_START" then
            self.active = true
        elseif  event == "CHALLENGE_MODE_COMPLETED" then
            self.active = false
        elseif event == "ENCOUNTER_END" then
            -- keep the module active if it is M+ dungeon, otherwise, set it to inactive
            if addon.states["instanceInfo"].difficultyID ~= 8 and addon.states["instanceInfo"].difficultyID ~= 23 then
                self.active = false
            end
        end

        Handler(self)
    end

    addon.core:RegisterEvent("ENCOUNTER_START", self.frame, self.modName)
    addon.core:RegisterEvent("ENCOUNTER_END", self.frame, self.modName)
    addon.core:RegisterEvent("SPELL_UPDATE_CHARGES", self.frame, self.modName)
    addon.core:RegisterEvent("CHALLENGE_MODE_START", self.frame, self.modName)
    addon.core:RegisterEvent("CHALLENGE_MODE_COMPLETED", self.frame, self.modName)
    addon.core:RegisterStateMonitor("instanceInfo", self.modName, function()
        -- when the player is not in an instance, just set the module to inactive
        if addon.states["instanceInfo"].difficultyID == 0 then
            self.active = false
        end

        Handler(self)
    end)

    self.frame:SetScript("OnEvent", function (_, event, ...)
        OnEvent(event, ...)
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(BattleRes.modName, function() return BattleRes:Initialize() end)