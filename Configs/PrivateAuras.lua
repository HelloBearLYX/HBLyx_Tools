local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "PrivateAuras"

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = false,
	SoundChannel = "Master",
	data = {}, -- data structure: { [encounterID] = { [spellID] = sound } }
}

-- MARK: Adds
local function AddSound(encounterID, spellID, sound)
	if not addon.db.PrivateAuras.data then
		addon.db.PrivateAuras.data = {}
	end

	if not addon.db.PrivateAuras.data[encounterID] then
		addon.db.PrivateAuras.data[encounterID] = {}
	end

	addon.db.PrivateAuras.data[encounterID][spellID] = sound

	addon.Utilities:print(string.format("%d-%d-%s: %s", encounterID, spellID, sound, L["AddSuccess"]))
end

-- MARK: Removes
local function RemoveSound(encounterID, spellID)
	if addon.db.PrivateAuras.data and addon.db.PrivateAuras.data[encounterID] and addon.db.PrivateAuras.data[encounterID][spellID] then
		addon.db.PrivateAuras.data[encounterID][spellID] = nil
	end
end

-- MARK: Get Maps List
local function GetMapsList()
    local output = {}
    for mapID, mapInfo in pairs(addon.data.MAP_ENCOUNTER_EVENTS) do
        if mapInfo.name then
            output[mapID] =  "|T" .. C_Spell.GetSpellInfo(mapInfo.portalID).iconID .. ":0|t " .. mapInfo.name
        end
    end
    return output
end

-- MARK: Get Encounters List
local function GetEncountersList(mapID)
	local output = {}
	if addon.data.MAP_ENCOUNTER_EVENTS[mapID] and addon.data.MAP_ENCOUNTER_EVENTS[mapID].encounters then
		for encounterID, encounterInfo in pairs(addon.data.MAP_ENCOUNTER_EVENTS[mapID].encounters) do
			output[encounterID] = encounterInfo.journalID and EJ_GetEncounterInfo(encounterInfo.journalID) or encounterID
		end
	end

	return output
end

-- MARK: Render Settings
local function CreatePrivateAuraSettings(encounterID, spellID, container)
    local inputSound = nil
    local currentSound = addon.db.PrivateAuras.data and addon.db.PrivateAuras.data[encounterID] and addon.db.PrivateAuras.data[encounterID][spellID] or nil
    local soundSelect = GUI:CreateDropdown(container, L["SoundSettings"], addon.Utilities.Sounds, nil, currentSound, function (value)
        inputSound = value
        AddSound(encounterID, spellID, value)
    end)
    GUI:CreateButton(container, L["Remove"], function ()
        RemoveSound(encounterID, spellID)
        soundSelect:SetValue(nil)
    end)
end

local function RenderEncounterSettings(mapID, encounterID, container)
	for _, spellID in ipairs(addon.data.MAP_ENCOUNTER_EVENTS[mapID].encounters[encounterID].privateAuras) do
		local spellInfo = C_Spell.GetSpellInfo(spellID)
		local name = "UNKNOWN"
		if spellID then
			name = "|T" .. spellInfo.iconID .. ":0|t " .. spellInfo.name
		end
		local group = GUI:CreateInlineGroup(container, name)
		CreatePrivateAuraSettings(encounterID, spellID, group)
	end
end

-- GUI
GUI.TagPanels.PrivateAuras = {}
function GUI.TagPanels.PrivateAuras:CreateTabPanel(parent)
	-- MARK: General
	local frame = GUI:CreateScrollFrame(parent)

    GUI:CreateInformationTag(frame, L["PrivateAurasSettingsDesc"], "LEFT")
	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["PrivateAurasSettings"] .. "|r", addon.db.PrivateAuras.Enabled, function(value)
		addon.db.PrivateAuras.Enabled = value
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
	GUI:CreateDropdown(frame, L["SoundChannelSettings"], addon.Utilities.SoundChannels, nil, addon.db.PrivateAuras.SoundChannel, function(key)
        addon.db.PrivateAuras.SoundChannel = key
    end)
	GUI:CreateButton(frame, L["ResetMod"], function ()
		addon.Utilities:SetPopupDialog(
			ADDON_NAME .. "ResetMod",
			"|cffC41E3A" .. L["EncounterSoundSettings"] .. "|r: " .. L["ComfirmResetMod"],
			true,
			{button1 = YES, button2 = NO, OnButton1 = function ()
		    	addon.Utilities:ResetModule(MOD_KEY)
				ReloadUI()
			end}
		)
	end)

    -- MARK: TODO Private Anchor

    -- MARK: Setting Part
	local inputMap, inputEncounter = nil, nil
	local selectGroup = GUI:CreateInlineGroup(frame, L["Select"])
	local settingsGroup = GUI:CreateInlineGroup(nil, L["PrivateAurasSettings"])
	local encounterGroup = 	GUI:CreateDropdown(nil, L["SelectEncounter"], {}, nil, nil, function (value)
		settingsGroup:ReleaseChildren()
		
		inputEncounter = value
		RenderEncounterSettings(inputMap, inputEncounter, settingsGroup)
		frame:DoLayout()
	end)
	GUI:CreateDropdown(selectGroup, L["SelectInstance"], GetMapsList(), nil, nil, function (value)
		inputMap = value
		local list = GetEncountersList(value)
		encounterGroup:SetList(list)
		encounterGroup:SetValue(nil)
		settingsGroup:ReleaseChildren()
		frame:DoLayout()
	end)
	selectGroup:AddChild(encounterGroup)
	selectGroup:AddChild(settingsGroup)

	return frame
end