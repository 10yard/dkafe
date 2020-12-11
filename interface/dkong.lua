--Set highscore, player scores, player names.  Dump highscore to file when finished.
--Reference to memory locations at:
--  https://github.com/furrykef/dkdasm/blob/master/dkong.asm
--Useful function reference at:
--  https://code.google.com/archive/p/mame-rr/wikis/LuaScriptingFunctions.wiki

function string:split(sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end
   
function get_formatted_data(var_name)
	content = os.getenv(var_name)
	if content ~= nil then
		content = content:split(",")
	else content = {}
	end
	return content
end   

function get_loaded()
	return emu["loaded"]
end   

function query_highscore()
	highscore = ""
	for key, value in pairs(ram_high) do
		highscore = highscore .. mem:read_i8(value)
	end	
	if highscore == "161616161616" then 
		highscore = "000000" 
	end
	return highscore
end

-- Get data from DKAFE
data_file = os.getenv("DATA_FILE")
data_scores = get_formatted_data("DATA_SCORES")
data_high = get_formatted_data("DATA_HIGH")
data_high_dbl = get_formatted_data("DATA_HIGH_DBL")
data_scores = get_formatted_data("DATA_SCORES")
data_players = get_formatted_data("DATA_PLAYERS")

-- Get ROM addresses
rom_scores = get_formatted_data("ROM_SCORES")

-- Get RAM addresses
ram_high = get_formatted_data("RAM_HIGH")
ram_high_dbl = get_formatted_data("RAM_HIGH_DBL")
ram_scores = get_formatted_data("RAM_SCORES")
ram_players = get_formatted_data("RAM_PLAYERS")

-- Memory state
cpu = manager:machine().devices[":maincpu"]
mem = cpu.spaces["program"]

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
		if mem:read_i8(ram_players[1]) > 0 then
			emu["loaded"] = 2
			for key, value in pairs(ram_high) do
				mem:write_i8(value, data_high[key])				
			end						
			for key, value in pairs(ram_high_dbl) do
				mem:write_i8(value, data_high_dbl[key])				
			end						
			for key, value in pairs(ram_scores) do
				mem:write_i8(value, data_scores[key])				
			end
			for key, value in pairs(ram_players) do
				mem:write_i8(value, data_players[key])				
			end
		end
		emu["target"] = tonumber(query_highscore())
	end
	
	--if loaded == 2 then
	--	if tonumber(query_highscore()) > emu.target then
	--		emu.print_info("Reached Target")
	--	end
	--end
end)

emu.register_stop(function()
	-- Export data file
	file = io.open(data_file, "w+")
	file:write(query_highscore())
	file:write("\n")
	file:write(emu.romname())
	file:write("\n")
	file:write(emu.gamename())
	file:close()
end)
