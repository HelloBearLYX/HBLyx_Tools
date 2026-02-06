---@class CustomSpellAlert
CustomSpellAlert = {
    spells = {},
    head = nil, -- use two-head/tail linked list to keep
    tail = nil,
    showIcons = {},
    anchor = "",
    anchorParent = "",
}

local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

-- Constants
local MOD_KEY = "CustomSpellAlert"
local UNKNOWN_SPELL_TEXTURE = 134400

-- MARK: Initialize

---Initialize(Constructor)
---@return CustomSpellAlert customSpellAlert
function CustomSpellAlert:Initialize()
    if not addon.db[MOD_KEY]["Enabled"] then
        return nil
    end

    if addon.db[MOD_KEY]["Grow"] == "RIGHT" then
        self.anchor = "LEFT"
        self.anchorParent = "RIGHT"
    elseif addon.db[MOD_KEY]["Grow"] == "UP" then
        self.anchor = "BOTTOM"
        self.anchorParent = "TOP"
    elseif addon.db[MOD_KEY]["Grow"] == "DOWN" then
        self.anchor = "TOP"
        self.anchorParent = "BOTTOM"
    else
        self.anchor = "RIGHT"
        self.anchorParent = "LEFT"
    end

    self.spells = {}
    self.head = CreateFrame("Frame", ADDON_NAME .. "_" .. MOD_KEY, UIParent)
    self.head:SetFrameStrata("LOW")

    for id, info in pairs(addon.db[MOD_KEY]["Spells"]) do
        self:AddSpell(id, info["duration"], info["cooldown"])
    end

    self:UpdateStyle()

    return self
end

-- private methods

-- MARK: Handler

local function StartDuration(frame)
    frame.cooldown:SetHideCountdownNumbers(false)
    frame.cooldown:SetCooldown(GetTime(), frame.duration)
    frame.icon:SetDesaturated(false)
    frame.cooldown:SetReverse(true)

    if frame.activeSound and frame.activeSound ~= "" then
        PlaySoundFile(addon.LSM:Fetch("sound", frame.activeSound), "Master")
    end
end

local function EndCooldown(frame)
    frame.cooldown:SetCooldown(0, 0)
    frame.cooldown:SetHideCountdownNumbers(true)
    frame.icon:SetDesaturated(false)

    if frame.afterCDSound and frame.afterCDSound ~= "" then
        PlaySoundFile(addon.LSM:Fetch("sound", frame.afterCDSound), "Master")
    end
end

local function StartCooldown(frame)
    frame.cooldown:SetHideCountdownNumbers(false)
    frame.cooldown:SetCooldown(GetTime(), frame.cd - frame.duration)
    frame.icon:SetDesaturated(true)
    frame.cooldown:SetReverse(false)

    frame.timer = C_Timer.NewTimer(frame.cd - frame.duration, function ()
        EndCooldown(frame)
    end)
end

local function Handler(frame)
    if frame.timer then
        frame.timer:Cancel()
        frame.timer = nil
    end

    StartDuration(frame)
    frame.timer = C_Timer.NewTimer(frame.duration, function ()
        StartCooldown(frame)
    end)
end

-- public methods

-- MARK: UpdateStyle

function CustomSpellAlert:UpdateStyle()
    self.head:SetSize(addon.db[MOD_KEY]["IconSize"] * addon.db[MOD_KEY]["DisplayNum"], addon.db[MOD_KEY]["IconSize"])
    self.head:SetPoint(self.anchor, UIParent, "CENTER", addon.db[MOD_KEY]["X"], addon.db[MOD_KEY]["Y"])

    for _, frame in pairs(self.spells) do
        frame:SetSize(addon.db[MOD_KEY]["IconSize"], addon.db[MOD_KEY]["IconSize"])
        frame.cooldown:SetScale(addon.db[MOD_KEY]["TimeFontScale"])
        frame.icon:SetTexCoord(addon.db[MOD_KEY]["IconZoom"], 1 - addon.db[MOD_KEY]["IconZoom"], addon.db[MOD_KEY]["IconZoom"], 1 - addon.db[MOD_KEY]["IconZoom"])
    end
end

-- MARK: UpdateSpellInfo

function CustomSpellAlert:UpdateSpellInfo(id, duration, cd, activeSound, afterCDSound)
    if type(id) ~= "number" or type(duration) ~= "number" or type(cd) ~="number" or type(activeSound) ~= "string" or type(afterCDSound) ~= "string" 
    or not self.spells[id] then -- or do not contains it
        return false
    end

    self.spells[id].duration = duration
    self.spells[id].cd = cd
    self.spells[id].timer = nil

    if activeSound ~= "" then
        self.spells[id].activeSound = activeSound
    end
    if afterCDSound ~= "" then
        self.spells[id].afterCDSound = afterCDSound
    end
end

-- MARK: AddSpell

function CustomSpellAlert:AddSpell(id, duration, cd, activeSound, afterCDSound)
    if type(id) ~= "number" or type(duration) ~= "number" or type(cd) ~="number" or type(activeSound) ~= "string" or type(afterCDSound) ~= "string"
    or self.spells[id] then -- or already constains it
        return false
    end

    local frame
    if not self.tail then -- first element
        frame = CreateFrame("Frame", nil, self.head)
        frame:SetPoint(self.anchor, self.head, self.anchor, 0, 0)
        frame.prev = self.head
        self.head.next = frame
        frame.next = nil
        self.tail = frame
    else
        frame = CreateFrame("Frame", nil, self.tail)
        frame:SetPoint(self.anchor, self.tail, self.anchorParent, 0, 0)
        frame.prev = self.tail
        self.tail.next = frame
        frame.next = nil
        self.tail = frame
    end

    -- cooldown
    frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.cooldown:SetAllPoints()
    frame.cooldown:SetDrawEdge(false)
    frame.cooldown:SetCountdownAbbrevThreshold(300)

    --icon
    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetAllPoints()
    frame.icon:SetTexture(C_Spell.GetSpellInfo(id).iconID or UNKNOWN_SPELL_TEXTURE)

    -- borders
    frame.border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.border:SetAllPoints()
    frame.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    frame.border:SetBackdropBorderColor(0, 0, 0, 1)

    frame:Show()
    self.spells[id] = frame

    self:UpdateSpellInfo(id, duration, cd, activeSound, afterCDSound)

    return true
end

-- MARK: DeleteSpell

function CustomSpellAlert:DeleteSpell(id)
    if type(id) ~= "number" or not self.spells[id] then
        return false
    end

    self.spells[id].next:SetPoint(self.anchor, self.spells[id].prev, self.anchorParent, 0, 0)

    self.spells[id].prev.next = self.spells[id].next
    self.spells[id].next.prev = self.spells[id].prev
    self.spells[id] = nil

    return true
end

-- MARK: Test

function CustomSpellAlert:Test(on)
    if on then
         
    else

    end
end

-- MARK: Register Events

function CustomSpellAlert:RegisterEvents()
    addon.eventsHandler:Register(function (_, ...)
        local _, _, spellID = ...
        if not self.spells[spellID] then
            return
        end

        Handler(self.spells[spellID])
    end, "UNIT_SPELLCAST_SUCCEEDED", MOD_KEY, "player")
end