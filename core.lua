local ADDON_NAME, addon = ...

---@class addon.Core
---@field eventFrame Frame the frame used to register events
---@field eventMap table<string, table<string, table<function>>> map of event to module to functions, used to handle events
---@field modules table<string, table> map of module key to module instance, used to store
---@field registeredMods table<string, table> map of module key to module initialize and event register function, used to store the registered modules before they are loaded
---@field totalMods number total number of registered modules, used to check if all modules are loaded
---@field loadedMods number total number of loaded modules, used to check if all modules are loaded
addon.Core = {
    eventFrame = nil,
    eventMap = {},
    modules = {},
    registeredMods = {},
    totalMods = 0,
    loadedMods = 0,
}

-- MARK: Initialize

---Initialize/Constructor
---@return addon.Core
function addon.Core:Initialize()
    self.eventFrame = CreateFrame("Frame")
    self.eventMap = {}
    -- self.eventNameMap = {}
    self.modules = {}
    self.registeredMods = {}
    self.totalMods = 0
    self.loadedMods = 0

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
        for _, funcs in pairs(self.eventMap[event]) do
            for _, func in pairs(funcs) do
                func(event, ...)
            end
        end
    end
end

-- public methods
-- MARK: Register Event

---Call to let Manager register this event with the function
---@param func function function register to the event
---@param event string event name
---@param mod string module name/key
---@param unit nil|string|table<string>? if this is a unit event, the unit name or units list
function addon.Core:RegisterEvent(func, event, mod, unit)
    if not self.eventMap[event] then
        self.eventMap[event] = {}
        -- self.eventNameMap[event] = {}
    end

    if not self.eventMap[event][mod] then
        self.eventMap[event][mod] = {}
    end

    table.insert(self.eventMap[event][mod], func)

    RegisterE(self, event, unit)
end

function addon.Core:Start()
    self.eventFrame:SetScript("OnEvent", function (_, event, ...)
        Handle(self, event, ...)
    end)
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
---@param on boolean on(true)/off(false)
function addon.Core:TestMode(on)
    for _, module in pairs(self.modules) do -- for all loaded modules, call the Test function if it exists
        if module.Test then
            module:Test(on)
        end
    end
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

addon.core = addon.Core:Initialize()