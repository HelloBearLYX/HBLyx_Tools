local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local data = addon.data.AUCTION_HELPER

---@class AuctionHelper
local AuctionHelper = {
    modName = "AuctionHelper",
    frame = nil,
    panel = nil,
    loaded = false,
    currentX = 0,
    currentY = 0,
    currentRowMaxHeight = 0,
    activeSubCategories = {},
    spareButtons = {},
    spareSubCategory = {},
}

-- MARK: Constants
local MENU_BUTTON_WIDTH = 100
local MENU_BUTTON_HEIGHT = 40
local TAB_HEIGHT = 20
local BUTTON_WIDTH = 40
local BUTTON_HEIGHT = 40
local SUBCATEGORY_GAP = 5
local UNKNOWN_TEXTURE = 134400
local COLOR_CYCLE = {
    {0.33, 0.55, 0.82, 1},
    {0.42, 0.70, 0.48, 1},
    {0.89, 0.62, 0.34, 1},
    {0.73, 0.47, 0.76, 1},
    {0.86, 0.42, 0.46, 1},
    {0.45, 0.73, 0.72, 1},
    {0.78, 0.68, 0.35, 1},
}

-- MARK: Initialize

---Initialize (Constructor)
---@return AuctionHelper AuctionHelper a AuctionHelper object
function AuctionHelper:Initialize()
    self.frame = CreateFrame("Frame", ADDON_NAME .. self.modName, UIParent)

    return self
end

-- MARK: CreateHideButton
local function CreateHideButton(self)
    local button = CreateFrame("Button", nil, AuctionHouseFrame)
    button.toggled = false
    button:SetSize(50, 20)
    button:SetPoint("BOTTOMRIGHT", AuctionHouseFrame, "TOPRIGHT", 0, 0)

    button.texture = button:CreateTexture(nil, "BACKGROUND")
    button.texture:SetAllPoints()
    button.texture:SetColorTexture(0.5, 0.5, 0.5, 1)

    button.border = CreateFrame("Frame", nil, button, "BackdropTemplate")
    button.border:SetAllPoints()
    button.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    button.border:SetBackdropBorderColor(0, 0, 0, 1)

    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.text:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.text:SetText(L["Hide"])
    button.text:SetTextColor(1, 1, 1, 1)
    button.text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

    button:SetScript("OnClick", function()
        button.toggled = not button.toggled
        if button.toggled then
            self.frame:Hide()
            button.text:SetText(L["Show"])
        else
            self.frame:Show()
            button.text:SetText(L["Hide"])
        end
    end)

    return button
end

-- MARK: CreatePanel
local function CreatePanel(self)
    local panel = CreateFrame("Frame", nil, self.frame)
    panel:SetSize(self.frame:GetWidth() - 10, self.frame:GetHeight() - MENU_BUTTON_HEIGHT - 15) -- leave space for the menu buttons
    panel:SetPoint("TOP", self.frame, "TOP", 0, -MENU_BUTTON_HEIGHT - 10)

    -- used to debug, show the panel area
    -- panel.background = panel:CreateTexture(nil, "BACKGROUND")
    -- panel.background:SetAllPoints()
    -- panel.background:SetColorTexture(1, 1, 1, 0.5)

    return panel
end

-- MARK: CreateMenuButton
local function CreateMenuButton(self, name, index, color, onClick)
    local button = CreateFrame("Button", nil, self.frame)
    button:SetSize(MENU_BUTTON_WIDTH, MENU_BUTTON_HEIGHT)
    button:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 5 + index * MENU_BUTTON_WIDTH, -5)
    button:SetScript("OnClick", onClick)

    button.texture = button:CreateTexture(nil, "BACKGROUND")
    button.texture:SetAllPoints()
    if color and type(color) == "table" then
        button.texture:SetColorTexture(unpack(color))
    else
        button.texture:SetColorTexture(0, 0, 0, 1)
    end

    button.border = CreateFrame("Frame", nil, button, "BackdropTemplate")
    button.border:SetAllPoints()
    button.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    button.border:SetBackdropBorderColor(0, 0, 0, 1)

    button.selectOverlay = button:CreateTexture(nil, "HIGHLIGHT")
    button.selectOverlay:SetAllPoints()
    button.selectOverlay:SetBlendMode("ADD")
    button.selectOverlay:SetColorTexture(1, 1, 1, 0.25)

    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.text:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.text:SetText(name)
    button.text:SetTextColor(1, 1, 1, 1)
    button.text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

    return button
