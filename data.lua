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
			[2067] = {events = {246, 247, 376, 245}, journalID = 1981, privateAuras = {1263542, 1268733}},
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
			[3073] = {events = {635, 97, 98, 100}, journalID = 2660, privateAuras = {1224104, 1224401, 1284958, 1224299, 1253709}},
			[3074] = {events = {290, 292, 420}, journalID = 2662, privateAuras = {1215157, 1215161, 1215897, 1269631}},
		},
	},
	[556] = {
		portalID = 1254555,
		name = L["Pit of Saron"],
		short = L["Pit of Saron_short"],
		encounters = {
			[1999] = {events = {144, 145, 146, 147}, journalID = 608, privateAuras = {1261286, 1261799}},
			[2000] = {events = {164, 165, 166, 167, 168, 375}, journalID = 610, privateAuras = {1262772, 1262596}},
			[2001] = {events = {203, 204, 205, 206, 561}, journalID = 609, privateAuras = {1264186, 1264453, 1264299}},
		},
	},
	-- MARK: M5 Dungeons 
	[1309] = {
		portalID = 000000,
		name = select(1, EJ_GetInstanceInfo(1309)) or "The Blinding Vale",
		encounters = {
			[3199] = {
				events = {177, 173, 174, 175, 176},
				journalID = 2769,
				privateAuras = {1234802, 1235574, 1235828, 1235865}
			},
			[3200] = {
				events = {179, 180, 178},
				journalID = 2770,
				privateAuras = {1237091, 1237267, 1272290}
			},
			[3201] = {
				events = {181, 182, 184, 188, 115, 183},
				journalID = 2771,
				privateAuras = {1239825, 1239919, 1241058, 1251345, 1257094}
			},
			[3202] = {
				events = {192, 191, 189, 190},
				journalID = 2772,
				privateAuras = {1246751, 1246753, 1247746}
			},
		},
	},
	[1304] = {
		portalID = 000000,
		name = select(1, EJ_GetInstanceInfo(1304)) or "Murder Row",
		encounters = {
			[3101] = {
				events = {610, 202, 122, 120},
				journalID = 2679,
				privateAuras = {1228198}
			},
			[3102] = {
				events = {124, 127, 193, 123, 125},
				journalID = 2680,
				privateAuras = {474515, 474545, 1214352}
			},
			[3103] = {
				events = {30, 31, 559, 32},
				journalID = 2681,
				privateAuras = {473898, 474234, 1214650}
			},
			[3105] = {
				events = {37, 207},
				journalID = 2682,
				privateAuras = {}
			},
		},
	},
	[1311] = {
		portalID = 000000,
		name = select(1, EJ_GetInstanceInfo(1311)) or "Den of Nalorakk",
		encounters = {
			[3207] = {
				events = {86, 87, 88},
				journalID = 2776,
				privateAuras = {1234846, 1235125}
			},
			[3208] = {
				events = {67, 70, 68, 69},
				journalID = 2777,
				privateAuras = {1235549, 1235829, 1235841, 1235641, 1236289}
			},
			[3209] = {
				events = {92, 90, 89, 91},
				journalID = 2778,
				privateAuras = {1242869, 1243590, 1255577, 1262253, 1261781}
			},

		},
	},
	[1313] = {
		portalID = 000000,
		name = select(1, EJ_GetInstanceInfo(1313)) or "Voidscar Arena",
		encounters = {
			[3285] = {
				events = {39, 558, 40, 42, 41},
				journalID = 2791,
				privateAuras = {1222103, 1262283}
			},
			[3286] = {
				events = {297, 47, 54, 55, 46, 557},
				journalID = 2792,
				privateAuras = {1222484, 1222642, 1226031, 1263971}
			},
			[3287] = {
				events = {56, 57, 58, 171},
				journalID = 2793,
				privateAuras = {1227197, 1248130, 1264188}
			},

		},
	},
    -- MARK: Raid
	[1314] = {
		portalID = 000000,
		name = select(1, EJ_GetInstanceInfo(1314)) or "The Dreamrift",
		encounters = {
			[3306] = {
				events = {118, 117, 307, 119, 51, 53, 458, 50, 149, 431, 555, 49, 217, 48},
				journalID = 2795,
				privateAuras = {1245698, 1262020, 1250953, 1253744, 1264756, 1272726, 1246653, 1257087}
			},
		},
	},
	[1307] = {
		portalID = 000000,
		name = select(1, EJ_GetInstanceInfo(1307)) or "The Voidspire",
		encounters = {
			[3176] = {
				events = {197, 200, 194, 195, 201, 198, 492, 199, 209, 419, 196},
				journalID = 2733,
				privateAuras = {1275059, 1280075, 1284786, 1265540, 1283069}
			},
			[3177] = {
				events = {133, 59, 60, 62, 61},
				journalID = 2734,
				privateAuras = {1259186, 1272527, 1243270, 1241844}
			},
			[3179] = {
				events = {140, 143, 148, 141, 142, 139},
				journalID = 2736,
				privateAuras = {1250828, 1245960, 1250991, 1245592, 1251213, 1248697, 1248709, 1250686}
			},
			[3178] = {
				events = {104, 105, 221, 220, 551, 101, 102, 381, 103},
				journalID = 2735,
				privateAuras = {1244672, 1252157, 1264467, 1245554, 1270852, 1245175, 1265152, 1255763}
			},
			[3180] = {
				events = {74, 80, 85, 79, 365, 78, 82, 71, 81, 75, 77, 373, 358, 359, 360, 535, 83, 374, 84, 76, 73},
				journalID = 2737,
				privateAuras = {1276982, 1272324, 1246736, 1251857, 1249130, 1258514}
			},
			[3181] = {
				events = {15, 8, 12, 66, 65, 11, 131, 4, 14, 132, 13, 10, 5, 9, 137, 7, 6, 64},
				journalID = 2738,
				privateAuras = {1233602, 1242553, 1233865, 1243753, 1238206, 1237038, 1232470, 1238708}
			},
		},
	},
	[1308] = {
		portalID = 000000,
		name = select(1, EJ_GetInstanceInfo(1308)) or "March on Quel'Danas",
		encounters = {
			[3182] = {
				events = {130, 494, 482, 384, 497, 134, 272, 138, 161, 273, 218, 495, 483, 385, 128},
				journalID = 2739,
				privateAuras = {1245698, 1262020, 1250953, 1253744, 1264756, 1272726, 1246653, 1257087}
			},
			[3183] = {
				events = {632, 259, 261, 364, 256, 434, 363, 437, 435, 362, 255, 433, 258, 636, 260, 405, 263, 262, 436, 650, 649, 644},
				journalID = 2740,
				privateAuras = {1282027, 1249609, 1249584, 1251789, 1284699, 1265842, 1262055, 1281184, 1266113, 1253104}
			},
		},
	},
}