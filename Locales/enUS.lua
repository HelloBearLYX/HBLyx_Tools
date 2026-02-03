local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true)

L["Welecome"] = "|cff8788ee" .. ADDON_NAME .. "|r: Welcome! Your profile has been reset, and you can set up in: ESC-Options-AddOns-|cff8788ee" .. ADDON_NAME .. "|r"
L["WelecomeSetting"] = "you can change settings in ESC-Options-AddOns-|cff8788ee" .. ADDON_NAME .. "|r"
L["WarlockWelecome"] = "Hello, |cff8788eeWarlock|r. Ready to serve you!"

-- MARK: Config
L["Test"] = "Test"
L["Mute"] = "Mute"
L["Enable"] = "Enable"
L["SoundSettings"] = "Sound Settings"
L["PetSettings"] = "Pet Reminder Settings"
L["PetStanceEnable"] = "Enable Pet Stance Check"
L["PetTypeSettings"] = "Enable Pet Type Check"
L["FadeTime"] = "Fade Time"
L["IconSize"] = "Icon Size"
L["BackgroundAlpha"] = "Background Alpha"
L["Texture"] = "Texture"
L["Width"] = "Width"
L["Height"] = "Height"
L["Sound"] = "Sound"
L["HidenInactive"] = "Hide while Inactive"
L["TimeFontSize"] = "Time Font Size"
L["TimeFontScale"] = "Time Font Scale"
L["StackFontSize"] = "Stack/Charge Font Size"
L["Ready"] = "Ready"
L["NotLearned"] = "Not Learned"
L["Reload"] = "Reload(RL)"
L["ReloadDesc"] = "Reload if changed"
L["ReloadNeeded"] = "Need to reload to take effect of changes"
L["ResetModule"] = "Are you sure you want to |cffC41E3Areset settings for this module|r?"
L["IconZoom"] = "Icon Zoom"
L["ResetMod"] = "Reset Module"
L["ComfirmResetMod"] = "Are you sure you want to reset all settings for this module?(also reload UI)"

-- MARK: Style
L["StyleSettings"] = "Style Settings"
L["Font"] = "Font"
L["FontSize"] = "Font Size"
L["X"] = "Horizontal Position"
L["XDesc"] = "Horizontal Position relative to screen center"
L["Y"] = "Vertical Position"
L["YDesc"] = "Vertical Position relative to screen center"
L["InterruptibleColor"] = "Interruptible Color"
L["NotInterruptibleColor"] = "NotInterruptible Color"

-- MARK: Constants
L["PetFamily"] = {
	Felguard = "Felguard",
	Felhunter = "Felhunter",
	Imp = "Imp",
	WRONG = "Wrong Pet!",
}
L["PetStance"] = {
	ASSIST = "",
	DEFENSIVE = "DEFENSIVE",
	PASSIVE = "PASSIVE",
}

-- MARK: Default values
-- combat indicator
L["CombatInSoundDefault"] = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\in-combat.ogg"
L["CombatOutSoundDefault"] = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\out-combat.ogg"
L["CInText"] = "Enter Combat Text"
L["COutText"] = "Leave Combat Text"
L["CombatInText"] = "Enter Combat"
L["CombatOutText"] = "Leave Combat"
-- combat timer
L["TimerPrintTextIntro"] = "Last combat: "
-- focus interrupt
L["FocusDefaultSound"] = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\kick.ogg"
-- warlock reminder
L["PetMissingText"] = "Missing Pet!"
L["CandyMissingText"] = "Missing Candy!"

--MARK: Combat Indicator
L["CombatSettings"] = "Combat Indicator"
L["CombatSettingsDesc"] = "Display a text alert of enter/leave combat"
L["CombatFadeTimeDesc"] = "Combat Indicator Fade Time in seconds after enter/leave combat"
-- combat indicator style settings
L["CombatInColor"] = "Enter Combat Text Color"
L["CombatOutColor"] = "Out Combat Text Color"
-- combat indicator sound settings
L["CombatInSoundMedia"] = "Enter-Combat Sound"
L["CombatOutSoundMedia"] = "Out-Combat Sound"

