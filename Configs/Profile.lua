local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local Serialize = LibStub:GetLibrary("AceSerializer-3.0")
local Compress = LibStub:GetLibrary("LibDeflate")

---Get modules list with locales(some old locales are not in formats)
---@return table<string, string> list key is module key, value is localized name
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

    -- MARK: General Profile
    local generalProfileGroup = GUI:CreateInlineGroup(frame, L["Profile"])
    GUI:CreateInformationTag(generalProfileGroup, L["ProfileSettingsDesc"], "LEFT")
    GUI:CreateMultiLineEditBox(generalProfileGroup, L["Export/Import"], addon:ExportProfile(), function (value)
        addon:ImportProfile(value)
    end)

    -- MARK: Module Profile
    local modProfileGroup = GUI:CreateInlineGroup(frame, L["ModuleProfile"])
    GUI:CreateInformationTag(modProfileGroup, L["ModuleProfileDesc"], "LEFT")
    GUI:CreateInformationTag(modProfileGroup, "\n")
    local modBox = GUI:CreateMultiLineEditBox(nil, L["Export/Import"], "", function (value)
        local mod = value:match("!HBLyx_Tools_(%w+)_")
        if not mod or mod == "" then
            addon.Utilities:print("Invalid module profile string.")
            return
        end

        addon:ImportModuleProfile(value, mod)
    end)

    GUI:CreateDropDown(modProfileGroup, L["SelectModule"], GetModuleNameList(), "", false, function(key)
        modBox:SetText(addon:ExportModuleProfile(key))
    end)
    GUI:CreateInformationTag(modProfileGroup, "\n", "LEFT")

    modProfileGroup:AddChild(modBox)

    return frame
end

-- MARK: Profile Export

---Export all profiles
---@return string|nil export profile string or nil if no profile data
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

---Export profile for the module
---@param mod string key for the module
---@return string|nil export profile string or nil if no profile data for the module
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

-- MARK: Profile Import

---Import all profiles
---@param data string profile string to import
---@return boolean success if the import was successful
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

    return true
end

---Import module profile
---@param data string module profile string to import
---@param mod string key for the module
---@return boolean success if the import was successful
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

    return true
end