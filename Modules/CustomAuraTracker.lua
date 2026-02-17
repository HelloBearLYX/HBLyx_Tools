---@class CustomAuraTracker
CustomAuraTracker = {
    auras = {},
}

local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

-- MARK: Constants
-- TODO: The key for the module, used for databse, core, and other things. Replace "CustomIconTracker" with your module key
local MOD_KEY = "CustomAuraTracker"
local UNKNOWN_SPELL_TEXTURE = 134400

-- MARK: Initialize

---Initialize (Constructor)
---@return CustomAuraTracker CustomAuraTracker a CustomAuraTracker object
function CustomAuraTracker:Initialize()
    self.auras = {}
    self.auras.spells = {}
    self.auras.size = 0
    self.auras.head = CreateFrame("Frame", ADDON_NAME .. "_CustomAuraTracker", UIParent)
    self.auras.tail = nil
    self.auras.head:Show()

    self:UpdateStyle() -- Update style on initialization, so you do not have to duplicate code of rendering style in both Initialize and UpdateStyle functions

    return self
end

-- private methods

-- MARK: Load Saved Auras

---Handle old data(3.6.0 - 3.6.1)
---@param auraList any
local function HanlerOldAuraData(auraList)
    local oldAuras= {}

    for id, auraData in pairs(auraList) do
        if auraData.id then
            addon.Utilities:print(string.format("Found old aura data: %d", auraData.id))
            local spellID = auraData.id
            oldAuras[spellID] = {
                index = id,
                duration = auraData.duration,
                cooldown = auraData.cooldown,
                activeSound = auraData.activeSound,
                expireSound = auraData.expireSound,
            }
        end
    end

    for spellID, auraData in pairs(oldAuras) do
        addon.Utilities:print(string.format("Replace old aura data with new format: %d", addon.db[MOD_KEY].spells[auraData.index].id))
        addon.db[MOD_KEY].spells[auraData.index] = nil
        addon.db[MOD_KEY].spells[spellID] = auraData
    end
end

---Load saved auras from database and initialize them
---@param self CustomAuraTracker self
local function LoadSavedAuras(self)
    local auraList = addon.db[MOD_KEY].spells

    if auraList then
        HanlerOldAuraData(auraList)

        for spellID, auraData in pairs(auraList) do
            self:AddAura(spellID, auraData.duration, auraData.cooldown, auraData.activeSound, auraData.expireSound)
        end
    end

    self:UpdateStyle()
end

-- MARK: Show Aura

---Set showing auras
---@param self CustomAuraTracker self
---@param frame frame the frame of the aura to show
local function ShowAura(self, frame)
    local anchorFrom, anchorTo = addon.Utilities:GetGrowAnchors(addon.db[MOD_KEY]["Grow"])

    if not self.auras.tail then -- if tail is head, return the first position
        frame:ClearAllPoints()
        frame:SetPoint(anchorFrom, self.auras.head, anchorFrom, 0, 0)
        frame.prev = self.auras.head
    else
        frame:ClearAllPoints()
        frame:SetPoint(anchorFrom, self.auras.tail, anchorTo, 0, 0)
        frame.prev = self.auras.tail
        frame.prev.next = frame
    end

    self.auras.tail = frame
    frame:Show()
end

-- MARK: Hide Aura

---Hide aura and relink the showing auras chain
---@param self CustomAuraTracker self
---@param frame frame the frame of the aura to hide
local function HideAura(self, frame)
    local anchorFrom, anchorTo = addon.Utilities:GetGrowAnchors(addon.db[MOD_KEY]["Grow"])

    if frame.prev == self.auras.head then -- if the first showing aura
        if frame.next then -- if there is another showing aura after this one, set it to first position
            frame.next:ClearAllPoints()
            frame.next:SetPoint(anchorFrom, self.auras.head, anchorFrom, 0, 0)
            frame.next.prev = self.auras.head
        else -- if there is no other showing aura, set tail to head
            self.auras.tail = nil
        end
    else -- if this is not the first showing aura
        if frame.next then -- if there is another showing aura after this one, set it to the previous position
            frame.next:ClearAllPoints()
            frame.next:SetPoint(anchorFrom, frame.prev, anchorTo, 0, 0)
            frame.next.prev = frame.prev
            frame.prev.next = frame.next
        else -- if there is no other showing aura, set tail to the previous position
            frame.prev.next = nil
            self.auras.tail = frame.prev
        end
    end

    frame.prev = nil
    frame.next = nil
    frame:ClearAllPoints()
    frame:Hide()
