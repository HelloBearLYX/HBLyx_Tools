local ADDON_NAME, addon = ...
local GUI = addon.GUI

---@class DeveloperTools
---@field displayFrame frame|nil a frame to display developer tool's outputs
addon.DeveloperTools = {
    displayFrame = nil,
    isOpened = false,
}

-- MARK: Constants
local TABS = {
    {text = "Copy Info", value = "CopyInfo"},
    {text = "Modules Info", value = "ModulesInfo"},
    {text = "States Info", value = "StatesInfo"},
}

local FRAME_WIDTH = 900
local FRAME_HEIGHT = 600
local PADDING = 16
local TITLE_HEIGHT = 26
local TAB_HEIGHT = 22
local TAB_WIDTH = 160

local BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    tile = false, tileSize = 1, edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
}

-- private methods

-- MARK: Render
local function RenderTab(self, tab, info)
    local content = self.content
    content:SetRenderer(function(container)
        if tab == "CopyInfo" then
            local addonInfo = ""
            for _, value in pairs(info) do
                addonInfo = addonInfo .. value .. "\n------\n\n"
            end
            GUI:CreateMultiLineEditBox(container, "Copy the addon info below:", addonInfo)
            GUI:CreateMultiLineEditBox(container, "Copy the data below:", info["Data"] or "")
        elseif tab == "ModulesInfo" then
            GUI:CreateInformationTag(container, info["ModulesInfo"], "LEFT")
        elseif tab == "StatesInfo" then
            GUI:CreateInformationTag(container, info["StatesInfo"], "LEFT")
        end

        container:DoLayout()
    end)
    content:Rerender()
end

local function RenderDisplayFrame(self, info)
    self.isOpened = true

    if self.displayFrame then
        self.displayFrame:Show()
        RenderTab(self, "CopyInfo", info)
        return
    end

    local frame = CreateFrame("Frame", "HBLyxDeveloperTools", UIParent)
    frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("HIGH")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)

    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(frame)
    background:SetColorTexture(0, 0, 0, 0.8)

    local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    border:SetAllPoints(frame)
    border:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    border:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    local title = frame:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 18, "OUTLINE")
    title:SetTextColor(1, 1, 1, 1)
    title:SetText("|cFF8788EEHBLyx Tools|r - Developer Tools |cff8788ee" .. ADDON_NAME .. "|r v" .. addon:GetVersion())
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", PADDING, -PADDING)

    local close = CreateFrame("Button", nil, frame, "BackdropTemplate")
    close:SetBackdrop(BACKDROP)
    close:SetBackdropColor(0, 0, 0, 0.5)
    close:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    close:SetSize(25, 25)
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    close:SetScript("OnClick", function()
        frame:Hide()
        self.isOpened = false
    end)
    addon.UICore:BuildHover(close)

    local closeText = close:CreateFontString(nil, "OVERLAY")
    closeText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    closeText:SetTextColor(1, 1, 1, 1)
    closeText:SetText("X")
    closeText:SetPoint("CENTER", close, "CENTER", 0, 0)

    local content = addon.UICore:Build("ScrollFrame")
    content:SetParent(frame)
    content:SetSize(FRAME_WIDTH - PADDING * 2, FRAME_HEIGHT - PADDING * 3 - TITLE_HEIGHT - TAB_HEIGHT)
    content:SetPoint("TOPLEFT", frame, "TOPLEFT", PADDING, -(PADDING * 2 + TITLE_HEIGHT + TAB_HEIGHT))
    content:Show()

    self.displayFrame = frame
    self.content = content

    local previous
    for _, tabInfo in ipairs(TABS) do
        local tabButton = addon.UICore:Build("TextButton")
        tabButton:SetParent(frame)
        tabButton:SetSize(TAB_WIDTH, TAB_HEIGHT)
        tabButton:SetText(tabInfo.text)
        if previous then
            tabButton:SetPoint("LEFT", previous.frame, "RIGHT", PADDING * 0.5, 0)
        else
            tabButton:SetPoint("TOPLEFT", frame, "TOPLEFT", PADDING, -PADDING - TITLE_HEIGHT)
        end
        tabButton:SetOnClick(function() RenderTab(self, tabInfo.value, info) end)
        tabButton:Show()
        previous = tabButton
    end

    RenderTab(self, "CopyInfo", info)
end

