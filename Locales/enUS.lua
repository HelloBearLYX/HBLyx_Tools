local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true)

L["Welecome"] = "|cff8788ee" .. ADDON_NAME .. "|r: Welcome! Your profile has been reset, and you can set up in: ESC-Options-AddOns-|cff8788ee" .. ADDON_NAME .. "|r"
L["WelecomeInfo"] = "Welecome! Thank you for using |cff8788ee" .. ADDON_NAME .. "|r!"
L["WelecomeSetting"] = "You can change settings with \"|cff8788ee/hblyx|r\" or open configuration panel in ESC-Options-AddOns-|cff8788ee" .. ADDON_NAME .. "|r"
L["WarlockWelecome"] = "Hello, |cff8788eeWarlock|r. Ready to serve you!"
L["GUITitle"] = "|cff8788ee" .. ADDON_NAME .. "|r Configurations Panel"
L["Notifications"] = "Notifications"
L["NotificationContent"] = "The tabs shows modules contained in this addon, you can configure each module separately. The profile sharing feature is in development, but you can use screenshot to share your settings for now."
--MARK: Issues
L["Issues"] = "Issues"
L["AnyIssues"] = "If you encounter any issues, please report them to the addon author through the contact information"
L["IssuesContent"] = "The profile sharing feature is in development\n" ..
"\nQ: Will there be a target version for the Focus Interrupt module?\nA: No plan for it, the target cast bar is too redundant with other addons"
-- MARK: Contact
L["Contact"] = "Contact"
L["GitHub"] = "Submit issue on GitHub"
L["CurseForge"] = "Comments on CurseForge"

-- MARK: Config
L["Test"] = "Test/Unlock(Drag to Move)"
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
L["TimeFontScale"] = "Time Font Scale"
L["StackFontSize"] = "Stack/Charge Font Size"
L["Reminders"] = "Reminders"
L["Ready"] = "Ready"
L["NotLearned"] = "Not Learned"
L["Reload"] = "Reload(RL)"
L["ReloadNeeded"] = "Need to reload to take effect of changes"
L["IconZoom"] = "Icon Zoom"
L["ResetMod"] = "Reset Module"
L["ComfirmResetMod"] = "Are you sure you want to reset all settings for this module?(also reload UI)"
L["Anchor"] = "Anchor"
L["Grow"] = "Grow Direction"
L["General"] = "General"

-- MARK: Style
L["StyleSettings"] = "Style Settings"
L["Font"] = "Font"
L["FontSize"] = "Font Size"
L["FontSettings"] = "Font Settings"
L["X"] = "Horizontal Position"
L["Y"] = "Vertical Position"
L["PositionSettings"] = "Position Settings"
L["IconSettings"] = "Icon Settings"
L["TextureSettings"] = "Texture Settings"
L["SizeSettings"] = "Size Settings"
L["ColorSettings"] = "Color Settings"
L["TextSettings"] = "Text Settings"
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
	ASSIST = "ASSIST",
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
L["CombatIndicatorTextDesc"] = "Text displayed when enter/leave combat"
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

-- MARK: Focus Interrupt
L["FocusInterruptSettings"] = "Focus Interrupt"
L["FocusInterruptSettingsDesc"] = "Focus Interrupt alert and Focus Cast Bar settings"
L["Interrupted"] = "Interrupted"
L["InterruptedColor"] = "Interrupted Color"
-- Focus Cast Bar Settings
L["FocusCastBarHidden"] = "Hide Focus Cast Bar"
L["FocusColorPriorityDesc"] = "NotInterruptibleColor > InterruptibleColor > InterruptNotReadyColor"
L["ShowTotalTime"] = "Show Total Time"
-- Focus Interrupt Settings
L["FocusInteruptSettings"] = "Focus Interupt Settings"
L["FocusInterruptCooldownFilter"] = "Disable when Interrupt NOT Ready"
L["FocusInterruptNotReadyColor"] = "Interrupt Not Ready Color"
L["FocusInterruptibleFilter"] = "Disable when NOT Interrupible"
L["FocusMuteDesc"] = "Due to Blizzard's restrictions(02/06/2026), the sound alert will still play no matter how cast is\n\nRecommend keep sound alert off(this module contains multiple version of visual display to identify focus casting and interrupt information)"
L["InterruptedFadeTime"] = "Interrpted Fade Time"
L["ShowInterrupter"] = "Show Interrupter"
L["ShowTarget"] = "Show Target"
L["InterruptedSettings"] = "Interrupted Settings"
L["InterruptedSettingsDesc"] = "When the focus is interrupted, there is a short fade time for the cast bar, you can make the fade time zero to make it disappear immediately.\n\nAlso, there is information showing during the fade time"
L["InterruptIconsSettings"] = "Interrupt Icon Settings"
L["InterruptIconDesc"] = "When the player is capable of interrupt(interruptible + interrupt ready), display an icon of interrupt\n\nThis is mainly designed for Demonology Warlock, display which interrupt is available"
L["ShowDemoWarlockOnly"] = "Show Only if Demonology Warlock"
 
-- MARK: BattleRes
L["BattleResSettings"] = "BattleRes Timer"
L["BattleResSettingsDesc"] = "display the cooldown and charges of Battle-Res"

--MARK: Warlock
L["WarlockReminders"] = "|cff8788eeWarlock|r Reminders"
L["WarlockRemindersIntro"] = "This module provides pet and healthstone reminders\n\nThe reminder will show up when you are missing your pet/healthstone(or incorrect pet stance/type)"
-- Warlock Pet settings
L["PetTypeSettingsDesc"] = "Felguard check for Demonology, and Felhunter/Imp check for other specs"
L["FelguardEnable"] = "Enable Felguard Check"
L["FelhunterEnable"] = "Enable Felhunter/Imp Check"
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