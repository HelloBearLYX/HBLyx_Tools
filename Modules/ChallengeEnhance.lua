local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local LibKS = LibStub("LibKeystone")

---@class ChallengeEnhance
---@field buttons table ChallengeEnhance buttons
---@field eventFrame frame Handle Blizzard PVEFrame loaded
---@field modName string module name for registering in core
---@field keystoneFrame frame frame showing teammates' keystone info
---@field keystoneHeader frame header row showing the column titles
---@field keystoneBody frame container frame holding the keystone columns
---@field keystoneColumns table playerName/keyLevel/dungeonName fontstrings, one line per teammate
---@field keystoneData table party member name -> {keyLevel, keyChallengeMapID} cache
local ChallengeEnhance = {
    modName = "ChallengeEnhance",
    buttons = {},
    loaded = false,
    updateHooked = false,
    keystoneShowHooked = false,
    keystoneFrame = nil,
    keystoneHeader = nil,
    keystoneBody = nil,
    keystoneColumns = nil,
    keystoneData = {},
    eventFrame = CreateFrame("Frame", ADDON_NAME .. "_ChallengeEnhanceEvent"),
}

local HOOK_UPDATE_DELAY = 0.5
local EVENT_UPDATE_DELAY = 1

local KEYSTONE_COL_PLAYER_W = 100
local KEYSTONE_COL_LEVEL_W = 50
local KEYSTONE_COL_DUNGEON_W = 100
local KEYSTONE_ROW_HEIGHT = 20
local KEYSTONE_FONT_SIZE = 16
 
local NAME_TO_INFO = {}
for mapID, mapInfo in pairs(addon.data.SEASON_MAP) do
    if mapInfo.short then
        NAME_TO_INFO[mapInfo.name] = mapID
    end
end

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
    local portalID = addon.data.SEASON_MAP[mapID] and addon.data.SEASON_MAP[mapID].portalID or nil
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
        local mapBestInfo = C_MythicPlus.GetSeasonBestForMap(mapID)
        local level = mapBestInfo and mapBestInfo.level or 0
        if level and addon.db[self.modName]["LevelEnabled"] and level > 0 then
            button.level:SetText(tostring(level))
        else
            button.level:SetText("")
        end

        local score = select(2, C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapID)) or 0
        if score and addon.db[self.modName]["ScoreEnabled"] and score > 0 then
            button.score:SetText(tostring(score))
            button.score:SetTextColor(button.level:GetTextColor())
        else
            button.score:SetText("")
        end

        local name = addon.data.SEASON_MAP[mapID] and addon.data.SEASON_MAP[mapID].short or ""
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
            addon.LSM:Fetch("font", addon.db[self.modName]["Font"]) or addon.DEFAULTS.font,
            addon.db[self.modName]["LevelFontSize"],
            "OUTLINE"
        )
        button.level:ClearAllPoints()
        button.level:SetPoint("CENTER", button, addon.db[self.modName]["LevelAnchor"], addon.db[self.modName]["LevelX"], addon.db[self.modName]["LevelY"])

        button.score:SetFont(
            addon.LSM:Fetch("font", addon.db[self.modName]["Font"]) or addon.DEFAULTS.font,
            addon.db[self.modName]["ScoreFontSize"],
            "OUTLINE"
        )
        button.score:ClearAllPoints()
        button.score:SetPoint("CENTER", button, addon.db[self.modName]["ScoreAnchor"], addon.db[self.modName]["ScoreX"], addon.db[self.modName]["ScoreY"])

        button.mapName:SetFont(
            addon.LSM:Fetch("font", addon.db[self.modName]["Font"]) or addon.DEFAULTS.font,
            addon.db[self.modName]["NameFontSize"],
            "OUTLINE"
        )
        button.mapName:ClearAllPoints()
        button.mapName:SetPoint("CENTER", button, addon.db[self.modName]["NameAnchor"], addon.db[self.modName]["NameX"], addon.db[self.modName]["NameY"])
    
        RefreshMapInfo(self, mapID)
    end
end

-- MARK: UpdateButtons

local function UpdateButtonHelper(self)
    for _, icon in pairs(ChallengesFrame.DungeonIcons) do
        local mapID = icon.mapID
        local button = self.buttons[mapID]
        if button then
            if button:GetParent() ~= icon then
                button:ClearAllPoints()
                button:SetParent(icon)
                button:SetAllPoints()
            end
            RefreshMapInfo(self, mapID)
            -- Only refresh tooltip content while the icon tooltip is currently shown.
            if GameTooltip:IsOwned(icon) then
                UpdateTooltip(icon, mapID)
            end
        end
    end
