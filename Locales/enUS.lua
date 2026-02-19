local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true)

L["Welecome"] = "|cff8788ee" .. ADDON_NAME .. "|r: Welcome! Your profile has been reset, and you can set up in: ESC-Options-AddOns-|cff8788ee" .. ADDON_NAME .. "|r"
L["WelecomeInfo"] = "Welecome! Thank you for using |cff8788ee" .. ADDON_NAME .. "|r!"
L["WelecomeSetting"] = "You can change settings with \"|cff8788ee/hblyx|r\" or open configuration panel in ESC-Options-AddOns-|cff8788ee" .. ADDON_NAME .. "|r"
L["WarlockWelecome"] = "Hello, |cff8788eeWarlock|r. Ready to serve you!"
L["GUITitle"] = "|cff8788ee" .. ADDON_NAME .. "|r Configurations Panel"
L["Notifications"] = "Notifications"
L["NotificationContent"] = "The tabs shows modules contained in this addon, you can configure each module separately." .. "\n\n" .. 
"You can find on |cff8788eeHBLyx|r's CurseForge page:" .. "\n" ..
"|cff8788eeHBLyx_Tools|r: a collection of modules including Combat Indicator, Combat Timer, Focus Interrupt and more modules" .. "\n" ..
"|cff8788eeMidnightFocusInterrupt|r: Focus Interrupt module standalone version" .. "\n" ..
"|cff8788eeSharedMedia_HBLyx|r: an AI-generated Chinese sound pack(LibSharedMedia)"

-- MARK: Change Log
L["ChangeLog"] = "Change Log"
L["ChangeLogContent"] =
"v3.8\n" ..
"-Focus Interrupt: Added an option for a target cast bar, which can create a target cast bar similar to the focus cast bar\n" ..
"v3.7\n" ..
"-Custom Auras Tracker: auras can be loaded by specializations(a new corresponding custom option)\n" ..
"v3.6\n" ..
"-Custom Auras Tracker: add a new module \"Custom Aura Tracker\" which Track aura that are triggered by \"player\" and display and play sound alert with customizable options\n"

--MARK: Issues
L["Issues"] = "Issues"
L["AnyIssues"] = "If you encounter any issue, please feedback to the author through the contact information"
L["IssuesContent"] = "Q: Can you add XXX spell as an interrupt spell in Focus Interrupt module?\nA: No, spells with GCD cannot be added due to Blizzard's API restrictions. If you want to add a spell without GCD, please inform me with the spell details" .. "\n\n" ..
"Q: The BattleRes cannot display at the start of some Beta M+ dungeons and \"reload\" can fix it, why?\nA: It is caused by Blizzard's failure to trigger the CHALLENGE_MODE_START event in some dungeons with M+ mode, there is currently no good solution, wait for Blizzard to fix it"

-- MARK: Contact
L["Contact"] = "Contact"
L["GitHub"] = "Submit issue on GitHub"
L["CurseForge"] = "Comments on CurseForge"

-- MARK: Sound Channel
L["SoundChannelSettings"] = "Sound Channel"
L["SoundChannel"] = {
	Master = "Master",
	SFX = "Effects",
	Music = "Music",
	Ambience = "Ambience",
	Dialog = "Dialog",
}

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
L["Profile"] = "Profile"
L["Export"] = "Export"
L["Import"] = "Import"
L["Export/Import"] = "Export/Import"
L["ProfileSettingsDesc"] = "Export and Import your profile with the string below.\n\nExported string contains all modules"
L["ImportSuccess"] = "Profile imported successfully. Please reload your UI to apply the changes."
L["ModuleProfile"] = "Module Profile"
L["ModuleProfileDesc"] = "You can select a module to export/import profile separately.\n\nTo export, select the module below first. To import, the module will be automatically recognized from the string"
L["SelectModule"] = "Select Module"
L["SpellID"] = "Spell ID"
L["Duration"] = "Duration"
L["Cooldown"] = "Cooldown"
L["ActiveSound"] = "Active Sound"
L["ExpireSound"] = "Expire Sound"
L["Add"] = "Add"
L["Remove"] = "Remove"
L["AddSuccess"] = "|cffffff00added|r successfully"
L["AddFailed"] = "Failed to |cffffff00add|r"
L["UpdateSuccess"] = "|cffffff00updated|r successfully"
L["RemoveSuccess"] = "|cffffff00removed|r successfully"
L["RemoveFailed"] = "Failed to |cffffff00remove|r"
L["LoadingSpecs"] = "Loading Specializations"
L["LoadingSpecsDesc"] = "Select the specializations(none or multiple) for which the aura will be active. |cffff0000If none of specializations is selected, the aura will be active for all specializations|r.\n\nWhen you select an existing aura, the specializations information will also be automatically filled."

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

