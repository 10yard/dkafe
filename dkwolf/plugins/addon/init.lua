-- Simple plugin to display time targets for the console Add-On pack games.
-- Targets appear for ~4 seconds when game is launched.
-- by Jon Wilson (10yard)
--
-----------------------------------------------------------------------------------------
local exports = {
	name = "addon",
	version = "0.1",
	description = "Add On Targets",
	license = "GNU GPLv3",
	author = { name = "Jon Wilson (10yard)" } }

local addon = exports

function addon.startplugin()
	local score1, score2, score3
	local col0 = 0xffffffff
	local col1 = 0xff000060
	local col2 = 0xff0000a0

	function addon_initialize()
		if tonumber(emu.app_version()) >= 0.196 then
			if type(manager.machine) == "userdata" then
				mac = manager.machine
			else
				mac =  manager:machine()
			end			
			scr = mac.screens[':screen']
			
			show_hud = os.getenv("DKAFE_SHELL_HUD")
			score1 = os.getenv("DKAFE_SHELL_SCORE1")
			score2 = os.getenv("DKAFE_SHELL_SCORE2")
			score3 = os.getenv("DKAFE_SHELL_SCORE3")
		else
			print("ERROR: The addon plugin requires MAME version 0.196 or greater.")
		end						
	end
	
	function addon_main()
		if mac ~= nil then
						
			if (show_hud ~= "0" and score1 and score2 and score3 and scr:frame_number() < 300) or mac.paused then
				_len = string.len(score1)
				_spaces = string.sub("          ", 1, _len)
				_x = scr.width - ((14 + _len) * 5) - 5
				
				scr:draw_text(_x, 0,  "              ".._spaces, col0, col2)
				scr:draw_text(_x, 7,  "              ".._spaces, col0, col2)
				scr:draw_text(_x, 14, "              ".._spaces, col0, col2)
				scr:draw_text(_x, 21, "              ".._spaces, col0, col2)
				scr:draw_text(_x, 28, "              ".._spaces, col0, col2)

				scr:draw_text(_x + 5, 12, '       '.._spaces..'     ', col0, col1)
				scr:draw_text(_x + 5, 19, '       '.._spaces..'     ', col0, col1)
				scr:draw_text(_x + 5, 26, '       '.._spaces..'     ', col0, col1)

				scr:draw_text(_x + 5, 12, '1ST AT '..score1..' MINS', col0, col1)
				scr:draw_text(_x + 5, 19, '2ND AT '..score2..' MINS', col0, col1)
				scr:draw_text(_x + 5, 26, '3RD AT '..score3..' MINS', col0, col1)

				scr:draw_text(_x, 2,  " DKAFE PRIZES:".._spaces, col0, col2)
				scr:draw_text(_x, 32, "              ".._spaces, col0, col2)
			end
		end
	end
		
	emu.register_start(function()
		addon_initialize()
	end)

	emu.register_frame_done(addon_main, "frame")
	
end
return exports