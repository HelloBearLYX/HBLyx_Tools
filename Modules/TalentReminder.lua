local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class TalentReminder
local TalentReminder = {
    modName = "TalentReminder",
    head = nil, -- the head frame of the module, used to attach other frames
    tail = nil, -- tail of the showing icon linked-list
    spareFrames = {}, -- frame pool
    activeFrames = {}, -- frames currently showing
}

-- MARK: Constants

-- MARK: Initialize

---Initialize (Constructor)
---@return TalentReminder TalentReminder a TalentReminder object
function TalentReminder:Initialize()
    -- initial head
    self.head = CreateFrame("Frame", ADDON_NAME .. self.modName, UIParent)
    self.head:SetSize(addon.db[self.modName].IconSize, addon.db[self.modName].IconSize)
    self.head.text = self.head:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.head.text:SetPoint("LEFT", self.head, "LEFT", 0, 0)
    self.head.text:SetTextColor(255, 255, 255)
    self.head:Hide()

    return self
end

-- MARK: GetMissingTalents

---Get missing talents
---@return table missingTalents a table of missing talents(spellIDs)
local function GetMissingTalents(self)
    local missingTalents = {}

    local instanceData = addon.db[self.modName].data[addon.states.instanceInfo.instanceID]
    if instanceData then
        for spellID, loadingSpecs in pairs(instanceData) do
            local shouldCheck = not loadingSpecs or not next(loadingSpecs) or loadingSpecs[addon.states.playerSpec]
            if shouldCheck and not C_SpellBook.IsSpellKnown(spellID) then
                table.insert(missingTalents, spellID)
            end
        end
    end

    return missingTalents
end

--- MARK: Create Icon
--- Create an icon for the missing talent
local function CreateIcon(self)
    local icon = CreateFrame("Frame", nil, self.head)
    icon:SetSize(addon.db[self.modName].IconSize, addon.db[self.modName].IconSize)
    icon.border = CreateFrame("Frame", nil, icon, "BackdropTemplate")
    icon.border:SetAllPoints()
    icon.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    icon.border:SetBackdropBorderColor(0, 0, 0, 1)

    icon.texture = icon:CreateTexture(nil, "BACKGROUND")
    icon.texture:SetAllPoints()

    return icon
end

-- MARK: Load Talent Icon
---Insert an icon into the showing linked-list
---@param self TalentReminder
---@param icon Frame
local function InsertIcon(self, icon)
    if not self.tail then
        icon:ClearAllPoints()
        icon:SetPoint("LEFT", self.head.text, "RIGHT", 0, 0)
        icon.prev = self.head
    else
        icon:ClearAllPoints()
        icon:SetPoint("LEFT", self.tail, "RIGHT", 0, 0)
        icon.prev = self.tail
        icon.prev.next = icon
    end

    icon.next = nil
    self.tail = icon
    icon:Show()
end

---Remove an icon from the showing linked-list
---@param self TalentReminder
---@param icon Frame
local function RemoveIcon(self, icon)
    if not icon or not icon.prev then
        return
    end

    if icon.prev == self.head then
        if icon.next then
            icon.next:ClearAllPoints()
            icon.next:SetPoint("LEFT", self.head.text, "RIGHT", 0, 0)
            icon.next.prev = self.head
        else
            self.tail = nil
        end
    else
        if icon.next then
            icon.next:ClearAllPoints()
            icon.next:SetPoint("LEFT", icon.prev, "RIGHT", 0, 0)
            icon.next.prev = icon.prev
            icon.prev.next = icon.next
        else
            icon.prev.next = nil
            self.tail = icon.prev
        end
    end

    icon.prev = nil
    icon.next = nil
    icon:ClearAllPoints()
    icon:Hide()
    table.insert(self.spareFrames, icon)
end

--- Load a icon for a missing talent
--- @param spellID number the spellID of the missing talent
local function LoadTalentIcon(self, spellID)
    local icon
    if self.spareFrames[#self.spareFrames] then
        icon = table.remove(self.spareFrames, #self.spareFrames)
    else
        icon = CreateIcon(self)
    end

    icon.texture:SetTexture(C_Spell.GetSpellTexture(spellID))
    InsertIcon(self, icon)
    self.activeFrames[spellID] = icon
end

-- MARK: Unload Icon
---Unload a icon
---@param spellID number the spellID of the talent to unload
local function UnloadIcon(self, spellID)
    local icon = self.activeFrames[spellID]
    if icon then
        RemoveIcon(self, icon)
        self.activeFrames[spellID] = nil
    end
end

-- MARK: Clear Icons
---Clear all icons
local function ClearIcons(self)
    for spellID, _ in pairs(self.activeFrames) do
        UnloadIcon(self, spellID)
    end
end

-- MARK: OnUpdate
---OnUpdate handler
local function OnUpdate(self)
    -- as some states may update before the module is fully initialized, skip it until the first load is complete
    -- only make check when in a mythic dungeon(not keystone)
    -- if not self then return end

    self.head:Hide()
    ClearIcons(self)
    if addon.states.instanceInfo.difficultyID ~= 23 then return end

    local foundMissing = false

    for _, spellID in ipairs(GetMissingTalents(self)) do
        LoadTalentIcon(self, spellID)
        foundMissing = true
    end

    if foundMissing then
        self.head:Show()
    else
        self.head:Hide()
    end
end

-- MARK: UpdateStyle

---Update style settings and render them in-game for CustomTracker
function TalentReminder:UpdateStyle()
    self.head:SetPoint("CENTER", UIParent, "CENTER", addon.db[self.modName].X, addon.db[self.modName].Y)
    self.head:SetFrameStrata(addon.db[self.modName].FrameStrata)
    self.head.text:SetFont(
        addon.LSM:Fetch("font", addon.db[self.modName]["Font"]) or "Fonts\\FRIZQT__.TTF",
        addon.db[self.modName]["FontSize"],
        "OUTLINE"
    )
    self.head.text:SetText(addon.db[self.modName].MissingText)
    for _, icon in pairs(self.activeFrames) do
        icon:SetSize(addon.db[self.modName].IconSize, addon.db[self.modName].IconSize)
    end
    for _, icon in pairs(self.spareFrames) do
        icon:SetSize(addon.db[self.modName].IconSize, addon.db[self.modName].IconSize)
    end
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function TalentReminder:Test(on)
    if not addon.db[self.modName]["Enabled"] then -- if the module is not enabled, do not allow test mode
        return
    end

    if on then
        self.head:Show()
        addon.Utilities:ShowDragRegion(self.head, L["TalentReminderSettings"])
        addon.Utilities:MakeFrameDragPosition(self.head, self.modName, "X", "Y")
    else
        OnUpdate(self)
        addon.Utilities:HideDragRegion(self.head)
    end
end 

-- MARK: RegisterEvents

---Register events
function TalentReminder:RegisterEvents()
    addon.core:RegisterStateMonitor("instanceInfo", self.modName, function() OnUpdate(self) end)
    addon.core:RegisterStateMonitor("playerSpec", self.modName, function() OnUpdate(self) end)
    addon.core:RegisterEvent("TRAIT_CONFIG_UPDATED", self.head, self.modName)

    self.head:SetScript("OnEvent", function(_, event)
        if event == "TRAIT_CONFIG_UPDATED" then
            OnUpdate(self)
        end
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(TalentReminder.modName, function() return TalentReminder:Initialize() end)