-- MARK: Input
L["InvalidInput"] = "Invalid input, please check all required inputs and their format and type."
L["InvalidSpellID"] = "Invalid spell ID, the spell ID must be a positive integer and must exist in the game."
L["SpellIDNotFound"] = "Spell ID not found in the game."
L["InvalidTime"] = "Invalid time, time inputs must be a non-negative number(float/decimal is allowed) in seconds."

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
L["InteruptSettings"] = "Focus Interupt Settings"
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
-- Target Interrupt Settings
L["TargetBarSettings"] = "Target Cast Bar Settings"
L["TargetBarSettingsDesc"] = "|cffffff00Enable a target cast bar as same as the focus cast bar|r. Most settings are shared, only the style settings below are independent."

-- MARK: BattleRes
L["BattleResSettings"] = "BattleRes Timer"
L["BattleResSettingsDesc"] = "display the cooldown and charges of Battle-Res"
L["HideInactive"] = "Hide When Inactive"

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
L["ChallengeEnhanceScoreSettingsDesc"] = "|cffff0000NOTE: for BigWigs users|r, as recently(02/17/2026) BigWigs added a M+ score display as well, to prevent the overlapping of multiple scores, you may disable the score display of this module."
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

-- MARK: Custom Aura Tracker
L["CustomAuraTrackerSettings"] = "Custom Aura Tracker"
L["CustomAuraTrackerSettingsDesc"] = "Track aura that are triggered by \"player\" and display and play sound alert with customizable options \n\n|cffff0000NOTE|r: this is |cffff0000not a real aura tracker|r, it highly depends on |cffff0000\"UNIT_SPELLCAST_SUCCEEDED\"|r of |cffff0000\"player\"|r. In other words, it can only track things from the cast success event, and it is highly hard-coded(no dynamic duration/cooldown)."
L["AuraSettings"] = "Auras Settings"
L["AuraSettingsDesc"] = "Although the function is limited, but it still can be supportive. For example, you can track your potion and active trinkets\n\n" ..
"Taking 12.0 potion as an example, you can add \"Light's Potential\" with its spell ID(1236616) + duration(30s) + cooldown(300s) + expire sound(X sound effect), and then you will get a 30s icon to show aura when you use the potion and a sound alert played after the cooldown time(300s).\n\n" ..
"You can also use it as a simple sound alert after a period of time after you cast a certain spell. For example, after 300s of using \"health potion\" play a sound effect, you can set spell ID=\"spell ID of health potion\" + duration=0 + cooldown=300 + expire sound\n\n" ..
"|cffff0000NOTE|r: Spell IDs for items are |cffff0000\"spell ID\"|r instead of |cffff0000\"item ID\"|r(you can aquire them with other addon like \"idTip\"), and you can delete/update(delete/add button below) an aura by entering spell ID manually or selecting an existing aura by the dropdown menu below. Additionally, duration and cooldown are in seconds. Eventually, if you want to cancel a sound effect, you can select |cffff0000\"None\"|r for the sound effect to cancel it.\n\n" ..
"|cffffff00TO ADD/UPDATE|r: |cffffff00Spell ID, Duration, and Cooldown are required|r to add/update an aura. Spell ID must be a positive integer and exist in the game, Duration and Cooldown must be non-negative numbers(can be decimal/float or zero).\n\n" ..
"|cffffff00TO REMOVE|r: Only |cffffff00Spell ID is required|r, and it must be an existing aura's spell ID. You can also select an existing aura from the dropdown menu to auto-fill the spell ID for deletion or update."
L["SelectAura"] = "Select an existing aura"