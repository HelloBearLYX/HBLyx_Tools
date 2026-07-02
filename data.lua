local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
addon.data = {}

addon.data.SEASON_MAP = {
	-- TODO: Update unknown portalIDs (placeholder 134401): 587, 586, 585, 584, 250
	-- Midnight 12.0
	[588] = {
		enabled = true,
		instanceID = 2993,
		journalInstanceID = 1322,
		portalID = 1286812,
		name = select(1, EJ_GetInstanceInfo(1322)) or "Altar of Fangs",
		short = L["Altar of Fangs_short"],
	},
	[587] = {
		enabled = true,
		instanceID = 2813,
		journalInstanceID = 1304,
		portalID = 134401,
		name = select(1, EJ_GetInstanceInfo(1304)) or "Murder Row",
		short = L["Murder Row_short"],
	},
	[586] = {
		enabled = true,
		instanceID = 2825,
		journalInstanceID = 1311,
		portalID = 134401,
		name = select(1, EJ_GetInstanceInfo(1311)) or "Den of Nalorakk",
		short = L["Den of Nalorakk_short"],
	},
	[585] = {
		enabled = true,
		instanceID = 2923,
		journalInstanceID = 1313,
		portalID = 134401,
		name = select(1, EJ_GetInstanceInfo(1313)) or "Voidscar Arena",
		short = L["Voidscar Arena_short"],
	},
	[584] = {
		enabled = true,
		instanceID = 2859,
		journalInstanceID = 1309,
		portalID = 134401,
		name = select(1, EJ_GetInstanceInfo(1309)) or "The Blinding Vale",
		short = L["The Blinding Vale_short"],
	},
	[560] = {
		enabled = false,
		instanceID = 2874,
		journalInstanceID = 1315,
		portalID = 1254559,
		name = select(1, EJ_GetInstanceInfo(1315)) or "Maisara Caverns",
		short = L["Maisara Caverns_short"],
	},
	[559] = {
		enabled = false,
		instanceID = 2915,
		journalInstanceID = 1316,
		portalID = 1254563,
		name = select(1, EJ_GetInstanceInfo(1316)) or "Nexus-Point Xenas",
		short = L["Nexus-Point Xenas_short"],
	},
	[558] = {
		enabled = false,
		instanceID = 2811,
		journalInstanceID = 1300,
		portalID = 1254572,
		name = select(1, EJ_GetInstanceInfo(1300)) or "Magister's Terrace",
		short = L["Magister's Terrace_short"],
	},
	[557] = {
		enabled = false,
		instanceID = 2805,
		journalInstanceID = 1299,
		portalID = 1254400,
		name = select(1, EJ_GetInstanceInfo(1299)) or "Windrunner Spire",
		short = L["Windrunner Spire_short"],
	},
	-- DF
    [402] = {
		enabled = false,
		instanceID = 2526,
		journalInstanceID = 1201,
		portalID = 393273,
		name = select(1, EJ_GetInstanceInfo(1201)) or "Algeth'ar Academy",
		short = L["Algeth'ar Academy_short"],
	},
	[399] = {
		enabled = true,
		instanceID = 2521,
		journalInstanceID = 1202,
		portalID = 393256,
		name = select(1, EJ_GetInstanceInfo(1202)) or "Ruby Life Pools",
		short = L["Ruby Life Pools_short"],
	},
	-- BFA
	[250] = {
		enabled = true,
		instanceID = 1877,
		journalInstanceID = 1030,
		portalID = 134401,
		name = select(1, EJ_GetInstanceInfo(1030)) or "Temple of Sethraliss",
		short = L["Temple of Sethraliss_short"],
	},
	[249] = {
		enabled = true,
		instanceID = 1762,
		portalID = 134400,
		journalInstanceID = 1041,
		name = select(1, EJ_GetInstanceInfo(1041)) or "King's Rest",
		short = L["King's Rest_short"],
	},
	-- Legion
	[239] = {
		enabled = false,
		instanceID = 1753,
		journalInstanceID = 945,
		portalID = 1254551,
		name = select(1, EJ_GetInstanceInfo(945)) or "Seat of the Triumvirate",
		short = L["Seat of the Triumvirate_short"],
	},
	-- WoD
	[161] = {
		enabled = false,
		instanceID = 1209,
		journalInstanceID = 476,
		portalID = {1254557, 159898},
		name = select(1, EJ_GetInstanceInfo(476)) or "Skyreach",
		short = L["Skyreach_short"],
	},
	-- WoLK
	[556] = {
		enabled = false,
		instanceID = 658,
		journalInstanceID = 278,
		portalID = 1254555,
		name = select(1, EJ_GetInstanceInfo(278)) or "Pit of Saron",
		short = L["Pit of Saron_short"],
	},
}

