local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "ChallengeEnhance"

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
    Enabled = true,
    Font = "",
    PortalPartyMessage = true,
    -- level settings
    LevelEnabled = true,
    LevelFontSize = 20,
    LevelX = 0,
    LevelY = -10,
    LevelAnchor = "TOP",
    -- score settings
    ScoreEnabled = true,
    ScoreFontSize = 20,
    ScoreX = 0,
    ScoreY = 0,
    ScoreAnchor = "CENTER",
    -- name settings
    NameEnabled = true,
    NameFontSize = 12,
    NameX = 0,
    NameY = 0,
    NameAnchor = "BOTTOM",
}

-- MARK: Safe update
local function update()
    return addon.core:GetSafeUpdate(MOD_KEY)()
end

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
    GUI:CreateToggleCheckBox(frame, L["PortalPartyMessage"], addon.db.ChallengeEnhance.PortalPartyMessage, function(value)
        addon.db.ChallengeEnhance.PortalPartyMessage = value
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
    local levelFontSizeSlider = GUI:CreateSlider(nil, L["FontSize"], 6, 40, 1, addon.db.ChallengeEnhance.LevelFontSize, function(value)
        addon.db.ChallengeEnhance.LevelFontSize = value
        update()
    end)
    local levelXSlider = GUI:CreateSlider(nil, L["X"], -100, 100, 1, addon.db.ChallengeEnhance.LevelX, function(value)
        addon.db.ChallengeEnhance.LevelX = value
        update()
    end)
    local levelYSlider = GUI:CreateSlider(nil, L["Y"], -100, 100, 1, addon.db.ChallengeEnhance.LevelY, function(value)
        addon.db.ChallengeEnhance.LevelY = value
        update()
    end)
    local levelAnchorDropdown = GUI:CreateDropdown(nil, L["Anchor"], {TOP = "TOP", CENTER = "CENTER", BOTTOM = "BOTTOM"}, nil, addon.db.ChallengeEnhance.LevelAnchor, function(value)
        addon.db.ChallengeEnhance.LevelAnchor = value
        update()
    end, {"TOP", "CENTER", "BOTTOM"})
    GUI:CreateToggleCheckBox(levelGroup, L["Enable"], addon.db.ChallengeEnhance.LevelEnabled, function(value)
        addon.db.ChallengeEnhance.LevelEnabled = value
        levelFontSizeSlider:SetDisabled(not value)
        levelXSlider:SetDisabled(not value)
        levelYSlider:SetDisabled(not value)
        levelAnchorDropdown:SetDisabled(not value)
        update()
    end):SetRelativeWidth(0.15)
    levelFontSizeSlider:SetRelativeWidth(0.2)
    levelXSlider:SetRelativeWidth(0.2)
    levelYSlider:SetRelativeWidth(0.2)
    levelAnchorDropdown:SetRelativeWidth(0.2)
    levelFontSizeSlider:SetDisabled(not addon.db.ChallengeEnhance.LevelEnabled)
    levelXSlider:SetDisabled(not addon.db.ChallengeEnhance.LevelEnabled)
    levelYSlider:SetDisabled(not addon.db.ChallengeEnhance.LevelEnabled)
    levelAnchorDropdown:SetDisabled(not addon.db.ChallengeEnhance.LevelEnabled)
    levelGroup:AddChild(levelFontSizeSlider)
    levelGroup:AddChild(levelXSlider)
    levelGroup:AddChild(levelYSlider)
    levelGroup:AddChild(levelAnchorDropdown)

    -- MARK: Score Settings
    local scoreGroup = GUI:CreateInlineGroup(frame, L["ChallengeEnhanceScoreSettings"])
    GUI:CreateInformationTag(scoreGroup, L["ChallengeEnhanceScoreSettingsDesc"], "LEFT")
    local scoreFontSizeSlider = GUI:CreateSlider(nil, L["FontSize"], 6, 40, 1, addon.db.ChallengeEnhance.ScoreFontSize, function(value)
        addon.db.ChallengeEnhance.ScoreFontSize = value
        update()
    end)
    local scoreXSlider = GUI:CreateSlider(nil, L["X"], -100, 100, 1, addon.db.ChallengeEnhance.ScoreX, function(value)
        addon.db.ChallengeEnhance.ScoreX = value
        update()
    end)
    local scoreYSlider = GUI:CreateSlider(nil, L["Y"], -100, 100, 1, addon.db.ChallengeEnhance.ScoreY, function(value)
        addon.db.ChallengeEnhance.ScoreY = value
        update()
    end)
    local scoreAnchorDropdown = GUI:CreateDropdown(nil, L["Anchor"], {TOP = "TOP", CENTER = "CENTER", BOTTOM = "BOTTOM"}, nil, addon.db.ChallengeEnhance.ScoreAnchor, function(value)
        addon.db.ChallengeEnhance.ScoreAnchor = value
        update()
    end, {"TOP", "CENTER", "BOTTOM"})
    GUI:CreateToggleCheckBox(scoreGroup, L["Enable"], addon.db.ChallengeEnhance.ScoreEnabled, function(value)
        addon.db.ChallengeEnhance.ScoreEnabled = value
        scoreFontSizeSlider:SetDisabled(not value)
        scoreXSlider:SetDisabled(not value)
        scoreYSlider:SetDisabled(not value)
        scoreAnchorDropdown:SetDisabled(not value)
        update()
    end):SetRelativeWidth(0.15)
    scoreFontSizeSlider:SetRelativeWidth(0.2)
    scoreXSlider:SetRelativeWidth(0.2)
    scoreYSlider:SetRelativeWidth(0.2)
    scoreAnchorDropdown:SetRelativeWidth(0.2)
    scoreFontSizeSlider:SetDisabled(not addon.db.ChallengeEnhance.ScoreEnabled)
    scoreXSlider:SetDisabled(not addon.db.ChallengeEnhance.ScoreEnabled)
    scoreYSlider:SetDisabled(not addon.db.ChallengeEnhance.ScoreEnabled)
    scoreAnchorDropdown:SetDisabled(not addon.db.ChallengeEnhance.ScoreEnabled)
    scoreGroup:AddChild(scoreFontSizeSlider)
    scoreGroup:AddChild(scoreXSlider)
    scoreGroup:AddChild(scoreYSlider)
    scoreGroup:AddChild(scoreAnchorDropdown)

    -- MARK: Name Settings
    local nameGroup = GUI:CreateInlineGroup(frame, L["ChallengeEnhanceNameSettings"])
    local nameFontSizeSlider = GUI:CreateSlider(nil, L["FontSize"], 6, 40, 1, addon.db.ChallengeEnhance.NameFontSize, function(value)
        addon.db.ChallengeEnhance.NameFontSize = value
        update()
    end)
    local nameXSlider = GUI:CreateSlider(nil, L["X"], -100, 100, 1, addon.db.ChallengeEnhance.NameX, function(value)
        addon.db.ChallengeEnhance.NameX = value
        update()
    end)
    local nameYSlider = GUI:CreateSlider(nil, L["Y"], -100, 100, 1, addon.db.ChallengeEnhance.NameY, function(value)
        addon.db.ChallengeEnhance.NameY = value
        update()
    end)
    local nameAnchorDropdown = GUI:CreateDropdown(nil, L["Anchor"], {TOP = "TOP", CENTER = "CENTER", BOTTOM = "BOTTOM"}, nil, addon.db.ChallengeEnhance.NameAnchor, function(value)
        addon.db.ChallengeEnhance.NameAnchor = value
        update()
    end, {"TOP", "CENTER", "BOTTOM"})
    GUI:CreateToggleCheckBox(nameGroup, L["Enable"], addon.db.ChallengeEnhance.NameEnabled, function(value)
        addon.db.ChallengeEnhance.NameEnabled = value
        nameFontSizeSlider:SetDisabled(not value)
        nameXSlider:SetDisabled(not value)
        nameYSlider:SetDisabled(not value)
        nameAnchorDropdown:SetDisabled(not value)
        update()
    end):SetRelativeWidth(0.15)
    nameFontSizeSlider:SetRelativeWidth(0.2)
    nameXSlider:SetRelativeWidth(0.2)
    nameYSlider:SetRelativeWidth(0.2)
    nameAnchorDropdown:SetRelativeWidth(0.2)
    nameFontSizeSlider:SetDisabled(not addon.db.ChallengeEnhance.NameEnabled)
    nameXSlider:SetDisabled(not addon.db.ChallengeEnhance.NameEnabled)
    nameYSlider:SetDisabled(not addon.db.ChallengeEnhance.NameEnabled)
    nameAnchorDropdown:SetDisabled(not addon.db.ChallengeEnhance.NameEnabled)
    nameGroup:AddChild(nameFontSizeSlider)
    nameGroup:AddChild(nameXSlider)
    nameGroup:AddChild(nameYSlider)
    nameGroup:AddChild(nameAnchorDropdown)

    return frame
end