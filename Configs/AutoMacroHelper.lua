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
}

---Sync spell/target state and the generated macro if the module is currently loaded
local function RefreshMacro()
    local mod = addon.core:GetModule(MOD_KEY)
    if mod then
        mod:SearchTarget()
        mod:UpdateMacro()
    end
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

	return parent
end

GUI:RegisterModule(MOD_KEY, RenderPanel)