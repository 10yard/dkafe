--[[
ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
888    88o  888  o88        888       888          888
888    888  888888         8  88      888ooo8      888ooo8
888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
									by Jon Wilson (10yard)

DKAFE Interface routine for shell scripts
--------------------------------------------------------------
]]

package.path = package.path .. ";" .. os.getenv("DATA_INCLUDES") .. "/?.lua;"
require "functions"
require "graphics"
require "globals"

local start_time = os.time()
local time_played
local col0 = 0xffffffff
local col1 = 0xff000060
local col2 = 0xff0000a0
local bronze = 0xffcd7f32
local silver = 0xffc0c0c0
local gold = 0xffd4af37

function shell_main()
	if mac ~= nil then
		time_played = os.time() - start_time
					
		if data_show_hud ~= 0 then
			if data_score1 > 0 and time_played > (data_score1 * 60) then
				screen:draw_text(_x, 0,  " WON 1ST "..tostring(data_scpre1_award.." "), gold, col2)
			elseif data_score2 > 0 and time_played > (data_score2) * 60 then
				screen:draw_text(_x, 0,  " WON 2ND "..tostring(data_score2_award.." "), silver, col2)
			elseif data_score3 > 0 and time_played > (data_score3) * 60 then
				screen:draw_text(_x, 0,  " WON 3RD "..tostring(data_score3_award.." "), bronze, col2)
			end
			if (data_score1 and data_score2 and data_score3 and time_played <= 6) or mac.paused then
				_len = string.len(tostring(data_score1))
				_spaces = string.sub("          ", 1, _len)
				_x = screen.width - ((14 + _len) * 5) - 5
				
				screen:draw_text(_x, 0,  "              ".._spaces, col0, col2)
				screen:draw_text(_x, 7,  "              ".._spaces, col0, col2)
				screen:draw_text(_x, 14, "              ".._spaces, col0, col2)
				screen:draw_text(_x, 21, "              ".._spaces, col0, col2)
				screen:draw_text(_x, 28, "              ".._spaces, col0, col2)

				screen:draw_text(_x + 5, 12, '       '.._spaces..'     ', col0, col1)
				screen:draw_text(_x + 5, 19, '       '.._spaces..'     ', col0, col1)
				screen:draw_text(_x + 5, 26, '       '.._spaces..'     ', col0, col1)

				screen:draw_text(_x + 5, 12, '1ST AT '..tostring(data_score1)..' MINS', gold, col1)
				screen:draw_text(_x + 5, 19, '2ND AT '..tostring(data_score2)..' MINS', silver, col1)
				screen:draw_text(_x + 5, 26, '3RD AT '..tostring(data_score3)..' MINS', bronze, col1)

				screen:draw_text(_x, 2,  " DKAFE PRIZES:".._spaces, col0, col2)
				screen:draw_text(_x, 32, "              ".._spaces, col0, col2)
			end
		end
	end
	
end
	
emu.register_frame_done(shell_main, "frame")
