local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class AutoMacroHelper
---@field modName string
---@field target string
---@field targetRole string
---@field spellID integer
---@field spellName string
---@field eventFrame Frame
---@field db table
local AutoMacroHelper = {
    modName = "AutoMacroHelper",
    target = nil,
    targetRole = nil,
    spellID = nil,
    spellName = nil,
    eventFrame = nil,
    db = nil
}

-- MARK: Constants
local UNKNOWN_SPELL_TEXTURE = 134400
local CLASS_MISDIRECTION = {
    HUNTER = {spellID = 34477, role = "TANK"},
    ROGUE = {spellID = 57934, role = "TANK"},
    DRUID = {spellID = 29166, role = "HEALER"},
    PRIEST = {spellID = 10060, role = "DAMAGER"}
}
local MACRO_NAME = "HBT_AutoMacro"
local MACRO_BODY = "#showtooltip\n/cast [@%s][@player] %s"
local MACRO_BODY_NO_TARGET = "#showtooltip\n/cast [@player] %s"

-- MARK: Get Spell Name

---Get the spell name for the player's class
local function FetchSpellName(self)
    local classData = CLASS_MISDIRECTION[addon.states["playerClass"]] or nil
    if not classData then return end

    local entry = self.db["Data"] and self.db["Data"][addon.states["playerClass"]]
    if entry and not entry.Enabled then -- user disabled this class' spell
        self.spellID = nil
        self.spellName = nil
        return
    end

    -- macro need the localized spell name
    local spellInfo = C_Spell.GetSpellInfo(classData.spellID)

    self.spellID = classData.spellID
    self.spellName = spellInfo and spellInfo.name or nil
end

-- MARK: Search Target

local function GetGroupType()
    if IsInGroup() then
        if IsInRaid() then
            return "RAID"
        else
            return "PARTY"
        end
    end

    return nil -- not in a group
end

local function GetGroupIterator()
    local groupType = GetGroupType()
    if not groupType then return nil end -- not in a group

    local numMembers = GetNumGroupMembers()
    local output = {}
    if groupType == "RAID" then
        for i = 1, numMembers do
            table.insert(output, "raid" .. i)
        end
    elseif groupType == "PARTY" then
        for i = 1, numMembers - 1 do
            table.insert(output, "party" .. i)
        end
    end

    return #output > 0 and output or nil
end

function AutoMacroHelper:SearchTarget()
    -- if player's class has no misdirection-like spell, disable the feature entirely
    local classData = CLASS_MISDIRECTION[addon.states["playerClass"]] or nil
    if not classData then
        self.targetRole = nil
        self.target = nil
        return
    end

    local entry = self.db["Data"] and self.db["Data"][addon.states["playerClass"]]
    local token = entry and entry.Target

    if token == "TANK" or token == "HEALER" or token == "DAMAGER" then -- a role token, update the role and search for it below
        self.targetRole = token
    elseif token and token ~= "" then -- a specified "name-realm" target, config panel does not assert the format
        self.target = token
        return
    else
        self.targetRole = classData.role
    end

    -- search group for a member matching the target role
    self.target = nil
    local groupIterator = GetGroupIterator()
    if groupIterator then
        for _, unit in ipairs(groupIterator) do
            if UnitGroupRolesAssigned(unit) == self.targetRole then
                local unitName, realm = UnitName(unit)
                local output = unitName .. (realm and "-" .. realm or "")
                
                self.target = output
                return -- use the first valid target
            end
        end
    end

    return nil
end

-- MARK: Macro

---Build the macro body, falling back to a self-cast only clause when no target is found
---@param self AutoMacroHelper self
local function BuildMacroBody(self)
    if self.target and self.target ~= "" then
        return MACRO_BODY:format(self.target, self.spellName)
    end

    return MACRO_BODY_NO_TARGET:format(self.spellName)
end

---Create/update the "HBT_AutoMacro" macro so its target and spell match the current state
---@param self AutoMacroHelper self
local function UpdateMacro(self)
    if not self.spellName then return end -- player's class has no misdirection-like spell

    local body = BuildMacroBody(self)
    local icon = C_Spell.GetSpellInfo(self.spellID).iconID or UNKNOWN_SPELL_TEXTURE
    local index = GetMacroIndexByName(MACRO_NAME)
    if index and index > 0 then
        EditMacro(index, MACRO_NAME, icon, body)
    else
        CreateMacro(MACRO_NAME, icon, body)
    end
end

---Public accessor to sync the "HBT_AutoMacro" macro with the current spell/target
function AutoMacroHelper:UpdateMacro()
    FetchSpellName(self)
    UpdateMacro(self)
end

-- MARK: Initialize

---Initialize (Constructor)
---@return AutoMacroHelper AutoMacroHelper a AutoMacroHelper object
function AutoMacroHelper:Initialize()
    self.eventFrame = CreateFrame("Frame", string.format("%s_%s", ADDON_NAME, self.modName))
    self.db = addon.db[self.modName]

    return self
end

-- MARK: RegisterEvents

---Register events
function AutoMacroHelper:RegisterEvents()
    addon.core:RegisterEvent("PLAYER_ENTERING_WORLD", self.eventFrame, self.modName)
    addon.core:RegisterEvent("GROUP_ROSTER_UPDATE", self.eventFrame, self.modName)

    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_ENTERING_WORLD" then
            self:SearchTarget()
            self:UpdateMacro()
        elseif event == "GROUP_ROSTER_UPDATE" then
            self:SearchTarget()
            self:UpdateMacro()
        end
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(AutoMacroHelper.modName, L["AutoMacroHelperSettings"], function() return AutoMacroHelper:Initialize() end)
