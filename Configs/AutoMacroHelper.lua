local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "AutoMacroHelper"

local CLASS_MISDIRECTION = {
    HUNTER = {spellID = 34477, role = "TANK"},
    ROGUE = {spellID = 57934, role = "TANK"},
    DRUID = {spellID = 29166, role = "HEALER"},
    PRIEST = {spellID = 10060, role = "DAMAGER"}
}
-- fixed display order, pairs() iteration order is not guaranteed
local CLASS_ORDER = {"HUNTER", "ROGUE", "DRUID", "PRIEST"}

local function GenerateDefaultData()
    -- data are CLASS = {Enabled = boolean, Target = string}
    local output = {}
    for class, data in pairs(CLASS_MISDIRECTION) do
        output[class] = {Enabled = true, Target = data.role}
    end
    return output
end

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = true,
    Data = GenerateDefaultData(),
    PotionEnabled = true,
    CustomPotions = {},
}

---Sync spell/target state and both the "HBT_AutoMacro" and "HBT_Potion" macros, if the module is currently loaded
local function RefreshMacro()
    local mod = addon.core:GetModule(MOD_KEY)
    if mod then
        mod:SearchTarget()
        mod:UpdateMacro()
        mod:UpdatePotionMacro()
    end
end

---Sync the "HBT_Potion" macro with the currently detected combat potion, if the module is currently loaded
local function RefreshPotionMacro()
    local mod = addon.core:GetModule(MOD_KEY)
    if mod then
        mod:UpdatePotionMacro()
    end
end

---Build the dropdown list/order of the user's custom combat potions, keyed by itemID
local function FetchCustomPotionList()
    local list, order = {}, {}
    for _, itemID in ipairs(addon.db.AutoMacroHelper.CustomPotions) do
        local name = C_Item.GetItemNameByID(itemID)
        list[itemID] = name and string.format("%s (%d)", name, itemID) or tostring(itemID)
        table.insert(order, itemID)
    end
    return list, order
end

-- GUI
local function RenderPanel(parent)
	-- MARK: General
	GUI:CreateToggleCheckBox(parent, L["Enable"] .. "|cff0070DD" .. L["AutoMacroHelperSettings"] .. "|r", addon.db.AutoMacroHelper.Enabled, function(value)
		addon.db.AutoMacroHelper.Enabled = value
		addon.core:ToggleModule(MOD_KEY, value)
	end)
	GUI:CreateResetModButton(parent, MOD_KEY, L["AutoMacroHelperSettings"])

    GUI:CreateLinebreaker(parent)
	GUI:CreateButton(parent, L["MDHelperGenerateMacro"], RefreshMacro)
	-- MARK: Per-class spells
	local spellGroup = GUI:CreateInlineGroup(parent, L["AutoMacroHelperSettings"])
	GUI:CreateInformationTag(spellGroup, L["MDHelperTargetDesc"], "LEFT")
	for _, class in ipairs(CLASS_ORDER) do
		local classData = CLASS_MISDIRECTION[class]
		local entry = addon.db.AutoMacroHelper.Data[class]
		local spellInfo = C_Spell.GetSpellInfo(classData.spellID)
		local label = spellInfo and (("|T" .. spellInfo.iconID .. ":0|t ") .. spellInfo.name) or class

		GUI:CreateToggleCheckBox(spellGroup, label, entry.Enabled, function(value)
			entry.Enabled = value
			RefreshMacro()
		end)
		GUI:CreateEditBox(spellGroup, L["MDHelperTarget"], entry.Target, function(value)
			entry.Target = value
			RefreshMacro()
		end)
		GUI:CreateLinebreaker(spellGroup)
	end

	-- MARK: Potion macro
	local potionGroup = GUI:CreateInlineGroup(parent, L["PotionMacroSettings"])
	GUI:CreateInformationTag(potionGroup, L["PotionMacroDesc"], "LEFT")
	GUI:CreateToggleCheckBox(potionGroup, L["Enable"] .. L["PotionMacroSettings"], addon.db.AutoMacroHelper.PotionEnabled, function(value)
		addon.db.AutoMacroHelper.PotionEnabled = value
		RefreshPotionMacro()
	end)

	local potionSelected = nil
	local potionSelection
	local potionIDInput

	GUI:CreateLinebreaker(potionGroup)
	local initialPotionList, initialPotionOrder = FetchCustomPotionList()
	potionSelection = GUI:CreateDropdown(potionGroup, L["CustomPotionList"], initialPotionList, initialPotionOrder, "", function(key)
		potionSelected = key ~= "" and key or nil
	end)

	potionIDInput = GUI:CreateEditBox(potionGroup, L["CustomPotionID"], "", nil)

	GUI:CreateLinebreaker(potionGroup)
	GUI:CreateButton(potionGroup, L["Add"], function()
		local itemID = tonumber(strtrim(potionIDInput:GetText() or ""))
		if not itemID or itemID <= 0 or itemID % 1 ~= 0 then
			addon.Utilities:SetPopupDialog(ADDON_NAME .. "InvalidInput", L["InvalidPotionItemID"], true)
			return
		end

		for _, existing in ipairs(addon.db.AutoMacroHelper.CustomPotions) do
			if existing == itemID then
				addon.Utilities:print(L["PotionAlreadyAdded"])
				return
			end
		end

		table.insert(addon.db.AutoMacroHelper.CustomPotions, itemID)
		potionIDInput:SetText("")
		potionSelection:SetList(FetchCustomPotionList())
		RefreshPotionMacro()
	end)

	GUI:CreateButton(potionGroup, L["Remove"], function()
		if not potionSelected then return end

		for i, existing in ipairs(addon.db.AutoMacroHelper.CustomPotions) do
			if existing == potionSelected then
				table.remove(addon.db.AutoMacroHelper.CustomPotions, i)
				break
			end
		end

		potionSelected = nil
		potionSelection:SetList(FetchCustomPotionList())
		potionSelection:SetValue("")
		RefreshPotionMacro()
	end)

	return parent
end

GUI:RegisterModule(MOD_KEY, RenderPanel)