local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
addon.data = {}

addon.data.SEASON_MAP = {
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
		portalID = 1286809,
		name = select(1, EJ_GetInstanceInfo(1304)) or "Murder Row",
		short = L["Murder Row_short"],
	},
	[586] = {
		enabled = true,
		instanceID = 2825,
		journalInstanceID = 1311,
		portalID = 1286807,
		name = select(1, EJ_GetInstanceInfo(1311)) or "Den of Nalorakk",
		short = L["Den of Nalorakk_short"],
	},
	[585] = {
		enabled = true,
		instanceID = 2923,
		journalInstanceID = 1313,
		portalID = 1286804,
		name = select(1, EJ_GetInstanceInfo(1313)) or "Voidscar Arena",
		short = L["Voidscar Arena_short"],
	},
	[584] = {
		enabled = true,
		instanceID = 2859,
		journalInstanceID = 1309,
		portalID = 1286801,
		name = select(1, EJ_GetInstanceInfo(1309)) or "The Blinding Vale",
		short = L["The Blinding Vale_short"],
	},
	-- DF 10.0
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
		portalID = 1286828,
		name = select(1, EJ_GetInstanceInfo(1030)) or "Temple of Sethraliss",
		short = L["Temple of Sethraliss_short"],
	},
	[249] = {
		enabled = true,
		instanceID = 1762,
		portalID = 1286831,
		journalInstanceID = 1041,
		name = select(1, EJ_GetInstanceInfo(1041)) or "King's Rest",
		short = L["King's Rest_short"],
	},
}

