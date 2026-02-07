---@class FocusInterrupt
---@field frame frame frame for FocusInterrupt cast bar
---@field active boolean if the FocusInterrupt active
---@field interruptID integer interrupt id
---@field subInterrupt integer? if there is a second interrupt
---@field timer C_Timer? timer to handle interrupt fade out
---@field cooldownColer ColorMixin? color for interrupt on cooldown cast
---@field interruptibleColor ColorMixin? color for interruptible cast
---@field notInterruptibleColor ColorMixin? color for NOT interruptible cast
---@field interruptedColor ColorMixin? color for interrupted fade time
FocusInterrupt = {
    frame = nil,
    active = false,
    interruptID = nil,
    subInterrupt = nil,
    timer = nil,
    cooldownColor = nil,
    interruptibleColor = nil,
    notInterruptibleColor = nil,
    interruptedColor = nil,
    kickIcon = nil,
    subKickIcon = nil,
}

local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

-- MARK: Constants
local MOD_KEY = "FocusInterrupt"
local UNKNOWN_SPELL_TEXTURE = 134400
local INTERRUPT_BY_CLASS = {
  DEATHKNIGHT = {DEFAULT = 47528}, -- Mind Freeze
  DEMONHUNTER = {DEFAULT = 183752}, -- Disrupt
  DRUID = {BALANCE = 78675, DEFAULT = 106839},
  EVOKER = {DEFAULT = 351338}, -- Quell
  HUNTER = {DEFAULT = 147362, SURVIVAL = 187707},
  MAGE = {DEFAULT = 2139}, -- Counterspell
  MONK = {DEFAULT = 116705}, -- Spear Hand Strike
  PALADIN = {DEFAULT = 96231}, -- Rebuke
  PRIEST = {DEFAULT = 15487}, -- Silence
  ROGUE = {DEFAULT = 1766}, -- Kick
  SHAMAN = {DEFAULT = 57994}, -- Wind Shear
  WARLOCK = {DEFAULT = 19647, DEMONOLOGY = 119914, DEMONOLOGY_SUB = 132409, GRIMOIRE = 1276467},
  WARRIOR = {DEFAULT = 6552}, -- Pummel
}

-- MARK: Initialize

---Initialize(Constructor)
---@return FocusInterrupt FocusInterrupt a FocusInterrupt object
function FocusInterrupt:Initialize()
    if not addon.db[MOD_KEY]["Enabled"] then
        return nil
    end

    self.frame = CreateFrame("Frame", ADDON_NAME .. "_FocusCastBar", UIParent)
    self.frame:SetFrameStrata("HIGH")
    self.frame:Hide()

    self.frame.background = self.frame:CreateTexture(nil, "background")
    self.frame.background:SetAllPoints()

    self.frame.border = CreateFrame("Frame", nil, self.frame, "BackdropTemplate")
    self.frame.border:SetAllPoints()
    self.frame.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    self.frame.border:SetFrameLevel(self.frame:GetFrameLevel() + 10)
    self.frame.border:SetBackdropBorderColor(0, 0, 0, 1)

    self.frame.icon = self.frame:CreateTexture(nil, "ARTWORK")
    self.frame.icon:SetPoint("LEFT", self.frame, "LEFT", 0, 0)

    self.frame.statusBar = CreateFrame("StatusBar", nil, self.frame)
    self.frame.statusBar:SetMinMaxValues(0, 1)
    self.frame.statusBar:SetValue(0)
    self.frame.statusBar:SetPoint("RIGHT", self.frame, "RIGHT")

    -- frame which takes texts
    self.frame.textFrame = CreateFrame("Frame", nil, self.frame)
    self.frame.textFrame:SetAllPoints()
    self.frame.textFrame:SetFrameLevel(self.frame:GetFrameLevel() + 10)
    -- set spell text
    self.frame.spellText = self.frame.textFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    self.frame.spellText:SetJustifyH("LEFT")
    self.frame.spellText:SetTextColor(1, 1, 1, 1)
    -- set time text
    self.frame.timeText = self.frame.textFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    self.frame.timeText:SetPoint("RIGHT", self.frame, "RIGHT", 0, 0)
    self.frame.timeText:SetJustifyH("RIGHT")
    self.frame.timeText:SetTextColor(1, 1, 1, 1)

    self.active = false
    self.subInterrupt = nil
    self:UpdateStyle()

    return self
