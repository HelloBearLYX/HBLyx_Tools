local ADDON_NAME, addon = ...

---@class DeveloperTools
---@field displayFrame frame? a frame to display developer tool's outputs
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
    self.displayFrame:SetFrameStrata("LOW")
    self.displayFrame:SetSize(750, 500)
    self.displayFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

    self.displayFrame.background = self.displayFrame:CreateTexture(nil, "background")
    self.displayFrame.background:SetAllPoints()
    self.displayFrame.background:SetColorTexture(0, 0, 0, 0.5)

    self.displayFrame.text = self.displayFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    self.displayFrame.text:SetPoint("TOPLEFT", self.displayFrame, "TOPLEFT", 0, 0)
    self.displayFrame.text:SetJustifyH("LEFT")
    self.displayFrame.text:SetWidth(750)
    self.displayFrame.text:SetTextColor(1, 1, 1, 1)
    self.displayFrame.text:SetFont(
        "Fonts\\FRIZQT__.TTF",
        12,
        "OUTLINE"
    )

    self.displayFrame.text:SetText(info)
    self.displayFrame:Show()

    local popupDialogs = _G.StaticPopupDialogs
    if type(popupDialogs) ~= "table" then
		popupDialogs = {}
	end

    if type(popupDialogs[ADDON_NAME .. "_Info"] ~= "table") then
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
	end

    StaticPopup_Show(ADDON_NAME .. "_Info")
end

-- public methods

function addon.DeveloperTools:IsShown()
    return self.displayFrame ~= nil
end

local function GetEventsInfo()
    local events = {}
    for event, _ in pairs(addon.eventsHandler.eventNameMap) do
        table.insert(events, event)
    end
    table.sort(events, function (a, b)
        if #addon.eventsHandler.eventNameMap[a] == #addon.eventsHandler.eventNameMap[b] then
            return a < b
        end

        return #addon.eventsHandler.eventNameMap[a] > # addon.eventsHandler.eventNameMap[b]
    end)

    local output = ""
    local count = 0
    
    for _, event in ipairs(events) do
        output = output .. "|cff00ff00" .. event .. "|r|cffC41E3A(" .. tostring(#addon.eventsHandler.eventNameMap[event]) .. ")|r: "
        count = count + #addon.eventsHandler.eventNameMap[event]
        for i, mod in ipairs(addon.eventsHandler.eventNameMap[event]) do
            if i < #addon.eventsHandler.eventNameMap[event] then -- NOTE: Lua start index with 1 end with n instead of 0 to n-1
                output = output .. tostring(mod .. ", ")
            else
                output = output .. tostring(mod .. "\n")
            end
        end
    end

    output = output .. string.format("*|cff00ff00Total Events: %d|r *|cffC41E3ATotal Registers: %d|r\n", #events, count)

    return output
end

local function GetGlobalVarInfo()
    local vars = {}
    for var, _ in pairs(addon.Global) do
        table.insert(vars, var)
    end
    table.sort(vars)

    local output = ""
    
    for i, var in ipairs(vars) do
        if i < #vars then
            output = output .. string.format("|cff0070DD%s|r|cffC41E3A(%s)|r: %s, ", var, type(addon.Global[var]), tostring(addon.Global[var]))
        else
            output = output .. string.format("|cff0070DD%s|r|cffC41E3A(%s)|r: %s\n", var, type(addon.Global[var]), tostring(addon.Global[var]))
        end
    end

    return output
end

function addon.DeveloperTools:DisplayAddonInfo()
    if self.displayFrame then -- if there is an existing display frame
        CreateDisplayFrame(self, "") -- erase and reset it
        return
    end

    local output = ""

    output = output .. GetEventsInfo() .. "\n" .. GetGlobalVarInfo()

    CreateDisplayFrame(self, output)
end