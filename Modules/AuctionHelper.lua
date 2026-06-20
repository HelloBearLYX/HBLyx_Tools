local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class AuctionHelper
local AuctionHelper = {
    modName = "AuctionHelper",
    frame = nil,
    loaded = false,
    spareButtons = {},
}

-- MARK: Constants
local MENU_BUTTON_WIDTH = 100
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
    button.text:SetText("Hide")
    button.text:SetTextColor(1, 1, 1, 1)
    button.text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

    button:SetScript("OnClick", function()
        button.toggled = not button.toggled
        if button.toggled then
            self.frame:Hide()
            button.text:SetText("Show")
        else
            self.frame:Show()
            button.text:SetText("Hide")
        end
    end)

    return button
end

-- MARK: CreateMenuButton
local function CreateMenuButton(self, name, index, color, onClick)
    local button = CreateFrame("Button", nil, self.frame)
    button:SetSize(MENU_BUTTON_WIDTH, 30)
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

    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.text:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.text:SetText(name)
    button.text:SetTextColor(1, 1, 1, 1)
    button.text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

    return button
end

-- MARK: CreateButton
local function CreateButton()
end

-- MARK: DeleteButton
local function DeleteButton(self, button)
    self.spareButtons[#self.spareButtons + 1] = button
    button:Hide()
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
    self.frame.background = self.frame:CreateTexture(nil, "BACKGROUND")
    self.frame.background:SetAllPoints()
    self.frame.background:SetColorTexture(0, 0, 0, 0.5)
    self.frame.border = CreateFrame("Frame", nil, self.frame, "BackdropTemplate")
    self.frame.border:SetAllPoints()
    self.frame.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    self.frame.border:SetBackdropBorderColor(0, 0, 0, 1)
    -- hide button
    CreateHideButton(self)
    -- menu buttons
    CreateMenuButton(self, "Consumerables", 0, COLOR_CYCLE[1], function() addon:debug("clicked Consumerables") end)
    CreateMenuButton(self, "Enhancements", 1, COLOR_CYCLE[2], function() addon:debug("clicked Enhancements") end)
    CreateMenuButton(self, "Gems", 2, COLOR_CYCLE[3], function() addon:debug("clicked Gems") end)
    CreateMenuButton(self, "Crafts", 3, COLOR_CYCLE[4], function() addon:debug("clicked Crafts") end)
end

-- MARK: UpdateStyle

---Update style settings and render them in-game for CustomTracker
function AuctionHelper:UpdateStyle()
    -- TODO: Update style settings and render them in-game when the user changes custom options
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function AuctionHelper:Test(on)
    if not addon.db[self.modName]["Enabled"] then -- if the module is not enabled, do not allow test mode
        return
    end

    if on then
        -- TODO: Implement test mode for your module
    else
        -- TODO: Disable test mode for your module
    end
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
