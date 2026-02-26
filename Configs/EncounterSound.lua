local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "EncounterSound"

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = false,
	SoundChannel = "Master",
	data = {}, -- data structure: { [encounterID] = { [eventID] = { [trigger] = sound, color = color } } }
}

-- MARK: Constants
local EVENT_TRIGGERS = {
	[0] = L["OnTextWarningShown"],
	[1] = L["OnTimelineEventFinished"],
	[2] = L["OnTimelineEventHighlight"],
}

-- MARK: Safe update
local function update()
	return addon.core:GetSafeUpdate(MOD_KEY)()
end

-- MARK: Adds
local function AddSound(encounterID, eventID, trigger, sound)
	if not addon.db.EncounterSound.data then
		addon.db.EncounterSound.data = {}
	end

	if not addon.db.EncounterSound.data[encounterID] then
		addon.db.EncounterSound.data[encounterID] = {}
	end

	if not addon.db.EncounterSound.data[encounterID][eventID] then
		addon.db.EncounterSound.data[encounterID][eventID] = {}
	end

	addon.db.EncounterSound.data[encounterID][eventID][trigger] = sound

	addon.Utilities:print(string.format("%d-%d-%s-%s: %s", encounterID, eventID, EVENT_TRIGGERS[trigger], sound, L["AddSuccess"]))
end

local function AddColor(encounterID, eventID, color)
	if not addon.db.EncounterSound.data then
		addon.db.EncounterSound.data = {}
	end

	if not addon.db.EncounterSound.data[encounterID] then
		addon.db.EncounterSound.data[encounterID] = {}
	end

	if not addon.db.EncounterSound.data[encounterID][eventID] then
		addon.db.EncounterSound.data[encounterID][eventID] = {}
	end

	addon.db.EncounterSound.data[encounterID][eventID].color = color
end

-- MARK: Removes
local function RemoveSound(encounterID, eventID, trigger)
	if addon.db.EncounterSound.data and addon.db.EncounterSound.data[encounterID] and addon.db.EncounterSound.data[encounterID][eventID] and addon.db.EncounterSound.data[encounterID][eventID][trigger] then
		addon.db.EncounterSound.data[encounterID][eventID][trigger] = nil
	end
end

