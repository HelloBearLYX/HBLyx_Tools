local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class BloodlustHelper
local BloodlustHelper = {
    modName = "BloodlustHelper",
    registered = {},
    container = nil,
    frame = nil,
    db = nil,
    lastExhaustionExpiration = 0, -- dedupes repeat UNIT_AURA fires for the same Sated application
    scheduledLockoutExpiration = 0, -- dedupes the expiration timer so only the newest lockout schedules one
}

-- MARK: Constants
local LUST_TEXTURE = 136012
local EXHAUSTION_TEXTURE = 136090
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
}
local AURA_FRAME_SIZE = 35
local EXHAUSTION_DURATION = 600 -- canonical lockout duration applied by any Lust-type effect
local EXHAUSTION_FRESH_WINDOW = 5 -- seconds of tolerance used to treat a lockout as "just applied"

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
    frame.background:SetDesaturated(true) -- the background is always desaturated, since the buff container is above it

    frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.cooldown:SetAllPoints()
    frame.cooldown:SetDrawEdge(false)
    frame.cooldown:SetReverse(true)
    frame.cooldown:SetCountdownAbbrevThreshold(600)
    frame.cooldown:SetScale(0.75)

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

-- MARK: Sated Detection

---Check the player for a freshly-applied Exhaustion/Sated-family debuff.
---Mirrors ExTools.YYSound: event-driven, no pcall (the lockout debuff is
---trusted to be readable even when the Lust buff itself is hidden), and a
---lockout counts as "fresh" when it still has close to its full 600s left.
---@return boolean fresh true if a fresh lockout application was found
---@return number|nil expirationTime the aura's expirationTime, used to dedupe repeat events
---@return number|nil duration the aura's own duration, used to size the cooldown
local function CheckExhaustionFresh()
    local now = GetTime()
    for _, spellId in ipairs(EXHAUSTION_SPELL_ID) do
        local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellId)
        if aura and aura.expirationTime and aura.expirationTime - now >= EXHAUSTION_DURATION - EXHAUSTION_FRESH_WINDOW then
            return true, aura.expirationTime, aura.duration
        end
    end
    return false, nil, nil
end

---Find any Exhaustion/Sated-family debuff currently on the player, fresh or
---not. Used on login/zoning to re-sync self.frame's cooldown with a lockout
---that was already running before the addon loaded.
---@return table|nil aura the first readable exhaustion aura found on the player
local function FindExhaustionAura()
    for _, spellId in ipairs(EXHAUSTION_SPELL_ID) do
        local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellId)
        if aura and aura.expirationTime and aura.duration then
            return aura
        end
    end
    return nil
end

---Start/refresh the self.frame cooldown sweep for the given lockout window,
---and schedule a direct visibility recheck at the exact moment it ends. The
---natural debuff removal also fires UNIT_AURA (which recomputes visibility
---too), so this timer is a belt-and-suspenders backup for that event.
---The aura container handles showing the Lust buff itself; this only drives
---the basic frame's background cooldown.
---@param self BloodlustHelper
---@param expirationTime number the lockout aura's expirationTime (GetTime()-based)
---@param duration number the lockout aura's own duration in seconds
local function StartLockoutCooldown(self, expirationTime, duration)
    local startTime = expirationTime - duration
    self.frame.cooldown:SetCooldown(startTime, duration)

    self.scheduledLockoutExpiration = expirationTime
    C_Timer.After(math.max(0, expirationTime - GetTime()), function()
        if self.scheduledLockoutExpiration ~= expirationTime then
            return -- superseded by a newer lockout application, let that one own the recheck
        end
        self:UpdateVisibility()
    end)
end

---Event-driven Sated/Exhaustion check, fired from UNIT_AURA after a short
---delay so the new aura value has settled (same timing used by ExTools.YYSound).
---@param self BloodlustHelper
local function CheckSatedTrigger(self)
    if not self.db["Enabled"] then
        return
    end

    local fresh, expirationTime, duration = CheckExhaustionFresh()
    if fresh and expirationTime ~= self.lastExhaustionExpiration then
        self.lastExhaustionExpiration = expirationTime
        StartLockoutCooldown(self, expirationTime, duration or EXHAUSTION_DURATION)
    end
end

