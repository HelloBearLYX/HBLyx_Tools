local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class BloodlustHelper
local BloodlustHelper = {
    modName = "BloodlustHelper",
    resigered = {},
}

-- MARK: Constants
local LUST_SPELL_ID = {
    2825, -- Bloodlust
    32182, -- Heroism
    80353, -- Time Warp
    264689, -- Primal Rage
    390386, -- Fury of the Aspects
}
local EXHAUSTION_SPELL_ID = {
    57723, -- Exhaustion
    57724, -- Sated
    80354, -- Temporal Displacement
    264689, -- Fatigue
}
local AURA_FRAME_SIZE = 35

-- MARK: Initialize

---Initialize (Constructor)
---@return BloodlustHelper BloodlustHelper a BloodlustHelper object
function BloodlustHelper:Initialize()
    return self
end

local function InitializeAuraButtonFrame(frame)
    frame:SetSize(AURA_FRAME_SIZE, AURA_FRAME_SIZE)

    if not frame.texture then
        local icon = frame:CreateTexture(nil, "BACKGROUND")
        icon:SetAllPoints()
        icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        frame.texture = icon
        frame:SetIcon(icon)
    end

    if not frame.cooldown then
        local cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
        cooldown:SetAllPoints()
        cooldown:SetDrawEdge(false)
        cooldown:SetReverse(true)
        cooldown:SetScale(0.75)
        frame.cooldown = cooldown
        frame:SetDurationCooldown(cooldown)
    end

    if not frame.border then
        local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        border:SetAllPoints()
        border:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        border:SetBackdropBorderColor(0, 0, 0, 1)
        frame.border = border
    end
end

-- MARK: ApplyLustSound
local function ApplyLustSound(self)
    if InCombatLockdown() then
        return
    end

    local lustSound = addon.LSM:Fetch("sound", addon.db.BloodlustHelper["LustSound"])
    local exhaustionSound = addon.LSM:Fetch("sound", addon.db.BloodlustHelper["ExhaustionSound"])
    local channel = addon.db.BloodlustHelper["SoundChannel"] or "Master"
    if lustSound  then
        for _, spellId in ipairs(LUST_SPELL_ID) do
            local aura = C_UnitAuras.AddAuraAppliedSound({
                spellID = spellId,
                unitToken = "player",
                soundFileName = lustSound,
                outputChannel = channel,
            })
            table.insert(self.resigered, aura)
        end
    end
    if exhaustionSound then
        for _, spellId in ipairs(EXHAUSTION_SPELL_ID) do
            local aura = C_UnitAuras.AddAuraAppliedSound({
                spellID = spellId,
                unitToken = "player",
                soundFileName = exhaustionSound,
                outputChannel = channel,
            })
            table.insert(self.resigered, aura)
        end
    end
end

-- MARK: ClearLustSound
local function ClearLustSound(self)
    for _, aura in ipairs(self.resigered) do
        C_UnitAuras.RemoveAuraAppliedSound(aura)
    end
    self.resigered = {}
end

-- MARK: LustAuraContainer
local function CreateLustAuraContainer()
    -- includeSpellIDs is expected as a map: [spellID] = true
    local includeLustSpellIDs = {}
    for _, spellId in ipairs(LUST_SPELL_ID) do
        includeLustSpellIDs[spellId] = true
    end

    -- test only
    -- includeLustSpellIDs[385787] = true -- used for testing

    -- 12.1 new aura system aura container
    local container = CreateFrame("AuraContainer", nil, UIParent, "CustomAuraContainerTemplate")
    container:SetUnit("player")
    container:SetAuraLayoutAnchorPoint("RIGHT")
    container:SetAuraLayoutPadding(0, 0, 0, 0)
    
    local horizontalDirection, verticalDirection = container:GetAuraLayoutGrowthDirection()
    addon:debug("Horizontal: " .. tostring(horizontalDirection) .. ", Vertical: " .. tostring(verticalDirection))

    container:AddAuraGroup("lustGroup", "HELPFUL", {
        maxFrameCount = 1,
        candidateFilters = { includeSpellIDs = includeLustSpellIDs },
        initializeFrame = function(frame)
            InitializeAuraButtonFrame(frame)
        end,
        layout = {
            elementSpacingX = 0,
            elementSpacingY = 0,
            gapX = 0,
            gapY = 0,
            forceNewRow = false,
            elementWidth = AURA_FRAME_SIZE,
            elementHeight = AURA_FRAME_SIZE,
        },
    })

    container:Show()
    container:UpdateAllAuras()

    return container
end

-- MARK: UpdateStyle

---Update style settings and render them in-game for CustomTracker
function BloodlustHelper:UpdateStyle()
    ApplyLustSound(self)

    if addon.db.BloodlustHelper["EnableAuraContainer"] and not self.lustAuraContainer then
        self.lustAuraContainer = CreateLustAuraContainer()
    end
    if self.lustAuraContainer then
        self.lustAuraContainer:ClearAllPoints()
        self.lustAuraContainer:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        self.lustAuraContainer:SetEnabled(addon.db.BloodlustHelper["EnableAuraContainer"])

        if addon.db.BloodlustHelper["EnableAuraContainer"] then
            self.lustAuraContainer:Show()
            self.lustAuraContainer:UpdateAllAuras()
        else
            self.lustAuraContainer:Hide()
        end
    end
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function BloodlustHelper:Test(on)
    if not addon.db[self.modName]["Enabled"] then -- if the module is not enabled, do not allow test mode
        return
    end

    if on then
    else
    end
end

-- MARK: RegisterEvents

---Register events
function BloodlustHelper:RegisterEvents()
end

-- MARK: Register Module
addon.core:RegisterModule(BloodlustHelper.modName, function() return BloodlustHelper:Initialize() end)
