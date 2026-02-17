local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "CustomAuraTracker"

-- MARK: Safe update

local function update()
	return addon.core:GetSafeUpdate(MOD_KEY)()
end

local function FetchAurasList()
    if addon.core.modules[MOD_KEY] then
        return addon.core.modules[MOD_KEY]:GetAurasList()
    else
        return {}
    end
end

local function GetAuraInfo(spellID)
    if addon.core.modules[MOD_KEY] then
        return addon.core.modules[MOD_KEY]:GetAuraInfo(spellID)
    else
        return nil
    end
end

local function Add(spellID, duration, cooldown, activeSound, expireSound, loadingSpecs)
    if addon.core.modules[MOD_KEY] then
        return addon.core.modules[MOD_KEY]:AddAura(spellID, duration, cooldown, activeSound, expireSound, loadingSpecs)
    else
        return false
    end
end

local function Remove(spellID)
    if addon.core.modules[MOD_KEY] then
        return addon.core.modules[MOD_KEY]:RemoveAura(spellID)
    else
        return false
    end
end

-- MARK: Input Check

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

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = true,
    IconSize = 35,
    TimeFontScale = 1,
    X = 0,
    Y = 0,
    Grow = "LEFT",
    SoundChannel = "Master",
}

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
    GUI:CreateDropDown(frame, L["SoundChannelSettings"], addon.Utilities.SoundChannels, addon.db.CustomAuraTracker.SoundChannel, false, function(key)
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
    GUI:CreateSlider(iconStyleGroup, L["TimeFontScale"], 0.5, 2, 0.1, addon.db.CustomAuraTracker.TimeFontScale, function(value)
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
    GUI:CreateDropDown(iconStyleGroup, L["Grow"], addon.Utilities.Grows, addon.db.CustomAuraTracker.Grow, false, function(key)
        addon.db.CustomAuraTracker.Grow = key
        update()
    end)

    -- MARK: Input Options
    local auraGroup = GUI:CreateInlineGroup(frame, L["AuraSettings"])
    GUI:CreateInformationTag(auraGroup, L["AuraSettingsDesc"], "LEFT")
    local inputSpellID = GUI:CreateEditBox(auraGroup, L["SpellID"], "", nil)
    local inputDuration = GUI:CreateEditBox(auraGroup, L["Duration"], "", nil)
    local inputCooldown = GUI:CreateEditBox(auraGroup, L["Cooldown"], "", nil)
    local inputActiveSound = GUI:CreateSoundSelect(auraGroup, L["ActiveSound"], nil, nil)
    local inputExpireSound = GUI:CreateSoundSelect(auraGroup, L["ExpireSound"], nil, nil)
    inputSpellID:SetRelativeWidth(0.2)
    inputDuration:SetRelativeWidth(0.2)
    inputCooldown:SetRelativeWidth(0.2)
    inputActiveSound:SetRelativeWidth(0.2)
    inputExpireSound:SetRelativeWidth(0.2)
    local specsSelected = {}
    GUI:CreateDropDown(auraGroup, "LoadingSpecs", addon.Utilities:GetAllSpecIconList(), nil, true, function(key, checked)
        if checked then
            specsSelected[key] = true
        else
            specsSelected[key] = nil
        end
    end, addon.Utilities.SpecIDs)

    GUI:CreateInformationTag(auraGroup, "\n")
    local auraSelected = GUI:CreateDropDown(auraGroup, L["SelectAura"], FetchAurasList(), "", false, function(key)
        local spellInfo = GetAuraInfo(key)
        if spellInfo then
            inputSpellID:SetText(spellInfo.spellID or "")
            inputDuration:SetText(spellInfo.duration or "")
            inputCooldown:SetText(spellInfo.cooldown or "")
            inputActiveSound:SetValue(spellInfo.activeSound or "")
            inputExpireSound:SetValue(spellInfo.expireSound or "")
        end
    end)
    -- MARK: Add Aura
    GUI:CreateButton(auraGroup, L["Add"], function ()
        local id = CheckSpellIDInput(inputSpellID:GetText())
        local duration = CheckTimeInput(inputDuration:GetText())
        local cooldown = CheckTimeInput(inputCooldown:GetText())

        if not id or not duration or not cooldown then
            return
        end
        
        local activeSound = inputActiveSound:GetValue()
        if activeSound == "" or activeSound == "None" then activeSound = nil end

        local expireSound = inputExpireSound:GetValue()
        if expireSound == "" or expireSound == "None" then expireSound = nil end

        local specsCount = 0
        for _ in pairs(specsSelected) do specsCount = specsCount + 1 end
        local loadingSpecs = specsCount > 0 and specsSelected or nil

        local isAdd = Add(id, duration, cooldown, activeSound, expireSound, loadingSpecs)
        if not addon.db.CustomAuraTracker.spells then
            addon.db.CustomAuraTracker.spells = {}
        end

        addon.db.CustomAuraTracker.spells[id] = {
            duration = duration,
            cooldown = cooldown,
            activeSound = activeSound,
            expireSound = expireSound,
        }
        
        -- update the dropdown list
        local val = addon.Utilities:GetSpellIconString(id)
        if isAdd then
            auraSelected:SetList(FetchAurasList())
            auraSelected:SetValue(id)
            addon.Utilities:print(string.format("%s-" .. L["AddSuccess"], val))
        else
            addon.Utilities:print(string.format("%s-" .. L["UpdateSuccess"], val))
        end
    end)
    -- MARK: Remove Aura
    GUI:CreateButton(auraGroup, L["Remove"], function ()
        local id = CheckSpellIDInput(inputSpellID:GetText())
        if not id then
            return
        end

        local success = Remove(id)
        local val = addon.Utilities:GetSpellIconString(id)
        if success then
            addon.db.CustomAuraTracker.spells[id] = nil

            -- update the dropdown list
            auraSelected:SetList(FetchAurasList())
            auraSelected:SetText("")
            
            addon.Utilities:print(string.format("%s-" .. L["RemoveSuccess"], val))
        else
            addon.Utilities:print(string.format("%s-" .. L["RemoveFailed"], val))
        end
    end)

    return frame
end