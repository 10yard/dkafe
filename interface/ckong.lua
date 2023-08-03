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
	_, loaded = pcall(get_loaded)

	if loaded == nil then
		math.randomseed(os.time())
		autostart_delay = screen:frame_number() + math.random(5, 30)
		
		-- Wait for ROM to start
		emu["loaded"] = 1
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
				ports[":SYSTEM"].fields["1 Player Start"]:set_value(1)
				data_autostart = "0"
			end
		end
		
		-- Wait for autostart (when necessary) before continuing
		if data_autostart ~= "1" then
			emu["loaded"] = 2
			emu.register_frame_done(ckong_overlay, "frame")
		end	
	end

	if loaded == 2 then
		mode1 = mem:read_u8(0xc6005)  -- 1-attract mode, 2-credits entered waiting to start, 3-when playing game
		mode2 = mem:read_u8(0xc600a)  -- Status of note: 7-climb scene, 10-how high, 15-dead, 16-game over
		score = get_score(0x1c00)
						
		if mode1 == 3 and last_mode1 == 3 then
			-- Keep track of best P1 score achieved this session
			if score > best_score then
				best_score = score
			end

			-- Release P1 START button (after autostart)
			if data_autostart == "1" then
				ports[":SYSTEM"].fields["1 Player Start"]:set_value(0)
				data_autostart = "0"
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
			end
		elseif skipped_intro == true then
			skipped_intro = false
			max_frameskip(false)
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
