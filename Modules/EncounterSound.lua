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
    return self
end

-- MARK: RegisterEvents

---Register events
function EncounterSound:RegisterEvents()
    addon.core:RegisterStateMonitor("encounterInfo", self.modName, function ()
        local currentEncounter = addon.states["encounterInfo"].encounterID
        if not currentEncounter or currentEncounter == 0 then -- not an encounter or encounter ended
            return
        end

        if addon.db.EncounterSound.data and addon.db.EncounterSound.data[currentEncounter] then
            local encounterData = addon.db.EncounterSound.data[currentEncounter]
            for eventID, eventData in pairs(encounterData) do
                for attribute, value in pairs(eventData) do
                    if attribute == "color" then
                        -- Handle color TODO
                        local color = CreateColorFromHexString(addon.db.EncounterSound.data[currentEncounter][eventID].color)
                        C_EncounterEvents.SetEventColor(eventID, color)
                    else
                        -- Handle sound trigger
                        local trigger = attribute
                        local sound = addon.LSM:Fetch("sound", value)
                        local channel = addon.db.EncounterSound.SoundChannel or "Master"
                        if sound then
                            C_EncounterEvents.SetEventSound(eventID, trigger, {file = sound, channel = channel, volume = 1})
                        end
                    end
                end
            end
            addon.Utilities:print("Encounter Sound: Applied sound/color for |cffffff00" .. addon.states["encounterInfo"].encounterName .. "|r")
        end
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(EncounterSound.modName, function() return EncounterSound:Initialize() end)