end

-- MARK: Locale Helpers
local function FetchCategoryLocales(category)
    return L["AuctionCategory"][category]
end

local function FetchTagLocales(tag)
    return L["AuctionTag"][tag]
end

-- MARK: CreateCategoryTab
local function CreateCategoryTab(tab, subCategoryData, color, parent, width)
    tab:SetParent(parent)
    tab:ClearAllPoints()
    tab:SetSize(width, TAB_HEIGHT)
    tab:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)

    if color and type(color) == "table" then
        tab.texture:SetColorTexture(unpack(color))
    else
        tab.texture:SetColorTexture(0, 0, 0, 1)
    end
    tab.text:SetText(FetchCategoryLocales(subCategoryData.subCategory) or subCategoryData.subCategory or "")
    tab.text:SetTextColor(1, 1, 1, 1)
    tab.text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    tab:Show()

    return tab
end

-- MARK: CreateButton
local function CreateButton(self, itemID, tag, parent)
    local button = table.remove(self.spareButtons)
    if not button then
        button = CreateFrame("Button", nil, parent)
        button:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT)
        button.texture = button:CreateTexture(nil, "BACKGROUND")
        button.texture:SetAllPoints()

        button.textFrame = CreateFrame("Frame", nil, button)
        button.textFrame:SetAllPoints()

        button.name = button.textFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        button.name:SetPoint("BOTTOM", button, "BOTTOM", 0, 0)
        button.name:SetTextColor(1, 1, 1, 1)
        button.name:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")

        button.quantity = button.textFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        button.quantity:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, 0)
        button.quantity:SetTextColor(1, 1, 1, 1)
        button.quantity:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")

        button.border = CreateFrame("Frame", nil, button, "BackdropTemplate")
        button.border:SetAllPoints()
        button.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
        button.border:SetBackdropBorderColor(0, 0, 0, 1)

        button.selectOverlay = button:CreateTexture(nil, "HIGHLIGHT")
        button.selectOverlay:SetAllPoints()
        button.selectOverlay:SetBlendMode("ADD")
        button.selectOverlay:SetColorTexture(1, 1, 1, 0.25)

        button:SetScript("OnClick", function(self)
            if AuctionHouseFrame and AuctionHouseFrame.SearchBar and AuctionHouseFrame.SearchBar.SearchBox then
                if AuctionHouseFrame.SetDisplayMode then
                    AuctionHouseFrame:SetDisplayMode(AuctionHouseFrameDisplayMode.Buy)
                end

                local itemName = C_Item.GetItemNameByID(self.itemID)
                if itemName then
                    AuctionHouseFrame.SearchBar.SearchBox:SetText(itemName)
                    AuctionHouseFrame.SearchBar.SearchButton:Click()
                else
                    C_Item.RequestLoadItemDataByID(self.itemID)
                    AuctionHouseFrame.SearchBar.SearchBox:SetText(self.itemID)
                    C_Timer.After(0.2, function()
                        local loadedName = C_Item.GetItemNameByID(self.itemID)
                        if loadedName then
                            AuctionHouseFrame.SearchBar.SearchBox:SetText(loadedName)
                        end
                        AuctionHouseFrame.SearchBar.SearchButton:Click()
                    end)
                end
            end
        end)
    else
        button:SetParent(parent)
    end

    button:ClearAllPoints()
    button.itemID = itemID
    local itemTexture = select(10, C_Item.GetItemInfo(itemID))
    button.texture:SetTexture(itemTexture or UNKNOWN_TEXTURE)
    button.name:SetText(FetchTagLocales(tag) or tag or "")
    local quantity = C_Item.GetItemCount(C_Item.GetItemNameByID(itemID)) or 0
    if quantity >= 1 then
        button.quantity:SetText(quantity >= 1 and quantity or "")
        button.texture:SetVertexColor(1, 1, 1, 1)
    else
        button.quantity:SetText("")
        button.texture:SetVertexColor(0.66, 0.66, 0.66, 0.66)
    end
    button:Show()

    return button
