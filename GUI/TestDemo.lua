local addon = select(2, ...)

--- Test panel for the HBLyx GUI library, toggled with /hbgui
--- Every widget is built through the UICore frame pool so that the pool, the row layout,
--- the release logic and the re-use logic are all exercised by the demo.

-- MARK: Default values
local PANEL_WIDTH = 460
local PANEL_HEIGHT = 380
local PANEL_PADDING = 16
local TITLE_HEIGHT = 24
local CLOSE_BUTTON_SIZE = 25
local WINDOW_WIDTH = 180
local WINDOW_HEIGHT = 190
local WINDOW_BUTTON_WIDTH = 168
local WINDOW_BUTTON_HEIGHT = 22

local BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    tile = false, tileSize = 1, edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
}

local DROPDOWN_LIST = {
    tank = "Tank",
    healer = "Healer",
    melee = "Melee DPS",
    ranged = "Ranged DPS",
}
local DROPDOWN_ORDER = { "tank", "healer", "melee", "ranged" }

local demo = {}

local function Report(message)
    addon.Utilities:print(message)
end

-- MARK: Content

---Build one of every registered widget into the scroll frame
local function PopulateContent(scrollFrame)
    addon.UICore:ResetColorCycle()

    local intro = addon.UICore:Build("TextRegion")
    intro:SetFontSize(14)
    intro:SetText("This panel builds one of every widget through the UICore frame pool. "
        .. "The text region takes the full width of its container and grows as tall as the text needs, "
        .. "so it wraps over as many lines as required.")
    scrollFrame:AddWidget(intro)
    scrollFrame:NewRow()

    local separator = addon.UICore:Build("LineSeperator")
    separator:SetFullWidth(true)
    scrollFrame:AddWidget(separator)

    scrollFrame:NewRow()

    local toggleA = addon.UICore:Build("ToggleBox")
    toggleA:SetSize(160, 20)
    toggleA:SetText("Enable feature A")
    toggleA:SetValue(true)
    toggleA:SetOnClick(function(_, value) Report("ToggleBox A = " .. tostring(value)) end)
    scrollFrame:AddWidget(toggleA)

    local toggleB = addon.UICore:Build("ToggleBox")
    toggleB:SetSize(160, 20)
    toggleB:SetText("Enable feature B")
    toggleB:SetOnClick(function(_, value) Report("ToggleBox B = " .. tostring(value)) end)
    scrollFrame:AddWidget(toggleB)

    scrollFrame:NewRow()

    local slider = addon.UICore:Build("Slider")
    slider:SetSize(200, 40)
    slider:SetLabel("Scale")
    slider:SetMinMaxValues(0.5, 2, 0.05)
    slider:SetValue(1)
    slider:SetOnValueChanged(function(_, value) Report("Scale = " .. value) end)
    scrollFrame:AddWidget(slider)

    local steppedSlider = addon.UICore:Build("Slider")
    steppedSlider:SetSize(200, 40)
    steppedSlider:SetLabel("Icon size")
    steppedSlider:SetMinMaxValues(8, 64, 1)
    steppedSlider:SetValue(32)
    steppedSlider:SetOnValueChanged(function(_, value) Report("Icon size = " .. value) end)
    scrollFrame:AddWidget(steppedSlider)

    scrollFrame:NewRow()

    local editBox = addon.UICore:Build("EditBox")
    editBox:SetSize(200, 38)
    editBox:SetLabel("Player name")
    editBox:SetMaxLetters(24)
    editBox:SetText(UnitName("player") or "")
    editBox:SetOnEnterPressed(function(_, text) Report("Name committed = " .. text) end)
    scrollFrame:AddWidget(editBox)

    local disabledEditBox = addon.UICore:Build("EditBox")
    disabledEditBox:SetSize(200, 38)
    disabledEditBox:SetLabel("Disabled input")
    disabledEditBox:SetText("read only")
    disabledEditBox:SetDisabled(true)
    scrollFrame:AddWidget(disabledEditBox)

    scrollFrame:NewRow()

    local dropdown = addon.UICore:Build("Dropdown")
    dropdown:SetSize(200, 38)
    dropdown:SetLabel("Role")
    dropdown:SetPlaceholder("Select a role")
    dropdown:SetList(DROPDOWN_LIST, DROPDOWN_ORDER)
    dropdown:SetValue("healer")
    dropdown:SetOnValueChanged(function(_, key) Report("Role = " .. DROPDOWN_LIST[key]) end)
    scrollFrame:AddWidget(dropdown)

    -- a long list to verify the pullout scrolling
    local longList, longOrder = {}, {}
    for i = 1, 30 do
        longList["item" .. i] = "Entry " .. i
        longOrder[i] = "item" .. i
    end

    local longDropdown = addon.UICore:Build("Dropdown")
    longDropdown:SetSize(200, 38)
    longDropdown:SetLabel("Long list")
    longDropdown:SetList(longList, longOrder)
    longDropdown:SetValue("item1")
    longDropdown:SetOnValueChanged(function(_, key) Report("Long list = " .. longList[key]) end)
    scrollFrame:AddWidget(longDropdown)

    scrollFrame:NewRow()

    local multiDropdown = addon.UICore:Build("MultiDropdown")
    multiDropdown:SetSize(200, 38)
    multiDropdown:SetLabel("Roles (multi)")
    multiDropdown:SetPlaceholder("Select roles")
    multiDropdown:SetList(DROPDOWN_LIST, DROPDOWN_ORDER)
    multiDropdown:SetSelectedKeys({ tank = true, healer = true })
    multiDropdown:SetOnValueChanged(function(_, key, checked)
        Report(DROPDOWN_LIST[key] .. " = " .. tostring(checked))
    end)
    scrollFrame:AddWidget(multiDropdown)

    local fontDropdown = addon.UICore:Build("FontDropdown")
    fontDropdown:SetSize(200, 38)
    fontDropdown:SetLabel("Font")
    fontDropdown:SetPlaceholder("Select a font")
    fontDropdown:SetOnValueChanged(function(_, key) Report("Font = " .. key) end)
    scrollFrame:AddWidget(fontDropdown)

    scrollFrame:NewRow()

    local textureDropdown = addon.UICore:Build("TextureDropdown")
    textureDropdown:SetSize(200, 38)
    textureDropdown:SetLabel("Status bar texture")
    textureDropdown:SetPlaceholder("Select a texture")
    textureDropdown:SetOnValueChanged(function(_, key) Report("Texture = " .. key) end)
    scrollFrame:AddWidget(textureDropdown)

    local soundDropdown = addon.UICore:Build("SoundDropdown")
    soundDropdown:SetSize(200, 38)
    soundDropdown:SetLabel("Sound")
    soundDropdown:SetPlaceholder("Select a sound")
    soundDropdown:SetOnValueChanged(function(_, key) Report("Sound = " .. key) end)
    scrollFrame:AddWidget(soundDropdown)

    scrollFrame:NewRow()

    local colorPicker = addon.UICore:Build("ColorPicker")
    colorPicker:SetSize(200, 38)
    colorPicker:SetLabel("Bar color")
    colorPicker:SetHasAlpha(true)
    colorPicker:SetColor(0.33, 0.55, 0.82, 1)
    colorPicker:SetOnColorChanged(function(widget) Report("Color = " .. widget:GetHexColor()) end)
    scrollFrame:AddWidget(colorPicker)

    local disabledColorPicker = addon.UICore:Build("ColorPicker")
    disabledColorPicker:SetSize(200, 38)
    disabledColorPicker:SetLabel("Disabled color")
    disabledColorPicker:SetColor(0.5, 0.5, 0.5, 1)
    disabledColorPicker:SetDisabled(true)
    scrollFrame:AddWidget(disabledColorPicker)

    scrollFrame:NewRow()

    local multiLine = addon.UICore:Build("MultiLineEditBox")
    multiLine:SetSize(400, 120)
    multiLine:SetLabel("Export / import")
    multiLine:SetText("Paste a profile string here.\nThe accept button shows up once the text changes.")
    multiLine:SetOnEnterPressed(function(_, text) Report("Committed " .. #text .. " characters") end)
    scrollFrame:AddWidget(multiLine)

    scrollFrame:NewRow()

    local link = addon.UICore:Build("TextRegion")
    link:SetText("|cff8080FFClick here to hover and click, like an interactive label|r")
    link:SetOnClick(function() Report("interactive text clicked") end)
    addon.UICore:SetTooltip(link, "TextRegion supports click and tooltip callbacks")
    scrollFrame:AddWidget(link)

    scrollFrame:NewRow()

    local rebuild = addon.UICore:Build("TextButton")
    rebuild:SetSize(120, 22)
    rebuild:SetText("Rebuild")
    rebuild:SetOnClick(function()
        demo.rebuildRequested = true
    end)
    scrollFrame:AddWidget(rebuild)

    local hello = addon.UICore:Build("TextButton")
    hello:SetSize(120, 22)
    hello:SetText("Say hello")
    hello:SetOnClick(function() Report("hello") end)
    scrollFrame:AddWidget(hello)

    scrollFrame:NewRow()

    local footer = addon.UICore:Build("TextRegion")
    footer:SetColor(0.6, 0.6, 0.6)
    footer:SetJustifyH("CENTER")
    footer:SetText("Rebuild releases every widget above back to the pool and builds the content again.")
    scrollFrame:AddWidget(footer)

    -- enough rows to make the scroll bar useful
    for i = 1, 12 do
        local row = addon.UICore:Build("ToggleBox")
        row:SetSize(200, 20)
        row:SetText("Filler toggle " .. i)
        scrollFrame:AddWidget(row)
    end
end

local function RebuildContent()
    demo.rebuildRequested = false
    demo.scrollFrame:Rerender()
    Report("content rebuilt from the frame pool")
end

---A window holding a single column of buttons, each one re-renders the scroll frame
local function PopulateWindow(window)
    addon.UICore:ResetColorCycle()

    for index, label in ipairs({ "First", "Second", "Third", "Fourth" }) do
        if index > 1 then
            window:NewRow()
        end

        local button = addon.UICore:Build("TextButton")
        button:SetSize(WINDOW_BUTTON_WIDTH, WINDOW_BUTTON_HEIGHT)
        button:SetText(label)
        button:SetColor(unpack(addon.UICore:GetNextColorCycle()))
        button:SetOnClick(function()
            Report(label .. " button clicked")
            demo.rebuildRequested = true
        end)
        window:AddWidget(button)
    end
end

-- MARK: Panel
local function CreatePanel()
    local panel = CreateFrame("Frame", "HBLyxGUITestDemo", UIParent, "BackdropTemplate")
    panel:SetSize(PANEL_WIDTH, PANEL_HEIGHT)
    panel:SetPoint("CENTER")
    panel:SetBackdrop(BACKDROP)
    panel:SetBackdropColor(0, 0, 0, 0.8)
    panel:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel:SetClampedToScreen(true)
    panel:Hide()

    local close = CreateFrame("Button", nil, panel, "BackdropTemplate")
    close:SetBackdrop(BACKDROP)
    close:SetBackdropColor(0, 0, 0, 0.5)
    close:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    close:SetSize(CLOSE_BUTTON_SIZE, CLOSE_BUTTON_SIZE)
    close:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, 0)
    close:SetScript("OnClick", function() panel:Hide() end)
    addon.UICore:BuildHover(close)

    local closeText = close:CreateFontString(nil, "OVERLAY")
    closeText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    closeText:SetTextColor(1, 1, 1, 1)
    closeText:SetText("X")
    closeText:SetPoint("CENTER", close, "CENTER", 0, 0)

    local scrollFrame = addon.UICore:Build("ScrollFrame")
    scrollFrame:SetParent(panel)
    scrollFrame:SetSize(PANEL_WIDTH - PANEL_PADDING * 2, PANEL_HEIGHT - PANEL_PADDING * 2 - TITLE_HEIGHT)
    scrollFrame:SetTitle("|TInterface\\AddOns\\HBLyx_Tools\\Media\\HBLyx.png:20:20|t HBLyx GUI Test Demo")
    scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", PANEL_PADDING, -PANEL_PADDING - TITLE_HEIGHT)

    demo.panel = panel
    demo.scrollFrame = scrollFrame

    scrollFrame:SetRenderer(PopulateContent)
    scrollFrame:Rerender()
    scrollFrame:Show()

    local window = addon.UICore:Build("Window")
    window:SetParent(panel)
    window:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT)
    window:SetPoint("TOPRIGHT", scrollFrame.frame, "TOPLEFT", -PANEL_PADDING, 0)
    window:SetRenderer(PopulateWindow)
    window:Rerender()
    window:Show()

    demo.window = window

    -- the rebuild button releases the widget that is running its own handler, so it is deferred one frame
    panel:SetScript("OnUpdate", function()
        if demo.rebuildRequested then
            RebuildContent()
        end
    end)

    return panel
end

local function ToggleDemo()
    if not demo.panel then
        CreatePanel()
        Report("GUI Test Demo loaded. Type /hbgui to toggle the demo panel.")
    end

    if demo.panel:IsShown() then
        demo.panel:Hide()
    else
        demo.panel:Show()
    end
end

SLASH_HBLYXGUI1 = "/hbgui"
SlashCmdList["HBLYXGUI"] = ToggleDemo