local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

addon.LSM = LibStub("LibSharedMedia-3.0")

local optionOrder = 1

---Show the RLNeeded popup dialog
---@param dialogName string dialog name
function addon:ShowDialog(dialogName)
	StaticPopup_Show(dialogName)
end

---Handle option group order for options creations
---@return integer order the order of this option group
function addon:OptionOrderHandler()
	local output = optionOrder
	optionOrder = optionOrder + 1
	return output
end

function addon:AppendOptionsList(optionName, optionMap)
	addon.optionsList[optionName] = optionMap
end

-- MARK: Config set ups
-- set up  configurationList
addon.configurationList = {}
-- set up optionsList according to ACEConfig format
-- make the Test(Unlock) option at the beginning
local optionsList = {
	Test = {
		order = addon:OptionOrderHandler(),
		type = "toggle",
		name = L["Test"],
		get = function (_)
			return addon.isTestMode
		end,
		set = function (_, val)
			addon.isTestMode = val
			addon:TestMode(addon.isTestMode)
		end
	},
}
addon.optionsList = optionsList
--set up RLNeeded popup dialog
addon.Utilities:SetPopupDialog(ADDON_NAME .. "RLNeeded", L["ReloadNeeded"], false, {button1 = L["Reload"], button2 = CLOSE, OnButton1 = ReloadUI})