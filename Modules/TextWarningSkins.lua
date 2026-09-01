local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class TextWarningSkins
local TextWarningSkins = {
    modName = "TextWarningSkins",
}

-- MARK: Constants
local COUNTDOWN_ICON = 132349
local COUNTDOWN_SPELLID = 386164

-- MARK: Initialize

---Initialize (Constructor)
---@return TextWarningSkins TextWarningSkins a TextWarningSkins object
function TextWarningSkins:Initialize()
    -- forrce turn the Blizzard Encounter Warning
    C_CVar.SetCVar("encounterWarningsEnabled", "1")
    C_EncounterWarnings.SetPlayCustomSoundsWhenHidden(true)
    C_EncounterWarnings.SetWarningsShown(false)
    
    self.head = CreateFrame("Frame", ADDON_NAME .. "_" .. self.modName, UIParent)
    self.tail = nil
    self.spareFrames = {}

    self.privateWarningFrame = CreateFrame("Frame", nil, UIParent)
    self.privateWarningFrame:Show()

    return self
end

-- MARK: Queue Helpers

---Insert a warning frame at the end of the active display queue
---@param self TextWarningSkins self
---@param frame Frame the warning frame to insert
local function QueueInsert(self, frame)
    local anchorFrom, anchorTo = addon.Utilities:GetGrowAnchors(addon.db[self.modName]["Grow"])
    if not self.tail then
        frame:ClearAllPoints()
        frame:SetPoint(anchorFrom, self.head, anchorFrom, 0, 0)
        frame.prev = self.head
    else
        frame:ClearAllPoints()
        frame:SetPoint(anchorFrom, self.tail, anchorTo, 0, 0)
        frame.prev = self.tail
        frame.prev.next = frame
    end

    self.tail = frame
end

local function QueueRemove(self, frame)
    local anchorFrom, anchorTo = addon.Utilities:GetGrowAnchors(addon.db[self.modName]["Grow"])
    if frame.prev == self.head then
        if frame.next then
            frame.next:ClearAllPoints()
            frame.next:SetPoint(anchorFrom, self.head, anchorFrom, 0, 0)
            frame.next.prev = self.head
        else
            self.tail = nil
        end
    else
        if frame.next then
            frame.next:ClearAllPoints()
            frame.next:SetPoint(anchorFrom, frame.prev, anchorTo, 0, 0)
            frame.next.prev = frame.prev
            frame.prev.next = frame.next
        else
            frame.prev.next = nil
            self.tail = frame.prev
        end
    end

    frame.prev = nil
    frame.next = nil
end

-- MARK: UpdateWarningStyle

---Apply current style settings to a warning frame
---@param self TextWarningSkins self
---@param frame Frame the warning frame to update
local function UpdateWarningStyle(self, frame)
    frame:SetSize(addon.db[self.modName]["Width"], addon.db[self.modName]["Height"])
    frame.text:SetWidth(addon.db[self.modName]["Width"])
    frame.text:SetHeight(addon.db[self.modName]["Height"])
    frame.text:SetFont(
        addon.LSM:Fetch("font", addon.db[self.modName]["Font"]) or "Fonts\\FRIZQT__.TTF",
        addon.db[self.modName]["FontSize"],
        "OUTLINE"
    )
end

-- MARK: CreateWarning

---Create a new warning display frame
---@param self TextWarningSkins self
---@return Frame frame the created warning frame
local function CreateWarning(self)
    local frame = CreateFrame("Frame", nil, UIParent)
    frame.text = frame:CreateFontString(nil, "OVERLAY")
    frame.text:SetAllPoints()
    UpdateWarningStyle(self, frame)

    frame.active = false
    frame.timer = nil

    return frame
end

-- MARK: UnloadWarning

---Unload a warning frame, cancelling its timer and returning it to the spare pool
---@param self TextWarningSkins self
---@param frame Frame the warning frame to unload
local function UnloadWarning(self, frame)
    if frame.timer then
        frame.timer:Cancel()
        frame.timer = nil
    end

    frame:Hide()
    frame.active = false
    frame.text:SetText("")

    -- linked-list removal
    QueueRemove(self, frame)

    table.insert(self.spareFrames, frame)
end

-- MARK: LoadWarning

