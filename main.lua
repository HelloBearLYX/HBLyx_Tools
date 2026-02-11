---@class HBLyx_tools: AceAddon
HBLyx_Tools = LibStub("AceAddon-3.0"):NewAddon("HBLyx_Tools")

local ADDON_NAME, addon = ...

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

	-- after 3.0 configurationList: {mod1 = {option1 = defaultVal, option2 = defaultVal, ...}, mod2 = ...}
	for mod, option in pairs(configurationList or {}) do
		for name, defaultVal in pairs(option) do
			ResetConfiguration(mod, name, defaultVal)
		end
	end
end

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

-- MARK: TestMode

---Addon's Test(Unlock) mod
---@param on boolean If test mod on
function addon:TestMode(on)
	addon.core:TestMode(on)
end

-- MARK: Initialize

---Initialization before main
function addon:Initialize()
	addon.version = 3.4

	-- set up profile and configures
	InitializeConfig()

	-- set up slash command
	SetUpSlashCommand()

    -- global variables
	addon.Global = {}
	_, addon.Global["characterClass"] = UnitClass("player")

    addon.Global["inCombat"] = false -- keep this for the situation the CombatLockDown not locked but combat begings
    addon.core:RegisterEvent(function () addon.Global["inCombat"] = true end, "PLAYER_REGEN_DISABLED", "Global[\"inCombat\"]")
    addon.core:RegisterEvent(function () addon.Global["inCombat"] = false end, "PLAYER_REGEN_ENABLED", "Global[\"inCombat\"]")

    -- modules
	addon.core:LoadAllModules()
end

-- main
-- addon.core = addon.Core:Initialize() -- has been called in Core.lua, no need to call again here
-- "ADDON_LOADED" has been automatically registered into eventHandler
addon.core:Start() -- start