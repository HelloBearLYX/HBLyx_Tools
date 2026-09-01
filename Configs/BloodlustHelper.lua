local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "BloodlustHelper"

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
    Enabled = true,
    Mute = true,
    LustSound = "None",
    ExhaustionSound = "None",
    SoundChannel = "Master",
    AuraFrameSize = 35,
    HideInactive = true,
    X = -265,
    Y = -260,
}

-- MARK: Safe update
local function update()
    return addon.core:GetSafeUpdate(MOD_KEY)()
end

-- GUI
GUI.TagPanels.BloodlustHelper = {}
function GUI.TagPanels.BloodlustHelper:CreateTabPanel(parent)
    -- MARK: General
    local frame = parent

    local enabledModule = GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["BloodlustHelperSettings"] .. "|r", addon.db.BloodlustHelper.Enabled, function(value)
        addon.db.BloodlustHelper.Enabled = value
        if addon.core:HasModuleLoaded(MOD_KEY) then
            if not value then
                addon:ShowDialog(ADDON_NAME .. "RLNeeded")
            end
        else
            if value then
                addon.core:LoadModule(MOD_KEY)
                addon.core:TestModule(MOD_KEY)
            end
        end
    end)
    local notValidVersion = select(4, GetBuildInfo()) < 120100
    enabledModule:SetDisabled(notValidVersion)
    if notValidVersion then
        GUI:CreateInformationTag(frame, L["BloodlustHelperNotValidVersion"], "LEFT")
    end

    GUI:CreateButton(frame, L["ResetMod"], function ()
        addon.Utilities:SetPopupDialog(
            ADDON_NAME .. "ResetMod",
            "|cffC41E3A" .. L["BloodlustHelperSettings"] .. "|r: " .. L["ComfirmResetMod"],
            true,
            {button1 = YES, button2 = NO, OnButton1 = function ()
                addon.Utilities:ResetModule(MOD_KEY)
                ReloadUI()
            end}
        )
    end)

    -- MARK: Sound
    local soundGroup = GUI:CreateInlineGroup(frame, L["SoundSettings"])
    GUI:CreateInformationTag(soundGroup, L["BloodlustMuteDesc"], "LEFT")

    local lustSoundSelect = GUI:CreateSoundSelect(nil, L["BloodlustLustSound"], addon.db.BloodlustHelper.LustSound, function(value)
        addon.db.BloodlustHelper.LustSound = value
        update()
    end)
    local exhaustionSoundSelect = GUI:CreateSoundSelect(nil, L["BloodlustExhaustionSound"], addon.db.BloodlustHelper.ExhaustionSound, function(value)
        addon.db.BloodlustHelper.ExhaustionSound = value
        update()
    end)
    local soundChannelDropdown = GUI:CreateDropdown(nil, L["SoundChannelSettings"], addon.Utilities.SoundChannels, nil, addon.db.BloodlustHelper.SoundChannel, function(value)
        addon.db.BloodlustHelper.SoundChannel = value
        update()
    end)
    GUI:CreateToggleCheckBox(soundGroup, L["Mute"], addon.db.BloodlustHelper.Mute, function(value)
        addon.db.BloodlustHelper.Mute = value
        lustSoundSelect:SetDisabled(value)
        exhaustionSoundSelect:SetDisabled(value)
        soundChannelDropdown:SetDisabled(value)
        update()
    end)

    lustSoundSelect:SetDisabled(addon.db.BloodlustHelper.Mute)
    exhaustionSoundSelect:SetDisabled(addon.db.BloodlustHelper.Mute)
    soundChannelDropdown:SetDisabled(addon.db.BloodlustHelper.Mute)
    frame:AddWidget(lustSoundSelect)
    frame:AddWidget(exhaustionSoundSelect)
    frame:AddWidget(soundChannelDropdown)

    -- MARK: Container
    local styleGroup = GUI:CreateInlineGroup(frame, L["StyleSettings"])
    GUI:CreateToggleCheckBox(styleGroup, L["HideInactive"], addon.db.BloodlustHelper.HideInactive, function(value)
        addon.db.BloodlustHelper.HideInactive = value
        local module = addon.core:GetModule(MOD_KEY)
        if module then
            module:UpdateVisibility()
        end
    end)
    GUI:CreateSlider(styleGroup, L["X"], -2000, 2000, 1, addon.db.BloodlustHelper.X, function(value)
        addon.db.BloodlustHelper.X = value
        update()
    end)
    GUI:CreateSlider(styleGroup, L["Y"], -1000, 1000, 1, addon.db.BloodlustHelper.Y, function(value)
        addon.db.BloodlustHelper.Y = value
        update()
    end)
    GUI:CreateSlider(styleGroup, L["IconSize"], 10, 200, 1, addon.db.BloodlustHelper.AuraFrameSize, function(value)
        addon.db.BloodlustHelper.AuraFrameSize = value
        update()
    end)

    return frame
end