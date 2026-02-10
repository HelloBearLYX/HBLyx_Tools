local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local MOD_KEY = "FocusInterrupt"

addon.LSM:Register("sound", ADDON_NAME.. "_FocusDefault", L["FocusDefaultSound"])

local function update()
    if addon.focusCastBar then
        addon.focusCastBar:UpdateStyle()
    end
end
-- local function RLNeeded()
-- 	addon:ShowDialog(ADDON_NAME.."RLNeeded")
-- end

addon.configurationList[MOD_KEY] = {
    Enabled = true,
    Mute = true,
    SoundMedia = ADDON_NAME .. "_FocusDefault",
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

-- local optionMap = addon.Utilities:MakeOptionGroup(L["FocusInterruptSettings"], {
--     addon.Utilities:MakeToggleOption(L["Enable"], MOD_KEY, "Enabled", RLNeeded),
--     addon.Utilities:MakeResetOption(MOD_KEY, L["FocusInterruptSettings"]),
--     -- focus cast bar settings
--     addon.Utilities:MakeOptionGroup(L["FocusCastBarSettings"], {
--         addon.Utilities:MakeToggleOption(L["FocusCastBarHidden"], MOD_KEY, "Hidden", nil, {desc = L["FocusCastBarHiddenDesc"]}),
--         addon.Utilities:MakeOptionGroup(L["StyleSettings"], {
--             addon.Utilities:MakeRangeOption(L["BackgroundAlpha"], MOD_KEY, "BackgroundAlpha", 0, 1, 0.01, update),
--             addon.Utilities:MakeLSMTextureOption(L["Texture"], MOD_KEY, "Texture", update),
--             addon.Utilities:MakeOptionLineBreak(),
--             addon.Utilities:MakeRangeOption(L["X"], MOD_KEY, "X", -2000, 2000, 1, update, {desc = L["XDesc"]}),
--             addon.Utilities:MakeRangeOption(L["Y"], MOD_KEY, "Y", -1000, 1000, 1, update, {desc = L["YDesc"]}),
--             addon.Utilities:MakeOptionLineBreak(),
--             addon.Utilities:MakeRangeOption(L["Width"], MOD_KEY, "Width", 50, 1000, 1, update),
--             addon.Utilities:MakeRangeOption(L["Height"], MOD_KEY, "Height", 10, 200, 1, update),
--             addon.Utilities:MakeOptionLineBreak(),
--             addon.Utilities:MakeLSMFontOption(L["Font"], MOD_KEY, "Font", update),
--             addon.Utilities:MakeRangeOption(L["FontSize"], MOD_KEY, "FontSize", 4, 40, 1, update),
--             addon.Utilities:MakeColorOption(L["InterruptibleColor"], MOD_KEY, "InterruptibleColor", update, {desc = L["FocusColorPriorityDesc"]}),
--             addon.Utilities:MakeColorOption(L["InterruptedColor"], MOD_KEY, "InterruptedColor", update),
--             addon.Utilities:MakeOptionLineBreak(),
--             addon.Utilities:MakeToggleOption(L["ShowTotalTime"], MOD_KEY, "ShowTotalTime"),
--             addon.Utilities:MakeRangeOption(L["IconZoom"], MOD_KEY, "IconZoom", 0.01, 0.5, 0.01, update),
--         }, true, {hidden = function () return addon.db[MOD_KEY]["Hidden"] end}),
--     }, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
--     addon.Utilities:MakeOptionGroup(L["FocusInteruptSettings"], {
--         addon.Utilities:MakeToggleOption(L["FocusInterruptCooldownFilter"], MOD_KEY, "CooldownHide", nil, {desc = L["FocusInterruptCooldownFilterDesc"]}),
--         addon.Utilities:MakeColorOption(L["FocusInterruptNotReadyColor"], MOD_KEY, "CooldownColor", update, {hidden = function () return addon.db[MOD_KEY]["CooldownHide"] end}),
--         addon.Utilities:MakeOptionLineBreak(),
--         addon.Utilities:MakeToggleOption(L["FocusInterruptibleFilter"], MOD_KEY, "NotInterruptibleHide", nil, {desc = L["FocusInterruptibleFilterDesc"]}),
--         addon.Utilities:MakeColorOption(L["NotInterruptibleColor"], MOD_KEY, "NotInterruptibleColor", update, {hidden = function () return addon.db[MOD_KEY]["NotInterruptibleHide"] end}),
--         addon.Utilities:MakeOptionLineBreak(),
--         addon.Utilities:MakeToggleOption(L["ShowInterrupter"], MOD_KEY, "ShowInterrupter"),
--         addon.Utilities:MakeRangeOption(L["InterruptedFadeTime"], MOD_KEY, "InterruptedFadeTime", 0.0, 2, 0.25, nil, {desc = L["InterruptedFadeTimeDesc"]}),
--         addon.Utilities:MakeOptionLineBreak(),
--         addon.Utilities:MakeToggleOption(L["ShowTarget"], MOD_KEY, "ShowTarget"),
--     }, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
--     addon.Utilities:MakeOptionGroup(L["SoundSettings"], {
--         {type = "description", name = L["FocusMuteDesc"]},
--         addon.Utilities:MakeToggleOption("|cffC41E3A" .. L["Mute"] .. "|r", MOD_KEY, "Mute", nil, {desc = L["FocusMuteDesc"]}),
--         addon.Utilities:MakeLSMSoundOption(L["Sound"], MOD_KEY, "SoundMedia", {desc = L["FocusInterruptSoundDesc"], hidden = function () return addon.db[MOD_KEY]["Mute"] end}),
--     }, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
--     addon.Utilities:MakeOptionGroup(L["InterruptIconsSettings"], {
--         {type = "description", name = L["InterruptIconDesc"]},
--         addon.Utilities:MakeToggleOption(L["Enable"], MOD_KEY, "ShowKickIcons", RLNeeded),
--         addon.Utilities:MakeOptionGroup("", {
--             addon.Utilities:MakeToggleOption(L["ShowDemoWarlockOnly"], MOD_KEY, "ShowDemoWarlockOnly"),
--             addon.Utilities:MakeRangeOption(L["IconSize"], MOD_KEY, "KickIconSize", 10, 200, 1, update),
--             {type="select", name=L["Anchor"], values=addon.Utilities.Anchors, get=function(_)
--                 return addon.db[MOD_KEY]["KickIconAnchor"]
--             end, set=function(_, val)
--                 addon.db[MOD_KEY]["KickIconAnchor"] = val
--                 RLNeeded()
--             end},
--             {type="select", name=L["Grow"], values=addon.Utilities.Grows, desc="Only work for multi-interrupts specs(demo warlock)\n只对多打断专精(恶魔术)生效", get=function(_)
--                 return addon.db[MOD_KEY]["KickIconGrow"]
--             end, set=function(_, val)
--                 addon.db[MOD_KEY]["KickIconGrow"] = val
--                 RLNeeded()
--             end},
--         }, true, {hidden = function() return not addon.db[MOD_KEY]["ShowKickIcons"] end})
--     }, true, {hidden = function() return not addon.db[MOD_KEY]["Enabled"] end}),
-- }, false, {order = addon:OptionOrderHandler(), desc = L["FocusInterruptSettingsDesc"]})
-- addon:AppendOptionsList("FocusInterruptCastBar", optionMap)

-- GUI
local GUI = addon.GUI

GUI.TagPanels.FocusInterrupt = {}
function GUI.TagPanels.FocusInterrupt:CreateTabPanel(parent)
    local frame = GUI:CreateScrollFrame(parent)
    frame:SetLayout("Flow")
    GUI:CreateInformationTag(frame, L["FocusInterruptSettingsDesc"], "LEFT")
    GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["FocusInterruptSettings"] .. "|r", addon.db.FocusInterrupt.Enabled, function(value)
        addon.db.FocusInterrupt.Enabled = value
        addon:ShowDialog(ADDON_NAME.."RLNeeded")
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

    GUI:CreateHeader(frame, L["StyleSettings"])
    GUI:CreateSlider(frame, L["BackgroundAlpha"], 0, 1, 0.01, addon.db.FocusInterrupt.BackgroundAlpha, function(value)
        addon.db.FocusInterrupt.BackgroundAlpha = value
        update()
    end)
    GUI:CreateTextureSelect(frame, L["Texture"], addon.db.FocusInterrupt.Texture, function(value)
        addon.db.FocusInterrupt.Texture = value
        update()
    end)
    GUI:CreateSlider(frame, L["X"], -2000, 2000, 1, addon.db.FocusInterrupt.X, function(value)
        addon.db.FocusInterrupt.X = value
        update()
    end)
    GUI:CreateSlider(frame, L["Y"], -1000, 1000, 1, addon.db.FocusInterrupt.Y, function(value)
        addon.db.FocusInterrupt.Y = value
        update()
    end)
    GUI:CreateSlider(frame, L["Width"], 50, 1000, 1, addon.db.FocusInterrupt.Width, function(value)
        addon.db.FocusInterrupt.Width = value
        update()
    end)
    GUI:CreateSlider(frame, L["Height"], 10, 200, 1, addon.db.FocusInterrupt.Height, function(value)
        addon.db.FocusInterrupt.Height = value
        update()
    end)
    GUI:CreateFontSelect(frame, L["Font"], addon.db.FocusInterrupt.Font, function(value)
        addon.db.FocusInterrupt.Font = value
        update()
    end)
    GUI:CreateSlider(frame, L["FontSize"], 4, 40, 1, addon.db.FocusInterrupt.FontSize, function(value)
        addon.db.FocusInterrupt.FontSize = value
        update()
    end)
    GUI:CreateColorPicker(frame, L["InterruptibleColor"], true, addon.db.FocusInterrupt.InterruptibleColor, function(value)
        addon.db.FocusInterrupt.InterruptibleColor = value
        update()
    end)
    GUI:CreateColorPicker(frame, L["InterruptedColor"], true, addon.db.FocusInterrupt.InterruptedColor, function(value)
        addon.db.FocusInterrupt.InterruptedColor = value
        update()
    end)
    GUI:CreateToggleCheckBox(frame, L["ShowTotalTime"], addon.db.FocusInterrupt.ShowTotalTime, function(value)
        addon.db.FocusInterrupt.ShowTotalTime = value
    end)
    GUI:CreateSlider(frame, L["IconZoom"], 0.01, 0.5, 0.01, addon.db.FocusInterrupt.IconZoom, function(value)
        addon.db.FocusInterrupt.IconZoom = value
        update()
    end)

    GUI:CreateHeader(frame, L["FocusInteruptSettings"])
    GUI:CreateToggleCheckBox(frame, L["FocusInterruptCooldownFilter"], addon.db.FocusInterrupt.CooldownHide, function(value)
        addon.db.FocusInterrupt.CooldownHide = value
    end)
    GUI:CreateColorPicker(frame, L["FocusInterruptNotReadyColor"], true, addon.db.FocusInterrupt.CooldownColor, function(value)
        addon.db.FocusInterrupt.CooldownColor = value
        update()
    end)
    GUI:CreateToggleCheckBox(frame, L["FocusInterruptibleFilter"], addon.db.FocusInterrupt.NotInterruptibleHide, function(value)
        addon.db.FocusInterrupt.NotInterruptibleHide = value
    end)
    GUI:CreateColorPicker(frame, L["NotInterruptibleColor"], true, addon.db.FocusInterrupt.NotInterruptibleColor, function(value)
        addon.db.FocusInterrupt.NotInterruptibleColor = value
        update()
    end)
    GUI:CreateToggleCheckBox(frame, L["ShowInterrupter"], addon.db.FocusInterrupt.ShowInterrupter, function(value)
        addon.db.FocusInterrupt.ShowInterrupter = value
    end)
    GUI:CreateSlider(frame, L["InterruptedFadeTime"], 0, 2, 0.25, addon.db.FocusInterrupt.InterruptedFadeTime, function(value)
        addon.db.FocusInterrupt.InterruptedFadeTime = value
    end)
    GUI:CreateToggleCheckBox(frame, L["ShowTarget"], addon.db.FocusInterrupt.ShowTarget, function(value)
        addon.db.FocusInterrupt.ShowTarget = value
    end)

    GUI:CreateHeader(frame, L["SoundSettings"])
    GUI:CreateInformationTag(frame, L["FocusMuteDesc"], "LEFT")
    GUI:CreateToggleCheckBox(frame, L["Mute"], addon.db.FocusInterrupt.Mute, function(value)
        addon.db.FocusInterrupt.Mute = value
    end)
    GUI:CreateSoundSelect(frame, L["Sound"], addon.db.FocusInterrupt.SoundMedia, function(value)
        addon.db.FocusInterrupt.SoundMedia = value
    end)

    GUI:CreateHeader(frame, L["InterruptIconsSettings"])
    GUI:CreateInformationTag(frame, L["InterruptIconDesc"], "LEFT")
    GUI:CreateToggleCheckBox(frame, L["Enable"], addon.db.FocusInterrupt.ShowKickIcons, function(value)
        addon.db.FocusInterrupt.ShowKickIcons = value
        addon:ShowDialog(ADDON_NAME.."RLNeeded")
    end)
    
    GUI:CreateToggleCheckBox(frame, L["ShowDemoWarlockOnly"], addon.db.FocusInterrupt.ShowDemoWarlockOnly, function(value)
        addon.db.FocusInterrupt.ShowDemoWarlockOnly = value
    end)
    GUI:CreateSlider(frame, L["IconSize"], 10, 200, 1, addon.db.FocusInterrupt.KickIconSize, function(value)
        addon.db.FocusInterrupt.KickIconSize = value
        update()
    end)

    parent:AddChild(frame)
    return frame
end