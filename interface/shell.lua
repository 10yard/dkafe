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
- Send keyboard inputs for some games to initiate loading.
- Show targets for play time when the game starts up or when game is paused.
- Show prize award when targets reached for 3rd, 2nd and 1st.
---------------------------------------------------------------------------------
]]

package.path = package.path .. ";" .. os.getenv("DATA_INCLUDES") .. "/?.lua;"
require "functions"
require "graphics"
require "globals"

shell_name = os.getenv("DKAFE_SHELL_NAME")
shell_state = os.getenv("DKAFE_SHELL_STATE")

mame_version = tonumber(emu.app_version())
if mame_version >= 0.241 then
	keyb = mac.natkeyboard
end

local col0, col1, col2 = 0xffffffff, 0xffa0a0ff, 0xff0000a0
local bronze, silver, gold = 0xffcd7f32, 0xffc0c0c0, 0xffd4af37
local time_played
local i_attenuation = sound.attenuation

-- Adjustments for systems
local target_time = 5
local input_frame, input_frame2 = 60, 0
local scale, quick_start, hide_targets, y_offset, x_offset, y_padding = 0, 0, 0, 0, 0, 0
local state = False

if emu.romname() == "a5200" then
	state = true
	quick_start = 600
elseif emu.romname() == "a7800" then
	if shell_name == "a7800_dk_remix" then
		state = true
		quick_start = 750
	else
		quick_start = 200
	end
elseif emu.romname() == "a800xl" then
	state = true
	quick_start = 90
elseif emu.romname() == "adam" then
	state = true
	quick_start = 600
elseif emu.romname() == "apple2e" then
	state = true
	quick_start = 600
	scale = 3
	y_padding = 1
	input_frame = 500
	x_offset = -110
elseif emu.romname() == "bbcb" then
	state = false
	quick_start = 300
	y_padding = 15
	scale = 6
elseif emu.romname() == "c64" then
	state = true
	input_frame = 150
	scale = 1.33
	y_padding = 2
	if shell_name == "c64_ck64" then
		quick_start = 900
	elseif shell_name == "c64_kongokong" then
		quick_start = 700
	else
		quick_start = 550
	end
elseif emu.romname() == "coco3" then
	state = true
	if shell_name == "coco3_dk_emu" or shell_name == "coco3_dk_remixed" then
		quick_start = 6700
	elseif shell_name == "coco3_donkeyking" then
		quick_start = 6400
	else
		quick_start = 5200
	end
	scale = 4.25
	y_padding = 4
elseif emu.romname() == "coleco" then
	state = true
	quick_start = 720
elseif emu.romname() == "cpc6128" then
	quick_start = 1450
	scale = 6
	y_padding = 4
elseif emu.romname() == "dragon32" then
	state = true
	input_frame = 120
	 y_offset = 16
	if shell_name == "dragon32_kingcuthbert" then
		input_frame2 = 2900
		quick_start = 3250
	elseif shell_name == "dragon32_dunkeymonkey" then
		input_frame2 = 4000
		quick_start = 4200
	end
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
	state = true
	scale = 5
	y_padding = 12
	if shell_name == "hbf900a_tokekong" then
		quick_start = 3700
	else
		quick_start = 2300
	end
elseif emu.romname() == "intv" then
	state = true
	quick_start = 900
elseif emu.romname() == "nes" then
	scale = 0.5
elseif emu.romname() == "oric1" then
	state = true
	input_frame = 180
	y_offset = 16
	if shell_name == "oric1_honeykong" then
		quick_start = 10000
		input_frame2 = 10050
	elseif shell_name == "oric1_orickong" then
		quick_start = 4700
		input_frame2 = 4500
	elseif shell_name == "oric1_dinkykong" then
		quick_start = 6400
		input_frame2 = 5000
	end
elseif emu.romname() == "pet4032" then
	quick_start = 240
	input_frame = 180
elseif emu.romname() == "snes" then
	scale = 2.5
	quick_start = 360
elseif emu.romname() == "spectrum" then
	scale = 2
	y_padding = 4
	input_frame = 15