end

-- MARK: DeleteButton
local function DeleteButton(self, button)
    self.spareButtons[#self.spareButtons + 1] = button
    button:ClearAllPoints()
    button:SetParent(self.panel)
    button:Hide()
    button.name:ClearText()
    button.quantity:ClearText()
    button.itemID = nil
end

-- MARK: CreateSubCategoryFrame
local function CreateSubCategoryFrame(self)
    local frame = table.remove(self.spareSubCategory)
    if not frame then
        frame = CreateFrame("Frame", nil, self.panel)
        frame.buttons = {}

        frame.tab = CreateFrame("Button", nil, frame)
        frame.tab.texture = frame.tab:CreateTexture(nil, "BACKGROUND")
        frame.tab.texture:SetAllPoints()

        frame.tab.border = CreateFrame("Frame", nil, frame.tab, "BackdropTemplate")
        frame.tab.border:SetAllPoints()
        frame.tab.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
        frame.tab.border:SetBackdropBorderColor(0, 0, 0, 1)

        frame.tab.text = frame.tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.tab.text:SetPoint("CENTER", frame.tab, "CENTER", 0, 0)
    else
        frame:SetParent(self.panel)
    end

    frame:ClearAllPoints()
    frame:Show()
    return frame
end

-- MARK: DeleteSubCategoryFrame
local function DeleteSubCategoryFrame(self, frame)
    for i = #frame.buttons, 1, -1 do
        DeleteButton(self, frame.buttons[i])
        frame.buttons[i] = nil
    end

    frame.tab:Hide()
    frame:ClearAllPoints()
    frame:Hide()
    self.spareSubCategory[#self.spareSubCategory + 1] = frame
end

-- MARK: ClearPanel
local function ClearPanel(self)
    for i = #self.activeSubCategories, 1, -1 do
        DeleteSubCategoryFrame(self, self.activeSubCategories[i])
        self.activeSubCategories[i] = nil
    end
end

-- MARK: CreateSubCategory
local function CreateSubCategory(self, subCategoryData, color)
    local frame = CreateSubCategoryFrame(self)
    local itemCount = #subCategoryData.items
    local maxColumns = math.max(1, math.floor(self.panel:GetWidth() / BUTTON_WIDTH))
    local columns = math.max(1, math.min(itemCount, maxColumns))
    local rows = math.max(1, math.ceil(itemCount / columns))
    local frameWidth = columns * BUTTON_WIDTH
    local tab = CreateCategoryTab(frame.tab, subCategoryData, color, frame, frameWidth)

    for i, item in ipairs(subCategoryData.items) do
        local button = CreateButton(self, item.itemID, item.tag, frame)
        frame.buttons[#frame.buttons + 1] = button
        local column = (i - 1) % columns
        local row = math.floor((i - 1) / columns)
        button:SetPoint("TOPLEFT", frame, "TOPLEFT", column * BUTTON_WIDTH, -TAB_HEIGHT - row * BUTTON_HEIGHT)
    end

    frame:SetSize(frameWidth, tab:GetHeight() + rows * BUTTON_HEIGHT)
    -- compute the position for the the subCategory
    if self.currentX > 0 and self.currentX + frame:GetWidth() > self.panel:GetWidth() then
        self.currentX = 0
        self.currentY = self.currentY - self.currentRowMaxHeight - SUBCATEGORY_GAP
        self.currentRowMaxHeight = 0
    end

    frame:SetPoint("TOPLEFT", self.panel, "TOPLEFT", self.currentX, self.currentY)
    self.currentX = self.currentX + frame:GetWidth() + SUBCATEGORY_GAP
    self.currentRowMaxHeight = math.max(self.currentRowMaxHeight, frame:GetHeight())
    self.activeSubCategories[#self.activeSubCategories + 1] = frame

    return frame
end

-- MARK: RenderPanel
local function RenderPanel(self, categoryData)
    if not self.panel then return end

    ClearPanel(self)

    self.currentX = 0
    self.currentY = 0
    self.currentRowMaxHeight = 0

    if categoryData and categoryData.subCategories then
        for i, subCategoryData in ipairs(categoryData.subCategories) do
            CreateSubCategory(self, subCategoryData, COLOR_CYCLE[i % #COLOR_CYCLE + 1])
        end
    end

end

-- MARK: CreateMainFrame

---Create the main frame for the AuctionHelper module
---@param self AuctionHelper the AuctionHelper object
local function CreateMainFrame(self)
    -- change the parent of the frame to AuctionHouseFrame to make sure it follows the same visibility
    self.frame:SetParent(AuctionHouseFrame)
    local height = AuctionHouseFrame:GetHeight()
    -- create the main backdrop panel
    self.frame:SetSize(410, height) -- set the size of the frame
    self.frame:SetPoint("TOPLEFT", AuctionHouseFrame, "TOPRIGHT", 5, 0)

    self.frame.titleFrame = CreateFrame("Frame", nil, self.frame)
    self.frame.titleFrame:SetAllPoints()
    self.frame.title = self.frame.titleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.frame.title:SetPoint("BOTTOM", self.frame, "TOP", 0, 0)
    self.frame.title:SetText(L["AuctionHelperTitle"])
    self.frame.title:SetTextColor(1, 1, 1, 1)
    self.frame.title:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")

    self.frame.background = self.frame:CreateTexture(nil, "BACKGROUND")
    self.frame.background:SetAllPoints()
    self.frame.background:SetColorTexture(0, 0, 0, 0.5)
    self.frame.border = CreateFrame("Frame", nil, self.frame, "BackdropTemplate")
    self.frame.border:SetAllPoints()
    self.frame.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    self.frame.border:SetBackdropBorderColor(0, 0, 0, 1)
    -- hide button
    CreateHideButton(self)
    -- Create the panel
    self.panel = CreatePanel(self)
    -- menu buttons
    for i, categoryData in ipairs(data) do
        local name = FetchCategoryLocales(categoryData.category) or categoryData.category or ""
        CreateMenuButton(self, name, i - 1, COLOR_CYCLE[i % #COLOR_CYCLE + 1], function() RenderPanel(self, categoryData) end)
    end
    
    C_Timer.After(0.5, function() RenderPanel(self, data[1]) end) -- render the first category by default
end

-- MARK: UpdateStyle

---Update style settings and render them in-game for CustomTracker
function AuctionHelper:UpdateStyle()
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function AuctionHelper:Test(on)
end

-- MARK: RegisterEvents

---Register events
function AuctionHelper:RegisterEvents()
    self.frame:RegisterEvent("ADDON_LOADED")

    self.frame:SetScript("OnEvent", function(_, event, ...)
        if event == "ADDON_LOADED" then
            local addonName = ...
            if addonName == "Blizzard_AuctionHouseUI" then
                self.frame:UnregisterEvent("ADDON_LOADED")
                CreateMainFrame(self)
                self.loaded = true
            end
        end
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(AuctionHelper.modName, function() return AuctionHelper:Initialize() end)