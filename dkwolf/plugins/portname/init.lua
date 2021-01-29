-- license:BSD-3-Clause
-- copyright-holders:Carl
-- data files are json files named <romname>.json
-- {
--   "ports":{
--     "<ioport name>":{
--       "labels":{
--         "player":<int player number>,
--         "name":"<field label>"
--     },{
--       ...
--     }
--   }
-- }
-- any additional metadata can be included for other usage
-- and will be ignored
local exports = {}
exports.name = "portname"
exports.version = "0.0.1"
exports.description = "IOPort name/translation plugin"
exports.license = "The BSD 3-Clause License"
exports.author = { name = "Carl" }

local portname = exports

function portname.startplugin()
	local json = require("json")
	local ctrlrpath = lfs.env_replace(manager:options().entries.ctrlrpath:value():match("([^;]+)"))
	local function get_filename(nosoft)
		local filename
		if emu.softname() ~= "" and not nosoft then
			filename = emu.romname() .. "_" .. emu.softname() .. ".json"
		else
			filename = emu.romname() .. ".json"
		end
		return filename
	end

	emu.register_start(function()
		local file = emu.file(ctrlrpath .. "/portname", "r")
		local ret = file:open(get_filename())
		if ret then
			ret = file:open(get_filename(true))
			if ret then
				ret = file:open(manager:machine():system().parent .. ".json")
				if ret then
					return
				end
			end
		end
		local ctable = json.parse(file:read(file:size()))
		for pname, port in pairs(ctable.ports) do
			local ioport = manager:machine():ioport().ports[pname]
			if ioport then
				for mask, label in pairs(port.labels) do
					for num3, field in pairs(ioport.fields) do
						if tonumber(mask) == field.mask and label.player == field.player then
							field.live.name = label.name
						end
					end
				end
			end
		end
	end)

	local function menu_populate()
		return {{ _("Save input names to file"), "", 0 }}
	end

	local function menu_callback(index, event)
		if event == "select" then
			local ports = {}
			for pname, port in pairs(manager:machine():ioport().ports) do
				local labels = {}
				ports[pname] = { labels = labels }
				for fname, field in pairs(port.fields) do
					if not labels[field.mask] then
						labels[field.mask] = { name = fname, player = field.player }
					end
				end
			end
			local function check_path(path)
				local attr = lfs.attributes(path)
				if not attr then
					lfs.mkdir(path)
					if not lfs.attributes(path) then
						manager:machine():popmessage(_("Failed to save input name file"))
						emu.print_verbose("portname: unable to create path " .. path .. "\n")
						return false
				end
				elseif attr.mode ~= "directory" then
					manager:machine():popmessage(_("Failed to save input name file"))
					emu.print_verbose("portname: path exists but isn't directory " .. path .. "\n")
					return false
				end
				return true
			end
			if not check_path(ctrlrpath) then
				return false
			end
			if not check_path(ctrlrpath .. "/portname") then
				return false
			end
			local filename = get_filename()
			local file = io.open(ctrlrpath .. "/portname/" .. filename, "r")
			if file then
				emu.print_verbose("portname: input name file exists " .. filename .. "\n")
				manager:machine():popmessage(_("Failed to save input name file"))
				file:close()
				return false
			end
			file = io.open(ctrlrpath .. "/portname/" .. filename, "w")
			local ctable = { romname = emu.romname(), ports = ports }
			if emu.softname() ~= "" then
				ctable.softname = emu.softname()
			end
			file:write(json.stringify(ctable, { indent = true }))
			file:close()
			manager:machine():popmessage(string.format(_("Input port name file saved to %s"), ctrlrpath .. "/portname/" .. filename))
		end
		return false
	end

	emu.register_menu(menu_callback, menu_populate, _("Input ports"))
end

return exports
