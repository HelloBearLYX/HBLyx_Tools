local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "MicroMenu"

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = true,
	X = 0,
	Y = 465,
	HearthstoneID = 0,

	GroupMenuEnabled = true,
	GroupMenuOnlyInGroup = false,
	X_GroupMenu = -490,
	Y_GroupMenu = 460,
}

-- MARK: Safe update
local function update()
	return addon.core:GetSafeUpdate(MOD_KEY)()
end

local function GetHearthstoneList()
	if addon.core:GetModule(MOD_KEY) then
		return addon.core:GetModule(MOD_KEY):GetAvailableHearthstoneID()
	end
	return {}
end

-- GUI
GUI.TagPanels.MicroMenu = {}
function GUI.TagPanels.MicroMenu:CreateTabPanel(parent)
	local frame = parent

	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["MicroMenuSettings"] .. "|r", addon.db[MOD_KEY].Enabled, function(value)
		addon.db[MOD_KEY].Enabled = value
		if addon.core:HasModuleLoaded(MOD_KEY) then
			if not value then
				addon:ShowDialog(ADDON_NAME .. "RLNeeded")
			end
		else
			if value then
				addon.core:LoadModule(MOD_KEY)
				addon.core:TestModule(MOD_KEY)
				update()
			end
		end
	end)

	GUI:CreateResetModButton(frame, MOD_KEY, L["MicroMenuSettings"])

	local positionGroup = GUI:CreateInlineGroup(frame, L["PositionSettings"])
	GUI:CreateSlider(positionGroup, L["X"], -2000, 2000, 1, addon.db[MOD_KEY].X, function(value)
		addon.db[MOD_KEY].X = value
		update()
	end)
	GUI:CreateSlider(positionGroup, L["Y"], -1000, 1000, 1, addon.db[MOD_KEY].Y, function(value)
		addon.db[MOD_KEY].Y = value
		update()
	end)

	GUI:CreateDropdown(frame, L["HearthStoneSelection"], GetHearthstoneList(), nil, addon.db[MOD_KEY].HearthstoneID, function(value)
		addon.db[MOD_KEY].HearthstoneID = value
		update()
	end)

	local groupMenuGroup = GUI:CreateInlineGroup(frame, L["GroupMenuSettings"])
	GUI:CreateToggleCheckBox(groupMenuGroup, L["Enable"] .. L["GroupMenuSettings"], addon.db[MOD_KEY].GroupMenuEnabled, function(value)
		addon.db[MOD_KEY].GroupMenuEnabled = value
		update()
	end)
	GUI:CreateToggleCheckBox(groupMenuGroup, L["GroupMenuOnlyInGroup"], addon.db[MOD_KEY].GroupMenuOnlyInGroup, function(value)
		addon.db[MOD_KEY].GroupMenuOnlyInGroup = value
		update()
	end)

	local groupMenuPositionGroup = GUI:CreateInlineGroup(groupMenuGroup, L["PositionSettings"])
	GUI:CreateSlider(groupMenuPositionGroup, L["X"], -2000, 2000, 1, addon.db[MOD_KEY].X_GroupMenu, function(value)
		addon.db[MOD_KEY].X_GroupMenu = value
		update()
	end)
	GUI:CreateSlider(groupMenuPositionGroup, L["Y"], -1000, 1000, 1, addon.db[MOD_KEY].Y_GroupMenu, function(value)
		addon.db[MOD_KEY].Y_GroupMenu = value
		update()
	end)

	return frame
end
