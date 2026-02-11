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

---@enum
addon.Utilities.Grows = {
	LEFT = "LEFT",
	RIGHT = "RIGHT",
	UP = "UP",
	DOWN = "DOWN",
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

-- MARK: Spell2Icon

---Get Icon ID Through Spell ID
---@param spellID integer spellID
---@return integer? iconID return iconID or nil for error
function addon.Utilities:SpellToIcon(spellID)
	if spellID then
		local spellInfo = C_Spell.GetSpellInfo(spellID)
		if  spellID then
			return spellInfo.iconID
		end
	end

	return nil
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
		if button == "LeftButton" and addon.isTestMode and not InCombatLockdown() then
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