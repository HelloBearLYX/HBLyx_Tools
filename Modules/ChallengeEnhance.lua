local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class ChallengeEnhance
---@field buttons table ChallengeEnhance buttons
---@field eventFrame frame Handle Blizzard PVEFrame loaded
---@field modName string module name for registering in core
local ChallengeEnhance = {
    modName = "ChallengeEnhance",
    buttons = {},
    loaded = false,
    eventFrame = CreateFrame("Frame", ADDON_NAME .. "_ChallengeEnhanceEvent"),
}

-- MARK: Initialize

---Intialize(Constructor)
---@return ChallengeEnhance ChallengeEnhance a ChallengeEnhance object
function ChallengeEnhance:Initialize()
    self.portals = {}
    self.lastUpdate = 0

    return self
end

-- MARK: GetPortalID

---Get portalID for a specific mapID
---@param mapID integer mapID of the dungeon
---@return integer|nil portalID of the dungeon, return nil if not found
local function GetPortalID(mapID)
    local portalID = addon.data.MAP_ENCOUNTER_EVENTS[mapID] and addon.data.MAP_ENCOUNTER_EVENTS[mapID].portalID or nil
    if type(portalID) == "table" then
        for _, id in ipairs(portalID) do
            if C_SpellBook.IsSpellInSpellBook(id) then
                return id
            end
        end
        return portalID[1]
    end

    return portalID
end

-- MARK:Tooltip

---UpdateTooltip for ChallengeEnhance buttons
---@param parent frame parent frame of the button
---@param mapID integer mapID of the dungeon
local function UpdateTooltip(parent, mapID)
    local onEnterParent = parent:GetScript("OnEnter")
    if onEnterParent then
        onEnterParent(parent)
    end

    if addon.states["inCombat"] then
        GameTooltip:Show()
        return
    end

    local portalID = GetPortalID(mapID)
    local portalName = C_Spell.GetSpellInfo(portalID).name or ""

    if not C_SpellBook.IsSpellInSpellBook(portalID) then
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(portalName .. ":", L["NotLearned"], 1, 1, 1, 1, 0, 0)
    else
        local cooldown = C_Spell.GetSpellCooldownDuration(portalID):GetRemainingDuration()
        if not issecretvalue(cooldown) then
            GameTooltip:AddLine(" ")
            if cooldown <= 0 then
                GameTooltip:AddDoubleLine(portalName .. ":", L["Ready"], 1, 1, 1, 0, 1, 0)
            else
                GameTooltip:AddDoubleLine(portalName .. ":", tostring(SecondsToTime(cooldown)), 1, 1, 1, 1, 0, 0)
            end
        end
    end

    GameTooltip:Show()
end

-- MARK: Refresh Map Info

local function RefreshMapInfo(self, mapID)
    local button = self.buttons[mapID]
    if button then
        local score = select(2, C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapID)) or ""
        if score and addon.db[self.modName]["ScoreEnabled"] then
            button.score:SetText(tostring(score))
            button.score:SetTextColor(button.level:GetTextColor())
        else
            button.score:SetText("")
        end

        local name = addon.data.MAP_ENCOUNTER_EVENTS[mapID] and addon.data.MAP_ENCOUNTER_EVENTS[mapID].short or ""
        if name and addon.db[self.modName]["NameEnabled"] then
            button.mapName:SetText(name)
        else
            button.mapName:SetText("")
        end
    end
end

--MARK: UpdateStyle

---Update style settings and render it in-game for ChallengeEnhance
function ChallengeEnhance:UpdateStyle()
    for mapID, button in pairs(self.buttons) do
        button.level:SetFont(
            addon.LSM:Fetch("font", addon.db[self.modName]["Font"]) or "Fonts\\FRIZQT__.TTF",
            addon.db[self.modName]["LevelFontSize"],
            "OUTLINE"
        )
        button.level:ClearAllPoints()
        button.level:SetPoint("CENTER", button, addon.db[self.modName]["LevelAnchor"], addon.db[self.modName]["LevelX"], addon.db[self.modName]["LevelY"])

        button.score:SetFont(
            addon.LSM:Fetch("font", addon.db[self.modName]["Font"]) or "Fonts\\FRIZQT__.TTF",
            addon.db[self.modName]["ScoreFontSize"],
            "OUTLINE"
        )
        button.score:ClearAllPoints()
        button.score:SetPoint("CENTER", button, addon.db[self.modName]["ScoreAnchor"], addon.db[self.modName]["ScoreX"], addon.db[self.modName]["ScoreY"])

        button.mapName:SetFont(
            addon.LSM:Fetch("font", addon.db[self.modName]["Font"]) or "Fonts\\FRIZQT__.TTF",
            addon.db[self.modName]["NameFontSize"],
            "OUTLINE"
        )
        button.mapName:ClearAllPoints()
        button.mapName:SetPoint("CENTER", button, addon.db[self.modName]["NameAnchor"], addon.db[self.modName]["NameX"], addon.db[self.modName]["NameY"])
    
        RefreshMapInfo(self, mapID)
    end
