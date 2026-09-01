local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "GossipHelper"

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = true,
    EnabledSeasonGossip = true,
    ShowGossipID = true,
    data = {}, -- data = {gossipID = true, ...}
}

-- MARK: Helpers
local function EnsureGossipDB()
    addon.db[MOD_KEY] = addon.db[MOD_KEY] or {}
    addon.db[MOD_KEY].data = addon.db[MOD_KEY].data or {}

    -- saved variables may keep the gossipID as a string key, normalize them to numbers
    for gossipKey, value in pairs(addon.db[MOD_KEY].data) do
        local normalized = tonumber(gossipKey)
        if normalized and normalized ~= gossipKey then
            addon.db[MOD_KEY].data[normalized] = value
            addon.db[MOD_KEY].data[gossipKey] = nil
        end
    end
end

local function FetchGossipList()
    EnsureGossipDB()
    local list = {}
    local order = {}
    for gossipID in pairs(addon.db[MOD_KEY].data) do
        local key = tostring(gossipID)
        list[key] = key
        table.insert(order, key)
    end
    table.sort(order, function(a, b)
        return (tonumber(a) or 0) < (tonumber(b) or 0)
    end)

    return list, order
end

-- GUI
GUI.TagPanels.GossipHelper = {}
function GUI.TagPanels.GossipHelper:CreateTabPanel(parent)
    EnsureGossipDB()
    local frame = parent

    GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["GossipHelperSettings"] .. "|r", addon.db[MOD_KEY].Enabled, function(value)
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
            "|cffC41E3A" .. L["GossipHelperSettings"] .. "|r: " .. L["ComfirmResetMod"],
            true,
            {button1 = YES, button2 = NO, OnButton1 = function()
                addon.Utilities:ResetModule(MOD_KEY)
                ReloadUI()
            end}
        )
    end)

    -- MARK: Basic settings
    local basicGroup = GUI:CreateInlineGroup(frame, L["BasicSettings"])
    GUI:CreateInformationTag(basicGroup, L["GossipSeasonDesc"], "LEFT")
    GUI:CreateToggleCheckBox(basicGroup, L["GossipSeasonEnable"], addon.db[MOD_KEY].EnabledSeasonGossip, function(value)
        addon.db[MOD_KEY].EnabledSeasonGossip = value
    end)
    
    GUI:CreateInformationTag(basicGroup, L["GossipShowIDDesc"], "LEFT")
    GUI:CreateToggleCheckBox(basicGroup, L["GossipShowID"], addon.db[MOD_KEY].ShowGossipID, function(value)
        addon.db[MOD_KEY].ShowGossipID = value
    end)

    -- MARK: Gossip list
    local gossipGroup = GUI:CreateInlineGroup(frame, L["GossipListSettings"])
    GUI:CreateInformationTag(gossipGroup, L["GossipListDesc"], "LEFT")

    local gossipSelected
    local gossipSelection
    local gossipEditBox

    gossipSelection = GUI:CreateDropdown(gossipGroup, L["SelectGossipID"], FetchGossipList(), nil, "", function(key)
        gossipSelected = key ~= "" and tonumber(key) or nil
        gossipEditBox:SetText(gossipSelected and tostring(gossipSelected) or "")
    end)
    gossipEditBox = GUI:CreateEditBox(gossipGroup, L["GossipID"], "", nil)

    GUI:CreateInformationTag(gossipGroup, "\n", "LEFT")
    GUI:CreateButton(gossipGroup, L["Add"], function()
        local gossipID = tonumber(strtrim(gossipEditBox:GetText() or ""))
        if not gossipID or gossipID <= 0 then
            addon.Utilities:SetPopupDialog(ADDON_NAME .. "InvalidInput", L["InvalidGossipID"], true)
            return
        end

        if addon.db[MOD_KEY].data[gossipID] then
            addon.Utilities:print(string.format("%s-" .. L["AddFailed"], gossipID))
            return
        end

        addon.db[MOD_KEY].data[gossipID] = true
        gossipSelected = gossipID
        gossipSelection:SetList(FetchGossipList())
        gossipSelection:SetValue(tostring(gossipID))
        addon.Utilities:print(string.format("%s-" .. L["AddSuccess"], gossipID))
    end)

    GUI:CreateButton(gossipGroup, L["Remove"], function()
        local gossipID = gossipSelected
        if not gossipID or not addon.db[MOD_KEY].data[gossipID] then
            addon.Utilities:print(L["RemoveFailed"])
            return
        end

        addon.db[MOD_KEY].data[gossipID] = nil
        gossipSelected = nil
        gossipSelection:SetList(FetchGossipList())
        gossipSelection:SetValue("")
        gossipEditBox:SetText("")
        addon.Utilities:print(string.format("%s-" .. L["RemoveSuccess"], gossipID))
    end)

    return frame
end
