local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class WarlockReminder
---@field pet frame pet frame
---@field candy frame candy frame
---@field timer C_Timer timer to keep track of mount state
---@field modName string module name for registering in core
local WarlockReminder = {
    modName = "WarlockReminders",
    frame = CreateFrame("Frame", ADDON_NAME .. "_WarlockReminder", UIParent),
}

-- MARK: Constants
local HEALSTONE_ID = {
    HEALTHSTONE = 5512,
    DEMONIC_HEALTHSTONE = 224464,
}
local TEXTURE_ID = {
    GENERIC_SUMMON_DEMON = 136082,
    FELGUARD = 136216,
    FELHUNTER = 136217,
    HEALTHSTONE = 538745,
    ASSIST = 524348,
    DEFENSIVE = 132110,
    PASSIVE = 132311,
}
-- Warlock Spec IDs
local SPEC_ID = {
    AFFLICTION = 265,
    DEMONOLOGY = 266,
    DESTRUCTION = 267
}
local PET_STANCE = { -- map pet stance names onto numbers
    ASSIST = 1,
    DEFENSIVE = 2,
    PASSIVE = 3,
}

-- MARK: Initialize

---Intialize(Constructor)
---@return WarlockReminder|nil WarlockReminder a WarlockReminder object(nil for non-warlock player -> not initialized)
function WarlockReminder:Initialize()
    if addon.states["playerClass"] ~= "WARLOCK" then
        return nil
    end

    self.pet = CreateFrame("Frame", nil, UIParent)
    self.pet:Hide()

    self.candy = CreateFrame("Frame", nil, UIParent)
    self.candy:Hide()

    -- icons
    self.pet.icon = self.pet:CreateTexture(nil, "ARTWORK")
    self.pet.icon:SetAllPoints()
    self.pet.icon:SetTexture(TEXTURE_ID.GENERIC_SUMMON_DEMON)

    self.candy.icon = self.candy:CreateTexture(nil, "ARTWORK")
    self.candy.icon:SetAllPoints()
    self.candy.icon:SetTexture(TEXTURE_ID.HEALTHSTONE)
    self.candy.icon:SetDesaturated(true)

    -- texts
    -- frame which takes texts
    self.pet.textFrame = CreateFrame("Frame", nil, self.pet)
    self.pet.textFrame:SetAllPoints()
    
    self.candy.textFrame = CreateFrame("Frame", nil, self.candy)
    self.candy.textFrame:SetAllPoints()

    self.pet.text = self.pet.textFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.pet.text:SetText("")

    self.candy.text = self.candy.textFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.candy.text:SetText("")

    -- borders
    self.pet.border = CreateFrame("Frame", nil, self.pet, "BackdropTemplate")
    self.pet.border:SetAllPoints()
    self.pet.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    self.pet.border:SetBackdropBorderColor(0, 0, 0, 1)

    self.candy.border = CreateFrame("Frame", nil, self.candy, "BackdropTemplate")
    self.candy.border:SetAllPoints()
    self.candy.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    self.candy.border:SetBackdropBorderColor(0, 0, 0, 1)

    addon.Utilities:print(L["WarlockWelecome"])
    return self
end

-- MARK: private methods

---Determine whether there is at least one valid candy in the bag
---@return boolean isCandyValid if there is at least one valid candy in the bag
local function IsCandyValid()
    local count = 0  
    for _, v in pairs(HEALSTONE_ID) do
        count = count + GetItemCount(v)
    end

    return count > 0
end

---Get Warlock Pet's Stance
---@return integer stance an integer indicates stance: 1: Assist, 2: Defensive, 3: Passive -1: Abnormal
local function GetPetStance()
    -- 1: Assist, 2: Defensive, 3: Passive
    if not UnitExists("pet") then -- if pet missing
        return -1
    end

    for i = 1, NUM_PET_ACTION_SLOTS do
        local name, _, _, isActive, _, _, _ = GetPetActionInfo(i)
        if isActive then
            if name == "PET_MODE_ASSIST" then
                return PET_STANCE.ASSIST
            elseif name == "PET_MODE_DEFENSIVEASSIST" then
                return PET_STANCE.DEFENSIVE
            elseif name == "PET_MODE_PASSIVE" then
                return PET_STANCE.PASSIVE
            end
        end
    end

    return -1
