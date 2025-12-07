-- Minor tweak to remove the small delay between restarts
-- by Jon Wilson (10yard)
--
-- Compatible with MAME versions from 0.227
-----------------------------------------------------------------------------------------
local exports = {
	name = "dk2nutplus",
	version = "0.1",
	description = "Better speeds up that delay between restarts",
	license = "GNU GPLv3",
	author = { name = "Jon Wilson (10yard)" } }

local dk2nutplus = exports

function dk2nutplus.startplugin()
	
	local i_mode1, i_mode2, i_attenuation
	
	function dk2nutplus_initialize()
		
		-- MAME LUA machine initialisation
		-- Handles historic changes back to MAME v0.196 release
		if tonumber(emu.app_version()) >= 0.227 then
			mac = manager.machine
		else
			print("ERROR: The dk2nutplus plugin requires MAME version 0.227 or greater.")
		end				
		
		if mac ~= nil then
			cpu = mac.devices[":maincpu"]
			video = mac.video
			sound = mac.sound
			mem = cpu.spaces["program"]
			
			i_attenuation = sound.attenuation  -- store default sound level
		end
		
	end
	
	function dk2nutplus_main()
		if mem ~= nil then
			i_mode1, i_mode2 = mem:read_u8(0x6005), mem:read_u8(0x600a)
			if i_mode1 == 3 and i_mode2 == 11 then					
				video.throttled = false
				video.throttle_rate = 1000
				video.frameskip = 11
				sound.attenuation = -32  -- mute sound
			else
				video.throttled = true
				video.throttle_rate = 1
				video.frameskip = 0
				sound.attenuation = i_attenuation  -- restore sound level
			end
		end
	end
	
	emu.register_start(function()
		dk2nutplus_initialize()
	end)

	emu.register_frame_done(dk2nutplus_main, "frame")
end
return exports