end

-- private methods

-- MARK: Get Interrupt ID

---Get interruptID depending on class and spec of the player
---@param self FocusInterrupt self
---@param class string Upper-case class string
---@return integer interruptID the interrupt spell ID
local function GetInterruptSpellID(self, class)
    local output = INTERRUPT_BY_CLASS[class].DEFAULT
    self.subInterrupt = nil

    if class == "WARLOCK" then -- warlock has the complex cases handle it
        -- specID: AFFLICTION = 1, DEMONOLOGY = 2, DESTRUCTION = 3
        local spec = GetSpecialization()
        if spec == 2 then
            self.subInterrupt = INTERRUPT_BY_CLASS[class].DEMONOLOGY_SUB
            output = INTERRUPT_BY_CLASS[class].DEMONOLOGY
        end
    elseif class == "HUNTER" then -- hunter has the complex cases handle it
        -- specID: BEASTMASTERY = 1, MARKSMANSHIP = 2, SURVIVAL = 3
        local spec = GetSpecialization()
        if spec == 3 then
            output = INTERRUPT_BY_CLASS[class].SURVIVAL
        end
    elseif class == "DRUID" then -- druid has the complex cases handle it
        -- specID: BALANCE = 1, FERAL = 2, GUARDIAN = 3, RESTORATION = 4
        local spec = GetSpecialization()
        if spec == 1 then
            output = INTERRUPT_BY_CLASS[class].BALANCE
        end
    end

    return output
end

-- MARK: SetBarColor

---Set statusBar color for the cast
---@param self FocusInterrupt self
---@param interrupted boolean is cast interrupted already(never use secret-value)
---@param notInterruptible boolean is Not-interruptible cast
---@param isInterruptReady boolean is Interrupt ready
---@param subInterruptReady boolean? is subInterrupt ready(optional)
local function SetBarColor(self, interrupted, notInterruptible, isInterruptReady, subInterruptReady)
    local color = C_CurveUtil.EvaluateColorFromBoolean(interrupted, self.interruptedColor, self.interruptibleColor)

    -- also secret-value comparation operations: See details in Update() -> Hidden-Control
    color = C_CurveUtil.EvaluateColorFromBoolean(isInterruptReady, color, self.cooldownColor)

    if self.subInterrupt then
        color = C_CurveUtil.EvaluateColorFromBoolean(subInterruptReady, self.interruptibleColor, color)
    end

    color = C_CurveUtil.EvaluateColorFromBoolean(notInterruptible, self.notInterruptibleColor, color)

    self.frame.statusBar:GetStatusBarTexture():SetVertexColor(color:GetRGBA())
end

---Get Interrupter from GUID
---@param guid integer GUID for the interrupter
---@return string name name of the interrupter
---@return string class class of the interrupter
local function GetInterrupter(guid)
    local name, class
    name = UnitNameFromGUID(guid)
    _, class = GetPlayerInfoByGUID(guid)
    
    return name, class
end

