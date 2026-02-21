local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "CustomAuraTracker"

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = true,
    IconSize = 35,
    TimeFontScale = 1,
    X = 0,
    Y = 0,
    Grow = "LEFT",
    SoundChannel = "Master",
    IconZoom = 0.07,
    spells = {}, -- just for reset
}

-- MARK: Safe update

local function update()
	return addon.core:GetSafeUpdate(MOD_KEY)()
end

-- MARK: Fetch Auras List

---Fetch the auras saved in the database
---@return table aurasList a table with spellID as key and spell icon string as value for all auras in the database
local function FetchAurasList()
    local output = {}
    for spellID, _ in pairs(addon.db[MOD_KEY].spells or {}) do
        output[spellID] = addon.Utilities:GetSpellIconString(spellID)
    end

    return output
end

-- MARK: Get Aura Info

---Get detailed information for a specific tracked aura
---@param spellID integer the spellID of the aura
---@return table|nil info a table containing aura details, or nil if not found
local function FetchAuraInfo(spellID)
    local spellInfo = addon.db[MOD_KEY].spells and addon.db[MOD_KEY].spells[spellID]
    if spellInfo then
        return {
            spellID = spellID,
            duration = spellInfo.duration,
            cooldown = spellInfo.cooldown,
            activeSound = spellInfo.activeSound,
            expireSound = spellInfo.expireSound,
            loadingSpecs = spellInfo.loadingSpecs,
        }
    else
        return nil
    end
end

-- MARK: I/O Functions

---Add an aura after validate inputs
---@param spellID integer spellID
---@param duration number duration
---@param cooldown number cooldown
---@param activeSound string|nil active sound file ID or path, nil for no sound
---@param expireSound string|nil expire sound file ID or path, nil for no sound
---@param loadingSpecs table|nil a hash set of specIDs to load the aura, nil for all specs
---@return boolean isUpdate true if the aura is updated, false if it's a new aura
local function AddAura(spellID, duration, cooldown, activeSound, expireSound, loadingSpecs)
    -- save to the database
    if not addon.db.CustomAuraTracker.spells then
        addon.db.CustomAuraTracker.spells = {}
    end
    local isUpdate = addon.db.CustomAuraTracker.spells[spellID] or false
    addon.db.CustomAuraTracker.spells[spellID] = {
        duration = duration,
        cooldown = cooldown,
        activeSound = activeSound,
        expireSound = expireSound,
        loadingSpecs = loadingSpecs,
    }

    if addon.core.modules[MOD_KEY] then
        addon.core.modules[MOD_KEY]:HandleAddAura(spellID)
    end

    return isUpdate
end

---Remove an aura after validate inputs
---@param spellID integer spellID
---@return boolean success true if the aura is successfully removed, false if the aura is not found in the database
local function RemoveAura(spellID)
    -- if the aura is not found in the database, return false
    if not addon.db.CustomAuraTracker.spells or not addon.db.CustomAuraTracker.spells[spellID] then
        return false
    end

    -- remove from the database
    addon.db.CustomAuraTracker.spells[spellID] = nil

    if addon.core.modules[MOD_KEY] then
        addon.core.modules[MOD_KEY]:HandleRemoveAura(spellID)
    end

    return true
end

-- MARK: Input Check

---Check if the input value is a valid time (non-negative number)
---@param value any
---@return number|nil data the valid time value, or nil if invalid
local function CheckTimeInput(value)
    local data = tonumber(value)
    if not data then
        addon.Utilities:SetPopupDialog(ADDON_NAME.."InvalidInput", L["InvalidInput"], true)
        return nil
    elseif data < 0 then
        addon.Utilities:SetPopupDialog(ADDON_NAME.."InvalidInput", L["InvalidTime"], true)
        return nil
    end

    return data
end

---Check if the input value is a valid spell ID (positive integer and exists in the game)
---@param value any
---@return number|nil data the valid spell ID, or nil if invalid
local function CheckSpellIDInput(value)
    local data = tonumber(value)
    if not data or data <= 0 or data % 1 ~= 0 then
        addon.Utilities:SetPopupDialog(ADDON_NAME.."InvalidInput", L["InvalidSpellID"], true)
        return nil
    elseif not C_Spell.GetSpellInfo(data) then
        addon.Utilities:SetPopupDialog(ADDON_NAME.."InvalidInput", L["SpellIDNotFound"], true)
        return nil
    end

    return data
