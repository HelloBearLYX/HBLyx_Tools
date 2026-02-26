local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
addon.data = {}

addon.data.MAP_ENCOUNTER_EVENTS = {
	-- MARK: current season 12.0
    [402] = {
		portalID = 393273,
		name = L["Algeth'ar Academy"],
		short = L["Algeth'ar Academy_short"],
		encounters = {
			[2562] = {events = {274, 275, 276, 277}, journalID = 2509, privateAuras = {386201, 391977}},
			[2563] = {events = {282, 283, 284, 285}, journalID = 2512, privateAuras = {388544, 389033, 396716}},
			[2564] = {events = {278, 279, 280, 397}, journalID = 2495, privateAuras = {376760, 376997, 377009}},
			[2565] = {events = {293, 294, 295, 296}, journalID = 2514, privateAuras = {389007, 389011}},
		},
	},
	[239] = {
		portalID = 1254551,
		name = L["Seat of the Triumvirate"],
		short = L["Seat of the Triumvirate_short"],
		encounters = {
			[2065] = {events = {223, 224, 225, 226, 238}, journalID = 1979, privateAuras = {244588, 244599}},
			[2066] = {events = {234, 235, 236, 237, 243}, journalID = 1980, privateAuras = {245742, 246026, 1263523}},
			[2067] = {events = {246, 247, 376, 245}, journalID = 1981, privateAuras = {1263523, 1263542, 1268733}},
			[2068] = {events = {248, 249, 250, 251, 252, 253, 254}, journalID = 1982, privateAuras = {1265426, 1265650}},
		},
	},
	[559] = {
		portalID = 1254563,
		name = L["Nexus-Point Xenas"],
		short = L["Nexus-Point Xenas_short"],
		encounters = {
			[3328] = {events = {106, 107, 108, 172}, journalID = 2813, privateAuras = {1251626, 1251772, 1264042, 1276485}},
			[3332] = {events = {33, 34, 35, 36, 313}, journalID = 2814, privateAuras = {1247975, 1249020, 1252828}},
			[3333] = {events = {109, 110, 111, 112}, journalID = 2815, privateAuras = {1255310, 1255335, 1255503}},
		},
	},
	[560] = {
		portalID = 1254559,
		name = L["Maisara Caverns"],
		short = L["Maisara Caverns_short"],
		encounters = {
			[3212] = {events = {150, 151, 152, 153, 154, 155}, journalID = 2810, privateAuras = {1243741, 1243752, 1249478, 1260643, 1266488}},
			[3213] = {events = {16, 17, 18, 19, 20}, journalID = 2811, privateAuras = {1251568, 1251775, 1251813, 1251833, 1252130, 1266706}},
			[3214] = {events = {156, 157, 158}, journalID = 2812, privateAuras = {1251023, 1252675, 1252777, 1252816, 1253779, 1253844, 1254043, 1254175, 1255629, 1266188}},
		},
	},
	[161] = {
		portalID = 1254557,
		name = L["Skyreach"],
		short = L["Skyreach_short"],
		encounters = {
			[1698] = {events = {298, 299, 300, 301}, journalID = 965, privateAuras = {153757, 1252733}},
			[1699] = {events = {302, 303, 304}, journalID = 966, privateAuras = {154150}},
			[1700] = {events = {305, 306, 308, 603}, journalID = 967, privateAuras = {1253511, 1253520}},
			[1701] = {events = {309, 310, 311, 312}, journalID = 968, privateAuras = {153954, 1253541}},
		},
	},
	[557] = {
		portalID = 1254400,
		name = L["Windrunner Spire"],
		short = L["Windrunner Spire_short"],
		encounters = {
			[3056] = {events = {239, 241, 242}, journalID = 2655, privateAuras = {466091, 466559, 470212, 472118}},
			[3057] = {events = {25, 26, 27, 28, 29}, journalID = 2656, privateAuras = {472777, 472793, 472888, 474129, 1253834, 1215803, 1219491, 1282272}},
			[3058] = {events = {210, 211, 213, 212, 214, 215, 216}, journalID = 2657, privateAuras = {467620, 468659, 470966, 1283247, 1253030}},
			[3059] = {events = {21, 22, 23, 24, 538}, journalID = 2658, privateAuras = {468442, 472662, 474528, 1282911, 1216042, 1253979, 1282955}},
		},
	},
	[558] = {
		portalID = 1254572,
		name = L["Magister's Terrace"],
		short = L["Magister's Terrace_short"],
		encounters = {
			[3071] = {events = {281, 286, 287, 288}, journalID = 2659, privateAuras = {1214038, 1214089, 1243905}},
			[3072] = {events = {93, 94, 95, 513, 96}, journalID = 2661, privateAuras = {1225015, 1225205, 1225792, 1246446}},
			[3073] = {events = {635, 97, 98, 99, 100}, journalID = 2660, privateAuras = {1224140, 1224401, 1284958, 1224299, 1253709}},
			[3074] = {events = {290, 292, 420}, journalID = 2662, privateAuras = {1215157, 1215161, 1215897, 1269631}},
		},
	},
	[556] = {
		portalID = 1254555,
		name = L["Pit of Saron"],
		short = L["Pit of Saron_short"],
		encounters = {
			[1999] = {events = {144, 145, 146, 147}, journalID = 608, privateAuras = {1261286, 1261799}},
			[2000] = {events = {164, 165, 166, 167, 168, 375}, journalID = 610, privateAuras = {1262772}},
			[2001] = {events = {203, 204, 205, 206, 561}, journalID = 609, privateAuras = {1264453, 1264299}},
		},
	},
    -- MARK: Pre-patch 11.2.7
    [503] = {portalID = 445417, short = L["ARAK"]},
    [505] = {portalID = 445414, short = L["TD"]},
    [542] = {portalID = 1237215, short = L["ED"]},
    [378] = {portalID = 354465, short = L["HOA"]},
    [525] = {portalID = 1216786, short = L["OF"]},
    [499] = {portalID = 445444, short = L["PSF"]},
    [392] = {portalID = 367416, short = L["GAMBIT"]},
    [391] = {portalID = 367416, short = L["STREET"]}
}