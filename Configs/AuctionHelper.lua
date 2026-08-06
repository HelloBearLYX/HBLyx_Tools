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
GUI.TagPanels.AuctionHelper = {}
function GUI.TagPanels.AuctionHelper:CreateTabPanel(parent)
	-- MARK: General
	local frame = GUI:CreateScrollFrame(parent)
	frame:SetLayout("Flow")
	frame:SetFullWidth(true)

	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["AuctionHelperSettings"] .. "|r", addon.db.AuctionHelper.Enabled, function(value)
		addon.db.AuctionHelper.Enabled = value
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

	GUI:CreateButton(frame, L["ResetMod"], function ()
		addon.Utilities:SetPopupDialog(
			ADDON_NAME .. "ResetMod",
			"|cffC41E3A" .. L["AuctionHelperSettings"] .. "|r: " .. L["ComfirmResetMod"],
			true,
			{button1 = YES, button2 = NO, OnButton1 = function ()
		    	addon.Utilities:ResetModule(MOD_KEY)
				ReloadUI()
			end}
		)
	end)

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
