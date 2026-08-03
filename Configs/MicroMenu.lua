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

-- GUI
GUI.TagPanels.MicroMenu = {}
function GUI.TagPanels.MicroMenu:CreateTabPanel(parent)
	local frame = GUI:CreateScrollFrame(parent)
	frame:SetLayout("Flow")
	frame:SetFullWidth(true)

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

	GUI:CreateButton(frame, L["ResetMod"], function()
		addon.Utilities:SetPopupDialog(
			ADDON_NAME .. "ResetMod",
			"|cffC41E3A" .. L["MicroMenuSettings"] .. "|r: " .. L["ComfirmResetMod"],
			true,
			{button1 = YES, button2 = NO, OnButton1 = function()
				addon.Utilities:ResetModule(MOD_KEY)
				ReloadUI()
			end}
		)
	end)

	local styleGroup = GUI:CreateInlineGroup(frame, L["StyleSettings"])
	local positionGroup = GUI:CreateInlineGroup(styleGroup, L["PositionSettings"])
	GUI:CreateSlider(positionGroup, L["X"], -2000, 2000, 1, addon.db[MOD_KEY].X, function(value)
		addon.db[MOD_KEY].X = value
		update()
	end)
	GUI:CreateSlider(positionGroup, L["Y"], -1000, 1000, 1, addon.db[MOD_KEY].Y, function(value)
		addon.db[MOD_KEY].Y = value
		update()
	end)

	GUI:CreateDropdown(frame, L["HearthStoneSelection"], addon.core:GetModule(MOD_KEY):GetAvailableHearthstoneID(), nil, addon.db[MOD_KEY].HearthstoneID, function(value)
		addon.db[MOD_KEY].HearthstoneID = value
		update()
	end)

	local groupMenuGroup = GUI:CreateInlineGroup(frame, L["GroupMenuSettings"])
	GUI:CreateToggleCheckBox(groupMenuGroup, L["Enable"] .. "|cff0070DD" .. L["GroupMenuSettings"] .. "|r", addon.db[MOD_KEY].GroupMenuEnabled, function(value)
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
