-- Teleport Hack 
-- Perform hack to teleport between hammers changing Jumpman's position

-- Idea - Jumpman has regenerated as the next Dr Who.

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

function draw_tardis(x, y)
	--box and bottom
	manager:machine().screens[":screen"]:draw_box(x, y+1, x+15, y+14, blue, 0)
	manager:machine().screens[":screen"]:draw_line(x, y, x, y+15, blue, 0)	
	--windows
	manager:machine().screens[":screen"]:draw_box(x+9, y+3, x+12, y+7, yellow, 0)
	manager:machine().screens[":screen"]:draw_box(x+9, y+8, x+12, y+12, yellow, 0)
	manager:machine().screens[":screen"]:draw_box(x+5, y+3, x+8, y+7, cyan, 0)
	manager:machine().screens[":screen"]:draw_box(x+5, y+8, x+8, y+12, cyan, 0)
	manager:machine().screens[":screen"]:draw_box(x+1, y+3, x+4, y+7, cyan, 0)
	manager:machine().screens[":screen"]:draw_box(x+1, y+8, x+4, y+12, cyan, 0)
	--flashing light at top
	blink_toggle = mem:read_i8(0xc7720) -- sync with the flashing 1UP 
	if blink_toggle == 16 then
		manager:machine().screens[":screen"]:draw_box(x+15, y+7, x+16, y+8, yellow, 0)
	else
		manager:machine().screens[":screen"]:draw_box(x+15, y+7, x+16, y+8, red, 0)
	end
end

function dkongwho_overlay()
	mode1 = mem:read_i8(0xc6005)
	mode2 = mem:read_i8(0xc600a)
	if mem:read_i8(0xc6A18) ~= 0 then
		-- hammer hasn't yet been used
		-- (during play) or (during attact mode) including just before and just after
		if (mode1 == 3 and mode2 >= 11 and mode2 <= 13) or (mode1 == 1 and mode2 >= 2 and mode2 <= 4) then
			-- draw tardis graphics and switch palette
			if stage == 1 then        -- Girders
				draw_tardis(55, 165)
				draw_tardis(148, 14)
			elseif stage == 2 then    -- Pies/Conveyors
				draw_tardis(68, 101)
				draw_tardis(107, 13)
			elseif stage == 4 then    -- Rivets
				draw_tardis(148, 102)
				draw_tardis(108, 5)
			end
		end
	else
		if (mode1 == 3 and mode2 >= 11 and mode2 <= 13) or (mode1 == 1 and mode2 >= 2 and mode2 <= 4) then
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
		emu.register_frame_done(dkongwho_overlay, "frame")
	end
	teleport_hack_started = 1
end

stage = mem:read_i8(0xc6227)      -- Stage (1-girders, 2-pie, 3-elevator, 4-rivets, 5-bonus)	
grab = mem:read_i8(0xc6218)

if mem:read_i8(0xc6A18) == 00 or mem:read_i8(0xc6A1C) ~= 00 then
	-- Prevent cleared hammers from becoming active
	mem:write_i8(0xc6345, 0)
	mem:write_i8(0xc6350, 0)
end	

if grab ~= 00 and stage ~= 3 then	
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