local function RemoveColor(encounterID, eventID)
	if addon.db.EncounterSound.data and addon.db.EncounterSound.data[encounterID] and addon.db.EncounterSound.data[encounterID][eventID] then
		addon.db.EncounterSound.data[encounterID][eventID].color = nil
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
local function CreateTimelineSettings(encounterID, eventID, container)
	local soundGroup = GUI:CreateInlineGroup(container, L["SoundSettings"])
	local inputTrigger, inputSound = nil, nil
	local soundSelect = GUI:CreateSoundSelect(nil, L["EncounterEventSound"], nil, function(key)
		inputSound = key
		if inputTrigger then
			AddSound(encounterID, eventID, inputTrigger, inputSound)
		end
	end)
	GUI:CreateDropdown(soundGroup, L["EncounterEventTrigger"], EVENT_TRIGGERS, nil, nil, function(value)
		inputTrigger = value
		if addon.db.EncounterSound.data and addon.db.EncounterSound.data[encounterID] and addon.db.EncounterSound.data[encounterID][eventID] and addon.db.EncounterSound.data[encounterID][eventID][inputTrigger] then
			inputSound = addon.db.EncounterSound.data[encounterID][eventID][inputTrigger]
			soundSelect:SetValue(inputSound)
		else
			inputSound = nil
			soundSelect:SetValue(nil)
		end
	end)
	soundGroup:AddChild(soundSelect)
	GUI:CreateButton(soundGroup, L["Remove"], function()
		if addon.db.EncounterSound.data and addon.db.EncounterSound.data[encounterID] and addon.db.EncounterSound.data[encounterID][eventID] and addon.db.EncounterSound.data[encounterID][eventID][inputTrigger] then
			RemoveSound(encounterID, eventID, inputTrigger)
			inputSound = nil
			soundSelect:SetValue(nil)
			addon.Utilities:print(string.format("%d-%d-%s: %s", encounterID, eventID, EVENT_TRIGGERS[inputTrigger], L["RemoveSuccess"]))
		else
			addon.Utilities:print(L["RemoveFailed"])
		end
	end)

	local inputColor = nil
	local colorGroup = GUI:CreateInlineGroup(container, L["ColorSettings"])
	local color = "ffffff"
	if addon.db.EncounterSound.data and addon.db.EncounterSound.data[encounterID] and addon.db.EncounterSound.data[encounterID][eventID] and addon.db.EncounterSound.data[encounterID][eventID].color then
		color = addon.db.EncounterSound.data[encounterID][eventID].color
	end
	local colorPicker = GUI:CreateColorPicker(colorGroup, L["EventColor"], false, color, function(hex)
		inputColor = hex
		AddColor(encounterID, eventID, inputColor)
	end)
	GUI:CreateButton(colorGroup, L["Remove"], function()
		if addon.db.EncounterSound.data and addon.db.EncounterSound.data[encounterID] and addon.db.EncounterSound.data[encounterID][eventID] and addon.db.EncounterSound.data[encounterID][eventID].color then
			RemoveColor(encounterID, eventID)
			inputColor = "ffffff"
			colorPicker:SetColor(addon.Utilities:HexToRGB("ffffff"))
			addon.Utilities:print(string.format("%d-%d-Color: %s", encounterID, eventID, L["RemoveSuccess"]))
		else
			addon.Utilities:print(string.format("%d-%d-Color: %s", encounterID, eventID, L["RemoveFailed"]))
		end
	end)
end

local function RenderEncounterSettings(mapID, encounterID, container)
	for _, eventID in ipairs(addon.data.MAP_ENCOUNTER_EVENTS[mapID].encounters[encounterID].events) do
		local encounterSpellID = C_EncounterEvents.GetEventInfo(eventID).spellID
		local name = "UNKNOWN"
		local spell = nil
		if encounterSpellID then
			spell = Spell:CreateFromSpellID(encounterSpellID)
			name = string.format("|T%s:0|t %s(%d)", spell:GetSpellTexture(), spell:GetSpellName(), encounterSpellID)
		end
		local group = GUI:CreateInlineGroup(container, name)
		if spell then
			local description = GUI:CreateInformationTag(group, "UNKNOWN", "LEFT")
			spell:ContinueOnSpellLoad(function()
				description:SetText((spell:GetSpellDescription() or "UNKNOWN") .. "\n")
				group:DoLayout()
			end)
		end
		CreateTimelineSettings(encounterID, eventID, group)
	end
end

-- GUI
GUI.TagPanels.EncounterSound = {}
function GUI.TagPanels.EncounterSound:CreateTabPanel(parent)
	-- MARK: General
	local frame = GUI:CreateScrollFrame(parent)

    GUI:CreateInformationTag(frame, L["EncounterSoundSettingsDesc"], "LEFT")
	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["EncounterSoundSettings"] .. "|r", addon.db.EncounterSound.Enabled, function(value)
		addon.db.EncounterSound.Enabled = value
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
	GUI:CreateDropdown(frame, L["SoundChannelSettings"], addon.Utilities.SoundChannels, nil, addon.db.EncounterSound.SoundChannel, function(key)
        addon.db.EncounterSound.SoundChannel = key
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

    -- MARK: Setting Part
	local inputMap, inputEncounter = nil, nil
	local selectGroup = GUI:CreateInlineGroup(frame, L["Select"])
	GUI:CreateInformationTag(selectGroup, L["EncounterSoundInstruction"], "LEFT")
	local settingsGroup = GUI:CreateInlineGroup(nil, L["EncounterSettings"])
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