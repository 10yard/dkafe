--[[
ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
 888    88o  888  o88        888       888          888
 888    888  888888         8  88      888ooo8      888ooo8
 888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
									by Jon Wilson (10yard)

DKAFE Interface routine for shell scripts.
Simple interface is based on the time a game is played.
- Speed up the loading time of some disk and tape based games
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

local bronze, silver, gold = 0xffcd7f32, 0xffc0c0c0, 0xffd4af37
local white, black, cyan, blue = 0xffffffff, 0xff000000, 0xffa0a0ff, 0xff0000a0
local attenuation = sound.attenuation

-- Adjustments for systems
local target_time = 6
local time_played = 0

--defaults
local start_msg = "PUSH P1 TO START"
local state = false
local post1, postc1 = "", ""
local quick_start, input_fr1, input_fr2, post2, postc2, scale, y_pad, x_off, y_off = 0, 0, 0, 0, 0, 0, 0, 0, 0

-- compatible roms with associated data
local rom_data, rom_table = {}, {}
--                                                            Quick  Input                            Post     Input                 Post              Y    X    Y
-- System or rom name                  Message         State  Start  Fr. 1  Post 1                    Coded 1  Fr. 2   Post 2        Coded 2    Scale  Pad  Off  Off
rom_table["a2600"]                   = {"JJ",          false, 0,     0,     "",                       "",      0,      "",           "",        0,     0,   0,   0 }
rom_table["a5200"]                   = {"P1",          true,  600,   0,     "",                       "",      0,      "",           "",        0,     0,   0,   0 }
rom_table["a7800"]                   = {"P1",          false, 200,   0,     "",                       "",      0,      "",           "",        0,     0,   0,   0 }
rom_table["a7800_dk_remix"]          = {"P1",          true,  750,   0,     "",                       "",      0,      "",           "",        0,     0,   0,   0 }
rom_table["a7800_dk_xm"]             = {"P1 TT P1 AA", false, 200,   0,     "",                       "",      0,      "",           "",        0,     0,   0,   0 }
rom_table["a800xl"]                  = {"P1",          false, 400,   0,     "",                       "",      0,      "",           "",        0,     0,   0,   0 }
rom_table["adam"]                    = {"P1",          true,  700,   0,     "",                       "",      0,      "",           "",        0,     0,   0,   0 }
rom_table["apple2e"]                 = {"P1 TT P1 AA", true,  600,   500,   "",                       "S",     0,      "",           "",        3,     1,   -110,0 }
rom_table["bbcb"]                    = {"JJ",          false, 300,   60,    '*EXEC !BOOT\n',          "",      0,      "",           "",        6,     15,  0,   0 }
rom_table["bbcb_dk_junior"]          = {"JJ TT P1",    false, 300,   60,    '*EXEC !BOOT\n',          "",      200,    "",           "SSSSSSS", 6,     15,  0,   0 }
rom_table["bbcb_killergorilla"]      = {"JJ TT P1",    false, 300,   60,    '*EXEC !BOOT\n',          "",      0,      "",           "",        6,     15,  0,   0 }
rom_table["bbcb_killergorilla2"]     = {"JJ TT P1",    false, 300,   60,    '*EXEC !BOOT\n',          "",      0,      "",           "",        0,     5,   0,   10}
rom_table["c64"]                     = {"P1",          true,  550,   150,   "RUN\n",                  "",      0,      "",           "",        1.33,  2,   0,   0 }
rom_table["c64p"]                    = {"P1",          true,  550,   150,   "RUN\n",                  "",      0,      "",           "",        1.33,  2,   0,   0 }
rom_table["c64_ck64"]                = {"P1",          true,  900,   150,   "RUN\n",                  "",      0,      "",           "",        1.33,  2,   0,   0 }
rom_table["c64_dk_x"]                = {"JJ TT P1",    true,  400,   150,   "RUN\n",                  "",      0,      "RUN\n",      "",        1.33,  2,   0,   0 }
rom_table["c64_kong"]                = {"JJ",          true,  550,   150,   "RUN\n",                  "",      0,      "",           "",        1.33,  2,   0,   0 }
rom_table["c64_kongokong"]           = {"P2 TT P1",    true,  1300,  150,   "RUN\n",                  "",      1250,   "",           "{F7}",    1.33,  2,   0,   0 }
rom_table["c64_bonkeykong"]          = {"JJ",          true,  14000, 150,   'LOAD"*",8,1\n',          "",      13000,  "RUN\n",      "",        1.33,  2,   0,   0 }
rom_table["c64_felix"]               = {"JJ TT JJ AA", true,  550,   150,   'RUN\n',                  "",      0,      "",           "",        1.33,  2,   0,   0 }
rom_table["c64_krazykong64"]         = {"JJ",          true,  550,   150,   "RUN\n",                  "",      0,      "",           "",        1.33,  2,   0,   0 }
rom_table["c64_mariosbrewery"]       = {"JJ",          true,  550,   150,   "RUN\n",                  "",      0,      "",           "",        1.33,  2,   0,   0 }
rom_table["c64p_dk_junior"]          = {"JJ",          true,  550,   150,   "RUN\n",                  "",      0,      "",           "",        1.33,  2,   0,   0 }
rom_table["c64_jumpman"]             = {"P1",          true,  550,   150,   "RUN\n",                  "",      500,    "1",          "",        1.33,  2,   0,   0 }
rom_table["c64_kong_sputnik"]        = {"JJ",          true,  850,   150,   "RUN\n",                  "",      800,    "",           "T",       1.33,  2,   0,   0 }
rom_table["coco3"]                   = {"JJ",          true,  5200,  0,     "",                       "",      0,      "",           "",        4.25,  4,   0,   0 }
rom_table["coco3_dk_emu"]            = {"JJ TT JJ AA", true,  6700,  60,    'LOADM"EMULATOR":EXEC\n', "",      0,      "",           "",        4.25,  4,   0,   0 }
rom_table["coco3_dk_remixed"]        = {"JJ TT JJ AA", true,  6700,  60,    'LOADM"DKREMIX":EXEC\n',  "",      0,      "",           "",        4.25,  4,   0,   0 }
rom_table["coco3_donkeyking"]        = {"P1 TT P2",    true,  1600,  60,    'LOADM"DONKEY":EXEC\n',   "",      1100,   " ",          "S",       4.25,  4,   0,   0 }
rom_table["coco3_dunkeymonkey"]      = {"JJ",          true,  6400,  60,    'LOADM"DUNKEYM":EXEC\n',  "",      0,      "",           "",        4.25,  4,   0,   0 }
rom_table["coco3_monkeykong"]        = {"P1 TT P1 AA", true,  5200,  60,    'LOADM"MONKEYK":EXEC\n',  "",      0,      "",           "",        4.25,  4,   0,   0 }
rom_table["coleco"]                  = {"P1",          true,  720,   0,     "",                       "",      0,      "",           "",        0,     0,   0,   0 }
rom_table["cpc6128"]                 = {"P1",          false, 1450,  60,    'RUN"DONKEY\n',           "",      0,      "",           "",        6,     4,   0,   0 }
rom_table["dragon32"]                = {"JJ",          true,  0,     120,   "CLOADM\n",               "",      0,      "",           "",        0,     0,   0,   16}
rom_table["dragon32_kingcuthbert"]   = {"P1 TT P1 AA", true,  3250,  120,   "CLOADM\n",               "",   2900,      "EXEC\n",     "",        0,     0,   0,   16}
rom_table["dragon32_donkeyking"]     = {"JJ",          true,  7300,  120,   "CLOADM\n",               "",   7000,      "",           "",        0,     0,   0,   16}
rom_table["dragon32_dunkeymonkey"]   = {"JJ",          true,  6200,  180,   "CLOADM\n",               "",   6000,      "EXEC\n",     "",        0,     0,   0,   16}
rom_table["dragon32_juniorsrevenge"] = {"JJ",          true,  20000, 120,   "CLOADM\n",               "",      0,      "",           "",        0,     0,   0,   16}
rom_table["fds"]                     = {"P1",          false, 600,   0,     "",                       "",      0,      "",           "",        0,     0,   0,   0 }
rom_table["gameboy"]                 = {"P1",          false, 300,   0,     "",                       "",      0,      "",           "",        1.5,   0,   0,   10}
rom_table["gbcolor"]                 = {"P1",          false, 180,   0,     "",                       "",      0,      "",           "",        1.5,   0,   0,   10}
rom_table["hbf900a"]                 = {"P1",          true , 2300,  0,     "",                       "",      0,      "",           "",        5,     12,  0,   0 }
rom_table["hbf900a_tokekong"]        = {"JJ",          true , 3700,  0,     "",                       "",      0,      "",           "",        5,     12,  0,   0 }
rom_table["cdkong"]                  = {"P1",          false, 0,     0,     "",                       "",      0,      "",           "",        18,    32,  0,   40}
rom_table["gckong"]                  = {"P1",          false, 0,     0,     "",                       "",      0,      "",           "",        18,    32,  0,   40}
rom_table["intv"]                    = {"P1",          true,  900,   0,     "",                       "",      0,      "",           "",        0,     0,   0,   0 }
rom_table["nes"]                     = {"P1",          false, 0,     0,     "",                       "",      0,      "",           "",        0.5,   0,   0,   0 }
rom_table["oric1"]                   = {"P1",          true,  0,     180,   'CLOAD ""\n',             "",      0,      "",           "",        0,     0,   0,   16}
rom_table["oric1_honeykong"]         = {"LRUD AND JJ", true,  10000, 180,   'CLOAD ""\n',             "",      10500,  "",           "S",        0,     0,   0,   16}
rom_table["oric1_orickong"]          = {"P1",          true,  4700,  180,   'CLOAD ""\n',             "",      4500,   "RUN\n",      "",        0,     0,   0,   16}
rom_table["oric1_dinkykong"]         = {"P1",          true,  6400,  180,   'CLOAD ""\n',             "",      5000,   'CLOAD ""\n', "",        0,     0,   0,   16}
rom_table["pet4032"]                 = {"P1",          false, 240,   180,   "RUN\n",                  "",      0,      "",           "",        0,     0,   0,   0 }
rom_table["snes"]                    = {"P1",          false, 360,   0,     "",                       "",      0,      "",           "",        2.5,   0,   0,   0 }
rom_table["spectrum"]                = {"P1",          false, 0,     0,     "",                       "",      0,      "",           "",        2,     4,   0,   0 }
rom_table["spectrum_kong"]           = {"P1 TT JJ",    false, 0,     0,     "",                       "",      0,      "",           "",        2,     4,   0,   0 }
rom_table["spectrum_krazykong"]      = {"JJ",          false, 0,     15,    "y",                      "",      0,      "",           "",        2,     4,   0,   0 }
rom_table["spectrum_wallykong"]      = {"P1",          false, 180,   60,    "SS        0        0",   "",      0,      "",           "",        2,     4,   0,   0 }
rom_table["ti99_4a"]                 = {"JJ TT P1",    false, 180,   60,    "  2",                    "",      0,      "",           "",        0,     0,   0,   0 }
rom_table["vic20"]                   = {"NONE",        true,  400,   360,   "RUN\n",                  "",      0,      "",           "",        1.33,  2,   0,   0 }
rom_table["vic20_littlekong"]        = {"NONE",        true,  1100,  360,   "RUN\n",                  "",      0,      "",           "",        1.33,  2,   0,   0 }
rom_table["vic20_kongokong"]         = {"P1",          true,  400,   360,   "RUN\n",                  "",      0,      "",           "",        1.33,  2,   0,   0 }
rom_table["vic20_krazykong_nufecop"] = {"P1",          true,  550,   360,   "RUN\n",                  "",      0,      "",           "",        1.33,  2,   0,   0 }

-- Read rom data
rom_data = rom_table[shell_name] or rom_table[emu:romname()]
if rom_data then
	if rom_data[1] == "NONE" then
		start_msg = ""
	else
		start_msg = "PUSH "..rom_data[1].." TO START"
		state = rom_data[2]
	end
	quick_start = rom_data[3]
	input_fr1 = rom_data[4]
	post1 = rom_data[5]
	input_fr2 = rom_data[7]
	post2 = rom_data[8]
	postc2 = rom_data[9]
	scale = rom_data[10]
	y_pad = rom_data[11]
	x_off = rom_data[12]
	y_off = rom_data[13]

	-- Substitutions
	start_msg = string.gsub(start_msg, "JJ", "JUMP")
	start_msg = string.gsub(start_msg, "TT", "THEN")
	start_msg = string.gsub(start_msg, "AA", "AGAIN")
	start_msg = string.gsub(start_msg, "LRUD", "LEFT,RIGHT,UP,DOWN")
	postc1 = string.gsub(postc1, "S", "{SPACE}")
	postc2 = string.gsub(postc2, "S", "{SPACE}")
	postc1 = string.gsub(postc1, "T", "{TAB}")
	postc2 = string.gsub(postc2, "T", "{TAB}")
end

local start_time = os.time()

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function shell_main()
	if mac ~= nil then
		if screen and screen:frame_number() < quick_start then
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
				input_fr1, input_fr2 = 0, 0
				mac:load(shell_state)
			end
			if state and screen and screen:frame_number() == quick_start and not file_exists(shell_state) then
				-- Save a state (rather than using quick start again in the future)
				mac:save(shell_state)
			end

			-- blank the screen
			if screen then
				screen:draw_box(0, 0 , screen.width, screen.height, 0xff000000, 0xff000000)

				if screen:frame_number() < quick_start then
					sound.attenuation = -32 -- mute sounds
					max_frameskip(true)
					if quick_start > 500 then
						local _remain = tostring(math.floor((screen:frame_number() / quick_start) * 100)).."%"
						screen:draw_text(0, 6 + scale + y_off,  "LOADING...".._remain, white, 0xff000000)
						if state and not file_exists(shell_state) then
							screen:draw_text(0, 22 + scale + y_off,  "(SUBSEQUENT LOADS WILL BE INSTANT)", white, 0xff000000)
						end
					end
				else
					sound.attenuation = attenuation
					max_frameskip(false)
					quick_start = 0
				end
			end
		end	
						
		-- specific keys to press on boot
		if keyb then
			-- Inputs 1
			if screen and screen:frame_number() == input_fr1 then
				if postc1 then keyb:post_coded(postc1) end
				if post1 then keyb:post(post1) end
			end

			-- Inputs 2
			if screen and screen:frame_number() == input_fr2 then
				if postc2 then keyb:post_coded(postc2) end
				if post2 then keyb:post(post2) end
			end
		end

		-- HUD
		if screen then
			if data_show_hud ~= 0 and data_score1 and data_score2 and data_score3 then
				-- Draw time targets at startup
				_len = string.len(tostring(data_score1))
				_wid = (14 + _len) * (5 + scale)
				_x = screen.width - _wid - 1
				if time_played > 0 and time_played <= target_time or mac.paused then

					if not mac.paused then
						screen:draw_box(0, 0, screen.width, 10 + scale, black, black)
						screen:draw_text(0, 0,  start_msg, white, black)
					end

					-- Draw surrounding box
					screen:draw_box(_x, y_off + 1, _x + _wid, 39 + (scale * 3) + y_off + (y_pad * 3), cyan, blue)
					-- Draw score targets
					screen:draw_text(_x + 5 + (scale / 2), 6 + scale + y_off,  "DKAFE PRIZES:", white)
					screen:draw_text(_x + 5 + (scale / 2), 13 + scale + y_off + (y_pad * 1), '1ST AT '..tostring(data_score1)..' MINS', gold)
					screen:draw_text(_x + 5 + (scale / 2), 20 + scale + y_off + (y_pad * 2), '2ND AT '..tostring(data_score2)..' MINS', silver)
					screen:draw_text(_x + 5 + (scale / 2), 27 + scale + y_off + (y_pad * 3), '3RD AT '..tostring(data_score3)..' MINS', bronze)
				end

				if not mac.paused then
					-- Show prize award top-right when time target achieved
					if data_score1 > 0 and time_played > data_score1 * 60 then
						screen:draw_text(_x + x_off, y_off,  " 1ST WON "..tostring(data_score1_award.." "), gold, blue)
					elseif data_score2 > 0 and time_played > data_score2 * 60 then
						screen:draw_text(_x + x_off, y_off,  " 2ND WON "..tostring(data_score2_award.." "), silver, blue)
					elseif data_score3 > 0 and time_played > data_score3 * 60 then
						screen:draw_text(_x + x_off, y_off,  " 3RD WON "..tostring(data_score3_award.." "), bronze, blue)
					end
				end
			end
		end
	end
end
	
emu.register_frame_done(shell_main, "frame")