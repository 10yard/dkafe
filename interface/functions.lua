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

function get_loaded()
	return emu["loaded"]
end

function int_to_bin(x)
	local ret = ""
	while x~=1 and x~=0 do
		ret = tostring(x%2) .. ret
		x=math.modf(x/2)
	end
	return string.format("%08d", tostring(x)..ret)
end

function get_score(offset)
	-- read P1 score from the top line,  allowing for 6 and 7 digit scores
	-- address offset can be used for not DK roms (such as crazy kong) 
	local _score, _s, _offset
	_score = 0
	_offset = offset or 0 
	
	_s = mem:read_u8(0xc7781 + _offset)
	if _s <= 9 then
		_score = tostring(_s)
		for k, v in ipairs({0xc7761, 0xc7741, 0xc7721, 0xc7701, 0xc76e1, 0xc76c1}) do
			_s = mem:read_u8(v + _offset)
			if k < 6 or _s <= 9 then
				_score = _score..tostring(_s)
			end
		end
		_score = tonumber(_score)
	end
	return _score
end

function set_score(score)
	-- update score on screen
	local _padded_score = string.format("%06d", score)
	local _offset = 0x00
	if emu.romname() == "dkongx11" or emu.romname() == "dkongx" or emu.romname() == "dkongf" then
		_offset = 0x20
	end
	write_message(0xc7781 - _offset, _padded_score) -- update screen as it otherwise may not be updated
	-- update score in ram
	local _s1, _s2, _s3 = string.sub(_padded_score, 1, 2), string.sub(_padded_score, 3, 4), string.sub(_padded_score, 5, 6)
	mem:write_u8(0xc60b4, tonumber(_s1, 16))
	mem:write_u8(0xc60b3, tonumber(_s2, 16))
	mem:write_u8(0xc60b2, tonumber(_s3, 16))
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
			if string.sub(int_to_bin(mem:read_u8(0xc7c00)), 4, 4) == "1" then
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

function display_awards(rom_offset)
	local _rom_offset = rom_offset or 0
	if data_show_award_targets == "1" and mode1 == 3 and mode2 == 7 then
		-- Show score awards during the DK climb scene/intro
		local _dkclimb = mem:read_u8(0xc638e)
		local _adjust = 0 -- vertical adjustment
		if emu.romname() == "dkongjr" then
			_adjust = 1
			_dkclimb = _dkclimb - 36
		end
		if emu.romname() == "dkongx" then
			_dkclimb = math.floor((mem:read_u8(0xc691f) + 51) / 8)
		end
		if _dkclimb >= 10 then
			if _dkclimb <= 17 then
				write_message(0xc7770 + _rom_offset + (_adjust * 7), "1ST PRIZE")
				write_message(0xc7570 + _rom_offset + (_adjust * 7), "AT "..tostring(data_score1))
			end
			if _dkclimb <= 21 then
				write_message(0xc7774 + _rom_offset + (_adjust * 5), "2ND PRIZE")
				write_message(0xc7574 + _rom_offset + (_adjust * 5), "AT "..tostring(data_score2))
			end
			if _dkclimb <= 25 then
				write_message(0xc7778 + _rom_offset + (_adjust * 3), "3RD PRIZE")
				write_message(0xc7578 + _rom_offset + (_adjust * 3), "AT "..tostring(data_score3))
			end
			if _dkclimb <= 29 then
				write_message(0xc777c + _rom_offset + _adjust, "PLAY TO WIN COINS")
			end
		end
	end

	if data_show_award_progress == "1" and mode1 == 3 then
		-- Show progress against targets at top of screen replacing high score
		if best_score >= data_score3 then
			write_message(0xc76e0, "              ")
			if data_subfolder == "dkongwizardry" or data_subfolder == "dkongaccelerate" then -- see https://github.com/10yard/dkafe/issues/7
				if best_score >= data_score1 then
					write_message(0xc7660 + _rom_offset, "WON 1ST!")
				elseif best_score >= data_score2 then
					write_message(0xc7660 + _rom_offset, "WON 2ND!")
				else
					write_message(0xc7660 + _rom_offset, "WON 3RD!")
				end
			else
				if best_score >= data_score1 then
					write_message(0xc76a0 + _rom_offset, "1ST WON " .. data_score1_award .. "  ")
				elseif best_score >= data_score2 then
					write_message(0xc76a0 + _rom_offset, "2ND WON " .. data_score2_award .. "  ")
				else
					write_message(0xc76a0 + _rom_offset, "3RD WON " .. data_score3_award .. "  ")
				end
			end	
		end
	end

	if data_show_hud == "1" or data_show_hud == "2" or data_show_hud == "3" then
		-- Toggle the HUD using P2 Start button
		if data_autostart == "0" and string.sub(int_to_bin(mem:read_u8(0xc7d00)), 5, 5) == "1" then
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
			if data_subfolder == "dkonghrthnt" then
				msg1 = " "..sep[1]..data_score1_k  -- Workaround alternative palette colour for DK Hearthunt
				draw_1()
			end
		elseif data_toggle_hud == 2 then
			msg1, msg2, msg3 = data_score1_award..sep[2], data_score2_award..sep[2], data_score3_award..sep[2]
		elseif data_toggle_hud == 3 then
			data_toggle_hud = 0
		end
		write_message(0xc7500 + _rom_offset, msg1)
		write_message(0xc7501 + _rom_offset, msg2)
		write_message(0xc7502 + _rom_offset, msg3)
	end
end

function record_in_compete_file()
	if data_file then
		compete_file = io.open(data_file, "w+")
		compete_file:write(emu.romname()  .. "\n")
		compete_file:write(tostring(best_score) .. "\n")
	end
end