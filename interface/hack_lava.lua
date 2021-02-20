-- DKAFE Lava Hack by Jon Wilson
--------------------------------
-- Drives additional features of the "DK Lava Panic" hack:
-- Jumpman must keep his cool and move quickly to avoid the rising Lava.

function draw_lava()
	local level = mem:read_i8(0xc6229)
  local difficulty = math.floor(1.2 * (22 - level))
	if stage == 4 then
    -- rivets needs more time
		difficulty = math.floor(1.5 * (22 - level))
	elseif stage == 3 then
    -- elevators needs less time
		difficulty = math.floor(0.6 * (22 - level))
	end
	
	if mode2 == 7 or mode2 == 10 or mode2 == 11 or mode2 == 1 then
    -- reset lava level at start of game or when in attract mode
		lava_y = -7
    -- remember default music
		music = mem:read_i8(0xc6089)		
	elseif mode2 == 21 and lava_y > 15 then
    -- Reduce lava level on high score entry screens to avoid obstruction.
		lava_y = 15
	elseif mode2 == 16 and lava_y > 60 then
    -- Reduce lava level on game over screens to avoid obstruction.    
		lava_y = 60
	end
	
	if mode1 == 3 or (mode1 == 1 and mode2 >= 2 and mode2 <= 4) then
		-- draw rising lava
		screen:draw_box(0, 0, lava_y, 224, 0xddff0000, 0)
		
		if mode2 == 12 or (mode1 == 1 and mode2 >= 2 and mode2 <= 3) then	
			jumpman_y = get_jumpman_y()
			-- issue warning to Jumpman
			if lava_y + 10 > jumpman_y then
				-- dim the screen above lava flow
				screen:draw_box(256, 224, lava_y, 0, 0xc77990000, 0)
				
				-- flash colour palette for dramatic effect
				if toggle() == 1 then
					mem:write_i8(0xc7d86, 1)
					block_text("PANIC!", 128, 16, 0xcffEE7511, 0xcffF5BCA0) 					
				else					
					mem:write_i8(0xc7d86, 0)
				end

				-- temporary change music for more drama
				if stage ~= 2 then
					mem:write_i8(0xc6089, 9)
				else
					mem:write_i8(0xc6089, 11)
				end
			else
				-- reset palette to default
				if stage == 1 or stage == 3 then
					mem:write_i8(0xc7d86, 0)
				else
					mem:write_i8(0xc7d86, 1)
				end
				-- set music back to default
				mem:write_i8(0xc6089, music)
			end
		
			if lava_y > jumpman_y + 1 then
				-- lava has engulfed Jumpman. Set status to dead
				mem:write_i8(0xc6200, 0)
			elseif math.fmod((mem:read_i8(0xc601A)), difficulty) == 0 then
				-- Game is active.  Lava rises periodically based on the difficulty
				if mem:read_i8(0xc6350) == 0 then
					-- Lava shouldn't rise when an item is being smashed by the hammer
					lava_y = lava_y + 1
				end
			end
		end
						
		-- add dancing flames above lava
		for i=0, 224 do		
			if math.fmod(i, 18) == 0 then
        local adjust_y = math.random(-3, 3)
				local flame_y = lava_y + adjust_y
				local flame_color = BLACK
				if flame_y > 0 then
					if adjust_y > 0  then flame_color = ORANGE end
					if adjust_y < 0  then flame_color = RED    end
					screen:draw_text(flame_y, i, "~", flame_color)
				end
			end
		end
	end
end

-- PROGRAM START --

if loaded == 3 then
	if lava_hack_started ~= 1 then
		--register the frame drawing callback
		emu.register_frame_done(draw_lava, "frame")
	end
	lava_hack_started = 1
end