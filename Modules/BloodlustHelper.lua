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

-- MARK: Initialize

---Initialize (Constructor)
---@return BloodlustHelper BloodlustHelper a BloodlustHelper object
function BloodlustHelper:Initialize()
    return self
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

-- MARK: UpdateStyle

---Update style settings and render them in-game for CustomTracker
function BloodlustHelper:UpdateStyle()
    ApplyLustSound(self)
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function BloodlustHelper:Test(on)
    if not addon.db[self.modName]["Enabled"] then -- if the module is not enabled, do not allow test mode
        return
    end

    if on then
        -- TODO: Implement test mode for your module
    else
        -- TODO: Disable test mode for your module
    end
end

-- MARK: RegisterEvents

---Register events
function BloodlustHelper:RegisterEvents()
    -- TODO: Register events needed by your module here, for example:
    -- local handle = function() Handler(self) end
    -- addon.core:RegisterEvent("EVENT_NAME", handle)
end

-- MARK: Register Module
addon.core:RegisterModule(BloodlustHelper.modName, function() return BloodlustHelper:Initialize() end)
