local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "TalentReminder"
local MOD_LABEL = L["TalentReminderSettings"] or "Talent Reminder"

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = true,
	IconSize = 35,
    Font = "",
    FontSize = 14,
    MissingText = L["Missing"] .. ":",
	X = -130,
	Y = 285,
	FrameStrata = "MEDIUM",
    data = {} -- {instanceID = {spellID = {spec1 = true, spec2 = true, ...}}}
}

-- MARK: Safe update
local function update()
	return addon.core:GetSafeUpdate(MOD_KEY)()
end

-- MARK: Notify Data Changed

local function NotifyDataChanged()
	local module = addon.core:GetModule(MOD_KEY)
	if module and module.head then
		local onEvent = module.head:GetScript("OnEvent")
		if onEvent then
			onEvent(module.head, "TRAIT_CONFIG_UPDATED")
		end
	end
end

-- MARK: Get Dungeon List
local function GetDungeonList()
    local list = {}
    for dungeonID, info in pairs(addon.data.DUNGEONS) do
        local mapIcon = select(6, EJ_GetInstanceInfo(dungeonID)) or 134400
        if info.enabled then
            list[info.instanceID] =  "|T" .. mapIcon .. ":0|t " .. info.name
        end
    end
    return list
end

-- MARK: Input Data Helpers

local function FetchExistingEntries(instanceID)
	local output = {}
	if not instanceID then
		return output
	end

	for spellID, _ in pairs(addon.db[MOD_KEY].data[instanceID] or {}) do
		output[spellID] = addon.Utilities:GetSpellIconString(spellID)
	end

	return output
end

local function FetchEntryInfo(instanceID, spellID)
	if not instanceID or not spellID then
		return nil
	end

	local database = addon.db[MOD_KEY].data
    if database[instanceID] and database[instanceID][spellID] then
        return database[instanceID][spellID]
    end
end

local function AddEntry(instanceID, spellID, loadingSpecs)
	local data = addon.db[MOD_KEY].data
	local existed = false

	if not data[instanceID] then
		data[instanceID] = {}
	end

	existed = data[instanceID][spellID] ~= nil

	if loadingSpecs then
		local copiedSpecs = {}
		for specID, isEnabled in pairs(loadingSpecs) do
			if isEnabled then
				copiedSpecs[specID] = true
			end
		end
		data[instanceID][spellID] = copiedSpecs
	else
		data[instanceID][spellID] = {}
	end

	return existed
end

local function RemoveEntry(instanceID, spellID)
	local data = addon.db[MOD_KEY].data
	local spellMap = data[instanceID]
	if not spellMap or not spellMap[spellID] then
		return false
	end

	spellMap[spellID] = nil

	if not next(spellMap) then
		data[instanceID] = nil
	end

	return true
end

