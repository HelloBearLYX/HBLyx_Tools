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

-- privete methods

local function LoadReminder(self, instanceID, spellID)
    local new = false
    local frame = self.reminders[instanceID][spellID]
end

local function UnloadReminder(self)
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
    -- TODO: Register events needed by your module here, for example:
    -- local handle = function() Handler(self) end
    -- addon.core:RegisterEvent("EVENT_NAME", handle)
end

-- MARK: Register Module
addon.core:RegisterModule(TalentsReminders.modName, function() return TalentsReminders:Initialize() end)
