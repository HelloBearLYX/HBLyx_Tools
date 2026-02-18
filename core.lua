local ADDON_NAME, addon = ...

---@class addon.Core
---@field eventFrame Frame the frame used to register events
---@field eventMap table<string, table<string, function>> map of event to map of module to handler function
---@field modules table<string, table> map of module key to module instance, used to store
---@field registeredMods table<string, table> map of module key to module initialize and event register function, used to store the registered modules before they are loaded
---@field totalMods number total number of registered modules, used to check if all modules are loaded
---@field loadedMods number total number of loaded modules, used to check if all modules are loaded
---@field testMode boolean if the addon is in test mode
---@field statesUpdate table<string, table<string, function>> map of event to map of addon state to update function
---@field statesMonitor table<string, table<string, function>> map of addon state to map of module to monitor function
addon.Core = {
    eventFrame = nil,
    eventMap = {},
    eventUnitMap = {},
    modules = {},
    registeredMods = {},
    totalMods = 0,
    loadedMods = 0,
    testMode = false,
    statesUpdate = {},
    statesMonitor = {},
}

-- MARK: Initialize

---Initialize/Constructor
---@return addon.Core
function addon.Core:Initialize()
    self.eventFrame = CreateFrame("Frame")
    self.eventMap = {}
    self.eventUnitMap = {}
    self.modules = {}
    self.registeredMods = {}
    self.totalMods = 0
    self.loadedMods = 0
    self.testMode = false
    self.statesUpdate = {}
    self.statesMonitor = {}

    self.eventFrame:RegisterEvent("ADDON_LOADED") -- "ADDON_LOADED" is automatically registered

    return self
end

-- private methods
-- MARK: private event register

---Register event for the EventHandler on the EventHandler.eventFrame
---@param self addon.Core self
---@param event string event to register
---@param unit nil|string|table<string>? if this is a unit event, the unit name or units list
local function RegisterE(self, event, unit)
    if unit then
        if type(unit) == "table" then
            self.eventFrame:RegisterUnitEvent(event, unpack(unit))
        else
            self.eventFrame:RegisterUnitEvent(event, unit)
        end
    else
        self.eventFrame:RegisterEvent(event)
    end
end

-- MARK: Event Handler