end

---Update buttons for ChallengeEnhance
---@param self ChallengeEnhance self
---@param delay number delay time for updating buttons, default is 0.25s
local function UpdateButtons(self, delay)
    -- modify the delay to only update the last trigger
    -- make a timer to update buttons after the specified delay
    -- if there is a recent update within the delay, schedule an update instead of updating immediately
    if not delay then delay = 0.5 end
    if not ChallengesFrame or not ChallengesFrame.DungeonIcons then return end
    local now = GetTime()
    if self.loaded == false or self.lastUpdate + delay >= now then
        -- cancel the previous timer if it exists
        if self.timer then
            self.timer:Cancel()
            self.timer = nil
        end
        self.timer = C_Timer.NewTimer(delay, function() UpdateButtonHelper(self) end)
        self.lastUpdate = now
        return
    end

    self.lastUpdate = now
    UpdateButtonHelper(self)
end

-- MARK: CreateButtons

---Create buttons and stored them in self.buttons
---@param self ChallengeEnhance self
local function CreateButtons(self)
    for _, icon in pairs(ChallengesFrame.DungeonIcons) do
        local mapID = icon.mapID
        -- level text on the icon, keep a reference in button.level
        local level = icon.HighestLevel

        if mapID and not self.buttons[mapID] then
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
                self.portals[portalID] = addon.data.SEASON_MAP[mapID].name or ""
            end

            self.buttons[mapID] = button

            self.buttons[mapID]:Show()
        end
    end

    self.lastUpdate = GetTime()
end

-- MARK: Keystone Frame

---Strip the realm suffix off a full player name
---@param fullName string full player name, possibly with "-Realm" suffix
---@return string name name without the realm suffix
local function StripRealm(fullName)
    if not fullName then return "?" end
    return Ambiguate(fullName, "short") or fullName:match("^([^%-]+)") or fullName
end

---Build a short name -> classFile lookup for everyone currently in the group
---@return table classMap short name -> classFile
local function BuildClassColorMap()
    local map = {}
    if IsInGroup() then
        local prefix = IsInRaid() and "raid" or "party"
        local count = GetNumGroupMembers()
        for i = 1, (IsInRaid() and count or count - 1) do
            local unit = prefix .. i
            local name = UnitName(unit)
            local _, classFile = UnitClass(unit)
            if name and classFile then
                map[name] = classFile
            end
        end
    end

    local myName = UnitName("player")
    local _, myClassFile = UnitClass("player")
    if myName and myClassFile then
        map[myName] = myClassFile
    end

    return map
end

---Get the display color for a keystone level, higher levels are colored more distinctly
---@param keyLevel integer keystone level
---@return ColorMixin color color for the level
local function GetKeyLevelColor(keyLevel)
    if keyLevel >= 12 then return CreateColor(1, 0.5, 0, 1)
    elseif keyLevel >= 10 then return CreateColor(0.63, 0.2, 0.93, 1)
    elseif keyLevel >= 7 then return CreateColor(0, 0.44, 0.87, 1)
    elseif keyLevel >= 4 then return CreateColor(0.12, 1, 0, 1)
    else return CreateColor(1, 1, 1, 1) end
end

