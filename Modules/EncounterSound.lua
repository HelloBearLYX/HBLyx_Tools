local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class EncounterSound
local EncounterSound = {
    modName = "EncounterSound",
}

-- MARK: Constants

-- MARK: Initialize

---Initialize (Constructor)
---@return EncounterSound EncounterSound a EncounterSound object
function EncounterSound:Initialize()
    self.privateAuras = {}
    self.role = nil

    -- 3.11 data change migration
    if not addon.db.EncounterSound.version or addon.db.EncounterSound.version < "3.11" then
        local events = {}
        events[3073] = {[99] = nil}
        local pa = {}
        pa[3073] = {[1224104] = nil}
        pa[2067] = {[1263523] = nil}

        -- remove incorrect event entry
        for encounterID, eventData in pairs(events) do
            if addon.db.EncounterSound.data and addon.db.EncounterSound.data[encounterID] then
                for eventID, _ in pairs(eventData) do
                    if addon.db.EncounterSound.data[encounterID][eventID] then
                        addon.db.EncounterSound.data[encounterID][eventID] = nil -- remove incorrect entry
                    end
                end
            end
        end
        -- remove incorrect PA entries
        for encounterID, spellData in pairs(pa) do
            if addon.db.EncounterSound.dataPA and addon.db.EncounterSound.dataPA[encounterID] then
                for spellID, _ in pairs(spellData) do
                    if addon.db.EncounterSound.dataPA[encounterID][spellID] then
                        addon.db.EncounterSound.dataPA[encounterID][spellID] = nil -- remove incorrect entry
                    end
                end
            end
        end

        -- a general data parse for new version
        for encounterID, encounterData in pairs(addon.db.EncounterSound.data or {}) do
            for eventID, eventData in pairs(encounterData) do
                for attribute, sound in pairs(eventData) do
                    if type(attribute) ~= "string" then
                        eventData[attribute] = {sound = sound}
                    end
                end
            end
        end

        addon.db.EncounterSound.version = addon.version -- update version after migration
    end

    return self
end

-- MARK: Check Role

---Check whether the role condition is satisfied
---@param self EncounterSound self
---@param eventRole table|nil the role requirement for the event, can be nil for no role requirement
---@return boolean true if the role condition is satisfied, false otherwise
local function CheckRole(self, eventRole)
    if not eventRole or not self.role then
        return true
    end

    -- eventRole is a hash set, e.g. {TANK = true, HEALER = true}
    return eventRole[self.role]
end

-- MARK: Load Event Sounds

---Load event sounds for the given encounter ID
---@param encounterID integer the encounter ID to load sounds for
local function LoadEventSounds(self, encounterID)
    if addon.db.EncounterSound.data and addon.db.EncounterSound.data[encounterID] then
        local encounterData = addon.db.EncounterSound.data[encounterID]
        for eventID, eventData in pairs(encounterData) do
            for attribute, value in pairs(eventData) do
                if type(attribute) == "string" then
                    -- Handle color
                    C_EncounterEvents.SetEventColor(eventID, CreateColorFromHexString(addon.db.EncounterSound.data[encounterID][eventID].color))
                else
                    if CheckRole(self, value.role) then -- handle role, role can be nil
                        -- Handle sound trigger
                        local sound = addon.LSM:Fetch("sound", value.sound)
                        if sound then
                            C_EncounterEvents.SetEventSound(
                                eventID,
                                attribute, -- trigger
                                {file = sound, channel = addon.db.EncounterSound.SoundChannel or "Master", volume = 1}
                            )
                        end
                    end
                end
            end
        end
        addon.Utilities:print(L["EncounterSoundSettings"] .. ": |cffffff00" .. addon.states["encounterInfo"].encounterName .. "|r")
    end
end

-- MARK: Load PA Sounds

---Load private aura sounds for the given encounter ID
---@param self EncounterSound self
---@param encounterID integer the encounter ID to load private aura sounds for
local function LoadPrivateAuraSounds(self, encounterID)
    if addon.db.EncounterSound.EnablePrivateAuras and addon.db.EncounterSound.dataPA and addon.db.EncounterSound.dataPA[encounterID] then
        local privateAuraData = addon.db.EncounterSound.dataPA[encounterID]
        for spellID, soundName in pairs(privateAuraData) do
            local sound = addon.LSM:Fetch("sound", soundName)
            if sound then
                local pa = C_UnitAuras.AddPrivateAuraAppliedSound({
                    spellID = spellID,
                    unitToken = "player",
                    soundFileName = sound,
                    outputChannel = addon.db.EncounterSound.SoundChannel or "Master",
                })
                table.insert(self.privateAuras, pa)
            end
        end
        addon.Utilities:print(L["PrivateAuraSettings"] .. ": |cffffff00" .. addon.states["encounterInfo"].encounterName .. "|r")
    end
end

-- MARK: Clear PA Sounds

---Clear private aura sounds loaded
---@param self EncounterSound self
local function ClearPrivateAuraSounds(self)
    if self.privateAuras and #self.privateAuras > 0 then
        for _, pa in ipairs(self.privateAuras) do
            C_UnitAuras.RemovePrivateAuraAppliedSound(pa)
        end
        self.privateAuras = {}
        addon.Utilities:print("End of encounter: cleared private aura sounds")
    end
end

-- MARK: RegisterEvents

---Register events
function EncounterSound:RegisterEvents()
    addon.core:RegisterStateMonitor("encounterInfo", self.modName, function ()
        local currentEncounter = addon.states["encounterInfo"].encounterID
        if not currentEncounter then -- not an encounter error
            return
        elseif currentEncounter == 0 then -- encounter ended
            -- only clear private aura sounds
            ClearPrivateAuraSounds(self)
        end

        self.role = UnitGroupRolesAssigned("player") or nil -- update current role
        LoadEventSounds(self, currentEncounter)
        LoadPrivateAuraSounds(self, currentEncounter)
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(EncounterSound.modName, function() return EncounterSound:Initialize() end)