-- MARK: Auction Helper
addon.data.AUCTION_HELPER = {
	{
		category = "Consumerables",
		subCategories = {
			{
				subCategory = "Flask",
				items = {
					{itemID = 241326, tag = "Crit"},
					{itemID = 241324, tag = "Haste"},
					{itemID = 241322, tag = "Mastery"},
					{itemID = 241320, tag = "Vers"},
				},
			},
			{
				subCategory = "Rune",
				items = {
					{itemID = 259085, tag = "Rune"},
					{itemID = 245879, tag = "Vantus"},
				},
			},
			{
				subCategory = "Oil",
				items = {
					{itemID = 243737, tag = "Proc"},
					{itemID = 243735, tag = "Healer"},
					{itemID = 243733, tag = "Secondary"},
					{itemID = 237370, tag = "Sharp"},
					{itemID = 237367, tag = "Blunt"},
				},
			},
			{
				subCategory = "Food",
				items = {
					{itemID = 255846, tag = "Primary"},
					{itemID = 255845, tag = "Primary"},
					{itemID = 242273, tag = "Secondary"},
					{itemID = 242272, tag = "Secondary"},
					{itemID = 242275, tag = "Primary"},
					{itemID = 255848, tag = "Secondary"},
					{itemID = 242274, tag = "Secondary"},
				},
			},
			{
				subCategory = "Potion",
				items = {
					{itemID = 241308, tag = "Primary"},
					{itemID = 241288, tag = "Secondary"},
					{itemID = 241292, tag = "Primary"},
					{itemID = 241304, tag = "Health"},
					{itemID = 241302, tag = "Invisible"},
					{itemID = 241300, tag = "Mana"},
					{itemID = 241294, tag = "Mana"},
					{itemID = 241338},
				},
			},
			{
				subCategory = "Utility",
				items = {
					{itemID = 244639, tag = "Bloodlust"},
					{itemID = 248486, tag = "BattleRes"},
					{itemID = 132514, tag = "Repair"},
					{itemID = 204370},
					{itemID = 124640},
				},
			},
		},
	},
	{
		category = "Gems",
		subCategories = {
			{
				subCategory = "Diamond",
				items = {
					{itemID = 240982, tag = "Primary"},
					{itemID = 240970, tag = "Armor"},
					{itemID = 240968, tag = "Mana"},
					{itemID = 240966, tag = "Crit"},
				},
			},
			{
				subCategory = "Crit",
				items = {
					{itemID = 240903, tag = "Crit"},
					{itemID = 240905, tag = "Haste"},
					{itemID = 240907, tag = "Mastery"},
					{itemID = 240909, tag = "Vers"},
				},
			},
			{
				subCategory = "Haste",
				items = {
					{itemID = 240889, tag = "Crit"},
					{itemID = 240887, tag = "Haste"},
					{itemID = 240891, tag = "Mastery"},
					{itemID = 240893, tag = "Vers"},
				},
			},
			{
				subCategory = "Mastery",
				items = {
					{itemID = 240897, tag = "Crit"},
					{itemID = 240899, tag = "Haste"},
					{itemID = 240895, tag = "Mastery"},
					{itemID = 240901, tag = "Vers"},
				},
			},
			{
				subCategory = "Vers",
				items = {
					{itemID = 240913, tag = "Crit"},
					{itemID = 240915, tag = "Haste"},
					{itemID = 240917, tag = "Mastery"},
					{itemID = 240911, tag = "Vers"},
				},
			},
		},
	},
	{
		category = "Enhancements",
		subCategories = {
			{
				subCategory = "Finger",
				items = {
					{itemID = 243956, tag = "Damage"},
					{itemID = 243986, tag = "Crit"},
					{itemID = 244014, tag = "Haste"},
					{itemID = 243985, tag = "Mastery"},
					{itemID = 244016, tag = "Vers"},
				},
			},
			{
				subCategory = "Weapon",
				items = {
					{itemID = 244028, tag = "Primary"},
					{itemID = 243970, tag = "Crit"},
					{itemID = 243972, tag = "Haste"},
					{itemID = 244030, tag = "Mastery"},
					{itemID = 244001, tag = "Vers"},
					{itemID = 257745, tag = "Crit"},
					{itemID = 257747, tag = "Mastery"},
				},
			},
			{
				subCategory = "Chest",
				items = {
					{itemID = 243976, tag = "Primary"},
				},
			},
			{
				subCategory = "Leg",
				items = {
					{itemID = 240094, tag = "Intelligence"},
					{itemID = 240154, tag = "Mana"},
					{itemID = 244640, tag = "Martial"},
					{itemID = 244642, tag = "Armor"},
				},
			},
			{
				subCategory = "Head",
				items = {
					{itemID = 244006, tag = "Avoidance"},
					{itemID = 243950, tag = "Leech"},
					{itemID = 243980, tag = "Speed"},
				},
			},
			{
				subCategory = "Shoulder",
				items = {
					{itemID = 243990, tag = "Avoidance"},
					{itemID = 244020, tag = "Leech"},
					{itemID = 243962, tag = "Speed"},
				},
			},
			{
				subCategory = "Feet",
				items = {
					{itemID = 243952, tag = "Avoidance"},
					{itemID = 243982, tag = "Leech"},
					{itemID = 244008, tag = "Speed"},
				},
			},
		},
	},
	{
		category = "Crafts",
		subCategories = {
			{
				subCategory = "Missive",
				items = {
					{itemID = 245785, tag = "CritHaste"},
					{itemID = 245789, tag = "CritMastery"},
					{itemID = 245791, tag = "CritVers"},
					{itemID = 245783, tag = "HasteMastery"},
					{itemID = 245781, tag = "HasteVers"},
					{itemID = 245787, tag = "MasteryVers"},
				},
			},
			{
				subCategory = "Embellishment",
				items = {
					{itemID = 248130},
					{itemID = 240167},
					{itemID = 240164},
					{itemID = 251489},
					{itemID = 244603},
					{itemID = 244607},
					{itemID = 244674},
					{itemID = 245871},
					{itemID = 245873},
					{itemID = 245875},
					{itemID = 245877},
				},
			},
		},
	},
}