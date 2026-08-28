local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class AuraHelper
local AuraHelper = {
    modName = "AuraHelper",
    db = nil,
    containers = {},
    testOverlay = {},
    soundRegistered = {},
}

-- MARK: container options
--[[
Below is the default options table for the AuraHelper module
The values are arbitrary, only the structure and types are important

container_options = {
    Type = "Helpful", -- "Helpful" or "Harmful", it decides whether the container tracks buffs or debuffs
    IconSize = 35,
    MaxCount = 5,
    IconSpacing = 0,
    GrowDirection = "RIGHT",
    X = 0,
    Y = 0,
    Filters = {"Player", "Raid", "Defensive", "External"},
}]]

-- HBLyx Preset
-- local External_Preset = {
--     IconSize = 35,
--     MaxCount = 5,
--     IconSpacing = 0,
--     GrowDirection = "LEFT",
--     X = 0,
--     Y = 0,
--     Filters = {"Helpful", "External", "PI"}
-- }
-- local Debuff_Preset = {
--     IconSize = 35,
--     MaxCount = 5,
--     IconSpacing = 0,
--     GrowDirection = "LEFT",
--     X = 145,
--     Y = -85,
--     Filters = {"Harmful", "NonPlayer"}
-- }

-- MARK: Constants
local DIRECTION = {
    LEFT = AnchorUtil.FlowDirection.Left,
    RIGHT = AnchorUtil.FlowDirection.Right,
    UP = AnchorUtil.FlowDirection.Up,
    DOWN = AnchorUtil.FlowDirection.Down,
}

-- the type decides whether the container tracks buffs or debuffs, it is required and is not a filter
local TYPES = {
    Helpful = {value = "HELPFUL", category = "Buff", name = L["AuraFilter"]["Helpful"]},
    Harmful = {value = "HARMFUL", category = "Debuff", name = L["AuraFilter"]["Harmful"]},
}

local FILTERS = {
    -- token filters, the values are string
    Player = {value = "PLAYER", category = "Both", name = L["AuraFilter"]["Player"]},
    NonPlayer = {value = "!PLAYER", category = "Both", name = L["AuraFilter"]["NonPlayer"]},
    Raid = {value = "RAID", category = "Both", name = L["AuraFilter"]["Raid"]},
    Defensive = {value = "BIG_DEFENSIVE", category = "Buff", name = L["AuraFilter"]["Defensive"]},
    -- External = {value = "EXTERNAL_DEFENSIVE", category = "Buff", name = L["AuraFilter"]["External"]},
    CrowdControl = {value = "CROWD_CONTROL", category = "Debuff", name = L["AuraFilter"]["CrowdControl"]},
    Dispellable = {value = "DISPELLABLE", category = "Both", name = L["AuraFilter"]["Dispellable"]},
    -- candidate filters, the values are table
    PI = {value = {includeSpellIDs = {
        [10060] = true, -- Power Infusion
        [1044] = true, -- Bless of Freedom
        [116841] = true, -- Tiger's Lust
        -- external defensive
        [33206] = true, -- Pain Suppression
        [47788] = true, -- Guardian Spirit
        [102342] = true, -- Ironbark
        [116849] = true, -- Life Cocoon
        [6940] = true, -- Bless of Sacrifice
        [1022] = true, -- Bless of Protection
        [204018] = true, -- Blessing of Spellwarding
        [357170] = true, -- Time Dilation
        [3411] = true, -- Intervene
        -- team defensive
        [31821] = true, -- Aura Mastery
        [81782] = true, -- Power Word: Barrier
        [325174] = true, -- Spirit Link Totem
        [97463] = true, -- Rallying Cry
        [145629] = true, -- Anti-Magic Zone
        [209426] = true, -- Darkness
    }}, category = "Buff", name = L["AuraFilter"]["Power_Infusion"]},
    Role = {value = {isRoleAura = true}, category = "Both", name = L["AuraFilter"]["Role"]},
    Priority = {value = {isPriorityAura = true}, category = "Both", name = L["AuraFilter"]["Priority"]},
    Stealable = {value = {isStealableAura = true}, category = "Both", name = L["AuraFilter"]["Stealable"]},
    Boss = {value = {isBossAura = true}, category = "Both", name = L["AuraFilter"]["Boss"]},
}

