local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "AuraHelper"
local MOD_LABEL = L["AuraHelperSettings"] or "Aura Helper"

GUI.TagPanels.AuraHelper = {}

-- MARK: Defaults
addon.configurationList[MOD_KEY] = addon.configurationList[MOD_KEY] or {
	Enabled = true,
	data = {},
	dataSound = {}, -- {spellID = {trigger = soundLSM}}
}

local DEFAULT_CONTAINER = {
	Type = "Helpful",
	IconSize = 35,
	MaxCount = 5,
	IconSpacing = 0,
	GrowDirection = "RIGHT",
	X = 0,
	Y = 0,
	Filters = {},
}

local GROW_DIRECTIONS = addon.Utilities.Grows
local GROW_ORDER = {"LEFT", "RIGHT"}

local SOUND_TRIGGERS = {
	[0] = L["AuraSoundTrigger"]["Add"],
	[1] = L["AuraSoundTrigger"]["Apply"],
	[2] = L["AuraSoundTrigger"]["Remove"],
}
local SOUND_TRIGGER_ORDER = {0, 1, 2}

local TYPE_LIST = {
	Helpful = (L["AuraFilter"] and L["AuraFilter"]["Helpful"]) or "Helpful",
	Harmful = (L["AuraFilter"] and L["AuraFilter"]["Harmful"]) or "Harmful",
}
local TYPE_ORDER = {"Helpful", "Harmful"}
local TYPE_CATEGORY = {
	Helpful = "Buff",
	Harmful = "Debuff",
}
local FILTER_META = {
	Player = "Both",
	NonPlayer = "Both",
	Raid = "Both",
	Defensive = "Buff",
	CrowdControl = "Debuff",
	Dispellable = "Both",
	PI = "Buff",
	Role = "Both",
	Priority = "Both",
	Stealable = "Both",
	Boss = "Both",
}
local FILTER_LOCALE_KEY = {
	PI = "Power_Infusion",
}

local function CloneTable(t)
	local result = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			local nested = {}
			for nk, nv in pairs(v) do
				nested[nk] = nv
			end
			result[k] = nested
		else
			result[k] = v
		end
	end
	return result
end

local function EnsureAuraDB()
	addon.db[MOD_KEY] = addon.db[MOD_KEY] or {}
	addon.db[MOD_KEY].data = addon.db[MOD_KEY].data or {}
	addon.db[MOD_KEY].dataSound = addon.db[MOD_KEY].dataSound or {}
	for spellKey, triggerMap in pairs(addon.db[MOD_KEY].dataSound) do
		local normalizedSpellKey = tonumber(spellKey)
		if normalizedSpellKey and normalizedSpellKey ~= spellKey and type(triggerMap) == "table" then
			addon.db[MOD_KEY].dataSound[normalizedSpellKey] = addon.db[MOD_KEY].dataSound[normalizedSpellKey] or {}
			for triggerKey, soundName in pairs(triggerMap) do
				local normalizedTriggerKey = tonumber(triggerKey) or triggerKey
				addon.db[MOD_KEY].dataSound[normalizedSpellKey][normalizedTriggerKey] = soundName
			end
			addon.db[MOD_KEY].dataSound[spellKey] = nil
		end
	end
	for spellKey, triggerMap in pairs(addon.db[MOD_KEY].dataSound) do
		if type(triggerMap) == "table" then
			for triggerKey, soundName in pairs(triggerMap) do
				local normalizedTriggerKey = tonumber(triggerKey) or triggerKey
				if normalizedTriggerKey ~= triggerKey then
					triggerMap[normalizedTriggerKey] = soundName
					triggerMap[triggerKey] = nil
				end
			end
		end
	end
	if addon.db[MOD_KEY].Enabled == nil then
		addon.db[MOD_KEY].Enabled = true
	end
end

local function FetchTypeList()
	local module = addon.core:GetModule(MOD_KEY)
	if module and module.GetTypeList then
		local list, order = module:GetTypeList()
		if type(list) == "table" and type(order) == "table" then
			return list, order
		end
	end

	return TYPE_LIST, TYPE_ORDER
end

