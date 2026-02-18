local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "FocusInterrupt"

addon.LSM:Register("sound", ADDON_NAME.. "_FocusDefault", L["FocusDefaultSound"])

-- MARK: Safe update
local function update()
    return addon.core:GetSafeUpdate(MOD_KEY)()
end

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
    Enabled = true,
    Mute = true,
    SoundMedia = ADDON_NAME .. "_FocusDefault",
    SoundChannel = "Master",
    CooldownHide = false,
    CooldownColor = "ffC41E3A",
    NotInterruptibleHide = true,
    NotInterruptibleColor = "ffFF7C0A",
    InterruptedColor = "ff828282",
    InterruptedFadeTime = 0.75,
    -- bar style settings
    Hidden = false,
    BackgroundAlpha = 0.3,
    Width = 280,
    Height = 30,
    Texture = "Solid",
    InterruptibleColor = "ff3fc7eb",
    Font = "",
    FontSize = 12,
    X = 0,
    Y = 250,
    IconZoom = 0.07,
    ShowTarget = true,
    ShowInterrupter = true,
    ShowTotalTime = true,
    ShowKickIcons = true,
    ShowDemoWarlockOnly = true,
    KickIconSize = 30,
    KickIconAnchor = "BOTTOMLEFT",
    KickIconGrow = "RIGHT",
}

