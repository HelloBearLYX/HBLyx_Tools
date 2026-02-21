local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "WarlockReminders"

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

-- MARK: Safe update
local function update()
	return addon.core:GetSafeUpdate(MOD_KEY)()
end

-- GUI
GUI.TagPanels.WarlockReminder = {}
function GUI.TagPanels.WarlockReminder:CreateTabPanel(parent)
	-- MARK: General
	local frame = GUI:CreateScrollFrame(parent)
	frame:SetLayout("Flow")

	GUI:CreateInformationTag(frame, L["WarlockWelecome"] .. "\n\n" .. L["WarlockRemindersIntro"], "LEFT")
	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["WarlockReminders"] .. "|r", addon.db.WarlockReminders.Enabled, function(value)
		addon.db.WarlockReminders.Enabled = value
		if addon.core:HasModuleLoaded(MOD_KEY) then -- if module is loaded
            if not value then -- user try to disable the module
                addon:ShowDialog(ADDON_NAME.."RLNeeded")
            end
        else -- if the module is not loaded yet
            if value then -- user try to enable the module, just load it without asking for reload, since it will be loaded immediately
                addon.core:LoadModule(MOD_KEY)
                addon.core:TestModule(MOD_KEY) -- the test mode will be on if the addon is in test mode
            end
        end
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
	GUI:CreateInformationTag(petTypeGroup, L["PetTypeSettingsDesc"], "LEFT")
	GUI:CreateToggleCheckBox(petTypeGroup, L["FelguardEnable"], addon.db.WarlockReminders.FelguardEnabled, function(value)
		addon.db.WarlockReminders.FelguardEnabled = value
	end)
	GUI:CreateToggleCheckBox(petTypeGroup, L["FelhunterEnable"], addon.db.WarlockReminders.FelhunterEnabled, function(value)
		addon.db.WarlockReminders.FelhunterEnabled = value
	end)
	-- MARK: Pet Texts
	local petTextGroup = GUI:CreateInlineGroup(petGroup, L["TextSettings"])
	GUI:CreateEditBox(petTextGroup, L["PetMissingTextSettings"], addon.db.WarlockReminders.PetMissingText, function(value)
		addon.db.WarlockReminders.PetMissingText = value
		update()
	end)
	GUI:CreateEditBox(petTextGroup, L["PetWrongTypeTextSettings"], addon.db.WarlockReminders.PetWrongTypeText, function(value)
		addon.db.WarlockReminders.PetWrongTypeText = value
		update()
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
	local candyTextGroup = GUI:CreateInlineGroup(candyGroup, L["TextSettings"])
	GUI:CreateEditBox(candyTextGroup, L["CandyMissingTextSettings"], addon.db.WarlockReminders.CandyMissingText, function(value)
		addon.db.WarlockReminders.CandyMissingText = value
		update()
	end)

	return frame
end