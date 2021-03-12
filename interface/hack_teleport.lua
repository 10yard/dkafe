-- DKAFE Teleport Hack by Jon Wilson
------------------------------------------------------------------------
-- Perform hack to teleport between hammers
------------------------------------------------------------------------
-- Drives additional features of the "DK Who and the Daleks" hack:
-- Jumpman has regenerated as the next Dr Who.  Help him rescue his 
-- assistant Rose from the clutches of Donkey Kong.
-- The Daleks have destroyed her rocket ship and you are now her only 
-- hope for escape.
-- The Doctor can use the Tardis to teleport through spacetime to assist 
-- his travel through the stages.
------------------------------------------------------------------------

function update_teleport_ram(update_x, update_y, update_ly)
  -- force 0 to disable the hammer
	mem:write_i8(0xc6217, 0)
	mem:write_i8(0xc6218, 0)
	mem:write_i8(0xc6345, 0)
	mem:write_i8(0xc6350, 0)

	-- update position
	mem:write_i8(0xc6203, update_x)   -- Update Jumpman's X position
	mem:write_i8(0xc6205, update_y)   -- Update Jumpman's Y position
	mem:write_i8(0xc620E, update_ly)  -- Update launch Y position to prevent excessive fall

	-- clear all hammers
	mem:write_i8(0xc6A18, 0)    -- top
	mem:write_i8(0xc6680, 0)
	mem:write_i8(0xc6A1C, 0)    -- bottom
	mem:write_i8(0xc6690, 0)	
	
	-- change music after teleporting
	if stage ~= 2 then
		mem:write_i8(0xc6089, 9)
	else
		mem:write_i8(0xc6089, 11)
	end
end   

function draw_tardis(y1, x1, y2, x2)
	if toggle("TIMER") == 0  then -- sync flashing with bonus timer
		_xpos, _ypos = x1, y1	
	else
		_xpos, _ypos = x2, y2	
	end
	--box and bottom
	screen:draw_box(_ypos, _xpos+1, _ypos+15, _xpos+14, BLUE, 0)
	screen:draw_box(_ypos, _xpos, _ypos+1, _xpos+15, BLUE, 0)	
	--windows
	screen:draw_box(_ypos+9, _xpos+3, _ypos+12, _xpos+7, YELLOW, BROWN)
	screen:draw_box(_ypos+9, _xpos+8, _ypos+12, _xpos+12, YELLOW, BROWN)
	screen:draw_box(_ypos+5, _xpos+3, _ypos+8, _xpos+7, BLUE, CYAN)
	screen:draw_box(_ypos+5, _xpos+8, _ypos+8, _xpos+12, BLUE, CYAN)
	screen:draw_box(_ypos+1, _xpos+3, _ypos+4, _xpos+7, BLUE, CYAN)
	screen:draw_box(_ypos+1, _xpos+8, _ypos+4, _xpos+12, BLUE, CYAN)
	-- blinking light
	if toggle() == 1 then
		screen:draw_box(_ypos+15, _xpos+7, _ypos+16, _xpos+8, YELLOW, 0)
	else
		screen:draw_box(_ypos+15, _xpos+7, _ypos+16, _xpos+8, RED, 0)
	end
end

function draw_stars()
	-- draw a starfield background
  local _starfield = starfield
  local _ypos, _xpos = 0, 0
	for key=1, number_of_stars, 2 do
		_ypos, _xpos = _starfield[key], _starfield[key+1]
		screen:draw_line(_ypos, _xpos, _ypos, _xpos, 0xcbbffffff, 0)
	end
end

function animate_broken_ship(x, y, dont_check_lit)
	-- flash flames on the ship when fire is lit
	if dont_check_lit == 1 or mem:read_i8(0xc6348) == 1 then
    local flame_color = RED
		if toggle() == 1 then
			flame_color = YELLOW
		end
		screen:draw_box(x, y, x+4, y+4, flame_color)
	end
end

function adjust_weeping_angels()
	-- adjust Y position of angel sprites by 4 pixels as they are taller than pies
	for _, value in pairs({0xc65a5,0xc65b5,0xc65c5,0xc65d5,0xc65e5,0xc65f5}) do
    _y = mem:read_u8(value)
    if _y == 124 or _y == 204 then
			mem:write_u8(value, _y - 4)
		end
	end
