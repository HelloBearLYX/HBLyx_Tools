local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class MicroMenu
local MicroMenu = {
    modName = "MicroMenu",
    frame = nil,
    buttons = {},
    hearthstoneID = nil,
    customTeleportID = nil,
}

-- MARK: Hearthstone Data
local HEARTHSTONE_DEFAULT_ID = 6948
local CUSTOM_TELEPORT_DEFAULT_ID = 253629
local HEARTHSTONE_AND_TOY_ID_LIST = {
    6948,   -- Hearthstone
    54452,  -- Ethereal Portal
    64488,  -- The Innkeeper's Daughter
    93672,  -- Dark Portal
    142542, -- Tome of Town Portal
    162973, -- Greatfather Winter's Hearthstone
    163045, -- Headless Horseman's Hearthstone
    165669, -- Lunar Elder's Hearthstone
    165670, -- Peddlefeet's Lovely Hearthstone
    165802, -- Noble Gardener's Hearthstone
    166746, -- Fire Eater's Hearthstone
    166747, -- Brewfest Reveler's Hearthstone
    168907, -- Holographic Digitalization Hearthstone
    172179, -- Eternal Traveler's Hearthstone
    180290, -- Night Fae Hearthstone
    182773, -- Necrolord Hearthstone
    183716, -- Venthyr Sinstone
    184353, -- Kyrian Hearthstone
    188952, -- Dominated Hearthstone
    190196, -- Enlightened Hearthstone
    193588, -- Timewalker's Hearthstone
    200630, -- Ohn'ir Windsage's Hearthstone
    206195, -- Path of the Naaru
    208704, -- Deepdweller's Earthen Hearthstone
    209035, -- Hearthstone of the Flame
    210455, -- Draenei Hologem
    212337, -- Stone of the Hearth
    228940, -- Notorious Thread's Hearthstone
    235016, -- Redeployment Module
    236687, -- Explosive Hearthstone
    245970, -- P.O.S.T. Master's Express Hearthstone
    246565, -- Stellar Hearthstone
    257736, -- Hearthstone of the Lightcaller
    263489, -- Embrace of the Naaru
    263933, -- Huntmaster's Hearthstone
    265100, -- Coreway Foundry Hearthstone
}

local function GetFirstAvailableHearthstone()
    for _, itemID in ipairs(HEARTHSTONE_AND_TOY_ID_LIST) do
        local isOwnedItem = C_Item.GetItemCount(itemID, nil, true) > 0
        local hasToy = PlayerHasToy(itemID)
        local isUsableToy = (not hasToy) or C_ToyBox.IsToyUsable(itemID)

        if (isOwnedItem or hasToy) and isUsableToy then
            return itemID
        end
    end

    return HEARTHSTONE_DEFAULT_ID
end

local function SuppressBlizzardFrame(frameName)
    local container = _G[frameName]
    if not container then
        return false
    end

    if container._hblyxSuppressed then
        if container:IsShown() then
            container:Hide()
        end
        return true
    end

    container._hblyxSuppressed = true
    container:Hide()

    container:HookScript("OnShow", function(frame)
        frame:Hide()
    end)

    if type(container.Layout) == "function" then
        hooksecurefunc(container, "Layout", function(frame)
            if frame and frame:IsShown() then
                frame:Hide()
            end
        end)
    end

    return true
end

local function SuppressBlizzardMicroAndBagBars()
    local hasMicro = SuppressBlizzardFrame("MicroMenuContainer")
    local hasBags = SuppressBlizzardFrame("BagsBar")
    return hasMicro and hasBags
end

local function UpdateHearthstoneMacro(self, button)
    local hearthStoneID = addon.db[self.modName].HearthstoneID ~= "" and addon.db[self.modName].HearthstoneID or GetFirstAvailableHearthstone()
    self.hearthstoneID = hearthStoneID
    button:SetAttribute("type1", "macro")
    local macroText = string.format("/use item:%d", self.hearthstoneID)
    button:SetAttribute("macrotext1", macroText)
end

-- MARK: Buttons Action
local function CharacterButtonAction(self, button)
    button:SetScript("OnClick", function(self, buttonClicked)
        _G.ToggleCharacter("PaperDollFrame")
    end)
    button:RegisterForClicks("AnyDown")
end

local function BagButtonAction(self, button)
    button:SetScript("OnClick", function(self, buttonClicked)
        _G.ToggleAllBags()
    end)
    button:RegisterForClicks("AnyDown")
end

