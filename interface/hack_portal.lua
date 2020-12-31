-- Portal Hack 
-- Perform hack to portal between the 2 hammers changing Jumpman's position

function update_portal_ram(_x, _y, _ly)
    -- force 0 to disable the hammer
	mem:write_i8(0xc6217, 0)
	mem:write_i8(0xc6218, 0)

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

hammer_grab = mem:read_i8(0xc6218)
if hammer_grab ~= 00 then	
	-- Jumpman is attempting to grab a hammer
	stage = mem:read_i8(0xc6227)      -- Stage (1-girders, 2-pie, 3-elevator, 4-rivets)	
	jumpman_x = mem:read_i8(0xc6205)  -- Jumpman's X position
	
	-- portal jumps vary for each stage
	if stage == 1 then 
		if jumpman_x < 0 then
			update_portal_ram(36, 100, 113)  -- top to bottom
		else
			update_portal_ram(187, 192, -46) -- bottom to top
		end
	elseif stage == 4 then 
		if jumpman_x > 100 then
			update_portal_ram(33, -110, -96) -- top to bottom
		else
			update_portal_ram(126, 106, 120) -- bottom to top
		end
	elseif stage == 2 then
		if jumpman_x < -100 then
			update_portal_ram(124, 180, -45) -- top to bottom
		else
			update_portal_ram(27, 140, -96)  -- bottom to top
		end
	end				
end
