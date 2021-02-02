-- DKAFE Interface for DKONG
-- Set target score, registered names/scores and dump highscore to file when finished.  Enable some hacks.
-- 0. Update ROM on start
-- 1. Update RAM
-- 2. Update coins (optional) and autostart (optional)
-- 3. Activate hacks (optional)

data_includes_folder = os.getenv("DATA_INCLUDES")
package.path = package.path .. ";" .. data_includes_folder .. "/?.lua;"
require "functions"
require "globals"

--register function for each frame
emu.register_frame(function()
	status, loaded = pcall(get_loaded)
		
	if loaded == nil then
		-- Update ROM on start
		emu["loaded"] = 1
		for key, value in pairs(rom_scores) do
			mem:write_direct_i8(value, data_scores[key])				
		end
	end

	if loaded == 1 then
		-- Update RAM when ready	
		if mem:read_i8(ram_players[1]) > 0 and ( emu.romname() ~= "dkongx" or mem:read_i8("0xc0000") < 0 ) then
			emu["loaded"] = 2
			for key, value in pairs(ram_high) do
				mem:write_i8(value, data_high[key])				
			end						
			for key, value in pairs(ram_high_DOUBLE) do
				mem:write_i8(value, data_high_DOUBLE[key])				
			end
			for key, value in pairs(ram_scores) do
				mem:write_i8(value, data_scores[key])
			end
			for key, value in pairs(ram_scores_DOUBLE) do
				mem:write_i8(value, data_scores_DOUBLE[key])				
			end		
			for key, value in pairs(ram_players) do
				mem:write_i8(value, data_players[key])
			end
		end
	end
	
	if loaded == 2 then
		-- Optionally set number of coins inserted into the machine
		if tonumber(data_credits) > 0 and tonumber(data_credits) < 90 then
			mem:write_i8(0x6001, data_credits)
		end
		-- Optionally start the game by simulating P1 start being pressed
		if data_autostart == "1" then
			ports[":IN2"].fields["1 Player Start"]:set_value(1)
		end
		emu["loaded"] = 3
	end
	
	if loaded == 3 then
		mode1 = mem:read_i8(0xc6005)
		mode2 = mem:read_i8(0xc600a)
		stage = mem:read_i8(0xc6227)      -- Stage (1-girders, 2-pie, 3-elevator, 4-rivets, 5-bonus)	
		score = get_score()
		
		display_awards()			
		
		-- Optional hacks
		if hack_teleport == "1" then
			dofile(data_includes_folder.."/hack_teleport.lua")
		elseif hack_nohammers == "1" then
			dofile(data_includes_folder.."/hack_nohammers.lua")
		end
		if hack_lava == "1" then
			dofile(data_includes_folder.."/hack_lava.lua")
		end
		if hack_penalty == "1" then
			dofile(data_includes_folder.."/hack_penalty.lua")
		end
	end
end)

-- Register callback function on exit
emu.register_stop(function()
	-- Export score data
	file = io.open(data_file, "w+")
	file:write(query_highscore() .. "\n")
	file:write(emu.romname() .. "\n")
	file:write("\n")
end)
