local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class BloodlustHelper
local BloodlustHelper = {
    modName = "BloodlustHelper",
    registered = {},
    container = nil, -- the Lust buff AuraContainer
    satedContainer = nil, -- the Sated/Exhaustion debuff AuraContainer, same appearance as container
    frame = nil,
    db = nil,
}

-- MARK: Constants
local LUST_TEXTURE = 136012
local LUST_SPELL_ID = {
    2825, -- Bloodlust
    32182, -- Heroism
    80353, -- Time Warp
    264689, -- Primal Rage
    390386, -- Fury of the Aspects
    466904, -- Marksman Hunter's
    1243972, -- Drums
}
local EXHAUSTION_SPELL_ID = {
    57723, -- Exhaustion
    57724, -- Sated
    80354, -- Temporal Displacement
    264689, -- Fatigue
    390435, -- Sated(Evoker)
}
local AURA_FRAME_SIZE = 35

local function CreateBasicFrame(self)
    -- create a basic frame with backdrop and border, used as the background for the aura button frame
    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    frame:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    frame:SetBackdropBorderColor(0, 0, 0, 1)
    frame:SetSize(self.db["AuraFrameSize"] or AURA_FRAME_SIZE, self.db["AuraFrameSize"] or AURA_FRAME_SIZE)
    frame:SetPoint("CENTER", UIParent, "CENTER", self.db["X"] or 0, self.db["Y"] or 0)

    frame.background = frame:CreateTexture(nil, "BACKGROUND")
    frame.background:SetAllPoints()
    frame.background:SetTexture(LUST_TEXTURE) -- default texture for lust
    frame.background:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    return frame
end

local function InitializeAuraButtonFrame(self, frame)
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
    if addon.states["inCombat"] then
        return
    end

    local lustSound = addon.LSM:Fetch("sound", addon.db.BloodlustHelper["LustSound"])
    local exhaustionSound = addon.LSM:Fetch("sound", addon.db.BloodlustHelper["ExhaustionSound"])
    local channel = addon.db.BloodlustHelper["SoundChannel"] or "Master"
    if lustSound then
        for _, spellId in ipairs(LUST_SPELL_ID) do
            local soundInfo = {
                spellID = spellId,
                unitToken = "player",
                soundFileName = lustSound,
                outputChannel = channel,
            }
            local aura = C_UnitAuras.AddAuraSound(0, soundInfo)
            table.insert(self.registered, aura)
        end
    end
    if exhaustionSound then
        for _, spellId in ipairs(EXHAUSTION_SPELL_ID) do
            local soundInfo = {
                spellID = spellId,
                unitToken = "player",
                soundFileName = exhaustionSound,
                outputChannel = channel,
            }
            local aura = C_UnitAuras.AddAuraSound(2, soundInfo)
            table.insert(self.registered, aura)
        end
    end
end

-- MARK: ClearLustSound
local function ClearLustSound(self)
    for _, aura in ipairs(self.registered) do
        C_UnitAuras.RemoveAuraSound(aura)
    end
    self.registered = {}
end

-- MARK: AuraContainers

---Create one AuraContainer tracking a single aura group filtered to the
---given spellIDs. Used for both the Lust buff container and the Sated/
---Exhaustion debuff container, which share the exact same appearance
---(icon/cooldown/border) and only differ in their group filter/spell list.
---@param self BloodlustHelper
---@param parent Frame the basic frame the container is anchored to
---@param groupName string a unique AddAuraGroup name for this container
---@param filterString string "HELPFUL" for buffs, "HARMFUL" for debuffs
---@param spellIDs table array of spell IDs the container should track
---@return table container the created AuraContainer frame
local function CreateTrackedAuraContainer(self, parent, groupName, filterString, spellIDs)
    -- includeSpellIDs is expected as a map: [spellID] = true
    local includeSpellIDs = {}
    for _, spellId in ipairs(spellIDs) do
        includeSpellIDs[spellId] = true
    end

    -- 12.1 new aura system aura container
    local container = CreateFrame("AuraContainer", nil, parent, "CustomAuraContainerTemplate")
    container:SetUnit("player")
    container:SetAllPoints(parent)

    container:AddAuraGroup(groupName, filterString, {
        maxFrameCount = 1,
        candidateFilters = { includeSpellIDs = includeSpellIDs },
        initializeFrame = function(frame)
            InitializeAuraButtonFrame(self, frame)
        end,
        layout = {
            elementSpacing = 0,
            lineSpacing = 0,
            groupSpacing = 0,
            groupLineSpacing = 0,
            forceNewLine = false,
            elementWidth = self.db["AuraFrameSize"] or AURA_FRAME_SIZE,
            elementHeight = self.db["AuraFrameSize"] or AURA_FRAME_SIZE,
        },
    })

    container:Show()

    return container
