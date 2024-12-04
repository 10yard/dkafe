-- Cranky Kong
-- by Jon Wilson (10yard)
--
-- Minimum start up arguments:
--   mame dkong -plugin dksavage
-----------------------------------------------------------------------------------------
local exports = {
	name = "dksavage",
	version = "0.1",
	description = "DK Savage",
	license = "GNU GPLv3",
	author = { name = "Jon Wilson (10yard)" } }

local dksavage = exports

function dksavage.startplugin()
	local characters = "0123456789       ABCDEFGHIJKLMNOPQRSTUVWXYZ@-"

	function dksavage_initialize()
		local _param
		
		-- MAME LUA machine initialisation
		-- Handles historic changes back to MAME v0.196 release
		if tonumber(emu.app_version()) >= 0.196 then
			if type(manager.machine) == "userdata" then
				mac = manager.machine
			else
				mac =  manager:machine()
			end			
		else
			print("ERROR: The dksavage plugin requires MAME version 0.196 or greater.")
		end				
		
		if mac ~= nil then
			cpu = mac.devices[":maincpu"]
			mem = cpu.spaces["program"]
			scr = mac.screens[":screen"]
			write_rom_message(0x36b4, "DK SAVAGE ")
		end
	end
	
	function dksavage_main()
		if mem ~= nil then
			--mem:write_u8(0x6227, 3) -- stage
			mem:write_u8(0x6380, 5) -- difficulty			
		
			mem:write_u8(0x639b, 0) -- release pie
			mem:write_u8(0x639a, 1) -- fires counter
			
			mem:write_u8(0x62b9, 3) -- release fires
			mem:write_u8(0x6396, 3) -- release springs			
			mem:write_u8(0x62af, scr:frame_number() % 8)  -- release barrels and speed up timer
		end
	end
	
	function write_rom_message(start_addr, text)
		-- write characters of message to ROM
		for key=1, string.len(text) do
			mem:write_direct_u8(start_addr + (key - 1), string.find(characters, string.sub(text, key, key)) - 1)
		end
	end	
	
	emu.register_start(function()
		dksavage_initialize()
	end)

	emu.register_frame_done(dksavage_main, "frame")
	
end
return exports