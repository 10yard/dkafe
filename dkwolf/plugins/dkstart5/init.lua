-- Simple plugin to start game from level 5 for practive purposes
-- by Jon Wilson (10yard)
--
-- Tested with latest MAME version 0.245
-- Compatible with MAME versions from 0.196
--
-- Minimum start up arguments:
--   mame dkong -plugin dkstart5
-----------------------------------------------------------------------------------------

local exports = {}
exports.name = "dkstart5"
exports.version = "0.1"
exports.description = "DK Start 5"
exports.license = "GNU GPLv3"
exports.author = { name = "Jon Wilson (10yard)" }
local dkstart5 = exports

function dkstart5.startplugin()

	function initialize()
		-- MAME LUA machine initialisation
		-- Handles historic changes back to MAME v0.196 release
		if tonumber(emu.app_version()) >= 0.196 then
			if type(manager.machine) == "userdata" then
				mac = manager.machine
			else
				mac =  manager:machine()
			end			
		else
			print("ERROR: The dkstart5 plugin requires MAME version 0.196 or greater.")
		end				
		
		if mac ~= nil then
			cpu = mac.devices[":maincpu"]
			mem = cpu.spaces["program"]
		end
	end
	
	function main()
		if mem ~= nil then
			if mem:read_u8(0x6229) == 1 then
				mem:write_u8(0x6229, 5)  -- update to level 5 
				mem:write_u16(0x622a, 0x3a73)  -- update screen sequence
			end
		end
	end
	
	emu.register_start(function()
		initialize()
	end)

	emu.register_frame_done(main, "frame")
	
end
return exports