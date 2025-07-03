-- Janky 3D Plugin for MAME
-- by Jon Wilson (10yard)
--
-- Minimum start up arguments:
--   mame dkong -plugin janky3d
-----------------------------------------------------------------------------------------
local exports = {
	name = "janky3d",
	version = "0.1",
	description = "Janky 3D",
	license = "GNU GPLv3",
	author = { name = "Jon Wilson (10yard)" } }

local janky3d = exports
TAB = {}

function janky3d.startplugin()
	local mac, cpu, mem, slt, scr	
	local system_data, depth_flip, depth_default, depth_1, depth_2
	local colors_ignore, colors_1, colors_2 = {}, {}, {}

	function janky3d_initialize()
	  -- System parameters are maintained in parameters.lua file
		require "janky3d.parameters"
		
		mac = manager.machine
		if mac then
			cpu = mac.devices[":maincpu"]
			mem = cpu.spaces["program"]
			scr = mac.screens[":screen"]
			slt = mac.images[":cartslot"]			
			
			if slt then
				if slt.crc then
					-- Look for a specific cart for this system
					print("CRC = "..slt.crc)
					system_data = TAB[emu.romname().."|"..slt.crc]
				end
				if not system_data then 			
					-- Look for cart system defaults
					system_data = TAB["default|NOCRC"]
				end
			end
			if not system_data then 			
				-- Look for system defaults
				system_data = TAB[emu.romname()]
			end
			if not system_data then 
				-- Use the global defaults
				system_data = TAB["default"] 
			end
			depth_flip = system_data[1]
			for k, v in pairs(system_data[2]) do colors_ignore[v] = true end
			depth_default = system_data[3]
			depth_1 = system_data[4]
			for k, v in pairs(system_data[5]) do colors_1[v] = true end
			depth_2 = system_data[6]
			for k, v in pairs(system_data[7]) do colors_2[v] = true end
		end
	end

	function janky3d_main()

		if system_data then		
			-- local copy of global vars for performance
			local _scr = scr
			local _byte = string.byte
			local _depth_1, _depth_2, _depth_default, _depth_flip = depth_1, depth_2, depth_default, depth_flip
			local _colors_1, _colors_2, _colors_ignore = colors_1, colors_2, colors_ignore

			-- local vars
			local p = _scr:pixels()
			local y, x, d, c, i
			local a, r, g, b
			local w, h = _scr.width, _scr.height

			-- Loop through all screen pizels
			for y = h, 0, -1 do
				for x = 0, w do
					-- Determine index of pixel at X, Y and read A,R,G,B colour values
					i = ((x + (w * y)) * 4) + 1
					a, r, g, b = _byte(p, i, i + 4)
					if a and r and g and b then
						-- Convert ARGB colour to hex
						c = (b * 0x1000000) + (g * 0x10000) + (r * 0x100) + a						
						if not _colors_ignore[c] then
							-- Determine 3D depth for this colour and draw line extending from pixel
							if _colors_1[c] then
								d = _depth_1
							elseif _colors_2[c] then
								d = _depth_2
							else
								d = _depth_default
							end
							_scr:draw_line(x, y+1, x - (d * _depth_flip), y - d, c)
						end
					end
				end
			end
		end
	end
		
	emu.register_start(function()
		janky3d_initialize()
	end)
	
	emu.register_frame_done(function() 
		janky3d_main() 
	end)
		
end
return exports