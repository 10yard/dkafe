-- DKAFE Teleport Hack 
-- Perform hack to teleport between hammers

-- Drives additional features of the "DK Who and the Daleks" hack 
--
-- Jumpman has regenerated as the next Dr Who.  Help him rescue his assistant Rose from the clutches of Donkey Kong.
-- The Daleks have destroyed her rocket ship and now you are her only hope for escape.
-- Donkey Kong's legion of Daleks aim to exterminate Jumpman (aka The Doctor) as he climbs the galactic space station.  
-- The Doctor can use the Tardis to teleport through spacetime to assist his travel through the stages.
-- Bonus items to be collected are K9, Sonic Screwdriver and The Master's Watch.

function update_teleport_ram(_x, _y, _ly)
    -- force 0 to disable the hammer
	mem:write_i8(0xc6217, 0)
	mem:write_i8(0xc6218, 0)
	mem:write_i8(0xc6345, 0)
	mem:write_i8(0xc6350, 0)

	-- update position
	mem:write_i8(0xc6203, _x)   -- Update Jumpman's X position
	mem:write_i8(0xc6205, _y)   -- Update Jumpman's Y position
	mem:write_i8(0xc620E, _ly)  -- Update launch Y position to prevent excessive fall

	-- clear all hammers
	mem:write_i8(0xc6A18, 0)    -- top
	mem:write_i8(0xc6680, 0)
	mem:write_i8(0xc6A1C, 0)    -- bottom
	mem:write_i8(0xc6690, 0)
end   

function draw_tardis(y1, x1, y2, x2)
	if math.fmod(mem:read_i8(0xc638c), 2) == 0  then -- sync flashing with bonus timer
		x = x1	
		y = y1
	else
		x = x2	
		y = y2
	end
	--box and bottom
	screen:draw_box(y, x+1, y+15, x+14, BLUE, 0)
	screen:draw_box(y, x, y+1, x+15, BLUE, 0)	
	--windows
	screen:draw_box(y+9, x+3, y+12, x+7, BROWN, BROWN)
	screen:draw_box(y+9, x+8, y+12, x+12, BROWN, BROWNp)
	screen:draw_box(y+5, x+3, y+8, x+7, BLUE, CYAN)
	screen:draw_box(y+5, x+8, y+8, x+12, BLUE, CYAN)
	screen:draw_box(y+1, x+3, y+4, x+7, BLUE, CYAN)
	screen:draw_box(y+1, x+8, y+4, x+12, BLUE, CYAN)
	-- blinking light
	if toggle() == 1 then
		screen:draw_box(y+15, x+7, y+16, x+8, YELLOW, 0)
	else
		screen:draw_box(y+15, x+7, y+16, x+8, RED, 0)
	end
end

function draw_stars()
	-- draw a starfield background
	for key=0, number_of_stars, 2 do
		_y = starfield[key]
		_x = starfield[key+1]
		screen:draw_line(_y, _x, _y, _x, 0xcbbffffff, 0)
	end
end

function animate_broken_ship(x, y, dont_check_lit)
	-- if fire is lit
	if dont_check_lit == 1 or mem:read_i8(0xc6348) == 1 then
		-- flash colours in sync with 1UP
		-- use timer as 1UP doesn't flash on the attract mode
		if toggle() == 1 then
			flame_color = YELLOW
		else
			flame_color = RED
		end
		screen:draw_box(x, y, x+4, y+4, flame_color)
	end

end

function adjust_weeping_angels()
	-- adjust Y position of dalek sprites by 4 pixels as they are taller than pies
	angels_ram = {0xc65a5,0xc65b5,0xc65c5,0xc65d5,0xc65e5,0xc65f5}
	for key, value in pairs(angels_ram) do
		if mem:read_i8(value) == -52 then
			mem:write_i8(value, -56)
		end
		if mem:read_i8(value) == 124 then
			mem:write_i8(value, 120)
		end
	end
end

