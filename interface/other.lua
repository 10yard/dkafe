--[[
ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
 888    88o  888  o88        888       888          888
 888    888  888888         8  88      888ooo8      888ooo8
 888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
									by Jon Wilson (10yard)

DKAFE Interface routine for other arcade.
Simple interface is based on the time a game is played.
- Show targets for play time when the game starts or when game is paused.
- Show and announce prize award when targets reached for 3rd, 2nd and 1st.
---------------------------------------------------------------------------------
]]

package.path = package.path .. ";" .. os.getenv("DATA_INCLUDES") .. "/?.lua;"
require "globals"
require "functions"

-- score targets achieved
local st1, st2, st3 = false, false, false

-- Adjustments for systems
local display_time = 6
local time_played = 0
local start_time = os.time()
local msg_displayed = false


function other_main()
	if mac ~= nil then
		time_played = os.time() - start_time

		-- HUD
		if screen then
			if data_show_hud ~= 0 and data_score1 and data_score2 and data_score3 then
				-- Draw time targets at startup (or when paused)
				if time_played > -1 then
					if time_played < display_time or mac.paused then
						--Display prize target message
						mac:popmessage('Prizes: 1st at '..tostring(data_score1)..' mins, 2nd at '..tostring(data_score2)..' mins, 3rd at '..tostring(data_score3)..' mins')
						msg_displayed = true
					else
						if msg_displayed then
							-- clear the target message
							mac:popmessage()
							msg_displayed = false
						end
					end
				end

				if not mac.paused then
					-- Show prize award for 5 seconds when time target achieved
					if data_score1 > 0 and time_played > data_score1 * 60 and time_played < data_score1 * 60 + display_time then
						mac:popmessage('Won 1st Prize of '..tostring(data_score1_award)..' coins')
						if not st1 then
							if data_announce_award == "1" then play_wav("award1_short") end
							st1 = true
						end
					elseif data_score2 > 0 and time_played > data_score2 * 60 and time_played < data_score2 * 60 + display_time then
						mac:popmessage('Won 2nd Prize of '..tostring(data_score2_award)..' coins')
						if not st2 then
							if data_announce_award == "1" then play_wav("award2_short") end
							st2 = true
						end
					elseif data_score3 > 0 and time_played > data_score3 * 60 and time_played < data_score3 * 60 + display_time then
						mac:popmessage('Won 3rd Prize of '..tostring(data_score3_award)..' coins')
						if not st3 then
							if data_announce_award == "1" then play_wav("award3_short") end
							st3 = true
						end
					end
				end
			end
		end
	end
end

emu.register_frame_done(other_main, "frame")