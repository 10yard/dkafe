--Retrieve player name and highscore via mame script engine
--reference to memory locations at:
--  https://github.com/furrykef/dkdasm/blob/master/dkong.asm

--Input and output with respect to DKAFE
input = os.getenv("DKAFE_LUA_INTERFACE_OUT")
output = os.getenv("DKAFE_LUA_INTERFACE_IN")
--emu.print_info(output)

score_mem = {0xc7641,0xc7621,0xc7601,0xc75e1,0xc75c1,0xc75a1}
player_mem = {0xc610f, 0xc6110, 0xc6111}
cpu = manager:machine().devices[":maincpu"]
mem = cpu.spaces["program"]

function get_loaded()
	return emu["loaded"]
end

emu.register_frame(function()
	status, loaded = pcall(get_loaded)
	if loaded == nil and emu.time() > 0 then
		if mem:read_i8(0xc610f) > 0 then		
			emu["loaded"] = 1
			file = io.open(input, "r")
			for key,value in pairs(score_mem) do
				data = file:read()
				mem:write_i8(value, data)
			end
			for key,value in pairs(player_mem) do
				data = file:read()
				mem:write_i8(value, data)
			end
			file:close()
		end
	end
end)

emu.register_stop(function()
    file = io.open(output, "w+")
    for key,value in pairs(score_mem) do
        file:write(mem:read_i8(value))
		file:write("\n")
    end
    for key,value in pairs(player_mem) do
		file:write(mem:read_i8(value))
		file:write("\n")
    end
	file:close()
end)
