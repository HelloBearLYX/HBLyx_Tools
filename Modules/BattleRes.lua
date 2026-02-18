---@class BattleRes
---@field frame frame BattleRes frame
local BattleRes = {
    frame = nil,
    modName = "BattleRes",
}

local ADDON_NAME, addon = ...

--MARK: Constants
local BATTLE_RES_ID = 20484
local BATTLE_RES_TEXTURE = 136080

--MARK: Initialize

---Initialize(Constructor)
---@return BattleRes BattleRes a BattleRes object
function BattleRes:Initialize()
    self.frame = CreateFrame("Frame", ADDON_NAME .. "_BattleRes", UIParent)
    self.frame:SetFrameStrata("BACKGROUND")
    
    self.frame.cooldown = CreateFrame("Cooldown", nil, self.frame, "CooldownFrameTemplate")
    self.frame.cooldown:SetAllPoints()
    self.frame.cooldown:SetDrawEdge(false)
    self.frame.cooldown:SetCountdownAbbrevThreshold(600)

    -- icon
    self.frame.icon = self.frame:CreateTexture(nil, "ARTWORK")
    self.frame.icon:SetAllPoints()
    self.frame.icon:SetTexture(BATTLE_RES_TEXTURE)

    -- text
    self.frame.textFrame = CreateFrame("Frame", nil, self.frame)
    self.frame.textFrame:SetAllPoints()

    self.frame.charge = self.frame.textFrame:CreateFontString(nil, "OVERLAY")
    self.frame.charge:SetPoint("CENTER", self.frame, "BOTTOM", 0, 0)
    self.frame.charge:SetTextColor(1, 1, 1, 1)

    -- borders
    self.frame.border = CreateFrame("Frame", nil, self.frame, "BackdropTemplate")
    self.frame.border:SetAllPoints()
    self.frame.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    self.frame.border:SetBackdropBorderColor(0, 0, 0, 1)

    self:UpdateStyle()

    if addon.db[self.modName]["HideInactive"] then
        self.frame:Hide()
    else
        self.frame:Show()
    end

    return self
end

-- private methods
-- MARK: Handler

---Handler for BattleRes
---@param self BattleRes self
---@param active boolean if turn the BattleRes on or off
local function Handler(self)
    local chargeInfo = C_Spell.GetSpellCharges(BATTLE_RES_ID)
    if chargeInfo then
        self.frame.charge:SetText(chargeInfo.currentCharges)
        self.frame.cooldown:SetCooldown(chargeInfo.cooldownStartTime, chargeInfo.cooldownDuration)
        if chargeInfo.currentCharges == 0 then
            self.frame.icon:SetDesaturated(true)
        else
            self.frame.icon:SetDesaturated(false)
        end

        self.frame:Show()
    else
        self.frame.charge:SetText("")
        self.frame.cooldown:SetCooldown(0, 0)
        if addon.db[self.modName]["HideInactive"] then
            self.frame:Hide()
        end
    end
end

-- public methods
-- MARK: UpdateStyle

---Update style settings and render it in-game for BattleRes
function BattleRes:UpdateStyle()
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
        -- make a demo
        self.frame.charge:SetText("5")
        self.frame.cooldown:SetCooldown(GetTime(), 90)
        self.frame.icon:SetDesaturated(false)
        self.frame:Show()

        addon.Utilities:MakeFrameDragPosition(self.frame, self.modName, "X", "Y")
    else
        -- reset all data
        self.frame.charge:SetText("")
        self.frame.cooldown:SetCooldown(0, 0)
        self.frame.icon:SetDesaturated(false)
        
        if addon.db[self.modName]["HideInactive"] then
            self.frame:Hide()
        end
    end
end

--MARK: Register Event

---Register events needed by CombatTimer
function BattleRes:RegisterEvents()
    local Handle = function () Handler(self) end

    addon.core:RegisterEvent("PLAYER_ENTERING_WORLD", self.modName, nil, Handle)
    addon.core:RegisterEvent("ENCOUNTER_START", self.modName, nil, Handle)
    addon.core:RegisterEvent("ENCOUNTER_END", self.modName, nil, Handle)
    addon.core:RegisterEvent("SPELL_UPDATE_CHARGES", self.modName, nil, Handle)
    addon.core:RegisterEvent("CHALLENGE_MODE_START", self.modName, nil, Handle)
    addon.core:RegisterEvent("CHALLENGE_MODE_COMPLETED", self.modName, nil, Handle)
end

-- MARK: Register Module
addon.core:RegisterModule(BattleRes.modName, function() return BattleRes:Initialize() end, function() BattleRes:RegisterEvents() end)