end

-- MARK: UpdateButtons

---Update buttons for ChallengeEnhance
local function UpdateButtons(self)
    local now = GetTime()
    if self.loaded == false or self.lastUpdate + 0.25 >= now then return end
    self.lastUpdate = now

    for _, icon in pairs(ChallengesFrame.DungeonIcons) do
        local mapID = icon.mapID
        local button = self.buttons[mapID]
        if button then
            button:ClearAllPoints()
            button:SetAllPoints(icon)
            RefreshMapInfo(self, mapID)
        end
    end
end

-- MARK: CreateButtons

---Create buttons and stored them in self.buttons
---@param self ChallengeEnhance self
local function CreateButtons(self)
    for _, icon in pairs(ChallengesFrame.DungeonIcons) do
        local mapID = icon.mapID
        -- level text on the icon, keep a reference in button.level
        local level = icon.HighestLevel

        if mapID then
            local portalID = GetPortalID(mapID)
            local button = CreateFrame("Button", nil, icon, "InsecureActionButtonTemplate")
            button:SetAllPoints()
            button:RegisterForClicks("AnyDown", "AnyUp")
            button:SetAttribute("type", "spell")
            button:SetAttribute("spell", portalID)

            button.selectOverlay = button:CreateTexture(nil, "HIGHLIGHT") 
            button.selectOverlay:SetAllPoints()
            button.selectOverlay:SetBlendMode("ADD")
            button.selectOverlay:SetColorTexture(1, 1, 1, 0.25)
            
            button.score = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            button.mapName = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")

            button.level = level

            button:SetScript("OnEnter", function(self)
                UpdateTooltip(icon, mapID)
            end)
            button:SetScript("OnLeave", function(self)
                if GameTooltip:IsOwned(icon) then
                    GameTooltip:Hide()
                end
            end)

            if portalID then
                self.portals[portalID] = button.mapName
            end

            self.buttons[mapID] = button

            self.buttons[mapID]:Show()
        end
    end

    self.lastUpdate = GetTime()
end

---Create buttons for dungeons in the PVEFrame
---This must be executed after Blizzard_ChallengesUI loaded the PVEFrame and its icons
---@return boolean success if the buttons are created
function ChallengeEnhance:Create()
    if addon.states["inCombat"] or not ChallengesFrame or not ChallengesFrame.DungeonIcons then return false end

    if ChallengesFrame.Update then
        local firstExecute = true
        hooksecurefunc(ChallengesFrame, "Update", function()
            -- only execute once when all dungeon icons are set up by Blizzard_ChallengesUI
            -- and #ChallengesFrame.DungeonIcons >= #ChallengesFrame.maps -> latent callback can wait till the dungeon icons are set, not need to check whether Blizzard_ChallengesUI set all icons up
            if firstExecute  then
                -- use a callback function to execute this later after all dungeon icons are sorted
                C_Timer.After(0.25, function ()
                    CreateButtons(self)
                    self:UpdateStyle()

                    hooksecurefunc(ChallengesFrame, "Update", function()
                        UpdateButtons(self)
                    end)
                end)
                firstExecute = false
            end
        end)
    end

    return true
end

--MARK: Register Event

---Register ChallengeEnhance for "Blizzard_ChallengesUI" loaded
---This only run once after loaded
function ChallengeEnhance:RegisterEvents()
    -- this feature only load on Blizzard_ChallengesUI loaded
    self.eventFrame:RegisterEvent("ADDON_LOADED")
    -- refresh button status when new record or map update
    -- self.eventFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    -- self.eventFrame:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
    -- self.eventFrame:RegisterEvent("CHALLENGE_MODE_LEADERS_UPDATE")
    if addon.db.ChallengeEnhance.PortalPartyMessage then
        addon.core:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self.eventFrame, self.modName, "player")
    end

    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "ADDON_LOADED" then
            local name = ...
            if name == "Blizzard_ChallengesUI" then
                self.loaded = addon.core:GetModule(ChallengeEnhance.modName):Create()
                if self.loaded then
                    self.eventFrame:UnregisterEvent("ADDON_LOADED")
                end
            end
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            local unit, _, spellID = ...
            if unit == "player" and self.portals[spellID] then
                local spellLink = C_Spell.GetSpellLink(spellID)
                if IsInGroup() then
                    C_ChatInfo.SendChatMessage(L["PortalUsed"] .. spellLink, "PARTY")
                end
            end
        else
            UpdateButtons(self)
        end
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(ChallengeEnhance.modName, function() return ChallengeEnhance:Initialize() end)