local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class TalentsReminders
---@field modName string module name for registering in core
---@field head Frame the head frame of the reminder list, used for anchoring the first reminder
---@field tail Frame the tail frame of the reminder list, used for anchoring the next reminder
---@field reminders table<integer, table<integer, table<integer>>> reminders[instanceID][spellID] = {spec1, spec2, ...}
---@field spareFrames table<frame> a list of spare frames that can be reused for new reminders, each
local TalentsReminders = {
    modName = "TalentsReminders",
}

-- MARK: Constants
local UNKNOWN_SPELL_TEXTURE = 134400
local INSTANCE_NAME = {
    -- current season
    [2526] = L["AA"],    -- Algeth'ar Academy
    [2811] = L["MT"],   -- Magister's Terrace
    [2874] = L["MC"],   -- Maisara Caverns
    [2915] = L["NPX"],   -- Nexus-Point Xenas
    [658] = L["PS"],   -- Pit of Saron
    [1753] = L["ST"],   -- Seat of the Triumvirate
    [1209] = L["Skyreach"],   -- Skyreach
    [2805] = L["WS"],   -- Windrunner Spire
}

-- MARK: Initialize

---Initialize (Constructor)
---@return TalentsReminders TalentsReminders a TalentsReminders object
function TalentsReminders:Initialize()
    self.head = CreateFrame("Frame", ADDON_NAME .. "_" .. self.modName, UIParent)
    self.tail = nil
    self.reminders = {}
    self.spareFrames = {}
    self.head:Show()

    return self
end

-- private methods

local function UpdateReminderInfo(frame, spellID)
    frame.spellID = spellID
    frame.icon:SetTexture(C_Spell.GetSpellInfo(spellID).iconID or UNKNOWN_SPELL_TEXTURE)
end

local function CreateReminder(self, spellID)
    local frame = CreateFrame("Frame", nil, self.head)

    frame.icon = frame:CreateTexture(nil, "BACKGROUND")
    frame.icon:SetAllPoints()

    frame.text = frame:CreateFontString(nil, "OVERLAY")
    frame.text:SetPoint("LEFT", frame, "RIGHT", 0, 0)
    frame.text:SetTextColor(1, 1, 1, 1)

    return frame
end

local function LoadReminder(self, instanceID, spellID)
    local frame = self.reminders[instanceID][spellID]

    if not frame then
        if #self.spareFrames > 0 then
            frame = table.remove(self.spareFrames) -- reuse a spare frame if available
        else
            frame = CreateReminder(self, spellID) -- create a new frame if no spare frame is available
        end

        self.reminders[instanceID][spellID] = frame
    end

    UpdateReminderInfo(frame, spellID) -- update the reminder info such as icon and text 
    self.reminders[spellID] = frame
end

local function UnloadReminder(self, instanceID, spellID)
    if not self.reminders[instanceID] or not self.reminders[instanceID][spellID] then
        return
    end

    local frame = self.reminders[instanceID][spellID]
    frame:Hide()
    frame.spellID = nil
    frame.icon:SetTexture(UNKNOWN_SPELL_TEXTURE)

    table.insert(self.spareFrames, frame) -- put the frame into spare pool for later re-use 
end

-- MARK: On Update

local function OnUpdate(self)
    -- only show in Myhic dungeon
    if not addon.states["instanceInfo"]["inInstance"] or addon.states["instanceInfo"]["difficultyID"] ~= 23 then
        return
    elseif addon.states["instanceInfo"]["difficultyID"] == 8 then -- start the Keystone
        for _, frame in ipairs(self.reminders) do
            frame:Hide()
        end
        return
    end

    local instanceID = addon.states["instanceInfo"]["instanceID"]
    local playerSpec = addon.states["playerSpec"]

    if addon.db[self.modName]["reminders"] then
        for spellID, specs in pairs(addon.db[self.modName]["reminders"][instanceID] or {}) do
            if not specs or not specs[playerSpec] then
            
            else
                LoadReminder(self, instanceID, spellID)
            end
        end
    end
end

-- MARK: UpdateStyle

---Update style settings and render them in-game for CustomTracker
function TalentsReminders:UpdateStyle()
    -- TODO: Update style settings and render them in-game when the user changes custom options
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function TalentsReminders:Test(on)
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
function TalentsReminders:RegisterEvents()
    addon.core:RegisterStateMonitor("instanceInfo", self.modName, function()
        OnUpdate(self)
    end)
    addon.core:RegisterStateMonitor("playerSpec", self.modName, function()
        OnUpdate(self)
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(TalentsReminders.modName, function() return TalentsReminders:Initialize() end)
