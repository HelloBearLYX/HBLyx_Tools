local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
addon.data = {}

-- MARK: UNKNOWN_SPELL_TEXTURE
addon.data.UNKNOWN_SPELL_TEXTURE = 134400

addon.data.MAP_ENCOUNTER_EVENTS = {
	-- MARK: current season 12.0
    [402] = {
		portalID = 393273,
		name = L["Algeth'ar Academy"],
		short = L["Algeth'ar Academy_short"],
		encounters = {
			[2562] = {274, 275, 276, 277},
			[2563] = {282, 283, 284, 285},
			[2564] = {278, 279, 280, 397},
			[2565] = {293, 294, 295, 296},
		},
	},
	[239] = {
		portalID = 1254551,
		name = L["Seat of the Triumvirate"],
		short = L["Seat of the Triumvirate_short"],
		encounters = {
			[2065] = {223, 224, 225, 226, 238},
			[2066] = {234, 235, 236, 237, 243},
			[2067] = {246, 247, 376, 245},
			[2068] = {248, 249, 250, 251, 252, 253, 254},
		},
	},
	[559] = {
		portalID = 1254563,
		name = L["Nexus-Point Xenas"],
		short = L["Nexus-Point Xenas_short"],
		encounters = {
			[3328] = {106, 107, 108, 172},
			[3332] = {33, 34, 35, 36, 313},
			[3333] = {109, 110, 111, 112},
		},
	},
	[560] = {
		portalID = 1254559,
		name = L["Maisara Caverns"],
		short = L["Maisara Caverns_short"],
		encounters = {
			[3212] = {150, 151, 152, 153, 154, 155},
			[3213] = {16, 17, 18, 19, 20},
			[3214] = {156, 157, 158},
		},
	},
	[161] = {
		portalID = 1254557,
		name = L["Skyreach"],
		short = L["Skyreach_short"],
		encounters = {
			[1698] = {298, 299, 300, 301},
			[1699] = {302, 303, 304},
			[1700] = {305, 306, 308, 603},
			[1701] = {309, 310, 311, 312},
		},
	},
	[557] = {
		portalID = 1254400,
		name = L["Windrunner Spire"],
		short = L["Windrunner Spire_short"],
		encounters = {
			[3056] = {239, 241, 242},
			[3057] = {25, 26, 27, 28, 29},
			[3058] = {210, 211, 213, 212, 214, 215, 216},
			[3059] = {21, 22, 23, 24, 538},
		},
	},
	[558] = {
		portalID = 1254572,
		name = L["Magister's Terrace"],
		short = L["Magister's Terrace_short"],
		encounters = {
			[3071] = {281, 286, 287, 288},
			[3072] = {93, 94, 95, 513, 96},
			[3073] = {635, 97, 98, 99, 100},
			[3074] = {290, 292, 420},
		},
	},
	[556] = {
		portalID = 1254555,
		name = L["Pit of Saron"],
		short = L["Pit of Saron_short"],
		encounters = {
			[2001] = {203, 204, 205, 206, 561},
			[1999] = {144, 145, 146, 147},
			[2000] = {164, 165, 166, 167, 168, 375},
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