---Get the container type list for the config panel
---@return table list map of type name to its localized name
---@return table order the type names sorted alphabetically
function AuraHelper:GetTypeList()
    local list, order = {}, {}
    for name, info in pairs(TYPES) do
        list[name] = info.name
        table.insert(order, name)
    end
    table.sort(order)

    return list, order
end

---Get the filter list for the config panel
---@param auraType string? the container type, only the filters of this type are returned
---@return table list map of filter name to its localized name
---@return table order the filter names sorted alphabetically
function AuraHelper:GetFilterList(auraType)
    local category = TYPES[auraType or ""] and TYPES[auraType].category
    local list, order = {}, {}
    for name, info in pairs(FILTERS) do
        if not category or info.category == "Both" or info.category == category then
            list[name] = info.name
            table.insert(order, name)
        end
    end
    table.sort(order)

    return list, order
end

-- MARK: Create Container
local function InitializeAuraButton(frame, options)
    frame:SetSize(options.IconSize, options.IconSize)

    local icon = frame:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints()
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    frame:SetIcon(icon)

    local cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    cooldown:SetAllPoints()
    cooldown:SetDrawEdge(false)
    cooldown:SetReverse(true)
    cooldown:SetScale(0.75)
    frame:SetDurationCooldown(cooldown)

    local stack = frame:CreateFontString(nil, "OVERLAY")
    stack:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    stack:SetFont("Fonts\\FRIZQT__.TTF", options.StackTextSize or 12, "OUTLINE")
    stack:SetTextColor(1, 1, 1, 1)
    frame:SetApplicationCount(stack)

    -- border
    local border = frame:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\iconBorder.png")
    border:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
    frame:SetAuraBorder(border, {
        showIcon = true,
        showWhenHarmful = true,
        showWhenHelpful = true,
        showWithoutDispelType = true,
        style = 3,
        customDispelColorMap = {
            None = CreateColor(0, 0, 0, 1),
            Magic = CreateColor(0.349, 0.475, 1.0),
            Curse = CreateColor(0.635, 0.0, 0.639),
            Disease = CreateColor(0.671, 0.384, 0.098),
            Poison = CreateColor(0.0, 0.706, 0.286),
            Bleed = CreateColor(0.749, 0.149, 0.149),
        },
    })
end

-- MARK: Filter handlers

local function GenerateFiltersFromOptions(options)
    local tokenFilters = {}
    local candidateFilters = {}

    local auraType = TYPES[options.Type or ""] or TYPES.Helpful -- the type token always comes first
    table.insert(tokenFilters, auraType.value)

    for _, name in pairs(options.Filters or {}) do
        if FILTERS[name] then -- if the filter is valid
            local filterContent = FILTERS[name].value
            if type(filterContent) == "string" then
                table.insert(tokenFilters, filterContent)
            else -- candidate filters is a concatenated table
                for key, value in pairs(filterContent) do
                    candidateFilters[key] = value
                end
            end
        end
    end

    -- make tokenFilters
    local tokenFiltersString = table.concat(tokenFilters, "|")

    return tokenFiltersString, candidateFilters
end

local function CreateAuraContainer(name, options)
    local width = options.IconSize * options.MaxCount
    local height = options.IconSize

    local container = CreateFrame("AuraContainer", ADDON_NAME .. "_" .. name, UIParent, "CustomAuraContainerTemplate")
    container:SetFlowLayoutGrowthDirection(DIRECTION[options.GrowDirection or "RIGHT"], DIRECTION.UP)
    local anchorFrom = options.GrowDirection == "RIGHT" and "LEFT" or "RIGHT"
    container:SetPoint(anchorFrom, UIParent, "CENTER", options.X or 0, options.Y or 0)
    container:SetSize(width, height)
    container:SetUnit("player") -- the unit is always player, the auras are filtered by the filters

    local filterString, candidateFilters = GenerateFiltersFromOptions(options)
    container:AddAuraGroup(name, filterString, {
        maxFrameCount = options.MaxCount,
        initializeFrame = function(frame)
            InitializeAuraButton(frame, options)
        end,
        layout = {
            elementSpacing = options.IconSpacing or 0,
            lineSpacing = 0,
            groupSpacing = 0,
            groupLineSpacing = 0,
            forceNewLine = false,
            elementWidth = options.IconSize,
            elementHeight = options.IconSize,
        },
        candidateFilters = candidateFilters,
    })

    container:Show()
    return container
