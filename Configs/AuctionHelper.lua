local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "AuctionHelper"

-- MARK: Safe update
local function update()
	return addon.core:GetSafeUpdate(MOD_KEY)()
end

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = true,
	ButtonSize = 40,
	GlobalScale = 1,
	FrameOffsetX = 5,
	FrameOffsetY = 0,

}

-- GUI
local function RenderPanel(parent)
	-- MARK: General
	local frame = parent

	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["AuctionHelperSettings"] .. "|r", addon.db.AuctionHelper.Enabled, function(value)
		addon.db.AuctionHelper.Enabled = value
		addon.core:ToggleModule(MOD_KEY, value)
	end)

	GUI:CreateResetModButton(frame, MOD_KEY, L["AuctionHelperSettings"])

	local styleGroup = GUI:CreateInlineGroup(frame, L["StyleSettings"])
	GUI:CreateSlider(styleGroup, L["Scale"], 0.1, 5.0, 0.01, addon.db.AuctionHelper.GlobalScale or 1, function(value)
		addon.db.AuctionHelper.GlobalScale = value
		update()
	end)
	GUI:CreateSlider(styleGroup, L["IconSize"], 20, 50, 1, addon.db.AuctionHelper.ButtonSize, function(value)
		addon.db.AuctionHelper.ButtonSize = value
		update()
	end)

	local positionGroup = GUI:CreateInlineGroup(styleGroup, L["PositionSettings"])
	GUI:CreateSlider(positionGroup, L["X"], -200, 200, 1, addon.db.AuctionHelper.FrameOffsetX or 5, function(value)
		addon.db.AuctionHelper.FrameOffsetX = value
		update()
	end)
	GUI:CreateSlider(positionGroup, L["Y"], -200, 200, 1, addon.db.AuctionHelper.FrameOffsetY or 0, function(value)
		addon.db.AuctionHelper.FrameOffsetY = value
		update()
	end)

	return frame
end

-- Register the panel with the GUI system
GUI:RegisterModule(MOD_KEY, RenderPanel)