local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "ChannelHelper"

-- MARK: Constants
-- keeps the same order/keys as the CHANNELS list in Modules/ChannelHelper.lua
local CHANNEL_DEFAULTS = {
	{channel = "say", color = "ffFFFFFF", short = "S"},
	{channel = "yell", color = "ffFF4040", short = "Y"},
	{channel = "party", color = "ffAAAAFF", short = "P"},
	{channel = "raid", color = "ffFF7F00", short = "R"},
	{channel = "raidwarning", color = "ffFF4040", short = "RW"},
	{channel = "guild", color = "ff40FF40", short = "G"},
	{channel = "custom", color = "ff8080FF", short = "C"},
	{channel = "roll", isIcon = true},
}

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = true,
	X = -970,
	Y = -215,
	FrameStrata = "MEDIUM",
	Vertical = false,
	ButtonHeight = 25,
	ButtonPadding = 10,
	ButtonSpacing = 5,
	Font = "",
	FontSize = 20,
	Command_custom = "",
}
for _, channel in ipairs(CHANNEL_DEFAULTS) do
	addon.configurationList[MOD_KEY]["Enabled_" .. channel.channel] = true
	if not channel.isIcon then
		addon.configurationList[MOD_KEY]["Text_" .. channel.channel] = channel.short
		addon.configurationList[MOD_KEY]["Color_" .. channel.channel] = channel.color
	end
end

-- MARK: Safe update
local function update()
	return addon.core:GetSafeUpdate(MOD_KEY)()
end

-- GUI
GUI.TagPanels.ChannelHelper = {}
function GUI.TagPanels.ChannelHelper:CreateTabPanel(parent)
	local frame = parent

	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["ChannelHelperSettings"] .. "|r", addon.db[MOD_KEY].Enabled, function(value)
		addon.db[MOD_KEY].Enabled = value
		if addon.core:HasModuleLoaded(MOD_KEY) then
			if not value then
				addon:ShowDialog(ADDON_NAME .. "RLNeeded")
			end
		else
			if value then
				addon.core:LoadModule(MOD_KEY)
				addon.core:TestModule(MOD_KEY)
				update()
			end
		end
	end)

	GUI:CreateResetModButton(frame, MOD_KEY, L["ChannelHelperSettings"])
	GUI:CreateInformationTag(frame, L["ChannelHelperSettingsDesc"], "LEFT")

	-- MARK: Style
	local styleGroup = GUI:CreateInlineGroup(frame, L["StyleSettings"])
    GUI:CreateToggleCheckBox(styleGroup, L["ChannelHelperVertical"], addon.db[MOD_KEY].Vertical, function(value)
		addon.db[MOD_KEY].Vertical = value
		update()
	end)
    GUI:CreateFrameStrataDropdown(styleGroup, addon.db[MOD_KEY].FrameStrata, function(value)
		addon.db[MOD_KEY].FrameStrata = value
		update()
	end)
    GUI:CreateLinebreaker(styleGroup)
	GUI:CreateSlider(styleGroup, L["Height"], 12, 60, 1, addon.db[MOD_KEY].ButtonHeight, function(value)
		addon.db[MOD_KEY].ButtonHeight = value
		update()
	end)
	GUI:CreateSlider(styleGroup, L["Width"], 0, 30, 1, addon.db[MOD_KEY].ButtonPadding, function(value)
		addon.db[MOD_KEY].ButtonPadding = value
		update()
	end)
	GUI:CreateSlider(styleGroup, L["ChannelHelperSpacing"], 0, 20, 1, addon.db[MOD_KEY].ButtonSpacing, function(value)
		addon.db[MOD_KEY].ButtonSpacing = value
		update()
	end)

	local fontGroup = GUI:CreateInlineGroup(styleGroup, L["FontSettings"])
	GUI:CreateFontSelect(fontGroup, L["Font"], addon.db[MOD_KEY].Font, function(value)
		addon.db[MOD_KEY].Font = value
		update()
	end)
	GUI:CreateSlider(fontGroup, L["FontSize"], 6, 40, 1, addon.db[MOD_KEY].FontSize, function(value)
		addon.db[MOD_KEY].FontSize = value
		update()
	end)

	local positionGroup = GUI:CreateInlineGroup(styleGroup, L["PositionSettings"])
	GUI:CreateSlider(positionGroup, L["X"], -2000, 2000, 1, addon.db[MOD_KEY].X, function(value)
		addon.db[MOD_KEY].X = value
		update()
	end)
	GUI:CreateSlider(positionGroup, L["Y"], -1000, 1000, 1, addon.db[MOD_KEY].Y, function(value)
		addon.db[MOD_KEY].Y = value
		update()
	end)

	-- MARK: Custom Channel
	local customGroup = GUI:CreateInlineGroup(frame, L["ChannelHelperCustomSettings"])
	GUI:CreateInformationTag(customGroup, L["ChannelHelperCustomSettingsDesc"], "LEFT")
	GUI:CreateEditBox(customGroup, L["ChannelHelperCustomCommand"], addon.db[MOD_KEY].Command_custom, function(value)
		addon.db[MOD_KEY].Command_custom = value
	end)

	-- MARK: Channels
	local channelsGroup = GUI:CreateInlineGroup(frame, L["ChannelHelperChannelsSettings"])
	for _, channel in ipairs(CHANNEL_DEFAULTS) do
		local key = channel.channel
		GUI:CreateToggleCheckBox(channelsGroup, L["ChannelHelperChannels"][key], addon.db[MOD_KEY]["Enabled_" .. key], function(value)
			addon.db[MOD_KEY]["Enabled_" .. key] = value
			update()
		end)
		if not channel.isIcon then
			GUI:CreateEditBox(channelsGroup, L["ChannelHelperText"], addon.db[MOD_KEY]["Text_" .. key], function(value)
				addon.db[MOD_KEY]["Text_" .. key] = value
				update()
			end)
			GUI:CreateColorPicker(channelsGroup, L["Color"], false, addon.db[MOD_KEY]["Color_" .. key], function(value)
				addon.db[MOD_KEY]["Color_" .. key] = value
				update()
			end)
		end
        GUI:CreateLinebreaker(channelsGroup)
	end

	return frame
end
