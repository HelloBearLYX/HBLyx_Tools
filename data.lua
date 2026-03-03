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
		portalID = 1254557,
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