end

-- MARK: Handler

---Handler for CustomAuraTracker when a tracked spell is cast
---@param self CustomAuraTracker self
---@param spellID integer the spell ID that was cast
local function Handler(self, spellID)
    local frame = self.auras.spells[spellID]
    if frame then
        if frame.timer then
            frame.timer:Cancel()
            frame.timer = nil
        end

        frame:Show()
        ShowAura(self, frame)
        frame.cooldown:SetCooldown(GetTime(), frame.duration)
        if frame.activeSound then
            PlaySoundFile(addon.LSM:Fetch("sound", frame.activeSound), addon.db[MOD_KEY]["SoundChannel"] or "Master")
        end

        -- after duration
        frame.timer = C_Timer.NewTimer(frame.duration, function()
            HideAura(self, frame)
            -- set cooldown timer, make a callback after cooldown to play ready sound if exist
            frame.timer = C_Timer.NewTimer(math.max(frame.cd - frame.duration, 0), function()
                if frame.expireSound then
                    PlaySoundFile(addon.LSM:Fetch("sound", frame.expireSound), addon.db[MOD_KEY]["SoundChannel"] or "Master")
                end
                frame.timer = nil
            end)
        end)
    end
end

-- MARK: Update Aura Info

---Update aura information for a frame
---@param frame frame the frame to update
---@param spellID integer the spell ID
---@param duration number the duration of the aura effect
---@param cooldown number the cooldown of the spell
---@param activeSound string? the sound to play when aura becomes active
---@param expireSound string? the sound to play when cooldown expires
local function UpdateAuraInfo(frame, spellID, duration, cooldown, activeSound, expireSound)
    frame.spellID = spellID
    frame.duration = duration
    frame.cd = cooldown
    frame.activeSound = activeSound
    frame.expireSound = expireSound
    frame.timer = nil
    local info = C_Spell.GetSpellInfo(spellID)

    if info then
        frame.icon:SetTexture(info.iconID or UNKNOWN_SPELL_TEXTURE)
        frame.name = info.name or "UNKNOWN"
    else
        frame.icon:SetTexture(UNKNOWN_SPELL_TEXTURE)
        frame.name = "UNKNOWN"
    end
end

-- MARK: UpdateStyle

---Update style settings and render them in-game
function CustomAuraTracker:UpdateStyle()
    local iconSize = addon.db[MOD_KEY]["IconSize"]
    local scale = addon.db[MOD_KEY]["TimeFontScale"]

    self.auras.head:SetSize(iconSize, iconSize)
    self.auras.head:SetPoint("CENTER", UIParent, "CENTER", addon.db[MOD_KEY]["X"], addon.db[MOD_KEY]["Y"])

    for _, frame in pairs(self.auras.spells) do
        frame:SetSize(iconSize, iconSize)
        frame.cooldown:SetScale(scale)
        frame:ClearAllPoints()
    end
end

-- MARK: Add Aura

