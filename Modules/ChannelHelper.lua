local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class ChannelHelper
---@field frame frame? the bar frame
---@field buttons table<string, frame> map of channel key to its button
local ChannelHelper = {
    modName = "ChannelHelper",
}

-- MARK: Constants
local CHANNELS = {
    {channel = "say", command = "/s", short = "S"},
    {channel = "yell", command = "/y", short = "Y"},
    {channel = "party", command = "/p", short = "P"},
    {channel = "raid", command = "/raid", short = "R"},
    {channel = "raidwarning", command = "/rw", short = "RW"},
    {channel = "guild", command = "/g", short = "G"},
    {channel = "custom", command = "/1", short = "C"},
    {channel = "roll", command = "/roll", isCommand = true, icon = "Interface\\Buttons\\UI-GroupLoot-Dice-Up"}
}

-- private methods

---Get the display text for a channel button(icon channels render a texture escape string, others show custom or localized text)
---@param self ChannelHelper self
---@param entry table channel entry from CHANNELS
---@return string text label to show on the button
local function GetChannelText(self, entry)
    if entry.icon then
        return string.format("|T%s:0|t", entry.icon)
    end

    local text = addon.db[self.modName]["Text_" .. entry.channel]
    if text and text ~= "" then
        return text
    end

    return entry.short
end

---Resolve the slash command to switch to a channel(the custom channel accepts a raw number or slash command, e.g. "5" or "/5")
---@param self ChannelHelper self
---@param entry table channel entry from CHANNELS
---@return string command the slash command to open chat with
local function ResolveCommand(self, entry)
    if entry.channel ~= "custom" then
        return entry.command
    end

    local command = addon.db[self.modName]["Command_custom"]
    command = command and command:match("^%s*(.-)%s*$") or ""
    if command == "" then
        return entry.command
    end

    if not command:match("^/") then
        command = "/" .. command
    end

    return command
end

---Find the function bound to a slash command, falling back to a scan of SlashCmdList for late-registered aliases
---@param slash string the slash command(with leading "/")
---@return function? handler the registered handler, if any
local function FindSlashHandler(slash)
    if type(slash) ~= "string" or slash == "" then
        return nil
    end

    slash = slash:upper()
    local handler = _G.hash_SlashCmdList and _G.hash_SlashCmdList[slash]
    if type(handler) == "function" then
        return handler
    end

    for key, candidate in pairs(_G.SlashCmdList or {}) do
        if type(candidate) == "function" then
            local index = 1
            while true do
                local registered = _G["SLASH_" .. tostring(key) .. index]
                if not registered then
                    break
                end
                if tostring(registered):upper() == slash then
                    return candidate
                end
                index = index + 1
            end
        end
    end

    return nil
end

---Trigger a channel button(commands run their registered slash handler directly, channels open the chat edit box)
---@param self ChannelHelper self
---@param entry table channel entry from CHANNELS
local function Execute(self, entry)
    local command = ResolveCommand(self, entry)

    if entry.isCommand then
        local slash, args = command:match("^(/[^%s]+)%s*(.*)")
        local handler = FindSlashHandler(slash)
        if type(handler) == "function" then
            pcall(handler, args or "")
        end
        return
    end

    ChatFrame_OpenChat(command .. " ")
end

---Create a single clickable text button for a channel
---@param self ChannelHelper self
---@param parent frame the bar frame
---@param entry table channel entry from CHANNELS
---@return frame button the created button
local function CreateButton(self, parent, entry)
    local button = CreateFrame("Button", nil, parent)
    button:RegisterForClicks("AnyDown")

    button.highlight = button:CreateTexture(nil, "HIGHLIGHT")
    button.highlight:SetAllPoints()
    button.highlight:SetColorTexture(1, 1, 1, 0.2)

    button.text = button:CreateFontString(nil, "OVERLAY")
    button.text:SetPoint("CENTER")

    button:SetScript("OnClick", function()
        Execute(self, entry)
    end)

    return button
end