local function ProfessionButtonAction(self, button)
    button:SetScript("OnClick", function(self, buttonClicked)
        if addon.states.inCombat == false then
            _G.ToggleProfessionsBook()
        else
            _G.UIErrorsFrame:AddMessage(_G.ERR_NOT_IN_COMBAT, RED_FONT_COLOR:GetRGBA())
        end
    end)
    button:RegisterForClicks("AnyDown")
end

local function SpellbookButtonAction(self, button)
    button:SetScript("OnClick", function(self, buttonClicked)
        if buttonClicked == "RightButton" then
            _G.PlayerSpellsUtil.ToggleSpellBookFrame()
        else
            _G.PlayerSpellsUtil.ToggleClassTalentFrame()
        end
    end)
    button:RegisterForClicks("AnyDown")
end

local function SocialButtonAction(self, button)
    button:SetScript("OnClick", function(self, buttonClicked)
        if buttonClicked == "RightButton" then
            if IsInGuild() then
                _G.ToggleGuildFrame()
            else
                _G.ToggleGuildFinder()
            end
        else
            _G.ToggleFriendsFrame(1)
        end
    end)
    button:RegisterForClicks("AnyDown")
end

local function AchievementsButtonAction(self, button)
    button:SetScript("OnClick", function(self, buttonClicked)
        _G.ToggleAchievementFrame()
    end)
    button:RegisterForClicks("AnyDown")
end

local function TeleportButtonAction(self, button)
    UpdateHearthstoneMacro(self, button)
    button:SetAttribute("type2", "macro")
    button:SetAttribute("macrotext2", string.format("/use item:%d", CUSTOM_TELEPORT_DEFAULT_ID))
    self.customTeleportID = CUSTOM_TELEPORT_DEFAULT_ID
    button:RegisterForClicks("AnyDown")
end

local function HousingButtonAction(self, button)
    button:SetScript("OnClick", function(self, buttonClicked)
        _G.HousingFramesUtil.ToggleHousingDashboard()
    end)
    button:RegisterForClicks("AnyDown")
end

local function JournalButtonAction(self, button)
    button:SetScript("OnClick", function(self, buttonClicked)
        _G.ToggleEncounterJournal()
    end)
    button:RegisterForClicks("AnyDown")
end

local function LFGButtonAction(self, button)
    button:SetAttribute("type1", "macro")
    button:SetAttribute("macrotext1", "/click LFDMicroButton")
    button:SetAttribute("type2", "macro")
    button:SetAttribute("macrotext2", "/meetingstone")
    button:RegisterForClicks("AnyDown")
end

-- MARK: Teleport Tooltip
local function GetCooldownOutputString(itemID)
    local startTime, duration = C_Item.GetItemCooldown(itemID)
    if issecretvalue(startTime) or issecretvalue(duration) then
        return ""
    end
    local remaining = duration - (GetTime() - startTime)
    if remaining and remaining > 0 then
        local minutes = math.floor(remaining / 60)
        local seconds = math.floor(remaining % 60)
        -- red text
        return string.format("(|cffff0000%02d:%02d|r)", minutes, seconds)
    else
        return "-|cff00ff00" .. L["Ready"] .. "|r"
    end
end

