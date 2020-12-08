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
   
function get_env(var_name)
	content = os.getenv(var_name)
	if content ~= nil then
		content = content:split(",")
	end
	return content
end   

function get_loaded()
	return emu["loaded"]
end   


function show_info()
	scr:draw_text(10, 10, "You need to beat 10,000 to unlock the next level!");
	--scr:draw_box(20, 20, 80, 80, 0, 0xff00ffff); -- (x0, y0, x1, y1, fill-color, line-color)
	--scr:draw_line(20, 20, 80, 80, 0xff00ffff); -- (x0, y0, x1, y1, line-color)
end

--Read data from DKAFE
ram_high_addr = get_env("DK_RAM_HIGH_ADDR")
ram_high_data = get_env("DK_RAM_HIGH_DATA")
ram_scores_addr = get_env("DK_RAM_SCORES_ADDR")
ram_scores_data = get_env("DK_RAM_SCORES_DATA")
ram_players_addr = get_env("DK_RAM_PLAYERS_ADDR")
ram_players_data = get_env("DK_RAM_PLAYERS_DATA")
rom_title_addr = get_env("DK_ROM_TITLE_ADDR")
rom_title_data = get_env("DK_ROM_TITLE_DATA")

--File to export results when finishedd
data_file = "dkong_out.txt"

--Check ram is ready to be written
ram_ready = ram_players_addr[1]

cpu = manager:machine().devices[":maincpu"]
mem = cpu.spaces["program"]
scr = manager:machine().screens[":screen"]


emu.register_frame(function()
	status, loaded = pcall(get_loaded)
		
	if loaded == nil then
		emu.register_frame_done(show_info, "frame")
		-- Update ROM
		emu["loaded"] = 1
		if rom_title_addr ~= nil and rom_title_data ~= nil then
			for key, value in pairs(rom_title_addr) do
				mem:write_direct_i8(value, rom_title_data[key])
			end
		end
	end

	if loaded == 1 then
		-- Update RAM
		if mem:read_i8(ram_ready) > 0 then
			emu["loaded"] = 2
			if ram_high_addr ~= nil and ram_high_data ~= nil then
				for key, value in pairs(ram_high_addr) do
					mem:write_i8(value, ram_high_data[key])				
				end						
			end
			if ram_scores_addr ~= nil and ram_scores_data ~= nil then
				for key, value in pairs(ram_scores_addr) do
					mem:write_i8(value, ram_scores_data[key])				
				end
			end
			if ram_players_addr ~= nil and ram_players_data ~= nil then
				for key, value in pairs(ram_players_addr) do
					mem:write_i8(value, ram_players_data[key])				
				end
			end
		end
	end
end)

emu.register_stop(function()
	-- Export data file
	if ram_high_addr ~= nil and ram_high_data ~= nil then
		file = io.open(data_file, "w+")
		for key, value in pairs(ram_high_addr) do
			file:write(mem:read_i8(value))
		end
		file:write("\n")
		file:close()
	end
end)
