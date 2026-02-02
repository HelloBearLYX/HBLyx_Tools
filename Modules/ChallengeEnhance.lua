---@class ChallengeEnhance
---@field buttons table ChallengeEnhance buttons
---@field eventFrame frame Handle Blizzard PVEFrame loaded
ChallengeEnhance = {
    buttons = {},
    eventFrame = nil
}

local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

-- MARK: Constants
local MOD_KEY = "ChallengeEnhance"
local MAP_PORTAL = {
    -- current season
    [402] = {id = 393273, name = L["AA"]},    -- Algeth'ar Academy
    [558] = {id = 1254572, name = L["MT"]},   -- Magister's Terrace
    [560] = {id = 1254559, name = L["MC"]},   -- Maisara Caverns
    [559] = {id = 1254563, name = L["NPX"]},   -- Nexus-Point Xenas
    [556] = {id = 1254555, name = L["PS"]},   -- Pit of Saron
    [239] = {id = 1254551, name = L["ST"]},   -- Seat of the Triumvirate
    [161] = {id = 1254557, name = L["Skyreach"]},   -- Skyreach
    [557] = {id = 1254400, name = L["WS"]},   -- Windrunner Spire
    -- 11.2.7 Pre-Patch
    [503] = {id = 445417, name = L["ARAK"]},
    [505] = {id = 445414, name = L["TD"]},
    [542] = {id = 1237215, name = L["ED"]},
    [378] = {id = 354465, name = L["HOA"]},
    [525] = {id = 1216786, name = L["OF"]},
    [499] = {id = 445444, name = L["PSF"]},
    [392] = {id = 367416, name = L["GAMBIT"]},
    [391] = {id = 367416, name = L["STREET"]}             
}

-- MARK: Initialize

---Intialize(Constructor)
---@return ChallengeEnhance ChallengeEnhance a ChallengeEnhance object
function ChallengeEnhance:Initialize()
    if not addon.db[MOD_KEY]["Enabled"] then
        return nil
    end
    
    self.buttons = {}
    self.eventFrame = CreateFrame("Frame")

    return self
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

    if addon.inCombat then
        GameTooltip:Show()
        return
    end

    local portalID = MAP_PORTAL[mapID].id
    local portalInfo = C_Spell.GetSpellInfo(portalID)
    local portalName = portalInfo.name or ""
    

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

---Create buttons and stored them in self.buttons
---@param self ChallengeEnhance self
local function CreateButtons(self)
    for _, icon in pairs(ChallengesFrame.DungeonIcons) do
        local mapID = icon.mapID
        -- level text on the icon, keep a reference in button.level
        local level = icon.HighestLevel

        if mapID then
            local portalID = MAP_PORTAL[mapID].id
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

            self.buttons[mapID] = button

            self.buttons[mapID]:Show()
            self:UpdateStyle()
        end
    end
end

---Create buttons for dungeons in the PVEFrame
---This must be executed after Blizzard_ChallengesUI loaded the PVEFrame and its icons
---@return boolean success if the buttons are created
function ChallengeEnhance:Create()
    if addon.inCombat or not ChallengesFrame or not ChallengesFrame.DungeonIcons then return false end

    if ChallengesFrame.Update then
        local firstExecute = true
        hooksecurefunc(ChallengesFrame, "Update", function()
            -- only execute once when all dungeon icons are set up by Blizzard_ChallengesUI
            -- and #ChallengesFrame.DungeonIcons >= #ChallengesFrame.maps -> latent callback can wait till the dungeon icons are set, not need to check whether Blizzard_ChallengesUI set all icons up
            if firstExecute  then
                -- use a callback function to execute this later after all dungeon icons are sorted
                C_Timer.After(0.25, function () CreateButtons(self) end)
                firstExecute = false
            end
        end)
    end

    return true
end

--MARK: UpdateStyle

---Update style settings and render it in-game for ChallengeEnhance
function ChallengeEnhance:UpdateStyle()
    for mapID, button in pairs(self.buttons) do
        local _, score = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapID)
        local name = MAP_PORTAL[mapID].name

        button.level:SetFont(
            addon.LSM:Fetch("font", addon.db[MOD_KEY]["Font"]) or "Fonts\\FRIZQT__.TTF",
            addon.db[MOD_KEY]["LevelFontSize"],
            "OUTLINE"
        )
        button.level:SetPoint("TOP", button, "TOP", addon.db[MOD_KEY]["LevelX"], addon.db[MOD_KEY]["LevelY"])

        button.score:SetFont(
            addon.LSM:Fetch("font", addon.db[MOD_KEY]["Font"]) or "Fonts\\FRIZQT__.TTF",
            addon.db[MOD_KEY]["ScoreFontSize"],
            "OUTLINE"
        )
        button.score:SetPoint("CENTER", button, "CENTER", addon.db[MOD_KEY]["ScoreX"], addon.db[MOD_KEY]["ScoreY"])

        button.mapName:SetFont(
            addon.LSM:Fetch("font", addon.db[MOD_KEY]["Font"]) or "Fonts\\FRIZQT__.TTF",
            addon.db[MOD_KEY]["NameFontSize"],
            "OUTLINE"
        )
        button.mapName:SetPoint("BOTTOM", button, "BOTTOM", addon.db[MOD_KEY]["NameX"], addon.db[MOD_KEY]["NameY"])
        
        -- update text info and colors
        if not addon.db[MOD_KEY]["LevelEnabled"] then -- blizzard assign it, we only disable it when needed
            button.mapName:SetText("")
        end

        if addon.db[MOD_KEY]["ScoreEnabled"] then
            button.score:SetText(tostring(score or ""))
        else
            button.score:SetText("")
        end
        button.score:SetTextColor(button.level:GetTextColor())
        
        if addon.db[MOD_KEY]["NameEnabled"] then
            button.mapName:SetText(name or "")
        else
            button.mapName:SetText("")
        end
    end
end

--MARK: Register Event

---Register ChallengeEnhance for "Blizzard_ChallengesUI" loaded
---This only run once after loaded
function ChallengeEnhance:RegisterEvents()
    -- this feature only load on Blizzard_ChallengesUI loaded
    self.eventFrame:RegisterEvent("ADDON_LOADED")

    self.eventFrame:SetScript("OnEvent", function(self, event, name)
        if event == "ADDON_LOADED" and name == "Blizzard_ChallengesUI" then
            if addon.challengeEnhance:Create() then
                self:UnregisterEvent("ADDON_LOADED")
            end
        end
    end)
end