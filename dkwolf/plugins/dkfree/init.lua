-- DK Free - Removes enemies from dkong, dkongjr and dkong3
-- by Jon Wilson (10yard)
--
-- Fully compatible with all MAME versions from 0.227
--
-- Minimum start up arguments:
--   mame dkong -plugin dkfree
-----------------------------------------------------------------------------------------
local exports = {
	name = "dkfree",
	version = "0.1",
	description = "DK Free",
	license = "GNU GPLv3",
	author = { name = "Jon Wilson (10yard)" } }

local dkfree = exports

function dkfree.startplugin()
	
	local enemy_table
	local title = {0x10,0x16,0x22,0x15,0x15,0x10,0x22,0x25,0x1e,0x10}

	function dkfree_initialize()
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
			print("ERROR: The dkfree plugin requires MAME version 0.196 or greater.")
		end				
		
		if mac ~= nil then
			cpu = mac.devices[":maincpu"]
			mem = cpu.spaces["program"]

			-- Set the title
			if emu.romname() ~= "dkong3" then
				for k, i in pairs(title) do mem:write_direct_u8(0x36b4 + k - 1, i) end
			end

			-- Donkey Kong Junior specific initialisation
			if emu.romname() == "dkongjr" then
				enemy_table =
					{0x6700, 0x6720, 0x6740, 0x6760, 0x6780, 0x67a0, 0x67c0, 0x67e0, 
					0x6800, 0x6810, 0x6820, 0x6830, 0x6840,
					0x6400, 0x6420, 0x6440, 0x6460, 0x6480,
					0x6500, 0x6510, 0x6520, 0x6530, 0x6540, 0x6550, 0x6560, 0x6570, 0x6580, 0x6590}
			else
				enemy_table =
					{0x6700, 0x6720, 0x6740, 0x6760, 0x6780, 0x67a0, 0x67c0, 0x67e0, 
					 0x6400, 0x6420, 0x6440, 0x6460, 0x6480, 
					 0x6500, 0x6510, 0x6520, 0x6530, 0x6540, 0x6550, 0x6550,
					 0x65a0, 0x65b0, 0x65c0, 0x65d0, 0x65e0, 0x65f0}			
			end
		end
	end
	
	function dkfree_main()
		if mem ~= nil then
			local address
			if emu.romname() == "dkong3" then
				for k, i in pairs(title) do mem:write_u8(0x7560 - (k  * 32), i) end
				for address=0x6400, 0x661f do mem:write_u8(address, 0) end
				for address=0x6900, 0x6917 do mem:write_u8(address, 0) end
			else
				for _, address in pairs(enemy_table) do
					mem:write_u8(address+3, 250)
					mem:write_u8(address+5, 8)
					if (address >= 0x6400 and address < 0x6500) or (address >= 0x65a0 and address < 0x6600) then
						mem:write_u8(address+0x0e, 250)
						mem:write_u8(address+0x0f, 8)
					end
				end
			end
		end
	end

	emu.register_start(function()
		dkfree_initialize()
	end)

	emu.register_frame_done(dkfree_main, "frame")	
end
return exports