---Add or update a tracked aura
---@param spellID integer the spell ID to track
---@param duration number the duration of the aura effect
---@param cooldown number the cooldown of the spell
---@param activeSound string? the sound to play when aura becomes active
---@param expireSound string? the sound to play when cooldown expires
---@return boolean isAdd true if add a new aura, false if update an existing aura
function CustomAuraTracker:AddAura(spellID, duration, cooldown, activeSound, expireSound)
    local isAdd = false
    local frame = self.auras.spells[spellID]
    if not frame then
        frame = CreateFrame("Frame", nil, self.auras.head)
        self.auras.spells[spellID] = frame
        self.auras.size = self.auras.size + 1
        isAdd = true

        frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
        frame.cooldown:SetAllPoints()
        frame.cooldown:SetDrawEdge(false)
        frame.cooldown:SetCountdownAbbrevThreshold(600)

        frame.icon = frame:CreateTexture(nil, "BACKGROUND")
        frame.icon:SetAllPoints()
        
        frame.border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        frame.border:SetAllPoints()
        frame.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
        frame.border:SetBackdropBorderColor(0, 0, 0, 1)

        frame:SetSize(addon.db[MOD_KEY]["IconSize"], addon.db[MOD_KEY]["IconSize"])
        frame.cooldown:SetScale(addon.db[MOD_KEY]["TimeFontScale"])

        self.auras.head:SetSize(math.max(self.auras.size, 1) * addon.db[MOD_KEY]["IconSize"], addon.db[MOD_KEY]["IconSize"])
    end

    if activeSound == "" then
        activeSound = nil
    end
    if expireSound == "" then
        expireSound = nil
    end

    UpdateAuraInfo(frame, spellID, duration, cooldown, activeSound, expireSound)

    return isAdd
end

-- MARK: Remove Aura

---Remove a tracked aura
---@param spellID integer the spell ID to remove from tracking
---@return boolean success true if the aura was removed successfully, false if not found
function CustomAuraTracker:RemoveAura(spellID)
    if self.auras.spells[spellID] then
        self.auras.spells[spellID]:ClearAllPoints()
        if self.auras.spells[spellID].timer then
            self.auras.spells[spellID].timer:Cancel()
            self.auras.spells[spellID].timer = nil
        end

        self.auras.spells[spellID] = nil
        return true
    end

    return false
end

-- MARK: Get Auras List

---Get a list of all tracked auras
---@return table output a table mapping spell IDs to spell names
function CustomAuraTracker:GetAurasList()
    if not self.auras.spells then
        return {}
    end

    local output = {}
    for spellID, _ in pairs(self.auras.spells) do
        output[spellID] = addon.Utilities:GetSpellIconString(spellID)
    end

    return output
end

-- MARK: Get Aura Info

---Get detailed information for a specific tracked aura
---@param spellID integer the spell ID to get information for
---@return table? info a table containing aura details, or nil if not found
function CustomAuraTracker:GetAuraInfo(spellID)
    if not self.auras.spells[spellID] then
        return nil
    end

    local frame = self.auras.spells[spellID]
    return {
        spellID = frame.spellID,
        name = frame.name,
        duration = frame.duration,
        cooldown = frame.cd,
        activeSound = frame.activeSound,
        expireSound = frame.expireSound,
    }
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function CustomAuraTracker:Test(on)
    if not addon.db[MOD_KEY]["Enabled"] then -- if the module is not enabled, do not allow test mode
        return
    end

    if on then
        self.auras.dragRegion = addon.Utilities:CreateDragBackground(self.auras.head, L["CustomAuraTrackerSettings"])

        addon.Utilities:MakeFrameDragPosition(self.auras.head, MOD_KEY, "X", "Y")
    else
        if self.auras.dragRegion then
            addon.Utilities:ReleaseDragBackground(self.auras.dragRegion)
        end
    end
end

-- MARK: RegisterEvents

---Register events
function CustomAuraTracker:RegisterEvents()
    local OnUpdate = function (...)
        local spellID  = select(3, ...)
        if self.auras.spells[spellID] then
            Handler(self, spellID)
        end
    end

    local Load = function (...)
        LoadSavedAuras(self)
    end

    addon.core:RegisterEvent(OnUpdate, "UNIT_SPELLCAST_SUCCEEDED", MOD_KEY, "player")
    addon.core:RegisterEvent(Load, "PLAYER_LOGIN", MOD_KEY)
end

-- MARK: Register Module
addon.core:RegisterModule(MOD_KEY, function() return CustomAuraTracker:Initialize() end, function() CustomAuraTracker:RegisterEvents() end)
