-- gingerbreakkong: Overlay a Gingerbread Kong sprite to the Atari 2600 rom hack
-- by Jon Wilson (10yard)
--
-- Tested with latest MAME version 0.239
-- Fully compatible with all MAME versions from 0.196
--
-- Minimum start up arguments:
--   mame dkong -plugin gingerbreadkong
-----------------------------------------------------------------------------------------

local exports = {}
exports.name = "gingerbreadkong"
exports.version = "0.1"
exports.description = "Overlay a Gingerbread Kong sprite to the Atari 2600 rom hack"
exports.license = "GNU GPLv3"
exports.author = { name = "Jon Wilson (10yard)" }
local gingerbreadkong = exports


function gingerbreadkong.startplugin()	
	local logo_palette = {}
	logo_palette["!"] = 0xffb55328
	logo_palette[" "] = 0xff000000
	
	local gingerbread_left = {
		"        ",
		"  !!!   ",
		" !!!!!  ",
		" ! ! ! !",
		" !!!!! !",
		" !   ! !",
		"  !!!  !",
		" !!!!!!!",
		"!!!!!!!!",
		"!!!!!!! ",
		"! !!!!  ",
		"!! !!!  ",
		" ! !!!! ",
		"  !!!!! ",
		" !!!!!! ",
		" !!!!!! ",
		" !!  !!!",
		" !!  !!!",
		"!!!     ",
		"!!!     "}
		
	local gingerbread_right = {
		"        ",
		"   !!!  ",
		"  !!!!! ",
		"! ! ! ! ",
		"! !!!!! ",
		"! !   ! ",
		"!  !!!  ",
		"!!!!!!! ",
		"!!!!!!!!",
		" !!!!!!!",
		"  !!!! !",
		"  !!! !!",
		" !!!! ! ",
		" !!!!!  ",
		" !!!!!! ",
		" !!!!!! ",
		"!!!  !! ",
		"!!!  !! ",
		"     !!!",
		"     !!!"}

	local gingerbread_fall = {
		"!!!  !!! ",
		"!!!  !!! ",
		" !!  !!  ",
		" !!  !!  ",
		" !!!!!!  ",
		" !!!!!!  ",
		"  !!!!   ",
		"  !!!!   ",
		"  !!!!   ",
		"  !!!!   ",
		" !!!!!!! ",
		"!!!!!!!!!",
		"!!!!!!! !",
		"!  !!!  !",
		"! !   ! !",
		"! !!!!! !",
		"! ! ! ! !",
		"  !!!!!  ",
		"   !!!   "}
	
	function initialize()
		if tonumber(emu.app_version()) >= 0.196 then
			if type(manager.machine) == "userdata" then
				mac = manager.machine
			else
				mac =  manager:machine()
			end			
		else
			print("ERROR: The gingerbreadkong plugin requires MAME version 0.196 or greater.")
		end
		if mac ~= nil then
			scr = mac.screens[":screen"]
			cpu = mac.devices[":maincpu"]
			mem = cpu.spaces["program"]
		end
				
		fall_y = 0
		kong_sprite = gingerbread_left
	end
	
	function main()
		if cpu ~= nil then

			local mode2 = mem:read_u8(0x600a)
			local stage = mem:read_u8(0x6227)  -- 1-barrels, 2-pies, 3-springs, 4-rivets

			if mode2 == 0x07 then
				-- Skip the intro screen completely

				mem:write_u8(0x600a, 0x08)
							
			elseif mode2 == 0x16 and stage == 4 then
				-- End of level animation of Gingerbread Kong
				
				if mem:read_u8(0x6084) ~= 0 then
					fall_y = 203
				end
				if fall_y > 0 then
					draw_sprite(gingerbread_fall, fall_y, 86)
					if fall_y > 72 and not mac.paused then
						fall_y = fall_y - 1
					end
				else
					draw_sprite(gingerbread_left, 200, 86)				
				end
				
			elseif mode2 == 0x0a then
				-- Draw multiple Gingerbread Kongs on the How High screen

				_y = 58
				kong_sprite = gingerbread_left
				for i=1, mem:read_u8(0x622e) do
					draw_sprite(kong_sprite, _y, 86)
					_y = _y + 32
					if kong_sprite == gingerbread_left then
						kong_sprite = gingerbread_right
					else
						kong_sprite = gingerbread_left
					end
				end
				fall_y = 0
				
			elseif (mode2 >= 0x0b and mode2 <= 0xd) or (mode2 >= 0x03 and mode2 <= 0x04) then 
				-- During gameplay and attract mode
				
				-- Determine Kong sprite based on Jumpman's direction of travel
				if mode2 == 0xc then
					input = mem:read_u8(0xc7c00)
					if input == 2 then
						kong_sprite = gingerbread_left
					elseif input == 1 then 
						kong_sprite = gingerbread_right
					end
				else
					kong_sprite = gingerbread_left
				end
			
				-- Barrels stage
				if stage == 1 or (mode2 == 0x08 and stage == 0x04) then
					draw_sprite(kong_sprite, 206, 18, false)	
				end

				-- Springs stage
				if stage == 3 then
					draw_sprite(kong_sprite, 202, 14, true)	
				end

				-- Pies stage
				if stage == 2 then
					draw_sprite(kong_sprite, 202, 144, true)	
				end

				-- Rivets stage
				if stage == 4 then
					draw_sprite(kong_sprite, 202, 86, true)	
				end
				
			end
		end
	end
	
	function draw_sprite(sprite_data, pos_y, pos_x, transparent)
		for _y, line in pairs(sprite_data) do
			for _x=1, string.len(line) do
				_col = string.sub(line, _x, _x)
				if not transparent or _col ~= " " then
					scr:draw_box(pos_y - (_y * 1.6), pos_x + (_x * 4.7), pos_y - (_y * 1.6) - 1.6, pos_x + (_x * 4.7) + 4.7, logo_palette[_col], logo_palette[_col])
				end
			end
		end
	end
	
	emu.register_start(function()
		initialize()
	end)
		
	emu.register_frame_done(main, "frame")
end
return exports