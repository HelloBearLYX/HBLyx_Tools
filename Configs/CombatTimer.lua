local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local MOD_KEY = "CombatTimer"

local function update()
	if addon.combatTimer then
		addon.combatTimer:UpdateStyle()
	end
end

addon.configurationList[MOD_KEY] = {
	Enabled = true,
	CombatShow = false,
	PrintEnabled = false,
	Font = "",
	FontSize = 20,
	X = -180,
	Y = -260,
}

-- options
-- local optionMap = addon.Utilities:MakeOptionGroup(L["TimerSettings"], {
-- 	addon.Utilities:MakeToggleOption(L["Enable"], MOD_KEY, "Enabled", RLNeeded, {desc = L["ReloadDesc"]}),
-- 	addon.Utilities:MakeResetOption(MOD_KEY, L["TimerSettings"]),
-- 	addon.Utilities:MakeOptionLineBreak(),
-- 	addon.Utilities:MakeToggleOption(L["TimerCombatShow"], MOD_KEY, "CombatShow", RLNeeded, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end, desc = L["ReloadDesc"]}),
-- 	addon.Utilities:MakeToggleOption(L["TimerPrintEnabled"], MOD_KEY, "PrintEnabled", nil, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end, desc = L["TimerPrintEnabledDesc"]}),
-- 	-- combat timer style settings
-- 	addon.Utilities:MakeOptionGroup(L["StyleSettings"],{
-- 		addon.Utilities:MakeLSMFontOption(L["Font"], MOD_KEY, "Font", update),
-- 		addon.Utilities:MakeRangeOption(L["FontSize"], MOD_KEY, "FontSize", 6, 40, 1, update),
-- 		addon.Utilities:MakeOptionLineBreak(),
-- 		addon.Utilities:MakeRangeOption(L["X"], MOD_KEY, "X", -2000, 2000, 1, update),
-- 		addon.Utilities:MakeRangeOption(L["Y"], MOD_KEY, "Y", -1000, 1000, 1, update),
-- 	}, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
-- }, false, {order = addon:OptionOrderHandler(), desc = L["TimerSettingsDesc"]})
-- addon:AppendOptionsList("CombatTimer", optionMap)

--GUI
local GUI = addon.GUI

GUI.TagPanels.CombatTimer = {}
function GUI.TagPanels.CombatTimer:CreateTabPanel(parent)
	local frame = GUI:CreateScrollFrame(parent)
	frame:SetLayout("Flow")
	GUI:CreateInformationTag(frame, L["TimerSettingsDesc"], "LEFT")
	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["TimerSettings"] .. "|r", addon.db.CombatTimer.Enabled, function(value)
		addon.db.CombatTimer.Enabled = value
		addon:ShowDialog(ADDON_NAME.."RLNeeded")
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

	GUI:CreateHeader(frame, L["StyleSettings"])
	GUI:CreateFontSelect(frame, L["Font"], addon.db.CombatTimer.Font, function(value)
		addon.db.CombatTimer.Font = value
		update()
	end)
	GUI:CreateSlider(frame, L["FontSize"], 6, 40, 1, addon.db.CombatTimer.FontSize, function(value)
		addon.db.CombatTimer.FontSize = value
		update()
	end)
	GUI:CreateSlider(frame, L["X"], -2000, 2000, 1, addon.db.CombatTimer.X, function(value)
		addon.db.CombatTimer.X = value
		update()
	end)
	GUI:CreateSlider(frame, L["Y"], -1000, 1000, 1, addon.db.CombatTimer.Y, function(value)
		addon.db.CombatTimer.Y = value
		update()
	end)

	parent:AddChild(frame)
	return frame
end