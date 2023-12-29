-- Simple plugin to end your game at a specific level
-- by Jon Wilson (10yard)
--
-- Tested with latest MAME version 0.256
-- Compatible with MAME versions from 0.212
--
--By default this plugin will end your game after level 3 rivets.
--You can provide a specific level by setting a parameter before launching MAME
--e.g.
--SET DKEND_PARAMETER=1 
--
-- Minimum start up arguments:
--   mame dkong -plugin dkend
-----------------------------------------------------------------------------------------
local exports = {
	name = "dkend",
	version = "0.1",
	description = "DK End",
	license = "GNU GPLv3",
	author = { name = "Jon Wilson (10yard)" } }

local dkend = exports

function dkend.startplugin()
	local end_level
	
	local fires_table = {0x6400, 0x6420, 0x6440, 0x6460, 0x6480} 
	
	function dkend_initialize()
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
			print("ERROR: The dkend plugin requires MAME version 0.196 or greater.")
		end				
		
		if mac ~= nil then
			cpu = mac.devices[":maincpu"]
			mem = cpu.spaces["program"]
		end
		
		_param = os.getenv("DKEND_PARAMETER")
		if _param and _param >= "1" and _param <= "21" then
			end_level = tonumber(_param)
		else
			end_level = 3
		end	
		dkend_title()
	end
	
	function dkend_main()
		if mem ~= nil then
			level = mem:read_u8(0x6229)
			stage = mem:read_u8(0x6227)
			mode1 = mem:read_u8(0x6005)
			mode2 = mem:read_u8(0x600a)
			if mode1 == 3 and stage == 1 and level > end_level then
				if mode2 == 0xa then
					--jump forward to get to game over
					mem:write_u8(0x600a, 0xc)
					mem:write_u8(0x6203, 208)  -- adjust jumpman x pos on how high screen
					mem:write_u8(0x6205, 240)  -- and his y pos

					-- Clear fireballs from memory so they don't appear on final how high screen
					for _, address in pairs(fires_table) do
						mem:write_u8(address, 0)
						mem:write_u8(address+0x3, 0)
						mem:write_u8(address+0x5, 0)
						mem:write_u8(address+0x7, 0x1c) -- blank graphic
						mem:write_u8(address+0xe, 0)
						mem:write_u8(address+0xf, 0)
					end
				elseif mode2 == 0xc then				
					mem:write_u8(0x6228, 1)  --adjust remaining lives
					mem:write_u8(0x6200, 0)  --set jumpman status to dead					
				end
			end	
		end
	end
	
	function dkend_title()
		-- Change high score text in rom to ENDS L=03 
		if end_level >= 20 then
			end_tens = 2
			end_units = end_level - 20
		elseif end_level >= 10 then
			end_tens = 1
			end_units = end_level - 10
		else
			end_tens = 0
			end_units = end_level
		end	
		for k, i in pairs({0x15,0x1e,0x14,0x23,0x10,0x1c,0x34,end_tens,end_units,0x10}) do
			mem:write_direct_u8(0x36b4 + k - 1, i)
		end
		-- Change "HOW HIGH CAN YOU GET" text in rom to "Help! LAVA IS RISING UP!!"
		for k, i in pairs({0xdd,0xde,0xdf,0x10,0x1c,0x11,0x26,0x11,0x10,0x19,0x23,0x10,0x22,0x19,0x23,0x19,0x1e,0x17,0x10,0x25,0x20,0x36,0x10}) do
			mem:write_direct_u8(0x36ce + k - 1, i)
		end
	end

		
	emu.register_start(function()
		dkend_initialize()
	end)

	emu.register_frame_done(dkend_main, "frame")
	
end
return exports