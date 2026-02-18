---@class CustomAuraTracker
---@field auras table a table contains loaded auras and informations
---@field auras.loaded table a table mapping spell IDs to their corresponding aura frames
---@field auras.size integer the number of loaded auras, used for calculating the size of
---@field auras.head frame the head of the showing auras linked-list, a dummy frame used for anchoring the first showing aura
---@field auras.tail frame the tail of the showing auras linked-list, nil if there is no showing aura
---@field specAuras table a table store auras for each spec to load
---@field spareFrames table a table store the spare frames that can be reused when needed
CustomAuraTracker = {
    auras = {},
    specAuras = {},
    spareFrames = {},
    lastSpec = -1,
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
    self.auras.loaded = {} -- a loaded frame pool
    self.auras.size = 0
    self.auras.head = CreateFrame("Frame", ADDON_NAME .. "_CustomAuraTracker", UIParent)
    self.auras.tail = nil
    self.specAuras = {}
    self.spareFrames = {}
    self.lastSpec = -1

    self.auras.head:Show()

    self:UpdateStyle() -- Update style on initialization, so you do not have to duplicate code of rendering style in both Initialize and UpdateStyle functions

    return self
end

-- private methods

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
    frame.active = true
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

-- MARK: Update Spec Loading

---Update spec loading map
---@param self CustomAuraTracker self
---@param newLoadingSpecs table<table<integer>> the new specialization table
---@param spellID integer the spell ID of updating specialization map
local function UpdateSpecLoading(self, newLoadingSpecs, spellID)
    for spec, auras in pairs(self.specAuras) do
        if auras[spellID] then -- if the aura is already associated
            if not newLoadingSpecs or not newLoadingSpecs[spec] then -- if the association should be removed
                self.specAuras[spec][spellID] = nil -- remove the spec association
            end
        else
            if newLoadingSpecs and newLoadingSpecs[spec] then -- if the association should be added
                self.specAuras[spec][spellID] = true -- add the spec association
            end
        end
    end
end

-- MARK: Should Load

---Check if the spell should be load by spell's loading spec map
---@param self CustomAuraTracker self
---@param loadingSpecs table<table<integer>> the loading spec map
---@return boolean success if the spell should be loaded for current spec
local function ShouldLoad(self, loadingSpecs)
    -- if loadingSpecs is nil, it means the aura is a general aura for all specs, return true directly
    if not loadingSpecs then
        return true
    end

    -- if loadingSpecs exist, return true only if current spec is in loadingSpecs
    return loadingSpecs[addon.states["playerSpec"]] or false
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
    frame.icon:SetTexCoord(addon.db[MOD_KEY]["IconZoom"], 1 - addon.db[MOD_KEY]["IconZoom"], addon.db[MOD_KEY]["IconZoom"], 1 - addon.db[MOD_KEY]["IconZoom"])
    
    frame.border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.border:SetAllPoints()
    frame.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    frame.border:SetBackdropBorderColor(0, 0, 0, 1)

    frame:SetSize(addon.db[MOD_KEY]["IconSize"], addon.db[MOD_KEY]["IconSize"])
    frame.cooldown:SetScale(addon.db[MOD_KEY]["TimeFontScale"])

    frame.active = false

    return frame
end

-- MARK: Load Aura

---Load/update an aura. Update if already loaded, otherwise load it.
---When try to load an aura, first use spared frame if exist, otherwise create a new one
---@param self CustomAuraTracker self
---@param spellID integer the spell ID of the aura
---@param duration number the duration of the aura effect
---@param cooldown number the cooldown of the spell
---@param activeSound string|nil the sound to play when aura becomes active
---@param expireSound string|nil the sound to play when aura expires
---@return boolean
local function LoadAura(self, spellID, duration, cooldown, activeSound, expireSound)
    local isAdd = false
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
        isAdd = true
    end

    -- update the frame information
    UpdateAuraInfo(frame, spellID, duration, cooldown, activeSound, expireSound)

    return isAdd
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

    table.insert(self.spareFrames, frame) -- put the frame into spare pool for later re-use
    self.auras.loaded[frame.spellID] = nil -- remove the frame from loaded pool
    self.auras.size = self.auras.size - 1
end

-- MARK: Switch Spec

---Handle after switch specialization to unload unneccessary auras and load needed auras
---@param self CustomAuraTracker self
local function SwitchSpec(self)
    local currentSpec = addon.states["playerSpec"]
    if currentSpec == self.lastSpec then return end

    local alreadyLoaded = {}

    -- delete all auras for last spec
    for spellID, _ in pairs(self.specAuras[self.lastSpec] or {}) do
        local frame = self.auras.loaded[spellID]
        if frame and not self.specAuras[currentSpec][spellID] then -- if the aura is not for current spec, hide it and put the frame into spare pool
            UnloadAura(self, frame)
        elseif frame then -- if the aura is also for current spec, just put it into alreadyLoaded for later use, no need to hide or cancel timer
            alreadyLoaded[spellID] = true
        end
    end

    -- load auras for current spec
    for spellID, _ in pairs(self.specAuras[currentSpec] or {}) do
        if not alreadyLoaded[spellID] then -- if the aura is not already loaded, load it
            local auraData = addon.db[MOD_KEY].spells[spellID] -- find aura data in the database
            if auraData then
                LoadAura(self, spellID, auraData.duration, auraData.cooldown, auraData.activeSound, auraData.expireSound)
            end
        end
    end

    -- update last spec
    self.lastSpec = currentSpec
end

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
                loadingSpecs = auraData.loadingSpecs,
            }
        end
    end

    for spellID, auraData in pairs(oldAuras) do
        addon.Utilities:print(string.format("Replace old aura data with new format: %d", addon.db[MOD_KEY].spells[auraData.index].id))
        addon.db[MOD_KEY].spells[auraData.index] = nil
        addon.db[MOD_KEY].spells[spellID] = {
            duration = auraData.duration,
            cooldown = auraData.cooldown,
            activeSound = auraData.activeSound,
            expireSound = auraData.expireSound,
            loadingSpecs = auraData.loadingSpecs,
        }
    end
