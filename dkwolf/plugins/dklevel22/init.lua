-- Simple plugin to start game from level 22 (the Killscreen)
-- by Jon Wilson (10yard)
--
-- Tested with latest MAME version 0.245
-- Compatible with MAME versions from 0.196
--
-- A simple plugin to start the game at the level 22 killscreen.
-- On Donkey Kong you will only get a few seconds to score points.
-- On Crazy Kong you can attempt the stage skip trick to buy more time.
--
-- Example start up arguments:
--   mame dkong -plugin dklevel22
--   mame ckonpt2 -plugin dklevel22
-----------------------------------------------------------------------------------------
local exports = {
	name = "dklevel22",
	version = "0.1",
	description = "DK Level 22",
	license = "GNU GPLv3",
	author = { name = "Jon Wilson (10yard)" } }

local dklevel22 = exports

function dklevel22.startplugin()

	function dklevel22_initialize()
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
			print("ERROR: The dklevel22 plugin requires MAME version 0.196 or greater.")
		end				
		
		if mac ~= nil then
			cpu = mac.devices[":maincpu"]
			mem = cpu.spaces["program"]

			-- Set the title
			for k, i in pairs({0x1b,0x19,0x1c,0x1c,0x23,0x13,0x22,0x15, 0x15,0x1e}) do
				mem:write_direct_u8(0x36b4 + k - 1, i)
			end
		end
		
	end
	
	function dklevel22_main()
		if mem ~= nil then
			if mem:read_u8(0x6229) == 1 then
				mem:write_u8(0x6229, 22)  -- update to level 22
				mem:write_u16(0x622a, 0x3a73)  -- update screen sequence
			end
		end
	end
	
	emu.register_start(function()
		dklevel22_initialize()
	end)

	emu.register_frame_done(dklevel22_main, "frame")	
end
return exports