end

-- MARK: Visibility

local function MakeInvisible(self, invisible)
    if invisible then
        self.frame:SetBackdropBorderColor(0, 0, 0, 0) -- make the border invisible when hiding inactive
        self.frame.background:SetAlpha(0) -- make the background invisible when hiding inactive
    else
        self.frame:SetBackdropBorderColor(0, 0, 0, 1) -- restore the border visibility
        self.frame.background:SetAlpha(1) -- restore the background visibility
    end
end

-- MARK: Initialize

---Initialize (Constructor)
---@return BloodlustHelper BloodlustHelper a BloodlustHelper object
function BloodlustHelper:Initialize()
    self.db = addon.db[self.modName]
    self.frame = CreateBasicFrame(self)
    self.satedContainer = CreateTrackedAuraContainer(self, self.frame, "satedGroup", "HARMFUL", EXHAUSTION_SPELL_ID)
    self.container = CreateTrackedAuraContainer(self, self.frame, "lustGroup", "HELPFUL", LUST_SPELL_ID)

    -- the buff container must render above the debuff container so the Lust
    -- icon is the one visible during the brief overlap when both are up
    self.container:SetFrameLevel(self.satedContainer:GetFrameLevel() + 1)

    self.frame:Show()
    self:UpdateVisibility()

    return self
end

-- MARK: UpdateStyle

---Update style settings and render them in-game for CustomTracker
function BloodlustHelper:UpdateStyle()
    if select(4, GetBuildInfo()) < 120100 then
        return
    end

    ClearLustSound(self)
    ApplyLustSound(self)

    self.frame:SetSize(self.db["AuraFrameSize"] or AURA_FRAME_SIZE, self.db["AuraFrameSize"] or AURA_FRAME_SIZE)
    self.frame:SetPoint("CENTER", UIParent, "CENTER", self.db["X"] or 0, self.db["Y"] or 0)

    local groupLayout = {
        elementSpacing = 0,
        lineSpacing = 0,
        groupSpacing = 0,
        groupLineSpacing = 0,
        forceNewLine = false,
        elementWidth = self.db["AuraFrameSize"] or AURA_FRAME_SIZE,
        elementHeight = self.db["AuraFrameSize"] or AURA_FRAME_SIZE,
    }
    -- both containers share the exact same appearance, so update them together
    self.container:SetAuraGroupLayout("lustGroup", groupLayout)
    self.satedContainer:SetAuraGroupLayout("satedGroup", groupLayout)
end

---Apply self.frame.background's visibility
function BloodlustHelper:UpdateVisibility()
    MakeInvisible(self, self.db["HideInactive"])
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function BloodlustHelper:Test(on)
    if on then
        -- make the frame visible for test mode
        MakeInvisible(self, false)
        addon.Utilities:ShowEditFrame(self.frame, addon.db[self.modName], "X", "Y", nil, L["BloodlustHelperSettings"], self.modName)
    else
        addon.Utilities:HideEditFrame(self.frame)
        self:UpdateVisibility()
    end
end

-- MARK: Register Module
addon.core:RegisterModule(BloodlustHelper.modName, L["BloodlustHelperSettings"], function() return BloodlustHelper:Initialize() end)