end

-- MARK: PetHandler

---Handler for pet frame
---@param self WarlockReminder self
local function PetHandler(self)
    if not addon.db[self.modName]["PetEnabled"] or addon.states["inCombat"] or IsMounted() then
        self.pet:Hide()
        return
    end

    -- check existance of pet
    local petFamily = ""
    if UnitExists("pet") then -- pet is missing: petFamily == ""
        petFamily = UnitCreatureFamily("pet")
    end

    if petFamily == "" then -- if pet is missing
        self.pet.icon:SetDesaturated(true)
        if addon.states["playerSpec"] == SPEC_ID.DEMONOLOGY then -- assign correct pet icon depending on spec
            self.pet.icon:SetTexture(TEXTURE_ID.FELGUARD)
        else
            self.pet.icon:SetTexture(TEXTURE_ID.FELHUNTER)
        end
        self.pet.text:SetText(addon.db[self.modName]["PetMissingText"])
        self.pet:Show()
    else -- check pet type
        if addon.states["playerSpec"] == SPEC_ID.DEMONOLOGY and addon.db[self.modName]["FelguardEnabled"] then
            if petFamily ~= L["PetFamily"]["Felguard"] then -- wrong type for demonology
                self.pet.icon:SetDesaturated(true)
                self.pet.icon:SetTexture(TEXTURE_ID.FELGUARD)
                self.pet.text:SetText(addon.db[self.modName]["PetWrongTypeText"])
                self.pet:Show()
                return
            end
        elseif addon.states["playerSpec"] ~= SPEC_ID.DEMONOLOGY and addon.db[self.modName]["FelhunterEnabled"] then 
            if petFamily ~= L["PetFamily"]["Felhunter"] and petFamily ~= L["PetFamily"]["Imp"] then -- wrong type for afflication/destruction
                self.pet.icon:SetDesaturated(true)
                self.pet.icon:SetTexture(TEXTURE_ID.FELHUNTER)
                self.pet.text:SetText(addon.db[self.modName]["PetWrongTypeText"])
                self.pet:Show()
                return
            end
        end

        if addon.db[self.modName]["StanceEnabled"] then -- check stance if needed
            local curStance = GetPetStance()
            if curStance == -1 or curStance == PET_STANCE.ASSIST then -- stance error or stance correct
                self.pet.text:SetText(L["PetStance"]["ASSIST"])
                self.pet:Hide()
            else -- if wrong stance
                if curStance == PET_STANCE.PASSIVE then
                    self.pet.icon:SetDesaturated(false)
                    self.pet.icon:SetTexture(TEXTURE_ID.PASSIVE)
                    self.pet.text:SetText(L["PetStance"]["PASSIVE"])
                elseif curStance == PET_STANCE.DEFENSIVE then
                    self.pet.icon:SetDesaturated(false)
                    self.pet.icon:SetTexture(TEXTURE_ID.DEFENSIVE)
                    self.pet.text:SetText(L["PetStance"]["DEFENSIVE"])
                end

                self.pet:Show()
                return
            end
        end
    end
end

-- MARK: CandyHandler

---Handler for candy frame
---@param self WarlockReminder self
local function CandyHandler(self)
    if not addon.db[self.modName]["CandyEnabled"] or addon.states["inCombat"] then
        self.candy:Hide()
        return
    end

    if IsCandyValid() then
        self.candy:Hide()
    else
        self.candy:Show()
    end
end

-- MARK: Handler

---Handler for WarlockReminder
---@param self WarlockReminder self
---@param pattern? string either "pet", "candy", or nil(both)
local function Handler(self, pattern)
    if pattern == "pet" then
        PetHandler(self)
    elseif pattern == "candy" then
        CandyHandler(self)
    else
        PetHandler(self)
        CandyHandler(self)
    end
end

-- public methods
-- MARK: UpdateStyle

