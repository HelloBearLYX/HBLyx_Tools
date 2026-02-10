local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "CombatIndicator"

addon.LSM:Register("sound", ADDON_NAME.. "_EnterCombat", L["CombatInSoundDefault"])
addon.LSM:Register("sound", ADDON_NAME.. "_LeaveCombat", L["CombatOutSoundDefault"])

local function update()
	if addon.combatIndicator then
		addon.combatIndicator:UpdateStyle()
	end
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
	InCombatSoundMedia = ADDON_NAME.. "_EnterCombat",
	OutCombatSoundMedia = ADDON_NAME.. "_LeaveCombat",
}

-- options
-- local optionMap = addon.Utilities:MakeOptionGroup(L["CombatSettings"], {
-- 	addon.Utilities:MakeToggleOption(L["Enable"], MOD_KEY, "Enabled", RLNeeded),
-- 	addon.Utilities:MakeResetOption(MOD_KEY, L["CombatSettings"]),
-- 	-- combat indicator style settings
-- 	addon.Utilities:MakeOptionGroup(L["StyleSettings"],{
-- 		addon.Utilities:MakeRangeOption(L["FadeTime"], MOD_KEY, "FadeTime", 0.5, 10, 0.5, nil, {desc = L["CombatFadeTimeDesc"]}),
-- 		addon.Utilities:MakeOptionLineBreak(),
-- 		addon.Utilities:MakeLSMFontOption(L["Font"]	, MOD_KEY, "Font", update),
-- 		addon.Utilities:MakeRangeOption(L["FontSize"], MOD_KEY, "FontSize", 6, 40, 1, update),
-- 		addon.Utilities:MakeOptionLineBreak(),
-- 		addon.Utilities:MakeColorOption(L["CombatInColor"], MOD_KEY, "InCombatColor", update),
-- 		addon.Utilities:MakeColorOption(L["CombatOutColor"], MOD_KEY, "OutCombatColor", update),
-- 		addon.Utilities:MakeOptionLineBreak(),
-- 		addon.Utilities:MakeInputOption(L["CInText"], MOD_KEY, "InCombatText"),
-- 		addon.Utilities:MakeInputOption(L["COutText"], MOD_KEY, "OutCombatText"),
-- 		addon.Utilities:MakeOptionLineBreak(),
-- 		addon.Utilities:MakeRangeOption(L["X"], MOD_KEY, "X", -2000, 2000, 1, update, {desc = L["XDesc"]}),
-- 		addon.Utilities:MakeRangeOption(L["Y"], MOD_KEY, "Y", -1000, 1000, 1, update, {desc = L["YDesc"]}),
-- 	}, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
-- 	addon.Utilities:MakeOptionLineBreak(),
-- 	-- combat indicator sound settings
-- 	addon.Utilities:MakeOptionGroup(L["SoundSettings"], {
-- 		addon.Utilities:MakeToggleOption(L["Mute"], MOD_KEY, "Mute"),
-- 		addon.Utilities:MakeOptionLineBreak(),
-- 		addon.Utilities:MakeLSMSoundOption(L["CombatInSoundMedia"], MOD_KEY, "InCombatSoundMedia", {hidden = function() return addon.db[MOD_KEY]["Mute"] end}),
-- 		addon.Utilities:MakeLSMSoundOption(L["CombatOutSoundMedia"], MOD_KEY, "OutCombatSoundMedia", {hidden = function() return addon.db[MOD_KEY]["Mute"] end}),
-- 	}, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
-- }, false, {order = addon:OptionOrderHandler(), desc = L["CombatSettingsDesc"]})
-- addon:AppendOptionsList("CombatIndicator", optionMap)

--GUI
GUI.TagPanels.CombatIndicator = {}
function GUI.TagPanels.CombatIndicator:CreateTabPanel(parent)
	local frame = GUI:CreateScrollFrame(parent)
	frame:SetLayout("Flow")
	GUI:CreateInformationTag(frame, L["CombatSettingsDesc"], "LEFT")
	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["CombatSettings"] .. "|r", addon.db.CombatIndicator.Enabled, function(value)
		addon.db.CombatIndicator.Enabled = value
		addon:ShowDialog(ADDON_NAME.."RLNeeded")
	end)
	GUI:CreateButton(frame, L["ResetMod"], function ()
        addon.Utilities:SetPopupDialog(
            ADDON_NAME .. "ResetMod",
            "|cffC41E3A" .. L["CombatSettings"] .. "|r: " .. L["ComfirmResetMod"],
            true,
            {button1 = YES, button2 = NO, OnButton1 = function ()
                addon.Utilities:ResetModule(MOD_KEY)
                ReloadUI()
            end}
        )
	end)

	GUI:CreateHeader(frame, L["StyleSettings"])
	GUI:CreateFontSelect(frame, L["Font"], addon.db.CombatIndicator.Font, function(value)
		addon.db.CombatIndicator.Font = value
		update()
	end)
	GUI:CreateSlider(frame, L["FontSize"], 6, 40, 1, addon.db.CombatIndicator.FontSize, function(value)
		addon.db.CombatIndicator.FontSize = value
		update()
	end)
	GUI:CreateSlider(frame, L["FadeTime"], 0.5, 10, 0.5, addon.db.CombatIndicator.FadeTime, function(value)
		addon.db.CombatIndicator.FadeTime = value
		update()
	end)
	GUI:CreateColorPicker(frame, L["CombatInColor"], true, addon.db.CombatIndicator.InCombatColor, function(value)
		addon.db.CombatIndicator.InCombatColor = value
	end)
	GUI:CreateColorPicker(frame, L["CombatOutColor"], true, addon.db.CombatIndicator.OutCombatColor, function(value)
		addon.db.CombatIndicator.OutCombatColor = value
	end)
	GUI:CreateEditBox(frame, L["CInText"], addon.db.CombatIndicator.InCombatText, function(value)
		addon.db.CombatIndicator.InCombatText = value
	end)
	GUI:CreateEditBox(frame, L["COutText"], addon.db.CombatIndicator.OutCombatText, function(value)
		addon.db.CombatIndicator.OutCombatText = value
	end)
	GUI:CreateSlider(frame, L["X"], -2000, 2000, 1, addon.db.CombatIndicator.X, function(value)
		addon.db.CombatIndicator.X = value
		update()
	end)
	GUI:CreateSlider(frame, L["Y"], -1000, 1000, 1, addon.db.CombatIndicator.Y, function(value)
		addon.db.CombatIndicator.Y = value
		update()
	end)

	GUI:CreateHeader(frame, L["SoundSettings"])
	GUI:CreateToggleCheckBox(frame, L["Mute"], addon.db.CombatIndicator.Mute, function(value)
		addon.db.CombatIndicator.Mute = value
	end)
	GUI:CreateSoundSelect(frame, L["CombatInSoundMedia"], addon.db.CombatIndicator.InCombatSoundMedia, function(value)
		addon.db.CombatIndicator.InCombatSoundMedia = value
	end)
	GUI:CreateSoundSelect(frame, L["CombatOutSoundMedia"], addon.db.CombatIndicator.OutCombatSoundMedia, function(value)
		addon.db.CombatIndicator.OutCombatSoundMedia = value
	end)

	parent:AddChild(frame)
	return frame
end