end

-- MARK: Aura Sound Handlers

local function RegisterAuraSound(self, spellId, trigger, soundFileLSM)
    if not spellId or not trigger or not soundFileLSM then
        return
    end

    trigger = tonumber(trigger)
    local sound = addon.LSM:Fetch("sound", soundFileLSM)
    if sound then
        local soundInfo = {
            spellID = tonumber(spellId),
            unitToken = "player",
            soundFileName = sound,
            outputChannel = "Master",
        }
        local auraSoundID = C_UnitAuras.AddAuraSound(trigger, soundInfo)

        if not self.soundRegistered[spellId] then
            self.soundRegistered[spellId] = {}
        end

        self.soundRegistered[spellId][trigger] = auraSoundID
    end
end

local function UnregisterAuraSound(self, spellId, trigger)
    trigger = tonumber(trigger)
    if self.soundRegistered[spellId] and self.soundRegistered[spellId][trigger] then
        local auraSoundID = self.soundRegistered[spellId][trigger]
        C_UnitAuras.RemoveAuraSound(auraSoundID)
        self.soundRegistered[spellId][trigger] = nil

        -- check whether the spellId has any other triggers registered, if not, remove the spellId entry
        if not next(self.soundRegistered[spellId]) then
            self.soundRegistered[spellId] = nil
        end
    end
end

-- MARK: Test Mode Handler

--- Build a test overlay for the given container
---@param self AuraHelper
---@param key string the key of the container in the db
---@return Frame|nil the test overlay frame, or nil if the container does not exist
local function BuildTestOverlay(self, key)
    -- instead of create the test overlay according to the container
    -- just use the DB data to create the test overlay
    -- so that the test overlay can be shown even if the container is not created yet
    local options = self.db.data[key]

    if options then
        local overlay = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
        local width = options.IconSize * options.MaxCount
        local height = options.IconSize
        overlay:SetSize(width, height)

        local anchorFrom = options.GrowDirection == "RIGHT" and "LEFT" or "RIGHT"
        overlay:SetPoint(anchorFrom, UIParent, "CENTER", options.X or 0, options.Y or 0)
        overlay:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
        })
        overlay:SetBackdropColor(0, 0, 1, 0.5)

        local text = overlay:CreateFontString(nil, "OVERLAY")
        text:SetPoint("CENTER", overlay, "CENTER", 0, 0)
        text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        text:SetText(L["AuraHelperSettings"] .. "-" .. key)
        overlay.text = text

        -- make the test overlay draggable and interact with db's position
        local function updatePosition(testOverlay)
            local x, y = GetCursorPosition()
            x, y = addon.Utilities:ScreenPositionToUIPosition(x, y)
            x, y = math.floor(x + 0.5), math.floor(y + 0.5) -- round the position to integers

            testOverlay:ClearAllPoints()
            testOverlay:SetPoint(anchorFrom, UIParent, "CENTER", x, y)

            return x, y
        end

        local module = self

        ---Keep the container on the overlay, the container does not follow it on its own
        local function saveAndApplyPosition(overlayFrame)
            local x, y = updatePosition(overlayFrame)
            module.db.data[key].X = x
            module.db.data[key].Y = y
            module:UpdatePosition(key)
        end

        overlay:SetScript("OnMouseDown", function(overlayFrame, button)
            if button == "LeftButton" then
                overlayFrame.isDragging = true
                saveAndApplyPosition(overlayFrame)
            end
        end)

        overlay:SetScript("OnMouseUp", function(overlayFrame, button)
            if button == "LeftButton" and overlayFrame.isDragging then
                overlayFrame.isDragging = nil
                saveAndApplyPosition(overlayFrame)
            end
        end)

        overlay:SetScript("OnUpdate", function(overlayFrame)
            if overlayFrame.isDragging then
                saveAndApplyPosition(overlayFrame)
            end
        end)

        overlay:Hide()
        return overlay
    end

    return nil
