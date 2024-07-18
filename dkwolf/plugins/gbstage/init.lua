-- gbstage
-- Loop the first 4 stages of DK.  Making use of 2 save states.
-- Skip the game intro going straight to climb scene.
-- Remove extra life collectables (using EdKit) on the target gb rom.
-- TO DO:  Keep track of score and lives when looping.  It's currently a "demo"
-- by Jon Wilson (10yard)
-----------------------------------------------------------------------------------------
local exports = {
	name = "gbstage",
	version = "0.1",
	description = "GB Stage",
	license = "GNU GPLv3",
	author = { name = "Jon Wilson (10yard)" } }

local gbstage = exports

function gbstage.startplugin()
	
	local stage
	local loaded = false
	local roms_folder

	function gbstage_initialize()
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
			print("ERROR: The gbstage plugin requires MAME version 0.196 or greater.")
		end				
		
		if mac ~= nil then
			cpu = mac.devices[":maincpu"]
			mem = cpu.spaces["program"]
			scr = mac.screens[":screen"]
		end
		roms_folder = os.getenv("DKAFE_SHELL_ROMS")		
	end
	
	function gbstage_main()
		if mem ~= nil and roms_folder ~= nil then
			stage = mem:read_u8(0xc829)
			if scr:frame_number() > 220 and not loaded then
				mac:load(roms_folder.."/gbcolor/".."gbcolor_dk_arcade_climb.sta")
				loaded = true
			end

			if stage == 3 and mem:read_u64(0xc000) == 28420588878299232 then
				-- loop back to stage 1 at end of stage 3
				mac:load(roms_folder.."/gbcolor/".."gbcolor_dk_arcade_stage1.sta")
			end
		end
	end
		
	emu.register_start(function()
		gbstage_initialize()
	end)

	emu.register_frame_done(gbstage_main, "frame")
	
end
return exports