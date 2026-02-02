local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local MOD_KEY = "FocusInterrupt"

addon.LSM:Register("sound", ADDON_NAME.. "_FocusDefault", L["FocusDefaultSound"])

local function update()
    if addon.focusCastBar then
        addon.focusCastBar:UpdateStyle()
    end
end
local function RLNeeded()
	addon:ShowDialog(ADDON_NAME.."RLNeeded")
end

addon.configurationList[MOD_KEY] = {
    Enabled = true,
    Mute = true,
    SoundMedia = ADDON_NAME .. "_FocusDefault",
    CooldownHide = false,
    CooldownColor = "ffC41E3A",
    NotInterruptibleHide = true,
    NotInterruptibleColor = "ffFF7C0A",
    InterruptedColor = "ff828282",
    -- bar style settings
    Hidden = false,
    BackgroundAlpha = 0.3,
    Width = 280,
    Height = 30,
    Texture = "Solid",
    InterruptibleColor = "ff3fc7eb",
    Font = "",
    FontSize = 12,
    X = 0,
    Y = 170,
    IconZoom = 0.07,
}

local optionMap = addon.Utilities:MakeOptionGroup(L["FocusInterruptSettings"], {
    addon.Utilities:MakeToggleOption(L["Enable"], MOD_KEY, "Enabled", RLNeeded),
    -- focus cast bar settings
    addon.Utilities:MakeOptionGroup(L["FocusCastBarSettings"], {
        addon.Utilities:MakeToggleOption(L["FocusCastBarHidden"], MOD_KEY, "Hidden", nil, {desc = L["FocusCastBarHiddenDesc"]}),
        addon.Utilities:MakeOptionGroup(L["StyleSettings"], {
            addon.Utilities:MakeRangeOption(L["BackgroundAlpha"], MOD_KEY, "BackgroundAlpha", 0, 1, 0.01, update),
            addon.Utilities:MakeLSMTextureOption(L["Texture"], MOD_KEY, "Texture", update),
            addon.Utilities:MakeOptionLineBreak(),
            addon.Utilities:MakeRangeOption(L["X"], MOD_KEY, "X", -2000, 2000, 1, update, {desc = L["XDesc"]}),
            addon.Utilities:MakeRangeOption(L["Y"], MOD_KEY, "Y", -1000, 1000, 1, update, {desc = L["YDesc"]}),
            addon.Utilities:MakeOptionLineBreak(),
            addon.Utilities:MakeRangeOption(L["Width"], MOD_KEY, "Width", 50, 1000, 1, update),
            addon.Utilities:MakeRangeOption(L["Height"], MOD_KEY, "Height", 10, 200, 1, update),
            addon.Utilities:MakeOptionLineBreak(),
            addon.Utilities:MakeLSMFontOption(L["Font"], MOD_KEY, "Font", update),
            addon.Utilities:MakeRangeOption(L["FontSize"], MOD_KEY, "FontSize", 4, 40, 1, update),
            addon.Utilities:MakeColorOption(L["InterruptibleColor"], MOD_KEY, "InterruptibleColor", update, {desc = L["FocusColorPriorityDesc"]}),
            addon.Utilities:MakeColorOption(L["InterruptedColor"], MOD_KEY, "InterruptedColor", update),
            addon.Utilities:MakeRangeOption(L["IconZoom"], MOD_KEY, "IconZoom",0.01, 0.5, 0.01, update),
        }, true, {hidden = function () return addon.db[MOD_KEY]["Hidden"] end}),
    }, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
    addon.Utilities:MakeOptionGroup(L["FocusInteruptSettings"], {
        addon.Utilities:MakeToggleOption(L["FocusInterruptCooldownFilter"], MOD_KEY, "CooldownHide", nil, {desc = L["FocusInterruptCooldownFilterDesc"]}),
        addon.Utilities:MakeColorOption(L["FocusInterruptNotReadyColor"], MOD_KEY, "CooldownColor", update, {hidden = function () return addon.db[MOD_KEY]["CooldownHide"] end}),
        addon.Utilities:MakeOptionLineBreak(),
        addon.Utilities:MakeToggleOption(L["FocusInterruptibleFilter"], MOD_KEY, "NotInterruptibleHide", nil, {desc = L["FocusInterruptibleFilterDesc"]}),
        addon.Utilities:MakeColorOption(L["NotInterruptibleColor"], MOD_KEY, "NotInterruptibleColor", update, {hidden = function () return addon.db[MOD_KEY]["NotInterruptibleHide"] end}),
    }, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
    addon.Utilities:MakeOptionGroup(L["SoundSettings"], {
        {type = "description", name = L["FocusMuteDesc"]},
        addon.Utilities:MakeToggleOption("|cffC41E3A" .. L["Mute"] .. "|r", MOD_KEY, "Mute", nil, {desc = L["FocusMuteDesc"]}),
        addon.Utilities:MakeLSMSoundOption(L["Sound"], MOD_KEY, "SoundMedia", {desc = L["FocusInterruptSoundDesc"], hidden = function () return addon.db[MOD_KEY]["Mute"] end}),
    }, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
}, false, {order = addon:OptionOrderHandler(), desc = L["FocusInterruptSettingsDesc"]})
addon:AppendOptionsList("FocusInterruptCastBar", optionMap)