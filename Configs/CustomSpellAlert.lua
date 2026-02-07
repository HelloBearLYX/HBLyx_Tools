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
local function List()
    return addon.customSpellAlert:GetSpellsList()
end

addon.configurationList[MOD_KEY] = {
	Enabled = true,
    Grow = "LEFT",
    IconSize = 30,
    IconZoom = 0.07,
    Spells = {},
    X = 0,
    Y = 0,
    TimeFontScale = 1,
}

local selectedSpell = ""
local spellID, duration, cooldown = "", "", ""
local activeSound, afterCDSound = "", ""

-- options
local optionMap = addon.Utilities:MakeOptionGroup("CustomSpellAlertSettings", {
	addon.Utilities:MakeToggleOption(L["Enable"], MOD_KEY, "Enabled", RLNeeded, {desc = L["ReloadNeeded"]}),
    addon.Utilities:MakeResetOption(MOD_KEY, "CustomSpellAlertSettings"),
    addon.Utilities:MakeOptionGroup(L["StyleSettings"], {
        addon.Utilities:MakeRangeOption(L["IconSize"], MOD_KEY, "IconSize", 10, 200, 1, update),
        addon.Utilities:MakeRangeOption(L["IconZoom"], MOD_KEY, "IconZoom", 0.01, 0.5, 0.01, update),
        addon.Utilities:MakeOptionLineBreak(),
        addon.Utilities:MakeRangeOption(L["X"], MOD_KEY, "X", -2000, 2000, 1, update),
		addon.Utilities:MakeRangeOption(L["Y"], MOD_KEY, "Y", -1000, 1000, 1, update),
        addon.Utilities:MakeOptionLineBreak(),
        addon.Utilities:MakeRangeOption(L["TimeFontScale"], MOD_KEY, "TimeFontScale", 0.1, 5, 0.01, update),
    }, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
    addon.Utilities:MakeOptionGroup("Spells Settings", {
        {type="select", name="SavedSpells", values=List,get=function(_)
            return selectedSpell
        end, set=function(_, id)
            selectedSpell = id
            addon.Utilities:print("type: " .. type(id))
            spellID = id
            duration, cooldown, activeSound, afterCDSound = addon.customSpellAlert(id)
        end},
        addon.Utilities:MakeButtonOption("Add", function ()
            local id, dur, cd = tonumber(spellID), tonumber(duration), tonumber(cooldown)

            if addon.customSpellAlert:AddSpell(id, dur, cd, activeSound, afterCDSound) then
                addon.db[MOD_KEY]["Spells"][id] = {}
                addon.db[MOD_KEY]["Spells"][id]["duration"] = dur
                addon.db[MOD_KEY]["Spells"][id]["cooldown"] = cd
                addon.db[MOD_KEY]["Spells"][id]["activeSound"] = activeSound
                addon.db[MOD_KEY]["Spells"][id]["afterCDSound"] = afterCDSound
            else
                addon.Utilities:SetPopupDialog(ADDON_NAME .. "_InvalidInput", "Invalid Input", true)
            end
        end, {width=0.5}),
        addon.Utilities:MakeButtonOption("Delete", function ()
            local id = tonumber(selectedSpell)
            if addon.customSpellAlert:DeleteSpell(id) then
                addon.db[MOD_KEY]["Spells"][id]= nil
            else
                addon.Utilities:SetPopupDialog(ADDON_NAME .. "_InvalidInput", "Invalid Input", true)
            end
        end, {width=0.5}),
        {type="input", name="SpellID", width=0.75, get=function (_)
            return spellID
        end, set= function (_, val)
            spellID =  val
        end},
        {type="input", name="Duration", width=0.75, get=function (_)
            return duration
        end, set= function (_, val)
            duration =  val
        end},
        {type="input", name="Cooldown", width=0.75, get=function (_)
            return cooldown
        end, set= function (_, val)
            cooldown =  val
        end},
        addon.Utilities:MakeLSMSoundOption("ActiveSound", MOD_KEY, "_", {get=function(_)return activeSound end, set=function(_,val) activeSound=val end}),
        addon.Utilities:MakeLSMSoundOption("AfterCDSound", MOD_KEY, "_", {get=function(_)return afterCDSound end, set=function(_,val) afterCDSound=val end}),
        addon.Utilities:MakeOptionLineBreak(),
    }, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end})
}, false, {order = addon:OptionOrderHandler(), desc = L["TimerSettingsDesc"]})
addon:AppendOptionsList(MOD_KEY, optionMap)