---Load and display a new warning from the given encounter warning info
---@param self TextWarningSkins self
---@param info table the encounter warning info payload
local function LoadWarning(self, info)
    local frame
    if self.spareFrames[#self.spareFrames] then
        frame = table.remove(self.spareFrames, #self.spareFrames)
    else
        frame = CreateWarning(self)
    end

    local text = info.text
    local casterName = info.casterName
    local targetName = info.targetName
    local targetGUID = info.targetGUID
    local icon = info.iconFileID
    local duration = info.duration
    if targetGUID then
        local className = select(2, GetPlayerInfoByGUID(targetGUID))
        if className then
            local classColor = C_ClassColor.GetClassColor(className)
            if classColor then
                targetName = classColor:WrapTextInColorCode(targetName)
            end
        end
    end

    if info.isTest or (duration and duration > 0) then
        text = string.format(text, casterName, targetName)
        -- if info.color then
        --     text = info.color:WrapTextInColorCode(text)
        -- end
        frame.text:SetText(string.format("|T%d:%d:%d|t%s", icon, addon.db[self.modName]["FontSize"], addon.db[self.modName]["FontSize"], text))
        frame:Show()
        frame.active = true

        -- linked-list insertion
        QueueInsert(self, frame)

        if not info.isTest then
            frame.timer = C_Timer.NewTimer(duration, function()
                UnloadWarning(self, frame)
            end)
        end

        if info.isTest then
            self.testWarningFrame = frame
        end
    end

    -- if info.shouldShowChatMessage then
    --     local chatMessage = string.format(info.text, info.casterName, info.targetName)
    --     addon.Utilities:print(chatMessage)
    -- end
end

-- MARK: Test Private Warning

---Show or hide the test overlay for the private warning frame
---@param self TextWarningSkins self
---@param onTest boolean whether to show or hide the test overlay
local function TestPrivateWarning(self, onTest)
    if self.privateWarningFrame and not self.privateWarningFrame.testWarning then
        local testWarning = CreateFrame("Frame", nil, self.privateWarningFrame)
        testWarning:SetAllPoints()
        testWarning.text = testWarning:CreateFontString(nil, "OVERLAY")
        testWarning.text:SetAllPoints()
        testWarning.text:SetFont(
            "Fonts\\FRIZQT__.TTF",
            12,
            "OUTLINE"
        )
        testWarning.text:SetText("Test Private Warning |T134400:16:16|t[Private Aura]")

        self.privateWarningFrame.testWarning = testWarning
    end

    if onTest then
        self.privateWarningFrame.testWarning:Show()
    else
        self.privateWarningFrame.testWarning:Hide()
    end
end

-- MARK: UpdateStyle

---Update style settings and render them in-game for CustomTracker
function TextWarningSkins:UpdateStyle()
    self.head:SetSize(addon.db[self.modName]["Width"], addon.db[self.modName]["Height"])
    self.head:SetPoint("CENTER", UIParent, "CENTER", addon.db[self.modName]["X"], addon.db[self.modName]["Y"])

    self.privateWarningFrame:SetSize(addon.db[self.modName]["Width"], addon.db[self.modName]["Height"])
    self.privateWarningFrame:SetPoint("CENTER", UIParent, "CENTER", addon.db[self.modName]["PrivateWarningX"], addon.db[self.modName]["PrivateWarningY"])
    local anchorBinding = {point = "CENTER", relativeTo = self.privateWarningFrame, relativePoint = "CENTER", offsetX = 0, offsetY = 0}
    if not InCombatLockdown() then
        C_UnitAuras.SetPrivateWarningTextAnchor(self.privateWarningFrame, anchorBinding)
    end

    local currentFrame = self.head.next
    while currentFrame do
        UpdateWarningStyle(self, currentFrame)
        currentFrame = currentFrame.next
    end

    for _, frame in pairs(self.spareFrames) do
        UpdateWarningStyle(self, frame)
    end
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function TextWarningSkins:Test(on)
    if not addon.db[self.modName]["Enabled"] then -- if the module is not enabled, do not allow test mode
        return
    end

    if on then
        local testInfo = {
            text = "Test Warning",
            iconFileID = 134400,
            color = CreateColor(1, 1, 1),
            isTest = true,
        }
        LoadWarning(self, testInfo)

        TestPrivateWarning(self, true)

        addon.Utilities:ShowDragRegion(self.head, L["TextWarningSkinsSettings"])
        addon.Utilities:MakeFrameDragPosition(self.head, self.modName, "X", "Y")

        addon.Utilities:ShowDragRegion(self.privateWarningFrame, L["PrivateWarningSettings"])
        addon.Utilities:MakeFrameDragPosition(self.privateWarningFrame, self.modName, "PrivateWarningX", "PrivateWarningY")
    else
        if self.testWarningFrame then
            UnloadWarning(self, self.testWarningFrame)
            self.testWarningFrame = nil
        end

        TestPrivateWarning(self, false)

        addon.Utilities:HideDragRegion(self.head)
        addon.Utilities:HideDragRegion(self.privateWarningFrame)
    end
end

-- MARK: RegisterEvents

---Register events
function TextWarningSkins:RegisterEvents()
    addon.core:RegisterEvent("ENCOUNTER_WARNING", self.head, self.modName)
    addon.core:RegisterEvent("START_PLAYER_COUNTDOWN", self.head, self.modName)

    self.head:SetScript("OnEvent", function(_, event, ...)
        if event == "ENCOUNTER_WARNING" then
            local encounterWarningInfo = ...
            LoadWarning(self, encounterWarningInfo)
        elseif event == "START_PLAYER_COUNTDOWN" then
            local initiatorGUID, _, duration, _, name = ...
            if initiatorGUID then
                local class = select(2, GetPlayerInfoByGUID(initiatorGUID)) or "PRIEST"
                name = C_ClassColor.GetClassColor(class):WrapTextInColorCode(name) or name
            end
            duration = duration > 60 and string.format("%d:%02d", math.floor(duration / 60), duration % 60) or tostring(duration)
            local countdownInfo = {
                text = name .. L["CountdownTextWarning"] .. duration,
                iconFileID = COUNTDOWN_ICON,
                color = CreateColor(1, 1, 1),
                duration = 3,
            }
            LoadWarning(self, countdownInfo)
        end
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(TextWarningSkins.modName, function() return TextWarningSkins:Initialize() end)
