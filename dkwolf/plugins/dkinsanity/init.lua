-- DK Insanity
-- by Jon Wilson (10yard)
--
-- Minimum start up arguments:
--   mame dkong -plugin dkinsanity
-----------------------------------------------------------------------------------------
local exports = {
	name = "dkinsanity",
	version = "0.1",
	description = "DK Insanity",
	license = "GNU GPLv3",
	author = { name = "Jon Wilson (10yard)" } }

local dkinsanity = exports

function dkinsanity.startplugin()
	local characters = "0123456789       ABCDEFGHIJKLMNOPQRSTUVWXYZ@-"

	function dkinsanity_initialize()
		-- MAME LUA machine initialisation
		-- Handles historic changes back to MAME v0.196 release
		if tonumber(emu.app_version()) >= 0.196 then
			if type(manager.machine) == "userdata" then
				mac = manager.machine
			else
				mac =  manager:machine()
			end			
		else
			print("ERROR: The dkinsanity plugin requires MAME version 0.196 or greater.")
		end				
		
		if mac ~= nil then
			cpu = mac.devices[":maincpu"]
			mem = cpu.spaces["program"]
			scr = mac.screens[":screen"]

			-- ROM modifications
			write_rom_message(0x36b4, " INSANITY ")			
		end
	end
	
	function dkinsanity_main()
		if mem ~= nil then
			--mem:write_u8(0x6227, 4) -- stage
			--mem:write_u8(0x6229, 2) -- level
			mem:write_u8(0x6380, 5) -- difficulty
		
			mem:write_u8(0x639a, 1) -- fires counter
			mem:write_u8(0x639b, 0) -- release pies
			mem:write_u8(0x62b9, 3) -- release fires
			mem:write_u8(0x6396, 3) -- release springs			

			if mem:read_u8(0x6229) == 1 then
				mem:write_u8(0x62af, (scr:frame_number() % 7) + 1)  -- release barrels quick and speed up timer
			else
				mem:write_u8(0x62af, ((scr:frame_number() % 4) * 2) + 1)  -- release even quicker!
			end
			-- add 3 more fires on springs stage
			if mem:read_u8(0x6227) == 3 and mem:read_u8(0x6400) == 1 and mem:read_u8(0x6440) ~= 1 then
				-- 3rd at top
				mem:write_u8(0x6440, 1)
				mem:write_u8(0x6443, 0x58)
				mem:write_u8(0x644e, 0x58)
				mem:write_u8(0x6445, 0x50)
				mem:write_u8(0x644f, 0x50)

				-- 4th is an extra one on the double ladders
				mem:write_u8(0x6460, 1)
				mem:write_u8(0x6463, 0x59)
				mem:write_u8(0x646e, 0x59)
				mem:write_u8(0x6465, 0x80)
				mem:write_u8(0x646f, 0x80)

				-- 5th is an extra one near the prize on right
				mem:write_u8(0x6480, 1)
				mem:write_u8(0x6483, 0xeb)
				mem:write_u8(0x648e, 0xeb)
				mem:write_u8(0x6485, 0x61)
				mem:write_u8(0x648f, 0x61)

			end
		end
	end
	
	function write_rom_message(start_addr, text)
		-- write characters of message to ROM
		for key=1, string.len(text) do
			mem:write_direct_u8(start_addr + (key - 1), string.find(characters, string.sub(text, key, key)) - 1)
		end
	end	
	
	emu.register_start(function()
		dkinsanity_initialize()
	end)

	emu.register_frame_done(dkinsanity_main, "frame")
	
end
return exports