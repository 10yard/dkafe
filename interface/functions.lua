-- DKAFE functions

function get_loaded()
	return emu["loaded"]
end   

function string:split(sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end
      
function number_to_binary(x)
	local ret = ""
	while x~=1 and x~=0 do
		ret = tostring(x%2) .. ret
		x=math.modf(x/2)
	end
	ret = tostring(x)..ret
	return string.format("%08d", ret)
end	  
	  
function get_formatted_data(var_name)
	-- read environment variable and convert comma separated values to a table
	local content = os.getenv(var_name)
	if content ~= nil then
		content = content:split(",")
	else content = {}
	end
	return content
end   

function toggle(sync_with)
	sync_with = sync_with or "1UP"
	if sync_with == "1UP" then
		-- Sync with flashing 1UP
		if math.fmod(mem:read_i8(0xc601a) + 128, 32) <= 16 then	
			return 1
		else
			return 0
		end
	elseif sync_with == "TIMER" then
		-- Sync with bonus timer
		if math.fmod(mem:read_i8(0xc638c), 2) == 0 then
			return 1
		else
			return 0
		end
	end
end

function get_score()
  -- read score from top left,  allowing for 6 and 7 digit scores
  _s1 = tostring(mem:read_i8(0xc7781))
  if _s1 ~= "16" then
    _s2 = tostring(mem:read_i8(0xc7761))
    _s3 = tostring(mem:read_i8(0xc7741))
    _s4 = tostring(mem:read_i8(0xc7721))
    _s5 = tostring(mem:read_i8(0xc7701))
    _s6 = tostring(mem:read_i8(0xc76e1))
    _s7 = tostring(mem:read_i8(0xc76c1))
    if _s7 == "16" then
      _score = tonumber(_s1.._s2.._s3.._s4.._s5.._s6)
    else
      _score = tonumber(_s1.._s2.._s3.._s4.._s5.._s6.._s7)  
    end
  else
    _score = 0
  end
	return _score
end

function set_score(score)
	-- update score on screen
	_padded_score = string.format("%06d", score)
	write_message(0xc7781, _padded_score) -- update screen as it otherwise may not be updated
	-- update score in ram
	_s1 = string.sub(_padded_score, 1, 2)
	_s2 = string.sub(_padded_score, 3, 4)
	_s3 = string.sub(_padded_score, 5, 6)
	mem:write_i8(0xc60b4, tonumber(_s1, 16))
	mem:write_i8(0xc60b3, tonumber(_s2, 16))
	mem:write_i8(0xc60b2, tonumber(_s3, 16))
end

function get_highscore()
	local highscore = ""
	if emu.romname() == "dkongx11" or data_subfolder == "dkongrdemo" then
		for key, value in pairs(ram_scores) do
			if key <= 7 then
				highscore = highscore .. mem:read_i8(value)
			end
		end	
	else
		for _, value in pairs(ram_high) do
			highscore = highscore .. mem:read_i8(value)
		end	
		if highscore == "161616161616" then 
			highscore = "000000" 
		end
	end
	return highscore
end

function draw_block(x, y, color1, color2)
	screen:draw_box(x, y, x+8, y+8, color1, 0)
	screen:draw_box(x, y, x+1, y+8, color2, 0)
	screen:draw_box(x+6, y, x+7, y+8, color2, 0)
	screen:draw_box(x+2, y+2, x+6, y+6, 0xcff000000, 0)
	screen:draw_box(x+3, y+1, x+5, y+7, 0xcff000000, 0)
end

function block_text(text, x, y, color1, color2)
	-- Write large block characters
	local _x = x
	local _y = y
  local width = 0
  local blocks = ""
	for i=1, string.len(text) do 
		blocks = dkblock[string.sub(text, i, i)]
		width = math.floor(string.len(blocks) / 5)
		for b=1, string.len(blocks) do
			if string.sub(blocks, b, b) == "#" then
				draw_block(_x, _y, color1, color2)
			end
			if math.fmod(b, width) == 0 then
				_y = _y - (width - 1) * 8 
				_x = _x - 8
			else
				_y = _y + 8
			end
		end
		_x = x
		_y = _y + (width * 8) + 8
	end
end

function write_message(start_address, text)
	-- write characters of message to DK's video ram
	for key=1, string.len(text) do
		mem:write_i8(start_address - ((key - 1) * 32), dkchars[string.sub(text, key, key)])
	end
end

function clear_sounds()
  -- clear music on soundcpu
  for key = 0, 32 do
    soundmem:write_i8(0x0 + key, 0x00)
  end
  
  -- clear sound fx buffer
  for key = 0, 8 do
    mem:write_i8(0xc6080 + key, 0x00)
  end
end

function max_throttle(switch)
  if switch == 1 then
    video.throttle_rate = 250
    if data_emulator == "dkwolf" then
      video.frameskip = 11  -- dkwolf has an increased max throttle
    else
      video.frameskip = 8
    end
    video.throttled = false
  else
    video.throttle_rate = 1
    video.frameskip = 0
    video.throttled = true
  end
end

function fast_skip_intro()
  -- Skip the DK climb intro when jump button is pressed
  if data_allow_skip_intro == "1" then
      if mode1 == 3 then
        if mode2 == 7 then
          if string.sub(number_to_binary(mem:read_i8(0xc7c00)), 4, 4) == "1" then
            player_skipped_intro = 1
            max_throttle(1)
          end
          if player_skipped_intro == 1 then
            -- clear music and soundfx as they won't sound good
            clear_sounds()
          end
        else
          skip_intro = 0
          max_throttle(0)
    end
      end
    end    
end

function display_awards()
	if data_show_award_targets == "1" and mode1 == 3 and mode2 == 7 then
		-- Show score awards during the DK climb scene/intro
        
		local dkclimb = mem:read_i8(0xc638e)
		local offset = 0
		if emu.romname() == "dkongjr" then
			offset = 1
			dkclimb = dkclimb - 36
		end
		if emu.romname() == "dkongx" then
      dkclimb = mem:read_i8(0xc691f)
      if dkclimb < 0 then
        dkclimb = dkclimb + 256
      end
      dkclimb = math.floor((dkclimb + 51) / 8)
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
		-- Show progress against targets at top of screen replacing high score
		if score > data_score1 then
			write_message(0xc76a0, "            ")
			write_message(0xc76a0, "1ST WON " .. data_award1)
		elseif score > data_score2 then
			write_message(0xc76a0, "            ")
			write_message(0xc76a0, "2ND WON " .. data_award2)
		elseif score > data_score3 then
			write_message(0xc76a0, "            ")
			write_message(0xc76a0, "3RD WON " .. data_award3)
		end 
	end
	
	if data_show_hud == "1" or data_show_hud == "2" or data_show_hud == "3" then
		-- Toggle the HUD using P2 Start button
		if data_autostart == "0" and string.sub(number_to_binary(mem:read_i8(0xc7d00)), 5, 5) == "1" then
			if os.clock() - data_last_toggle > 0.25 then
				data_last_toggle = os.clock()
				data_toggle_hud = data_toggle_hud + 1
			end
		end
      
		--Clear the HUD
    write_message(0xc7500, "       ")
		write_message(0xc7501, "       ")
		write_message(0xc7502, "       ")
		  
    if data_toggle_hud == 1 then
      if emu.romname() ~= "dkongx11" then
        write_message(0xc7500, "1="..data_score1_k)
        write_message(0xc7501, "2="..data_score2_k)
        write_message(0xc7502, "3="..data_score3_k)
      else
        write_message(0xc7500, "1."..data_score1_k)
        write_message(0xc7501, "2."..data_score2_k)
        write_message(0xc7502, "3."..data_score3_k)
      end
    elseif data_toggle_hud == 2 then
      if emu.romname() ~= "dkongx11" then
        write_message(0xc7500, data_award1.."[]")
        write_message(0xc7501, data_award2.."[]")
        write_message(0xc7502, data_award3.."[]")
      else
        write_message(0xc7500, data_award1.." C.")
        write_message(0xc7501, data_award2.." C.")
        write_message(0xc7502, data_award3.." C.")
      end
    elseif data_toggle_hud == 3 then
			data_toggle_hud = 0
		end
	end
end

function record_in_compete_file()
	compete_file = io.open(data_file, "w+")
	compete_file:write(emu.romname()  .. "\n")
	compete_file:write(get_highscore() .. "\n")	
end