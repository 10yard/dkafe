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

--function display_text(start_position, text_list, clear)
--	x_byte = start_position
--	for key, value in pairs(text_list) do
--		if clear ~= 1 then
--			mem:write_i8(x_byte, value)
--		else
--			mem:write_i8(x_byte, 0x10)
--		end
--		x_byte = x_byte - 0x20
--	end
--end

function draw_lava()
	mode1 = mem:read_i8(0xc6005)
	mode2 = mem:read_i8(0xc600a)
	level = mem:read_i8(0xc6229)
	stage = mem:read_i8(0xc6227) 
	difficulty = 34 - (level * 2) -- lower difficulty is harder
	--print("Mode1: "..mode1.." Mode2: "..mode2.." Stage: "..stage.." Lava Y: "..lava_y)
	
	if mode2 == 7 or mode2 == 10 or mode2 == 11 then  -- intro / how high can you get
		-- reset lava level
		lava_y = -7
	elseif mode2 == 21 and lava_y > 15 then
		-- Reduce lava level on high score entry screens to avoid obstruction.
		lava_y = 15
	elseif mode2 == 16 and lava_y > 60 then
		-- Reduce lava level on game over screens to avoid obstruction.
		lava_y = 60
	end

	jumpman_y = calc_sprite_top()

	if mode1 == 3 then
		if mode2 == 12 then			
			-- issue warning to Jumpman
			--if lava_y + 11 > jumpman_y then
			--	start_pos = 0xc7603
			--	msg = {0x20,0x11,0x1e,0x19,0x13,0x36}						
			--	blink_toggle = mem:read_i8(0xc7720) -- sync with the flashing 1UP 
			--	if blink_toggle ~= 16 then
			--		display_text(start_pos, msg, 0)
			--	else
			--		display_text(start_pos, msg, 1)			
			--	end
			--end
			manager:machine().screens[":screen"]:draw_text(50, 50, "DON'T PANIC", 0xffffffff)
		
			if lava_y > jumpman_y then
				--set jumpman status to dead
				mem:write_i8(0xc6200, 0)
			elseif math.fmod((mem:read_i8(0xc601A)), difficulty) == 0 then
				-- Game is active.  Lava rises periodically based on the difficulty
				lava_y = lava_y + 1
			end
		end
		
		-- draw rising lava 
		manager:machine().screens[":screen"]:draw_box(0, 0, lava_y, 224, 0xddff0000, 0)
		
		-- workaround Lua bug which prevent rightmost pixel being drawn
		-- the pixel is blacked out with a text block
		for i=0, 256 do	
			if math.fmod(i, 9) == 0 then
				manager:machine().screens[":screen"]:draw_text(i, 222, "#", 0xff000000)
			end
		end
		
		-- add flames
		for i=0, 224 do		
			if math.fmod(i, 14) == 0 then
				adjust_y = math.random(-4, 4)
				if adjust_y >= 0 then
					flame_color = 0xffffbd2e  -- yellow flame
				else
					flame_color = 0xffff0000  -- red flame
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
		lava_y = -7
		emu.register_frame_done(draw_lava, "frame")
	end
	lava_hack_started = 1

end