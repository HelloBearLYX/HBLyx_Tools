local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "WarlockReminders"

-- MARK: Safe update
local function update()
	if addon.warlockReminder then
		addon.warlockReminder:UpdateStyle()
	end
end
-- local function RLNeeded()
-- 	addon:ShowDialog(ADDON_NAME.."RLNeeded")
-- end

-- MARK: Defaults
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

-- MARK: Options (deprecated)
-- local optionMap = addon.Utilities:MakeOptionGroup(L["WarlockReminders"], {
-- 	addon.Utilities:MakeToggleOption(L["Enable"], MOD_KEY, "Enabled", RLNeeded, {desc = L["ReloadDesc"]}),
-- 	addon.Utilities:MakeResetOption(MOD_KEY, L["WarlockReminders"]),
-- 	-- warlock style settings
-- 	addon.Utilities:MakeOptionGroup(L["StyleSettings"],{
-- 		addon.Utilities:MakeRangeOption(L["IconSize"], MOD_KEY, "IconSize", 10, 200, 1, update),
-- 		addon.Utilities:MakeRangeOption(L["IconZoom"], MOD_KEY, "IconZoom",0.01, 0.5, 0.01, update),
-- 		addon.Utilities:MakeOptionLineBreak(),
-- 		addon.Utilities:MakeLSMFontOption(L["Font"]	, MOD_KEY, "Font", update),
-- 		addon.Utilities:MakeRangeOption(L["FontSize"], MOD_KEY, "FontSize", 6, 40, 1, update),
-- 	}, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
-- 	-- warlock pet settings
-- 	addon.Utilities:MakeOptionGroup(L["PetSettings"], {
-- 		addon.Utilities:MakeToggleOption(L["Enable"], MOD_KEY, "PetEnabled", RLNeeded, {desc = L["ReloadDesc"]}),
-- 		addon.Utilities:MakeToggleOption(L["PetStanceEnable"], MOD_KEY, "StanceEnabled", nil, {hidden = function() return not addon.db[MOD_KEY]["PetEnabled"] end, desc = L["ReloadDesc"]}),
-- 		-- warlock pet style settings
-- 		addon.Utilities:MakeOptionGroup(L["StyleSettings"], {
-- 			addon.Utilities:MakeRangeOption(L["X"], MOD_KEY, "PetX", -2000, 2000, 1, update),
-- 			addon.Utilities:MakeRangeOption(L["Y"], MOD_KEY, "PetY", -1000, 1000, 1, update),
-- 		}, true, {hidden = function() return not addon.db[MOD_KEY]["PetEnabled"] end}),
-- 		-- warlock pet type settings
-- 		addon.Utilities:MakeOptionGroup(L["PetTypeSettings"], {
-- 			addon.Utilities:MakeToggleOption(L["FelguardEnable"], MOD_KEY, "FelguardEnabled", nil, {desc = L["FelguardEnableDesc"]}),
-- 			addon.Utilities:MakeToggleOption(L["FelhunterEnable"], MOD_KEY, "FelhunterEnabled", nil, {desc = L["FelhunterEnableDesc"]}),
-- 		}, true, {hidden = function() return not addon.db[MOD_KEY]["PetEnabled"] end}),
-- 	}, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
-- 	-- warlock candy settings
-- 	addon.Utilities:MakeOptionGroup(L["CandySetting"], {
-- 		addon.Utilities:MakeToggleOption(L["Enable"], MOD_KEY, "CandyEnabled", RLNeeded, {desc = L["ReloadDesc"]}),
-- 		-- warlock candy style settings
-- 		addon.Utilities:MakeOptionGroup(L["StyleSettings"], {
-- 			addon.Utilities:MakeRangeOption(L["X"], MOD_KEY, "CandyX", -2000, 2000, 1, update),
-- 			addon.Utilities:MakeRangeOption(L["Y"], MOD_KEY, "CandyY", -1000, 1000, 1, update),
-- 		}, true, {hidden = function() return not addon.db[MOD_KEY]["CandyEnabled"] end}),
-- 	}, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
-- }, false, {order = addon:OptionOrderHandler()})
-- addon:AppendOptionsList("WarlockReminders", optionMap)

-- GUI
GUI.TagPanels.WarlockReminder = {}
function GUI.TagPanels.WarlockReminder:CreateTabPanel(parent)
	-- MARK: General
	local frame = GUI:CreateScrollFrame(parent)
	frame:SetLayout("Flow")

	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["WarlockReminders"] .. "|r", addon.db.WarlockReminders.Enabled, function(value)
		addon.db.WarlockReminders.Enabled = value
		addon:ShowDialog(ADDON_NAME.."RLNeeded")
	end)
	GUI:CreateButton(frame, L["ResetMod"], function()
		addon.Utilities:SetPopupDialog(
			ADDON_NAME .. "ResetMod",
			"|cffC41E3A" .. L["WarlockReminders"] .. "|r: " .. L["ComfirmResetMod"],
			true,
			{button1 = YES, button2 = NO, OnButton1 = function()
				addon.Utilities:ResetModule(MOD_KEY)
				ReloadUI()
			end}
		)
	end)

	-- Style Settings
	local styleGroup = GUI:CreateInlineGroup(frame, L["StyleSettings"])
	-- MARK: Icon
	local iconGroup = GUI:CreateInlineGroup(styleGroup, L["IconSettings"])
	GUI:CreateSlider(iconGroup, L["IconSize"], 10, 200, 1, addon.db.WarlockReminders.IconSize, function(value)
		addon.db.WarlockReminders.IconSize = value
		update()
	end)
	GUI:CreateSlider(iconGroup, L["IconZoom"], 0.01, 0.5, 0.01, addon.db.WarlockReminders.IconZoom, function(value)
		addon.db.WarlockReminders.IconZoom = value
		update()
	end)

	-- MARK: Font
	local fontGroup = GUI:CreateInlineGroup(styleGroup, L["FontSettings"])
	GUI:CreateFontSelect(fontGroup, L["Font"], addon.db.WarlockReminders.Font, function(value)
		addon.db.WarlockReminders.Font = value
		update()
	end)
	GUI:CreateSlider(fontGroup, L["FontSize"], 6, 40, 1, addon.db.WarlockReminders.FontSize, function(value)
		addon.db.WarlockReminders.FontSize = value
		update()
	end)

	-- MARK: Pet Settings
	local petGroup = GUI:CreateInlineGroup(frame, L["PetSettings"])
	GUI:CreateToggleCheckBox(petGroup, L["Enable"], addon.db.WarlockReminders.PetEnabled, function(value)
		addon.db.WarlockReminders.PetEnabled = value
		addon:ShowDialog(ADDON_NAME.."RLNeeded")
	end)
	GUI:CreateToggleCheckBox(petGroup, L["PetStanceEnable"], addon.db.WarlockReminders.StanceEnabled, function(value)
		addon.db.WarlockReminders.StanceEnabled = value
	end)
	-- MARK: Pet Position
	local petPositionGroup = GUI:CreateInlineGroup(petGroup, L["PositionSettings"])
	GUI:CreateSlider(petPositionGroup, L["X"], -2000, 2000, 1, addon.db.WarlockReminders.PetX, function(value)
		addon.db.WarlockReminders.PetX = value
		update()
	end)
	GUI:CreateSlider(petPositionGroup, L["Y"], -1000, 1000, 1, addon.db.WarlockReminders.PetY, function(value)
		addon.db.WarlockReminders.PetY = value
		update()
	end)

	-- MARK: Pet Type
	local petTypeGroup = GUI:CreateInlineGroup(petGroup, L["PetTypeSettings"])
	GUI:CreateToggleCheckBox(petTypeGroup, L["FelguardEnable"], addon.db.WarlockReminders.FelguardEnabled, function(value)
		addon.db.WarlockReminders.FelguardEnabled = value
	end)
	GUI:CreateToggleCheckBox(petTypeGroup, L["FelhunterEnable"], addon.db.WarlockReminders.FelhunterEnabled, function(value)
		addon.db.WarlockReminders.FelhunterEnabled = value
	end)

	-- MARK: Candy Settings
	local candyGroup = GUI:CreateInlineGroup(frame, L["CandySetting"])
	GUI:CreateToggleCheckBox(candyGroup, L["Enable"], addon.db.WarlockReminders.CandyEnabled, function(value)
		addon.db.WarlockReminders.CandyEnabled = value
		addon:ShowDialog(ADDON_NAME.."RLNeeded")
	end)
	-- MARK: Candy Position
	local candyPositionGroup = GUI:CreateInlineGroup(candyGroup, L["PositionSettings"])
	GUI:CreateSlider(candyPositionGroup, L["X"], -2000, 2000, 1, addon.db.WarlockReminders.CandyX, function(value)
		addon.db.WarlockReminders.CandyX = value
		update()
	end)
	GUI:CreateSlider(candyPositionGroup, L["Y"], -1000, 1000, 1, addon.db.WarlockReminders.CandyY, function(value)
		addon.db.WarlockReminders.CandyY = value
		update()
	end)

	return frame
end