local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class CustomAuraTracker
---@field auras table a table contains loaded auras and informations
---@field auras.loaded table a table mapping spell IDs to their corresponding aura frames
---@field auras.size integer the number of loaded auras, used for calculating the size of
---@field auras.head frame the head of the showing auras linked-list, a dummy frame used for anchoring the first showing aura
---@field auras.tail frame the tail of the showing auras linked-list, nil if there is no showing aura
---@field spareFrames table a table store the spare frames that can be reused when needed
---@field modName string module name for registering in core
local CustomAuraTracker = {
    modName = "CustomAuraTracker",
}

-- MARK: Constants
-- TODO: The key for the module, used for databse, core, and other things. Replace "CustomIconTracker" with your module key
local UNKNOWN_SPELL_TEXTURE = 134400

-- MARK: Initialize

---Initialize (Constructor)
---@return CustomAuraTracker CustomAuraTracker a CustomAuraTracker object
function CustomAuraTracker:Initialize()
    self.auras = {
        loaded = {},
        size = 0,
        head = CreateFrame("Frame", ADDON_NAME .. "_CustomAuraTracker", UIParent),
        tail = nil,
    }
    self.spareFrames = {}

    self.auras.head:Show()

    return self
end

-- private methods

-- MARK: Show Aura

---Set showing auras
---@param self CustomAuraTracker self
---@param frame frame the frame of the aura to show
local function ShowAura(self, frame)
    local anchorFrom, anchorTo = addon.Utilities:GetGrowAnchors(addon.db[self.modName]["Grow"])

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
    frame.active = true
    frame:Show()
end

-- MARK: Hide Aura

---Hide aura and relink the showing auras chain
---@param self CustomAuraTracker self
---@param frame frame the frame of the aura to hide
local function HideAura(self, frame)
    local anchorFrom, anchorTo = addon.Utilities:GetGrowAnchors(addon.db[self.modName]["Grow"])

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
    frame.active = false
    frame:Hide()
end

-- MARK: Handler

---Handler for CustomAuraTracker when a tracked spell is cast
---@param self CustomAuraTracker self
---@param spellID integer the spell ID that was cast
local function Handler(self, spellID)
    local frame = self.auras.loaded[spellID]
    if frame then
        if frame.timer then
            frame.timer:Cancel()
            frame.timer = nil
        end

        local duration = addon.db[self.modName].spells[spellID].duration
        local activeSound = addon.db[self.modName].spells[spellID].activeSound
        local soundChannel = addon.db[self.modName]["SoundChannel"] or "Master"

        frame:Show()
        ShowAura(self, frame)
        frame.cooldown:SetCooldown(GetTime(), duration)
        if activeSound then
            PlaySoundFile(addon.LSM:Fetch("sound", activeSound), soundChannel)
        end

        -- after duration
        frame.timer = C_Timer.NewTimer(duration, function()
            HideAura(self, frame)
            local cooldown = addon.db[self.modName].spells[spellID].cooldown
            -- set cooldown timer, make a callback after cooldown to play ready sound if exist
            frame.timer = C_Timer.NewTimer(math.max(cooldown - duration, 0), function()
                local expireSound = addon.db[self.modName].spells[spellID].expireSound
                if expireSound then
                    PlaySoundFile(addon.LSM:Fetch("sound", expireSound), soundChannel)
                end
                frame.timer = nil
            end)
        end)
    end
end

-- MARK: Should Load

---Check if the aura should be load
---@param self CustomAuraTracker
---@param spellID integer spell id
---@return boolean shouldLoad if the aura should be loaded, false otherwise
local function ShouldLoad(self, spellID)
    local loadingSpecs = addon.db[self.modName].spells[spellID].loadingSpecs
    return not loadingSpecs or loadingSpecs[addon.states["playerSpec"]]
end

-- MARK: Update Aura Info

---Update aura information for a frame
---@param frame frame the frame to update
---@param spellID integer the spell ID
local function UpdateAuraInfo(frame, spellID)
    frame.spellID = spellID -- keep spellID for unregistering
    frame.icon:SetTexture(C_Spell.GetSpellInfo(spellID).iconID or UNKNOWN_SPELL_TEXTURE)
end

-- MARK: Create New Frame

