---@class HBLyx_tools: AceAddon
HBLyx_Tools = LibStub("AceAddon-3.0"):NewAddon("HBLyx_Tools")

local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

-- MARK: Config Handle

---Attempt to reset a configure
---@param mod string the mod to access addon profile(the mod key for the addon.db[mod])
---@param name string the option name to access addon profile(the option key for the addon.db[mod][name])
---@param defaultValue any the default value for the configure
---@return boolean success if the configure is reset
local function ResetConfiguration(mod, name, defaultValue)
	if type(addon.db[mod]) ~= "table" then
		addon.db[mod] = {}
	end

	if type(addon.db[mod][name]) ~= type(defaultValue) then
		addon.db[mod][name] = defaultValue
		return true
	end

	return false
end

---Handle profile of configurations
---@param configurationList table a list contains options and configuration default values such as: {mod1 = {option1 = defaultVal, option2 = defaultVal, ...}, mod2 = ...}
local function ProfileHandler(configurationList)
	-- also reset configs before v3.0 version(no DB.Version before v3.0)
	if type(HBLyx_Tools_DB) ~= "table" or not HBLyx_Tools_DB["Version"] then
		HBLyx_Tools_DB = {}
		addon.Utilities:print("Profile database initialized.")

		addon.Utilities:SetPopupDialog(ADDON_NAME .. "ConfigRest", L["Welecome"], true)
  	end

	addon.db = HBLyx_Tools_DB
	addon.db["Version"] = addon.version
	if type(addon.db["MinimapIcon"]) ~= "table" then
		addon.db["MinimapIcon"] = {hide = false}
	end

	-- after 3.0 configurationList: {mod1 = {option1 = defaultVal, option2 = defaultVal, ...}, mod2 = ...}
	for mod, option in pairs(configurationList or {}) do
		for name, defaultVal in pairs(option) do
			ResetConfiguration(mod, name, defaultVal)
		end
	end
end

-- MARK: Initialize Config

---Initialize the configrations: make sure addon.optionsList and addon.configurationList are both created before run this
---In HBLyx design, configure.lua created these List and run before main.lua
local function InitializeConfig()
	-- initialize the test mode
	addon.isTestMode = false
	-- initialize configurations
	ProfileHandler(addon.configurationList)

	local options = {
		name = ADDON_NAME,
		handler = self,
		type = "group",
		args = addon.optionsList
  	}

	LibStub("AceConfig-3.0"):RegisterOptionsTable(ADDON_NAME, options)
  	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(ADDON_NAME, "|cff8788ee"..  ADDON_NAME .. "|r")

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
			tooltip:AddLine(string.format("|cff00ff00%s|r: %s", L["RightButton"], L["Test"]))
		end,
	})
	LibStub("LibDBIcon-1.0"):Register(ADDON_NAME, ldb, addon.db["MinimapIcon"])

	addon.Utilities:print(L["WelecomeSetting"])
end

-- MARK: SlashCMD

---Register in-game Slash Command
local function SetUpSlashCommand()
	SLASH_HBLYX1 = "/hblyx"
	SlashCmdList["HBLYX"] = function()
		addon.GUI:OpenGUI()
	end
end

---Get Addon's Version number
---@return number version number
function addon:GetVersion()
	return addon.version
end

-- MARK: States

---Initialize addon states
local function InitializeStates()
	addon.states = {}

	-- player class
	addon.states["playerClass"] = select(2, UnitClass("player")) -- "ADDON_LOADED"
	
	-- if the player is in combat
	addon.states["inCombat"] = InCombatLockdown()
	addon.core:RegisterState("PLAYER_REGEN_DISABLED", nil, "inCombat", function()
		addon.states["inCombat"] = true
		addon.GUI:CloseGUI() -- close GUI when enter combat
		if addon.core:IsTestOn() then
			addon.core:TestMode(false) -- turn off test mode when enter combat
			addon.Utilities:print(L["CombatLock"])
		end
	end)
	addon.core:RegisterState("PLAYER_REGEN_ENABLED", nil, "inCombat", function()
		addon.states["inCombat"] = false
	end)

	local GetInstanceState = function()
		-- if difficultyID = 0: not in instance; if instanceID = 0: not in instance or in world
		local _, _, difficultyID, _, _, _, _, instanceID = GetInstanceInfo()

		addon.states["instanceInfo"] = {difficultyID = difficultyID, instanceID = instanceID}
	end
	addon.core:RegisterState("PLAYER_ENTERING_WORLD", nil, "instanceInfo", GetInstanceState)
	addon.core:RegisterState("ZONE_CHANGED_NEW_AREA", nil, "instanceInfo", GetInstanceState)

	-- player spec state
	local GetSpec = function ()
		addon.states["playerSpec"] = C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization())
	end
	addon.core:RegisterState("PLAYER_ENTERING_WORLD", nil, "playerSpec", GetSpec) -- the spec cannot be initialized when "ADDON_LOADED", it must be initialized after "PLAYER_ENTERING_WORLD"
	addon.core:RegisterState("PLAYER_SPECIALIZATION_CHANGED", nil, "playerSpec", GetSpec)
end

-- MARK: Initialize

---Initialization before main
function addon:Initialize()
	addon.version = "3.13"

	-- set up profile and configures
	InitializeConfig()

	-- set up slash command
	SetUpSlashCommand()

    -- global states such as player class, spec, in-combat status, etc.
	InitializeStates()

    -- modules
	addon.core:LoadAllModules()
end

-- main
-- addon.core = addon.Core:Initialize() -- has been called in Core.lua, no need to call again here
-- "ADDON_LOADED" has been automatically registered into eventHandler
addon.core:Start() -- start