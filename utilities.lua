local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class Utilities
addon.Utilities = {}

-- MARK: Enums

---@enum anchor anchor_To = anchor_From
addon.Utilities.Anchors = {
	LEFT = "LEFT",
	RIGHT = "RIGHT",
	TOP = "TOP",
	BOTTOM = "BOTTOM",
	TOPLEFT = "TOPLEFT",
	BOTTOMLEFT = "BOTTOMLEFT",
	TOPRIGHT = "TOPRIGHT",
	BOTTOMRIGHT = "BOTTOMRIGHT",
}

---@enum growDirection the direction to grow from anchor point
addon.Utilities.Grows = {
	LEFT = "LEFT",
	RIGHT = "RIGHT",
	UP = "UP",
	DOWN = "DOWN",
}

---@enum soundChannel sound channel
addon.Utilities.SoundChannels = {
	Master = L["SoundChannel"]["Master"],
	SFX = L["SoundChannel"]["SFX"],
	Music = L["SoundChannel"]["Music"],
	Ambience = L["SoundChannel"]["Ambience"],
	Dialog = L["SoundChannel"]["Dialog"],
}

---@enum addon.Utilities.Specializations class specializations
addon.Utilities.Specializations = {
	-- Death Knight
	[250] = L["Specializations"]["DeathKnight"]["Blood"], -- Blood
	[251] = L["Specializations"]["DeathKnight"]["Frost"], -- Frost
	[252] = L["Specializations"]["DeathKnight"]["Unholy"], -- Unholy
	-- Demon Hunter
	[577] = L["Specializations"]["DemonHunter"]["Havoc"], -- Havoc
	[581] = L["Specializations"]["DemonHunter"]["Vengeance"], -- Vengeance
	[1480] = L["Specializations"]["DemonHunter"]["Devourer"], -- Devourer
	-- Druid
	[102] = L["Specializations"]["Druid"]["Balance"], -- Balance
	[103] = L["Specializations"]["Druid"]["Feral"], -- Feral
	[104] = L["Specializations"]["Druid"]["Guardian"], -- Guardian
	[105] = L["Specializations"]["Druid"]["Restoration"], -- Restoration
	-- Evoker
	[1467] = L["Specializations"]["Evoker"]["Devastation"], -- Devastation
	[1468] = L["Specializations"]["Evoker"]["Preservation"], -- Preservation
	[1473] = L["Specializations"]["Evoker"]["Augmentation"], -- Augmentation
	-- Hunter
	[253] = L["Specializations"]["Hunter"]["BeastMastery"], -- BeastMastery
	[254] = L["Specializations"]["Hunter"]["Marksmanship"], -- Marksmanship
	[255] = L["Specializations"]["Hunter"]["Survival"], -- Survival
	-- Mage
	[62] = L["Specializations"]["Mage"]["Arcane"], -- Arcane
	[63] = L["Specializations"]["Mage"]["Fire"], -- Fire
	[64] = L["Specializations"]["Mage"]["Frost"], -- Frost
	-- Monk
	[268] = L["Specializations"]["Monk"]["Brewmaster"], -- Brewmaster
	[269] = L["Specializations"]["Monk"]["Windwalker"], -- Windwalker
	[270] = L["Specializations"]["Monk"]["Mistweaver"], -- Mistweaver
	-- Paladin
	[65] = L["Specializations"]["Paladin"]["Holy"], -- Holy
	[66] = L["Specializations"]["Paladin"]["Protection"], -- Protection
	[70] = L["Specializations"]["Paladin"]["Retribution"], -- Retribution
	-- Priest
	[256] = L["Specializations"]["Priest"]["Discipline"], -- Discipline
	[257] = L["Specializations"]["Priest"]["Holy"], -- Holy
	[258] = L["Specializations"]["Priest"]["Shadow"], -- Shadow
	-- Rogue
	[259] = L["Specializations"]["Rogue"]["Assassination"], -- Assassination
	[260] = L["Specializations"]["Rogue"]["Outlaw"], -- Outlaw
	[261] = L["Specializations"]["Rogue"]["Subtlety"], -- Subtlety
	-- Shaman
	[262] = L["Specializations"]["Shaman"]["Elemental"], -- Elemental
	[263] = L["Specializations"]["Shaman"]["Enhancement"], -- Enhancement
	[264] = L["Specializations"]["Shaman"]["Restoration"], -- Restoration
	-- Warlock
	[265] = L["Specializations"]["Warlock"]["Affliction"], -- Affliction
	[266] = L["Specializations"]["Warlock"]["Demonology"], -- Demonology
	[267] = L["Specializations"]["Warlock"]["Destruction"], -- Destruction
	-- Warrior
	[71] = L["Specializations"]["Warrior"]["Arms"], -- Arms
	[72] = L["Specializations"]["Warrior"]["Fury"], -- Fury
	[73] = L["Specializations"]["Warrior"]["Protection"], -- Protection
}