elseif emu.romname() == "ti99_4a" then
	quick_start = 180
end
local start_time = os.time()

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function shell_main()
	if mac ~= nil then
		if screen:frame_number() < quick_start then
			time_played = 0
		else
			time_played = os.time() - start_time
		end
			
		-- Speed up the inital loading screens
		if quick_start > 0 then

			-- States are automatically used to save/restore the machine start up steps
			if state and file_exists(shell_state) then
				-- state is found so use it and ignore quick_start and any inputs
				quick_start = 0
				input_frame, input_frame2 = "", ""
				mac:load(shell_state)
			end
			if state and screen:frame_number() == quick_start and not file_exists(shell_state) then
				-- Save a state (rather than using quick start again in the future)
				mac:save(shell_state)
			end

			-- blank the screen
			screen:draw_box(0, 0 , screen.width, screen.height, 0xff000000, 0xff000000)

			if screen:frame_number() < quick_start then
				sound.attenuation = -32 -- mute sounds
				max_frameskip(true)
				if quick_start > 500 then
					--local _remain = tostring(math.floor((quick_start - screen:frame_number()) / 60))
					local _remain = tostring(math.floor((screen:frame_number() / quick_start) * 100)).."%"
					screen:draw_text(0, 6 + scale + y_offset,  "LOADING...".._remain, col0, 0xff000000)
				end
			else
				sound.attenuation = i_attenuation
				max_frameskip(false)
				quick_start = 0
			end
		end	
						
		-- specific keys to press on boot
		if keyb then
			-- Inputs 1
			if screen:frame_number() == input_frame then
				if emu.romname() == "apple2e" then
					keyb:post_coded("{SPACE}")
				elseif emu.romname() == "bbcb" then
					keyb:post("*EXEC !BOOT\n")
				elseif emu.romname() == "c64" then
					keyb:post('RUN\n')
				elseif emu.romname() == "cpc6128" then
					keyb:post('RUN"DONKEY\n')
				elseif emu.romname() == "coco3" then
					if shell_name == "coco3_dk_emu" then
						keyb:post('LOADM"EMULATOR":EXEC\n')
					elseif shell_name == "coco3_dk_remixed" then
						keyb:post('LOADM"DKREMIX":EXEC\n')
					elseif shell_name == "coco3_dunkeymonkey" then
						keyb:post('LOADM"DUNKEYM":EXEC\n')
					elseif shell_name == "coco3_kingcuthbert" then
						keyb:post('LOADM"KINGCUTH":EXEC\n')
					elseif shell_name == "coco3_monkeykong" then
						keyb:post('LOADM"MONKEYK":EXEC\n')
					elseif shell_name == "coco3_donkeyking" then
						keyb:post('LOADM"DONKEY":EXEC\n')
					end
				elseif emu.romname() == "dragon32" then
					keyb:post('CLOADM\n')
				elseif emu.romname() == "oric1" then
					keyb:post('CLOAD ""\n')
				elseif emu.romname() == "pet4032" then
					keyb:post('RUN\n')
				elseif emu.romname() == "spectrum" then
					if shell_name == "spectrum_krazykong" then
						keyb:post('y')
					elseif shell_name == "spectrum_wallykong" then
						-- have to press keys a few times, this game is not very responsive
						keyb:post('ssssssssss')
						keyb:post('   0   0   1')
					end
				elseif emu.romname() == "ti99_4a" then
					keyb:post_coded("{SPACE}")
					keyb:post("2")
				end
			end

			-- Inputs 2
			if screen:frame_number() == input_frame2 then
				if shell_name == "coco3_donkeyking" then
					keyb:post_coded("{SPACE}")
				elseif shell_name == "dragon32_kingcuthbert" or shell_name == "dragon32_dunkeymonkey" then
					keyb:post('EXEC\n')
				elseif shell_name == "oric1_dinkykong" then
					keyb:post('CLOAD ""\n')
				elseif shell_name == "oric1_orickong" then
					keyb:post('RUN\n')
				elseif shell_name == "oric1_honeykong" then
					keyb:post_coded('{SPACE}')
				end
			end
		end

		-- HUD
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