end

function check_teleports()
	if stage ~= 3 and mem:read_i8(0xc6218) ~= 0 then	
		-- Jumpman is attempting to grab a hammer
		local jumpman_y = mem:read_i8(0xc6205)  -- Jumpman's Y position
		
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

function dkongwho_overlay()
  local _rand = 1
	if mode1 == 1 and mode2 >= 6 and mode2 <= 7 then
		-- Title screen
		screen:draw_box(96, 16, 136, 208, BLACK, 0)
		screen:draw_box(152, 8, 198, 208, BLACK, 0)
		block_text("DK WHO", 191, 16, BLUE, CYAN) 
		write_message(0xc766d, "AND THE")
		block_text("DALEKS", 128, 16, BLUE, CYAN) 
		-- Bottom text
		screen:draw_box(16, 0, 32, 224, BLACK, 0)
		write_message(0xc777e, "DK WHO OF GALLIFREY INC.")

		-- Tardis travelling left/right
		if math.fmod(mem:read_u8(0xc601a), 84) <=42 then
			draw_tardis(56, 40, 56, 40)
		else
			draw_tardis(56, 172, 56, 172)
		end
	end
	
	-- Display alternative messages on How High screens other than stage 1
	if stage ~= 1 then
		if mode2 == 8 then
			howhigh_prepare = 1
		elseif mode2 == 10 and howhigh_prepare == 1 then
			if stage == 3 then
				write_message(0xc779e, "WARNING - DALEK'S CAN FLY $")
			elseif stage == 2 then
				write_message(0xc779e, "DON'T LOOK AWAY OR BLINK $")
			elseif stage == 4 then
				math.randomseed(os.time())
				_rand = math.random(3)
				if _rand == 1 then
					write_message(0xc777e, "WHERE'S MY             ")
					write_message(0xc777f, "    SONIC SCREWDRIVER ?")
				elseif _rand == 2 then
					write_message(0xc777e, "WE MUST SEARCH FOR K-9 $")
				else
					write_message(0xc77be, "THE MASTER WANTS HIS WATCH $")
				end
			end
			howhigh_prepare = 0
		end
	end
	
	draw_stars()
	
	if (mode1 == 3 and (mode2 == 11 or mode2 == 12 or mode2 == 13 or mode2 == 22)) or (mode1 == 1 and mode2 >= 2 and mode2 <= 4) then
    -- During play or during attact mode (including just before and just after)
		if stage == 1 then
			animate_broken_ship(18, 22, 0)
		elseif stage == 2 then
			animate_broken_ship(122, 110, 1)
			adjust_weeping_angels()
		end

		check_teleports()

		if mem:read_i8(0xc6A18) ~= 0 then
			-- Draw tardis graphics.  The hammer hasn't been used.
			if stage == 1 then        -- Girders
				draw_tardis(55, 165, 148, 14)
			elseif stage == 2 then    -- Pies/Conveyors
				draw_tardis(68, 101, 107, 13)
			elseif stage == 4 then    -- Rivets
				draw_tardis(148, 102, 108, 5)
			end
		else
			if mem:read_i8(0xc6200) ~= 0 then
				-- Switch the palette.  The hammer has been used and jumpman is not dead.
				if stage == 1 then        -- Girders
					mem:write_i8(0xc7d86, 1)				
					mem:write_i8(0xc7d87, 0)				
				elseif stage == 2 then    -- Pies/Conveyors
					mem:write_i8(0xc7d86, 0)				
					mem:write_i8(0xc7d87, 1)				
				elseif stage == 4 then    -- Rivets
					mem:write_i8(0xc7d86, 0) 				
				end
			end
		end
	end
end

------------------------------------------------------------------------
-- Program start
------------------------------------------------------------------------
if loaded == 3 and data_subfolder == "dkongwho" then
	-- rom specific hack for DK Who
	if teleport_hack_started ~= 1 then	
		number_of_stars = 500
		starfield={}
		math.randomseed (os.time())		
		for _=1, number_of_stars do
			table.insert(starfield, math.random(255))
			table.insert(starfield, math.random(223))
		end
		-- Register callback function to add extra graphics
		emu.register_frame_done(dkongwho_overlay, "frame")
	end
	teleport_hack_started = 1
end