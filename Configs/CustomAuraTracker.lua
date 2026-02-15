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

local function Add(spellID, duration, cooldown, activeSound, expireSound)
    if addon.core.modules[MOD_KEY] then
        return addon.core.modules[MOD_KEY]:AddAura(spellID, duration, cooldown, activeSound, expireSound)
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

        local success = Add(id, duration, cooldown, activeSound, expireSound)
        if success then
            if not addon.db.CustomAuraTracker.spells then
                addon.db.CustomAuraTracker.spells = {}
            end 

            table.insert(addon.db.CustomAuraTracker.spells, {
                id = id,
                duration = duration,
                cooldown = cooldown,
                activeSound = activeSound,
                expireSound = expireSound,
            })
            
            -- update the dropdown list
            local name = C_Spell.GetSpellInfo(id).name or "UNKNOWN"
            auraSelected:AddItem(id, name)
            addon.Utilities:print(string.format("%s(%d) added successfully.", name, id))
        else
            addon.Utilities:print(string.format("Failed to add %d. Please check input information.", id))
        end
    end)
    -- MARK: Remove Aura
    GUI:CreateButton(auraGroup, L["Remove"], function ()
        local id = tonumber(inputSpellID:GetText())

        local success = Remove(id)
        if success then
            for index, aura in pairs(addon.db.CustomAuraTracker.spells) do
                if aura.id == id then
                    table.remove(addon.db.CustomAuraTracker.spells, index)
                    break
                end
            end

            -- update the dropdown list
            local name = C_Spell.GetSpellInfo(id).name or "UNKNOWN"
            auraSelected:SetItemDisabled(id, true)
            addon.Utilities:print(string.format("%s(%d) removed successfully.", name, id))
        else
            addon.Utilities:print(string.format("Failed to remove %d. Please check spellID.", id))
        end
    end)

    return frame
end