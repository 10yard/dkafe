--[[
ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
888    88o  888  o88        888       888          888
888    888  888888         8  88      888ooo8      888ooo8
888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
									by Jon Wilson (10yard)

DKAFE Interface routine for shell scripts.
Simple interface is based on the time a game is played.
- Speed up the loading time of some disk based games
- Show targets for time when the game starts up.
- Show prize award when targets reached for 3rd, 2nd and 1st
--------------------------------------------------------------
]]

package.path = package.path .. ";" .. os.getenv("DATA_INCLUDES") .. "/?.lua;"
require "functions"
require "graphics"
require "globals"

shell_name = os.getenv("DKAFE_SHELL_NAME")
mame_version = tonumber(emu.app_version())
if mame_version >= 0.241 then
	keyb = mac.natkeyboard
end

local col0, col1, col2 = 0xffffffff, 0xffa0a0ff, 0xff0000a0
local bronze, silver, gold = 0xffcd7f32, 0xffc0c0c0, 0xffd4af37
local time_played

-- Adjustments for systems
local target_time = 5
local input_frame = 60
local scale, quick_start, hide_targets, y_offset, x_offset, y_padding = 0, 0, 0, 0, 0, 0

if emu.romname() == "a800xl" then
	quick_start = 90
elseif emu.romname() == "apple2e" then
	quick_start = 600
	scale = 3
	y_padding = 1
	input_frame = 500
	x_offset = -110
elseif emu.romname() == "bbcb" then
	quick_start = 300
	y_padding = 15
	scale = 6
elseif emu.romname() == "c64" then
	input_frame = 150
	scale = 1.33
	y_padding = 2
	quick_start = 550
elseif emu.romname() == "coco3" then
	if shell_name == "coco3_dk_emu" then
		quick_start = 6500
	else
		quick_start = 5200
	end	
	scale = 4.25
	y_padding = 4
elseif emu.romname() == "coleco" then
	quick_start = 720
elseif emu.romname() == "cpc6128" then
	quick_start = 1550
	scale = 6
	y_padding = 4
elseif emu.romname() == "fds" then
	quick_start = 600
elseif emu.romname() == "gameboy" then
	scale = -1.5
	quick_start = 300
	y_offset = 10
elseif emu.romname() == "gbcolor" then
	scale = -1.5
	quick_start = 180
	y_offset = 10
elseif emu.romname() == "hbf900a" then
	scale = 5
	quick_start = 2300
	y_padding = 12
elseif emu.romname() == "intv" then
	quick_start = 540
elseif emu.romname() == "nes" then
	scale = 0.5
elseif emu.romname() == "pet4032" then
	quick_start = 240
	input_frame = 180
elseif emu.romname() == "spectrum" then
	scale = 2
	y_padding = 4
	input_frame = 15
end
local start_time = os.time()

function shell_main()
	if mac ~= nil then
		if screen:frame_number() < quick_start then
			time_played = 0
		else
			time_played = os.time() - start_time
		end
			
		-- Speed up the inital loading screens
		if quick_start > 0 then
			screen:draw_box(0, 0 , screen.width, screen.height, 0xff000000, 0xff000000)
			
			if screen:frame_number() < quick_start then
				max_frameskip(true)
				if quick_start > 500 then
					local _remain = tostring(math.floor((quick_start - screen:frame_number()) / 60))
					screen:draw_text(0, 6 + scale,  "FAST LOADING...".._remain, col0, 0xff000000)
				else	
					screen:draw_text(0, 6 + scale,  "PLEASE WAIT...", col0, 0xff000000)
				end
			else	
				max_frameskip(false)
				quick_start = 0
			end
		end	
						
		-- specific keys to press on boot
		if keyb then
			if screen:frame_number() == input_frame then
				if emu.romname() == "apple2e" then
					keyb:post_coded("{SPACE}")
				elseif emu.romname() == "bbcb" then
					keyb:post("*EXEC !BOOT\n")
				elseif emu.romname() == "c64" then
					keyb:post('RUN\n')
				elseif emu.romname() == "ti99_4a" then
					keyb:post_coded("{SPACE}")
					keyb:post("2")
				elseif emu.romname() == "cpc6128" then
					keyb:post('RUN"DONKEY\n')
				elseif emu.romname() == "coco3" then
					if shell_name == "coco3_dk_emu" then
						keyb:post('LOADM"EMULATOR":EXEC\n')
					elseif shell_name == "coco3_dk_remixed" then
						keyb:post('LOADM"DKREMIX":EXEC\n')
					end
				elseif emu.romname() == "pet4032" then
					keyb:post('RUN\n')
				elseif emu.romname() == "spectrum" then
					if shell_name == "spectrum_krazykong" then
						keyb:post('y')
					end
				end
			end
		end


		if data_show_hud ~= 0 and data_score1 and data_score2 and data_score3 then			
			-- Draw time targets at startup
			if time_played <= target_time or mac.paused then
				_len = string.len(tostring(data_score1))
				_wid = (14 + _len) * (5 + scale)
				_x = screen.width - _wid - 1
				
				if hide_targets == 0 then
					-- Draw surrounding box
					screen:draw_box(_x, y_offset + 1, _x + _wid, 39 + (scale * 3) + y_offset + (y_padding * 3), col1, col2)
					-- Draw score targets
					screen:draw_text(_x + 5, 6 + scale + y_offset,  "DKAFE PRIZES:", col0)
					screen:draw_text(_x + 5, 13 + scale + y_offset + (y_padding * 1), '1ST AT '..tostring(data_score1)..' MINS', gold)
					screen:draw_text(_x + 5, 20 + scale + y_offset + (y_padding * 2), '2ND AT '..tostring(data_score2)..' MINS', silver)
					screen:draw_text(_x + 5, 27 + scale + y_offset + (y_padding * 3), '3RD AT '..tostring(data_score3)..' MINS', bronze)
				end
			end

			if not mac.paused then
				-- Show prize award top-right when time target achieved
				if data_score1 > 0 and time_played > data_score1 * 60 then
					screen:draw_text(_x + x_offset, y_offset,  " 1ST WON "..tostring(data_score1_award.." "), gold, col2)
				elseif data_score2 > 0 and time_played > data_score2 * 60 then
					screen:draw_text(_x + x_offset, y_offset,  " 2ND WON "..tostring(data_score2_award.." "), silver, col2)
				elseif data_score3 > 0 and time_played > data_score3 * 60 then
					screen:draw_text(_x + x_offset, y_offset,  " 3RD WON "..tostring(data_score3_award.." "), bronze, col2)
				end
			end
		end
	end
end
	
emu.register_frame_done(shell_main, "frame")