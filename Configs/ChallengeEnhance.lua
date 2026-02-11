local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "ChallengeEnhance"

-- MARK: Safe update
local function update()
    return addon.core:GetSafeUpdate(MOD_KEY)()
end

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
    Enabled = true,
    Font = "",
    -- level settings
    LevelEnabled = true,
    LevelFontSize = 20,
    LevelX = 0,
    LevelY = -1,
    -- score settings
    ScoreEnabled = true,
    ScoreFontSize = 20,
    ScoreX = 0,
    ScoreY = -5,
    -- name settings
    NameEnabled = true,
    NameFontSize = 12,
    NameX = 0,
    NameY = 2,
}

-- GUI
GUI.TagPanels.ChallengeEnhance = {}
function GUI.TagPanels.ChallengeEnhance:CreateTabPanel(parent)
    -- MARK: General
    local frame = GUI:CreateScrollFrame(parent)
    frame:SetLayout("Flow")
	frame:SetFullWidth(true)

    GUI:CreateInformationTag(frame, L["ChallengeEnhanceSettingsDesc"], "LEFT")
    GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["ChallengeEnhanceSettings"] .. "|r", addon.db.ChallengeEnhance.Enabled, function(value)
        addon.db.ChallengeEnhance.Enabled = value
        addon:ShowDialog(ADDON_NAME.."RLNeeded")
    end)
    GUI:CreateFontSelect(frame, L["Font"], addon.db.ChallengeEnhance.Font, function(value)
        addon.db.ChallengeEnhance.Font = value
        update()
    end)
    GUI:CreateButton(frame, L["ResetMod"], function ()
        addon.Utilities:SetPopupDialog(
            ADDON_NAME .. "ResetMod",
            "|cffC41E3A" .. L["ChallengeEnhanceSettings"] .. "|r: " .. L["ComfirmResetMod"],
            true,
            {button1 = YES, button2 = NO, OnButton1 = function ()
                addon.Utilities:ResetModule(MOD_KEY)
                ReloadUI()
            end}
        )
    end)

    -- MARK: Level Settings
    local levelGroup = GUI:CreateInlineGroup(frame, L["ChallengeEnhanceLevelSettings"])
    GUI:CreateToggleCheckBox(levelGroup, L["Enable"], addon.db.ChallengeEnhance.LevelEnabled, function(value)
        addon.db.ChallengeEnhance.LevelEnabled = value
        update()
    end)
    GUI:CreateSlider(levelGroup, L["FontSize"], 6, 40, 1, addon.db.ChallengeEnhance.LevelFontSize, function(value)
        addon.db.ChallengeEnhance.LevelFontSize = value
        update()
    end)
    GUI:CreateSlider(levelGroup, L["X"], -50, 50, 1, addon.db.ChallengeEnhance.LevelX, function(value)
        addon.db.ChallengeEnhance.LevelX = value
        update()
    end)
    GUI:CreateSlider(levelGroup, L["Y"], -50, 50, 1, addon.db.ChallengeEnhance.LevelY, function(value)
        addon.db.ChallengeEnhance.LevelY = value
        update()
    end)

    -- MARK: Score Settings
    local scoreGroup = GUI:CreateInlineGroup(frame, L["ChallengeEnhanceScoreSettings"])
    GUI:CreateToggleCheckBox(scoreGroup, L["Enable"], addon.db.ChallengeEnhance.ScoreEnabled, function(value)
        addon.db.ChallengeEnhance.ScoreEnabled = value
        update()
    end)
    GUI:CreateSlider(scoreGroup, L["FontSize"], 6, 40, 1, addon.db.ChallengeEnhance.ScoreFontSize, function(value)
        addon.db.ChallengeEnhance.ScoreFontSize = value
        update()
    end)
    GUI:CreateSlider(scoreGroup, L["X"], -50, 50, 1, addon.db.ChallengeEnhance.ScoreX, function(value)
        addon.db.ChallengeEnhance.ScoreX = value
        update()
    end)
    GUI:CreateSlider(scoreGroup, L["Y"], -50, 50, 1, addon.db.ChallengeEnhance.ScoreY, function(value)
        addon.db.ChallengeEnhance.ScoreY = value
        update()
    end)

    -- MARK: Name Settings
    local nameGroup = GUI:CreateInlineGroup(frame, L["ChallengeEnhanceNameSettings"])
    GUI:CreateToggleCheckBox(nameGroup, L["Enable"], addon.db.ChallengeEnhance.NameEnabled, function(value)
        addon.db.ChallengeEnhance.NameEnabled = value
        update()
    end)
    GUI:CreateSlider(nameGroup, L["FontSize"], 6, 40, 1, addon.db.ChallengeEnhance.NameFontSize, function(value)
        addon.db.ChallengeEnhance.NameFontSize = value
        update()
    end)
    GUI:CreateSlider(nameGroup, L["X"], -50, 50, 1, addon.db.ChallengeEnhance.NameX, function(value)
        addon.db.ChallengeEnhance.NameX = value
        update()
    end)
    GUI:CreateSlider(nameGroup, L["Y"], -50, 50, 1, addon.db.ChallengeEnhance.NameY, function(value)
        addon.db.ChallengeEnhance.NameY = value
        update()
    end)

    return frame
end