---Update style settings and render them in-game for WarlockReminder
function WarlockReminder:UpdateStyle()
    self.pet:SetFrameStrata(addon.db[self.modName]["FrameStrata"] or "BACKGROUND")
    self.pet:SetPoint("CENTER", UIParent, "CENTER", addon.db[self.modName]["PetX"], addon.db[self.modName]["PetY"])
    self.pet:SetSize(addon.db[self.modName]["IconSize"], addon.db[self.modName]["IconSize"])

    self.candy:SetFrameStrata(addon.db[self.modName]["FrameStrata"] or "BACKGROUND")
    self.candy:SetPoint("CENTER", UIParent, "CENTER", addon.db[self.modName]["CandyX"], addon.db[self.modName]["CandyY"])
    self.candy:SetSize(addon.db[self.modName]["IconSize"], addon.db[self.modName]["IconSize"])

    self.pet.icon:SetTexCoord(addon.db[self.modName]["IconZoom"], 1 - addon.db[self.modName]["IconZoom"], addon.db[self.modName]["IconZoom"], 1 - addon.db[self.modName]["IconZoom"])
    self.candy.icon:SetTexCoord(addon.db[self.modName]["IconZoom"], 1 - addon.db[self.modName]["IconZoom"], addon.db[self.modName]["IconZoom"], 1 - addon.db[self.modName]["IconZoom"])

    self.pet.text:SetPoint("CENTER", self.pet, "BOTTOM", 0, 0)
    self.pet.text:SetFont(addon.LSM:Fetch(
        "font", addon.db[self.modName]["Font"]) or "Fonts\\FRIZQT__.TTF",
        addon.db[self.modName]["FontSize"],
        "OUTLINE"
    )
    self.pet.text:SetTextColor(255, 255, 255)

    self.candy.text:SetPoint("CENTER", self.candy, "BOTTOM", 0, 0)
    self.candy.text:SetFont(addon.LSM:Fetch(
        "font", addon.db[self.modName]["Font"]) or "Fonts\\FRIZQT__.TTF",
        addon.db[self.modName]["FontSize"],
        "OUTLINE"
    )
    self.candy.text:SetTextColor(255, 255, 255)
    self.candy.text:SetText(addon.db[self.modName]["CandyMissingText"])
end

-- MARK: Test

---Test mode for WarlockReminder
---@param on boolean turn the Test mode on or off
function WarlockReminder:Test(on)
    if on and not addon.states["inCombat"] then
		self.pet:Show()
        addon.Utilities:MakeFrameDragPosition(self.pet, self.modName, "PetX", "PetY")

        self.candy:Show()
         addon.Utilities:MakeFrameDragPosition(self.candy, self.modName, "CandyX", "CandyY")
    else
        Handler(self)
    end
end

--MARK: Register Event

---Register events for WarlockReminder on EventsHandler
function WarlockReminder:RegisterEvents()
    local function OnEvent(_, event, ...)
        if event == "UNIT_PET" or event == "PET_BAR_UPDATE" or event == "PET_DISMISS_START" or event == "PLAYER_ALIVE" then
            Handler(self, "pet")
        elseif event == "BAG_UPDATE" then
            Handler(self, "candy")
         elseif event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
            if IsMounted() then
                Handler(self)
            else
                if self.timer then
                    self.timer:Cancel()
                    self.timer = nil
                end

                self.timer = C_Timer.NewTimer(3, function () Handler(self) end)
            end
        end
    end

    -- Both events
    addon.core:RegisterEvent("PLAYER_ENTERING_WORLD", self.frame, self.modName)
    addon.core:RegisterStateMonitor("inCombat", self.modName, function() Handler(self) end)
    -- Pet events
    addon.core:RegisterEvent("UNIT_PET", self.frame, self.modName, "player")
    addon.core:RegisterEvent("PET_BAR_UPDATE", self.frame, self.modName)
    addon.core:RegisterEvent("PET_DISMISS_START", self.frame, self.modName)
    addon.core:RegisterEvent("PLAYER_ALIVE", self.frame, self.modName)
    addon.core:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED", self.frame, self.modName)
    addon.core:RegisterStateMonitor("playerSpec", self.modName, function() Handler(self, "pet") end)
    -- Candy events
    addon.core:RegisterEvent("BAG_UPDATE", self.frame, self.modName)

    self.frame:SetScript("OnEvent", OnEvent)
end

-- MARK: Register Module
addon.core:RegisterModule(WarlockReminder.modName, function() return WarlockReminder:Initialize() end)