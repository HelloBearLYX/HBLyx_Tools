local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "TextWarningSkins"

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = false,
    Width = 500,
    Height = 40,
    X = 0,
    Y = 200,
    PrivateWarningX = 0,
    PrivateWarningY = 240,
    Grow = "DOWN",
    FontSize = 20,
    Font = "",
}

-- MARK: Safe update

local function update()
	return addon.core:GetSafeUpdate(MOD_KEY)()
end

-- GUI
GUI.TagPanels.TextWarningSkins = {}
function GUI.TagPanels.TextWarningSkins:CreateTabPanel(parent)
	-- MARK: General
	local frame = GUI:CreateScrollFrame(parent)

	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["TextWarningSkinsSettings"] .. "|r", addon.db.TextWarningSkins.Enabled, function(value)
		addon.db.TextWarningSkins.Enabled = value
		if addon.core:HasModuleLoaded(MOD_KEY) then
			if not value then
				addon:ShowDialog(ADDON_NAME.."RLNeeded")
			end
		else
			if value then
				addon.core:LoadModule(MOD_KEY)
				addon.core:TestModule(MOD_KEY)
			end
		end
	end)
	GUI:CreateButton(frame, L["ResetMod"], function()
		addon.Utilities:SetPopupDialog(
			ADDON_NAME .. "ResetMod",
			"|cffC41E3A" .. L["TextWarningSkinsSettings"] .. "|r: " .. L["ComfirmResetMod"],
			true,
			{button1 = YES, button2 = NO, OnButton1 = function()
				addon.Utilities:ResetModule(MOD_KEY)
				ReloadUI()
			end}
		)
	end)

	-- MARK: Style
	local styleGroup = GUI:CreateInlineGroup(frame, L["StyleSettings"])
	GUI:CreateDropdown(styleGroup, L["Grow"], addon.Utilities.Grows, nil, addon.db.TextWarningSkins.Grow, function(key)
		addon.db.TextWarningSkins.Grow = key
		update()
	end)

	-- MARK: Size
	local sizeGroup = GUI:CreateInlineGroup(styleGroup, L["IconSettings"])
	GUI:CreateSlider(sizeGroup, L["Width"], 10, 800, 1, addon.db.TextWarningSkins.Width, function(value)
		addon.db.TextWarningSkins.Width = value
		update()
	end)
	GUI:CreateSlider(sizeGroup, L["Height"], 10, 400, 1, addon.db.TextWarningSkins.Height, function(value)
		addon.db.TextWarningSkins.Height = value
		update()
	end)

	-- MARK: Position
	local positionGroup = GUI:CreateInlineGroup(styleGroup, L["PositionSettings"])
	GUI:CreateSlider(positionGroup, L["X"], -2000, 2000, 1, addon.db.TextWarningSkins.X, function(value)
		addon.db.TextWarningSkins.X = value
		update()
	end)
	GUI:CreateSlider(positionGroup, L["Y"], -1000, 1000, 1, addon.db.TextWarningSkins.Y, function(value)
		addon.db.TextWarningSkins.Y = value
		update()
	end)
	-- MARK: Font
	local fontGroup = GUI:CreateInlineGroup(styleGroup, L["FontSettings"])
	GUI:CreateFontSelect(fontGroup, L["Font"], addon.db.TextWarningSkins.Font, function(value)
		addon.db.TextWarningSkins.Font = value
		update()
	end)
	GUI:CreateSlider(fontGroup, L["FontSize"], 6, 40, 1, addon.db.TextWarningSkins.FontSize, function(value)
		addon.db.TextWarningSkins.FontSize = value
		update()
	end)

	local privateWarningGroup = GUI:CreateInlineGroup(frame, L["PrivateWarningSettings"])
	GUI:CreateInformationTag(privateWarningGroup, L["PrivateWarningSettingsDesc"], "LEFT")
	GUI:CreateSlider(privateWarningGroup, L["X"], -2000, 2000, 1, addon.db.TextWarningSkins.PrivateWarningX, function(value)
		addon.db.TextWarningSkins.PrivateWarningX = value
		update()
	end)
	GUI:CreateSlider(privateWarningGroup, L["Y"], -1000, 1000, 1, addon.db.TextWarningSkins.PrivateWarningY, function(value)
		addon.db.TextWarningSkins.PrivateWarningY = value
		update()
	end)

	return frame
end