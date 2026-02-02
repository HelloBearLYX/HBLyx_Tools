local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local MOD_KEY = "WarlockReminders"

local function update()
	if addon.warlockReminder then
		addon.warlockReminder:UpdateStyle()
	end
end
local function RLNeeded()
	addon:ShowDialog(ADDON_NAME.."RLNeeded")
end

addon.configurationList[MOD_KEY] = {
	Enabled = true,
	Font = "",
	FontSize = 12,
	IconSize = 45,
	IconZoom = 0.07,
	-- pet settings
	PetEnabled = true,
	PetMissingText = L["PetMissingText"],
	StanceEnabled = true,
	FelguardEnabled = true,
	FelhunterEnabled = true,
	PetWrongTypeText = L["PetFamily"]["WRONG"],
	PetX = 0,
	PetY = 300,
	-- candy settings
	CandyEnabled = true,
	CandyMissingText = L["CandyMissingText"],
	CandyX = 0,
	CandyY = 350,
}

local optionMap = addon.Utilities:MakeOptionGroup(L["WarlockReminders"], {
	addon.Utilities:MakeToggleOption(L["Enable"], MOD_KEY, "Enabled", RLNeeded, {desc = L["ReloadDesc"]}),
	-- warlock style settings
	addon.Utilities:MakeOptionGroup(L["StyleSettings"],{
		addon.Utilities:MakeRangeOption(L["IconSize"], MOD_KEY, "IconSize", 10, 200, 1, update),
		addon.Utilities:MakeRangeOption(L["IconZoom"], MOD_KEY, "IconZoom",0.01, 0.5, 0.01, update),
		addon.Utilities:MakeOptionLineBreak(),
		addon.Utilities:MakeLSMFontOption(L["Font"]	, MOD_KEY, "Font", update),
		addon.Utilities:MakeRangeOption(L["FontSize"], MOD_KEY, "FontSize", 6, 40, 1, update),
	}, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
	-- warlock pet settings
	addon.Utilities:MakeOptionGroup(L["PetSettings"], {
		addon.Utilities:MakeToggleOption(L["Enable"], MOD_KEY, "PetEnabled", RLNeeded, {desc = L["ReloadDesc"]}),
		addon.Utilities:MakeToggleOption(L["PetStanceEnable"], MOD_KEY, "StanceEnabled", nil, {hidden = function() return not addon.db[MOD_KEY]["PetEnabled"] end, desc = L["ReloadDesc"]}),
		-- warlock pet style settings
		addon.Utilities:MakeOptionGroup(L["StyleSettings"], {
			addon.Utilities:MakeRangeOption(L["X"], MOD_KEY, "PetX", -2000, 2000, 1, update),
			addon.Utilities:MakeRangeOption(L["Y"], MOD_KEY, "PetY", -1000, 1000, 1, update),
		}, true, {hidden = function() return not addon.db[MOD_KEY]["PetEnabled"] end}),
		-- warlock pet type settings
		addon.Utilities:MakeOptionGroup(L["PetTypeSettings"], {
			addon.Utilities:MakeToggleOption(L["FelguardEnable"], MOD_KEY, "FelguardEnabled", nil, {desc = L["FelguardEnableDesc"]}),
			addon.Utilities:MakeToggleOption(L["FelhunterEnable"], MOD_KEY, "FelhunterEnabled", nil, {desc = L["FelhunterEnableDesc"]}),
		}, true, {hidden = function() return not addon.db[MOD_KEY]["PetEnabled"] end}),
	}, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
	-- warlock candy settings
	addon.Utilities:MakeOptionGroup(L["CandySetting"], {
		addon.Utilities:MakeToggleOption(L["Enable"], MOD_KEY, "CandyEnabled", RLNeeded, {desc = L["ReloadDesc"]}),
		-- warlock candy style settings
		addon.Utilities:MakeOptionGroup(L["StyleSettings"], {
			addon.Utilities:MakeRangeOption(L["X"], MOD_KEY, "CandyX", -2000, 2000, 1, update),
			addon.Utilities:MakeRangeOption(L["Y"], MOD_KEY, "CandyY", -1000, 1000, 1, update),
		}, true, {hidden = function() return not addon.db[MOD_KEY]["CandyEnabled"] end}),
	}, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
}, false, {order = addon:OptionOrderHandler()})
addon:AppendOptionsList("WarlockReminders", optionMap)