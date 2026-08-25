local ADDON_NAME, addon = ...

---@class BattleRes
---@field frame frame BattleRes frame
---@field modName string module name for registering in core
local BattleRes = {
    modName = "BattleRes",
    frame = nil,
    active = false,
}

--MARK: Constants
local BATTLE_RES_ID = 20484
local BATTLE_RES_TEXTURE = 136080


-- private methods

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

local function CreateBRFrame()
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
    frame.charge = charge

    ApplyVisibility(BattleRes)

    return frame
end

-- MARK: Handler

---Handler for BattleRes
---@param self BattleRes self
---@param active boolean if turn the BattleRes on or off
local function Handler(self)
    local chargeInfo = C_Spell.GetSpellCharges(BATTLE_RES_ID)
    if chargeInfo then -- once the chargeInfo is available, it is active
        self.frame.charge:SetText(chargeInfo.currentCharges)
        self.frame.cooldown:SetCooldown(chargeInfo.cooldownStartTime, chargeInfo.cooldownDuration)
        if chargeInfo.currentCharges < 1 then
            self.frame.icon:SetDesaturated(true)
        else
            self.frame.icon:SetDesaturated(false)
        end
    else
        self.frame.charge:SetText("")
        self.frame.cooldown:SetCooldown(0, 0)
    end

    ApplyVisibility(self)
end

--MARK: Initialize

---Initialize(Constructor)
---@return BattleRes BattleRes a BattleRes object
function BattleRes:Initialize()
    self.active = false
    self.frame = CreateBRFrame()

    return self
end

-- public methods
-- MARK: UpdateStyle

---Update style settings and render it in-game for BattleRes
function BattleRes:UpdateStyle()
    self.frame:SetFrameStrata(addon.db[self.modName]["FrameStrata"] or "BACKGROUND")
    self.frame:SetSize(addon.db[self.modName]["IconSize"], addon.db[self.modName]["IconSize"])

    self.frame.icon:SetTexCoord(addon.db[self.modName]["IconZoom"], 1 - addon.db[self.modName]["IconZoom"], addon.db[self.modName]["IconZoom"], 1 - addon.db[self.modName]["IconZoom"])

    self.frame:SetPoint("CENTER", UIParent, "CENTER", addon.db[self.modName]["X"], addon.db[self.modName]["Y"])

    self.frame.cooldown:SetScale(addon.db[self.modName]["TimeFontScale"])

    self.frame.charge:SetFont(
        addon.LSM:Fetch("font", addon.db[self.modName]["Font"]) or "Fonts\\FRIZQT__.TTF",
        addon.db[self.modName]["ChargeFontSize"],
        "OUTLINE"
    )
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
    local function OnEvent()
        if addon.core.testMode then
            return
        end

        Handler(self)
    end

    addon.core:RegisterEvent("ENCOUNTER_START", self.frame, self.modName)
    addon.core:RegisterEvent("ENCOUNTER_END", self.frame, self.modName)
    addon.core:RegisterEvent("SPELL_UPDATE_CHARGES", self.frame, self.modName)
    addon.core:RegisterEvent("CHALLENGE_MODE_START", self.frame, self.modName)
    addon.core:RegisterEvent("CHALLENGE_MODE_COMPLETED", self.frame, self.modName)

    self.frame:SetScript("OnEvent", OnEvent)
end

-- MARK: Register Module
addon.core:RegisterModule(BattleRes.modName, function() return BattleRes:Initialize() end)