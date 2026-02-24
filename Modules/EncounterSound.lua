local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class EncounterSound
local EncounterSound = {
    modName = "EncounterSound",
}

-- MARK: Constants
-- 02/24/2026: 8 dungeons, 29 encounters, 131 events
local ENCOUNTER_EVENTS = {
   [2562] = {274, 275, 276, 277},
   [2563] = {282, 283, 284, 285},
   [2564] = {278, 279, 280, 397},
   [2565] = {293, 294, 295, 296},
   [2065] = {223, 224, 225, 226, 238},
   [2066] = {234, 235, 236, 237, 243},
   [2067] = {246, 247, 376, 245},
   [2068] = {248, 249, 250, 251, 252, 253, 254},
   [3328] = {106, 107, 108, 172},
   [3332] = {33, 34, 35, 36, 313},
   [3333] = {109, 110, 111, 112},
   [3212] = {150, 151, 152, 153, 154, 155},
   [3213] = {16, 17, 18, 19, 20},
   [3214] = {156, 157, 158},
   [1698] = {298, 299, 300, 301},
   [1699] = {302, 303, 304},
   [1700] = {305, 306, 308, 603},
   [1701] = {309, 310, 311, 312},
   [3056] = {239, 241, 242},
   [3057] = {25, 26, 27, 28, 29},
   [3058] = {210, 211, 213, 212, 214, 215, 216},
   [3059] = {21, 22, 23, 24, 538},
   [3071] = {281, 286, 287, 288},
   [3072] = {93, 94, 95, 513, 96},
   [3073] = {635, 97, 98, 99, 100},
   [3074] = {290, 292, 420},
   [2001] = {203, 204, 205, 206, 561},
   [1999] = {144, 145, 146, 147},
   [2000] = {164, 165, 166, 167, 168, 375},
}

-- MARK: Initialize

---Initialize (Constructor)
---@return EncounterSound EncounterSound a EncounterSound object
function EncounterSound:Initialize()
    -- TODO: Initialize your module here

    return self
end

-- MARK: UpdateStyle

---Update style settings and render them in-game for CustomTracker
function EncounterSound:UpdateStyle()
    -- TODO: Update style settings and render them in-game when the user changes custom options
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function EncounterSound:Test(on)
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
function EncounterSound:RegisterEvents()
    -- TODO: Register events needed by your module here, for example:
    -- local handle = function() Handler(self) end
    -- addon.core:RegisterEvent("EVENT_NAME", handle)
end

-- MARK: Register Module
addon.core:RegisterModule(EncounterSound.modName, function() return EncounterSound:Initialize() end)
