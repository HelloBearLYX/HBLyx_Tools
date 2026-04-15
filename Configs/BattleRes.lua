local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "BattleRes"

-- MARK: Defaults
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
	FrameStrata = "BACKGROUND",
}

-- MARK: Safe update
local function update()
	return addon.core:GetSafeUpdate(MOD_KEY)()
end

-- GUI
GUI.TagPanels.BattleRes = {}
function GUI.TagPanels.BattleRes:CreateTabPanel(parent)
	-- MARK: General
	local frame = GUI:CreateScrollFrame(parent)
	frame:SetLayout("Flow")
	frame:SetFullWidth(true)

	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["BattleResSettings"] .. "|r", addon.db.BattleRes.Enabled, function(value)
		addon.db.BattleRes.Enabled = value
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
	GUI:CreateToggleCheckBox(frame, L["HideInactive"], addon.db.BattleRes.HideInactive, function(value)
		addon.db.BattleRes.HideInactive = value
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

	-- Style Settings
	local styleGroup = GUI:CreateInlineGroup(frame, L["StyleSettings"])
	GUI:CreateFrameStrataDropdown(styleGroup, addon.db.BattleRes.FrameStrata, function(value)
		addon.db.BattleRes.FrameStrata = value
		update()
	end)
	-- MARK: Icon
	local iconGroup = GUI:CreateInlineGroup(styleGroup, L["IconSettings"])
	GUI:CreateSlider(iconGroup, L["IconSize"], 10, 200, 1, addon.db.BattleRes.IconSize, function(value)
		addon.db.BattleRes.IconSize = value
		update()
	end)
	GUI:CreateSlider(iconGroup, L["IconZoom"], 0.01, 0.5, 0.01, addon.db.BattleRes.IconZoom, function(value)
		addon.db.BattleRes.IconZoom = value
		update()
	end)

	-- MARK: Position
	local positionGroup = GUI:CreateInlineGroup(styleGroup, L["PositionSettings"])
	GUI:CreateSlider(positionGroup, L["X"], -2000, 2000, 1, addon.db.BattleRes.X, function(value)
		addon.db.BattleRes.X = value
		update()
	end)
	GUI:CreateSlider(positionGroup, L["Y"], -1000, 1000, 1, addon.db.BattleRes.Y, function(value)
		addon.db.BattleRes.Y = value
		update()
	end)

	-- MARK: Font
	local fontGroup = GUI:CreateInlineGroup(styleGroup, L["FontSettings"])
	GUI:CreateFontSelect(fontGroup, L["Font"], addon.db.BattleRes.Font, function(value)
		addon.db.BattleRes.Font = value
		update()
	end)
	GUI:CreateSlider(fontGroup, L["TimeFontScale"], 0.1, 5, 0.01, addon.db.BattleRes.TimeFontScale, function(value)
		addon.db.BattleRes.TimeFontScale = value
		update()
	end)
	GUI:CreateSlider(fontGroup, L["StackFontSize"], 6, 40, 1, addon.db.BattleRes.ChargeFontSize, function(value)
		addon.db.BattleRes.ChargeFontSize = value
		update()
	end)

	return frame
end