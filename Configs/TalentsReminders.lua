local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "TalentsReminders"

-- MARK: Safe update

local function update()
	return addon.core:GetSafeUpdate(MOD_KEY)()
end

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = true,
    IconSize = 35,
    IconZoom = 0.07,
    X = 0,
    Y = 0,
}

-- GUI
GUI.TagPanels.CustomAuraTracker = {}
function GUI.TagPanels.CustomAuraTracker:CreateTabPanel(parent)
	-- MARK: General
	local frame = GUI:CreateScrollFrame(parent)
	frame:SetLayout("Flow")
	frame:SetFullWidth(true)



    return frame
end