local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "EncounterSound"

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = true,
	SoundChannel = "Master",
	EnablePrivateAuras = true,
	data = {}, -- data structure: { [encounterID] = { [eventID] = { [trigger] = {sound = sound, role = {role = true}}, color = color} } }
	dataPA = {}, -- data structure: { [encounterID] = { [spellID] = sound } }
}

-- MARK: Constants
local EVENT_TRIGGERS = {
	[0] = L["OnTextWarningShown"],
	[1] = L["OnTimelineEventFinished"],
	[2] = L["OnTimelineEventHighlight"],
}

-- MARK: Adds
local function AddSound(encounterID, eventID, trigger, sound, role)
	local isNew = false
	if not addon.db.EncounterSound.data then
		addon.db.EncounterSound.data = {}
	end

	if not addon.db.EncounterSound.data[encounterID] then
		addon.db.EncounterSound.data[encounterID] = {}
	end

	if not addon.db.EncounterSound.data[encounterID][eventID] then
		addon.db.EncounterSound.data[encounterID][eventID] = {}
	end

	isNew = not addon.db.EncounterSound.data[encounterID][eventID][trigger]
	addon.db.EncounterSound.data[encounterID][eventID][trigger] = { sound = sound, role = role and {} or nil}
	if role then -- make a deep copy since other trigger may use the same role table reference
		for role, _ in pairs(role or {}) do
			addon.db.EncounterSound.data[encounterID][eventID][trigger].role[role] = true
		end
	end

	if isNew then
		addon.Utilities:print(string.format("%d-%d-%s-%s: %s", encounterID, eventID, EVENT_TRIGGERS[trigger], sound, L["AddSuccess"]))
	else
		addon.Utilities:print(string.format("%d-%d-%s-%s: %s", encounterID, eventID, EVENT_TRIGGERS[trigger], sound, L["UpdateSuccess"]))
	end
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

local function AddPASound(encounterID, spellID, sound)
	if not addon.db.EncounterSound.dataPA then
		addon.db.EncounterSound.dataPA = {}
	end

	if not addon.db.EncounterSound.dataPA[encounterID] then
		addon.db.EncounterSound.dataPA[encounterID] = {}
	end

	addon.db.EncounterSound.dataPA[encounterID][spellID] = sound

	addon.Utilities:print(string.format("%d-%d-%s: %s", encounterID, spellID, sound, L["AddSuccess"]))
end

-- MARK: Removes
local function RemoveSound(encounterID, eventID, trigger)
	if addon.db.EncounterSound.data and addon.db.EncounterSound.data[encounterID] and addon.db.EncounterSound.data[encounterID][eventID] and addon.db.EncounterSound.data[encounterID][eventID][trigger] then
		addon.db.EncounterSound.data[encounterID][eventID][trigger] = nil
		if not next(addon.db.EncounterSound.data[encounterID][eventID]) then
			addon.db.EncounterSound.data[encounterID][eventID] = nil
		end
		if not next(addon.db.EncounterSound.data[encounterID]) then
			addon.db.EncounterSound.data[encounterID] = nil
		end
		addon.Utilities:print(string.format("%d-%d-%s: %s", encounterID, eventID, EVENT_TRIGGERS[trigger], L["RemoveSuccess"]))
		return true
	end

	return false
end

local function RemoveColor(encounterID, eventID)
	if addon.db.EncounterSound.data and addon.db.EncounterSound.data[encounterID] and addon.db.EncounterSound.data[encounterID][eventID] then
		addon.db.EncounterSound.data[encounterID][eventID].color = nil
		if not next(addon.db.EncounterSound.data[encounterID][eventID]) then
			addon.db.EncounterSound.data[encounterID][eventID] = nil
		end
		if not next(addon.db.EncounterSound.data[encounterID]) then
			addon.db.EncounterSound.data[encounterID] = nil
		end
		addon.Utilities:print(string.format("%d-%d-Color: %s", encounterID, eventID, L["RemoveSuccess"]))
		return true
	else
		addon.Utilities:print(string.format("%d-%d-Color: %s", encounterID, eventID, L["RemoveFailed"]))
		return false
	end
end

