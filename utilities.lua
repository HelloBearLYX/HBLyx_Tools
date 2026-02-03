local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class Utilities
addon.Utilities = {}

-- MARK: print

---Use addon's identifier to print
---@param message string message to print
function addon.Utilities:print(message)
	print("|cff8788ee" .. ADDON_NAME .. "|r: " .. message)
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

-- MARK: Create Options

---Make a option group for options in the optionList
---@param name string the group name
---@param args table the group tables contains options in it
---@param inline? boolean is this group is arranged in a line(DEFAULT: false)
---@param extraFields? table the update(callback) function apply after set this option
---@return table output a group table for AceConfig to register
function addon.Utilities:MakeOptionGroup(name, args, inline, extraFields)
	local order = 1

	local output = {
		name = name,
		inline = inline or false,
		type = "group",
		args = {}
	}

	for _, value in pairs(args) do
		value.order = order
		output.args[tostring(order) .. type(value)] = value
		order = order + 1
	end

	if extraFields then
		for k, v in pairs(extraFields) do
			output[k] = v
		end
	end

	return output
end

---Make a line break in the optionList
---@param hidden? function function to set this line break hidden
---@param width? number width of the line break
---@return table output a line break table for AceConfig to register
function addon.Utilities:MakeOptionLineBreak(hidden, width)
	local output = {
		type = "description",
		name = "\n",
		hidden = hidden or false
	}

	if width then
		output.width = width
	end

	return output
end

---Make a toggle option in the optionList
---@param name string the option name
---@param mod string the mod to access addon profile(the mod key for the addon.db[mod])
---@param key string the option to access addon profile(the option key for the addon.db[mod][key])
---@param update? function the update(callback) function apply after set this option
---@param extraFields? table extra fields to set up this option
---@return table output a created option table for AceConfig to register
function addon.Utilities:MakeToggleOption(name, mod, key, update, extraFields)
	local output = {
		type = "toggle",
		name = name,
		get = function (_)
			return addon.db[mod][key]
		end,
		set = function (_, val)
			addon.db[mod][key] = val
			if update then
				update()
			end
		end
	}

	if extraFields then
		for k, v in pairs(extraFields) do
			output[k] = v
		end
	end

	return output
end

---Make a range option in the optionList
---@param name string the option name
---@param mod string the mod to access addon profile(the mod key for the addon.db[mod])
---@param key string the option to access addon profile(the option key for the addon.db[mod][key])
---@param update? function the update(callback) function apply after set this option
---@param extraFields? table extra fields to set up this option
---@return table output a created option table for AceConfig to register
function addon.Utilities:MakeRangeOption(name, mod, key, min, max, step, update, extraFields)
	local output = {
		type = "range",
		name = name,
		min = min,
		max = max,
		step = step,
		get = function (_)
			return addon.db[mod][key]
		end,
		set = function (_, val)
			addon.db[mod][key] = val
			if update then
				update()
			end
		end
	}

	if extraFields then
		for k, v in pairs(extraFields) do
			output[k] = v
		end
	end

	return output
end

---Make a text input option in optionList
---@param name string the option name
---@param mod string the mod to access addon profile(the mod key for the addon.db[mod])
---@param key string the option to access addon profile(the option key for the addon.db[mod][key])
---@param update? function the update(callback) function apply after set this option
---@param extraFields? table extra fields to set up this option
---@return table output a created option table for AceConfig to register
function addon.Utilities:MakeInputOption(name, mod, key, update, extraFields)
	local output = {
		type = "input",
		name = name,
		get = function (_)
			return addon.db[mod][key]
		end,
		set = function (_, val)
			addon.db[mod][key] = val
			if update then
				update()
			end
		end
	}

	if extraFields then
		for k, v in pairs(extraFields) do
			output[k] = v
		end
	end

	return output
end

---Make a button option in the option List
---@param name string the button name
---@param func function function run after click the button
---@param extraFields? table extra fields to set up this option
---@return table output a created option tabble for AceConfig to register
function addon.Utilities:MakeButtonOption(name, func, extraFields)
	local output = {
		type = "execute",
		name = name,
		func = func
	}

	if extraFields then
		for k, v in pairs(extraFields) do
			output[k] = v
		end
	end

	return output
end

