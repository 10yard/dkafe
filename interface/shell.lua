--[[
ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
888    88o  888  o88        888       888          888
888    888  888888         8  88      888ooo8      888ooo8
888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
									by Jon Wilson (10yard)

DKAFE Interface routine for shell scripts.
Simple interface is based on the time a game is played.
1) Show targets for time when the game starts up.
2) Show prize award when targets reached for 3rd, 2nd and 1st
--------------------------------------------------------------
]]

package.path = package.path .. ";" .. os.getenv("DATA_INCLUDES") .. "/?.lua;"
require "functions"
require "graphics"
require "globals"

local start_time = os.time()
local time_played
local col0 = 0xffffffff
local col1 = 0xff0000ff
local col2 = 0xff0000a0
local bronze = 0xffcd7f32
local silver = 0xffc0c0c0
local gold = 0xffd4af37

function shell_main()
	if mac ~= nil then
		time_played = os.time() - start_time
					
		if data_show_hud ~= 0 then
			-- Show prize award top-right when time target achieved
			if data_score1 > 0 and time_played > (data_score1 * 60) then
				screen:draw_text(_x, 0,  " 1ST WON "..tostring(data_scpre1_award.." "), gold, col2)
			elseif data_score2 > 0 and time_played > (data_score2) * 60 then
				screen:draw_text(_x, 0,  " 2ND WON "..tostring(data_score2_award.." "), silver, col2)
			elseif data_score3 > 0 and time_played > (data_score3) * 60 then
				screen:draw_text(_x, 0,  " 3RD WON "..tostring(data_score3_award.." "), bronze, col2)
			end
			
			-- Draw time targets at startup
			if (data_score1 and data_score2 and data_score3 and time_played <= 6) or mac.paused then
				_len = string.len(tostring(data_score1))
				_wid = (14 + _len) * 5
				_x = screen.width - _wid
				
				-- Draw surrounding box
				screen:draw_box(_x, 0, _x + _wid, 39, col1, col2)

				-- Draw score targets
				screen:draw_text(_x + 5, 6,  "DKAFE PRIZES:", col0)
				screen:draw_text(_x + 5, 13, '1ST AT '..tostring(data_score1)..' MINS', gold)
				screen:draw_text(_x + 5, 20, '2ND AT '..tostring(data_score2)..' MINS', silver)
				screen:draw_text(_x + 5, 27, '3RD AT '..tostring(data_score3)..' MINS', bronze)
			end
		end
	end
end
	
emu.register_frame_done(shell_main, "frame")