-- MARK: Constants
local BUTTON_SIZE = 40
local BUTTON_SPACING = 0
local BUTTONS = {
    {name = "Character", texture = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\MicroMenu\\Character.PNG", action = CharacterButtonAction, tooltip = L["MicroMenuButton"]["Character"]},
    {name = "Bag", texture = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\MicroMenu\\Bag.PNG", action = BagButtonAction, tooltip = L["MicroMenuButton"]["Bag"]},
    {name = "Profession", texture = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\MicroMenu\\Profession.PNG", action = ProfessionButtonAction, tooltip = L["MicroMenuButton"]["Profession"]},
    {name = "Spellbook", texture = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\MicroMenu\\Spellbook.PNG", action = SpellbookButtonAction, tooltip = L["MicroMenuButton"]["Spellbook"]},
    {name = "Social", texture = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\MicroMenu\\Social.PNG", action = SocialButtonAction, tooltip = L["MicroMenuButton"]["Social"]},
    {name = "Achievements", texture = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\MicroMenu\\Achievements.PNG", action = AchievementsButtonAction, tooltip = L["MicroMenuButton"]["Achievements"]},
    {name = "Teleport", texture = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\MicroMenu\\Teleport.PNG", action = TeleportButtonAction},
    {name = "Housing", texture = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\MicroMenu\\Housing.PNG", action = HousingButtonAction, tooltip = L["MicroMenuButton"]["Housing"]},
    {name = "Journal", texture = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\MicroMenu\\Journal.PNG", action = JournalButtonAction, tooltip = L["MicroMenuButton"]["Journal"]},
    {name = "LFG", texture = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\MicroMenu\\LFG.PNG", action = LFGButtonAction, tooltip = L["MicroMenuButton"]["LFG"]},
}

-- MARK: Initialize

---Initialize (Constructor)
---@return MicroMenu MicroMenu a MicroMenu object
function MicroMenu:Initialize()
    -- Suppress Blizzard Micro Menu and Bag Bar
    if not SuppressBlizzardMicroAndBagBars() then
        C_Timer.After(1, SuppressBlizzardMicroAndBagBars)
    end

    self.frame = CreateFrame("Frame", ADDON_NAME .. self.modName, UIParent)
    self.frame:SetSize((#BUTTONS + 2) * BUTTON_SIZE + (#BUTTONS - 1) * BUTTON_SPACING, BUTTON_SIZE)
    self.frame:SetFrameStrata("LOW")
    self.buttons = {}
    for i, button in ipairs(BUTTONS) do
        local btn = CreateFrame("Button", nil, self.frame, "SecureActionButtonTemplate")
        btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
        btn:SetPoint("LEFT", self.frame, "LEFT", (i) * (BUTTON_SIZE + BUTTON_SPACING), 0)
        btn.texture = btn:CreateTexture(nil, "BACKGROUND")
        btn.texture:SetAllPoints()
        btn.texture:SetTexture(button.texture)

        -- button click actions
        if button.name ~= "Teleport" then
            button.action(self, btn)
        else
            -- add a delay to wait for joy box to load, then execute the action
            C_Timer.After(1, function() button.action(self, btn) end)
        end

        -- button mouseover tooltip
        if button.tooltip then
            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
                btn.texture:SetVertexColor(1, 1, 1, 0.25)

                GameTooltip:SetText(button.tooltip or button.name, 1, 1, 1)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
        elseif button.name == "Teleport" then
            btn:SetScript("OnEnter", function(frame)
                GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMRIGHT")
                btn.texture:SetVertexColor(1, 1, 1, 0.25)

                local tooltipText
                local hearthStoneCooldown = GetCooldownOutputString(self.hearthstoneID)
                if PlayerHasToy(self.customTeleportID) then
                    local customTeleportCooldown = GetCooldownOutputString(self.customTeleportID)

                    tooltipText = string.format(L["MicroMenuButton"]["Teleport1"] .. "\n" .. L["MicroMenuButton"]["Teleport2"], hearthStoneCooldown, customTeleportCooldown)
                else
                    tooltipText = string.format(L["MicroMenuButton"]["Teleport1"], hearthStoneCooldown)
                end

                GameTooltip:SetText(tooltipText, 1, 1, 1)
                GameTooltip:Show()
            end)
        end
        btn:SetScript("OnLeave", function(self)
            btn.texture:SetVertexColor(1, 1, 1, 1)
            GameTooltip:Hide()
        end)

        self.buttons[button.name] = btn
    end
    self.frame:Show()

    return self
end

-- MARK: GetAvailableHearthstoneID
function MicroMenu:GetAvailableHearthstoneID()
    local output = {}

    for _, itemID in ipairs(HEARTHSTONE_AND_TOY_ID_LIST) do
        local isOwnedItem = C_Item.GetItemCount(itemID, nil, true) > 0
        local hasToy = PlayerHasToy(itemID)
        local isUsableToy = (not hasToy) or C_ToyBox.IsToyUsable(itemID)

        if (isOwnedItem or hasToy) and isUsableToy then
            local itemName = select(1, C_Item.GetItemInfo(itemID))
            output[itemID] = itemName
        end
    end

    return output
end

-- MARK: UpdateStyle

---Update style settings and render them in-game for CustomTracker
function MicroMenu:UpdateStyle()
    self.frame:SetPoint("CENTER", UIParent, "CENTER", addon.db[self.modName]["X"] or 0, addon.db[self.modName]["Y"] or 0)
    UpdateHearthstoneMacro(self, self.buttons["Teleport"])
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function MicroMenu:Test(on)
    if not addon.db[self.modName]["Enabled"] then -- if the module is not enabled, do not allow test mode
        return
    end

    if on then
        addon.Utilities:ShowDragRegion(self.frame, L["MicroMenuSettings"])
        addon.Utilities:MakeFrameDragPosition(self.frame, self.modName, "X", "Y")
    else
        addon.Utilities:HideDragRegion(self.frame)
    end
end

-- MARK: RegisterEvents

---Register events
function MicroMenu:RegisterEvents()
end

-- MARK: Register Module
addon.core:RegisterModule(MicroMenu.modName, function() return MicroMenu:Initialize() end)
