local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "BattleRes"

local function update()
	if addon.battleRes then
		addon.battleRes:UpdateStyle()
	end
end

addon.configurationList[MOD_KEY] = {
	Enabled = true,
	Font = "",
	HideInactive = true,
	TimeFontScale = 1,
	ChargeFontSize = 14,
	X = -230,
	Y = -260,
	IconSize = 35,
	IconZoom = 0.07,
}

-- options
-- local optionMap = addon.Utilities:MakeOptionGroup(L["BattleResSettings"], {
--     addon.Utilities:MakeToggleOption(L["Enable"], MOD_KEY, "Enabled", RLNeeded, {desc = L["ReloadNeeded"]}),
-- 	addon.Utilities:MakeResetOption(MOD_KEY, L["BattleResSettings"]),
-- 	addon.Utilities:MakeOptionLineBreak(),
-- 	addon.Utilities:MakeToggleOption(L["HidenInactive"], MOD_KEY, "HideInactive", nil, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
-- 	addon.Utilities:MakeOptionGroup(L["StyleSettings"], {
-- 		addon.Utilities:MakeRangeOption(L["IconSize"], MOD_KEY, "IconSize", 10, 200, 1, update),
-- 		addon.Utilities:MakeRangeOption(L["IconZoom"], MOD_KEY, "IconZoom",0.01, 0.5, 0.01, update),
-- 		addon.Utilities:MakeOptionLineBreak(),
-- 		addon.Utilities:MakeRangeOption(L["X"], MOD_KEY, "X", -2000, 2000, 1, update),
-- 		addon.Utilities:MakeRangeOption(L["Y"], MOD_KEY, "Y", -1000, 1000, 1, update),
-- 		addon.Utilities:MakeOptionLineBreak(),
-- 		addon.Utilities:MakeRangeOption(L["TimeFontScale"], MOD_KEY, "TimeFontScale", 0.1, 5, 0.01, update),
-- 		addon.Utilities:MakeOptionLineBreak(),
-- 		addon.Utilities:MakeLSMFontOption(L["Font"], MOD_KEY, "Font", update),
-- 		addon.Utilities:MakeRangeOption(L["StackFontSize"], MOD_KEY, "ChargeFontSize", 6, 40, 1, update),
-- 	}, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
-- }, false, {order = addon:OptionOrderHandler(), desc = L["BattleResSettingsDesc"]})
-- addon:AppendOptionsList("BattleRes", optionMap)

-- GUI
GUI.TagPanels.BattleRes = {}
function GUI.TagPanels.BattleRes:CreateTabPanel(parent)
	local frame = GUI:CreateScrollFrame(parent)
	frame:SetLayout("Flow")
	frame:SetFullWidth(true)
	
	GUI:CreateInformationTag(frame, L["BattleResSettingsDesc"], "LEFT")
	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["BattleResSettings"] .. "|r", addon.db.BattleRes.Enabled, function(value)
		addon.db.BattleRes.Enabled = value
		addon:ShowDialog(ADDON_NAME.."RLNeeded")
	end)
	GUI:CreateButton(frame, L["ResetMod"], function ()
		addon.Utilities:SetPopupDialog(
			ADDON_NAME .. "ResetMod",
			"|cffC41E3A" .. L["BattleResSettings"] .. "|r: " .. L["ComfirmResetMod"],
			true,
			{button1 = YES, button2 = NO, OnButton1 = function ()
		    	addon.Utilities:ResetModule(MOD_KEY)
				ReloadUI()
			end}
		)
	end)

	GUI:CreateHeader(frame, L["StyleSettings"])
	GUI:CreateSlider(frame, L["IconSize"], 10, 200, 1, addon.db.BattleRes.IconSize, function(value)
		addon.db.BattleRes.IconSize = value
		update()
	end)
	GUI:CreateSlider(frame, L["IconZoom"], 0.01, 0.5, 0.01, addon.db.BattleRes.IconZoom, function(value)
		addon.db.BattleRes.IconZoom = value
		update()
	end)
	GUI:CreateSlider(frame, L["X"], -2000, 2000, 1, addon.db.BattleRes.X, function(value)
		addon.db.BattleRes.X = value
		update()
	end)
	GUI:CreateSlider(frame, L["Y"], -1000, 1000, 1, addon.db.BattleRes.Y, function(value)
		addon.db.BattleRes.Y = value
		update()
	end)
	GUI:CreateFontSelect(frame, L["Font"], addon.db.BattleRes.Font, function(value)
		addon.db.BattleRes.Font = value
		update()
	end)
	GUI:CreateSlider(frame, L["TimeFontScale"], 0.1, 5, 0.01, addon.db.BattleRes.TimeFontScale, function(value)
		addon.db.BattleRes.TimeFontScale = value
		update()
	end)
	GUI:CreateSlider(frame, L["StackFontSize"], 6, 40, 1, addon.db.BattleRes.ChargeFontSize, function(value)
		addon.db.BattleRes.ChargeFontSize = value
		update()
	end)

	parent:AddChild(frame)
	return frame
end