---Wrap text in a color escape sequence using only a color's r/g/b fields
---(avoids relying on ColorMixin methods, which some color tables like RAID_CLASS_COLORS may lack)
---@param text string text to color
---@param color table|nil table with r,g,b fields, or nil to leave text uncolored
---@return string text color-wrapped text
local function WrapTextColor(text, color)
    if not color then return text end
    return string.format("|cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, text)
end

---Rebuild the keystoneFrame columns from the cached self.keystoneData
---@param self ChallengeEnhance self
local function UpdateKeystoneText(self)
    local classMap = BuildClassColorMap()
    local names = {}
    for name in pairs(self.keystoneData) do
        table.insert(names, name)
    end
    table.sort(names)

    local playerLines, levelLines, dungeonLines = {}, {}, {}
    for _, name in ipairs(names) do
        local info = self.keystoneData[name]

        local nameColor = RAID_CLASS_COLORS[classMap[StripRealm(name)]]
        table.insert(playerLines, WrapTextColor(StripRealm(name), nameColor))

        if info.keyLevel <= 0 then
            table.insert(levelLines, "")
            table.insert(dungeonLines, L["NotAcquired"])
        else
            table.insert(levelLines, WrapTextColor(tostring(info.keyLevel), GetKeyLevelColor(info.keyLevel)))

            local mapName = C_ChallengeMode.GetMapUIInfo(info.keyChallengeMapID)
            local mapID = mapName and NAME_TO_INFO[mapName]
            local seasonInfo = mapID and addon.data.SEASON_MAP[mapID]
            if seasonInfo then
                local portalID = GetPortalID(mapID)
                local icon = portalID and C_Spell.GetSpellTexture(portalID)
                local iconText = icon and ("|T" .. icon .. ":0|t") or ""
                table.insert(dungeonLines, iconText .. seasonInfo.short)
            else
                table.insert(dungeonLines, mapName or "")
            end
        end
    end

    self.keystoneColumns.playerName:SetText(table.concat(playerLines, "\n"))
    self.keystoneColumns.keyLevel:SetText(table.concat(levelLines, "\n"))
    self.keystoneColumns.dungeonName:SetText(table.concat(dungeonLines, "\n"))
end

---Create the keystoneFrame anchored to the right of ChallengesFrame
---@param self ChallengeEnhance self
local function CreateKeystoneFrame(self)
    local frame = CreateFrame("Frame", ADDON_NAME .. "_ChallengeEnhanceKeystoneFrame", ChallengesFrame, "BackdropTemplate")
    -- local totalHeight = math.floor(ChallengesFrame:GetHeight() / 2)
    local totalHeight = 6 * KEYSTONE_ROW_HEIGHT + 5
    frame:SetSize(KEYSTONE_COL_PLAYER_W + KEYSTONE_COL_LEVEL_W + KEYSTONE_COL_DUNGEON_W + 10, totalHeight)
    frame:SetPoint("BOTTOMLEFT", ChallengesFrame, "BOTTOMRIGHT", 5, 0)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.5)
    frame:SetBackdropBorderColor(0, 0, 0, 1)

    local playerHeader = frame:CreateFontString(nil, "OVERLAY")
    playerHeader:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    playerHeader:SetSize(KEYSTONE_COL_PLAYER_W, KEYSTONE_ROW_HEIGHT)
    playerHeader:SetJustifyH("LEFT")
    playerHeader:SetFont(addon.DEFAULTS.font, KEYSTONE_FONT_SIZE, "OUTLINE")
    playerHeader:SetText(L["KeystonePlayerName"])

    local levelHeader = frame:CreateFontString(nil, "OVERLAY")
    levelHeader:SetPoint("TOPLEFT", playerHeader, "TOPRIGHT", 0, 0)
    levelHeader:SetSize(KEYSTONE_COL_LEVEL_W, KEYSTONE_ROW_HEIGHT)
    levelHeader:SetJustifyH("LEFT")
    levelHeader:SetFont(addon.DEFAULTS.font, KEYSTONE_FONT_SIZE, "OUTLINE")
    levelHeader:SetText(L["KeystoneKeyLevel"])

    local dungeonHeader = frame:CreateFontString(nil, "OVERLAY")
    dungeonHeader:SetPoint("TOPLEFT", levelHeader, "TOPRIGHT", 0, 0)
    dungeonHeader:SetSize(KEYSTONE_COL_DUNGEON_W, KEYSTONE_ROW_HEIGHT)
    dungeonHeader:SetJustifyH("LEFT")
    dungeonHeader:SetFont(addon.DEFAULTS.font, KEYSTONE_FONT_SIZE, "OUTLINE")
    dungeonHeader:SetText(L["KeystoneDungeonName"])

    local playerColumn = frame:CreateFontString(nil, "OVERLAY")
    playerColumn:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, - KEYSTONE_ROW_HEIGHT)
    playerColumn:SetSize(KEYSTONE_COL_PLAYER_W, totalHeight - KEYSTONE_ROW_HEIGHT)
    playerColumn:SetJustifyH("LEFT")
    playerColumn:SetJustifyV("TOP")
    playerColumn:SetFont(addon.DEFAULTS.font, KEYSTONE_FONT_SIZE, "OUTLINE")

    local levelColumn = frame:CreateFontString(nil, "OVERLAY")
    levelColumn:SetPoint("TOPLEFT", frame, "TOPLEFT", KEYSTONE_COL_PLAYER_W, - KEYSTONE_ROW_HEIGHT)
    levelColumn:SetSize(KEYSTONE_COL_LEVEL_W, totalHeight - KEYSTONE_ROW_HEIGHT)
    levelColumn:SetJustifyH("LEFT")
    levelColumn:SetJustifyV("TOP")
    levelColumn:SetFont(addon.DEFAULTS.font, KEYSTONE_FONT_SIZE, "OUTLINE")

    local dungeonColumn = frame:CreateFontString(nil, "OVERLAY")
    dungeonColumn:SetPoint("TOPLEFT", frame, "TOPLEFT", KEYSTONE_COL_PLAYER_W + KEYSTONE_COL_LEVEL_W, - KEYSTONE_ROW_HEIGHT)
    dungeonColumn:SetSize(KEYSTONE_COL_DUNGEON_W, totalHeight - KEYSTONE_ROW_HEIGHT)
    dungeonColumn:SetJustifyH("LEFT")
    dungeonColumn:SetJustifyV("TOP")
    dungeonColumn:SetFont(addon.DEFAULTS.font, KEYSTONE_FONT_SIZE, "OUTLINE")

    self.keystoneFrame = frame
    self.keystoneColumns = { playerName = playerColumn, keyLevel = levelColumn, dungeonName = dungeonColumn }
