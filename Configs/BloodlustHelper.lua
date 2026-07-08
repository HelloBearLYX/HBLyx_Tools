local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "BloodlustHelper"

-- Register sound media
addon.LSM:Register("sound", ADDON_NAME .. "_LustDefault", L["BloodlustLustDefaultSound"])
addon.LSM:Register("sound", ADDON_NAME .. "_ExhaustionDefault", L["BloodlustExhaustionDefaultSound"])

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
    Enabled = true,
    Mute = true,
    LustSound = "",
    ExhaustionSound = "",
    SoundChannel = "Master",
}

-- MARK: Safe update
local function update()
    return addon.core:GetSafeUpdate(MOD_KEY)()
end

-- GUI
GUI.TagPanels.BloodlustHelper = {}
function GUI.TagPanels.BloodlustHelper:CreateTabPanel(parent)
    -- MARK: General
    local frame = GUI:CreateScrollFrame(parent)
    frame:SetLayout("Flow")

    GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["BloodlustHelperSettings"] .. "|r", addon.db.BloodlustHelper.Enabled, function(value)
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
    soundGroup:AddChild(lustSoundSelect)
    soundGroup:AddChild(exhaustionSoundSelect)
    soundGroup:AddChild(soundChannelDropdown)

    return frame
end