local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "TalentsReminders"

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = true,
    IconSize = 35,
    IconZoom = 0.07,
    X = 0,
    Y = 0,
}

-- MARK: Safe update

local function update()
	return addon.core:GetSafeUpdate(MOD_KEY)()
end

-- GUI
GUI.TagPanels.TalentsReminders = {}
function GUI.TagPanels.TalentsReminders:CreateTabPanel(parent)
	-- MARK: General
	local frame = GUI:CreateScrollFrame(parent)
	frame:SetLayout("Flow")
	frame:SetFullWidth(true)

    GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["TalentsRemindersSettings"] .. "|r", addon.db.TalentsReminders.Enabled, function(value)
		addon.db.TalentsReminders.Enabled = value
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
			"|cffC41E3A" .. L["TalentsRemindersSettings"] .. "|r: " .. L["ComfirmResetMod"],
			true,
			{button1 = YES, button2 = NO, OnButton1 = function ()
		    	addon.Utilities:ResetModule(MOD_KEY)
				ReloadUI()
			end}
		)
	end)

    local dungeonGroup = GUI:CreateInlineGroup(frame, L["SelectDungeon"])

    return frame
end