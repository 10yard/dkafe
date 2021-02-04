-- DKAFE Lava Hack 
------------------
-- Drives additional features of the "DK Lava Panic" hack:
-- Jumpman must keep his cool and move quickly to avoid the rising Lava.

function calc_sprite_top()
	-- calculate Jumpman Y position
	local _y = mem:read_i8(0xc6205)
	if _y >= 0 then
		_y = -256 + _y
	end
	_y = 8 - _y  -- 8 to allow lava to rise to sprite height + 1
	return _y
end

function draw_lava()
	level = mem:read_i8(0xc6229)
	if stage == 4 then
		difficulty = math.floor(1.5 * (22 - level)) -- lower difficulty is harder, rivets needs more time
	elseif stage == 3 then
		difficulty = math.floor(1.0 * (22 - level)) -- lower difficulty is harder, elevators needs less time
	else
		difficulty = math.floor(1.2 * (22 - level)) -- lower difficulty is harder
	end
	
	if mode2 == 7 or mode2 == 10 or mode2 == 11 then  -- intro / how high can you get
		lava_y = -7  --reset lava
		music = mem:read_i8(0xc6089)		

	elseif mode2 == 21 and lava_y > 15 then
		lava_y = 15  -- Reduce lava level on high score entry screens to avoid obstruction.
	elseif mode2 == 16 and lava_y > 60 then
		lava_y = 60  -- Reduce lava level on game over screens to avoid obstruction.
	end
	
	if mode1 == 3 then
		-- draw rising lava
		screen:draw_box(0, 0, lava_y, 224, lava_colour, 0)
		
		if mode2 == 12 then	
			jumpman_y = calc_sprite_top()
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
				-- lava has engulfed Jumpman. Set his status to dead
				mem:write_i8(0xc6200, 0)
			elseif math.fmod((mem:read_i8(0xc601A)), difficulty) == 0 then
				-- Game is active.  Lava rises periodically based on the difficulty
				if mem:read_i8(0xc6350) == 0 then
					-- Lava shouldn't rise when item is being smashed with hammer
					lava_y = lava_y + 1
				end
			end
		end
				
		-- workaround Lua bug which prevents the rightmost pixels from being drawn
		-- the pixels are blacked out with a text block
		for i=0, 256 do	
			if math.fmod(i, 8) == 0 then
				screen:draw_text(i, 223, "#", BLACK)
			end
		end
		
		-- add flames
		for i=0, 224 do		
			if math.fmod(i, 14) == 0 then
				adjust_y = math.random(-3, 3)
				flame_y = lava_y + adjust_y
				if flame_y > 0 then
					if adjust_y == 0 then flame_color = BLACK  end
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
		--initialise some variables
		lava_colour = 0xddff0000
		lava_y = -7		
		--register the frame drawing callback
		emu.register_frame_done(draw_lava, "frame")
	end
	lava_hack_started = 1
end