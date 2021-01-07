-- Lava Hack

function calc_jumpmans_top()
	jy = mem:read_i8(0xc6205)
	if jy >= 0 then
		jy = -256 + jy
	end
	jy = 7 - jy  -- 7 to allow lava to come up to his head
	return jy
end

function draw_lava()
	mode1 = mem:read_i8(0xc6005)
	mode2 = mem:read_i8(0xc600a)
	level = mem:read_i8(0xc6229)
	difficulty = 34 - (level * 2) -- lower difficulty is harder
	--print(mode1.." - "..mode2.." - "..level)
	
	if mode2 == 7 or mode2 == 10 or mode2 == 11 then  -- intro / how high can you get
		lava_y = 0
	end

	if mode1 == 3 then	
		if math.fmod((mem:read_i8(0xc601A)), difficulty) == 0 and lava_y < 257 then
			lava_y = lava_y + 1
		end
		manager:machine().screens[":screen"]:draw_box(0, 0, lava_y, 224, 0x99ff0000, 0)
		manager:machine().screens[":screen"]:draw_line(lava_y, 0, lava_y, 224, 0xffff0000)
	end
	
	jumpman_y = calc_jumpmans_top()
	
	if lava_y > jumpman_y then
        --set jumpman status to dead
		mem:write_i8(0xc6200, 0)
	end
end


if loaded == 3 then
	lava_y = 0
	emu["loaded"] = 4
	emu.register_frame_done(draw_lava, "frame")
end