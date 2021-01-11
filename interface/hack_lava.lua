-- Rising Lava and Flames Hack
-- Lava rises up the level 


function calc_sprite_top(sprite)
	-- calculate the Y position of Jumpman
	_y = mem:read_i8(0xc6205)
	if _y >= 0 then
		_y = -256 + _y
	end
	_y = 8 - _y  -- 8 to allow lava to rise to sprite height + 1
	return _y
end


function draw_lava()
	mode1 = mem:read_i8(0xc6005)
	mode2 = mem:read_i8(0xc600a)
	level = mem:read_i8(0xc6229)
	stage = mem:read_i8(0xc6227)   -- Stage (1-girders, 2-pie, 3-elevator, 4-rivets)
	difficulty = 34 - (level * 2) -- lower difficulty is harder
	
	if mode2 == 7 or mode2 == 10 or mode2 == 11 then  -- intro / how high can you get
		-- reset some variables
		lava_y = -7
	elseif mode2 == 21 and lava_y > 15 then
		-- Reduce lava level on high score entry screens to avoid obstruction.
		lava_y = 15
	elseif mode2 == 16 and lava_y > 60 then
		-- Reduce lava level on game over screens to avoid obstruction.
		lava_y = 60
	end
	
	--print("Mode1: "..mode1.." Mode2: "..mode2)
	jumpman_y = calc_sprite_top()

	if mode1 == 3 then
		-- draw rising lava
		manager:machine().screens[":screen"]:draw_box(0, 0, lava_y, 224, 0xddff0000, 0)
		
		if mode2 == 12 then			
			-- issue warning to Jumpman
			if lava_y + 9 > jumpman_y then
				-- flash colour palette A for dramatic effect
				blink_toggle = mem:read_i8(0xc7720) -- sync with the flashing 1UP 
				if blink_toggle == 16 then
					mem:write_i8(0xc7d86, 1)
					block_text("DON'T PANIC !!", 111, 1, color_yellow, 3)
				else
					mem:write_i8(0xc7d86, 0)
					block_text("DON'T PANIC !!", 105, 5, color_red, 3)
				end
			else
				-- revert to default
				if stage == 1 or stage == 3 then
					mem:write_i8(0xc7d86, 0)
				else
					mem:write_i8(0xc7d86, 1)
				end
			end
		
			if lava_y > jumpman_y + 1 then
				--set jumpman status to dead
				mem:write_i8(0xc6200, 0)
			elseif math.fmod((mem:read_i8(0xc601A)), difficulty) == 0 then
				-- Game is active.  Lava rises periodically based on the difficulty
				lava_y = lava_y + 1
			end
		end
				
		-- workaround Lua bug which prevent rightmost pixel being drawn
		-- the pixel is blacked out with a text block
		for i=0, 256 do	
			if math.fmod(i, 8) == 0 then
				manager:machine().screens[":screen"]:draw_text(i, 223, "#", 0xff000000)
			end
		end
		
		-- add flames
		for i=0, 224 do		
			if math.fmod(i, 14) == 0 then
				adjust_y = math.random(-4, 4)
				if adjust_y >= 0 then
					flame_color = color_yellow
				else
					flame_color = color_red
				end
				tweak_y = lava_y + adjust_y
				if tweak_y > 0 then
					manager:machine().screens[":screen"]:draw_text(tweak_y, i, "~", flame_color)
				end
			end
		end
	end
end

if loaded == 3 then
	if lava_hack_started ~= 1 then
		--initialise some variables
		color_yellow = 0xffffbd2e
		color_red =  0xffff0000 
		lava_y = -7
		--register the frame drawing callback
		emu.register_frame_done(draw_lava, "frame")
	end
	lava_hack_started = 1

end