-- MARK: print

---Use addon's identifier to print
---@param message string message to print
function addon.Utilities:print(message)
	print("|cff8788ee" .. ADDON_NAME .. "|r: " .. message)
end

---Debug print
---@param message string debug message
---@param callback function? additional function to call after print
function addon:debug(message, callback)
	addon.Utilities:print("|cffff0000[Debug]|r " .. message)
	if callback then
		callback()
	end
end

-- MARK: RGB Handle

---Convert a Hex string into a RGBa
---@param hex string a hex color string(6 or 8)
---@return number r red
---@return number g green
---@return number b blue
---@return number a alpha
function addon.Utilities:HexToRGB(hex)
	if string.len(hex) == 8 then
		return tonumber("0x" .. hex:sub(3, 4)) / 255, tonumber("0x" .. hex:sub(5, 6)) / 255, tonumber("0x" .. hex:sub(7, 8)) / 255, tonumber("0x" .. hex:sub(1, 2)) / 255
	end

	return tonumber("0x" .. hex:sub(1, 2)) / 255, tonumber("0x" .. hex:sub(3, 4)) / 255, tonumber("0x" .. hex:sub(5, 6)) / 255
end

---Convert a RGBa(seperated) into a Hex string
---@param r number red
---@param g number green
---@param b number blue
---@param a? number alpha
---@return string hex a Hex string of the RGBa
function addon.Utilities:RGBToHex(r, g, b, a)
	r = math.ceil(255 * r)
	g = math.ceil(255 * g)
	b = math.ceil(255 * b)
	if not a then
		return string.format("FF%02x%02x%02x", r, g, b)
	end

	a = math.ceil(255 * a)
	return string.format("%02x%02x%02x%02x", a, r, g, b)
end

-- MARK: Position Handle

---Convert a screen position into a UIParent position
---@param x number x position(screen position)
---@param y number y position(screen position)
---@return number x x position(UIParent position)
---@return number y y position(UIParent position)
function addon.Utilities:ScreenPositionToUIPosition(x, y)
	local scale = UIParent:GetEffectiveScale()
	x, y = x / scale, y / scale
	
	local centerX = GetScreenWidth() / 2
	local centerY = GetScreenHeight() / 2

	return x - centerX, y - centerY
end

-- MARK: Get AnchorTo

---Get anchor_from by anchor_to
---@param anchorTo string anchor_to
---@return string anchor_from anchor_from
function addon.Utilities:GetAnchorFrom(anchorTo)
	if anchorTo == "LEFT" then
		return "RIGHT"
	elseif anchorTo == "RIGHT" then
		return "LEFT"
	elseif anchorTo == "TOP" then
		return "BOTTOM"
	elseif anchorTo == "BOTTOM" then
		return "TOP"
	elseif anchorTo == "TOPLEFT" then
		return "BOTTOMLEFT"
	elseif anchorTo == "BOTTOMLEFT" then
		return "TOPLEFT"
	elseif anchorTo == "TOPRIGHT" then
		return "BOTTOMRIGHT"
	elseif anchorTo == "BOTTOMRIGHT" then
		return "TOPRIGHT"
	else
		error("Invalid Input")
	end
end

-- MARK: Get anchors by grow direction

---GetGrowAnchor
---@param direction string Grow direction
---@return string anchorFrom anchor point to grow from
---@return string anchorTo anchor point to grow to
function addon.Utilities:GetGrowAnchors(direction)
	if direction == "LEFT" then
		return "RIGHT", "LEFT"
	elseif direction == "RIGHT" then
		return "LEFT", "RIGHT"
	elseif direction == "UP" then
		return "BOTTOM", "TOP"
	elseif direction == "DOWN" then
		return "TOP", "BOTTOM"
	else
		error("Invalid Input")
	end
end

-- MARK: Drag Position

