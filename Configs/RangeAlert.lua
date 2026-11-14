local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "RangeAlert"

local RANGE_DISPLAY_COLOR_ORDER = {"0-5", "5-10", "10-20", "20-30", "30-40", "40+"}

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = true,
	X = 0,
	Y = -110,
	FontSize = 24,
	Color = "ffFF0000",
	AlertText = L["RangeAlertText"],
	FrameStrata = "BACKGROUND",
	ShowRangeDisplay = false,
	RangeDisplayColors = {
		["0-5"] = "E6E6E6",
		["5-10"] = "3FC7EB",
		["10-20"] = "00FF98",
		["20-30"] = "FFF468",
		["30-40"] = "FF7C0A",
		["40+"] = "C41E3A",
	},
}

-- MARK: Safe update
local function update()
	return addon.core:GetSafeUpdate(MOD_KEY)()
end

-- GUI
local function RenderPanel(parent)
	-- MARK: General
	local frame = parent

	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["RangeAlertSettings"] .. "|r", addon.db.RangeAlert.Enabled, function(value)
		addon.db.RangeAlert.Enabled = value
		addon.core:ToggleModule(MOD_KEY, value)
	end)
	GUI:CreateResetModButton(frame, MOD_KEY, L["RangeAlertSettings"])
	GUI:CreateInformationTag(frame, L["RangeAlertInfo"], "LEFT")
	GUI:CreateFrameStrataDropdown(frame, addon.db.RangeAlert.FrameStrata, function(value)
		addon.db.RangeAlert.FrameStrata = value
		update()
	end)

	-- MARK: Style
	local styleGroup = GUI:CreateInlineGroup(frame, L["StyleSettings"])
	GUI:CreateSlider(styleGroup, L["FontSize"], 6, 60, 1, addon.db.RangeAlert.FontSize, function(value)
		addon.db.RangeAlert.FontSize = value
		update()
	end)
	GUI:CreateEditBox(styleGroup, L["RangeAlertTextLabel"], addon.db.RangeAlert.AlertText, function(value)
		addon.db.RangeAlert.AlertText = value
		update()
	end)
	GUI:CreateColorPicker(styleGroup, L["Color"], false, addon.db.RangeAlert.Color, function(value)
		addon.db.RangeAlert.Color = value
		update()
	end)

	-- MARK: Position
	local positionGroup = GUI:CreateInlineGroup(styleGroup, L["PositionSettings"])
	GUI:CreateSlider(positionGroup, L["X"], -2000, 2000, 1, addon.db.RangeAlert.X, function(value)
		addon.db.RangeAlert.X = value
		update()
	end)
	GUI:CreateSlider(positionGroup, L["Y"], -1000, 1000, 1, addon.db.RangeAlert.Y, function(value)
		addon.db.RangeAlert.Y = value
		update()
	end)

	-- MARK: Range Display
	local rangeDisplayGroup = GUI:CreateInlineGroup(frame, L["RangeAlertRangeDisplay"])
	GUI:CreateInformationTag(rangeDisplayGroup, L["ShowRangeDisplayDesc"], "LEFT")
	GUI:CreateToggleCheckBox(rangeDisplayGroup, L["ShowRangeDisplay"], addon.db.RangeAlert.ShowRangeDisplay, function(value)
		addon.db.RangeAlert.ShowRangeDisplay = value
	end)

	GUI:CreateInformationTag(rangeDisplayGroup, L["RangeDisplayColorDesc"], "LEFT")
	for _, bracketKey in ipairs(RANGE_DISPLAY_COLOR_ORDER) do
		GUI:CreateColorPicker(rangeDisplayGroup, bracketKey, false, addon.db.RangeAlert.RangeDisplayColors[bracketKey], function(value)
			addon.db.RangeAlert.RangeDisplayColors[bracketKey] = value
		end):SetRelativeWidth(0.165) -- 1 / 6 where 6 is the number of range brackets, take the floor value
	end

	return frame
end

GUI:RegisterModule(MOD_KEY, RenderPanel)