local function FetchFilterList(auraType)
	local module = addon.core:GetModule(MOD_KEY)
	if module and module.GetFilterList then
		local list, order = module:GetFilterList(auraType)
		if type(list) == "table" and type(order) == "table" then
			return list, order
		end
	end

	local category = TYPE_CATEGORY[auraType or ""]
	local list = {}
	local order = {}
	for filterName, filterCategory in pairs(FILTER_META) do
		if (not category) or filterCategory == "Both" or filterCategory == category then
			local localeKey = FILTER_LOCALE_KEY[filterName] or filterName
			list[filterName] = (L["AuraFilter"] and L["AuraFilter"][localeKey]) or filterName
			table.insert(order, filterName)
		end
	end
	table.sort(order)

	return list, order
end

local function FetchContainerList()
	EnsureAuraDB()
	local list = {}
	local order = {}
	for key in pairs(addon.db[MOD_KEY].data) do
		list[key] = key
		table.insert(order, key)
	end
	table.sort(order)
	return list, order
end

local function FetchSoundList()
	EnsureAuraDB()
	local list = {}
	local order = {}
	for spellId in pairs(addon.db[MOD_KEY].dataSound) do
		local key = tostring(spellId)
		list[key] = key
		table.insert(order, key)
	end
	table.sort(order, function(a, b)
		return tonumber(a) < tonumber(b)
	end)
	return list, order
end

local function ApplyUpdate(methodName, key)
	local module = addon.core:GetModule(MOD_KEY)
	if module and module[methodName] then
		module[methodName](module, key)
	end
end

local function AddContainer(key, auraType)
	EnsureAuraDB()
	if key == nil or key == "" or addon.db[MOD_KEY].data[key] then
		return false
	end

	local options = CloneTable(DEFAULT_CONTAINER)
	options.Type = auraType or DEFAULT_CONTAINER.Type
	addon.db[MOD_KEY].data[key] = options

	local module = addon.core:GetModule(MOD_KEY)
	if module then
		module:AddContainer(key)
	end
	return true
end

local function RemoveContainer(key)
	EnsureAuraDB()
	if key == nil or key == "" or not addon.db[MOD_KEY].data[key] then
		return false
	end

	addon.db[MOD_KEY].data[key] = nil
	local module = addon.core:GetModule(MOD_KEY)
	if module then
		module:RemoveContainer(key)
	end
	return true
end

local function NormalizeSoundTrigger(value)
	if value == nil then
		return nil
	end
	if type(value) == "number" then
		return value
	end
	local num = tonumber(value)
	return num ~= nil and num or value
end

local function GetSoundTriggerLabel(trigger)
	local normalized = NormalizeSoundTrigger(trigger)
	if normalized == nil then
		return ""
	end

	local label = SOUND_TRIGGERS[normalized]
	if not label and type(normalized) ~= "number" then
		label = SOUND_TRIGGERS[tonumber(normalized)]
	end

	return label or tostring(normalized)
end

local function ResolveSoundSpellKey(dataSound, spellId)
	if not dataSound or spellId == nil then
		return nil
	end

	local spellNum = tonumber(spellId)
	local spellStr = tostring(spellId)

	if spellNum and dataSound[spellNum] ~= nil then
		return spellNum
	end
	if dataSound[spellStr] ~= nil then
		return spellStr
	end

	return spellNum or spellStr
end

