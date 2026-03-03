local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local Serialize = LibStub:GetLibrary("AceSerializer-3.0")
local Compress = LibStub:GetLibrary("LibDeflate")
local prefix = "!HBLyx_Tools_EncounterSound_"

-- GUI
GUI.TagPanels.EncounterSound = {}
function GUI.TagPanels.EncounterSound:CreateTabPanel(parent)
	local function ExportProfile()
		if not addon.db["EncounterSound"] then return "" end

		local profile = addon.db["EncounterSound"]

		local profileData = { ["EncounterSound"] = profile, }

		local serializedData = Serialize:Serialize(profileData)
		local compressedData = Compress:CompressDeflate(serializedData)
		local encodedData = Compress:EncodeForPrint(compressedData)
		return prefix .. encodedData
	end

	local frame = GUI:CreateScrollFrame(parent)
    frame:SetLayout("Flow")

    -- MARK: General Profile
    local generalProfileGroup = GUI:CreateInlineGroup(frame, L["Profile"])
    GUI:CreateInformationTag(generalProfileGroup, L["dispatch_notification"], "LEFT")

	local curseForgeInteractive = LibStub("AceGUI-3.0"):Create("InteractiveLabel")
    curseForgeInteractive:SetText("|TInterface\\AddOns\\HBLyx_tools\\Media\\CurseForge.png:20:20|t |cFF8080FFHBLyx_Encounter_Sound|r")
    curseForgeInteractive:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    curseForgeInteractive:SetJustifyV("MIDDLE")
    curseForgeInteractive:SetRelativeWidth(0.25)
    curseForgeInteractive:SetCallback("OnClick", function() addon.Utilities:OpenURL("", "https://www.curseforge.com/wow/addons/hblyx-encounter-sound") end)
    curseForgeInteractive:SetCallback("OnEnter", function() curseForgeInteractive:SetText("|TInterface\\AddOns\\HBLyx_tools\\Media\\CurseForge.png:20:20|t |cFFFFFFFFHBLyx_Encounter_Sound|r") end)
    curseForgeInteractive:SetCallback("OnLeave", function() curseForgeInteractive:SetText("|TInterface\\AddOns\\HBLyx_tools\\Media\\CurseForge.png:20:20|t |cFF8080FFHBLyx_Encounter_Sound|r") end)
    generalProfileGroup:AddChild(curseForgeInteractive)

    local exportString = GUI:CreateMultiLineEditBox(generalProfileGroup, L["Export"], ExportProfile(), nil)

	GUI:CreateInformationTag(generalProfileGroup, L["clear_info"], "LEFT")
	GUI:CreateButton(generalProfileGroup, L["clear_profile"], function()
		addon.db["EncounterSound"] = nil
		exportString:SetText("")
	end)

    return frame
end