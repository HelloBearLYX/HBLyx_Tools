---@class TemplateModule
TemplateModule = {
    
}

local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

-- MARK: Constants
-- TODO: The key for the module, used for databse, core, and other things. Replace "TemplateModule" with your module key
local MOD_KEY = "TemplateModule"

-- MARK: Initialize

---Initialize (Constructor)
---@return TemplateModule TemplateModule a TemplateModule object
function TemplateModule:Initialize()
    -- TODO: Initialize your module here

    self:UpdateStyle() -- Update style on initialization, so you do not have to duplicate code of rendering style in both Initialize and UpdateStyle functions

    return self
end

-- MARK: UpdateStyle

---Update style settings and render them in-game for CustomTracker
function TemplateModule:UpdateStyle()
    -- TODO: Update style settings and render them in-game when the user changes custom options
end

-- MARK: Test

---Test Mode for CustomTracker
---@param on boolean turn the Test mode on or off
function TemplateModule:Test(on)
    if not addon.db[MOD_KEY]["Enabled"] then -- if the module is not enabled, do not allow test mode
        return
    end

    if on then
        -- TODO: Implement test mode for your module
    else
        -- TODO: Disable test mode for your module
    end
end

-- MARK: RegisterEvents

---Register events for CustomTracker on EventsHandler
function TemplateModule:RegisterEvents()
    -- TODO: Register events needed by your module here, for example:
    -- local handle = function() Handler(self) end
    -- addon.core:RegisterEvent("EVENT_NAME", handle)
end

-- MARK: Register Module
-- TODO: register your module to the addon core, replace TemplateModule with your module name and make sure to implement Initialize and RegisterEvents functions
-- TODO: also, add the module in the .toc file, for both module and config file if you have one
addon.core:RegisterModule(MOD_KEY, function() return TemplateModule:Initialize() end, function() TemplateModule:RegisterEvents() end)
