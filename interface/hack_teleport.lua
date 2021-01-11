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


function draw_tardis()
	mode1 = mem:read_i8(0xc6005)
	mode2 = mem:read_i8(0xc600a)
	if mode1 == 3 and (mode2 == 11 or mode2 == 12) then
		if stage == 1 then
			--box
			manager:machine().screens[":screen"]:draw_box(55, 166, 70, 179, 0xff0000ff, 0)
			--windows
			manager:machine().screens[":screen"]:draw_box(64, 168, 67, 172, 0xffffbd2e, 0)
			manager:machine().screens[":screen"]:draw_box(64, 173, 67, 177, 0xffffbd2e, 0)
			manager:machine().screens[":screen"]:draw_box(60, 168, 63, 172, 0xff000000, 0)
			manager:machine().screens[":screen"]:draw_box(60, 173, 63, 177, 0xff000000, 0)
			manager:machine().screens[":screen"]:draw_box(56, 168, 59, 172, 0xff000000, 0)
			manager:machine().screens[":screen"]:draw_box(56, 173, 59, 177, 0xff000000, 0)
			--bottom
			manager:machine().screens[":screen"]:draw_line(55, 165, 55, 180, 0xff0000ff, 0)	
			--flashing light
			blink_toggle = mem:read_i8(0xc7720) -- sync with the flashing 1UP 
			if blink_toggle == 16 then
				manager:machine().screens[":screen"]:draw_box(70, 172, 71, 173, 0xffffbd2e, 0)
			else
				manager:machine().screens[":screen"]:draw_box(70, 172, 71, 173, 0xffff0000, 0)
			end
		end
	end
end

if loaded == 3 then
	if teleport_hack_started ~= 1 then
		emu.register_frame_done(draw_tardis, "frame")
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
