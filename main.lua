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
	if type(HBLyx_Tools_DB) ~= "table" or not HBLyx_Tools_DB.Version then
		HBLyx_Tools_DB = {}
		addon.Utilities:print("Profile database initialized.")

		addon.Utilities:SetPopupDialog(ADDON_NAME .. "ConfigRest", L["Welecome"], true)
  	end

	addon.db = HBLyx_Tools_DB
	addon.db.Version = addon.version -- update version number

	-- after 3.0 configurationList: {mod1 = {option1 = defaultVal, option2 = defaultVal, ...}, mod2 = ...}
	for mod, option in pairs(configurationList or {}) do
		for name, defaultVal in pairs(option) do
			ResetConfiguration(mod, name, defaultVal)
		end
	end

	addon.Utilities:print("Profile loaded")
end

---Initialize the configrations: make sure addon.optionsList and addon.configurationList are both created before run this
---In HBLyx design, configure.lua created these List and run before main.lua
local function InitializeConfig()
	-- initialize the test mode
	addon.isTestMode = false
	addon.version = 3.2
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

-- MARK: Initialize

---Initialization before main
function addon:Initialize()
    InitializeConfig()

    -- global variables
	addon.Global = {}
	_, addon.Global["characterClass"] = UnitClass("player")

    addon.Global["inCombat"] = false -- keep this for the situation the CombatLockDown not locked but combat begings
    addon.eventsHandler:Register(function () addon.Global["inCombat"] = true end, "PLAYER_REGEN_DISABLED", "Global[\"inCombat\"]")
    addon.eventsHandler:Register(function () addon.Global["inCombat"] = false end, "PLAYER_REGEN_ENABLED", "Global[\"inCombat\"]")

    -- features
    addon.combatIndicator = CombatIndicator:Initialize()
	if addon.combatIndicator then
		addon.combatIndicator:RegisterEvents()
	end

    addon.combatTimer = CombatTimer:Initialize()
    if addon.combatTimer then
		addon.combatTimer:RegisterEvents()
	end

    addon.focusCastBar = FocusInterrupt:Initialize()
    if addon.focusCastBar then
		addon.focusCastBar:RegisterEvents()
	end

    addon.battleRes = BattleRes:Initialize()
    if addon.battleRes then
		addon.battleRes:RegisterEvents()
	end

	addon.challengeEnhance = ChallengeEnhance:Initialize()
	if addon.challengeEnhance then
		addon.challengeEnhance:RegisterEvents()
	end

    addon.warlockReminder = WarlockReminder:Initialize()
	if addon.warlockReminder then
		addon.warlockReminder:RegisterEvents()
	end

	-- addon.customSpellAlert = CustomSpellAlert:Initialize()
	-- if addon.customSpellAlert then
	-- 	CustomSpellAlert:RegisterEvents()
	-- end
end

-- MARK: TestMode

---Addon's Test(Unlock) mod
---@param on boolean If test mod on
function addon:TestMode(on)
	
	if addon.combatIndicator then
		addon.combatIndicator:Test(on)
	end
	
	if addon.combatTimer then
		addon.combatTimer:Test(on)
	end
	
	if addon.focusCastBar then
		addon.focusCastBar:Test(on)
	end
	
	if addon.battleRes then
		addon.battleRes:Test(on)
	end
	
	if addon.warlockReminder then
		addon.warlockReminder:Test(on)
	end
end

-- main
-- addon.eventHandler = EventsHandler:Initialize() -- in excuted eventHandler.lua
-- "ADDON_LOADED" has been automatically registered into eventHandler
addon.eventsHandler.eventFrame:SetScript("OnEvent", function (self, event, ...)
    addon.eventsHandler:Handle(event, ...)
end)