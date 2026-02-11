local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local AceGUI = LibStub("AceGUI-3.0")

---@class HB_GUI
addon.GUI = {
    frame = nil,
    isOpened = false,
}

-- MARK: Constants
local TABS = {
    {text = "General", value = "General"},
    {text = L["FocusInterruptSettings"], value = "FocusInterrupt"},
    {text = L["CombatSettings"], value = "CombatIndicator"},
    {text = L["TimerSettings"], value = "CombatTimer"},
    {text = L["BattleResSettings"], value = "BattleRes"},
    {text = L["ChallengeEnhanceSettings"], value = "ChallengeEnhance"},
    {text = L["WarlockReminders"], value = "WarlockReminder"},
}

-- MARK: Initialize GUI

function addon.GUI:Initialize()
    if self.isOpened or InCombatLockdown() then return end

    -- create main frame
    self.isOpened = true
    self.frame = AceGUI:Create("Frame")
    self.frame:SetTitle(L["GUITitle"])
    self.frame:SetLayout("Flow")
    self.frame:SetWidth(900)
    self.frame:SetHeight(600)
    self.frame:EnableResize(false)
    self.frame:SetStatusText("|cff8788ee"..  ADDON_NAME .. "|r v" .. addon:GetVersion())
    self.frame:SetCallback("OnClose", function(widgets)
        if widgets then
            AceGUI:Release(widgets)
        end

        self.isOpened = false
        addon.isTestMode = false
        addon:TestMode(addon.isTestMode)
    end)

    -- test button
    self.TestButton = AceGUI:Create("Button")
    self.TestButton:SetText(L["Test"])
    self.TestButton:SetWidth(200)
    self.TestButton:SetCallback("OnClick", function()
        addon.isTestMode = not addon.isTestMode
        addon:TestMode(addon.isTestMode)
    end)
    self.frame:AddChild(self.TestButton)

    -- create tabs
    local tabs = AceGUI:Create("TabGroup")
    tabs:SetLayout("Fill")
    tabs:SetFullWidth(true)
    tabs:SetFullHeight(true)
    tabs:SetTabs(TABS)
    self.frame:AddChild(tabs)
    
    tabs:SetCallback("OnGroupSelected", function(container, _, tab)
        container:ReleaseChildren()

        if tab == "General" then
            local panel = addon.GUI:CreateScrollFrame(container)
            panel:SetLayout("Flow")
            panel:SetFullWidth(true)
            addon.GUI:CreateInformationTag(panel, "Welecome", "LEFT")

            panel:DoLayout()
        elseif tab == "FocusInterrupt" then
            local panel = addon.GUI.TagPanels.FocusInterrupt:CreateTabPanel(container)
            panel:DoLayout()
        elseif tab == "CombatIndicator" then
            local panel = addon.GUI.TagPanels.CombatIndicator:CreateTabPanel(container)
            panel:DoLayout()
        elseif tab == "CombatTimer" then
            local panel = addon.GUI.TagPanels.CombatTimer:CreateTabPanel(container)
            panel:DoLayout()
        elseif tab == "BattleRes" then
            local panel = addon.GUI.TagPanels.BattleRes:CreateTabPanel(container)
            panel:DoLayout()
        elseif tab == "ChallengeEnhance" then
            local panel = addon.GUI.TagPanels.ChallengeEnhance:CreateTabPanel(container)
            panel:DoLayout()
        elseif tab == "WarlockReminder" then
            local panel = addon.GUI.TagPanels.WarlockReminder:CreateTabPanel(container)
            panel:DoLayout()
        end
    end)
end

-- MARK: Inline Group

function addon.GUI:CreateInlineGroup(parent, title)
    local inlineGroup = AceGUI:Create("InlineGroup")
    inlineGroup:SetTitle("|cFFFFFFFF" .. title .. "|r")
    inlineGroup:SetFullWidth(true)
    inlineGroup:SetLayout("Flow")
    parent:AddChild(inlineGroup)
    return inlineGroup
end

-- MARK: Scroll Frame

function addon.GUI:CreateScrollFrame(parent)
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetLayout("Flow")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    parent:AddChild(scrollFrame)
    return scrollFrame
end

-- MARK: Toggle CheckBox
function addon.GUI:CreateToggleCheckBox(parent, label, get, callback)
    local toggle = AceGUI:Create("CheckBox")
    toggle:SetLabel(label)
    toggle:SetValue(get)
    toggle:SetCallback("OnValueChanged", function(_, _, newValue)
        if callback then
            callback(newValue)
        end
    end)
    parent:AddChild(toggle)
    return toggle
end

-- MARK: Button
function addon.GUI:CreateButton(parent, label, callback)
    local button = AceGUI:Create("Button")
    button:SetText(label)
    button:SetWidth(100)
    button:SetCallback("OnClick", function()
        if callback then
            callback()
        end
    end)
    parent:AddChild(button)
    return button