function dkongwho_overlay()
	mode1 = mem:read_i8(0xc6005)
	mode2 = mem:read_i8(0xc600a)

	if mode1 == 1 and mode2 >= 6 and mode2 <= 7 then
		-- Title Screen
		screen:draw_box(96, 16, 136, 208, BLACK, 0)
		screen:draw_box(152, 8, 198, 208, BLACK, 0)
		block_text("DK WHO", 191, 16, BLUE, CYAN) 
		block_text("DALEKS", 128, 16, BLUE, CYAN) 
		--AND THE
		write_message(0xc766d, 7, {0x11, 0x1e, 0x14, 0x10, 0x24, 0x18, 0x15})
		-- DK WHO OF GALLIFREY
		screen:draw_box(16, 0, 32, 224, BLACK, 0)
		write_message(0xc777e, 24, {0x14, 0x1b, 0x10, 0x27, 0x18, 0x1f, 0x10, 0x1f, 0x16, 0x10, 0x17, 0x11, 0x1c, 0x1c, 0x19, 0x16, 0x22, 0x15, 0x29, 0x10, 0x19, 0x1e, 0x13, 0x2b})
		-- Tardis jumping left to right
		if math.fmod(mem:read_i8(0xc601a) + 128, 84) <=42 then
			draw_tardis(64, 40, 64, 40)
		else
			draw_tardis(64, 172, 64, 172)
		end
	end

	draw_stars()
	-- (during play) or (during attact mode) including just before and just after
	if (mode1 == 3 and (mode2 == 11 or mode2 == 12 or mode2 == 13 or mode2 == 22)) or (mode1 == 1 and mode2 >= 2 and mode2 <= 4) then
		if stage == 1 then
			animate_broken_ship(18, 22, 0)
		elseif stage == 2 then
			animate_broken_ship(122, 110, 1)
			adjust_weeping_angels()
		end

		if mem:read_i8(0xc6A18) ~= 0 then
			-- hammer hasn't yet been used
			-- draw tardis graphics
			if stage == 1 then        -- Girders
				draw_tardis(55, 165, 148, 14)
			elseif stage == 2 then    -- Pies/Conveyors
				draw_tardis(68, 101, 107, 13)
			elseif stage == 4 then    -- Rivets
				draw_tardis(148, 102, 108, 5)
			end
		else
			-- hammer has been used
			-- switch palette
			if stage == 1 then        -- Girders
				mem:write_i8(0xc7d86, 1)				
			elseif stage == 2 then    -- Pies/Conveyors
				mem:write_i8(0xc7d86, 0)				
			elseif stage == 4 then    -- Rivets
				mem:write_i8(0xc7d86, 0) 				
			end
		end
	end
end

function check_jumpman()
	if stage ~= 3 and mem:read_i8(0xc6218) ~= 0 then	
		-- Jumpman is attempting to grab a hammer
		jumpman_y = mem:read_i8(0xc6205)  -- Jumpman's Y position
		
		if stage == 1 then
			if emu.romname() == "dkongx11" or data_subfolder == "dkongrdemo" then
				-- jumps for remix
				if jumpman_y > - 80 then
					update_teleport_ram(210, 140, -110)
				else
					update_teleport_ram(210, 192, -46)
				end
			else
				-- jumps for regular dkong
				if jumpman_y < 0 then
					update_teleport_ram(36, 100, 113)
				else
					update_teleport_ram(187, 192, -46)
				end
			end
		elseif stage == 2 then
			if jumpman_y < -100 then
				update_teleport_ram(124, 180, -45)
			else
				update_teleport_ram(27, 140, -96)
			end
		elseif stage == 4 then 
			if jumpman_y > 100 then
				update_teleport_ram(33, -110, -96)
			else
				update_teleport_ram(126, 106, 120)
			end
		elseif stage == 5 then 
			if jumpman_y > -40 then
				update_teleport_ram(90, -78, -65)
			else
				update_teleport_ram(65, -30, -17)
			end
		end
	end
end

-- PROGRAM START --

if loaded == 3 and data_subfolder == "dkongwho" then
	-- rom specific hack for DK Who
	if teleport_hack_started ~= 1 then	
		number_of_stars = 500
		starfield={}
		for i=0, number_of_stars do
			table.insert(starfield, math.random(224))
			table.insert(starfield, math.random(256))
		end
		-- Register callback function to add extra graphics
		emu.register_frame_done(dkongwho_overlay, "frame")
	end
	teleport_hack_started = 1
end

stage = mem:read_i8(0xc6227)      -- Stage (1-girders, 2-pie, 3-elevator, 4-rivets, 5-bonus)	
check_jumpman()

if mem:read_i8(0xc6A18) == 00 or mem:read_i8(0xc6A1C) ~= 00 then
	-- Prevent cleared hammers from becoming active again
	mem:write_i8(0xc6345, 0)
	mem:write_i8(0xc6350, 0)
end
