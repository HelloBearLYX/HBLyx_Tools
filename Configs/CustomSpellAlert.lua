local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local MOD_KEY = "CustomSpellAlert"

local function update()
	if addon.customSpellAlert then
		addon.customSpellAlert:UpdateStyle()
	end
end
local function RLNeeded()
	addon:ShowDialog(ADDON_NAME.."RLNeeded")
end

addon.configurationList[MOD_KEY] = {
	Enabled = true,
    DisplayNum = 6,
    Grow = "LEFT",
    IconSize = 30,
    IconZoom = 0.07,
    Spells = {},
    X = 0,
    Y = 0,
    TimeFontScale = 1,
}

local spellID, duration, cooldown = "", "", ""
local activeSound, afterCDSound = "", ""

-- options
local optionMap = addon.Utilities:MakeOptionGroup("CustomSpellAlertSettings", {
	addon.Utilities:MakeToggleOption(L["Enable"], MOD_KEY, "Enabled", RLNeeded, {desc = L["ReloadNeeded"]}),
    addon.Utilities:MakeResetOption(MOD_KEY, "CustomSpellAlertSettings"),
    addon.Utilities:MakeOptionGroup(L["StyleSettings"], {
        addon.Utilities:MakeRangeOption("Max Display Number", MOD_KEY, "DisplayNum", 1, 20, 1,update),
        addon.Utilities:MakeOptionLineBreak(),
        addon.Utilities:MakeRangeOption(L["IconSize"], MOD_KEY, "IconSize", 10, 200, 1, update),
        addon.Utilities:MakeRangeOption(L["IconZoom"], MOD_KEY, "IconZoom", 0.01, 0.5, 0.01, update),
        addon.Utilities:MakeOptionLineBreak(),
        addon.Utilities:MakeRangeOption(L["X"], MOD_KEY, "X", -2000, 2000, 1, update),
		addon.Utilities:MakeRangeOption(L["Y"], MOD_KEY, "Y", -1000, 1000, 1, update),
        addon.Utilities:MakeOptionLineBreak(),
        addon.Utilities:MakeRangeOption(L["TimeFontScale"], MOD_KEY, "TimeFontScale", 0.1, 5, 0.01, update),
    }, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
    addon.Utilities:MakeOptionGroup("Spells Settings", {
        addon.Utilities:MakeOptionGroup("Duration + Cooldown", {
            {type="input", name="SpellID", width=0.75, get=function (_)
                return spellID
            end, set= function (_, val)
                spellID =  val
            end},
            {type="input", name="Durtaion", width=0.75, get=function (_)
                return duration
            end, set= function (_, val)
                duration =  val
            end},
            {type="input", name="Cooldown", width=0.75, get=function (_)
                return cooldown
            end, set= function (_, val)
                cooldown =  val
            end},
            addon.Utilities:MakeLSMSoundOption("ActiveSound", MOD_KEY, "_", {get=function(_)return activeSound end, set=function(_,val) activeSound=val end, width=0.75}),
            addon.Utilities:MakeLSMSoundOption("AfterCDSound", MOD_KEY, "_", {get=function(_)return afterCDSound end, set=function(_,val) afterCDSound=val end, width=0.75}),
            addon.Utilities:MakeButtonOption("Add", function ()
                if addon.customSpellAlert:CreateIcon(spellID, duration, cooldown, activeSound, afterCDSound) then
                    -- update db
                    if addon.db[MOD_KEY]["Spells"] then
                        addon.db[MOD_KEY]["Spells"] = {}
                    end

                    addon.db[MOD_KEY]["Spells"]["duration"] = duration
                    addon.db[MOD_KEY]["Spells"]["cooldown"] = duration
                    addon.db[MOD_KEY]["Spells"]["activeSound"] = activeSound
                    addon.db[MOD_KEY]["Spells"]["afterCDSound"] = afterCDSound
                else
                    addon.Utilities:SetPopupDialog(ADDON_NAME .. "_InvalidInput", "Invalid Input", true)
                end
            end, {width=0.75}),
        }, true)
    }, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
}, false, {order = addon:OptionOrderHandler(), desc = L["TimerSettingsDesc"]})
addon:AppendOptionsList(MOD_KEY, optionMap)