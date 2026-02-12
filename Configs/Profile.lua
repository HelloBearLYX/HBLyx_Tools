local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local Serialize = LibStub:GetLibrary("AceSerializer-3.0")
local Compress = LibStub:GetLibrary("LibDeflate")

local function GetModuleNameList()
    local list = addon.core:GetModuleList()
    local output = {}
    
    for _, key in ipairs(list) do -- handle some early developed locales
        if key == "CombatIndicator" then
            output[key] = L["CombatSettings"]
        elseif key == "CombatTimer" then
            output[key] = L["TimerSettings"]
        elseif key == "WarlockReminders" then
            output[key] = L["WarlockReminders"]
        else
            output[key] = L[key .. "Settings"]
        end
    end
    
    return output
end


GUI.TagPanels.Profile = {}
function GUI.TagPanels.Profile:CreateTabPanel(parent)
    local frame = GUI:CreateScrollFrame(parent)
    frame:SetLayout("Flow")

    local generalProfileGroup = GUI:CreateInlineGroup(frame, L["Profile"])
    GUI:CreateInformationTag(generalProfileGroup, L["ProfileSettingsDesc"], "LEFT")
    GUI:CreateMultiLineEditBox(generalProfileGroup, L["Export"], addon:ExportProfile(), nil)
    GUI:CreateMultiLineEditBox(generalProfileGroup, L["Import"], "", function(value)
        addon:ImportProfile(value)
    end)

    local modProfileGroup = GUI:CreateInlineGroup(frame, L["ModuleProfile"])
    GUI:CreateInformationTag(modProfileGroup, L["ModuleProfileDesc"], "LEFT")
    GUI:CreateInformationTag(modProfileGroup, "\n")
    local modExportBox = GUI:CreateMultiLineEditBox(modProfileGroup, L["Export"], "", nil)
    GUI:CreateMultiLineEditBox(modProfileGroup, L["Import"], "", function(value)
        local mod = value:match("!HBLyx_Tools_(%w+)_")
        addon:debug("mod: " .. mod)
        if not mod or mod == "" then
            addon.Utilities:print("Invalid module profile string.")
            return
        end

        addon:ImportModuleProfile(value, mod)
    end)
    GUI:CreateDropDown(modProfileGroup, L["SelectModule"], GetModuleNameList(), "", false, function(key)
        modExportBox:SetText(addon:ExportModuleProfile(key))
    end)

    return frame
end

function addon:ExportProfile()
    local profile = addon.db
    if not profile then
        addon.Utilities:print("No profile data to export.")
        return nil
    end

    local profileData = { profile = profile, }

    local serializedData = Serialize:Serialize(profileData)
    local compressedData = Compress:CompressDeflate(serializedData)
    local encodedData = Compress:EncodeForPrint(compressedData)
    return "!HBLyx_Tools_Profile_" .. encodedData
end

function addon:ExportModuleProfile(mod)
    local moduleProfile = addon.db[mod]
    if not moduleProfile then
        addon.Utilities:print(string.format("No profile data for the %s.", mod))
        return nil
    end

    local profileData = { [mod] = moduleProfile }

    local serializedData = Serialize:Serialize(profileData)
    local compressedData = Compress:CompressDeflate(serializedData)
    local encodedData = Compress:EncodeForPrint(compressedData)
    local prefix = "!HBLyx_Tools_" .. mod .. "_"
    return prefix .. encodedData
end

function addon:ImportProfile(data)
    local decodedData = Compress:DecodeForPrint(data:sub(22))
    local decompressedData = Compress:DecompressDeflate(decodedData)
    local success, profileData = Serialize:Deserialize(decompressedData)

    if not success or type(profileData) ~= "table" or data:sub(1, 21) ~= "!HBLyx_Tools_Profile_" then
        addon.Utilities:print("Invalid profile data.")
        return false
    end

    addon.db = profileData.profile
    addon.Utilities:print(L["ImportSuccess"])
end

function addon:ImportModuleProfile(data, mod)
    local prefix = "!HBLyx_Tools_" .. mod .. "_"
    local prefixLength = string.len(prefix)
    local decodedData = Compress:DecodeForPrint(data:sub(prefixLength + 1))
    local decompressedData = Compress:DecompressDeflate(decodedData)
    local success, profileData = Serialize:Deserialize(decompressedData)

    if not success or type(profileData) ~= "table" or data:sub(1, prefixLength) ~= prefix then
        addon.Utilities:print("Invalid module profile data.")
        return false
    end

    addon.db[mod] = profileData[mod]
    addon.Utilities:print(string.format("Module %s profile imported successfully.", mod))
end