end

-- MARK: Slider
function addon.GUI:CreateSlider(parent, label, min, max, step, get, callback)
    local slider = AceGUI:Create("Slider")
    slider:SetLabel(label)
    slider:SetSliderValues(min, max, step)
    slider:SetValue(get)
    slider:SetCallback("OnValueChanged", function(_, _, newValue)
        if callback then
            callback(newValue)
        end
    end)
    parent:AddChild(slider)
    return slider
end

-- MARK: CreateHeader(parent, title)
function addon.GUI:CreateHeader(parent, title)
    local headingText = AceGUI:Create("Heading")
    headingText:SetText("|cFFFFCC00" .. title .. "|r")
    headingText:SetFullWidth(true)
    parent:AddChild(headingText)
    return headingText
end

-- MARK: Information Tag
function addon.GUI:CreateInformationTag(parent, description, textJustification)
    local informationLabel = AceGUI:Create("Label")
    informationLabel:SetText(description)
    informationLabel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    informationLabel:SetFullWidth(true)
    informationLabel:SetJustifyH(textJustification or "CENTER")
    informationLabel:SetHeight(24)
    informationLabel:SetJustifyV("MIDDLE")
    parent:AddChild(informationLabel)
    return informationLabel
end

-- MARK: Create Font
function addon.GUI:CreateFontSelect(parent, label, get, callback)
    local fontSelect = AceGUI:Create("LSM30_Font")
    fontSelect:SetLabel(label)
    fontSelect:SetList(addon.LSM:HashTable("font"))
    fontSelect:SetValue(get)
    fontSelect:SetCallback("OnValueChanged", function(self, _, key)
        self:SetValue(key)
        if callback then
            callback(key)
        end
    end)
    parent:AddChild(fontSelect)
    return fontSelect
end

-- MARK: Create Sound
function addon.GUI:CreateSoundSelect(parent, label, get, callback)
    local soundSelect = AceGUI:Create("LSM30_Sound")
    soundSelect:SetLabel(label)
    soundSelect:SetList(addon.LSM:HashTable("sound"))
    soundSelect:SetValue(get)
    soundSelect:SetCallback("OnValueChanged", function(self, _, key)
        self:SetValue(key)
        if callback then
            callback(key)
        end
    end)
    parent:AddChild(soundSelect)
    return soundSelect
end

-- MARK: Create Texture

function addon.GUI:CreateTextureSelect(parent, label, get, callback)
    local textureSelect = AceGUI:Create("LSM30_Statusbar")
    textureSelect:SetLabel(label)
    textureSelect:SetList(addon.LSM:HashTable("statusbar"))
    textureSelect:SetValue(get)
    textureSelect:SetCallback("OnValueChanged", function(self, _, key)
        self:SetValue(key)
        if callback then
            callback(key)
        end
    end)
    parent:AddChild(textureSelect)
    return textureSelect
end

-- MARK: Create Color Picker

function addon.GUI:CreateColorPicker(parent, label, hasAlpha, get, callback)
    local colorPicker = AceGUI:Create("ColorPicker")
    colorPicker:SetLabel(label)
    colorPicker:SetHasAlpha(hasAlpha)
    colorPicker:SetColor(addon.Utilities:HexToRGB(get))
    colorPicker:SetCallback("OnValueChanged", function(_, _, r, g, b, a)
        if callback then
            addon.Utilities:print("converted color: " .. addon.Utilities:RGBToHex(r, g, b, a))
            callback(addon.Utilities:RGBToHex(r, g, b, a))
        end
    end)
    parent:AddChild(colorPicker)
    return colorPicker
end

-- MARK: Create EditBox

function addon.GUI:CreateEditBox(parent, label, get, callback)
    local editBox = AceGUI:Create("EditBox")
    editBox:SetLabel(label)
    editBox:SetText(get)
    editBox:SetCallback("OnEnterPressed", function(self)
        if callback then
            callback(self:GetText())
        end
    end)
    parent:AddChild(editBox)
    return editBox
end

-- MARK: Create Dropdown

function addon.GUI:CreateDropDown(parent, label, list, get, multiSelect, callback)
    local dropdown = AceGUI:Create("Dropdown")
    dropdown:SetLabel(label)
    dropdown:SetMultiselect(multiSelect)
    for key, value in pairs(list) do
        dropdown:AddItem(key, value)
    end
    dropdown:SetText(get)
    dropdown:SetCallback("OnValueChanged", function(self, _, key)
        self:SetText(key)
        if callback then
            callback(key)
        end
    end)
    parent:AddChild(dropdown)
    return dropdown
    
end

-- MARK: Open/Close GUI

function addon.GUI:OpenGUI()
    addon.GUI:Initialize()
end

function addon.GUI:CloseGUI()
    if self.isOpened and self.frame then
        self.frame:Hide()
        self.isOpened = false
    end
end

addon.GUI.TagPanels = {}