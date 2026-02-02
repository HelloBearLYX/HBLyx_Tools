local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local MOD_KEY = "ChallengeEnhance"

local function update()
    if addon.challengeEnhance then
        addon.challengeEnhance:UpdateStyle()
    end
end
local function RLNeeded()
	addon:ShowDialog(ADDON_NAME.."RLNeeded")
end

-- configs
addon.configurationList[MOD_KEY] = {
    Enabled = true,
    Font = "",
    -- level settings
    LevelEnabled = true,
    LevelFontSize = 20,
    LevelX = 0,
    LevelY = -1,
    -- score settings
    ScoreEnabled = true,
    ScoreFontSize = 20,
    ScoreX = 0,
    ScoreY = -5,
    -- name settings
    NameEnabled = true,
    NameFontSize = 12,
    NameX = 0,
    NameY = 2,
}

-- options
local optionMap = addon.Utilities:MakeOptionGroup(L["ChallengeEnhanceSettings"], {
    addon.Utilities:MakeToggleOption(L["Enable"], MOD_KEY, "Enabled", RLNeeded, {desc = L["ReloadDesc"]}),
    addon.Utilities:MakeLSMFontOption(L["Font"], MOD_KEY, "Font", update, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
    addon.Utilities:MakeOptionGroup(L["ChallengeEnhanceLevelSettings"], {
        addon.Utilities:MakeToggleOption(L["Enable"], MOD_KEY, "LevelEnabled", update),
        addon.Utilities:MakeRangeOption(L["FontSize"], MOD_KEY, "LevelFontSize", 6, 40, 1, update, {hidden = function() return not addon.db[MOD_KEY]["LevelEnabled"] end}),
        addon.Utilities:MakeRangeOption(L["X"], MOD_KEY, "LevelX", -50, 50, 1, update, {hidden = function() return not addon.db[MOD_KEY]["LevelEnabled"] end}),
        addon.Utilities:MakeRangeOption(L["Y"], MOD_KEY, "LevelY", -50, 50, 1, update, {hidden = function() return not addon.db[MOD_KEY]["LevelEnabled"] end}),
    }, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
    addon.Utilities:MakeOptionGroup(L["ChallengeEnhanceScoreSettings"], {
        addon.Utilities:MakeToggleOption(L["Enable"], MOD_KEY, "ScoreEnabled", update),
        addon.Utilities:MakeRangeOption(L["FontSize"], MOD_KEY, "ScoreFontSize", 6, 40, 1, update, {hidden = function() return not addon.db[MOD_KEY]["ScoreEnabled"] end}),
        addon.Utilities:MakeRangeOption(L["X"], MOD_KEY, "ScoreX", -50, 50, 1, update, {hidden = function() return not addon.db[MOD_KEY]["ScoreEnabled"] end}),
        addon.Utilities:MakeRangeOption(L["Y"], MOD_KEY, "ScoreY", -50, 50, 1, update, {hidden = function() return not addon.db[MOD_KEY]["ScoreEnabled"] end}),
    }, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
    addon.Utilities:MakeOptionGroup(L["ChallengeEnhanceNameSettings"], {        
        addon.Utilities:MakeToggleOption(L["Enable"], MOD_KEY, "NameEnabled", update),
        addon.Utilities:MakeRangeOption(L["FontSize"], MOD_KEY, "NameFontSize", 6, 40, 1, update, {hidden = function() return not addon.db[MOD_KEY]["NameEnabled"] end}),
        addon.Utilities:MakeRangeOption(L["X"], MOD_KEY, "NameX", -50, 50, 1, update, {hidden = function() return not addon.db[MOD_KEY]["NameEnabled"] end}),
        addon.Utilities:MakeRangeOption(L["Y"], MOD_KEY, "NameY", -50, 50, 1, update, {hidden = function() return not addon.db[MOD_KEY]["NameEnabled"] end}),
    }, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
}, false, {order = addon:OptionOrderHandler(), desc = L["ChallengeEnhanceSettingsDesc"]})
addon:AppendOptionsList("ChallengeEnhance", optionMap)