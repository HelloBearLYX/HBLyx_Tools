local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class GossipHelper
local GossipHelper = {
    modName = "GossipHelper",
    db = nil,
}

-- MARK: Constants
local CURRENT_SEASON_GOSSIP = {
    -- Den of Nalorakk
    [135009] = true,
    [135010] = true,
    [137693] = true,
    [137702] = true,
	-- Murder Row
    [131502] = true,
    [131567] = true,
	-- The Blinding Vale
    [137222] = true,
	-- Temple of Sethraliss
    [48126] = true,
	-- Altar of Fangs
    [141729] = true,
    [141730] = true,
}


--- Auto choose gossip if the gossip is in the data or season data
---@param self GossipHelper
---@param gossipID number the gossipID to check
local function AutoSelectGossip(self, gossipID)
    if (self.db["EnabledSeasonGossip"] and CURRENT_SEASON_GOSSIP[gossipID]) or self.db["data"][gossipID] then
        C_GossipInfo.SelectOption(gossipID)
    end
end

--- Get gossipID from the gossipOptionInfo
---@param gossipOptionInfo table the gossip option info
---@return number|nil the gossipID or nil if not found
local function GetGossipID(gossipOptionInfo)
    local output = nil
    -- first try to get the gossipID
    if gossipOptionInfo and gossipOptionInfo.gossipOptionID then
        output = gossipOptionInfo.gossipOptionID
    -- try the gossip order
    elseif gossipOptionInfo and tonumber(gossipOptionInfo.orderIndex) then
        local order = tonumber(gossipOptionInfo.orderIndex)
        if order > 0 then
            output = order
        end
    end

    return output
end

local function InitializeGossipOptionHook(self)
    hooksecurefunc(_G.GossipOptionButtonMixin, "Setup", function(button, info)
        if not self.db["ShowGossipID"] then return end

        local gossipID = GetGossipID(info)
        if gossipID then
            button:SetText(button:GetText() .. " |cff828282[" .. gossipID .. "]|r")
        end
    end)
end

-- MARK: Initialize

---Initialize (Constructor)
---@return GossipHelper GossipHelper a GossipHelper object
function GossipHelper:Initialize()
    self.eventFrame = CreateFrame("Frame", ADDON_NAME .. self.modName, UIParent)
    self.db = addon.db[self.modName]
    InitializeGossipOptionHook(self)

    return self
end
-- MARK: RegisterEvents

---Register events
function GossipHelper:RegisterEvents()
    addon.core:RegisterEvent("GOSSIP_SHOW", self.eventFrame, self.modName)

    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "GOSSIP_SHOW" then
            local infos = C_GossipInfo.GetOptions()
            for _, info in ipairs(infos) do
                local gossipID = info.gossipOptionID or 0


                AutoSelectGossip(self, gossipID)
            end
        end
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(GossipHelper.modName, function() return GossipHelper:Initialize() end)