end

local function ToggleTestRegion(self, on)
    for key, options in pairs(self.db.data) do
        if not self.testOverlay[key] then
            self.testOverlay[key] = BuildTestOverlay(self, key)
        end

        if on then
            if self.testOverlay[key] then
                self.testOverlay[key]:Show()
            end
        else
            if self.testOverlay[key] then
                self.testOverlay[key]:Hide()
            end
        end
    end
end

-- MARK: Load DB
local function LoadDBAura(self)
    for key, options in pairs(self.db.data) do
        if not self.containers[key] then
            self.containers[key] = CreateAuraContainer(key, options)
        end
    end
end

local function LoadDBSound(self)
    for spellId, soundOptions in pairs(self.db.dataSound) do
        if type(soundOptions) == "table" then
            for trigger, soundFileLSM in pairs(soundOptions) do
                RegisterAuraSound(self, spellId, trigger, soundFileLSM)
            end
        end
    end
end

-- MARK: Initialize

---Initialize (Constructor)
---@return AuraHelper TemplateModule a TemplateModule object
function AuraHelper:Initialize()
    self.db = addon.db[self.modName]
    -- create containers for each key in the db
    self.containers = {}
    LoadDBAura(self)
    self.testOverlay = {}

    self.soundRegistered = {}
    -- LoadDBSound(self)

    return self
end

-- MARK: Update Style
function AuraHelper:UpdateStyle()
    -- UpdateStyle runs when player enter the world
    -- since LSM is not fully loaded by other addons
    -- we need to register sound after the player enter the world
    LoadDBSound(self)
end

-- MARK: Add/Remove Aura Container

---Create the container of a newly added key
---@param key string the key of the container in the db
function AuraHelper:AddContainer(key)
    local options = self.db.data[key]
    if not options or self.containers[key] then
        return
    end

    self.containers[key] = CreateAuraContainer(key, options)
end

---Hide and drop the container of a removed key
---@param key string the key of the container in the db
function AuraHelper:RemoveContainer(key)
    if self.containers[key] then
        self.containers[key]:Hide()
        self.containers[key] = nil
    end

    if self.testOverlay[key] then
        self.testOverlay[key]:Hide()
        self.testOverlay[key] = nil
    end
end

-- MARK: Update Conatiner

function AuraHelper:UpdateFilter(key)
    local options = self.db.data[key]
    local filterString, candidateFilters = GenerateFiltersFromOptions(options)
    local container = self.containers[key]
    if container then
        container:SetAuraGroupFilterString(key, filterString)
        container:SetAuraGroupCandidateFilters(key, candidateFilters)
    end
end

function AuraHelper:UpdateGrowDirection(key)
    local options = self.db.data[key]
    local container = self.containers[key]
    if container then
        local anchorFrom = options.GrowDirection == "RIGHT" and "LEFT" or "RIGHT"
        container:SetFlowLayoutGrowthDirection(DIRECTION[options.GrowDirection or "RIGHT"], DIRECTION.UP)
        container:ClearAllPoints()
        container:SetPoint(anchorFrom, UIParent, "CENTER", options.X or 0, options.Y or 0)
    end

    -- also change the grow direction/position of the test overlay if it exists
    if self.testOverlay[key] then
        local overlay = self.testOverlay[key]
        local anchorFrom = options.GrowDirection == "RIGHT" and "LEFT" or "RIGHT"
        overlay:ClearAllPoints()
        overlay:SetPoint(anchorFrom, UIParent, "CENTER", options.X or 0, options.Y or 0)
    end
end

function AuraHelper:UpdateMaxCount(key)
    local options = self.db.data[key]
    local container = self.containers[key]
    if container then
        container:SetAuraGroupMaxFrameCount(key, options.MaxCount)
        container:SetSize(options.IconSize * options.MaxCount, options.IconSize)
    end
    -- also change the grow direction/position of the test overlay if it exists
    if self.testOverlay[key] then
        local overlay = self.testOverlay[key]
        local width = options.IconSize * options.MaxCount
        local height = options.IconSize
        overlay:SetSize(width, height)

        local anchorFrom = options.GrowDirection == "RIGHT" and "LEFT" or "RIGHT"
        overlay:ClearAllPoints()
        overlay:SetPoint(anchorFrom, UIParent, "CENTER", options.X or 0, options.Y or 0)
    end
