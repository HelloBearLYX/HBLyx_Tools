local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local MOD_KEY = "CombatTimer"

local function update()
	if addon.combatTimer then
		addon.combatTimer:UpdateStyle()
	end
end
local function RLNeeded()
	addon:ShowDialog(ADDON_NAME.."RLNeeded")
end

addon.configurationList[MOD_KEY] = {
	Enabled = true,
	CombatShow = false,
	PrintEnabled = false,
	Font = "",
	FontSize = 20,
	X = -390,
	Y = - 180,
}

-- options
local optionMap = addon.Utilities:MakeOptionGroup(L["TimerSettings"], {
	addon.Utilities:MakeToggleOption(L["Enable"], MOD_KEY, "Enabled", RLNeeded, {desc = L["ReloadDesc"]}),
	addon.Utilities:MakeResetOption(MOD_KEY, L["TimerSettings"]),
	addon.Utilities:MakeOptionLineBreak(),
	addon.Utilities:MakeToggleOption(L["TimerCombatShow"], MOD_KEY, "CombatShow", RLNeeded, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end, desc = L["ReloadDesc"]}),
	addon.Utilities:MakeToggleOption(L["TimerPrintEnabled"], MOD_KEY, "PrintEnabled", nil, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end, desc = L["TimerPrintEnabledDesc"]}),
	-- combat timer style settings
	addon.Utilities:MakeOptionGroup(L["StyleSettings"],{
		addon.Utilities:MakeLSMFontOption(L["Font"], MOD_KEY, "Font", update),
		addon.Utilities:MakeRangeOption(L["FontSize"], MOD_KEY, "FontSize", 6, 40, 1, update),
		addon.Utilities:MakeOptionLineBreak(),
		addon.Utilities:MakeRangeOption(L["X"], MOD_KEY, "X", -2000, 2000, 1, update),
		addon.Utilities:MakeRangeOption(L["Y"], MOD_KEY, "Y", -1000, 1000, 1, update),
	}, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
}, false, {order = addon:OptionOrderHandler(), desc = L["TimerSettingsDesc"]})
addon:AppendOptionsList("CombatTimer", optionMap)