---Update interrupt icons, make sure icons are instantialized before use this
---@param self FocusInterrupt self
local function UpdateIcons(self)
    local anchorFrom, anchorTo = addon.Utilities:GetAnchorFrom(addon.db[MOD_KEY]["KickIconAnchor"]), addon.db[MOD_KEY]["KickIconAnchor"]
    local anchorChild, anchorParent = addon.Utilities:GetGrowAnchors(addon.db[MOD_KEY]["KickIconGrow"])

    self.kickIcon:SetSize(addon.db[MOD_KEY]["KickIconSize"], addon.db[MOD_KEY]["KickIconSize"])
    self.kickIcon:SetPoint(anchorFrom, self.frame, anchorTo, 0, 0)
    self.kickIcon.icon:SetTexCoord(
        addon.db[MOD_KEY]["IconZoom"],
        1 - addon.db[MOD_KEY]["IconZoom"],
        addon.db[MOD_KEY]["IconZoom"],
        1 - addon.db[MOD_KEY]["IconZoom"]
    )
    
    self.subKickIcon:SetSize(addon.db[MOD_KEY]["KickIconSize"], addon.db[MOD_KEY]["KickIconSize"])
    self.subKickIcon:SetPoint(anchorChild, self.kickIcon, anchorParent, 0, 0)
    self.subKickIcon.icon:SetTexCoord(
        addon.db[MOD_KEY]["IconZoom"],
        1 - addon.db[MOD_KEY]["IconZoom"],
        addon.db[MOD_KEY]["IconZoom"],
        1 - addon.db[MOD_KEY]["IconZoom"]
    )
end

--MARK: SetInterruptIcons

---Set Interrupt Icons if needed
---@param self FocusInterrupt self
---@param notInterruptible boolean if the cast is not-interruptible
---@param isInterruptReady boolean if the interrupt ready
---@param subInterruptReady boolean? if the sub-interrupt ready
local function SetInterruptIcons(self, notInterruptible, isInterruptReady, subInterruptReady)
    if self.kickIcon then
        self.kickIcon:SetAlphaFromBoolean(isInterruptReady)
        self.kickIcon:SetAlphaFromBoolean(notInterruptible, 0, self.kickIcon:GetAlpha())

        if self.subInterrupt then
            self.subKickIcon:SetAlphaFromBoolean(subInterruptReady)
            self.subKickIcon:SetAlphaFromBoolean(notInterruptible, 0, self.subKickIcon:GetAlpha())
        end
    end
end

-- MARK: Interrupt Handle

---Interrupt Hanlder
---@param self FocusInterrupt self
---@param guid integer the GUID of the interrupter
local function InterruptHandler(self, guid)
    local interrupter, class = GetInterrupter(guid)
    local color = C_ClassColor.GetClassColor(class):GenerateHexColor() or "FFFFFF" -- also secret-value

    if addon.db[MOD_KEY]["ShowInterrupter"] then
        self.frame.spellText:SetText(L["Interrupted"] .. ": |c".. color .. interrupter .. "|r")
    else
        self.frame.spellText:SetText(L["Interrupted"])
    end
    SetBarColor(self, true, false, true) -- change color to interrupted color
    self.active = false

    if self.timer then
        self.timer:Cancel()
    end

    self.timer = C_Timer.NewTimer(addon.db[MOD_KEY]["InterruptedFadeTime"], function ()
        self.timer = nil
        self.frame:Hide()
        SetBarColor(self, false, false, true) -- reset color
    end)
end

-- MARK: Update

