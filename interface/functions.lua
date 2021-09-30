--[[
ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
 888    88o  888  o88        888       888          888
 888    888  888888         8  88      888ooo8      888ooo8
 888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
                                        by Jon Wilson (10yard)

Functions
---------------------------------------------------------------
]]

-- Optimise access to globals used in these functions
local string_sub = string.sub
local string_format = string.format
local math_modf = math.modf
local math_floor = math.floor

function get_loaded()
	return emu["loaded"]
end

function int_to_bin(x)
	local ret = ""
	while x~=1 and x~=0 do
		ret = tostring(x%2) .. ret
		x=math_modf(x/2)
	end
	return string_format("%08d", tostring(x)..ret)
end

function string:split(sep)
	local sep, fields = sep or ":", {}
	local pattern = string_format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end

function get_formatted_data(var_name)
	-- read environment variable and convert CSV data to a table
	local var_data = os.getenv(var_name)
	if var_data ~= nil then
		return var_data:split(",")
	else
		return {}
	end
end

function get_score()
	-- read score from top left,  allowing for 6 and 7 digit scores
	local _score, s1, s2, s3, s4, s5, s6, s7
	_score = 0
	s1 = tostring(mem:read_u8(0xc7781))
	if s1 ~= "16" then
		s2, s3, s4, s5, s6, s7 = tostring(mem:read_u8(0xc7761)), tostring(mem:read_u8(0xc7741)), tostring(mem:read_u8(0xc7721)),
		tostring(mem:read_u8(0xc7701)), tostring(mem:read_u8(0xc76e1)), tostring(mem:read_u8(0xc76c1))
		if s7 == "16" then
			_score = tonumber(s1..s2..s3..s4..s5..s6)
		else
			_score = tonumber(s1..s2..s3..s4..s5..s6..s7)
		end
	end
	return _score
end

function set_score(score)
	-- update score on screen
	local _padded_score = string_format("%06d", score)
	local _offset = 0x00
	if emu.romname() == "dkongx11" or emu.romname() == "dkongx" or emu.romname() == "dkongf" then
		_offset = 0x20
	end
	write_message(0xc7781 - _offset, _padded_score) -- update screen as it otherwise may not be updated
	-- update score in ram
	local _s1, _s2, _s3 = string_sub(_padded_score, 1, 2), string_sub(_padded_score, 3, 4), string_sub(_padded_score, 5, 6)
	mem:write_u8(0xc60b4, tonumber(_s1, 16))
	mem:write_u8(0xc60b3, tonumber(_s2, 16))
	mem:write_u8(0xc60b2, tonumber(_s3, 16))
end

function get_highscore()
	local highscore = ""
	if emu.romname() == "dkongx" or emu.romname() == "dkongx11" or data_subfolder == "dkongrdemo" then
		for key, value in pairs(ram_scores) do
			if key <= 7 then
				highscore = highscore .. mem:read_u8(value)
			end
		end
	else
		for _, value in pairs(ram_high) do
			highscore = highscore .. mem:read_u8(value)
		end
		if highscore == "161616161616" then
			highscore = "000000"
		end
	end
	return highscore
end

function clear_sounds()
	-- clear music on soundcpu
	for key=0, 32 do
		soundmem:write_u8(0x0 + key, 0x00)
	end
	-- clear soundfx buffer
	for key=0, 8 do
		mem:write_u8(0xc6080 + key, 0x00)
	end
end

function max_frameskip(switch)
	if switch == true then
		video.throttled = false
		video.throttle_rate = 1000
		video.frameskip = 8
		if data_emulator == "dkwolf" then
			-- dkwolf has an increased max frameskip
			video.frameskip = 11
		end
	else
		video.throttled = true
		video.throttle_rate = 1
		video.frameskip = 0
	end
end

function fast_skip_intro()
	-- Skip the DK climb intro (and mute sounds) when jump button is pressed
	if data_allow_skip_intro == "1" and mode1 == 3 then
		if mode2 == 7 then
			if string_sub(int_to_bin(mem:read_u8(0xc7c00)), 4, 4) == "1" then
				skipped_intro = true
				max_frameskip(true)
			end
			if skipped_intro == true then
				clear_sounds()
			end
		elseif skipped_intro == true then
			skipped_intro = false
			max_frameskip(false)
		end
	end
end

function display_awards()
	if data_show_award_targets == "1" and mode1 == 3 and mode2 == 7 then
		-- Show score awards during the DK climb scene/intro
		local dkclimb = mem:read_u8(0xc638e)
		local offset = 0
		if emu.romname() == "dkongjr" then
			offset = 1
			dkclimb = dkclimb - 36
		end
		if emu.romname() == "dkongx" then
			dkclimb = math_floor((mem:read_u8(0xc691f) + 51) / 8)
		end
		if dkclimb >= 10 then
			if dkclimb <= 17 then
				write_message(0xc7770 + (offset * 7), "1ST PRIZE")
				write_message(0xc7570 + (offset * 7), "AT "..tostring(data_score1))
			end
			if dkclimb <= 21 then
				write_message(0xc7774 + (offset * 5), "2ND PRIZE")
				write_message(0xc7574 + (offset * 5), "AT "..tostring(data_score2))
			end
			if dkclimb <= 25 then
				write_message(0xc7778 + (offset * 3), "3RD PRIZE")
				write_message(0xc7578 + (offset * 3), "AT "..tostring(data_score3))
			end
			if dkclimb <= 29 then
				write_message(0xc777c + offset, "PLAY TO WIN COINS")
			end
		end
	end

	if data_show_award_progress == "1" and mode1 == 3 then
		score = tonumber(score)
		-- Show progress against targets at top of screen replacing high score
		if score > data_score3 then
			write_message(0xc76e0, "              ")
			if score > data_score1 then
				write_message(0xc76a0, "1ST WON " .. data_award1 .. "  ")
			elseif score > data_score2 then
				write_message(0xc76a0, "2ND WON " .. data_award2 .. "  ")
			else
				write_message(0xc76a0, "3RD WON " .. data_award3 .. "  ")
			end
		end
	end

	if data_show_hud == "1" or data_show_hud == "2" or data_show_hud == "3" then
		-- Toggle the HUD using P2 Start button
		if data_autostart == "0" and string_sub(int_to_bin(mem:read_u8(0xc7d00)), 5, 5) == "1" then
			if os.clock() - data_last_toggle > 0.25 then
				data_last_toggle = os.clock()
				data_toggle_hud = data_toggle_hud + 1
			end
		end
		-- Display the HUD
		local msg1, msg2, msg3, sep = "       ", "       ", "       ", {"=", "[]"}
		if emu.romname() == "dkongx11" then
			sep = {".", " C."}
		end
		if data_toggle_hud == 1 then
			msg1, msg2, msg3 = "1"..sep[1]..data_score1_k, "2"..sep[1]..data_score2_k, "3"..sep[1]..data_score3_k
		elseif data_toggle_hud == 2 then
			msg1, msg2, msg3 = data_award1..sep[2], data_award2..sep[2], data_award3..sep[2]
		elseif data_toggle_hud == 3 then
			data_toggle_hud = 0
		end
		write_message(0xc7500, msg1)
		write_message(0xc7501, msg2)
		write_message(0xc7502, msg3)
	end
end

function record_in_compete_file()
	compete_file = io.open(data_file, "w+")
	compete_file:write(emu.romname()  .. "\n")
	compete_file:write(get_highscore() .. "\n")
end