local function RemovePASound(encounterID, spellID)
	if addon.db.EncounterSound.dataPA and addon.db.EncounterSound.dataPA[encounterID] and addon.db.EncounterSound.dataPA[encounterID][spellID] then
		addon.db.EncounterSound.dataPA[encounterID][spellID] = nil
		if not next(addon.db.EncounterSound.dataPA[encounterID]) then
			addon.db.EncounterSound.dataPA[encounterID] = nil
		end
		addon.Utilities:print(string.format("%d-%d: %s", encounterID, spellID, L["RemoveSuccess"]))
		return true
	else
		addon.Utilities:print(string.format("%d-%d: %s", encounterID, spellID, L["RemoveFailed"]))
		return false
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
	local roleSelect = GUI:CreateMultiDropdown(nil, L["SelectGroupRole"], addon.Utilities.GroupRoles, nil, nil)
	local soundSelect = GUI:CreateSoundSelect(nil, L["EncounterEventSound"], nil, function(key)
		inputSound = key
	end)
	GUI:CreateDropdown(soundGroup, L["EncounterEventTrigger"], EVENT_TRIGGERS, nil, nil, function(value)
		inputTrigger = value
		if addon.db.EncounterSound.data and addon.db.EncounterSound.data[encounterID] and addon.db.EncounterSound.data[encounterID][eventID] and addon.db.EncounterSound.data[encounterID][eventID][inputTrigger] then
			inputSound = addon.db.EncounterSound.data[encounterID][eventID][inputTrigger].sound
			if addon.db.EncounterSound.data[encounterID][eventID][inputTrigger].role then
				roleSelect:SetSelectedKeys(addon.db.EncounterSound.data[encounterID][eventID][inputTrigger].role)
			end
			soundSelect:SetValue(inputSound)
		else
			inputSound = nil
			soundSelect:SetValue(nil)

			roleSelect:ClearSelections()
		end
	end)
	soundGroup:AddChild(roleSelect:GetWidget())
	soundGroup:AddChild(soundSelect)
	GUI:CreateButton(soundGroup, L["Add"], function()
		if inputTrigger and inputSound then
			AddSound(encounterID, eventID, inputTrigger, inputSound, roleSelect:GetSelectedKeys())
		else
			addon.Utilities:print(L["AddFailed"])
		end
	end)
	GUI:CreateButton(soundGroup, L["Remove"], function()
		if RemoveSound(encounterID, eventID, inputTrigger) then
			inputSound = nil
			soundSelect:SetValue(nil)
			roleSelect:ClearSelections()
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
			if RemoveColor(encounterID, eventID) then
				inputColor = "ffffff"
				colorPicker:SetColor(addon.Utilities:HexToRGB("ffffff"))
			end
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
			name = string.format("|T%s:0|t %s(%s)", spell:GetSpellTexture(), spell:GetSpellName(), L["EncounterEvent"])
		end
		
		local group = GUI:CreateInlineGroup(container, name)
		
		if spell then
			local description = GUI:CreateInformationTag(group, "UNKNOWN", "LEFT")
			spell:ContinueOnSpellLoad(function()
				description:SetText((spell:GetSpellDescription() or "UNKNOWN") .. "\n")
			end)
		end
		CreateTimelineSettings(encounterID, eventID, group)
	end
end

local function CreatePrivateAuraSettings(encounterID, spellID, container)
    local currentSound = addon.db.EncounterSound.dataPA and addon.db.EncounterSound.dataPA[encounterID] and addon.db.EncounterSound.dataPA[encounterID][spellID] or nil
    local soundSelect = GUI:CreateSoundSelect(container, L["SoundSettings"], currentSound, function (value)
        AddPASound(encounterID, spellID, value)
    end)
    GUI:CreateButton(container, L["Remove"], function ()
        if RemovePASound(encounterID, spellID) then
            soundSelect:SetValue(nil)
        end
    end)
end

local function RenderPrivateAuraSettings(mapID, encounterID, container)
	for _, spellID in ipairs(addon.data.MAP_ENCOUNTER_EVENTS[mapID].encounters[encounterID].privateAuras) do
		local spell = Spell:CreateFromSpellID(spellID) or nil
		local name = "UNKNOWN"
		if spell then
			name = string.format("|T%s:0|t %s(%s)", spell:GetSpellTexture(), spell:GetSpellName(), L["PrivateAura"])
		end
		
		local group = GUI:CreateInlineGroup(container, name)
		local description = GUI:CreateInformationTag(group, "UNKNOWN", "LEFT")
		
		if spell then
			spell:ContinueOnSpellLoad(function()
				description:SetText((spell:GetSpellDescription() or "UNKNOWN") .. "\n")
			end)
		end
		CreatePrivateAuraSettings(encounterID, spellID, group)
	end
end

-- GUI
GUI.TagPanels.EncounterSound = {}
function GUI.TagPanels.EncounterSound:CreateTabPanel(parent)
	-- MARK: General
	local frame = GUI:CreateScrollFrame(parent)

    GUI:CreateInformationTag(frame, L["EncounterSoundSettingsDesc"], "LEFT")
	local togglePA = GUI:CreateToggleCheckBox(nil, L["Enable"] .. "|cffffff00" .. L["PrivateAuraSettings"] .. "|r", addon.db.EncounterSound.EnablePrivateAuras, function(value)
		addon.db.EncounterSound.EnablePrivateAuras = value
	end)
	togglePA:SetDisabled(not addon.db.EncounterSound.Enabled)
	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["EncounterSoundSettings"] .. "|r", addon.db.EncounterSound.Enabled, function(value)
		addon.db.EncounterSound.Enabled = value
		togglePA:SetDisabled(not value)
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
	frame:AddChild(togglePA)
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
	local privateAuraGroup = GUI:CreateInlineGroup(nil, L["PrivateAuraSettings"])
	local encounterGroup = 	GUI:CreateDropdown(nil, L["SelectEncounter"], {}, nil, nil, function (value)
		settingsGroup:ReleaseChildren()
		privateAuraGroup:ReleaseChildren()
		
		inputEncounter = value

		GUI:CreateInformationTag(settingsGroup, L["EncounterEventsInstruction"], "LEFT")
		RenderEncounterSettings(inputMap, inputEncounter, settingsGroup)
		GUI:CreateInformationTag(privateAuraGroup, L["PrivateAuraInstruction"], "LEFT")
		RenderPrivateAuraSettings(inputMap, inputEncounter, privateAuraGroup)
		
		C_Timer.After(0.5, function() frame:DoLayout() end) -- make a latency for render to let spell info loaded
	end)
	GUI:CreateDropdown(selectGroup, L["SelectInstance"], GetMapsList(), nil, nil, function (value)
		inputMap = value
		local list = GetEncountersList(value)
		encounterGroup:SetList(list)
		encounterGroup:SetValue(nil)
		settingsGroup:ReleaseChildren()
		privateAuraGroup:ReleaseChildren()

		frame:DoLayout()
	end)
	selectGroup:AddChild(encounterGroup)
	selectGroup:AddChild(settingsGroup)
	selectGroup:AddChild(privateAuraGroup)

	return frame
end