end

-- GUI
GUI.TagPanels.CustomAuraTracker = {}
function GUI.TagPanels.CustomAuraTracker:CreateTabPanel(parent)
	-- MARK: General
	local frame = GUI:CreateScrollFrame(parent)
	frame:SetLayout("Flow")
	frame:SetFullWidth(true)

	GUI:CreateInformationTag(frame, L["CustomAuraTrackerSettingsDesc"], "LEFT")
	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["CustomAuraTrackerSettings"] .. "|r", addon.db.CustomAuraTracker.Enabled, function(value)
		addon.db.CustomAuraTracker.Enabled = value
		if addon.core:HasModuleLoaded(MOD_KEY) then -- if module is loaded
            if not value then -- user try to disable the module
                addon:ShowDialog(ADDON_NAME.."RLNeeded")
            end
        else -- if the module is not loaded yet
            if value then -- user try to enable the module, just load it without asking for reload, since it will be loaded immediately
                addon.core:LoadModule(MOD_KEY)
                addon.core:TestModule(MOD_KEY) -- the test mode will be on if the addon is in test mode
            end
        end
	end)
    GUI:CreateDropdown(frame, L["SoundChannelSettings"], addon.Utilities.SoundChannels, nil, addon.db.CustomAuraTracker.SoundChannel, function(key)
        addon.db.CustomAuraTracker.SoundChannel = key
    end)
	GUI:CreateButton(frame, L["ResetMod"], function ()
		addon.Utilities:SetPopupDialog(
			ADDON_NAME .. "ResetMod",
			"|cffC41E3A" .. L["CustomAuraTrackerSettings"] .. "|r: " .. L["ComfirmResetMod"],
			true,
			{button1 = YES, button2 = NO, OnButton1 = function ()
		    	addon.Utilities:ResetModule(MOD_KEY)
				ReloadUI()
			end}
		)
	end)

    -- MARK: Style Settings
    local iconStyleGroup = GUI:CreateInlineGroup(frame, L["StyleSettings"])
    GUI:CreateSlider(iconStyleGroup, L["IconSize"], 20, 100, 1, addon.db.CustomAuraTracker.IconSize, function(value)
        addon.db.CustomAuraTracker.IconSize = value
        update()
    end)
    GUI:CreateSlider(iconStyleGroup, L["TimeFontScale"], 0.5, 2, 0.01, addon.db.CustomAuraTracker.TimeFontScale, function(value)
        addon.db.CustomAuraTracker.TimeFontScale = value
        update()
    end)
    GUI:CreateSlider(iconStyleGroup, L["X"], -2000, 2000, 1, addon.db.CustomAuraTracker.X, function(value)
        addon.db.CustomAuraTracker.X = value
        update()
    end)
    GUI:CreateSlider(iconStyleGroup, L["Y"], -2000, 2000, 1, addon.db.CustomAuraTracker.Y, function(value)
        addon.db.CustomAuraTracker.Y = value
        update()
    end)
    GUI:CreateSlider(iconStyleGroup, L["IconZoom"], 0, 0.5, 0.01, addon.db.CustomAuraTracker.IconZoom, function(value)
        addon.db.CustomAuraTracker.IconZoom = value
        update()
    end)
    GUI:CreateDropdown(iconStyleGroup, L["Grow"], addon.Utilities.Grows, nil, addon.db.CustomAuraTracker.Grow, function(key)
        addon.db.CustomAuraTracker.Grow = key
        update()
    end)

    -- MARK: Input Options
    local auraGroup = GUI:CreateInlineGroup(frame, L["AuraSettings"])
    GUI:CreateInformationTag(auraGroup, L["AuraSettingsDesc"], "LEFT")
    GUI:CreateInformationTag(auraGroup, "\n")
    local inputSpellID = GUI:CreateEditBox(nil, L["SpellID"], "", nil)
    local inputDuration = GUI:CreateEditBox(nil, L["Duration"], "", nil)
    local inputCooldown = GUI:CreateEditBox(nil, L["Cooldown"], "", nil)
    local inputActiveSound = GUI:CreateSoundSelect(nil, L["ActiveSound"], nil, nil)
    local inputExpireSound = GUI:CreateSoundSelect(nil, L["ExpireSound"], nil, nil)
    inputSpellID:SetRelativeWidth(0.19)
    inputDuration:SetRelativeWidth(0.19)
    inputCooldown:SetRelativeWidth(0.19)
    inputActiveSound:SetRelativeWidth(0.19)
    inputExpireSound:SetRelativeWidth(0.19)

    -- MARK: Specs Selection
    local SpecsSelection = GUI:CreateSpecSelectDropdown(nil, L["LoadingSpecs"])
    SpecsSelection:GetWidget():SetRelativeWidth(0.5)
    local clearSpecsButton = GUI:CreateButton(nil, L["ClearSpecsSelection"], function ()
        SpecsSelection:ClearSpecSelection()
    end)

    -- MARK: Aura Selected Dropdown
    local auraSelected = GUI:CreateDropdown(auraGroup, L["SelectAura"], FetchAurasList(), nil, "", function(key)
        local spellInfo = FetchAuraInfo(key)
        if spellInfo then
            inputSpellID:SetText(spellInfo.spellID or "")
            inputDuration:SetText(spellInfo.duration or "")
            inputCooldown:SetText(spellInfo.cooldown or "")
            inputActiveSound:SetValue(spellInfo.activeSound or "")
            inputExpireSound:SetValue(spellInfo.expireSound or "")

            -- reset SpecsSelection and set selected specs according to the selected aura
            SpecsSelection:SetSelectedSpecs(spellInfo.loadingSpecs)
        end
    end)

    -- MARK: Add Aura
    GUI:CreateButton(auraGroup, L["Add"], function ()
        -- check inputs
        local id = CheckSpellIDInput(inputSpellID:GetText())
        local duration = CheckTimeInput(inputDuration:GetText())
        local cooldown = CheckTimeInput(inputCooldown:GetText())

        if not id or not duration or not cooldown then
            addon.Utilities:print(L["AddFailed"])
            return
        end
        
        local activeSound = inputActiveSound:GetValue()
        if activeSound == "" or activeSound == "None" then activeSound = nil end

        local expireSound = inputExpireSound:GetValue()
        if expireSound == "" or expireSound == "None" then expireSound = nil end

        -- get selected specs
        local loadingSpecs = SpecsSelection:GetSelectedSpecs()

        -- add the aura
        local isUpdate = AddAura(id, duration, cooldown, activeSound, expireSound, loadingSpecs)
        
        -- update the aura selected dropdown list
        local val = addon.Utilities:GetSpellIconString(id)
        if isUpdate then
            addon.Utilities:print(string.format("%s-" .. L["UpdateSuccess"], val))
        else
            auraSelected:SetList(FetchAurasList())
            auraSelected:SetValue(id)
            addon.Utilities:print(string.format("%s-" .. L["AddSuccess"], val))
        end
    end)

    -- MARK: Remove Aura
    GUI:CreateButton(auraGroup, L["Remove"], function ()
        -- check input
        local id = CheckSpellIDInput(inputSpellID:GetText())
        if not id then -- if the id not valid or the aura is not found in the database
            addon.Utilities:print(L["RemoveFailed"]) -- show error
            return
        end

        -- remove the aura
        local success = RemoveAura(id)

        if success then
            -- update the aura selected dropdown list
            auraSelected:SetList(FetchAurasList())
            auraSelected:SetText("")
            SpecsSelection:ClearSpecSelection()

            addon.Utilities:print(string.format("%s-" .. L["RemoveSuccess"], addon.Utilities:GetSpellIconString(id)))
        else
            addon.Utilities:print(string.format("%s-" .. L["RemoveFailed"], addon.Utilities:GetSpellIconString(id)))
        end
    end)

    -- create these option after select/add/remove
    -- but declare them before to avoid nil error
    GUI:CreateInformationTag(auraGroup, "\n")
    auraGroup:AddChild(inputSpellID)
    auraGroup:AddChild(inputDuration)
    auraGroup:AddChild(inputCooldown)
    auraGroup:AddChild(inputActiveSound)
    auraGroup:AddChild(inputExpireSound)
    GUI:CreateInformationTag(auraGroup, L["LoadingSpecsDesc"], "LEFT")
    auraGroup:AddChild(SpecsSelection:GetWidget())
    auraGroup:AddChild(clearSpecsButton)

    return frame
end