end

function AuraHelper:UpdatePosition(key)
    local options = self.db.data[key]
    local container = self.containers[key]
    if container then
        local anchorFrom = options.GrowDirection == "RIGHT" and "LEFT" or "RIGHT"
        container:ClearAllPoints()
        container:SetPoint(anchorFrom, UIParent, "CENTER", options.X or 0, options.Y or 0)
    end
    -- also change the position of the test overlay if it exists
    if self.testOverlay[key] then
        local overlay = self.testOverlay[key]
        local anchorFrom = options.GrowDirection == "RIGHT" and "LEFT" or "RIGHT"
        overlay:ClearAllPoints()
        overlay:SetPoint(anchorFrom, UIParent, "CENTER", options.X or 0, options.Y or 0)
    end
end

function AuraHelper:UpdateLayout(key)
    local options = self.db.data[key]
    local container = self.containers[key]
    if container then
        container:SetAuraGroupLayout(key, {
            elementSpacing = options.IconSpacing or 0,
            lineSpacing = 0,
            groupSpacing = 0,
            groupLineSpacing = 0,
            forceNewLine = false,
            elementWidth = options.IconSize,
            elementHeight = options.IconSize,
        })
        container:SetSize(options.IconSize * options.MaxCount, options.IconSize)
    end
    -- also change the size of the test overlay if it exists
    if self.testOverlay[key] then
        local overlay = self.testOverlay[key]
        local width = options.IconSize * options.MaxCount
        local height = options.IconSize
        overlay:SetSize(width, height)
    end
end

-- MARK: Update Sound
function AuraHelper:AddSound(spellID, trigger, soundFileLSM)
    if not self.db or not self.db.dataSound then
        return
    end

    local spellNum = tonumber(spellID)
    local spellStr = tostring(spellID)
    local spellKey = spellID
    if spellNum and self.db.dataSound[spellNum] ~= nil then
        spellKey = spellNum
    elseif self.db.dataSound[spellStr] ~= nil then
        spellKey = spellStr
    elseif spellNum then
        spellKey = spellNum
    else
        spellKey = spellStr
    end

    if not self.db.dataSound[spellKey] then
        self.db.dataSound[spellKey] = {}
    end

    self.db.dataSound[spellKey][trigger] = soundFileLSM
    RegisterAuraSound(self, spellKey, trigger, soundFileLSM)
end

function AuraHelper:RemoveSound(spellId, trigger)
    if not self.db or not self.db.dataSound then
        return
    end

    local spellNum = tonumber(spellId)
    local spellStr = tostring(spellId)
    local dbKey
    if spellNum and self.db.dataSound[spellNum] ~= nil then
        dbKey = spellNum
    elseif self.db.dataSound[spellStr] ~= nil then
        dbKey = spellStr
    else
        dbKey = spellNum or spellStr
    end

    local regKey
    if spellNum and self.soundRegistered[spellNum] ~= nil then
        regKey = spellNum
    elseif self.soundRegistered[spellStr] ~= nil then
        regKey = spellStr
    else
        regKey = dbKey
    end

    if trigger then
        trigger = tonumber(trigger)
        if self.db.dataSound[dbKey] then
            self.db.dataSound[dbKey][trigger] = nil
            if not next(self.db.dataSound[dbKey]) then
                self.db.dataSound[dbKey] = nil
            end
        end

        UnregisterAuraSound(self, regKey, trigger)
        return
    end

    if self.db.dataSound[dbKey] then
        for registeredTrigger in pairs(self.db.dataSound[dbKey]) do
            UnregisterAuraSound(self, regKey, registeredTrigger)
        end
        self.db.dataSound[dbKey] = nil
    end
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function AuraHelper:Test(on)
    if not addon.db[self.modName]["Enabled"] then -- if the module is not enabled, do not allow test mode
        return
    end

    if on then
        ToggleTestRegion(self, true)
    else
        ToggleTestRegion(self, false)
    end
end

-- MARK: Register Module
addon.core:RegisterModule(AuraHelper.modName, function() return AuraHelper:Initialize() end)
