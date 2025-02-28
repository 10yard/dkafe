-- Simple plugin to practice a particular Donkey Kong 3 Stage (1=Blue, 2=Gray, 3=Yellow)
-- by Jon Wilson (10yard)
--
-- Tested with MAME version 0.241
-- Compatible with MAME versions from 0.196
--
--e.g.
--  SET DK3STAGE_PARAMETER=1
--
-- Minimum start up arguments:
--   mame dkong -plugin dk3stage
-----------------------------------------------------------------------------------------
local exports = {
	name = "dk3stage",
	version = "0.1",
	description = "DK3 Stage",
	license = "GNU GPLv3",
	author = { name = "Jon Wilson (10yard)" } }

local dk3stage = exports

function dk3stage.startplugin()
	local stage

	function dk3stage_initialize()
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
			print("ERROR: The dk3stage plugin requires MAME version 0.196 or greater.")
		end				
		
		if mac ~= nil then
			cpu = mac.devices[":maincpu"]
			mem = cpu.spaces["program"]
		end
		
		_param = os.getenv("DK3STAGE_PARAMETER")
		if _param and _param >= "0" and _param <= "2" then
			stage = tonumber(_param)
		else
			stage = 0
		end
	end
	
	function dk3stage_main()
		if mem ~= nil then
			mem:write_u8(0x601b, stage)
		end
	end
	
	emu.register_start(function()
		dk3stage_initialize()
	end)

	emu.register_frame_done(dk3stage_main, "frame")
	
end
return exports