---Handle Casts by passed information
---@param self FocusInterrupt self
---@param duration LuaDurationObject Blizzard's LuaDurationObject
---@param isChannel boolean if the cast is a channel cast
local function Update(self, duration, isChannel, notInterruptible)
    -- after 3.2, self.active is still significant to halt update, but control it in RegisterEvent instead of handler
    if not self.active then
        return
    end

    -- get remaining time by cast types
    local remaining
    if isChannel then
        remaining = duration:GetRemainingDuration()
    else
        remaining = duration:GetElapsedDuration()
    end

    -- update statusBar
    self.frame.statusBar:SetValue(remaining)
    
    -- update time text
    -- considering remove total duration text
    if addon.db[MOD_KEY]["ShowTotalTime"] then
        self.frame.timeText:SetText(string.format("%.1f/%.1f", duration:GetRemainingDuration(), duration:GetTotalDuration()))
    else
        self.frame.timeText:SetText(string.format("%.1f", duration:GetRemainingDuration()))
    end

    -- general interrupt cooldown check
    local isInterruptReady = C_Spell.GetSpellCooldownDuration(self.interruptID):IsZero()
    
    -- for Demonology Warlocks/Two interrupts specs
    -- since the GRIMOIRE is also a kick, this part can only used for Demo Warlock so far. Prot Paladin cannot use this as GCD issue(IsZero includes GCD)
    local subInterruptReady
    if self.subInterrupt then
        -- the SpellLock(player version) is obtained to the SpellBook after used GRIMOIRE
        if not C_SpellBook.IsSpellInSpellBook(self.subInterrupt) then -- if SpellLock not in SpellBook-> GRIMOIRE not used yet/GRIMOIRE not learned(ignore it)
            -- if GRIMOIRE in SpellBook -> GRIMOIRE not on cooldown yet -> also a sub-interrupt ready
            subInterruptReady = C_SpellBook.IsSpellInSpellBook(INTERRUPT_BY_CLASS["WARLOCK"]["GRIMOIRE"])
        else -- SpellLock(player version) is in SpellBook -> GRIMOIRE used
            -- check SpellLock(player version)
            subInterruptReady = C_Spell.GetSpellCooldownDuration(self.subInterrupt):IsZero()
        end
    end

    -- handle colors for the statusBar
    -- after 3.2 use color constrol instead of overlays
    SetBarColor(self, false, notInterruptible, isInterruptReady, subInterruptReady)

    -- handle interrupt icons
    SetInterruptIcons(self, notInterruptible, isInterruptReady, subInterruptReady)

    -- Hidden-Control
        -- As secret-value cannot compute, even compare between secret-values are not allowed
        -- use func(bool, trueVal, falseVal) to replace not/and/or
        -- NOT: reverse the values, then
            -- func(bool, trueVal = falseVal, falseVal = trueVal)
        -- AND: any false is false -> need currentVal = value after first bool execution, then
            -- func(bool, trueVal = trueVal, falseVal = falseVal) + func(bool, trueVal = currentVal, falseVal = falseVal)
        -- OR: any true is true -> need currentVal = value after first bool execution, then
            -- func(bool, trueVal = trueVal, falseVal = falseVal) + func(bool, trueVal = trueVal, falseVal = currentVal)
    if addon.db[MOD_KEY]["CooldownHide"] then
        -- func(isInterruptReady or subInterruptReady, show, hide)
            -- func = Region:SetAlphaFromBoolean(bool, trueVal, falseVal)
            -- show = 255
            -- hide = 0
            -- currentVal = self.frame:GetAlpha()
        self.frame:SetAlphaFromBoolean(isInterruptReady) -- func(isInterruptReady, show, hide)
        if self.subInterrupt then
            self.frame:SetAlphaFromBoolean(subInterruptReady, 255, self.frame:GetAlpha()) -- func(subInterruptReady, show, currentVal)
        end
    end

    if addon.db[MOD_KEY]["NotInterruptibleHide"] then
        -- func(any(InterruptReady) and not notInterruptible, show hide)
            -- any(InterruptReady) is above, then func(not notInterruptible, currentVal, hide)
            -- then, func(notInterruptible, hide, currentVal)
        self.frame:SetAlphaFromBoolean(notInterruptible, 0, self.frame:GetAlpha())
    end
end

-- MARK: Update InterruptID

