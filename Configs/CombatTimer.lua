local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "CombatTimer"

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = true,
	CombatShow = false,
	PrintEnabled = false,
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
GUI.TagPanels.CombatTimer = {}
function GUI.TagPanels.CombatTimer:CreateTabPanel(parent)
	-- MARK: General
	local frame = GUI:CreateScrollFrame(parent)
	frame:SetLayout("Flow")

	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["TimerSettings"] .. "|r", addon.db.CombatTimer.Enabled, function(value)
		addon.db.CombatTimer.Enabled = value
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
	GUI:CreateToggleCheckBox(frame, L["TimerCombatShow"], addon.db.CombatTimer.CombatShow, function(value)
		addon.db.CombatTimer.CombatShow = value
		addon:ShowDialog(ADDON_NAME.."RLNeeded")
	end)
	GUI:CreateToggleCheckBox(frame, L["TimerPrintEnabled"], addon.db.CombatTimer.PrintEnabled, function(value)
		addon.db.CombatTimer.PrintEnabled = value
	end)
	GUI:CreateButton(frame, L["ResetMod"], function ()
		addon.Utilities:SetPopupDialog(
			ADDON_NAME .. "ResetMod",
			"|cffC41E3A" .. L["TimerSettings"] .. "|r: " .. L["ComfirmResetMod"],
			true,
			{button1 = YES, button2 = NO, OnButton1 = function ()
				addon.Utilities:ResetModule(MOD_KEY)
				ReloadUI()
			end}
		)
	end)

	-- Style Settings
	local styleGroup = GUI:CreateInlineGroup(frame, L["StyleSettings"])
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