-- GUI
GUI.TagPanels.FocusInterrupt = {}
function GUI.TagPanels.FocusInterrupt:CreateTabPanel(parent)
    -- MARK: General
    local frame = GUI:CreateScrollFrame(parent)
    frame:SetLayout("Flow")
    GUI:CreateInformationTag(frame, L["FocusInterruptSettingsDesc"], "LEFT")
    GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["FocusInterruptSettings"] .. "|r", addon.db.FocusInterrupt.Enabled, function(value)
        addon.db.FocusInterrupt.Enabled = value
        if addon.core:HasModuleLoaded(MOD_KEY) then -- if module is loaded
            if not value then -- user try to disable the module
                addon:ShowDialog(ADDON_NAME.."RLNeeded")
            end
        else -- if the module is not loaded yet
            if value then -- user try to enable the module, just load it without asking for reload, since it will be loaded immediately
                addon.core:LoadModule(MOD_KEY)
                addon.core:TestModule(MOD_KEY) -- the test mode will be on if the addon is in test mode
            end
        end
    end)
    GUI:CreateToggleCheckBox(frame, L["FocusCastBarHidden"], addon.db.FocusInterrupt.Hidden, function(value)
        addon.db.FocusInterrupt.Hidden = value
    end)
    GUI:CreateButton(frame, L["ResetMod"], function ()
        addon.Utilities:SetPopupDialog(
            ADDON_NAME .. "ResetMod",
            "|cffC41E3A" .. L["FocusInterruptSettings"] .. "|r: " .. L["ComfirmResetMod"],
            true,
            {button1 = YES, button2 = NO, OnButton1 = function ()
                addon.Utilities:ResetModule(MOD_KEY)
                ReloadUI()
            end}
        )
    end)

    -- MARK: Core
    local focusInterruptGroup = GUI:CreateInlineGroup(frame, L["InteruptSettings"])
    GUI:CreateToggleCheckBox(focusInterruptGroup, L["FocusInterruptCooldownFilter"], addon.db.FocusInterrupt.CooldownHide, function(value)
        addon.db.FocusInterrupt.CooldownHide = value
    end)
    GUI:CreateToggleCheckBox(focusInterruptGroup, L["FocusInterruptibleFilter"], addon.db.FocusInterrupt.NotInterruptibleHide, function(value)
        addon.db.FocusInterrupt.NotInterruptibleHide = value
    end)
    local interruptedGroup = GUI:CreateInlineGroup(focusInterruptGroup, L["InterruptedSettings"])
    GUI:CreateInformationTag(interruptedGroup, L["InterruptedSettingsDesc"], "LEFT")
    GUI:CreateSlider(interruptedGroup, L["InterruptedFadeTime"], 0, 2, 0.25, addon.db.FocusInterrupt.InterruptedFadeTime, function(value)
        addon.db.FocusInterrupt.InterruptedFadeTime = value
    end)
    GUI:CreateToggleCheckBox(interruptedGroup, L["ShowInterrupter"], addon.db.FocusInterrupt.ShowInterrupter, function(value)
        addon.db.FocusInterrupt.ShowInterrupter = value
    end)

    -- MARK: Interrupted
    local interruptIconsGroup = GUI:CreateInlineGroup(frame, L["InterruptIconsSettings"])
    GUI:CreateInformationTag(interruptIconsGroup, L["InterruptIconDesc"], "LEFT")
    GUI:CreateToggleCheckBox(interruptIconsGroup, L["Enable"], addon.db.FocusInterrupt.ShowKickIcons, function(value)
        addon.db.FocusInterrupt.ShowKickIcons = value
        addon:ShowDialog(ADDON_NAME.."RLNeeded")
    end)
    GUI:CreateToggleCheckBox(interruptIconsGroup, L["ShowDemoWarlockOnly"], addon.db.FocusInterrupt.ShowDemoWarlockOnly, function(value)
        addon.db.FocusInterrupt.ShowDemoWarlockOnly = value
        addon:ShowDialog(ADDON_NAME.."RLNeeded")
    end)
    GUI:CreateInformationTag(interruptIconsGroup, "\n")
    GUI:CreateSlider(interruptIconsGroup, L["IconSize"], 10, 200, 1, addon.db.FocusInterrupt.KickIconSize, function(value)
        addon.db.FocusInterrupt.KickIconSize = value
        update()
    end)
    GUI:CreateDropDown(interruptIconsGroup, L["Anchor"], addon.Utilities.Anchors, addon.db.FocusInterrupt.KickIconAnchor, false, function(value)
        addon.db.FocusInterrupt.KickIconAnchor = value
        update()
    end)
    GUI:CreateDropDown(interruptIconsGroup, L["Grow"], addon.Utilities.Grows, addon.db.FocusInterrupt.KickIconGrow, false, function(value)
        addon.db.FocusInterrupt.KickIconGrow = value
        update()
    end)

    -- style
    local styleGroup = GUI:CreateInlineGroup(frame, L["StyleSettings"])
    -- MARK: Texture
    local texttureGroup = GUI:CreateInlineGroup(styleGroup, L["TextureSettings"])
    GUI:CreateTextureSelect(texttureGroup, L["Texture"], addon.db.FocusInterrupt.Texture, function(value)
        addon.db.FocusInterrupt.Texture = value
        update()
    end)
    GUI:CreateSlider(texttureGroup, L["BackgroundAlpha"], 0, 1, 0.01, addon.db.FocusInterrupt.BackgroundAlpha, function(value)
        addon.db.FocusInterrupt.BackgroundAlpha = value
        update()
    end)
    local positionGroup = GUI:CreateInlineGroup(styleGroup, L["PositionSettings"])
    GUI:CreateSlider(positionGroup, L["X"], -2000, 2000, 1, addon.db.FocusInterrupt.X, function(value)
        addon.db.FocusInterrupt.X = value
        update()
    end)
    GUI:CreateSlider(positionGroup, L["Y"], -1000, 1000, 1, addon.db.FocusInterrupt.Y, function(value)
        addon.db.FocusInterrupt.Y = value
        update()
    end)
    -- MARK: Size
    local sizeGroup = GUI:CreateInlineGroup(styleGroup, L["SizeSettings"])
    GUI:CreateSlider(sizeGroup, L["Width"], 50, 1000, 1, addon.db.FocusInterrupt.Width, function(value)
        addon.db.FocusInterrupt.Width = value
        update()
    end)
    GUI:CreateSlider(sizeGroup, L["Height"], 10, 200, 1, addon.db.FocusInterrupt.Height, function(value)
        addon.db.FocusInterrupt.Height = value
        update()
    end)
    GUI:CreateSlider(sizeGroup, L["IconZoom"], 0.01, 0.5, 0.01, addon.db.FocusInterrupt.IconZoom, function(value)
        addon.db.FocusInterrupt.IconZoom = value
        update()
    end)
    -- MARK: Font
    local fontGroup = GUI:CreateInlineGroup(styleGroup, L["FontSettings"])
    GUI:CreateFontSelect(fontGroup, L["Font"], addon.db.FocusInterrupt.Font, function(value)
        addon.db.FocusInterrupt.Font = value
        update()
    end)
    GUI:CreateSlider(fontGroup, L["FontSize"], 4, 40, 1, addon.db.FocusInterrupt.FontSize, function(value)
        addon.db.FocusInterrupt.FontSize = value
        update()
    end)
    GUI:CreateInformationTag(fontGroup, "\n")
    GUI:CreateToggleCheckBox(fontGroup, L["ShowTotalTime"], addon.db.FocusInterrupt.ShowTotalTime, function(value)
        addon.db.FocusInterrupt.ShowTotalTime = value
    end)
    GUI:CreateToggleCheckBox(fontGroup, L["ShowTarget"], addon.db.FocusInterrupt.ShowTarget, function(value)
        addon.db.FocusInterrupt.ShowTarget = value
    end)
    -- MARK: Color
    local colorGroup = GUI:CreateInlineGroup(styleGroup, L["ColorSettings"])
    GUI:CreateInformationTag(colorGroup, L["FocusColorPriorityDesc"], "LEFT")
    GUI:CreateColorPicker(colorGroup, L["InterruptibleColor"], true, addon.db.FocusInterrupt.InterruptibleColor, function(value)
        addon.db.FocusInterrupt.InterruptibleColor = value
        update()
    end):SetRelativeWidth(0.25)
    GUI:CreateColorPicker(colorGroup, L["FocusInterruptNotReadyColor"], true, addon.db.FocusInterrupt.CooldownColor, function(value)
        addon.db.FocusInterrupt.CooldownColor = value
        update()
    end):SetRelativeWidth(0.25)
    GUI:CreateColorPicker(colorGroup, L["NotInterruptibleColor"], true, addon.db.FocusInterrupt.NotInterruptibleColor, function(value)
        addon.db.FocusInterrupt.NotInterruptibleColor = value
        update()
    end):SetRelativeWidth(0.25)
    GUI:CreateColorPicker(colorGroup, L["InterruptedColor"], true, addon.db.FocusInterrupt.InterruptedColor, function(value)
        addon.db.FocusInterrupt.InterruptedColor = value
        update()
    end):SetRelativeWidth(0.25)

    -- MARK: Sound
    local soundGroup = GUI:CreateInlineGroup(frame, L["SoundSettings"])
    GUI:CreateInformationTag(soundGroup, L["FocusMuteDesc"], "LEFT")
    GUI:CreateToggleCheckBox(soundGroup, L["Mute"], addon.db.FocusInterrupt.Mute, function(value)
        addon.db.FocusInterrupt.Mute = value
    end)
    GUI:CreateSoundSelect(soundGroup, L["Sound"], addon.db.FocusInterrupt.SoundMedia, function(value)
        addon.db.FocusInterrupt.SoundMedia = value
    end)
    GUI:CreateDropDown(soundGroup, L["SoundChannelSettings"], addon.Utilities.SoundChannels, addon.db.FocusInterrupt.SoundChannel, false, function(value)
        addon.db.FocusInterrupt.SoundChannel = value
    end)

    return frame
end