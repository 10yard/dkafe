-- Simple plugin to start game from level 0
-- Inspired by Kosmic's Video - https://youtu.be/kMiKd9Dzvow?si=S2fO5KCIXEHWiuu_
-- by Jon Wilson (10yard)
--
-- Compatible with MAME versions from 0.196
--
-- A simple plugin to start the game at the level 0 which would not normally be possible.
-- Level 0 behaves oddly and presents some bugs.
--
-- Example start up arguments:
--   mame dkong -plugin dklevel0
--   mame ckonpt2 -plugin dklevel0
-----------------------------------------------------------------------------------------
local exports = {
	name = "dklevel0",
	version = "0.1",
	description = "DK Level 0",
	license = "GNU GPLv3",
	author = { name = "Jon Wilson (10yard)" } }

local dklevel0 = exports

function dklevel0.startplugin()

	function dklevel0_initialize()
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
			print("ERROR: The dklevel0 plugin requires MAME version 0.196 or greater.")
		end				
		
		if mac ~= nil then
			cpu = mac.devices[":maincpu"]
			mem = cpu.spaces["program"]

			-- Set the title
			for k, i in pairs({0x2a,0x15,0x22,0x1f,0x10,0x23,0x15,0x1e,0x23,0x15}) do
				mem:write_direct_u8(0x36b4 + k - 1, i)
			end
		end
		
	end
	
	function dklevel0_main()
		if mem ~= nil then
			if mem:read_u8(0x6229) == 1 or mem:read_u8(0x6229) == 11 then
				mem:write_u8(0x6229, 0)  -- update to level 0
			end
		end
	end
	
	emu.register_start(function()
		dklevel0_initialize()
	end)

	emu.register_frame_done(dklevel0_main, "frame")
end
return exports