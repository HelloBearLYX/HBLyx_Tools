local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "CombatIndicator"

-- Register sound media
addon.LSM:Register("sound", ADDON_NAME.. "_EnterCombat", L["CombatInSoundDefault"])
addon.LSM:Register("sound", ADDON_NAME.. "_LeaveCombat", L["CombatOutSoundDefault"])

-- MARK: Safe update
local function update()
	return addon.core:GetSafeUpdate(MOD_KEY)()
end

-- MARK: Defaults
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
	SoundChannel = "Master",
}

-- GUI
GUI.TagPanels.CombatIndicator = {}
function GUI.TagPanels.CombatIndicator:CreateTabPanel(parent)
	-- MARK: General
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

	-- Style Settings
	local styleGroup = GUI:CreateInlineGroup(frame, L["StyleSettings"])
	GUI:CreateSlider(styleGroup, L["FadeTime"], 0.5, 10, 0.5, addon.db.CombatIndicator.FadeTime, function(value)
		addon.db.CombatIndicator.FadeTime = value
		update()
	end)
	-- MARK: Font
	local fontGroup = GUI:CreateInlineGroup(styleGroup, L["FontSettings"])
	GUI:CreateFontSelect(fontGroup, L["Font"], addon.db.CombatIndicator.Font, function(value)
		addon.db.CombatIndicator.Font = value
		update()
	end)
	GUI:CreateSlider(fontGroup, L["FontSize"], 6, 40, 1, addon.db.CombatIndicator.FontSize, function(value)
		addon.db.CombatIndicator.FontSize = value
		update()
	end)
	-- MARK: Text
	local textGroup = GUI:CreateInlineGroup(styleGroup, L["TextSettings"])
	GUI:CreateInformationTag(textGroup, L["CombatIndicatorTextDesc"], "LEFT")
	GUI:CreateColorPicker(textGroup, L["CombatInColor"], true, addon.db.CombatIndicator.InCombatColor, function(value)
		addon.db.CombatIndicator.InCombatColor = value
	end)
	GUI:CreateColorPicker(textGroup, L["CombatOutColor"], true, addon.db.CombatIndicator.OutCombatColor, function(value)
		addon.db.CombatIndicator.OutCombatColor = value
	end)
	GUI:CreateInformationTag(textGroup, "\n", "LEFT")
	GUI:CreateEditBox(textGroup, L["CInText"], addon.db.CombatIndicator.InCombatText, function(value)
		addon.db.CombatIndicator.InCombatText = value
	end)
	GUI:CreateEditBox(textGroup, L["COutText"], addon.db.CombatIndicator.OutCombatText, function(value)
		addon.db.CombatIndicator.OutCombatText = value
	end)
	-- MARK: Position
	local positionGroup = GUI:CreateInlineGroup(styleGroup, L["PositionSettings"])
	GUI:CreateSlider(positionGroup, L["X"], -2000, 2000, 1, addon.db.CombatIndicator.X, function(value)
		addon.db.CombatIndicator.X = value
		update()
	end)
	GUI:CreateSlider(positionGroup, L["Y"], -1000, 1000, 1, addon.db.CombatIndicator.Y, function(value)
		addon.db.CombatIndicator.Y = value
		update()
	end)

	-- MARK: Sound
	local soundGroup = GUI:CreateInlineGroup(frame, L["SoundSettings"])
	GUI:CreateToggleCheckBox(soundGroup, L["Mute"], addon.db.CombatIndicator.Mute, function(value)
		addon.db.CombatIndicator.Mute = value
	end)
	GUI:CreateSoundSelect(soundGroup, L["CombatInSoundMedia"], addon.db.CombatIndicator.InCombatSoundMedia, function(value)
		addon.db.CombatIndicator.InCombatSoundMedia = value
	end)
	GUI:CreateSoundSelect(soundGroup, L["CombatOutSoundMedia"], addon.db.CombatIndicator.OutCombatSoundMedia, function(value)
		addon.db.CombatIndicator.OutCombatSoundMedia = value
	end)
	GUI:CreateDropDown(soundGroup, L["SoundChannelSettings"], addon.Utilities.SoundChannels, addon.db.CombatIndicator.SoundChannel, false, function(value)
        addon.db.CombatIndicator.SoundChannel = value
    end)

	return frame
end