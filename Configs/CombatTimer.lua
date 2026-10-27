local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "CombatTimer"

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = true,
	CombatShow = false,
	PrintEnabled = false,
	TimeFormat = "%02d:%02d",
	Font = "",
	FontSize = 20,
	X = -180,
	Y = -260,
	FrameStrata = "BACKGROUND",
}

-- MARK: Safe update
local function update()
	return addon.core:GetSafeUpdate(MOD_KEY)()
end

-- GUI
local function RenderPanel(parent)
	-- MARK: General
	local frame = parent

	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["TimerSettings"] .. "|r", addon.db.CombatTimer.Enabled, function(value)
		addon.db.CombatTimer.Enabled = value
		addon.core:ToggleModule(MOD_KEY, value)
	end)
	GUI:CreateToggleCheckBox(frame, L["TimerCombatShow"], addon.db.CombatTimer.CombatShow, function(value)
		addon.db.CombatTimer.CombatShow = value
		addon.core:ShowReloadPopup()
	end)
	GUI:CreateToggleCheckBox(frame, L["TimerPrintEnabled"], addon.db.CombatTimer.PrintEnabled, function(value)
		addon.db.CombatTimer.PrintEnabled = value
	end)
	GUI:CreateResetModButton(frame, MOD_KEY, L["TimerSettings"])

	-- Style Settings
	local styleGroup = GUI:CreateInlineGroup(frame, L["StyleSettings"])
	GUI:CreateInformationTag(frame, L["TimerTimeFormatDesc"], "LEFT")
	GUI:CreateEditBox(frame, L["TimerTimeFormat"], addon.db.CombatTimer.TimeFormat, function(value)
		-- fall back to the default if the format is invalid
		if value == "" or not pcall(string.format, value, 0, 0) then
			value = "%02d:%02d"
		end
		addon.db.CombatTimer.TimeFormat = value
		update()
	end)
	GUI:CreateFrameStrataDropdown(styleGroup, addon.db.CombatTimer.FrameStrata, function(value)
		addon.db.CombatTimer.FrameStrata = value
		update()
	end)
	-- MARK: Font
	local fontGroup = GUI:CreateInlineGroup(styleGroup, L["FontSettings"])
	GUI:CreateFontSelect(fontGroup, L["Font"], addon.db.CombatTimer.Font, function(value)
		addon.db.CombatTimer.Font = value
		update()
	end)
	GUI:CreateSlider(fontGroup, L["FontSize"], 6, 40, 1, addon.db.CombatTimer.FontSize, function(value)
		addon.db.CombatTimer.FontSize = value
		update()
	end)

	-- MARK: Position
	local positionGroup = GUI:CreateInlineGroup(styleGroup, L["PositionSettings"])
	GUI:CreateSlider(positionGroup, L["X"], -2000, 2000, 1, addon.db.CombatTimer.X, function(value)
		addon.db.CombatTimer.X = value
		update()
	end)
	GUI:CreateSlider(positionGroup, L["Y"], -1000, 1000, 1, addon.db.CombatTimer.Y, function(value)
		addon.db.CombatTimer.Y = value
		update()
	end)

	return frame
end

GUI:RegisterModule(MOD_KEY, RenderPanel)