-- GUI
GUI.TagPanels.TalentReminder = {}
function GUI.TagPanels.TalentReminder:CreateTabPanel(parent)
	-- MARK: General
	local frame = GUI:CreateScrollFrame(parent)
	frame:SetLayout("Flow")
	frame:SetFullWidth(true)

	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. MOD_LABEL .. "|r", addon.db[MOD_KEY].Enabled, function(value)
		addon.db[MOD_KEY].Enabled = value
		if addon.core:HasModuleLoaded(MOD_KEY) then
			if not value then
				addon:ShowDialog(ADDON_NAME .. "RLNeeded")
			end
		else
			if value then
				addon.core:LoadModule(MOD_KEY)
				addon.core:TestModule(MOD_KEY)
			end
		end
	end)

	GUI:CreateButton(frame, L["ResetMod"], function ()
		addon.Utilities:SetPopupDialog(
			ADDON_NAME .. "ResetMod",
			"|cffC41E3A" .. MOD_LABEL .. "|r: " .. L["ComfirmResetMod"],
			true,
			{button1 = YES, button2 = NO, OnButton1 = function ()
				addon.Utilities:ResetModule(MOD_KEY)
				ReloadUI()
			end}
		)
	end)

    -- MARK: Data Settings
    local inputGroup = GUI:CreateInlineGroup(frame, L["General"])
	GUI:CreateInformationTag(inputGroup, L["TalentInputRequirement"], "LEFT")
	local instanceSelected = nil
	local dungeonLabel = L["SelectDungeon"] or "Select Dungeon"
	local spellLabel = L["SpellIDInput"] or L["SpellID"] or "Spell ID"
	local existingLabel = L["SelectTalentReminder"] or L["SelectAura"] or "Select Existing Entry"
	local instanceSelection
	local spellInput
	local specsSelection
    local existingSelection

	existingSelection = GUI:CreateDropdown(nil, existingLabel, FetchExistingEntries(instanceSelected), nil, "", function(key)
		local spellID = tonumber(key)
		local loadingSpecs = FetchEntryInfo(instanceSelected, spellID)
		if spellID and loadingSpecs then
			spellInput:SetText(tostring(spellID))
			specsSelection:SetSelectedSpecs(loadingSpecs)
		else
			spellInput:SetText("")
			specsSelection:ClearSpecSelection()
		end
	end)

    local currentInstance = addon.states.instanceInfo.instanceID ~= 0 and addon.states.instanceInfo.instanceID or nil
	instanceSelected = currentInstance
    if currentInstance then existingSelection:SetList(FetchExistingEntries(currentInstance)) end
	instanceSelection = GUI:CreateDropdown(nil, dungeonLabel, GetDungeonList(), nil, currentInstance, function(value)
        instanceSelected = value
        existingSelection:SetList(FetchExistingEntries(instanceSelected))
        existingSelection:SetValue("")
        spellInput:SetText("")
        specsSelection:ClearSpecSelection()
    end)

	spellInput = GUI:CreateEditBox(nil, spellLabel, "", nil)
	specsSelection = GUI:CreateSpecSelectDropdown(nil, L["LoadingSpecs"])
	specsSelection:GetWidget():SetRelativeWidth(0.45)
	local clearSpecsButton = GUI:CreateButton(nil, L["ClearSpecsSelection"], function ()
		specsSelection:ClearSpecSelection()
	end)
    local addButton
    local removeButton

    inputGroup:AddChild(instanceSelection)
    GUI:CreateInformationTag(inputGroup, "\n")
    inputGroup:AddChild(existingSelection)
    inputGroup:AddChild(spellInput)
    GUI:CreateInformationTag(inputGroup, "\n")
	inputGroup:AddChild(specsSelection:GetWidget())
	inputGroup:AddChild(clearSpecsButton)
	GUI:CreateInformationTag(inputGroup, "\n")

    addButton = GUI:CreateButton(nil, L["Add"], function()
		local spellID = tonumber(spellInput:GetText())
		if not spellID or spellID <= 0 or spellID % 1 ~= 0 then
			addon.Utilities:SetPopupDialog(ADDON_NAME .. "InvalidInput", L["InvalidSpellID"], true)
			return
		end

		if not C_Spell.GetSpellInfo(spellID) then
			addon.Utilities:SetPopupDialog(ADDON_NAME .. "InvalidInput", L["SpellIDNotFound"], true)
			return
		end

        local specsSelected = specsSelection:GetSelectedSpecs()
		if not instanceSelected then
            addon.Utilities:SetPopupDialog(ADDON_NAME.."InvalidInput", L["InvalidInput"], true)
            return
        end

		if not specsSelected then
			addon.Utilities:SetPopupDialog(ADDON_NAME .. "InvalidInput", L["InvalidInput"], true)
			return
		end

		local isUpdate = AddEntry(instanceSelected, spellID, specsSelected)
		NotifyDataChanged()

		existingSelection:SetList(FetchExistingEntries(instanceSelected))
		existingSelection:SetValue(spellID)

		local spellIconString = addon.Utilities:GetSpellIconString(spellID)
		if isUpdate then
			addon.Utilities:print(string.format("%s-" .. L["UpdateSuccess"], spellIconString))
		else
			addon.Utilities:print(string.format("%s-" .. L["AddSuccess"], spellIconString))
		end
	end)

	removeButton = GUI:CreateButton(nil, L["Remove"], function()
		local spellID = tonumber(spellInput:GetText())
		if not spellID or spellID <= 0 or spellID % 1 ~= 0 or not instanceSelected then
			addon.Utilities:print(L["RemoveFailed"])
			return
		end

		if RemoveEntry(instanceSelected, spellID) then
			NotifyDataChanged()

			existingSelection:SetList(FetchExistingEntries(instanceSelected))
			existingSelection:SetValue("")
			spellInput:SetText("")
			specsSelection:ClearSpecSelection()
			addon.Utilities:print(string.format("%s-" .. L["RemoveSuccess"], addon.Utilities:GetSpellIconString(spellID)))
		else
			addon.Utilities:print(string.format("%s-" .. L["RemoveFailed"], addon.Utilities:GetSpellIconString(spellID)))
		end
    end)

	inputGroup:AddChild(addButton)
	inputGroup:AddChild(removeButton)

	-- MARK: Style Settings
	local styleGroup = GUI:CreateInlineGroup(frame, L["StyleSettings"])
	GUI:CreateFrameStrataDropdown(styleGroup, addon.db[MOD_KEY].FrameStrata, function(value)
		addon.db[MOD_KEY].FrameStrata = value
		update()
	end)
    local fontGroup = GUI:CreateInlineGroup(styleGroup, L["FontSettings"])
    GUI:CreateFontSelect(fontGroup, L["Font"], addon.db[MOD_KEY]["Font"], function(value)
        addon.db[MOD_KEY]["Font"] = value
        update()
    end)
    GUI:CreateSlider(fontGroup, L["FontSize"], 6, 30, 1, addon.db[MOD_KEY]["FontSize"], function(value)
        addon.db[MOD_KEY]["FontSize"] = value
        update()
    end)
    GUI:CreateEditBox(fontGroup, L["MissingText"], addon.db[MOD_KEY]["MissingText"], function(value)
        addon.db[MOD_KEY]["MissingText"] = value
        update()
    end)

	local iconGroup = GUI:CreateInlineGroup(styleGroup, L["IconSettings"])
	GUI:CreateSlider(iconGroup, L["IconSize"], 10, 120, 1, addon.db[MOD_KEY].IconSize, function(value)
		addon.db[MOD_KEY].IconSize = value
		update()
	end)

	local positionGroup = GUI:CreateInlineGroup(styleGroup, L["PositionSettings"])
	GUI:CreateSlider(positionGroup, L["X"], -2000, 2000, 1, addon.db[MOD_KEY].X, function(value)
		addon.db[MOD_KEY].X = value
		update()
	end)
	GUI:CreateSlider(positionGroup, L["Y"], -1000, 1000, 1, addon.db[MOD_KEY].Y, function(value)
		addon.db[MOD_KEY].Y = value
		update()
	end)

	return frame
end
