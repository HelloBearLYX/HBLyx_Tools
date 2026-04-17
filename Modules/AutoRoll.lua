local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class AutoRoll
local AutoRoll = {
    modName = "AutoRoll",
    eventFrame = nil
}

-- MARK: Constants
local ROLL_TYPE = {
    PASS = 0,
    NEED = 1,
    GREED = 2,
    TRANSMOG = 4,
}

-- MARK: Initialize

---Initialize (Constructor)
---@return AutoRoll AutoRoll an AutoRoll object
function AutoRoll:Initialize()
    self.eventFrame = CreateFrame("Frame", ADDON_NAME .. "_" .. self.modName, UIParent)

    return self
end

-- MARK: Get Roll Type

local function NonGearHelper(self, lootStates, itemType)
    local alwaysNeed = addon.db[self.modName]["AlwaysNeed_" .. itemType] or false
    local secondaryChoice = ROLL_TYPE[addon.db[self.modName]["SecondaryChoice_" .. itemType] or "GREED"]
    if lootStates.canNeed and alwaysNeed then
        return ROLL_TYPE.NEED
    elseif lootStates.canGreed then
        return secondaryChoice
    else
        return ROLL_TYPE.PASS
    end
end

local function GetRollType(self, itemType, lootStates)
    if itemType == "Gear" then
        local secondaryChoice = ROLL_TYPE[addon.db[self.modName]["SecondaryChoice_" .. itemType] or "GREED"]
        if lootStates.canNeed and addon.db[self.modName]["AlwaysNeed_" .. itemType] then
            return ROLL_TYPE.NEED
        elseif lootStates.canGreed and secondaryChoice == ROLL_TYPE.GREED then
            return ROLL_TYPE.GREED
        elseif lootStates.canTransmog and secondaryChoice == ROLL_TYPE.TRANSMOG then
            return ROLL_TYPE.TRANSMOG
        else
            return ROLL_TYPE.PASS
        end
    else -- for non-gear items, only roll greed or pass
        return NonGearHelper(self, lootStates, itemType)
    end
end

-- MARK: Roll

local function Roll(self, rollID, itemLink, lootStates)
    local itemID, _, _, _, _, classID, subClassID = C_Item.GetItemInfoInstant(itemLink)

    -- only process the item with valid itemID
    if itemID then
        local choice = nil
        if classID == Enum.ItemClass.Recipe then -- recipe
            choice = GetRollType(self, "Recipe", lootStates)
        elseif classID == Enum.ItemClass.Housing then -- housing
            choice = GetRollType(self, "Housing", lootStates)
        elseif classID == Enum.ItemClass.Miscellaneous and subClassID == Enum.ItemMiscellaneousSubclass.Mount then -- mount
            choice = GetRollType(self, "Mount", lootStates)
        elseif C_ToyBox.IsToy(itemID) then -- toy
            choice = GetRollType(self, "Toy", lootStates)
        elseif classID == Enum.ItemClass.Weapon or classID == Enum.ItemClass.Armor then -- gear
            choice = GetRollType(self, "Gear", lootStates)
        else
            return -- for other types of items, do not roll automatically
        end

        -- only roll if have a valid choice and can actually roll that choice
        if choice then
            RollOnLoot(rollID, choice)
            addon.Utilities:print(string.format(L["AutoRollMessage"], L["RollType"][choice], itemLink))
        end
    end
end

-- MARK: RegisterEvents

---Register events
function AutoRoll:RegisterEvents()
    addon.core:RegisterEvent("START_LOOT_ROLL", self.eventFrame, self.modName)

    self.eventFrame:SetScript("OnEvent", function(_, _, ...)
        local rollID = ...
        local itemLink = GetLootRollItemLink(rollID)

        if itemLink then
            local _, _, _, _, _, canNeed, canGreed, _, _, _, _, _, canTransmog = GetLootRollItemInfo(rollID)
            local lootStates = {
                canNeed = canNeed,
                canGreed = canGreed,
                canTransmog = canTransmog,
            }

            Roll(self, rollID, itemLink, lootStates)
        end
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(AutoRoll.modName, function() return AutoRoll:Initialize() end)
