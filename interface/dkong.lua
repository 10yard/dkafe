--[[
ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
 888    88o  888  o88        888       888          888
 888    888  888888         8  88      888ooo8      888ooo8
 888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
                                        by Jon Wilson (10yard)

Interface routine for Donkey Kong
--------------------------------------------------------------
Set target score, registered player names and player scores.
Dump highscore to file when finished.
Show prizes and progress in the game (optional).
--------------------------------------------------------------
]]

data_includes_folder = os.getenv("DATA_INCLUDES")
package.path = package.path .. ";" .. data_includes_folder .. "/?.lua;"
require "functions"
require "graphics"
require "globals"

-- Register function for each frame
------------------------------------------------------------------------------------------------
emu.register_frame(function()
	_, loaded = pcall(get_loaded)

	if loaded == nil then
		-- Update ROM on start
		emu["loaded"] = 1
		for key, value in pairs(rom_scores) do
			mem:write_direct_u8(value, data_scores[key])
		end
	end

	if loaded == 1 then
		-- Skip past startup screen of DK2 when required
		max_frameskip(data_allow_skip_intro == "1" and emu.romname() == "dkongx")

		-- Update RAM when ready
		if mem:read_u8(ram_players[1]) > 0 and ( emu.romname() ~= "dkongx" or mem:read_u8("0xc0000") < 0 ) then
			emu["loaded"] = 2
			for key, value in pairs(ram_high) do
				mem:write_u8(value, data_high[key])
			end
			for key, value in pairs(ram_high_DOUBLE) do
				mem:write_u8(value, data_high_DOUBLE[key])
			end
			for key, value in pairs(ram_scores) do
				mem:write_u8(value, data_scores[key])
			end
			for key, value in pairs(ram_scores_DOUBLE) do
				mem:write_u8(value, data_scores_DOUBLE[key])
			end
			for key, value in pairs(ram_players) do
				mem:write_u8(value, data_players[key])
			end
		end
	end

	if loaded == 2 then
		-- Insert coins automatically when required
		if tonumber(data_credits) > 0 and tonumber(data_credits) < 90 then
			mem:write_u8(0x6001, data_credits)
		end
		-- Start game automatically when required
		if data_autostart == "1" then
			ports[":IN2"].fields["1 Player Start"]:set_value(1)
		end
		emu["loaded"] = 3
		emu.register_frame_done(dkong_overlay, "frame")
	end

	if loaded == 3 then
		mode1 = mem:read_u8(0xc6005)  -- 1-attract mode, 2-credits entered waiting to start, 3-when playing game
		mode2 = mem:read_u8(0xc600a)  -- Status of note: 7-climb scene, 10-how high, 15-dead, 16-game over
		stage = mem:read_u8(0xc6227)  -- 1-girders, 2-pie, 3-elevator, 4-rivets, 5-extra/bonus
		score = get_score()

		-- Release P1 START button (after autostart)
		if data_autostart == "1" and mode1 == 3 and mode2 == 7 then
			ports[":IN2"].fields["1 Player Start"]:set_value(0)
			data_autostart = "0"
		end

		-- Player can skip through the DK climb scene by pressing JUMP button
		fast_skip_intro()

		-- Player can end game early by pressing COIN button
		if mode1 == 3 and data_coin_ends == "1" and string.sub(int_to_bin(mem:read_u8(0xc7d00)), 1, 1) == "1" then
			mem:write_u8(0xc6228, 1)
			mem:write_u8(0xc6200, 0)
		end
	end
end)

-- Callback function for frame updates
------------------------------------------------------------------------------------------------
function dkong_overlay()
	-- Show award targets and progress during gameplay (optional)
	display_awards()
end

-- Register callback function on exit
------------------------------------------------------------------------------------------------
emu.register_stop(function()
	record_in_compete_file()
end)