---Create a new frame in this module when needed
---@param self CustomAuraTracker self
---@return frame frame a new frame created
local function CreateNewFrame(self)
    local frame = CreateFrame("Frame", nil, self.auras.head)
    frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.cooldown:SetAllPoints()
    frame.cooldown:SetDrawEdge(false)
    frame.cooldown:SetCountdownAbbrevThreshold(600)
    frame.cooldown:SetReverse(true)

    frame.icon = frame:CreateTexture(nil, "BACKGROUND")
    frame.icon:SetAllPoints()
    frame.icon:SetTexCoord(addon.db[self.modName]["IconZoom"], 1 - addon.db[self.modName]["IconZoom"], addon.db[self.modName]["IconZoom"], 1 - addon.db[self.modName]["IconZoom"])
    
    frame.border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.border:SetAllPoints()
    frame.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    frame.border:SetBackdropBorderColor(0, 0, 0, 1)

    frame:SetSize(addon.db[self.modName]["IconSize"], addon.db[self.modName]["IconSize"])
    frame.cooldown:SetScale(addon.db[self.modName]["TimeFontScale"])

    frame.active = false
    frame.timer = nil

    return frame
end

-- MARK: Load Aura

---Load/update an aura. Update if already loaded, otherwise load it.
---When try to load an aura, first use spared frame if exist, otherwise create a new one
---@param self CustomAuraTracker self
---@param spellID integer the spell ID of the aura
local function LoadAura(self, spellID)
    local frame = self.auras.loaded[spellID] -- try to find the frame in loaded pool

    if not frame then -- if the frame is not loaded
        if self.spareFrames[#self.spareFrames] then -- try to re-use spare frames
            -- pop the last spare frame to reduce the table.remove() run-time
            frame = table.remove(self.spareFrames, #self.spareFrames)
        else -- if no spare frame, create new one
            frame = CreateNewFrame(self)
        end

        -- set the frame to loaded pool and update the size
        self.auras.loaded[spellID] = frame
        self.auras.size = self.auras.size + 1
    end

    -- update the frame information
    UpdateAuraInfo(frame, spellID)
end

-- MARK: Unload Aura

---Unload an aura
---@param self CustomAuraTracker self
---@param frame frame the aura to unload
local function UnloadAura(self, frame)
    if frame.active then
        HideAura(self, frame)
    end

    if frame.timer then
        frame.timer:Cancel()
        frame.timer = nil
    end

    frame.icon:SetTexture(UNKNOWN_SPELL_TEXTURE)

    table.insert(self.spareFrames, frame) -- put the frame into spare pool for later re-use
    self.auras.loaded[frame.spellID] = nil -- remove the frame from loaded pool
    self.auras.size = self.auras.size - 1
end

-- MARK: Switch Spec

---Handle after switch specialization to unload unneccessary auras and load needed auras
---@param self CustomAuraTracker self
local function SwitchSpec(self)
    local alreadyLoaded = {}

    for spellID, frame in pairs(self.auras.loaded) do -- go over all loaded auras
        if ShouldLoad(self, spellID) then -- if the aura should be loaded for current spec
            alreadyLoaded[spellID] = true
        else -- otherwise, unload the aura that is not needed for current spec
            UnloadAura(self, frame)
        end
    end

    for spellID, auraData in pairs(addon.db[self.modName].spells) do -- go over all auras in the databse
        -- if the aura should be loaded for current spec but is not loaded yet, load it
        if ShouldLoad(self, spellID) and not alreadyLoaded[spellID] then
            LoadAura(self, spellID)
        end
    end
end

-- MARK: Handle Old Data

---Handle old data(3.6.0 - 3.6.1)
---@param self CustomAuraTracker self
---@param auraList any
local function HanlerOldAuraData(self, auraList)
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
                loadingSpecs = auraData.loadingSpecs,
            }
        end
    end

    for spellID, auraData in pairs(oldAuras) do
        addon.Utilities:print(string.format("Replace old aura data with new format: %d", addon.db[self.modName].spells[auraData.index].id))
        addon.db[self.modName].spells[auraData.index] = nil
        addon.db[self.modName].spells[spellID] = {
            duration = auraData.duration,
            cooldown = auraData.cooldown,
            activeSound = auraData.activeSound,
            expireSound = auraData.expireSound,
            loadingSpecs = auraData.loadingSpecs,
        }
    end
end

-- MARK: Load Saved Auras

---Load saved auras from database and initialize them
---@param self CustomAuraTracker self
local function LoadSavedAuras(self)
    local auraList = addon.db[self.modName].spells
    self.lastSpec = addon.states["playerSpec"] -- set last spec to current spec when loading

    if auraList then
        HanlerOldAuraData(self, auraList)

        for spellID, auraData in pairs(auraList) do
            -- if the aura should be loaded for current spec, load it
            -- nil loadingSpecs means load for all specs, otherwise only load when current spec is in loadingSpecs
            if ShouldLoad(self, spellID) then
                LoadAura(self, spellID)
            end
        end

        self:UpdateStyle()
    end
end

-- MARK: UpdateStyle

---Update style settings and render them in-game
function CustomAuraTracker:UpdateStyle()
    local iconSize = addon.db[self.modName]["IconSize"]
    local scale = addon.db[self.modName]["TimeFontScale"]

    self.auras.head:SetFrameStrata(addon.db[self.modName]["FrameStrata"] or "MEDIUM")
    self.auras.head:SetSize(iconSize, iconSize)
    self.auras.head:SetPoint("CENTER", UIParent, "CENTER", addon.db[self.modName]["X"], addon.db[self.modName]["Y"])

    for _, frame in pairs(self.auras.loaded) do
        frame:SetSize(iconSize, iconSize)
        frame.cooldown:SetScale(scale)
        frame.icon:SetTexCoord(addon.db[self.modName]["IconZoom"], 1 - addon.db[self.modName]["IconZoom"], addon.db[self.modName]["IconZoom"], 1 - addon.db[self.modName]["IconZoom"])
    end

    for _, frame in pairs(self.spareFrames) do -- need to update for the spare frames as well to make sure the style is correct when they are re-used
        frame:SetSize(iconSize, iconSize)
        frame.cooldown:SetScale(scale)
        frame.icon:SetTexCoord(addon.db[self.modName]["IconZoom"], 1 - addon.db[self.modName]["IconZoom"], addon.db[self.modName]["IconZoom"], 1 - addon.db[self.modName]["IconZoom"])
    end
end

-- MARK: Handle Add Aura

---Handle the aura added or updated
---@param spellID integer spellID
function CustomAuraTracker:HandleAddAura(spellID)
    if ShouldLoad(self, spellID) then -- if the aura should be loaded for current spec, load it    
        LoadAura(self, spellID)
    else -- should not be loaded
        if self.auras.loaded[spellID] then -- if the aura is currently loaded but should not be loaded, unload it
            UnloadAura(self, self.auras.loaded[spellID])
        end
    end
end

-- MARK: Handle Remove Aura

---Handle the aura removed
---@param spellID integer spellID
function CustomAuraTracker:HandleRemoveAura(spellID)
    if self.auras.loaded[spellID] then -- if the aura is currently loaded, unload it and remove from loaded pool
        UnloadAura(self, self.auras.loaded[spellID])
    end
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function CustomAuraTracker:Test(on)
    if not addon.db[self.modName]["Enabled"] then -- if the module is not enabled, do not allow test mode
        return
    end

    if on then
        addon.Utilities:ShowDragRegion(self.auras.head, L["CustomAuraTrackerSettings"])
        addon.Utilities:MakeFrameDragPosition(self.auras.head, self.modName, "X", "Y")
    else
        addon.Utilities:HideDragRegion(self.auras.head)
    end
end

-- MARK: RegisterEvents

---Register events
function CustomAuraTracker:RegisterEvents()
    local function OnEvent(_, event, ...)
        if event == "UNIT_SPELLCAST_SUCCEEDED" then
            local spellID  = select(3, ...)
            if self.auras.loaded[spellID] then
                Handler(self, spellID)
            end
        elseif event == "PLAYER_ENTERING_WORLD" then
            LoadSavedAuras(self)
        end
    end

    addon.core:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self.auras.head, self.modName, "player")
    addon.core:RegisterEvent("PLAYER_ENTERING_WORLD", self.auras.head, self.modName)
    addon.core:RegisterStateMonitor("playerSpec", self.modName, function() SwitchSpec(self) end)

    self.auras.head:SetScript("OnEvent", OnEvent)
end

-- MARK: Register Module
addon.core:RegisterModule(CustomAuraTracker.modName, function() return CustomAuraTracker:Initialize() end)