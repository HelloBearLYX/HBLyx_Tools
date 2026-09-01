local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "Countdown"

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = false,
	X = 0,
	Y = 50,
	Font = "",
	FontSize = 50,
    FontColor = "FFC41E3A", -- red
    FiveSound = "None",
    FourSound = "None",
    ThreeSound = "None",
    TwoSound = "None",
    OneSound = "None",
	VictorySound = "None",
    SoundChannel = "Master",
	StartSound = "[HBLyx] Notification",
}

-- MARK: Safe update

local function update()
	return addon.core:GetSafeUpdate(MOD_KEY)()
end

-- GUI
GUI.TagPanels.Countdown = {}
function GUI.TagPanels.Countdown:CreateTabPanel(parent)
	-- MARK: General
	local frame = GUI:CreateScrollFrame(parent)

	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["CountdownSettings"] .. "|r", addon.db.Countdown.Enabled, function(value)
		addon.db.Countdown.Enabled = value
		if addon.core:HasModuleLoaded(MOD_KEY) then -- if module is loaded
			if not value then -- user try to disable the module
				addon:ShowDialog(ADDON_NAME .. "RLNeeded")
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
			"|cffC41E3A" .. L["CountdownSettings"] .. "|r: " .. L["ComfirmResetMod"],
			true,
			{ button1 = YES, button2 = NO, OnButton1 = function()
				addon.Utilities:ResetModule(MOD_KEY)
				ReloadUI()
			end }
		)
	end)

	-- MARK: Style
	local styleGroup = GUI:CreateInlineGroup(frame, L["StyleSettings"])

	-- MARK: Position
	local positionGroup = GUI:CreateInlineGroup(styleGroup, L["PositionSettings"])
	GUI:CreateSlider(positionGroup, L["X"], -2000, 2000, 1, addon.db.Countdown.X, function(value)
		addon.db.Countdown.X = value
		update()
	end)
	GUI:CreateSlider(positionGroup, L["Y"], -1000, 1000, 1, addon.db.Countdown.Y, function(value)
		addon.db.Countdown.Y = value
		update()
	end)

	-- MARK: Font
	local fontGroup = GUI:CreateInlineGroup(styleGroup, L["FontSettings"])
	GUI:CreateFontSelect(fontGroup, L["Font"], addon.db.Countdown.Font, function(value)
		addon.db.Countdown.Font = value
		update()
	end)
	GUI:CreateSlider(fontGroup, L["FontSize"], 10, 240, 1, addon.db.Countdown.FontSize, function(value)
		addon.db.Countdown.FontSize = value
		update()
	end)
    GUI:CreateColorPicker(fontGroup, L["Color"], true, addon.db.Countdown.FontColor, function(value)
        addon.db.Countdown.FontColor = value
        update()
    end)

    -- MARK: Sound
    local soundGroup = GUI:CreateInlineGroup(frame, L["SoundSettings"])
    GUI:CreateDropdown(soundGroup, L["SoundChannelSettings"], addon.Utilities.SoundChannels, nil, addon.db.Countdown.SoundChannel, function(key)
        addon.db.Countdown.SoundChannel = key
    end)
	GUI:CreateSoundSelect(soundGroup, L["ActiveSound"], addon.db.Countdown.StartSound, function(value)
        addon.db.Countdown.StartSound = value
    end)
	GUI:CreateSoundSelect(soundGroup, L["VictorySound"], addon.db.Countdown.VictorySound, function(value)
		addon.db.Countdown.VictorySound = value
	end)
    GUI:CreateInformationTag(soundGroup, "\n")
    GUI:CreateSoundSelect(soundGroup, "5", addon.db.Countdown.FiveSound, function(value)
        addon.db.Countdown.FiveSound = value
    end):SetRelativeWidth(0.19)
    GUI:CreateSoundSelect(soundGroup, "4", addon.db.Countdown.FourSound, function(value)
        addon.db.Countdown.FourSound = value
    end):SetRelativeWidth(0.19)
    GUI:CreateSoundSelect(soundGroup, "3", addon.db.Countdown.ThreeSound, function(value)
        addon.db.Countdown.ThreeSound = value
    end):SetRelativeWidth(0.19)
    GUI:CreateSoundSelect(soundGroup, "2", addon.db.Countdown.TwoSound, function(value)
        addon.db.Countdown.TwoSound = value
    end):SetRelativeWidth(0.19)
    GUI:CreateSoundSelect(soundGroup, "1", addon.db.Countdown.OneSound, function(value)
        addon.db.Countdown.OneSound = value
    end):SetRelativeWidth(0.19)

	return frame
end
