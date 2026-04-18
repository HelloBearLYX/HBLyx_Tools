local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "AutoRoll"

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = false,
    -- gear section
    Toggle_Gear = true,
    FirstChoice_Gear = "NEED", -- options: "NEED", "GREED", "TRANSMOG", "PASS"
    SecondaryChoice_Gear = "TRANSMOG", -- options: "GREED", "TRANSMOG", "PASS"
    -- non-gear section
    Toggle_Recipe = true,
    FirstChoice_Recipe = "NEED", -- options: "NEED", "GREED", "PASS"
    SecondaryChoice_Recipe = "GREED", -- options: "GREED", "PASS"
    Toggle_Mount = true,
    FirstChoice_Mount = "NEED", -- options: "NEED", "GREED", "PASS"
    SecondaryChoice_Mount = "GREED", -- options: "GREED", "PASS"
    Toggle_Toy = true,
    FirstChoice_Toy = "NEED", -- options: "NEED", "GREED", "PASS"
    SecondaryChoice_Toy = "GREED", -- options: "GREED", "PASS"
    Toggle_Housing = true,
    FirstChoice_Housing = "NEED", -- options: "NEED", "GREED", "PASS"
    SecondaryChoice_Housing = "GREED", -- options: "GREED", "PASS"
}

local function CreateItemOptions(parentGroup, itemKey, itemLabel, firstChoices, firstOrder, secondaryChoices, secondaryOrder)
    local itemGroup = GUI:CreateInlineGroup(parentGroup, itemLabel)
    GUI:CreateToggleCheckBox(itemGroup, L["ApplyAutoRoll"], addon.db.AutoRoll["Toggle_" .. itemKey], function(value)
        addon.db.AutoRoll["Toggle_" .. itemKey] = value
    end):SetRelativeWidth(0.1)
    GUI:CreateDropdown(itemGroup, L["FirstChoice"], firstChoices, firstOrder, addon.db.AutoRoll["FirstChoice_" .. itemKey], function(key)
        addon.db.AutoRoll["FirstChoice_" .. itemKey] = key
    end):SetRelativeWidth(0.25)
    GUI:CreateDropdown(itemGroup, L["SecondaryChoice"], secondaryChoices, secondaryOrder, addon.db.AutoRoll["SecondaryChoice_" .. itemKey], function(key)
        addon.db.AutoRoll["SecondaryChoice_" .. itemKey] = key
    end):SetRelativeWidth(0.25)
end

-- GUI
GUI.TagPanels.AutoRoll = {}
function GUI.TagPanels.AutoRoll:CreateTabPanel(parent)
	-- MARK: General
	local frame = GUI:CreateScrollFrame(parent)
	frame:SetLayout("Flow")
	frame:SetFullWidth(true)

    GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["AutoRollSettings"] .. "|r", addon.db.AutoRoll.Enabled, function(value)
		addon.db.AutoRoll.Enabled = value
		if addon.core:HasModuleLoaded(MOD_KEY) then -- if module is loaded
            if not value then -- user try to disable the module
                addon:ShowDialog(ADDON_NAME.."RLNeeded")
            end
        else -- if the module is not loaded yet
            if value then -- user try to enable the module, just load it without asking for reload, since it will be loaded immediately
                addon.core:LoadModule(MOD_KEY)
                addon.core:TestModule(MOD_KEY) -- the test mode will be on if the addon is in test mode
            end
        end
	end)
	GUI:CreateButton(frame, L["ResetMod"], function ()
		addon.Utilities:SetPopupDialog(
			ADDON_NAME .. "ResetMod",
			"|cffC41E3A" .. L["AutoRollSettings"] .. "|r: " .. L["ComfirmResetMod"],
			true,
			{button1 = YES, button2 = NO, OnButton1 = function ()
		    	addon.Utilities:ResetModule(MOD_KEY)
				ReloadUI()
			end}
		)
	end)

    local gearFirstChoices = {NEED = L["RollType"]["NEED"], GREED = L["RollType"]["GREED"], TRANSMOG = L["RollType"]["TRANSMOG"], PASS = L["RollType"]["PASS"]}
    local gearFirstOrder = {"NEED", "TRANSMOG", "GREED", "PASS"}
    local gearSecondaryChoices = {GREED = L["RollType"]["GREED"], TRANSMOG = L["RollType"]["TRANSMOG"], PASS = L["RollType"]["PASS"]}
    local gearSecondaryOrder = {"GREED", "TRANSMOG", "PASS"}
    CreateItemOptions(frame, "Gear", L["ItemType"]["Gear"], gearFirstChoices, gearFirstOrder, gearSecondaryChoices, gearSecondaryOrder)
    local nonGearFirstChoices = {NEED = L["RollType"]["NEED"], GREED = L["RollType"]["GREED"], PASS = L["RollType"]["PASS"]}
    local nonGearFirstOrder = {"NEED", "GREED", "PASS"}
    local nonGearSecondaryChoices = {GREED = L["RollType"]["GREED"], PASS = L["RollType"]["PASS"]}
    local nonGearSecondaryOrder = {"GREED", "PASS"}
    CreateItemOptions(frame, "Housing", L["ItemType"]["Housing"], nonGearFirstChoices, nonGearFirstOrder, nonGearSecondaryChoices, nonGearSecondaryOrder)
    CreateItemOptions(frame, "Recipe", L["ItemType"]["Recipe"], nonGearFirstChoices, nonGearFirstOrder, nonGearSecondaryChoices, nonGearSecondaryOrder)
    CreateItemOptions(frame, "Mount", L["ItemType"]["Mount"], nonGearFirstChoices, nonGearFirstOrder, nonGearSecondaryChoices, nonGearSecondaryOrder)
    CreateItemOptions(frame, "Toy", L["ItemType"]["Toy"], nonGearFirstChoices, nonGearFirstOrder, nonGearSecondaryChoices, nonGearSecondaryOrder)

	return frame
end