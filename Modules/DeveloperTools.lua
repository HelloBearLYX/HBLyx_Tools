local ADDON_NAME, addon = ...

---@class DeveloperTools
---@field displayFrame frame|nil a frame to display developer tool's outputs
addon.DeveloperTools = {
    displayFrame = nil,
}

-- private methods

local function CreateDisplayFrame(self, info)
    if self.displayFrame then
        self.displayFrame:Hide()
        self.displayFrame = nil
        return
    end

    self.displayFrame = CreateFrame("Frame", ADDON_NAME .. "_EventsHandlerDisplay", UIParent)
    self.displayFrame:SetFrameStrata("HIGH")
    self.displayFrame:SetSize(0.75 * GetScreenWidth(), 0.75 * GetScreenHeight())
    self.displayFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

    self.displayFrame.background = self.displayFrame:CreateTexture(nil, "background")
    self.displayFrame.background:SetAllPoints()
    self.displayFrame.background:SetColorTexture(0, 0, 0, 0.5)

    self.displayFrame.text = self.displayFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    self.displayFrame.text:SetSize(0.75 * GetScreenWidth(), 0.75 * GetScreenHeight())
    self.displayFrame.text:SetPoint("TOPLEFT", self.displayFrame, "TOPLEFT", 0, 0)
    self.displayFrame.text:SetJustifyH("LEFT")
    self.displayFrame.text:SetJustifyV("TOP")
    self.displayFrame.text:SetTextColor(1, 1, 1, 1)
    self.displayFrame.text:SetFont(
        "Fonts\\FRIZQT__.TTF",
        12,
        "OUTLINE"
    )

    self.displayFrame.close = CreateFrame("Button", nil, self.displayFrame, "UIPanelCloseButton")
    self.displayFrame.close:SetPoint("TOPRIGHT", self.displayFrame, "TOPRIGHT", 0, 0)
    self.displayFrame.close:SetScript("OnClick", function()
        self.displayFrame:Hide()
        self.displayFrame = nil
    end)

    self.displayFrame.text:SetText(info)
    self.displayFrame:Show()

    local popupDialogs = _G.StaticPopupDialogs
    if type(popupDialogs) ~= "table" then
		popupDialogs = {}
	end

    if type(popupDialogs[ADDON_NAME .. "_Info"]) ~= "table" then
        popupDialogs[ADDON_NAME .. "_Info"] = {}
    end
    
    popupDialogs[ADDON_NAME .. "_Info"] = {
        text = "Copy the addon info below if needed",
        button1 = OKAY,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        hasEditBox = true,
        OnShow = function(self)
            self.EditBox:SetText(info)
            self.EditBox:SetFocus()
            self.EditBox:HighlightText()
        end,
        editBoxWidth = 300,
    }

    StaticPopup_Show(ADDON_NAME .. "_Info")
end

local function GetEventsInfo()
    local events = {}
    local eventsCount = {}
    for event, modules in pairs(addon.core.eventMap) do
        table.insert(events, event)
        eventsCount[event] = 0
        for _, _ in pairs(modules) do
            eventsCount[event] = eventsCount[event] + 1
        end
    end
    table.sort(events, function (a, b)
        if eventsCount[a] == eventsCount[b] then
            return a < b
        end

        return eventsCount[a] > eventsCount[b]
    end)

    local output = "|cff8788EEEvents Info|r:\n"
    local total = 0
    
    for _, event in ipairs(events) do
        output = output .. "|cff00ff00" .. event .. "|r|cffC41E3A(" .. tostring(eventsCount[event]) .. ")|r: "
        total = total + eventsCount[event]
        for mod, _ in pairs(addon.core.eventMap[event]) do
            output = output .. mod .. ", "
        end
        output = output .. "\n"
    end

    output = output .. string.format("*|cff00ff00Total Events: %d|r *|cffC41E3ATotal Registers: %d|r\n", #events, total)

    return output
end

local function GetStatesInfo()
    local vars = {}
    for var, _ in pairs(addon.states) do
        table.insert(vars, var)
    end
    table.sort(vars)

    local output = "|cff8788EEAddon States Info|r:\n"
    
    for _, var in ipairs(vars) do
        output = output .. string.format("|cff0070DD%s|r|cffC41E3A(%s)|r: %s, ", var, type(addon.states[var]), tostring(addon.states[var]))
    end
    output = output .. "\n"

    for event, states in pairs(addon.core.statesUpdate) do
        output = output .. string.format("|cff00ff00%s|r: ", event)
        for state, _ in pairs(states) do
            output = output .. string.format("%s, ", state)
        end
        output = output .. "\n"
    end

    return output
end

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

function addon.DeveloperTools:DisplayAddonInfo()
    if self.displayFrame then -- if there is an existing display frame
        CreateDisplayFrame(self, "") -- erase and reset it
        return
    end

    local output = ""

    output = output .. GetModulesInfo() .. "\n" .. GetEventsInfo() .. "\n" .. GetStatesInfo()

    CreateDisplayFrame(self, output)
end