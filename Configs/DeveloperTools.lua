local ADDON_NAME, addon = ...

local optionMap = addon.Utilities:MakeOptionGroup("Developer Tools", {
    addon.Utilities:MakeButtonOption("Print Addon Info", function ()
			addon.DeveloperTools:DisplayAddonInfo()
	end, {desc = "Click twice to close and erase outputs"})
}, false, {order = addon:OptionOrderHandler()})

addon:AppendOptionsList("Developer Tools", optionMap)