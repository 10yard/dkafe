-- Set highscore, player scores, player names and dump highscore to file when finished.
-- 0. Update ROM on start
-- 1. Update RAM
-- 2. Update coins (optional)
-- 3. Activate hacks (optional)

-- Get data from DKAFE
data_includes = os.getenv("DATA_INCLUDES")
dofile(data_includes.."/functions.lua")
dofile(data_includes.."/globals.lua")


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
		-- Automatically set number of coins inserted into the machine
		if tonumber(data_credits) > 0 and tonumber(data_credits) < 90 then
			mem:write_i8(0x6001, data_credits)
		end
		emu["loaded"] = 3
	end
	
	if loaded == 3 then
		-- Include optional Hacks
		if hack_teleport == "1" then
			dofile(data_includes.."/hack_teleport.lua")
		elseif hack_nohammers == "1" then
			dofile(data_includes.."/hack_nohammers.lua")
		end
		if hack_lava == "1" then
			dofile(data_includes.."/hack_lava.lua")
		end
		if hack_penaltypoints ~= nil and tonumber(hack_penaltypoints) >= 1 and tonumber(hack_penaltypoints) <= 9 then
			dofile(data_includes.."/hack_penaltypoints.lua")
		end
	end
end)


emu.register_stop(function()
	-- Export data with high score on first line
	file = io.open(data_file, "w+")
	file:write(query_highscore() .. "\n")
	file:write(emu.romname() .. "\n")
	file:write("\n")
end)
