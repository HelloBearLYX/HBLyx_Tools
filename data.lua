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

-- MARK: Auction Helper
addon.data.AUCTION_HELPER = {
	Consumerables = {
		-- flasks
		{itemID = 241326, category = "Flask", tag = "Crit"},
		{itemID = 241324, category = "Flask", tag = "Haste"},
		{itemID = 241322, category = "Flask", tag = "Mastery"},
		{itemID = 241320, category = "Flask", tag = "Vers"},
		-- runes
		{itemID = 259085, category = "Rune", tag = "Rune"},
		{itemID = 245879, category = "Rune", tag = "Vantus"},
		-- oils
		{itemID = 243737, category = "Oil", tag = "Proc"},
		{itemID = 243735, category = "Oil", tag = "Healer"},
		{itemID = 243733, category = "Oil", tag = "Secondary"},
		{itemID = 237370, category = "Oil", tag = "Sharp"},
		{itemID = 237367, category = "Oil", tag = "Blunt"},
		-- foods
			-- feasts
		{itemID = 255846, category = "Food", tag = "Primary"},
		{itemID = 255845, category = "Food", tag = "Primary"},
		{itemID = 242273, category = "Food", tag = "Secondary"},
		{itemID = 242272, category = "Food", tag = "Secondary"},
			-- other foods
		{itemID = 242275, category = "Food", tag = "Primary"},
		{itemID = 255848, category = "Food", tag = "Secondary"},
		{itemID = 242274, category = "Food", tag = "Secondary"},
		-- potion
		{itemID = 241308, category = "Potion", tag = "Primary"},
		{itemID = 241288, category = "Potion", tag = "Secondary"},
		{itemID = 241292, category = "Potion", tag = "Primary"},
		{itemID = 241304, category = "Potion", tag = "Health"},
		{itemID = 241302, category = "Potion", tag = "Invisible"},
		{itemID = 241300, category = "Potion", tag = "Mana"},
		{itemID = 241294, category = "Potion", tag = "Mana"},
		{itemID = 241338, category = "Potion", tag = "Utility"},
		-- utility
		{itemID = 244639, category = "Utility", tag = "Bloodlust"},
		{itemID = 248486, category = "Utility", tag = "BattleRes"},
		{itemID = 132514, category = "Utility", tag = "Repair"},
	},
	Gems = {
		-- diamond
		{itemID = 240982, category = "Diamond", tag = "Primary"},
		{itemID = 240970, category = "Diamond", tag = "Armor"},
		{itemID = 240968, category = "Diamond", tag = "Mana"},
		{itemID = 240966, category = "Diamond", tag = "Crit"},
		-- Crit
		{itemID = 240903, category = "Gem", tag = "Crit"},
		{itemID = 240905, category = "Gem", tag = "Haste"},
		{itemID = 240907, category = "Gem", tag = "Mastery"},
		{itemID = 240909, category = "Gem", tag = "Vers"},
		-- Haste
		{itemID = 240889, category = "Gem", tag = "Crit"},
		{itemID = 240887, category = "Gem", tag = "Haste"},
		{itemID = 240891, category = "Gem", tag = "Mastery"},
		{itemID = 240893, category = "Gem", tag = "Vers"},
		-- Mastery
		{itemID = 240897, category = "Gem", tag = "Crit"},
		{itemID = 240899, category = "Gem", tag = "Haste"},
		{itemID = 240895, category = "Gem", tag = "Mastery"},
		{itemID = 240901, category = "Gem", tag = "Vers"},
		-- Vers
		{itemID = 240913, category = "Gem", tag = "Crit"},
		{itemID = 240915, category = "Gem", tag = "Haste"},
		{itemID = 240917, category = "Gem", tag = "Mastery"},
		{itemID = 240911, category = "Gem", tag = "Vers"},
	},
	Enhancements = {
		-- finger
		{itemID = 243956, category = "Finger", tag = "Damage"},
		{itemID = 243986, category = "Finger", tag = "Crit"},
		{itemID = 244014, category = "Finger", tag = "Haste"},
		{itemID = 243985, category = "Finger", tag = "Mastery"},
		{itemID = 244016, category = "Finger", tag = "Vers"},
		-- weapon
		{itemID = 244028, category = "Weapon", tag = "Primary"},
		{itemID = 243970, category = "Weapon", tag = "Crit"},
		{itemID = 243972, category = "Weapon", tag = "Haste"},
		{itemID = 244030, category = "Weapon", tag = "Mastery"},
		{itemID = 244001, category = "Weapon", tag = "Vers"},
		{itemID = 257745, category = "Weapon", tag = "Crit"},
		{itemID = 257747, category = "Weapon", tag = "Mastery"},
		-- chest
		{itemID = 243976, category = "Chest", tag = "Primary"},
		-- leg
		{itemID = 240094, category = "Leg", tag = "Intelligence"},
		{itemID = 240154, category = "Leg", tag = "Mana"},
		{itemID = 244640, category = "Leg", tag = "Martial"},
		{itemID = 244642, category = "Leg", tag = "Armor"},
		-- head
		{itemID = 244006, category = "Head", tag = "Avoidance"},
		{itemID = 243950, category = "Head", tag = "Leech"},
		{itemID = 243980, category = "Head", tag = "Speed"},
		-- shoulder
		{itemID = 243990, category = "Shoulder", tag = "Avoidance"},
		{itemID = 244020, category = "Shoulder", tag = "Leech"},
		{itemID = 243962, category = "Shoulder", tag = "Speed"},
		-- feet
		{itemID = 243952, category = "Feet", tag = "Avoidance"},
		{itemID = 243982, category = "Feet", tag = "Leech"},
		{itemID = 244008, category = "Feet", tag = "Speed"},
	},
	Crafts = {
		-- missive
		{itemID = 245785, category = "Missive", tag = "CritHaste"},
		{itemID = 245789, category = "Missive", tag = "CritMastery"},
		{itemID = 245791, category = "Missive", tag = "CritVers"},
		{itemID = 245783, category = "Missive", tag = "HasteMastery"},
		{itemID = 245781, category = "Missive", tag = "HasteVers"},
		{itemID = 245787, category = "Missive", tag = "MasteryVers"},
		-- embellishment
		{itemID = 248130, category = "Embellishment"},
		{itemID = 240167, category = "Embellishment"},
		{itemID = 240164, category = "Embellishment"},
		{itemID = 251489, category = "Embellishment"},
		{itemID = 244603, category = "Embellishment"},
		{itemID = 244607, category = "Embellishment"},
		{itemID = 244674, category = "Embellishment"},
		{itemID = 245871, category = "Embellishment"},
		{itemID = 245873, category = "Embellishment"},
		{itemID = 245875, category = "Embellishment"},
		{itemID = 245877, category = "Embellishment"},
	}
}