end

---Read the player's own keystone directly and cache it into self.keystoneData
---@param self ChallengeEnhance self
local function RecordOwnKeystone(self)
    local myName = UnitName("player")
    if not myName then return end

    self.keystoneData[myName] = {
        keyLevel = C_MythicPlus.GetOwnedKeystoneLevel() or 0,
        keyChallengeMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID() or 0,
    }
end

---Clear cached teammates' keystones and request fresh ones from the party
---@param self ChallengeEnhance self
local function RefreshKeystoneFrame(self)
    if not self.keystoneFrame then return end

    wipe(self.keystoneData)
    RecordOwnKeystone(self)
    -- surface any error instead of letting it silently abort the rebuild
    local ok, err = pcall(UpdateKeystoneText, self)
    if not ok then geterrorhandler()(err) end
    LibKS.Request("PARTY")
end

---Create buttons for dungeons in the PVEFrame
---This must be executed after Blizzard_ChallengesUI loaded the PVEFrame and its icons
---@return boolean success if the buttons are created
function ChallengeEnhance:Create()
    if addon.states["inCombat"] or not ChallengesFrame or not ChallengesFrame.DungeonIcons then return false end

    if ChallengesFrame.Update and not self.updateHooked then
        local firstExecute = true
        hooksecurefunc(ChallengesFrame, "Update", function()
            -- only execute once when all dungeon icons are set up by Blizzard_ChallengesUI
            -- and #ChallengesFrame.DungeonIcons >= #ChallengesFrame.maps -> latent callback can wait till the dungeon icons are set, not need to check whether Blizzard_ChallengesUI set all icons up
            if firstExecute  then
                -- use a callback function to execute this later after all dungeon icons are sorted
                C_Timer.After(0.25, function ()
                    if addon.states["inCombat"] or not ChallengesFrame or not ChallengesFrame.DungeonIcons then return end
                    CreateButtons(self)
                    self:UpdateStyle()
                    UpdateButtons(self, 0)

                    if addon.db[self.modName]["TeamKeystone"] and not self.keystoneFrame then
                        CreateKeystoneFrame(self)
                        LibKS.Register(self, function(keyLevel, keyChallengeMapID, playerRating, name, channel)
                            if channel ~= "PARTY" then return end
                            self.keystoneData[name] = { keyLevel = keyLevel, keyChallengeMapID = keyChallengeMapID }
                            -- LibKeystone invokes this via securecallfunction, which silently swallows errors, so surface them ourselves
                            local ok, err = pcall(UpdateKeystoneText, self)
                            if not ok then geterrorhandler()(err) end
                        end)
                        RefreshKeystoneFrame(self)
                    end
                end)
                firstExecute = false
            else
                UpdateButtons(self, HOOK_UPDATE_DELAY)
            end
        end)
        self.updateHooked = true
    end

    if addon.db[self.modName]["TeamKeystone"] and not self.keystoneShowHooked then
        hooksecurefunc(ChallengesFrame, "Show", function()
            RefreshKeystoneFrame(self)
        end)
        self.keystoneShowHooked = true
    end

    return true
end

--MARK: Register Event

---Register ChallengeEnhance for "Blizzard_ChallengesUI" loaded
---This only run once after loaded
function ChallengeEnhance:RegisterEvents()
    -- this feature only load on Blizzard_ChallengesUI loaded
    self.eventFrame:RegisterEvent("ADDON_LOADED")
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
            if unit ~= "player" then return end
            if self.portals[spellID] then
                local msg = L["PortalUsed"]:format(self.portals[spellID])
                if IsInGroup() then
                    C_ChatInfo.SendChatMessage(msg, "PARTY")
                end
            end
        else
            UpdateButtons(self, EVENT_UPDATE_DELAY)
        end
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(ChallengeEnhance.modName, L["ChallengeEnhanceSettings"], function() return ChallengeEnhance:Initialize() end)