---Handle events
---@param event string event name
---@param ... unknown other args passed to the handler
local function Handle(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == ADDON_NAME then
            addon:Initialize()
        end
    else
        -- let state update first
        for name, func in pairs(self.statesUpdate[event] or {}) do
            local delta = func(...)
            for _, monitorFunc in pairs(self.statesMonitor[name] or {}) do
                monitorFunc(delta)
            end
        end

        -- unit events
        for _, func in pairs(self.eventUnitMap[event] or {}) do
            func(...)
        end

        -- general events
        for _, func in pairs(self.eventMap[event] or {}) do
            func(...)
        end
    end
end

-- public methods
-- MARK: Register Event

---Call to let Manager register this event with the function
---@param event string event name
---@param mod string module name/key
---@param unit nil|string|table<string>? if this is a unit event, the unit name or units list
---@param func function function register to the event
function addon.Core:RegisterEvent(event, mod, unit, func)
    if not self.eventMap[event] then
        self.eventMap[event] = {}
    end

    self.eventMap[event][mod] = func

    RegisterE(self, event, unit)
end

-- MARK: Register State

---Register addon state to the core
---@param event string event name
---@param unit nil|string|table<string>? if this is a unit event, the unit name or units list
---@param name string name of the addon state
---@param updateFunc function function used to update the addon state when the event is triggered
function addon.Core:RegisterState(event, unit, name, updateFunc)
    if not self.statesUpdate[event] then
        self.statesUpdate[event] = {}
    end

    self.statesUpdate[event][name] = updateFunc

    RegisterE(self, event, unit)
end

-- MARK: Register State Monitor

---Register a module to an addon state, call the monitor function when the state is updated
---@param stateName string name(key) of the addon state
---@param moduleName string name(key) of the module
---@param monitorFunc function function used to monitor the addon state, it will be called with the delta of the state value when the state is updated
function addon.Core:RegisterStateMonitor(stateName, moduleName, monitorFunc)
    if not self.statesMonitor[stateName] then
        self.statesMonitor[stateName] = {}
    end

    self.statesMonitor[stateName][moduleName] = monitorFunc
end

-- MARK: Register Module

---Register module to the manager(not initialized so far)
---@param mod string module key
---@param initializeFunc function function used to initialize module
---@param eventRegisterFunc function function used to register events for the module, this will only run after the module is initialized and loaded
function addon.Core:RegisterModule(mod, initializeFunc, eventRegisterFunc)
    self.registeredMods[mod] = {initialize = initializeFunc, eventRegister = eventRegisterFunc}
    self.totalMods = self.totalMods + 1
end

-- MARK: Check Module Loaded

---Check if the module has been loaded
---@param mod string module key
---@return boolean if the module is loaded
function addon.Core:HasModuleLoaded(mod)
    return self.modules[mod] ~= nil
end

-- MARK: Load module

---Load(initialize and register events) the module
---@param mod string module key
---@return boolean if the module is loaded after this call
function addon.Core:LoadModule(mod)
    local loadedAlready = self:HasModuleLoaded(mod)

    if not loadedAlready and self.registeredMods[mod] and addon.db[mod]["Enabled"] then
        self.modules[mod] = self.registeredMods[mod].initialize()
        if self.modules[mod] and self.registeredMods[mod].eventRegister then
            self.registeredMods[mod].eventRegister()
            self.loadedMods = self.loadedMods + 1
        end
        return true
    elseif loadedAlready then -- if the module is already loaded, it has been loaded
        return true
    end

    return false
end

---Load all registered modules
function addon.Core:LoadAllModules()
    for mod, _ in pairs(self.registeredMods) do
        self:LoadModule(mod)
    end
end

---Get a module instance
---@param mod string module key
---@return table|nil module module instance or nil if not loaded
function addon.Core:GetModule(mod)
    if self:HasModuleLoaded(mod) then
        return self.modules[mod]
    else
        return nil
    end
end

-- MARK: Get UpdateStyle

---Get the safe update function for module
---@param mod string module key
---@return function update update function for the update module style
function addon.Core:GetSafeUpdate(mod)
    if self:HasModuleLoaded(mod) and self.modules[mod].UpdateStyle then
        return function() self.modules[mod]:UpdateStyle() end
    else
        return function() end
    end
end

-- MARK: TestMode

---Turn on/off TestMode for all loaded modules
---@param on boolean|nil turn on or off the test mode, nil to toggle the test mode
function addon.Core:TestMode(on)
    if on == nil then
        self.testMode = not self.testMode -- toggle test mode if on is nil
    else
        self.testMode = on -- set test mode to on if on is not nil
    end

    for _, module in pairs(self.modules) do -- for all loaded modules, call the Test function if it exists
        if module.Test then
            module:Test(self.testMode)
        end
    end
end

-- MARK: Module Test Mode

---Attempt to turn the test mod for the module
---@param module string module key
---@return boolean success if the test mode is turned on after this call
function addon.Core:TestModule(module)
    if self.modules[module] and self.modules[module].Test then
        self.modules[module]:Test(self.testMode)
        return self.testMode
    end

    return false
end

-- MARK: Is Test On

---Check whether the test mode is on
---@return boolean on if the test mode is on
function addon.Core:IsTestOn()
    return self.testMode
end

-- MARK: Get Module List

---Get All Modules List(include not-loaded)
---@return table<string> list of all registered module keys
function addon.Core:GetModuleList()
    local output = {}
    for mod, _ in pairs(self.registeredMods) do
        table.insert(output, mod)
    end

    return output
end

-- MARK: Core Start
---Start the core, let the eventFrame hook to events
function addon.Core:Start()
    self.eventFrame:SetScript("OnEvent", function (_, event, ...)
        Handle(self, event, ...)
    end)
end

-- MARK: Main-Initialize Core
addon.core = addon.Core:Initialize()