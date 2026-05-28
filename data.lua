local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
addon.data = {}

addon.data.MAP_ENCOUNTER_EVENTS = {
	-- MARK: current season 12.0
    [402] = {
		portalID = 393273,
		name = L["Algeth'ar Academy"],
		short = L["Algeth'ar Academy_short"],
	},
	[239] = {
		portalID = 1254551,
		name = L["Seat of the Triumvirate"],
		short = L["Seat of the Triumvirate_short"],
	},
	[559] = {
		portalID = 1254563,
		name = L["Nexus-Point Xenas"],
		short = L["Nexus-Point Xenas_short"],
	},
	[560] = {
		portalID = 1254559,
		name = L["Maisara Caverns"],
		short = L["Maisara Caverns_short"],
	},
	[161] = {
		portalID = {1254557, 159898},
		name = L["Skyreach"],
		short = L["Skyreach_short"],
	},
	[557] = {
		portalID = 1254400,
		name = L["Windrunner Spire"],
		short = L["Windrunner Spire_short"],
	},
	[558] = {
		portalID = 1254572,
		name = L["Magister's Terrace"],
		short = L["Magister's Terrace_short"],
	},
	[556] = {
		portalID = 1254555,
		name = L["Pit of Saron"],
		short = L["Pit of Saron_short"],
	},
}

-- MARK: Instance Journal
addon.data.DUNGEONS = {
	[1201] = {name = select(1, EJ_GetInstanceInfo(1201)) or "Algeth'ar Academy", enabled = true, instanceID = 2526},
	[945] = {name = select(1, EJ_GetInstanceInfo(945)) or "Seat of the Triumvirate", enabled = true, instanceID = 1753},
	[1316] = {name = select(1, EJ_GetInstanceInfo(1316)) or "Nexus-Point Xenas", enabled = true, instanceID = 2915},
	[1315] = {name = select(1, EJ_GetInstanceInfo(1315)) or "Maisara Caverns", enabled = true, instanceID = 2874},
	[476] = {name = select(1, EJ_GetInstanceInfo(476)) or "Skyreach", enabled = true, instanceID = 1209},
	[1299] = {name = select(1, EJ_GetInstanceInfo(1299)) or "Windrunner Spire", enabled = true, instanceID = 2805},
	[1300] = {name = select(1, EJ_GetInstanceInfo(1300)) or "Magister's Terrace", enabled = true, instanceID = 2811},
	[278] = {name = select(1, EJ_GetInstanceInfo(278)) or "Pit of Saron", enabled = true, instanceID = 658},
	[1309] = {name = select(1, EJ_GetInstanceInfo(1309)) or "The Blinding Vale", enabled = false, instanceID = 2859},
	[1304] = {name = select(1, EJ_GetInstanceInfo(1304)) or "Murder Row", enabled = false, instanceID = 2813},
	[1311] = {name = select(1, EJ_GetInstanceInfo(1311)) or "Den of Nalorakk", enabled = false, instanceID = 2825},
	[1313] = {name = select(1, EJ_GetInstanceInfo(1313)) or "Voidscar Arena", enabled = false, instanceID = 2923},
	[1314] = {name = select(1, EJ_GetInstanceInfo(1314)) or "Dreamrift", enabled = false, instanceID = 2939},
	[1307] = {name = select(1, EJ_GetInstanceInfo(1307)) or "The Voidspire", enabled = false, instanceID = 2912},
	[1308] = {name = select(1, EJ_GetInstanceInfo(1308)) or "March on Quel'Danas", enabled = false, instanceID = 2913},
}