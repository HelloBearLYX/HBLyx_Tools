local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class BattleRes
---@field frame frame BattleRes frame
---@field modName string module name for registering in core
local BattleRes = {
    modName = "BattleRes",
    frame = nil,
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
        addon.LSM:Fetch("font", self.db["Font"]) or addon.DEFAULTS.font,
        self.db["ChargeFontSize"],
        "OUTLINE"
    )
    frame.charge = charge

    return frame
end

-- MARK: Handler

local function Reset(self)
    self.frame.charge:SetText("")
    self.frame.cooldown:Clear()
end

---Handler for BattleRes
---@param self BattleRes self
local function Handler(self)
    local chargeCount = C_Spell.GetSpellDisplayCount(BATTLE_RES_ID)
    if chargeCount and chargeCount ~= "" then
        self.frame.charge:SetText(chargeCount or "")

        self.frame.icon:SetDesaturated(false)
        if not issecretvalue(chargeCount) then
            local chargeNumber = tonumber(chargeCount)
            if chargeNumber and chargeNumber < 1 then
                self.frame.icon:SetDesaturated(true)
            end
        end

        local durationObj = C_Spell.GetSpellChargeDuration(BATTLE_RES_ID)
        self.frame.cooldown:SetCooldownDuration((durationObj and durationObj:GetRemainingDuration()) or 0)

        self.frame:Show()
    else
        Reset(self)
        if addon.db[self.modName]["HideInactive"] then
            self.frame:Hide()
        else
            self.frame:Show()
        end
    end
end

--MARK: Initialize

---Initialize(Constructor)
---@return BattleRes BattleRes a BattleRes object
function BattleRes:Initialize()
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
        addon.LSM:Fetch("font", self.db["Font"]) or addon.DEFAULTS.font,
        self.db["ChargeFontSize"],
        "OUTLINE"
    )

    Handler(self)
end

-- MARK: Test

---Test mode of BattleRes
---@param Test boolean turn the Test mod on or off
function BattleRes:Test(Test)
    if Test then
        -- make a demo for testMode
        self.frame.charge:SetText("5")
        self.frame.cooldown:SetCooldownDuration(90)
        self.frame:Show()
        addon.Utilities:ShowEditFrame(self.frame, addon.db[self.modName], "X", "Y", nil, nil, L["BattleResSettings"])
    else
        Reset(self)
        addon.Utilities:HideEditFrame(self.frame)
        Handler(self)
    end
end

--MARK: Register Event

---Register events needed
function BattleRes:RegisterEvents()
    local function OnEvent(event, ...)
        if addon.core.testMode then
            return
        end

        if event == "CHALLENGE_MODE_RESET" then
            C_Timer.After(10, function() Handler(self) end)
        else
            Handler(self)
        end
    end

    addon.core:RegisterEvent("ENCOUNTER_START", self.frame, self.modName)
    addon.core:RegisterEvent("ENCOUNTER_END", self.frame, self.modName)
    addon.core:RegisterEvent("SPELL_UPDATE_CHARGES", self.frame, self.modName)
    addon.core:RegisterEvent("CHALLENGE_MODE_RESET", self.frame, self.modName)
    addon.core:RegisterEvent("CHALLENGE_MODE_COMPLETED", self.frame, self.modName)
    addon.core:RegisterStateMonitor("instanceInfo", self.modName, function()
        Handler(self)
    end)

    self.frame:SetScript("OnEvent", function (_, event, ...)
        OnEvent(event, ...)
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(BattleRes.modName, function() return BattleRes:Initialize() end)