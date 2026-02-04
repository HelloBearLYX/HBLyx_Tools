---@class EventsHandler
---@field eventFrame frame Blizzard frame which is a pseudo-frame to keep track of events
---@field eventMap table a table contains events and functions to excute when event triggered such as {event1 = {func1, func2, ...}, ...}
---@field eventNameMap table a table contains events and the modules which regiestered to it such as {event1 = {mod1, mod2, ...}, ...}
EventsHandler = {
    eventFrame = nil,
    eventMap = {},
    eventNameMap = {},
}

local ADDON_NAME, addon = ...

-- MARK: Initialize

---Initialize/Constructor of EventHandler
---@return EventsHandler
function EventsHandler:Initialize()
    self.eventFrame = CreateFrame("Frame")
    self.eventMap = {}
    self.eventNameMap = {}
    self.displayFrame = nil
    self.eventFrame:RegisterEvent("ADDON_LOADED") -- "ADDON_LOADED" is automatically registered

    return self
end

-- private methods
---Register event for the EventHandler on the EventHandler.eventFrame
---@param self EventsHandler self
---@param event string event to register
---@param unit? string if this is a unit event, the unit name to register 
local function RegisterE(self, event, unit)
    if unit then
        self.eventFrame:RegisterUnitEvent(event, unit)
    else
        self.eventFrame:RegisterEvent(event)
    end
end

---Handle events for EventsHandler, pass to SetScript(OnEvent, EventsHandler:Handle)
---@param event string event name
---@param ... unknown other args passed to the handler
function EventsHandler:Handle(event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == ADDON_NAME then
            addon:Initialize()
        end
    else
        for _, func in ipairs(self.eventMap[event]) do
            func(event, ...)
        end 
    end
end

-- public methods
---Call to let EventsHandler register this event with the function
---@param func function function register to the event
---@param event string event name
---@param mod string module name/key
---@param unit string? if this is a unit event, the unit name to register
function EventsHandler:Register(func, event, mod, unit)
    if not self.eventMap[event] then
        self.eventMap[event] = {}
        self.eventNameMap[event] = {}
    end

    table.insert(self.eventMap[event], func)
    table.insert(self.eventNameMap[event], mod)

    RegisterE(self, event, unit)
end

-- initialize the EventsHandler before main initialize
addon.eventsHandler = EventsHandler:Initialize()