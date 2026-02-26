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

    return self
end

-- MARK: Load Event Sounds

local function LoadEventSounds(self, encounterID)
    if addon.db.EncounterSound.data and addon.db.EncounterSound.data[encounterID] then
        local encounterData = addon.db.EncounterSound.data[encounterID]
        for eventID, eventData in pairs(encounterData) do
            for attribute, value in pairs(eventData) do
                if attribute == "color" then
                    -- Handle color
                    C_EncounterEvents.SetEventColor(eventID, CreateColorFromHexString(addon.db.EncounterSound.data[encounterID][eventID].color))
                else
                    -- Handle sound trigger
                    local sound = addon.LSM:Fetch("sound", value)
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
        addon.Utilities:print(L["EncounterSoundSettings"] .. ": |cffffff00" .. addon.states["encounterInfo"].encounterName .. "|r")
    end
end

-- MARK: Load PA Sounds
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

        LoadEventSounds(self, currentEncounter)
        LoadPrivateAuraSounds(self, currentEncounter)
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(EncounterSound.modName, function() return EncounterSound:Initialize() end)