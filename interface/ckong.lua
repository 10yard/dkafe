--[[
ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
 888    88o  888  o88        888       888          888
 888    888  888888         8  88      888ooo8      888ooo8
 888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
                                        by Jon Wilson (10yard)

DKAFE Interface routine for Crazy Kong
--------------------------------------------------------------
]]

package.path = package.path .. ";" .. os.getenv("DATA_INCLUDES") .. "/?.lua;"
require "functions"
require "graphics"
require "globals"

-- Register function for each frame
------------------------------------------------------------------------------------------------
emu.register_frame(function()

	mode1 = mem:read_u8(0x6005)  -- 1-attract mode, 2-credits entered waiting to start, 3-when playing game
	mode2 = mem:read_u8(0x600a)  -- 1-attract mode, 7-climb scene, 10-how high, 15-dead, 16-game over

  -- load the game up quickly
	if loaded == 0 then
		max_frameskip(true)

		-- Wait for ROM to start
		if mode1 ~= 0 then
			math.randomseed(os.time())
			autostart_delay = math.random(5, 20)
			loaded = 1
		end
	end

	if loaded == 1 then
		max_frameskip(false)

		-- Reset P1 best score for this session
		best_score = 0
		
		-- Insert coins automatically when required
		if tonumber(data_credits) > 0 and tonumber(data_credits) < 90 then
			mem:write_u8(0x6001, data_credits)
			data_credits = "0"
		end

		-- Start game automatically when required
		if data_autostart == "1" then
			if screen:frame_number() > autostart_delay then
				--for k, v in pairs(ports[":IN1"].fields) do print(k) end -- debug to discover button names
				if emu.romname() == "ckongg" or emu.romname() == "ckongs" or emu.romname() == "bigkonggx" then
					ports[":IN1"].fields["1 Player Start"]:set_value(1)
				elseif emu.romname() == "ckongmc" then
					ports[":IN1"].fields["P1 Button 1"]:set_value(1)
				elseif emu.romname() == "kong" then
					ports[":IN1"].fields["One Player Start/Jump"]:set_value(1)
				else
					ports[":SYSTEM"].fields["1 Player Start"]:set_value(1)
				end
				data_autostart = "9" -- autostart has been done
			end
		end
		
		-- Wait for autostart (when necessary) before continuing
		if data_autostart ~= "1" then
			loaded = 2
			emu.register_frame_done(ckong_overlay, "frame")
		end	
	end

	if loaded == 2 then
		score = get_score(0x1c00)
		
		-- Release P1 START button (after autostart)	
		if data_autostart == "9" and mode1 > 2 then
			if emu.romname() == "ckongg" or emu.romname() == "ckongs" or emu.romname() == "bigkonggx" then
				ports[":IN1"].fields["1 Player Start"]:set_value(0)
			elseif emu.romname() == "ckongmc" then
				ports[":IN1"].fields["P1 Button 1"]:set_value(0)
			elseif emu.romname() == "kong" then
				ports[":IN1"].fields["One Player Start/Jump"]:set_value(0)
			else
				ports[":SYSTEM"].fields["1 Player Start"]:set_value(0)
			end
			data_autostart = "0"
		end
						
		if mode1 == 3 and last_mode1 == 3 then
			-- Keep track of best P1 score achieved this session
			if score > best_score then
				best_score = score
			end
		end

		-- Player can skip through the DK climb scene by pressing JUMP button
		fast_skip_ckong_intro()
		
		last_mode1 = mode1
	end
end)

function fast_skip_ckong_intro()
	-- Skip the climb intro when jump button is pressed
	if data_allow_skip_intro == "1" and mode1 == 3 then
		if mode2 == 7 then
			if mem:read_u8(0x6011) == 0x10 then
				skipped_intro = true
				max_frameskip(true)
				sound.attenuation = -32  -- mute sounds
			end
		elseif skipped_intro == true then
			skipped_intro = false
			max_frameskip(false)
			sound.attenuation = i_attenuation  -- restore sounds
		end
	end
end


-- Callback function for frame updates
------------------------------------------------------------------------------------------------
function ckong_overlay()
	-- Show award targets and progress during gameplay
	display_awards(0x1c00)
end

-- Register callback function on exit
------------------------------------------------------------------------------------------------
emu.register_stop(function()
	record_in_compete_file()
end)
