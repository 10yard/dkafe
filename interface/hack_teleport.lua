-- Teleport Hack 
-- Perform hack to teleport between hammers

-- Drives additional features of the "DK Who" hack 
--
-- Jumpman has regenerated as the next Dr Who.  Help him rescue his assistant Rose from the clutches of Donkey Kong.  Her rocket ship has been destroyed and now you are her only hope for escape.
-- Donkey Kong's legion of Daleks will try to exterminate Jumpman (aka The Doctor) as he climbs to the top of the galactic space station.  
-- The Doctor can use the Tardis to teleport through spacetime to assist his travel through the stage.
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
	manager:machine().screens[":screen"]:draw_box(y, x+1, y+15, x+14, blue, 0)
	manager:machine().screens[":screen"]:draw_box(y, x, y+1, x+15, blue, 0)	
	--windows
	manager:machine().screens[":screen"]:draw_box(y+9, x+3, y+12, x+7, brown, 0)
	manager:machine().screens[":screen"]:draw_box(y+9, x+8, y+12, x+12, brown, 0)
	manager:machine().screens[":screen"]:draw_box(y+5, x+3, y+8, x+7, cyan, 0)
	manager:machine().screens[":screen"]:draw_box(y+5, x+8, y+8, x+12, cyan, 0)
	manager:machine().screens[":screen"]:draw_box(y+1, x+3, y+4, x+7, cyan, 0)
	manager:machine().screens[":screen"]:draw_box(y+1, x+8, y+4, x+12, cyan, 0)
	-- blinking light
	blink_toggle = mem:read_i8(0xc7720) -- sync with the flashing 1UP 
	if blink_toggle == 16 then
		manager:machine().screens[":screen"]:draw_box(y+15, x+7, y+16, x+8, yellow, 0)
	else
		manager:machine().screens[":screen"]:draw_box(y+15, x+7, y+16, x+8, red, 0)
	end
end

function draw_stars()
	key = 0
	for x=0, 224, 2 do
		for y=0, 256, 2 do
			if starfield[key] == 1 then
				manager:machine().screens[":screen"]:draw_line(y, x, y, x, 0xbbffffff, 0)
			end
			key = key + 1
		end
	end
end

function animate_broken_ship()
	if mem:read_i8(0xc6348) == 1 then
		-- Fire is lit
		blink_toggle = mem:read_i8(0xc7720)
		if blink_toggle == 16 then
			flame_color = yellow
		else
			flame_color = red
		end
		manager:machine().screens[":screen"]:draw_box(18, 22, 22, 26, flame_color)
	end

end

function adjust_weeping_angels()
	-- adjust Y position of sprites by 4 pixels (these are normally pies)
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

	draw_stars()

	-- (during play) or (during attact mode) including just before and just after
	if (mode1 == 3 and mode2 >= 11 and mode2 <= 13) or (mode1 == 1 and mode2 >= 2 and mode2 <= 4) then
		if stage == 1 then
			animate_broken_ship()
		elseif stage == 2 then
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

if loaded == 3 and data_subfolder == "dkongwho" then
	-- rom specific hack to enable blue Tardis overlay graphic
	if teleport_hack_started ~= 1 then
		blue = 0xff0402dc
		yellow = 0xffffbd2e
		red = 0xffe8070a
		cyan = 0xff14f3ff
		brown = 0xfff5bca0
		
		starfield={}
		for x=0, 224, 2 do	
			for y=0, 256, 2 do
				table.insert(starfield, math.random(50))
			end
		end
		
		emu.register_frame_done(dkongwho_overlay, "frame")
	end
	teleport_hack_started = 1
end

stage = mem:read_i8(0xc6227)      -- Stage (1-girders, 2-pie, 3-elevator, 4-rivets, 5-bonus)	

if mem:read_i8(0xc6A18) == 00 or mem:read_i8(0xc6A1C) ~= 00 then
	-- Prevent cleared hammers from becoming active
	mem:write_i8(0xc6345, 0)
	mem:write_i8(0xc6350, 0)
end	

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