function GUI.TagPanels.AuraHelper:CreateTabPanel(parent)
	EnsureAuraDB()
	local frame = parent

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

	GUI:CreateButton(frame, L["ResetMod"], function()
		addon.Utilities:SetPopupDialog(
			ADDON_NAME .. "ResetMod",
			"|cffC41E3A" .. MOD_LABEL .. "|r: " .. L["ComfirmResetMod"],
			true,
			{button1 = YES, button2 = NO, OnButton1 = function()
				addon.Utilities:ResetModule(MOD_KEY)
				ReloadUI()
			end}
		)
	end)

	-- Container settings
	local containerGroup = GUI:CreateInlineGroup(frame, L["General"])
	GUI:CreateInformationTag(containerGroup, L["AuraContainerDesc"], "LEFT")

	local containerSelected = nil
	local typeSelected = nil
	local containerSelection
	local nameInput
	local typeSelection
	local filtersSelection
	local growSelection
	local maxCountSlider
	local iconSizeSlider
	local iconSpacingSlider
	local xSlider
	local ySlider

	local function BuildFilterSelectionMap(filters)
		local selected = {}
		for _, name in pairs(filters or {}) do
			selected[name] = true
		end
		return selected
	end

	local function RefreshFilterList()
		if not typeSelected then
			if filtersSelection and filtersSelection.GetWidget then
				filtersSelection:GetWidget():SetList({}, {})
			end
			return
		end

		local filterList, filterOrder = FetchFilterList(typeSelected)
		if filtersSelection and filtersSelection.GetWidget then
			filtersSelection:GetWidget():SetList(filterList, filterOrder)
		end
	end

	local function RefreshOptions()
		local options = containerSelected and addon.db[MOD_KEY].data[containerSelected] or DEFAULT_CONTAINER

		typeSelected = options.Type or "Helpful"
		typeSelection:SetValue(typeSelected)
		RefreshFilterList()
		if filtersSelection then
			if containerSelected then
				filtersSelection:SetSelectedKeys(BuildFilterSelectionMap(options.Filters or {}))
			else
				filtersSelection:SetSelectedKeys({})
			end
		end
		growSelection:SetValue(options.GrowDirection or "RIGHT")
		maxCountSlider:SetValue(options.MaxCount or 5)
		iconSizeSlider:SetValue(options.IconSize or 35)
		iconSpacingSlider:SetValue(options.IconSpacing or 0)
		xSlider:SetValue(options.X or 0)
		ySlider:SetValue(options.Y or 0)
	end

	containerSelection = GUI:CreateDropdown(containerGroup, L["SelectAuraContainer"], FetchContainerList(), nil, "", function(key)
		containerSelected = key ~= "" and key or nil
		nameInput:SetText(containerSelected or "")
		RefreshOptions()
	end)

	nameInput = GUI:CreateEditBox(containerGroup, L["AuraContainerName"], "", nil)

	typeSelection = GUI:CreateDropdown(containerGroup, L["AuraType"], FetchTypeList(), nil, "", function(value)
		typeSelected = value
		if not containerSelected then
			RefreshFilterList()
			return
		end

		if not addon.db[MOD_KEY].data[containerSelected] then
			return
		end

		addon.db[MOD_KEY].data[containerSelected].Type = value

		local allowed = FetchFilterList(value)
		local filters = {}
		for _, name in pairs(addon.db[MOD_KEY].data[containerSelected].Filters or {}) do
			if allowed[name] then
				table.insert(filters, name)
			end
		end
		addon.db[MOD_KEY].data[containerSelected].Filters = filters
		RefreshFilterList()
		if filtersSelection then filtersSelection:SetSelectedKeys(BuildFilterSelectionMap(filters)) end
		ApplyUpdate("UpdateFilter", containerSelected)
	end)

	GUI:CreateInformationTag(containerGroup, "\n", "LEFT")
	GUI:CreateButton(containerGroup, L["Add"], function()
		local key = strtrim(nameInput:GetText() or "")
		if key == "" or key:find("[^%w_]") then
			addon.Utilities:SetPopupDialog(ADDON_NAME .. "InvalidInput", L["InvalidAuraContainerName"], true)
			return
		end

		if not typeSelected then
			addon.Utilities:SetPopupDialog(ADDON_NAME .. "InvalidInput", L["AuraTypeRequired"], true)
			return
		end

		if not AddContainer(key, typeSelected) then
			addon.Utilities:print(string.format("%s-" .. L["AddFailed"], key))
			return
		end

		containerSelected = key
		containerSelection:SetList(FetchContainerList())
		containerSelection:SetValue(key)
		RefreshOptions()
		addon.Utilities:print(string.format("%s-" .. L["AddSuccess"], key))
	end)

	GUI:CreateButton(containerGroup, L["Remove"], function()
		local key = containerSelected
		if not RemoveContainer(key) then
			addon.Utilities:print(L["RemoveFailed"])
			return
		end

		containerSelected = nil
		containerSelection:SetList(FetchContainerList())
		containerSelection:SetValue("")
		nameInput:SetText("")
		RefreshOptions()
		addon.Utilities:print(string.format("%s-" .. L["RemoveSuccess"], key))
	end)

	-- Selected container settings
	local optionsGroup = GUI:CreateInlineGroup(frame, L["AuraContainerSettings"])
	GUI:CreateInformationTag(optionsGroup, L["AuraFilterDesc"], "LEFT")

	local filterList, filterOrder = FetchFilterList()
	filtersSelection = GUI:CreateMultiDropdown(optionsGroup, L["AuraFilters"], filterList, filterOrder, nil)
	filtersSelection:GetWidget():SetOnValueChanged(function()
		if not containerSelected then return end

		local filters = {}
		for name, isSelected in pairs(filtersSelection:GetSelectedKeys() or {}) do
			if isSelected then
				table.insert(filters, name)
			end
		end

		addon.db[MOD_KEY].data[containerSelected].Filters = filters
		ApplyUpdate("UpdateFilter", containerSelected)
	end)

	growSelection = GUI:CreateDropdown(optionsGroup, L["Grow"], GROW_DIRECTIONS, GROW_ORDER, "RIGHT", function(value)
		if not containerSelected then return end

		addon.db[MOD_KEY].data[containerSelected].GrowDirection = value
		ApplyUpdate("UpdateGrowDirection", containerSelected)
	end)

	local iconGroup = GUI:CreateInlineGroup(optionsGroup, L["IconSettings"])
	maxCountSlider = GUI:CreateSlider(iconGroup, L["MaxCount"], 1, 20, 1, 5, function(value)
		if not containerSelected then return end

		addon.db[MOD_KEY].data[containerSelected].MaxCount = value
		ApplyUpdate("UpdateMaxCount", containerSelected)
	end)
	iconSizeSlider = GUI:CreateSlider(iconGroup, L["IconSize"], 10, 120, 1, 35, function(value)
		if not containerSelected then return end

		addon.db[MOD_KEY].data[containerSelected].IconSize = value
		ApplyUpdate("UpdateLayout", containerSelected)
	end)
	iconSpacingSlider = GUI:CreateSlider(iconGroup, L["IconSpacing"], -10, 30, 1, 0, function(value)
		if not containerSelected then return end

		addon.db[MOD_KEY].data[containerSelected].IconSpacing = value
		ApplyUpdate("UpdateLayout", containerSelected)
	end)

	local positionGroup = GUI:CreateInlineGroup(optionsGroup, L["PositionSettings"])
	xSlider = GUI:CreateSlider(positionGroup, L["X"], -2000, 2000, 1, 0, function(value)
		if not containerSelected then return end

		addon.db[MOD_KEY].data[containerSelected].X = value
		ApplyUpdate("UpdatePosition", containerSelected)
	end)
	ySlider = GUI:CreateSlider(positionGroup, L["Y"], -1000, 1000, 1, 0, function(value)
		if not containerSelected then return end

		addon.db[MOD_KEY].data[containerSelected].Y = value
		ApplyUpdate("UpdatePosition", containerSelected)
	end)

	RefreshOptions()

	-- Sound settings
	local soundGroup = GUI:CreateInlineGroup(frame, L["AuraSoundSettings"])
	GUI:CreateInformationTag(soundGroup, L["AuraSoundDesc"], "LEFT")

	local soundSelected
	local triggerSelected
	local soundLSMSelected
	local soundEditBox
	local soundTriggerDropdown
	local soundMediaDropdown
	local soundSelectionDropdown

	local function RefreshSoundSelectionDisplay()
		if not soundSelected then
			if soundEditBox then soundEditBox:SetText("") end
			triggerSelected = nil
			soundLSMSelected = nil
			if soundTriggerDropdown then soundTriggerDropdown:SetValue("") end
			if soundMediaDropdown then soundMediaDropdown:SetValue("") end
			return
		end

		local dataSound = addon.db[MOD_KEY].dataSound
		local spellKey = ResolveSoundSpellKey(dataSound, soundSelected)
		local soundEntry = (spellKey and dataSound[spellKey]) or {}
		local firstTrigger, firstSound = nil, nil
		for trigger, soundName in pairs(soundEntry) do
			firstTrigger = trigger
			firstSound = soundName
			break
		end

		if soundEditBox then soundEditBox:SetText(tostring(soundSelected)) end
		triggerSelected = firstTrigger
		soundLSMSelected = firstSound
		if soundTriggerDropdown then soundTriggerDropdown:SetValue(firstTrigger or "") end
		if soundMediaDropdown then soundMediaDropdown:SetValue(firstSound or "") end
	end

	local function RefreshSoundPanel()
		if soundSelectionDropdown then
			soundSelectionDropdown:SetList(FetchSoundList())
			soundSelectionDropdown:SetValue("")
		end
		soundSelected = nil
		RefreshSoundSelectionDisplay()
	end

	soundSelectionDropdown = GUI:CreateDropdown(soundGroup, L["SelectAuraSound"], FetchSoundList(), nil, "", function(key)
		soundSelected = key ~= "" and tonumber(key) or nil
		RefreshSoundSelectionDisplay()
	end)
	soundEditBox = GUI:CreateEditBox(soundGroup, L["AuraSpellID"], "", nil)
	soundTriggerDropdown = GUI:CreateDropdown(soundGroup, L["SoundTriggers"], SOUND_TRIGGERS, SOUND_TRIGGER_ORDER, "", function(value)
		triggerSelected = NormalizeSoundTrigger(value)
		local dataSound = addon.db[MOD_KEY].dataSound
		local spellKey = ResolveSoundSpellKey(dataSound, soundSelected)
		if soundSelected and spellKey and dataSound[spellKey] then
			local normalizedTrigger = NormalizeSoundTrigger(value)
			soundLSMSelected = dataSound[spellKey][normalizedTrigger]
			if soundMediaDropdown then
				soundMediaDropdown:SetValue(soundLSMSelected or "")
			end
		end
	end)
	soundMediaDropdown = GUI:CreateSoundSelect(soundGroup, L["AuraSoundMedia"], "", function(value)
		soundLSMSelected = value
	end)

	GUI:CreateInformationTag(soundGroup, "\n", "LEFT")
	GUI:CreateButton(soundGroup, L["Add"], function()
		local key = strtrim(soundEditBox:GetText() or "")
		local spellId = tonumber(key)
		local dataSound = addon.db[MOD_KEY].dataSound
		if not dataSound then
			addon.db[MOD_KEY].dataSound = {}
			dataSound = addon.db[MOD_KEY].dataSound
		end
		if key == "" or not spellId or spellId <= 0 then
			addon.Utilities:SetPopupDialog(ADDON_NAME .. "InvalidInput", L["InvalidAuraSpellID"], true)
			return
		elseif not triggerSelected or triggerSelected == "" then
			addon.Utilities:SetPopupDialog(ADDON_NAME .. "InvalidInput", L["AuraSoundTriggerRequired"], true)
			return
		elseif not soundLSMSelected or soundLSMSelected == "" then
			addon.Utilities:SetPopupDialog(ADDON_NAME .. "InvalidInput", L["AuraSoundMediaRequired"], true)
			return
		end

		local triggerKey = NormalizeSoundTrigger(triggerSelected)
		local spellKey = ResolveSoundSpellKey(dataSound, spellId)
		if spellKey == nil then
			addon.Utilities:SetPopupDialog(ADDON_NAME .. "InvalidInput", L["InvalidAuraSpellID"], true)
			return
		end
		local soundBucket = dataSound[spellKey]
		if type(soundBucket) ~= "table" then
			soundBucket = {}
			dataSound[spellKey] = soundBucket
		end

		soundBucket[triggerKey] = soundLSMSelected
		local module = addon.core:GetModule(MOD_KEY)
		if module then
			module:AddSound(spellKey, triggerKey, soundLSMSelected)
		end

		soundSelected = spellId
		soundSelectionDropdown:SetList(FetchSoundList())
		soundSelectionDropdown:SetValue(spellId)
		RefreshSoundSelectionDisplay()
		addon.Utilities:print(string.format("%s-%s-" .. L["AddSuccess"], spellId, GetSoundTriggerLabel(triggerKey)))
	end)

	GUI:CreateButton(soundGroup, L["Remove"], function()
		if not soundSelected then return end

		local spellId = tonumber(soundSelected)
		local removedTrigger = NormalizeSoundTrigger(triggerSelected)
		local module = addon.core:GetModule(MOD_KEY)
		local dataSound = addon.db[MOD_KEY].dataSound
		if not dataSound then
			return
		end

		local spellKey = ResolveSoundSpellKey(dataSound, spellId)

		if removedTrigger ~= nil and spellKey and dataSound[spellKey] and dataSound[spellKey][removedTrigger] ~= nil then
			if module then
				module:RemoveSound(spellKey, removedTrigger)
			else
				dataSound[spellKey][removedTrigger] = nil
				if not next(dataSound[spellKey] or {}) then
					dataSound[spellKey] = nil
				end
			end
		else
			if module then
				module:RemoveSound(spellKey or spellId)
			end
			if spellKey and dataSound[spellKey] then
				dataSound[spellKey] = nil
			end
		end

		RefreshSoundPanel()
		addon.Utilities:print(string.format("%s-%s-" .. L["RemoveSuccess"], spellId, GetSoundTriggerLabel(removedTrigger)))
	end)

	return frame
end