---Update FocusInterrupt's interruptID
---@param self FocusInterrupt self
local function UpdateInterruptId(self)
    self.interruptID = GetInterruptSpellID(self, addon.Global["characterClass"])
    
    if addon.db[MOD_KEY]["ShowKickIcons"] and (not addon.db[MOD_KEY]["ShowDemoWarlockOnly"] or (addon.db[MOD_KEY]["ShowDemoWarlockOnly"] and self.subInterrupt ~= nil)) then
        self.kickIcon = CreateFrame("Frame", nil, self.frame)
        self.kickIcon.border = CreateFrame("Frame", nil, self.kickIcon, "BackdropTemplate")
        self.kickIcon.border:SetAllPoints()
        self.kickIcon.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
        self.kickIcon.border:SetBackdropBorderColor(0, 0, 0, 1)
        self.kickIcon.icon = self.kickIcon:CreateTexture(nil, "ARTWORK")
        self.kickIcon.icon:SetAllPoints()

        self.subKickIcon = CreateFrame("Frame", nil, self.frame)
        self.subKickIcon.border = CreateFrame("Frame", nil, self.subKickIcon, "BackdropTemplate")
        self.subKickIcon.border:SetAllPoints()
        self.subKickIcon.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
        self.subKickIcon.border:SetBackdropBorderColor(0, 0, 0, 1)
        self.subKickIcon.icon = self.subKickIcon:CreateTexture(nil, "ARTWORK")
        self.subKickIcon.icon:SetAllPoints()
        self.subKickIcon:Hide()

        self.kickIcon.icon:SetTexture(addon.Utilities:SpellToIcon(self.interruptID) or UNKNOWN_SPELL_TEXTURE)
        
        if self.subInterrupt then
            self.subKickIcon.icon:SetTexture(addon.Utilities:SpellToIcon(self.subInterrupt) or UNKNOWN_SPELL_TEXTURE)
            self.subKickIcon:Show()
        else
            self.subKickIcon:Hide()
        end

        UpdateIcons(self)
    else
        if self.kickIcon then
            self.kickIcon:Hide()
            self.subKickIcon:Hide()
            self.kickIcon = nil
            self.subKickIcon = nil
        end
    end
end

-- MARK: Handler

---Handler for FocusInterrupt
---@param self FocusInterrupt self
local function Handler(self)
    -- after 3.2 self.active is handled in RegisterEvent part, although self.active is still a key variable for Update(CastHandler)
    if not addon.db[MOD_KEY]["Enabled"] then
        self.frame:Hide()
        return
    end

    -- auto detemine isChannel and handle focus change situation
    -- check if this cast is a channel cast -> check if it is a cast
    local name, _, texture, _, _, _, notInterruptible, _ = UnitChannelInfo("focus")
    local isChannel = false
    if name then -- channel cast
        isChannel = true
    else -- NOT channel
        name, _, texture, _, _, _, _, notInterruptible, _ =  UnitCastingInfo("focus")
    end
    
    if not name then -- not a cast (for switching focus to a new unit)
        -- if the new focus is not casting, halt it 
        self.active = false
        self.frame:Hide()
        return
    end

    -- get duration according to cast types
    local duration
    if isChannel then
        duration = UnitChannelDuration("focus")
    else
        duration = UnitCastingDuration("focus")
    end

    -- handle target
    -- channel target is not naturally provided through API, a complicated way is to use focus's target but involves more events and too much excessive information
    local target = UnitSpellTargetName("focus") -- only attempt to get non-channel cast target
    if addon.db[MOD_KEY]["ShowTarget"] and target then
        local color = C_ClassColor.GetClassColor(UnitSpellTargetClass("focus")):GenerateHexColor() or "FFFFFF" -- 8 digits Hex(also secret-value, do not directly compute it)
        self.frame.spellText:SetText(string.format("%.16s", name) .. "-" .. "|c" .. color .. target .. "|r")
    else
        self.frame.spellText:SetText(name)
    end

    -- handle icon
    self.frame.icon:SetTexture(texture or UNKNOWN_SPELL_TEXTURE)

    -- set the max time earlier for performance
    self.frame.statusBar:SetMinMaxValues(0, duration:GetTotalDuration())

    -- still use "OnUpdate", as there are many things we need to keep real-time update
    -- attempted to restrict the refresh rate(update interval), but a smooth function is highly demanded for it -> temperarily gave it up
    self.frame:SetScript("OnUpdate", function (_, _)
        Update(self, duration, isChannel, notInterruptible)
    end)

    -- use alpha hiden instead of Hide() to prevent bugs on any hooked script or potential future hooked script
    self.frame:SetAlphaFromBoolean(addon.db[MOD_KEY]["Hidden"], 0, 255)

    -- attempted to use "HookScript("OnShow", func)" for sound alert, nontheless frames are seen as shown while zero alpha and SetShown() cannot take secret-values
    if not addon.db[MOD_KEY]["Mute"] then
        PlaySoundFile(addon.LSM:Fetch("sound", addon.db[MOD_KEY]["SoundMedia"]), "Master")
    end

    self.frame:Show()
