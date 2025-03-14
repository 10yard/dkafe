-- Simple plugin to practice a particular Logger 3 Stage
-- by Jon Wilson (10yard)
--
-- Tested with MAME version 0.241
-- Compatible with MAME versions from 0.196
--
--e.g.
--  SET LOGGERSTAGE_PARAMETER=1
--
-- Minimum start up arguments:
--   mame dkong -plugin loggerstage
-----------------------------------------------------------------------------------------
local exports = {
	name = "loggerstage",
	version = "0.1",
	description = "Logger Stage",
	license = "GNU GPLv3",
	author = { name = "Jon Wilson (10yard)" } }

local loggerstage = exports

function loggerstage.startplugin()
	local stage

	function loggerstage_initialize()
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
			print("ERROR: The loggerstage plugin requires MAME version 0.196 or greater.")
		end				
		
		if mac ~= nil then
			cpu = mac.devices[":maincpu"]
			mem = cpu.spaces["program"]
		end
		
		_param = os.getenv("LOGGERSTAGE_PARAMETER")
		if _param and _param >= "0" and _param <= "3" then
			stage = tonumber(_param)
		else
			stage = 0
		end
	end
	
	function loggerstage_main()
		if mem ~= nil then
			mem:write_u8(0x1d8b, stage)
		end
	end
	
	emu.register_start(function()
		loggerstage_initialize()
	end)

	emu.register_frame_done(loggerstage_main, "frame")
	
end
return exports