local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class MicroMenu
local MicroMenu = {
    modName = "MicroMenu",
    frame = nil,
    groupMenu = nil,
    buttons = {},
    hearthstoneList = {},
    hearthstoneID = nil,
    customTeleportID = nil,
}

-- MARK: Hearthstone Data
local HEARTHSTONE_DEFAULT_ID = 6948
local CUSTOM_TELEPORT_DEFAULT_ID = 253629
local HIGHTLIGHT_COLOR = addon.UICore:GetHighlightColor()
local HEARTHSTONE_AND_TOY_ID_LIST = {
    6948,   -- Hearthstone

    -- Midnight
    263933, -- Huntmaster's Hearthstone
    265100, -- Coreway Foundry Hearthstone
    263489, -- Embrace of the Naaru
    264367, -- Midnight hearthstone

    -- The War Within
    257736, -- Hearthstone of the Lightcaller
    246565, -- Stellar Hearthstone
    245970, -- P.O.S.T. Master's Express Hearthstone
    228940, -- Notorious Thread's Hearthstone
    212337, -- Stone of the Hearth
    209035, -- Hearthstone of the Flame
    208704, -- Deepdweller's Earthen Hearthstone
    210455, -- Draenei Hologem

    -- Dragonflight
    236687, -- Explosive Hearthstone
    235016, -- Redeployment Module
    200630, -- Ohn'ir Windsage's Hearthstone
    193588, -- Timewalker's Hearthstone

    -- Shadowlands
    190196, -- Enlightened Hearthstone
    190237, -- Shadowlands hearthstone
    188952, -- Dominated Hearthstone
    184353, -- Kyrian Hearthstone
    182773, -- Necrolord Hearthstone
    180290, -- Night Fae Hearthstone
    183716, -- Venthyr Sinstone
    172179, -- Eternal Traveler's Hearthstone

    -- Seasonal / Holiday
    163045, -- Headless Horseman's Hearthstone
    162973, -- Greatfather Winter's Hearthstone
    165669, -- Lunar Elder's Hearthstone
    165670, -- Peddlefeet's Lovely Hearthstone
    165802, -- Noble Gardener's Hearthstone
    166746, -- Fire Eater's Hearthstone
    166747, -- Brewfest Reveler's Hearthstone

    -- Legacy / Misc
    64488,  -- The Innkeeper's Daughter
    28585,  -- Legacy hearthstone
    93672,  -- Dark Portal
    142542, -- Tome of Town Portal
    142298, -- Legacy hearthstone
    168907, -- Holographic Digitalization Hearthstone
    54452,  -- Ethereal Portal
    206195, -- Path of the Naaru
}


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

