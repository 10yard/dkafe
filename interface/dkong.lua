--[[
ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
 888    88o  888  o88        888       888          888
 888    888  888888         8  88      888ooo8      888ooo8
 888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
                                        by Jon Wilson (10yard)

DKAFE Interface routine for Donkey Kong
--------------------------------------------------------------
]]

package.path = package.path .. ";" .. os.getenv("DATA_INCLUDES") .. "/?.lua;"
require "functions"
require "graphics"
require "globals"

-- Register function for each frame
------------------------------------------------------------------------------------------------
emu.register_frame(function()
	_, loaded = pcall(get_loaded)

	if loaded == nil then
		math.randomseed(os.time())
		autostart_delay = screen:frame_number() + math.random(1, 30)
		
		-- Wait for ROM to start
		if emu.romname() == "dkongx" and mem:read_u8(0xc600a) ~= 1 then
			-- Speed through the power up self test
			max_frameskip(true)
		else
			emu["loaded"] = 1
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
				ports[":IN2"].fields["1 Player Start"]:set_value(1)
				data_autostart = "0"
			end
		end
		
		-- Wait for autostart (when necessary) before continuing
		if data_autostart ~= "1" then
			emu["loaded"] = 2
			emu.register_frame_done(dkong_overlay, "frame")
		end	
	end

	if loaded == 2 then
		mode1 = mem:read_u8(0xc6005)  -- 1-attract mode, 2-credits entered waiting to start, 3-when playing game
		mode2 = mem:read_u8(0xc600a)  -- Status of note: 7-climb scene, 10-how high, 15-dead, 16-game over
		stage = mem:read_u8(0xc6227)  -- 1-girders, 2-pie, 3-elevator, 4-rivets, 5-extra/bonus
		score = get_score()
		
		if mode1 == 3 and last_mode1 == 3 then
			-- Keep track of best P1 score achieved this session
			if score > best_score then
				best_score = score
			end

			-- Release P1 START button (after autostart)
			if data_autostart == "1" then
				ports[":IN2"].fields["1 Player Start"]:set_value(0)
				data_autostart = "0"
			end
		end

		-- Player can skip through the DK climb scene by pressing JUMP button
		fast_skip_intro()

		last_mode1 = mode1
	end
end)

-- Callback function for frame updates
------------------------------------------------------------------------------------------------
function dkong_overlay()
	-- Show award targets and progress during gameplay
	display_awards()
end

-- Register callback function on exit
------------------------------------------------------------------------------------------------
emu.register_stop(function()
	record_in_compete_file()
end)
