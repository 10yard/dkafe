-- DK TV Plugin for MAME
-- Jumpman's position remains central with camera zooms for jumping or hammering.
-- by Jon Wilson (10yard)
--
-- Minimum start up arguments:
--   mame dkong -plugin dktv
-----------------------------------------------------------------------------------------
local exports = {
	name = "dktv",
	version = "0.1",
	description = "DK TV",
	license = "GNU GPLv3",
	author = { name = "Jon Wilson (10yard)" } }

local dktv = exports

function dktv.startplugin()
	local mame_version, mac, cpu, mem, scr	
	local x, y, h, mode1, mode2, zoom_level
	local zoom_default = 1.25
	local stage = 1
	local timer = 0
	local show_score, complete
	local characters = "0123456789       ABCDEFGHIJKLMNOPQRSTUVWXYZ@-"

	function dktv_initialize()
		mame_version = tonumber(emu.app_version())
		mac = manager.machine

		if mac then
			cpu = mac.devices[":maincpu"]
			mem = cpu.spaces["program"]
			scr = mac.screens[":screen"]
			con = scr.container			
			
			-- Update title
			write_rom_message(0x36b4, "  DK TV   ")
			
			-- Update how high text
			--write_rom_message(0x36ce, "SMILE FOR THE CAMERA  ")					-- Mod: Update how high text
			
			-- ROM mod to hide bottom edge of timer - so Jumpman can jump there without being cropped by the blanking box.
			for i=0x384c, 0x385b, 3 do
				mem:write_direct_u8(i, 0x10)
			end			
		
			-- ROM mod to start on title screen
			mem:write_direct_u32(0x01ea, 0x0000063e)
			mem:write_direct_u16(0x07d3, 0xff3e)
			
		end
	end

	function dktv_main()
		if con then
			mode1, mode2 = mem:read_u8(0x6005), mem:read_u8(0x600a)
			x, y = 0, 0
			zoom_level = zoom_default
												
			-- Stage complete flag set until the next how high screen starts
			if mode2 == 10 then
				stage = mem:read_u8(0x6227)
				complete = false
			elseif not complete and mem:read_u8(0x6388) > 0 then
				complete = true
			end
						
			if scr:frame_number() % 2 == 0 then
				show_score = true
				
				if mode1 == 1 and (mode2 == 6 or mode2 == 7) then
					-- title screen zoom
					x, y = 126, 190
					zoom_level = 0.85
				end
				
				if (mode1 == 1 and (mode2 >= 2 and mode2 <= 4)) or (mode1 == 3 and (mode2 >= 11 and mode2 <= 13)) or (complete and stage < 4) then				
					-- Get Jumpman's position
					if mode2 == 11 then
						if stage == 3 then
							x, y = 22, 224
						else
							x, y = 63, 240
						end
					else
						x, y = mem:read_u8(0x6203), mem:read_u8(0x6205)
					end
				end
				
				if (mode1 == 3 and mode2 == 7) or (complete and stage == 4) then
					-- Get DK's position
					x, y = mem:read_u8(0x6910), mem:read_u8(0x6913)
					if x == 0 and y == 0 then
						x, y = 138, 220
					else
						if mem:read_u8(0x6385) >= 5 or complete then
							x = x + 1
							if complete and (mem:read_u8(0x6388) == 0 or mem:read_u8(0x6388) >= 4) then
								-- Kong is falling at end of rivets
								y = y + 4
							else
								y = y - 8
							end
						else
							y = y + 4
							x = x + 8
						end
					end
				end

				if x > 0 and y > 0 then
					show_score = false
					
					if mem:read_u8(0x6216) == 1 or mem:read_u8(0x621f) == 1 or mem:read_u8(0x6217) == 1 then
						-- Zoom in when Jumpman jumps and hammers
						if mem:read_u8(0x6217) == 1 then
							timer = (mem:read_u8(0x6394) + (256 * mem:read_u8(0x6395))) / 2
							if timer > 127 then
								h = 255 - timer
							else
								h = timer
							end
							h = h / 5
						else
							h = mem:read_u8(0x620e) - mem:read_u8(0x620c)
						end
						if h > 0 and h <= 26 then
							con.xscale, con.yscale = zoom_level + (h / 35), zoom_level + (h / 35)
						end
					else
						con.xscale, con.yscale = zoom_level, zoom_level
					end
					
					-- Move screen container to keep Jumpman (or DK) central
					con.xoffset = (((y -256) / 256) + 0.50) * con.xscale
					con.yoffset = (1 - ((x / 224) + 0.43)) * con.yscale
				else
					con.xscale, con.yscale = 1, 1
					con.xoffset, con.yoffset = 0, 0
				end
			end
			
			if not show_score then
				-- Blanking boxes to remove titles, scores, levels etc from top of screen
				scr:draw_box(256, 0, 240, 224, 0xff000000, 0xff000000)
				scr:draw_box(256, 0, 224, 80, 0xff000000, 0xff000000)
				scr:draw_box(256, 160, 200, 224, 0xff000000, 0xff000000)
			end
		end
	end
			
	function write_rom_message(start_addr, text)
		-- write characters of message to ROM
		for key=1, string.len(text) do
			mem:write_direct_u8(start_addr + (key - 1), string.find(characters, string.sub(text, key, key)) - 1)
		end
	end
			
	emu.register_start(function()
		dktv_initialize()
	end)
	
	emu.register_frame_done(function() 
		dktv_main() 
	end)
		
end
return exports