local function GetHearthstoneList(self)
    local output = {}

    for _, itemID in ipairs(HEARTHSTONE_AND_TOY_ID_LIST) do
        local isOwnedItem = C_Item.GetItemCount(itemID, nil, true) > 0
        local hasToy = PlayerHasToy(itemID)
        local isUsableToy = (not hasToy) or C_ToyBox.IsToyUsable(itemID)

        if (isOwnedItem or hasToy) and isUsableToy then
            output[#output + 1] = itemID
        end
    end

    self.hearthstoneList = output
end

local function GetNextRandomHearthstone(self, currentIndex, times)
    if not self.hearthstoneList or #self.hearthstoneList == 0 then
        return nil, nil
    end

    if #self.hearthstoneList == 1 or (times and times >= 10) then
        return 1, self.hearthstoneList[1]
    end

    local randomIndex = math.random(#self.hearthstoneList)
    local itemID = self.hearthstoneList[randomIndex]
    local isToyNotUsable = PlayerHasToy(itemID) and not C_ToyBox.IsToyUsable(itemID)
    if isToyNotUsable or (currentIndex and randomIndex == currentIndex) then
        return GetNextRandomHearthstone(self, currentIndex, (times or 0) + 1)
    end

    return randomIndex, itemID
end

local function GetHearthstoneFromList(self, currentIndex)
    -- if 0, get a random hearthstone from the list
    if addon.db[self.modName].HearthstoneID == 0 and #self.hearthstoneList > 0 then
        local randomIndex, itemID = GetNextRandomHearthstone(self, currentIndex)
        return itemID or HEARTHSTONE_DEFAULT_ID, randomIndex
    elseif addon.db[self.modName].HearthstoneID then
        -- if not 0 and not nil, use the selected hearthstone
        return addon.db[self.modName].HearthstoneID, nil
    else
        -- if nil, use the default hearthstone
        return HEARTHSTONE_DEFAULT_ID, nil
    end
end

local function UpdateHearthstoneMacro(self, button)
    if not button then
        return
    end

    if not self.hearthstoneList or #self.hearthstoneList == 0 then
        GetHearthstoneList(self)
    end

    local macroText
    local configuredHearthstoneID = addon.db[self.modName].HearthstoneID

    button:SetAttribute("type1", "macro")

    if configuredHearthstoneID == 0 and #self.hearthstoneList > 0 then
        local currentIndex = button.randomHearthstoneIndex
        self.hearthstoneID, button.randomHearthstoneIndex = GetHearthstoneFromList(self, currentIndex)
        macroText = string.format("/use item:%d\n/run _G.HBLyxTools_UpdateMicroMenuTeleportButton()", self.hearthstoneID)
    else
        self.hearthstoneID, button.randomHearthstoneIndex = GetHearthstoneFromList(self, nil)
        macroText = string.format("/use item:%d", self.hearthstoneID)
    end

    button:SetAttribute("macrotext1", macroText)
end

_G.HBLyxTools_UpdateMicroMenuTeleportButton = function()
    if InCombatLockdown and InCombatLockdown() then
        return
    end

    local teleportButton = MicroMenu.buttons and MicroMenu.buttons["Teleport"]
    if not teleportButton then
        return
    end

    UpdateHearthstoneMacro(MicroMenu, teleportButton)
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

-- MARK: Group Menu
local function ReadyCheckAction(self, button)
    button:SetAttribute("type1", "macro")
    button:SetAttribute("macrotext1", "/readycheck")
    button:RegisterForClicks("AnyDown")
end

-- Countdown length is user-configurable (CountdownSeconds), refreshed whenever settings change.
local function UpdateCountdownMacro(self, button)
    if not button then
        return
    end

    local countdownTime = addon.db[self.modName]["CountdownSeconds"] or 10
    button:SetAttribute("macrotext1", "/countdown " .. countdownTime)
end

local function CountdownTenAction(self, button)
    button:SetAttribute("type1", "macro")
    UpdateCountdownMacro(self, button)
    button:SetAttribute("type2", "macro")
    button:SetAttribute("macrotext2", "/countdown 0")
    button:RegisterForClicks("AnyDown")
end

local function ResetInstanceAction(self, button)
    button:SetScript("OnClick", function(self, buttonClicked)
        ResetInstances()
    end)
    button:RegisterForClicks("AnyDown")
end

-- MARK: Group Menu Raid Markers
-- Sheet SYMBOL order (1 Star...8 Skull) is not the WORLD marker ID order; this maps
-- each symbol to the flare that actually carries it (same table EllesmereUIQoL_RaidTools uses).
local MARKER_SYMBOL_TO_WORLD = { 5, 6, 3, 2, 7, 1, 4, 8 }
local RAID_MARKER_TEXTURE = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_%d"

-- Left click toggles the target marker, right click sets the world marker.
local function MakeRaidMarkerAction(symbolIndex)
    local worldID = MARKER_SYMBOL_TO_WORLD[symbolIndex]
    return function(self, button)
        button:SetAttribute("type1", "macro")
        button:SetAttribute("macrotext1", (SLASH_TARGET_MARKER1 or "/tm") .. " !" .. symbolIndex)
        button:SetAttribute("type2", "worldmarker")
        button:SetAttribute("marker2", tostring(worldID))
        button:SetAttribute("action2", "set")
        button:SetAttribute("useOnKeyDown", true)
        button:RegisterForClicks("AnyDown")
    end
end

-- Left click clears the target marker, right click clears every world marker.
local function ClearRaidMarkersAction(self, button)
    button:SetAttribute("type1", "macro")
    button:SetAttribute("macrotext1", (SLASH_TARGET_MARKER1 or "/tm") .. " 0")
    button:SetAttribute("type2", "macro")
    button:SetAttribute("macrotext2", (SLASH_CLEAR_WORLD_MARKER1 or "/cwm") .. " " .. (ALL or "All"))
    button:SetAttribute("useOnKeyDown", true)
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
local DEFAULT_BUTTON_SIZE = 40
local DEFAULT_GROUP_BUTTON_SIZE = 35
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
local GROUP_BUTTONS = {
    {name = "Marker1", texture = string.format(RAID_MARKER_TEXTURE, 1), action = MakeRaidMarkerAction(1), tooltip = L["GroupMenuButton"]["Marker"]},
    {name = "Marker2", texture = string.format(RAID_MARKER_TEXTURE, 2), action = MakeRaidMarkerAction(2), tooltip = L["GroupMenuButton"]["Marker"]},
    {name = "Marker3", texture = string.format(RAID_MARKER_TEXTURE, 3), action = MakeRaidMarkerAction(3), tooltip = L["GroupMenuButton"]["Marker"]},
    {name = "Marker4", texture = string.format(RAID_MARKER_TEXTURE, 4), action = MakeRaidMarkerAction(4), tooltip = L["GroupMenuButton"]["Marker"]},
    {name = "Marker5", texture = string.format(RAID_MARKER_TEXTURE, 5), action = MakeRaidMarkerAction(5), tooltip = L["GroupMenuButton"]["Marker"]},
    {name = "Marker6", texture = string.format(RAID_MARKER_TEXTURE, 6), action = MakeRaidMarkerAction(6), tooltip = L["GroupMenuButton"]["Marker"]},
    {name = "Marker7", texture = string.format(RAID_MARKER_TEXTURE, 7), action = MakeRaidMarkerAction(7), tooltip = L["GroupMenuButton"]["Marker"]},
    {name = "Marker8", texture = string.format(RAID_MARKER_TEXTURE, 8), action = MakeRaidMarkerAction(8), tooltip = L["GroupMenuButton"]["Marker"]},
    {name = "ClearMarkers", texture = "Interface\\Buttons\\UI-GroupLoot-Pass-Up", action = ClearRaidMarkersAction, tooltip = L["GroupMenuButton"]["ClearMarkers"]},
    {name = "ReadyCheck", texture = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\MicroMenu\\ReadyCheck.PNG", action = ReadyCheckAction, tooltip = L["GroupMenuButton"]["ReadyCheck"]},
    {name = "Countdown", texture = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\MicroMenu\\Countdown.PNG", action = CountdownTenAction, tooltip = L["GroupMenuButton"]["CountdownTen"]},
    {name = "ResetInstance", texture = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\MicroMenu\\Reset.PNG", action = ResetInstanceAction, tooltip = L["GroupMenuButton"]["ResetInstance"]},
}

local function ApplyMicroMenuStyle(self)
    if not self.frame or not self.buttons then
        return
    end

    local size = addon.db[self.modName]["IconSize"] or DEFAULT_BUTTON_SIZE
    local spacing = addon.db[self.modName]["IconSpacing"] or 0
    local vertical = addon.db[self.modName]["Vertical"] == true
    if vertical then
        self.frame:SetSize(size, #BUTTONS * size + (#BUTTONS - 1) * spacing)
    else
        self.frame:SetSize(#BUTTONS * size + (#BUTTONS - 1) * spacing, size)
    end

    for i, buttonData in ipairs(BUTTONS) do
        local btn = self.buttons[buttonData.name]
        if btn then
            btn:SetSize(size, size)
            btn:ClearAllPoints()
            if vertical then
                btn:SetPoint("TOP", self.frame, "TOP", 0, -(i - 1) * (size + spacing))
            else
                btn:SetPoint("LEFT", self.frame, "LEFT", (i - 1) * (size + spacing), 0)
            end
        end
    end
end

local function ApplyGroupMenuStyle(self)
    if not self.groupMenu then
        return
    end

    local size = addon.db[self.modName]["GroupMenuIconSize"] or DEFAULT_GROUP_BUTTON_SIZE
    local spacing = addon.db[self.modName]["GroupMenuIconSpacing"] or 0
    local vertical = addon.db[self.modName]["GroupMenuVertical"] == true
    if vertical then
        self.groupMenu:SetSize(size, #GROUP_BUTTONS * size + (#GROUP_BUTTONS - 1) * spacing)
    else
        self.groupMenu:SetSize(#GROUP_BUTTONS * size + (#GROUP_BUTTONS - 1) * spacing, size)
    end
    self.groupMenu:ClearAllPoints()
    self.groupMenu:SetPoint("CENTER", UIParent, "CENTER", addon.db[self.modName]["X_GroupMenu"] or 0, addon.db[self.modName]["Y_GroupMenu"] or 0)

    for i, buttonData in ipairs(GROUP_BUTTONS) do
        local btn = self.groupMenu.buttons[buttonData.name]
        if btn then
            btn:SetSize(size, size)
            btn:ClearAllPoints()
            if vertical then
                btn:SetPoint("TOP", self.groupMenu, "TOP", 0, -(i - 1) * (size + spacing))
            else
                btn:SetPoint("LEFT", self.groupMenu, "LEFT", (i - 1) * (size + spacing), 0)
            end
        end
    end
end

local function ShouldShowGroupMenu(self)
    if not addon.db[self.modName]["GroupMenuEnabled"] then
        return false
    end

    if addon.db[self.modName]["GroupMenuOnlyInGroup"] then
        return IsInGroup()
    end

    return true
end

local function CreateGroupMenu(self)
    if self.groupMenu then
        return
    end

    self.groupMenu = CreateFrame("Frame", nil, UIParent)
    self.groupMenu:SetSize(#GROUP_BUTTONS * DEFAULT_GROUP_BUTTON_SIZE, DEFAULT_GROUP_BUTTON_SIZE)
    self.groupMenu:SetFrameStrata("LOW")
    self.groupMenu.buttons = {}
    for i, buttonData in ipairs(GROUP_BUTTONS) do
        local btn = CreateFrame("Button", nil, self.groupMenu, "SecureActionButtonTemplate")
        btn:SetSize(DEFAULT_GROUP_BUTTON_SIZE, DEFAULT_GROUP_BUTTON_SIZE)
        btn:SetPoint("LEFT", self.groupMenu, "LEFT", (i - 1) * DEFAULT_GROUP_BUTTON_SIZE, 0)
        btn.texture = btn:CreateTexture(nil, "BACKGROUND")
        btn.texture:SetAllPoints()
        btn.texture:SetTexture(buttonData.texture)

        buttonData.action(self, btn)

        if buttonData.tooltip then
            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
                btn.texture:SetVertexColor(unpack(HIGHTLIGHT_COLOR))
                GameTooltip:SetText(buttonData.tooltip or buttonData.name, 1, 1, 1)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
        end
        btn:SetScript("OnLeave", function(self)
            btn.texture:SetVertexColor(1, 1, 1, 1)
            GameTooltip:Hide()
        end)

        self.groupMenu.buttons[buttonData.name] = btn
    end

    ApplyGroupMenuStyle(self)
    self.groupMenu:Show()
end

-- MARK: Initialize

---Initialize (Constructor)
---@return MicroMenu MicroMenu a MicroMenu object
function MicroMenu:Initialize()
    -- Suppress Blizzard Micro Menu and Bag Bar
    if not SuppressBlizzardMicroAndBagBars() then
        C_Timer.After(1, SuppressBlizzardMicroAndBagBars)
    end

    self.frame = CreateFrame("Frame", ADDON_NAME .. self.modName, UIParent)
    self.frame:SetSize(#BUTTONS * DEFAULT_BUTTON_SIZE, DEFAULT_BUTTON_SIZE)
    self.frame:SetFrameStrata("LOW")
    self.buttons = {}
    for i, button in ipairs(BUTTONS) do
        local btn = CreateFrame("Button", nil, self.frame, "SecureActionButtonTemplate")
        btn:SetSize(DEFAULT_BUTTON_SIZE, DEFAULT_BUTTON_SIZE)
        btn:SetPoint("LEFT", self.frame, "LEFT", (i - 1) * DEFAULT_BUTTON_SIZE, 0)
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
                btn.texture:SetVertexColor(unpack(HIGHTLIGHT_COLOR))
                GameTooltip:SetText(button.tooltip or button.name, 1, 1, 1)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
        elseif button.name == "Teleport" then
            btn:SetScript("OnEnter", function(frame)
                GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMRIGHT")
                btn.texture:SetVertexColor(unpack(HIGHTLIGHT_COLOR))
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

    ApplyMicroMenuStyle(self)

    if addon.db[self.modName]["GroupMenuEnabled"] then
        CreateGroupMenu(self)
    end

    return self
end

-- MARK: GetAvailableHearthstoneID
function MicroMenu:GetAvailableHearthstoneID()
    if not self.hearthstoneList or #self.hearthstoneList == 0 then
        GetHearthstoneList(self)
    end

    local output = {}
    output[0] = L["Random"]
    for _, itemID in ipairs(self.hearthstoneList) do
        output[itemID] = C_Item.GetItemNameByID(itemID)
    end

    return output
end

-- MARK: UpdateStyle

---Update style settings and render them in-game for CustomTracker
function MicroMenu:UpdateStyle()
    if addon.states["inCombat"] then return end

    ApplyMicroMenuStyle(self)
    self.frame:SetPoint("CENTER", UIParent, "CENTER", addon.db[self.modName]["X"] or 0, addon.db[self.modName]["Y"] or 0)
    UpdateHearthstoneMacro(self, self.buttons["Teleport"])

    if ShouldShowGroupMenu(self) then
        if not self.groupMenu then
            CreateGroupMenu(self)
        end
        UpdateCountdownMacro(self, self.groupMenu.buttons["Countdown"])
        ApplyGroupMenuStyle(self)
        self.groupMenu:Show()
    elseif self.groupMenu then
        self.groupMenu:Hide()
    end
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function MicroMenu:Test(on)
    if not addon.db[self.modName]["Enabled"] then -- if the module is not enabled, do not allow test mode
        return
    end

    if on then
        addon.Utilities:ShowEditFrame(self.frame, addon.db[self.modName], "X", "Y", nil, L["MicroMenuSettings"], self.modName)

        if addon.db[self.modName]["GroupMenuEnabled"] and not self.groupMenu then
            CreateGroupMenu(self)
        end

        if addon.db[self.modName]["GroupMenuEnabled"] and self.groupMenu then
            self.groupMenu:Show()
            addon.Utilities:ShowEditFrame(self.groupMenu, addon.db[self.modName], "X_GroupMenu", "Y_GroupMenu", nil, L["GroupMenuSettings"], self.modName)
        end
    else
        addon.Utilities:HideEditFrame(self.frame)

        if self.groupMenu then
            addon.Utilities:HideEditFrame(self.groupMenu)
        end

        self:UpdateStyle()
    end
end

-- MARK: RegisterEvents

---Register events
function MicroMenu:RegisterEvents()
    addon.core:RegisterEvent("GROUP_ROSTER_UPDATE", self.frame, self.modName)
    addon.core:RegisterEvent("PLAYER_REGEN_ENABLED", self.frame, self.modName)

    self.frame:SetScript("OnEvent", function(_, event)
        if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_REGEN_ENABLED" then
            self:UpdateStyle()
        end
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(MicroMenu.modName, L["MicroMenuSettings"], function() return MicroMenu:Initialize() end)