---Make a color pick option in the optionList
---@param name string the option name
---@param mod string the mod to access addon profile(the mod key for the addon.db[mod])
---@param key string the option to access addon profile(the option key for the addon.db[mod][key])
---@param update? function the update(callback) function apply after set this option
---@param extraFields? table extra fields to set up this option
---@return table output a created option table for AceConfig to register
function addon.Utilities:MakeColorOption(name, mod, key, update, extraFields)
	local output = {
		type = "color",
		name = name,
		get = function (_)
			local r, g, b, a = addon.Utilities:HexToRGB(addon.db[mod][key])
			return r, g, b, a or -1
		end,
		set = function (_, r, g, b, a)
			addon.db[mod][key] = addon.Utilities:RGBToHex(r, g, b, a)
			if update then
				update()
			end
		end
	}

	if extraFields then
		for k, v in pairs(extraFields) do
			output[k] = v
		end
	end

	return output
end

---Make a LSM Sound option in the optionList
---@param name string the option name
---@param mod string the mod to access addon profile(the mod key for the addon.db[mod])
---@param key string the option to access addon profile(the option key for the addon.db[mod][key])
---@param extraFields? table extra fields to set up this option
---@return table output a created option table for AceConfig to register
function addon.Utilities:MakeLSMSoundOption(name, mod, key, extraFields)
	local output = {
		type = "select",
		dialogControl = "LSM30_Sound",
		name = name,
		values = addon.LSM:HashTable("sound"),
		get = function (_)
			return addon.db[mod][key]
		end,
		set = function (_, v)
			addon.db[mod][key] = v
		end
	}

	if extraFields then
		for k, v in pairs(extraFields) do
			output[k] = v
		end
	end

	return output
end	

---Make a LSM Font option in the optionList
---@param name string the option name
---@param mod string the mod to access addon profile(the mod key for the addon.db[mod])
---@param key string the option to access addon profile(the option key for the addon.db[mod][key])
---@param update? function the update(callback) function apply after set this option
---@param extraFields? table extra fields to set up this option
---@return table output a created option table for AceConfig to register
function addon.Utilities:MakeLSMFontOption(name, mod, key, update, extraFields)
	local output = {
		type = "select",
		dialogControl = "LSM30_Font",
		name = name,
		values = addon.LSM:HashTable("font"),
		get = function (_)
			return addon.db[mod][key]
		end,
		set = function (_, v)
			addon.db[mod][key] = v
			if update then
				update()
			end
		end
	}

	if extraFields then
		for k, v in pairs(extraFields) do
			output[k] = v
		end
	end

	return output
end

---Make a LSM Texture option in the optionList
---@param name string the option name
---@param mod string the mod to access addon profile(the mod key for the addon.db[mod])
---@param key string the option to access addon profile(the option key for the addon.db[mod][key])
---@param update? function the update(callback) function apply after set this option
---@param extraFields? table extra fields to set up this option
---@return table output a created option table for AceConfig to register
function addon.Utilities:MakeLSMTextureOption(name, mod, key, update, extraFields)
	local output = {
		type = "select",
		dialogControl = "LSM30_Statusbar",
		name = name,
		values = addon.LSM:HashTable("statusbar"),
		get = function (_)
			return addon.db[mod][key]
		end,
		set = function (_, v)
			addon.db[mod][key] = v
			if update then
				update()
			end
		end
	}

	if extraFields then
		for k, v in pairs(extraFields) do
			output[k] = v
		end
	end

	return output
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

	if type(popupDialogs[dialogName] ~= "table") then
		popupDialogs[dialogName] = {
			text = text,
			button1 = CLOSE,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
		}
	end

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

---Make a reset mod option in the optionList 
---@param mod string mod key
---@param modName string modName
---@return table a created option table for AceConfig to register
function addon.Utilities:MakeResetOption(mod, modName)
	local output = addon.Utilities:MakeButtonOption(L["ResetMod"], function ()
		addon.Utilities:SetPopupDialog(
			ADDON_NAME .. "ResetMod",
			"|cffC41E3A" .. modName .. "|r: " .. L["ComfirmResetMod"],
			true,
			{button1 = YES, button2 = NO, OnButton1 = function ()
		    	addon.Utilities:ResetModule(mod)
				ReloadUI()
			end})
	end)

	return output
end