end

-- public methods
-- MARK: UpdateStyle

---Update style settings and render them in-game for FocusInterrupt
function FocusInterrupt:UpdateStyle()
    -- basic size and position of bar
    self.frame:SetSize(addon.db[MOD_KEY]["Width"], addon.db[MOD_KEY]["Height"])
    self.frame:SetPoint("CENTER", UIParent, "CENTER", addon.db[MOD_KEY]["X"], addon.db[MOD_KEY]["Y"])
    
    -- background is kind of Blizzard's texture, only color and alpha are customizable
    self.frame.background:SetColorTexture(0, 0, 0, addon.db[MOD_KEY]["BackgroundAlpha"])

    -- icon zoom and size
    self.frame.icon:SetTexCoord( -- prevent Blizzard's raw icons' border and fill all space with texture
        addon.db[MOD_KEY]["IconZoom"],
        1 - addon.db[MOD_KEY]["IconZoom"],
        addon.db[MOD_KEY]["IconZoom"],
        1 - addon.db[MOD_KEY]["IconZoom"]
    )
    self.frame.icon:SetSize(addon.db[MOD_KEY]["Height"], addon.db[MOD_KEY]["Height"]) -- keep icon has the same height as bar and keep it a cube

    -- bar texture and size
    -- after 3.2, only keep one status bar instead of 3(1 bar + 2 overlays)
    self.frame.statusBar:SetStatusBarTexture(addon.LSM:Fetch("statusbar", addon.db[MOD_KEY]["Texture"]))
    self.frame.statusBar:SetSize(addon.db[MOD_KEY]["Width"] - addon.db[MOD_KEY]["Height"], addon.db[MOD_KEY]["Height"])

    -- color settings
    -- after 3.2, by accessing texture's color instead of SetStatusBarColor() to use secret-value to decide color instead of overlays manipulations
    self.cooldownColor = CreateColorFromHexString(addon.db[MOD_KEY]["CooldownColor"])
    self.interruptibleColor = CreateColorFromHexString(addon.db[MOD_KEY]["InterruptibleColor"])
    self.notInterruptibleColor = CreateColorFromHexString(addon.db[MOD_KEY]["NotInterruptibleColor"])
    self.interruptedColor = CreateColorFromHexString(addon.db[MOD_KEY]["InterruptedColor"])
    self.frame.statusBar:GetStatusBarTexture():SetVertexColor(self.interruptibleColor:GetRGBA())

    -- font/text positions/
    -- left texts(spell + target)
    -- after 3.2, allow change the font size but change the margin to 0 for formatting more information
    self.frame.spellText:SetFont(
        addon.LSM:Fetch("font", addon.db[MOD_KEY]["Font"]) or "Fonts\\FRIZQT__.TTF",
        addon.db[MOD_KEY]["FontSize"],
        "OUTLINE"
    )
    self.frame.spellText:SetPoint("LEFT", self.frame, "LEFT", addon.db[MOD_KEY]["Height"], 0)
    self.frame.spellText:SetSize(0.7 * (addon.db[MOD_KEY]["Width"] - addon.db[MOD_KEY]["Height"]), addon.db[MOD_KEY]["FontSize"]) -- how much propotion of space is allowd
    -- right texts(time)
    self.frame.timeText:SetFont(
        addon.LSM:Fetch("font", addon.db[MOD_KEY]["Font"]) or "Fonts\\FRIZQT__.TTF",
        addon.db[MOD_KEY]["FontSize"],
        "OUTLINE"
    )
    self.frame.timeText:SetSize(0.3 * (addon.db[MOD_KEY]["Width"] - addon.db[MOD_KEY]["Height"]), addon.db[MOD_KEY]["FontSize"]) -- how much propotion of space is allowd

    if self.kickIcon then
        UpdateIcons(self)
    end
