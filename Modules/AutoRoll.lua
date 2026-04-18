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
    local firstChoice = ROLL_TYPE[addon.db[self.modName]["FirstChoice_" .. itemType] or "NEED"]
    local secondaryChoice = ROLL_TYPE[addon.db[self.modName]["SecondaryChoice_" .. itemType] or "GREED"]

    if firstChoice == ROLL_TYPE.PASS
        or (firstChoice == ROLL_TYPE.NEED and lootStates.canNeed)
        or (firstChoice == ROLL_TYPE.GREED and lootStates.canGreed)
        or (firstChoice == ROLL_TYPE.TRANSMOG and lootStates.canTransmog) then
        return firstChoice
    elseif secondaryChoice == ROLL_TYPE.PASS
        or (secondaryChoice == ROLL_TYPE.NEED and lootStates.canNeed)
        or (secondaryChoice == ROLL_TYPE.GREED and lootStates.canGreed)
        or (secondaryChoice == ROLL_TYPE.TRANSMOG and lootStates.canTransmog) then
        return secondaryChoice
    end

    return nil
end

local function ResolveGearChoice(choice, lootStates)
    if choice == ROLL_TYPE.PASS then
        return ROLL_TYPE.PASS
    elseif choice == ROLL_TYPE.NEED and lootStates.canNeed then
        return ROLL_TYPE.NEED
    elseif choice == ROLL_TYPE.TRANSMOG then
        if lootStates.canTransmog then
            return ROLL_TYPE.TRANSMOG
        elseif lootStates.canGreed then
            return ROLL_TYPE.GREED
        end
    elseif choice == ROLL_TYPE.GREED and lootStates.canGreed then
        return ROLL_TYPE.GREED
    end

    return nil
end

local function GetRollType(self, itemType, lootStates)
    local toggle = addon.db[self.modName]["Toggle_" .. itemType] or false
    if not toggle then
        return nil
    end

    if itemType == "Gear" then
        local firstChoice = ROLL_TYPE[addon.db[self.modName]["FirstChoice_" .. itemType] or "NEED"]
        local secondaryChoice = ROLL_TYPE[addon.db[self.modName]["SecondaryChoice_" .. itemType] or "GREED"]

        local firstResolved = ResolveGearChoice(firstChoice, lootStates)
        if firstResolved then
            return firstResolved
        end

        local secondaryResolved = ResolveGearChoice(secondaryChoice, lootStates)
        if secondaryResolved then
            return secondaryResolved
        end

        return nil
    end

    return NonGearHelper(self, lootStates, itemType)
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
        elseif C_ToyBox.GetToyInfo(itemID) then -- toy
            choice = GetRollType(self, "Toy", lootStates)
        elseif classID == Enum.ItemClass.Weapon or classID == Enum.ItemClass.Armor then -- gear
            choice = GetRollType(self, "Gear", lootStates)
        else
            return -- for other types of items, do not roll automatically
        end

        -- only roll if have a valid choice and can actually roll that choice
        if choice then
            RollOnLoot(rollID, choice)
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
