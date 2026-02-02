local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local MOD_KEY = "BattleRes"

local function update()
	if addon.battleRes then
		addon.battleRes:UpdateStyle()
	end
end
local function RLNeeded()
	addon:ShowDialog(ADDON_NAME.."RLNeeded")
end

addon.configurationList[MOD_KEY] = {
	Enabled = true,
	Font = "",
	HideInactive = true,
	TimeFontScale = 0.5,
	ChargeFontSize = 14,
	X = -390,
	Y = -220,
	IconSize = 35,
	IconZoom = 0.07,
}

-- options
local optionMap = addon.Utilities:MakeOptionGroup(L["BattleResSettings"], {
    addon.Utilities:MakeToggleOption(L["Enable"], MOD_KEY, "Enabled", RLNeeded, {desc = L["ReloadNeeded"]}),
	addon.Utilities:MakeToggleOption(L["HidenInactive"], MOD_KEY, "HideInactive", nil, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
	addon.Utilities:MakeOptionGroup(L["StyleSettings"], {
		addon.Utilities:MakeRangeOption(L["IconSize"], MOD_KEY, "IconSize", 10, 200, 1, update),
		addon.Utilities:MakeRangeOption(L["IconZoom"], MOD_KEY, "IconZoom",0.01, 0.5, 0.01, update),
		addon.Utilities:MakeOptionLineBreak(),
		addon.Utilities:MakeRangeOption(L["X"], MOD_KEY, "X", -2000, 2000, 1, update),
		addon.Utilities:MakeRangeOption(L["Y"], MOD_KEY, "Y", -1000, 1000, 1, update),
		addon.Utilities:MakeOptionLineBreak(),
		addon.Utilities:MakeRangeOption(L["TimeFontScale"], MOD_KEY, "TimeFontScale", 0.1, 5, 0.01, update),
		addon.Utilities:MakeOptionLineBreak(),
		addon.Utilities:MakeLSMFontOption(L["Font"], MOD_KEY, "Font", update),
		addon.Utilities:MakeRangeOption(L["StackFontSize"], MOD_KEY, "ChargeFontSize", 6, 40, 1, update),
	}, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
}, false, {order = addon:OptionOrderHandler(), desc = L["BattleResSettingsDesc"]})
addon:AppendOptionsList("BattleRes", optionMap)