-- MARK: Combat Timer
L["TimerSettings"] = "Combat Timer"
L["TimerSettingsDesc"] = "Display a Timer(MM:SS) to show the combat duration"
L["TimerCombatShow"] = "Show ONLY in Combat"
L["TimerPrintEnabled"] = "Print to Chat"
L["TimerPrintEnabledDesc"] = "Print last combat duration to Chat(when leave combat)"

-- MARK: Focus Interrupt
L["FocusInterruptSettings"] = "Focus Interrupt"
L["FocusInterruptSettingsDesc"] = "Focus Interrupt alert and Focus Cast Bar settings"
L["Interrupted"] = "Interrupted"
L["InterruptedColor"] = "Interrupted Color"
-- Focus Cast Bar Settings
L["FocusCastBarSettings"] = "Focus Cast Bar Settings"
L["FocusCastBarHidden"] = "Hide Focus Cast Bar"
L["FocusCastBarHiddenDesc"] = "Hide focus cast bar of this addon"
L["FocusColorPriorityDesc"] = "NotInterruptibleColor > InterruptNotReadyColor > InterruptibleColor"
-- Focus Interrupt Settings
L["FocusInteruptSettings"] = "Focus Interupt Settings"
L["FocusInterruptCooldownFilter"] = "Disable when Interrupt NOT Ready"
L["FocusInterruptCooldownFilterDesc"] = "Invisible cast bar when your interrupt spell is on cooldown"
L["FocusInterruptNotReadyColor"] = "Interrupt Not Ready Bar Color"
L["FocusInterruptibleFilter"] = "Disable when NOT Interrupible"
L["FocusInterruptibleFilterDesc"] = "Disable sound and invisible cast bar while a non-interruptible spell is being casting"
L["FocusMuteDesc"] = "Due to Blizzard's restrictions, the sound alert will still play when the interrupt is on cooldown.\n\nRecommend keep sound alert off(this module contains multiple version of visual display to identify focus casting and interrupt information)\n\nNOTE: If other unit frame or cast bar addon (include ElvUI and oUF) disabled Blizzard's Focus Unit Frame/Focus Cast Bar, the sound alert will also play during NOT-interruptible casting(NOT affect visual cast bar). Blizzard's Focus Cast bar is the way to get a non-secret-value information of whether interruptible."
L["FocusInterruptSoundDesc"] = "Sound play when interrupt needed"
L["InterruptedFadeTime"] = "Interrpted Fade Time"
L["InterruptedFadeTimeDesc"] = "How long the cast bar hide after the cast is interrupted(seconds)"

-- MARK: BattleRes
L["BattleResSettings"] = "BattleRes Timer"
L["BattleResSettingsDesc"] = "display the cooldown and charges of Battle-Res"

--MARK: Warlock
L["WarlockReminders"] = "|cff8788eeWarlock|r Reminders"
-- Warlock Pet settings
L["FelguardEnable"] = "Enable Felguard Check"
L["FelguardEnableDesc"] = "With demonology, check whether your pet is a Felguard"
L["FelhunterEnable"] = "Enable Felhunter/Imp Check"
L["FelhunterEnableDesc"] = "With afflication/destruction, check whether your pet is a Felhunter or an imp"
-- Warlock Candy settings
L["CandySetting"] = "Healthstone Reminder Settings"

-- MARK: ChallengeEnhance
L["ChallengeEnhanceSettings"] = "M+ Panel Enhance"
L["ChallengeEnhanceSettingsDesc"] = "Display score and dungeon name and clickable M+ dungeon portal on the M+ Panel"
L["ChallengeEnhanceLevelSettings"] = "Highest Level Settings"
L["ChallengeEnhanceScoreSettings"] = " Score Settings"
L["ChallengeEnhanceNameSettings"] = "Name Settings"
--current season
L["AA"] = "Academy"
L["MT"] = "Magister"
L["MC"] = "Caverns"
L["NPX"] = "Nexus-Point"
L["PS"] = "Pit of Saron"
L["ST"] = "Triumvirate"
L["Skyreach"] = "Skyreach"
L["WS"] = "Windrunner"
-- pre-patch
L["ARAK"] = "Ara-Kara"
L["TD"] = "Dawnbreaker"
L["ED"] = "Eco-Dome"
L["HOA"] = "HoA"
L["OF"] = "Floodgate"
L["PSF"] = "PotSF"
L["GAMBIT"] = "Gambit"
L["STREET"] = "Street"