-- MARK: Aura Helper
addon.data.AURA_HELPER = {
	-- the type decides whether the container tracks buffs or debuffs, it is required and is not a filter
	TYPES = {
		Helpful = {value = "HELPFUL", category = "Buff", name = L["AuraFilter"]["Helpful"]},
		Harmful = {value = "HARMFUL", category = "Debuff", name = L["AuraFilter"]["Harmful"]},
	},
	FILTERS = {
		-- token filters, the values are string
		Player = {value = "PLAYER", category = "Both", name = L["AuraFilter"]["Player"]},
		Raid = {value = "RAID", category = "Both", name = L["AuraFilter"]["Raid"]},
		Defensive = {value = "BIG_DEFENSIVE", category = "Buff", name = L["AuraFilter"]["Defensive"]},
		-- External = {value = "EXTERNAL_DEFENSIVE", category = "Buff", name = L["AuraFilter"]["External"]},
		CrowdControl = {value = "CROWD_CONTROL", category = "Debuff", name = L["AuraFilter"]["CrowdControl"]},
		Dispellable = {value = "DISPELLABLE", category = "Both", name = L["AuraFilter"]["Dispellable"]},
		-- candidate filters, the values are table
		NonPlayer = {value = {isFromPlayerOrPlayerPet = false}, category = "Both", name = L["AuraFilter"]["NonPlayer"]},
		Role = {value = {isRoleAura = true}, category = "Both", name = L["AuraFilter"]["Role"]},
		Priority = {value = {isPriorityAura = true}, category = "Both", name = L["AuraFilter"]["Priority"]},
		Stealable = {value = {isStealableAura = true}, category = "Both", name = L["AuraFilter"]["Stealable"]},
		Boss = {value = {isBossAura = true}, category = "Both", name = L["AuraFilter"]["Boss"]},
		-- HBLyx made filters
		PI = {value = {includeSpellIDs = {
			[10060] = true, -- Power Infusion
			[406732] = true, -- Spatial Paradox
			[29166] = true, -- Innervate
			-- movement
			[192082] = true, -- Wind Rush Totem
			[106898] = true, -- Stampeding Roar
			[77761] = true, -- Stampeding Roar(Bear)
			[77764] = true, -- Stampeding Roar(Cat)
			[1044] = true, -- Bless of Freedom
			[116841] = true, -- Tiger's Lust
			-- external defensive
			[33206] = true, -- Pain Suppression
			[47788] = true, -- Guardian Spirit
			[102342] = true, -- Ironbark
			[116849] = true, -- Life Cocoon
			[6940] = true, -- Bless of Sacrifice
			[1022] = true, -- Bless of Protection
			[204018] = true, -- Blessing of Spellwarding
			[357170] = true, -- Time Dilation
			[3411] = true, -- Intervene
			-- team defensive
			[31821] = true, -- Aura Mastery
			[81782] = true, -- Power Word: Barrier
			[325174] = true, -- Spirit Link Totem
			[97463] = true, -- Rallying Cry
			[145629] = true, -- Anti-Magic Zone
			[209426] = true, -- Darkness
			[374227] = true, -- Zephyr
		}}, category = "Buff", name = L["AuraFilter"]["Power_Infusion"], isAddonMade = true},
		PDefensive = {value = {includeSpellIDs = {
			-- Death Knight
			[48792] = true, -- Icebound Fortitude
			[48707] = true, -- Anti-Magic Shell
			[49039] = true, -- Lichborne
			[55233] = true, -- Vampiric Blood-Tank
			[49028] = true, -- Dancing Rune Weapon-Tank
			-- Demon Hunter
			[198589] = true, -- Blur
			[196555] = true, -- Netherwalk
			[187827] = true, -- Metamorphosis-Tank
			-- Druid
			[22812] = true, -- Barkskin
			[61336] = true, -- Survival Instincts
			[102558] = true, -- Incarnation: Guardian of Ursoc-Tank
			[204066] = true, -- Lunar Beam-Tank
			-- Evoker
			[363916] = true, -- Obsidian Scales
			-- Hunter
			[186265] = true, -- Aspect of the Turtle
			[264735] = true, -- Survival of the Fittest
			-- Mage
			[45438] = true, -- Ice Block
			[110959] = true, -- Greater Invisibility
			[55342] = true, -- Mirror Image
			-- Monk
			[115203] = true, -- Fortifying Brew
			[122278] = true, -- Dampen Harm
			[322507] = true, -- Celestial Brew-Tank
			-- Paladin
			[642] = true, -- Divine Shield
			[403876] = true, -- Divine Protection
			[86659] = true, -- Guardian of Ancient Kings-Tank
			[31850] = true, -- Ardent Defender-Tank
			-- Priest
			[47585] = true, -- Dispersion
			[19236] = true, -- Desperate Prayer
			[586] = true, -- Fade
			-- Rogue
			[31224] = true, -- Cloak of Shadows
			[5277] = true, -- Evasion
			[1966] = true, -- Feint
			-- Shaman
			[108271] = true, -- Astral Shift
			[381755] = true, -- Earth Element
			-- Warlock
			[104773] = true, -- Unending Resolve
			[108416] = true, -- Dark Pact
			-- Warrior
			[184364] = true, -- Enraged Regeneration
			[118038] = true, -- Die by the Sword
			[335255] = true, -- Spell Reflection
			[871] = true, -- Shield Wall-Tank
		}}, category = "Buff", name = L["AuraFilter"]["Personal_Defensive"], isAddonMade = true},
		LUST = {value = {includeSpellIDs = {
			[2825] = true, -- Bloodlust
			[32182] = true, -- Heroism
			[80353] = true, -- Time Warp
			[264689] = true, -- Primal Rage
			[390386] = true, -- Fury of the Aspects
			[466904] = true, -- Marksman Hunter's
			[1243972] = true, -- Drums
		}}, category = "Buff", name = L["AuraFilter"]["Bloodlust"], isAddonMade = true},
		EXHAUSTION = {value = {excludeSpellIDs = {
			[57723] = true, -- Exhaustion
			[57724] = true, -- Sated
			[80354] = true, -- Temporal Displacement
			[264689] = true, -- Fatigue
		}}, category = "Debuff", name = L["AuraFilter"]["ExcludingExhaustion"], isAddonMade = true},
		-- TRINKET = {value = {includeSpellIDs = {
		-- }}, category = "Buff", name = L["AuraFilter"]["Trinkets"]},
		POTION = {value = {includeSpellIDs = {
			[1236616] = true, -- Light's Potential
			[1236994] = true, -- Potion of Recklessness
			[1236998] = true, -- Draught of Rampant Abandon
			[1295147] = true, -- Liquid Luster
			[1236551] = true, -- Void-Shrouded Tincture
		}}, category = "Buff", name = L["AuraFilter"]["Potions"], isAddonMade = true},
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
					{itemID = 272194, tag = "Vantus"},
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
					{itemID = 271887, tag = "Vers"},
					{itemID = 241304, tag = "Health"},
					{itemID = 271884, tag = "Health"},
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
					{itemID = 243958, tag = "Mastery"},
					{itemID = 244016, tag = "Vers"},
				},
			},
			{
				subCategory = "Weapon",
				items = {
					{itemID = 244028, tag = "Primary"},
					{itemID = 273071, tag = "Secondary"},
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
					{itemID = 273059},
				},
			},
		},
	},
}