end

-- MARK: Test

---Test Mode for FocusInterrupt
---@param on boolean turn the Test mode on or off
function FocusInterrupt:Test(on)
    if not addon.db[MOD_KEY]["Enabled"] or addon.db[MOD_KEY]["Hidden"] then
        self.active = false
        self.frame:Hide()
        return
    end

    if on then
        -- generate a demo cast bar
		self.active = true
        local name, target = "MaximumTestSpell", "Target"
        if addon.db[MOD_KEY]["ShowTarget"] then
            self.frame.spellText:SetText(string.sub(name, 1, 16) .. "-" .. "|c" .. C_ClassColor.GetClassColor("WARLOCK"):GenerateHexColor() .. target .. "|r")
        else
            self.frame.spellText:SetText(string.sub(name, 1, 16))
        end
        
        self.frame.icon:SetTexture(UNKNOWN_SPELL_TEXTURE)
        self.frame.statusBar:SetMinMaxValues(0, 30)
        local testDuration = C_DurationUtil.CreateDuration() -- use a Blizzard LuaDurationObject to test
        testDuration:SetTimeFromStart(GetTime(), 30)

        addon.Utilities:MakeFrameDragPosition(self.frame, MOD_KEY, "X", "Y", function() -- drag for re-positioning and capable of running test mode simultaneously
            Update(self, testDuration, false, false)
        end)

        self.frame:Show()
    else
        self.active = false
        self.frame:Hide()
    end
end

--MARK: Register Event

---Register events for FocusInterrupt on EventsHandler
function FocusInterrupt:RegisterEvents() -- for cast-start events
    local StartCastHandle = function()
        if self.timer then -- if the interrupted fade Timer is still there, we should immediately halt it and handle new cast
            self.timer:Cancel()
            self.timer = nil
            SetBarColor(self, false, false, true)
        end
        
        self.active = true
        Handler(self)
    end
    
    local StopCastHandle = function (event, ...)
        if event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_FAILED" then -- for stop-cast events
            if not self.timer then -- since the stop-cast events also triggered after the interrupted-events, must avoid stop-cast events override the interrupted-events
                self.active = false
                self.frame:Hide()
            end
        elseif event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then -- handle potential interrupted-cast events 
            local _, _, _, guid = ... -- if guid != null -> some one interrupted it
            if guid then -- handle interrupted
                InterruptHandler(self, guid)
            else -- potential a normal stop cast
                if not self.timer then
                    self.active = false
                    self.frame:Hide()
                end
            end
        end
    end

    local UpdateID = function () UpdateInterruptId(self) end

    -- active cast
    addon.eventsHandler:Register(StartCastHandle, "UNIT_SPELLCAST_START", MOD_KEY, "focus")
    addon.eventsHandler:Register(StartCastHandle, "UNIT_SPELLCAST_CHANNEL_START", MOD_KEY, "focus")
    -- switch focus
    addon.eventsHandler:Register(StartCastHandle, "PLAYER_FOCUS_CHANGED", MOD_KEY)
    -- switch spec
    addon.eventsHandler:Register(UpdateID, "PLAYER_SPECIALIZATION_CHANGED", MOD_KEY)
    addon.eventsHandler:Register(UpdateID, "PLAYER_ENTERING_WORLD", MOD_KEY)
    -- stop cast
    addon.eventsHandler:Register(StopCastHandle, "UNIT_SPELLCAST_STOP", MOD_KEY, "focus")
    addon.eventsHandler:Register(StopCastHandle, "UNIT_SPELLCAST_FAILED", MOD_KEY, "focus")
    addon.eventsHandler:Register(StopCastHandle, "UNIT_SPELLCAST_INTERRUPTED", MOD_KEY, "focus")
    addon.eventsHandler:Register(StopCastHandle, "UNIT_SPELLCAST_CHANNEL_STOP", MOD_KEY, "focus")
end