local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "AutoRoll"

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = false,
    -- gear section
    AlwaysNeed_Gear = true,
    SecondaryChoice_Gear = "TRANSMOG", -- options: "GREED", "TRANSMOG", "PASS"
    -- non-gear section
    AlwaysNeed_Recipe = true,
    SecondaryChoice_Recipe = "GREED", -- options: "GREED", "PASS"
    AlwaysNeed_Mount = true,
    SecondaryChoice_Mount = "GREED", -- options: "GREED", "PASS"
    AlwaysNeed_Toy = true,
    SecondaryChoice_Toy = "GREED", -- options: "GREED", "PASS"
    AlwaysNeed_Housing = true,
    SecondaryChoice_Housing = "GREED", -- options: "GREED", "PASS"
}

local function CreateItemOptions(parentGroup, itemKey, itemLabel, secondaryChoices, secondaryOrder)
    local itemGroup = GUI:CreateInlineGroup(parentGroup, itemLabel)
    GUI:CreateToggleCheckBox(itemGroup, L["AlwaysNeed"], addon.db.AutoRoll["AlwaysNeed_" .. itemKey], function(value)
        addon.db.AutoRoll["AlwaysNeed_" .. itemKey] = value
    end)
    GUI:CreateDropdown(itemGroup, L["SecondaryChoice"], secondaryChoices, secondaryOrder, addon.db.AutoRoll["SecondaryChoice_" .. itemKey], function(key)
        addon.db.AutoRoll["SecondaryChoice_" .. itemKey] = key
    end)
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

    CreateItemOptions(frame, "Gear", L["ItemType"]["Gear"], {GREED = L["RollType"]["GREED"], TRANSMOG = L["RollType"]["TRANSMOG"], PASS = L["RollType"]["PASS"]}, {"TRANSMOG", "GREED", "PASS"})
    CreateItemOptions(frame, "Housing", L["ItemType"]["Housing"], {GREED = L["RollType"]["GREED"], PASS = L["RollType"]["PASS"]}, {"GREED", "PASS"})
    CreateItemOptions(frame, "Recipe", L["ItemType"]["Recipe"], {GREED = L["RollType"]["GREED"], PASS = L["RollType"]["PASS"]}, {"GREED", "PASS"})
    CreateItemOptions(frame, "Mount", L["ItemType"]["Mount"], {GREED = L["RollType"]["GREED"], PASS = L["RollType"]["PASS"]}, {"GREED", "PASS"})
    CreateItemOptions(frame, "Toy", L["ItemType"]["Toy"], {GREED = L["RollType"]["GREED"], PASS = L["RollType"]["PASS"]}, {"GREED", "PASS"})

	return frame
end