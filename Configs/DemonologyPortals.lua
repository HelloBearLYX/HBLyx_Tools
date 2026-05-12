local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "DemonologyPortals"

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = true,
	HideWhenInactive = true,
	PrintToChat = true,
	HideDelay = 5,
	CountFont = "",
	CountFontSize = 12,
	TimeFontScale = 1,
	CountFontOffsetX = 0,
	CountFontOffsetY = 0,
	CountAnchor = "TOP",
	X = -110,
	Y = -150,
	IconSize = 30,
	IconZoom = 0.07,
	FrameStrata = "MEDIUM",
}

-- MARK: Safe update
local function update()
	return addon.core:GetSafeUpdate(MOD_KEY)()
end

-- GUI
GUI.TagPanels.DemonologyPortals = {}
function GUI.TagPanels.DemonologyPortals:CreateTabPanel(parent)
	-- MARK: General
	local frame = GUI:CreateScrollFrame(parent)
	frame:SetLayout("Flow")
	frame:SetFullWidth(true)

	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["DemonologyPortalsSettings"] .. "|r", addon.db.DemonologyPortals.Enabled, function(value)
		addon.db.DemonologyPortals.Enabled = value
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
			"|cffC41E3A" .. L["DemonologyPortalsSettings"] .. "|r: " .. L["ComfirmResetMod"],
			true,
			{button1 = YES, button2 = NO, OnButton1 = function ()
		    	addon.Utilities:ResetModule(MOD_KEY)
				ReloadUI()
			end}
		)
	end)

	-- behavior settings
	local behaviorGroup = GUI:CreateInlineGroup(frame, L["General"])
	GUI:CreateToggleCheckBox(behaviorGroup, L["HideInactive"], addon.db.DemonologyPortals.HideWhenInactive, function(value)
		addon.db.DemonologyPortals.HideWhenInactive = value
		update()
	end)
	GUI:CreateSlider(behaviorGroup, L["FadeOutTime"], 0, 10, 1, addon.db.DemonologyPortals.HideDelay, function(value)
		addon.db.DemonologyPortals.HideDelay = value
		update()
	end)
	GUI:CreateToggleCheckBox(behaviorGroup, L["TimerPrintEnabled"], addon.db.DemonologyPortals.PrintToChat, function(value)
		addon.db.DemonologyPortals.PrintToChat = value
		update()
	end)
	-- Style Settings
	local styleGroup = GUI:CreateInlineGroup(frame, L["StyleSettings"])
	GUI:CreateFrameStrataDropdown(styleGroup, addon.db.DemonologyPortals.FrameStrata, function(value)
		addon.db.DemonologyPortals.FrameStrata = value
		update()
	end)
	-- MARK: Icon
	local iconGroup = GUI:CreateInlineGroup(styleGroup, L["IconSettings"])
	GUI:CreateSlider(iconGroup, L["IconSize"], 10, 200, 1, addon.db.DemonologyPortals.IconSize, function(value)
		addon.db.DemonologyPortals.IconSize = value
		update()
	end)
	GUI:CreateSlider(iconGroup, L["IconZoom"], 0.01, 0.5, 0.01, addon.db.DemonologyPortals.IconZoom, function(value)
		addon.db.DemonologyPortals.IconZoom = value
		update()
	end)

	-- MARK: Position
	local positionGroup = GUI:CreateInlineGroup(styleGroup, L["PositionSettings"])
	GUI:CreateSlider(positionGroup, L["X"], -2000, 2000, 1, addon.db.DemonologyPortals.X, function(value)
		addon.db.DemonologyPortals.X = value
		update()
	end)
	GUI:CreateSlider(positionGroup, L["Y"], -1000, 1000, 1, addon.db.DemonologyPortals.Y, function(value)
		addon.db.DemonologyPortals.Y = value
		update()
	end)

	-- MARK: Font
	local fontGroup = GUI:CreateInlineGroup(styleGroup, L["FontSettings"])
	local timeFontGroup = GUI:CreateInlineGroup(fontGroup, L["Time"])
	GUI:CreateSlider(timeFontGroup, L["TimeFontScale"], 0.1, 5, 0.01, addon.db.DemonologyPortals.TimeFontScale, function(value)
		addon.db.DemonologyPortals.TimeFontScale = value
		update()
	end)

	local countFontGroup = GUI:CreateInlineGroup(fontGroup, L["Count"])
	GUI:CreateFontSelect(countFontGroup, L["Font"], addon.db.DemonologyPortals.CountFont, function(value)
		addon.db.DemonologyPortals.CountFont = value
		update()
	end)
	GUI:CreateSlider(countFontGroup, L["FontSize"], 6, 40, 1, addon.db.DemonologyPortals.CountFontSize, function(value)
		addon.db.DemonologyPortals.CountFontSize = value
		update()
	end)
	GUI:CreateInformationTag(countFontGroup, "\n")
	local anchors = {TOP = "TOP", BOTTOM = "BOTTOM", LEFT = "LEFT", RIGHT = "RIGHT"}
	GUI:CreateDropdown(countFontGroup, L["Anchor"], anchors, nil, addon.db.DemonologyPortals.CountAnchor, function(value)
		addon.db.DemonologyPortals.CountAnchor = value
		update()
	end)
	GUI:CreateSlider(countFontGroup, L["X"], -100, 100, 1, addon.db.DemonologyPortals.CountFontOffsetX, function(value)
		addon.db.DemonologyPortals.CountFontOffsetX = value
		update()
	end)
	GUI:CreateSlider(countFontGroup, L["Y"], -100, 100, 1, addon.db.DemonologyPortals.CountFontOffsetY, function(value)
		addon.db.DemonologyPortals.CountFontOffsetY = value
		update()
	end)


	return frame
end