---Make a "frame" object draggable for re-positioning
---@param frame frame Blizzard frame object
---@param mod string the mod to access addon profile(the mod key for the addon.db[mod])
---@param xKey string the option to access addon profile(the option key for the addon.db[mod][xKey])
---@param yKey string the option to access addon profile(the option key for the addon.db[mod][xKey])
---@param updateFunc function? additional function to call in update
function addon.Utilities:MakeFrameDragPosition(frame, mod, xKey, yKey, updateFunc)
	local function updatePosition(frame)
		local x, y = GetCursorPosition()
		x, y = addon.Utilities:ScreenPositionToUIPosition(x, y)
		x, y = math.floor(x + 0.5), math.floor(y + 0.5) -- round the position to integers

		frame:SetPoint("CENTER", UIParent, "CENTER", x, y)
		return x, y
	end

	frame:SetScript("OnMouseDown", function (self, button)
		if button == "LeftButton" and addon.core:IsTestOn() and not InCombatLockdown() then
			self.isDragging = true
			updatePosition(self)
		end
	end)

	frame:SetScript("OnMouseUp", function (self, button)
		if button == "LeftButton" and self.isDragging then
			self.isDragging = nil
			
			updatePosition(self)

			addon.db[mod][xKey], addon.db[mod][yKey] = updatePosition(self)
		end
	end)

	frame:SetScript("OnUpdate", function (self)
		if self.isDragging then
			updatePosition(self)
		end

		if updateFunc then
			updateFunc()
		end
	end)
end

---Create a drag region backgound for frame(especially non-texture like text frame)
---@param frame frame frame to take the drag region
---@return frame background drag region background
function addon.Utilities:CreateDragBackground(frame, name)
	local background = frame:CreateTexture(nil, "BACKGROUND")
	background:SetAllPoints()
	background:SetColorTexture(0, 0, 1, 0.5)
	background.text = frame:CreateFontString(nil, "OVERLAY")
	background.text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
	background.text:SetPoint("CENTER", background, "TOP", 0, 0)
	background.text:SetText(name or "")

	return background
end

function addon.Utilities:ReleaseDragBackground(background)
	background:Hide()
	if background.text then
		background.text:Hide()
		background.text = nil
	end
	background = nil
end

-- MARK: Popup Dialog

---@param dialogName string key stored in _G.StaticPopupDialogs
---@param text string text to show in the dialog
---@param show? boolean show this dialog immediately
---@param extraFields? table extra fields to set up this dialog
function addon.Utilities:SetPopupDialog(dialogName, text, show, extraFields)
	local popupDialogs = _G.StaticPopupDialogs
	if type(popupDialogs) ~= "table" then
		popupDialogs = {}
	end

	if type(popupDialogs[dialogName]) ~= "table" then
		popupDialogs[dialogName] = {}
	end

	popupDialogs[dialogName] = {
		text = text,
		button1 = CLOSE,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
	}

	if extraFields then
		for k, v in pairs(extraFields) do
			popupDialogs[dialogName][k] = v
		end
	end

	if show then
		StaticPopup_Show(dialogName)
	end
end

-- MARK: Reset Config

---Reset a module's settings into default
---@param mod string mod key
function addon.Utilities:ResetModule(mod)
	if addon.configurationList[mod] then
		for key, value in pairs(addon.configurationList[mod]) do
			addon.db[mod][key] = value
		end
	end
end

-- MARK: OpenURL

---Create pop a dialog with url which can be copied
---@param title string title
---@param url string url to show in the dialog
function addon.Utilities:OpenURL(title, url)
    local popupDialogs = _G.StaticPopupDialogs

    if type(popupDialogs) ~= "table" then
		popupDialogs = {}
	end

    if type(popupDialogs[ADDON_NAME .. "_OpenURL"]) ~= "table" then
        popupDialogs[ADDON_NAME .. "_OpenURL"] = {}
    end

    popupDialogs[ADDON_NAME .. "_OpenURL"] = {
        text = title or "",
        button1 = CLOSE,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        hasEditBox = true,
        OnShow = function(self)
            self.EditBox:SetText(url)
            self.EditBox:SetFocus()
            self.EditBox:HighlightText()
        end,
        editBoxWidth = 300,
    }

    StaticPopup_Show(ADDON_NAME .. "_OpenURL")
end

-- MARK: Get Spell Icon String

---Get a Icon_Name(id) string by spell id
---@param spellID integer spell id
---@return string output a Icon_Name(id) string
function addon.Utilities:GetSpellIconString(spellID)
	if not spellID then return tostring(spellID) end

	local info = C_Spell.GetSpellInfo(spellID)
	local name = info and info.name or "UNKNOWN"
	local icon = info and info.iconID and "|T" .. info.iconID .. ":0|t" or ""
	
	return string.format("%s%s(%d)", icon, name, spellID)
end