---Create the bar frame and one button per channel
---@param self ChannelHelper self
---@return frame frame the created bar frame
local function CreateCHFrame(self)
    local frame = CreateFrame("Frame", ADDON_NAME .. "_ChannelHelper", UIParent)
    frame:SetSize(10, 10) -- resized in UpdateStyle once the buttons are laid out

    self.buttons = {}
    for _, entry in ipairs(CHANNELS) do
        self.buttons[entry.channel] = CreateButton(self, frame, entry)
    end

    return frame
end

-- MARK: Initialize

---Initialize (Constructor)
---@return ChannelHelper ChannelHelper a ChannelHelper object
function ChannelHelper:Initialize()
    self.frame = CreateCHFrame(self)
    self.frame:Show()

    return self
end

-- MARK: UpdateStyle

---Update style settings and render them in-game for ChatChannels
function ChannelHelper:UpdateStyle()
    local db = addon.db[self.modName]
    local font = addon.LSM:Fetch("font", db["Font"]) or addon.DEFAULTS.font
    local height = db["ButtonHeight"]
    local padding = db["ButtonPadding"]
    local spacing = db["ButtonSpacing"]
    local vertical = db["Vertical"] == true
    -- extra empty margin on both sides so the drag region doesn't overlap the buttons(like MicroMenu)
    self.frame:SetFrameStrata(db["FrameStrata"] or "MEDIUM")

    local previous
    local totalPrimary = 0 -- accumulated size along the bar's growth axis(width if horizontal, height if vertical)
    local maxCross = 0 -- largest size along the perpendicular axis, used as the bar's other dimension
    for _, entry in ipairs(CHANNELS) do
        local button = self.buttons[entry.channel]
        if db["Enabled_" .. entry.channel] then
            button.text:SetFont(font, db["FontSize"], "OUTLINE")
            button.text:SetText(GetChannelText(self, entry))
            if not entry.icon then
                button.text:SetTextColor(addon.Utilities:HexToRGB(db["Color_" .. entry.channel]))
            end

            local width = math.max(button.text:GetStringWidth() + padding * 2, height)
            button:SetSize(width, height)

            button:ClearAllPoints()
            if vertical then
                if previous then
                    button:SetPoint("TOP", previous, "BOTTOM", 0, -spacing)
                    totalPrimary = totalPrimary + spacing + height
                else
                    button:SetPoint("TOP", self.frame, "TOP", 0, 0)
                    totalPrimary = height
                end
                maxCross = math.max(maxCross, width)
            else
                if previous then
                    button:SetPoint("LEFT", previous, "RIGHT", spacing, 0)
                    totalPrimary = totalPrimary + spacing + width
                else
                    button:SetPoint("LEFT", self.frame, "LEFT", 0, 0)
                    totalPrimary = width
                end
                maxCross = math.max(maxCross, height)
            end

            button:Show()
            previous = button
        else
            button:Hide()
        end
    end

    if vertical then
        self.frame:SetSize(math.max(maxCross, 1), math.max(totalPrimary, 1))
    else
        self.frame:SetSize(math.max(totalPrimary, 1), math.max(maxCross, 1))
    end
    self.frame:ClearAllPoints()
    self.frame:SetPoint("CENTER", UIParent, "CENTER", db["X"], db["Y"])
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function ChannelHelper:Test(on)
    if not addon.db[self.modName]["Enabled"] then -- if the module is not enabled, do not allow test mode
        return
    end

    if on then
        addon.Utilities:ShowEditFrame(self.frame, addon.db[self.modName], "X", "Y", nil, nil, L["ChannelHelperSettings"])
    else
        addon.Utilities:HideEditFrame(self.frame)
    end
end

-- MARK: RegisterEvents

---Register events
function ChannelHelper:RegisterEvents()
    -- no game state dependent behavior is needed, channels resolve at click time
end

-- MARK: Register Module
addon.core:RegisterModule(ChannelHelper.modName, function() return ChannelHelper:Initialize() end)