-- MARK: LustAuraContainer
local function CreateLustAuraContainer(self, parent)
    -- includeSpellIDs is expected as a map: [spellID] = true
    local includeLustSpellIDs = {}
    for _, spellId in ipairs(LUST_SPELL_ID) do
        includeLustSpellIDs[spellId] = true
    end

    -- 12.1 new aura system aura container
    local container = CreateFrame("AuraContainer", nil, parent, "CustomAuraContainerTemplate")
    container:SetUnit("player")
    container:SetAllPoints(parent)

    container:AddAuraGroup("lustGroup", "HELPFUL", {
        maxFrameCount = 1,
        candidateFilters = { includeSpellIDs = includeLustSpellIDs },
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

---Check whether the player currently has any Lust-type buff aura. This is a
---cosmetic signal only, used to decide self.frame's visibility; self.container
---(AuraContainer) always renders/owns the actual buff presentation on its own.
---@return boolean active true if any Lust buff is currently present
local function IsLustBuffActive()
    for _, spellId in ipairs(LUST_SPELL_ID) do
        if C_UnitAuras.GetPlayerAuraBySpellID(spellId) then
            return true
        end
    end
    return false
end

---Check whether self.frame's cooldown sweep (started from a fresh Sated/
---Exhaustion application) is still counting down.
---@param self BloodlustHelper
---@return boolean active true if the cooldown sweep is still running
local function IsLockoutCooldownActive(self)
    local startMs, durationMs = self.frame.cooldown:GetCooldownTimes()
    if not startMs or not durationMs or durationMs <= 0 then
        return false
    end
    return (startMs + durationMs) / 1000 - GetTime() > 0
end

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
    self.container = CreateLustAuraContainer(self, self.frame)
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

    self.container:SetAuraGroupLayout("lustGroup", {
        elementSpacing = 0,
        lineSpacing = 0,
        groupSpacing = 0,
        groupLineSpacing = 0,
        forceNewLine = false,
        elementWidth = self.db["AuraFrameSize"] or AURA_FRAME_SIZE,
        elementHeight = self.db["AuraFrameSize"] or AURA_FRAME_SIZE,
    })
end

---Recompute and apply self.frame's visibility and background desaturation.
---The module is "inactive" only when both the Lust buff and the Sated/
---Exhaustion cooldown sweep are absent; in that case self.frame is hidden if
---the user opted into HideInactive. The background shows LUST_TEXTURE
---desaturated (grey) by default, and switches to EXHAUSTION_TEXTURE in color
---while the Sated cooldown is counting down on self.frame.
function BloodlustHelper:UpdateVisibility()
    local cooldownActive = IsLockoutCooldownActive(self)
    local active = IsLustBuffActive() or cooldownActive

    self.frame.background:SetTexture(cooldownActive and EXHAUSTION_TEXTURE or LUST_TEXTURE)
    self.frame.background:SetDesaturated(not cooldownActive)

    if active or not self.db["HideInactive"] then
        MakeInvisible(self, false)
    else
        MakeInvisible(self, true)
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
        -- make the frame visible for test mode
        MakeInvisible(self, false)
        addon.Utilities:ShowEditFrame(self.frame, addon.db[self.modName], "X", "Y", nil, L["BloodlustHelperSettings"], self.modName)
    else
        addon.Utilities:HideEditFrame(self.frame)
        self:UpdateVisibility()
    end
end

-- MARK: RegisterEvents

---Register events used to detect a fresh Sated/Exhaustion application and
---drive the self.frame cooldown sweep. The Lust buff itself is left entirely
---to self.container (AuraContainer); this only manages the background frame.
function BloodlustHelper:RegisterEvents()
    addon.core:RegisterEvent("UNIT_AURA", self.frame, self.modName, "player")
    addon.core:RegisterEvent("PLAYER_ENTERING_WORLD", self.frame, self.modName)

    self.frame:SetScript("OnEvent", function(_, event, unit)
        if event == "UNIT_AURA" then
            if unit == "player" then
                C_Timer.After(0.05, function()
                    CheckSatedTrigger(self)
                    self:UpdateVisibility() -- the Lust buff or the Sated debuff may have just appeared/fallen off
                end)
            end
        elseif event == "PLAYER_ENTERING_WORLD" then
            -- re-sync with any lockout that was already running before login/zoning
            local aura = FindExhaustionAura()
            if aura then
                self.lastExhaustionExpiration = aura.expirationTime
                StartLockoutCooldown(self, aura.expirationTime, aura.duration)
            else
                self.lastExhaustionExpiration = 0
                self.scheduledLockoutExpiration = 0 -- invalidate any pending timer from a previous zone/session
                self.frame.cooldown:Clear()
            end
            self:UpdateVisibility()
        end
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(BloodlustHelper.modName, L["BloodlustHelperSettings"], function() return BloodlustHelper:Initialize() end)