end

---Load saved auras from database and initialize them
---@param self CustomAuraTracker self
local function LoadSavedAuras(self)
    local auraList = addon.db[MOD_KEY].spells
    self.lastSpec = addon.states["playerSpec"] -- set last spec to current spec when loading

    if auraList then
        HanlerOldAuraData(auraList)

        -- load auras(IDs only) for quick access when needed
        for spellID, auraData in pairs(auraList) do
            if auraData.loadingSpecs then
                for spec, _ in pairs(auraData.loadingSpecs) do
                    if not self.specAuras[spec] then
                        self.specAuras[spec] = {}
                    end

                    self.specAuras[spec][spellID] = true

                    if spec == addon.states["playerSpec"] then -- if the aura is for current spec, load it
                        LoadAura(self, spellID, auraData.duration, auraData.cooldown, auraData.activeSound, auraData.expireSound)
                    end
                end
            else -- if no spec is specified, it is a general aura for all specs, load it directly
                LoadAura(self, spellID, auraData.duration, auraData.cooldown, auraData.activeSound, auraData.expireSound)
            end
        end

        self:UpdateStyle()
    end
end

-- MARK: UpdateStyle

---Update style settings and render them in-game
function CustomAuraTracker:UpdateStyle()
    local iconSize = addon.db[MOD_KEY]["IconSize"]
    local scale = addon.db[MOD_KEY]["TimeFontScale"]

    self.auras.head:SetSize(iconSize, iconSize)
    self.auras.head:SetPoint("CENTER", UIParent, "CENTER", addon.db[MOD_KEY]["X"], addon.db[MOD_KEY]["Y"])

    for _, frame in pairs(self.auras.loaded) do
        frame:SetSize(iconSize, iconSize)
        frame.cooldown:SetScale(scale)
        frame.icon:SetTexCoord(addon.db[MOD_KEY]["IconZoom"], 1 - addon.db[MOD_KEY]["IconZoom"], addon.db[MOD_KEY]["IconZoom"], 1 - addon.db[MOD_KEY]["IconZoom"])
    end
end

-- MARK: Add Aura

---Add a new aura from option UI, all inputs are checked and pre-processed
---@param spellID integer spellID to add(key)
---@param duration number duration
---@param cooldown number cooldown
---@param activeSound string|nil LSM identifier for the active sound, nil for no sound effect
---@param expireSound string|nil LSM identifier for the expire sound, nil for no sound effect
---@param loadingSpecs table<table<integer>>|nil the spec loading map for the spell, nil for always load
---@return boolean isAdd if the aura is added successfully, false if just update the aura without adding
function CustomAuraTracker:AddAura(spellID, duration, cooldown, activeSound, expireSound, loadingSpecs)
    UpdateSpecLoading(self, loadingSpecs, spellID) -- update the spec loading

    if ShouldLoad(self, loadingSpecs) then -- if the aura should be loaded for current spec, load it    
        return LoadAura(self, spellID, duration, cooldown, activeSound, expireSound)
    end

    return false
end

-- MARK: Remove Aura

---Remove an existing aura by spellID, and unload it if it is currently loaded
---@param spellID integer spellID to remove
---@return boolean isRemoved if the aura is removed successfully, false otherwise
function CustomAuraTracker:RemoveAura(spellID)
    if self.auras.loaded[spellID] then -- if the aura is currently loaded, unload it and remove from loaded pool
        UnloadAura(self, self.auras.loaded[spellID])
        return true
    else
        if not addon.db[MOD_KEY].spells[spellID] then
            return false
        end

        return true -- if the aura is not loaded, return true let database operation runs
    end
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function CustomAuraTracker:Test(on)
    if not addon.db[MOD_KEY]["Enabled"] then -- if the module is not enabled, do not allow test mode
        return
    end

    if on then
        addon.Utilities:ShowDragRegion(self.auras.head, L["AuraSettings"])
        addon.Utilities:MakeFrameDragPosition(self.auras.head, MOD_KEY, "X", "Y")
    else
        addon.Utilities:HideDragRegion(self.auras.head)
    end
end

-- MARK: RegisterEvents

---Register events
function CustomAuraTracker:RegisterEvents()
    local OnUpdate = function (...)
        local spellID  = select(3, ...)
        if self.auras.loaded[spellID] then
            Handler(self, spellID)
        end
    end

    addon.core:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", MOD_KEY, "player", OnUpdate)
    addon.core:RegisterEvent("PLAYER_ENTERING_WORLD", MOD_KEY, nil, function ()
        LoadSavedAuras(self)
    end)
    addon.core:RegisterStateMonitor("playerSpec", MOD_KEY, function()
        SwitchSpec(self)
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(MOD_KEY, function() return CustomAuraTracker:Initialize() end, function() CustomAuraTracker:RegisterEvents() end)