-- MARK: Events Info
local function GetEventsInfo()
    local events = {}
    for event, _ in pairs(addon.core.eventMap) do
        table.insert(events, event)
    end
    table.sort(events, function (a, b)
        if #addon.core.eventMap[a] == #addon.core.eventMap[b] then
            return a < b
        end

        return #addon.core.eventMap[a] > #addon.core.eventMap[b]
    end)

    local output = "|cff8788EEEvents Info|r:\n"
    local total = 0
    
    for _, event in ipairs(events) do
        output = output .. "|cff00ff00" .. event .. "|r|cffC41E3A(" .. tostring(#addon.core.eventMap[event]) .. ")|r: "
        total = total + #addon.core.eventMap[event]
        for _, mod in ipairs(addon.core.eventMap[event]) do
            output = output .. mod .. ", "
        end
        output = output .. "\n"
    end

    output = output .. string.format("*|cff00ff00Total Events: %d|r *|cffC41E3ATotal Registers: %d|r\n", #events, total)

    return output
end

-- MARK: States Info
local function GetStatesInfo()
    local vars = {}
    for var, _ in pairs(addon.states) do
        table.insert(vars, var)
    end
    table.sort(vars)

    local output = "|cff8788EEStates Info|r:\n"

    for _, var in ipairs(vars) do
        if type(addon.states[var]) == "table" then
            for name, value in pairs(addon.states[var]) do
                output = output .. string.format("|cff0070DD%s|r.|cffffff00%s|r|cffC41E3A(%s)|r: %s\n", var, name, type(value), tostring(value))
            end
        else
            output = output .. string.format("|cff0070DD%s|r|cffC41E3A(%s)|r: %s\n", var, type(addon.states[var]), tostring(addon.states[var]))
        end
    end

    local eventKeys = {}
    for event, _ in pairs(addon.core.statesUpdate) do
        table.insert(eventKeys, event)
    end
    table.sort(eventKeys)

    for _, event in ipairs(eventKeys) do
        local states = addon.core.statesUpdate[event]
        output = output .. string.format("|cff00ff00%s|r: ", event)
        for state, _ in pairs(states) do
                output = output .. string.format("|cff0070DD%s|r, ", state)
        end
        output = output .. "\n"
    end

    return output
end

-- MARK: Modules Info
local function GetModulesInfo()
    local output = "|cff8788EEModules Info|r:\n"

    output = output .. string.format("|cffFF7C0ARegistered Modules|r|cffC41E3A(%d)|r: ", addon.core.totalMods)
    for mod, _ in pairs(addon.core.registeredMods) do
        output = output .. mod .. ", "
    end
    output = output .. "\n"

    output = output .. string.format("|cff00ff00Loaded Modules|r|cffC41E3A(%d)|r: ", addon.core.loadedMods)
    for mod, _ in pairs(addon.core.modules) do
        output = output .. mod .. ", "
    end
    output = output .. "\n"

    return output
end

-- MARK: State Monitors Info
local function GetStateMonitorsInfo()
    local output = "|cff8788EEState Monitors Info|r:\n"

    local states = {}
    local statesCount = {}
    for state, monitors in pairs(addon.core.statesMonitor) do
        table.insert(states, state)
        statesCount[state] = 0
        for _, _ in pairs(monitors) do
            statesCount[state] = statesCount[state] + 1
        end
    end

    table.sort(states, function (a, b)
        if statesCount[a] == statesCount[b] then
            return a < b
        end

        return statesCount[a] > statesCount[b]
    end)

    for _, state in ipairs(states) do
        local str = ""
        for monitor, _ in pairs(addon.core.statesMonitor[state]) do
            str = str .. monitor .. ", "
        end
        output = output .. string.format("|cff00ff00%s|r|cffC41E3A(%d)|r: %s\n", state, statesCount[state], str)
    end

    return output
end

function addon.DeveloperTools:DisplayAddonInfo()
    local output = {}
    output["ModulesInfo"] = GetModulesInfo() .. "\n" .. GetEventsInfo()
    output["StatesInfo"] = GetStatesInfo() .. "\n" .. GetStateMonitorsInfo()
    -- Fetch data
    -- local ScanPrivateAuras = function()
    --     local output = "SpellID,Result\n"
    --     local data = {}

    --     for _, spellID in ipairs(data) do
    --         local result = C_UnitAuras.AuraIsPrivate(spellID)
    --         output = output .. string.format("%d,%s\n", spellID, tostring(result))
    --     end

    --     return output
    -- end
    -- output["Data"] = ScanPrivateAuras()
    -- output["Data"] = self:FecthAllEncounterSections(2793, 23) -- get encounter spellIDs

    if self.isOpened and self.displayFrame then
        self.displayFrame:Hide()
        self.isOpened = false
    else
        RenderDisplayFrame(self, output)
    end
end

-- MARK: Fetch Data
function addon.DeveloperTools:FetchEncounterEventInfo(encounterEventID)
    local encounterEventInfo = C_EncounterEvents.GetEventInfo(encounterEventID)
    local data = {
        encounterEventID = encounterEventID,
        severity = nil,
        spellID = nil,
        spellName = nil,
    }

    if encounterEventInfo then
        data.spellID = encounterEventInfo.spellID or nil
        data.severity = encounterEventInfo.severity or nil
        data.spellName = encounterEventInfo.spellID and C_Spell.GetSpellInfo(encounterEventInfo.spellID).name or nil
    else
        data.encounterEventID = nil
    end

    return data
end

function addon.DeveloperTools:AttemptsFetchAllEEInfo()
    local output = "EncounterEventID, Severity, SpellID, SpellName\n"
    for i = 1, 1000 do
        local data = self:FetchEncounterEventInfo(i)
        output = output .. string.format("%d, %s, %s, %s\n",
            data.encounterEventID or -1,
            data.severity or "nil",
            tostring(data.spellID),
            data.spellName or "nil"
        )
    end

    return output
end

local function FetchSection(currentSectionID, output)
    local info = C_EncounterJournal.GetSectionInfo(currentSectionID)
    if not info.filteredByDifficulty then
        local spellID = info.spellID or -1
        if spellID == 0 then spellID = -1 end
        output = output .. string.format("%d,%s\n", spellID, info.title or "nil")
    end

    -- child sections first
    if info.firstChildSectionID then
        output = FetchSection(info.firstChildSectionID, output)
    end

    -- then, same level sections
    if info.siblingSectionID then
        output = FetchSection(info.siblingSectionID, output)
    end

    return output
end

function addon.DeveloperTools:FecthAllEncounterSections(encounterID, difficultyID)
    EJ_SetDifficulty(difficultyID)
    local output = "SpellID,SpellName\n"
    local currentSectionID = select(4, EJ_GetEncounterInfo(encounterID))

    output = FetchSection(currentSectionID, output)
    return output
end