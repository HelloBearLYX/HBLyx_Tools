local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
--[[
    Working in progress to re-factor addon's core structure for better modularity and maintainability
    Main goal is:
        - seperate event and state management to EventsHandler
        - seperate module management to ModuleHandler
        - make core able to manage addon db directly through DBHandler
        - make core can manage GUI directly
        - make the initialize and configuration initialize in the core itself
]]--

---@class Core
---@field EventsHandler table the event handler instance
---@field ModuleHandler table the module handler instance
---@field DBHandler table the database handler instance
local Core = {}
addon.core = Core

---Register in-game Slash Command
local function SetUpSlashCommand()
	SLASH_HBT1 = "/hbt"
	SlashCmdList["HBT"] = function(message)
		local command, rest = strsplit(" ", message, 2)
		if command == "" then
			if addon.GUI and addon.GUI.isOpened then
				addon.GUI:CloseGUI()
			else
				addon.GUI:OpenGUI()
			end
		elseif command == "dev" or command == "developer" then
			addon.Developer:DisplayAddonInfo()
		elseif command == "test" or command == "unlock" then
			addon.core:TestMode()
		end
	end
end

---Register the LibDataBroker (LDB) object for the addon
local function RegisterLDB()
	-- LDB register
	local ldb = LibStub("LibDataBroker-1.1"):NewDataObject(ADDON_NAME, {
		type = "data source",
		text = ADDON_NAME,
		label = "|cff8788ee" .. ADDON_NAME .. "|r",
		icon = "Interface\\AddOns\\HBLyx_Tools\\Media\\HBLyx.png",
		OnClick = function(_, button)
			if button == "LeftButton" then
				addon.GUI:OpenGUI()
			elseif button == "RightButton" then
				addon.core:TestMode()
			end
		end,

		OnTooltipShow = function(tooltip)
			tooltip:AddLine("|cff8788ee" .. ADDON_NAME .. "|r")
			tooltip:AddLine(string.format("|cff00ff00%s|r: %s", L["LeftButton"], L["ConfigPanel"]))
			tooltip:AddLine(string.format("|cff00ff00%s|r: %s", L["RightButton"], L["EditMode"]))
		end,
	})
	LibStub("LibDBIcon-1.0"):Register(ADDON_NAME, ldb, addon.db["MinimapIcon"])
end

---Show the reload popup dialog
function Core:ShowReloadPopup()
    StaticPopup_Show(ADDON_NAME .. "RLNeeded")
end

-- MARK: Initialize Core

---Initialize the core of the addon, including setting up the LDB, slash commands, and default configurations.
function Core:Initialize()
    addon.version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version")

    self.DBHandler:ValidateDatabase()
    RegisterLDB()
    SetUpSlashCommand()
    self.ModuleHandler:LoadAllModules()

    addon.Utilities:print(L["WelecomeSetting"])
end

---Configure the basic environment for the addon, including popup dialogs and media settings
function Core:Configure()
    -- set up RLNeeded popup dialog
    addon.Utilities:SetPopupDialog(ADDON_NAME .. "RLNeeded", L["ReloadNeeded"], false, {button1 = L["Reload"], button2 = CLOSE, OnButton1 = ReloadUI})
    -- set up LibSharedMedia and defult media for the addon
    addon.LSM = LibStub("LibSharedMedia-3.0")
    addon.LSM:Register("sound", "[HBLyx] Notification", "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\Sound\\notification.ogg")
    addon.LSM:Register("sound", "[HBLyx] Info", "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\Sound\\info.ogg")
    addon.DEFAULTS = {
        font = addon.LSM:Fetch("font", addon.LSM:GetDefault("font")) or "Fonts\\FRIZQT__.TTF",
    }
end

Core:Configure()