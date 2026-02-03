local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local MOD_KEY = "CombatIndicator"

addon.LSM:Register("sound", ADDON_NAME.. "_EnterCombat", L["CombatInSoundDefault"])
addon.LSM:Register("sound", ADDON_NAME.. "_LeaveCombat", L["CombatOutSoundDefault"])

local function update()
	if addon.combatIndicator then
		addon.combatIndicator:UpdateStyle()
	end
end
local function RLNeeded()
	addon:ShowDialog(ADDON_NAME.."RLNeeded")
end

addon.configurationList[MOD_KEY] = {
	Enabled = true,
	FadeTime = 3,
	Font = "",
	FontSize = 30,
	X = 0,
	Y = 140,
	InCombatColor = "ffC41E3A",
	OutCombatColor = "ff00FF00",
	InCombatText = L["CombatInText"],
	OutCombatText = L["CombatOutText"],
	Mute = true,
	InCombatSoundMeida = ADDON_NAME.. "_EnterCombat",
	OutCombatSoundMedia = ADDON_NAME.. "_LeaveCombat",
}

-- options
local optionMap = addon.Utilities:MakeOptionGroup(L["CombatSettings"], {
	addon.Utilities:MakeToggleOption(L["Enable"], MOD_KEY, "Enabled", RLNeeded),
	addon.Utilities:MakeResetOption(MOD_KEY, L["CombatSettings"]),
	-- combat indicator style settings
	addon.Utilities:MakeOptionGroup(L["StyleSettings"],{
		addon.Utilities:MakeRangeOption(L["FadeTime"], MOD_KEY, "FadeTime", 0.5, 10, 0.5, nil, {desc = L["CombatFadeTimeDesc"]}),
		addon.Utilities:MakeOptionLineBreak(),
		addon.Utilities:MakeLSMFontOption(L["Font"]	, MOD_KEY, "Font", update),
		addon.Utilities:MakeRangeOption(L["FontSize"], MOD_KEY, "FontSize", 6, 40, 1, update),
		addon.Utilities:MakeOptionLineBreak(),
		addon.Utilities:MakeColorOption(L["CombatInColor"], MOD_KEY, "InCombatColor", update),
		addon.Utilities:MakeColorOption(L["CombatOutColor"], MOD_KEY, "OutCombatColor", update),
		addon.Utilities:MakeOptionLineBreak(),
		addon.Utilities:MakeInputOption(L["CInText"], MOD_KEY, "InCombatText"),
		addon.Utilities:MakeInputOption(L["COutText"], MOD_KEY, "OutCombatText"),
		addon.Utilities:MakeOptionLineBreak(),
		addon.Utilities:MakeRangeOption(L["X"], MOD_KEY, "X", -2000, 2000, 1, update, {desc = L["XDesc"]}),
		addon.Utilities:MakeRangeOption(L["Y"], MOD_KEY, "Y", -1000, 1000, 1, update, {desc = L["YDesc"]}),
	}, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
	addon.Utilities:MakeOptionLineBreak(),
	-- combat indicator sound settings
	addon.Utilities:MakeOptionGroup(L["SoundSettings"], {
		addon.Utilities:MakeToggleOption(L["Mute"], MOD_KEY, "Mute"),
		addon.Utilities:MakeOptionLineBreak(),
		addon.Utilities:MakeLSMSoundOption(L["CombatInSoundMedia"], MOD_KEY, "InCombatSoundMeida", {hidden = function() return addon.db[MOD_KEY]["Mute"] end}),
		addon.Utilities:MakeLSMSoundOption(L["CombatOutSoundMedia"], MOD_KEY, "OutCombatSoundMedia", {hidden = function() return addon.db[MOD_KEY]["Mute"] end}),
	}, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
}, false, {order = addon:OptionOrderHandler(), desc = L["CombatSettingsDesc"]})
addon:AppendOptionsList("CombatIndicator", optionMap)