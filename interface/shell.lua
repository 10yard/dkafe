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
	cass = mac.cassettes[":cassette"]
	if not cass then
		-- find first cassette instance
		for k, v in ipairs(mac.cassettes) do
			cass = v
			break
		end
	end
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
local quick_start, scale, y_pad, x_off, y_off = 0, 0, 0, 0, 0
local inputs = {}

-- compatible roms with associated data
local rom_data, rom_table = {}, {}
--                                                            Quick                                                            Y    X    Y
-- System or rom name                  Message         State  Start  Inputs                                             Scale  Pad  Off  Off
rom_table["a2600"]                   = {"JJ",          false, 0,     {},                                                0,     0,   0,   0 }
rom_table["a2600_dk_kingkong"]       = {"P1",          false, 0,     {},                                                0,     0,   0,   0 }
rom_table["a2600_dk_junior"]         = {"P1 TT JJ",    false, 0,     {},                                                0,     0,   0,   10 }
rom_table["a5200"]                   = {"P1",          true,  600,   {},                                                0,     0,   0,   0 }
rom_table["a7800"]                   = {"P1",          false, 200,   {},                                                0,     0,   0,   0 }
rom_table["a7800_dk_remix"]          = {"P1",          true,  750,   {},                                                0,     0,   0,   0 }
rom_table["a7800_dk_xm"]             = {"P1",          false, 480,   {250,"1"},                                         0,     0,   0,   0 }
rom_table["a800xl"]                  = {"P1",          false, 400,   {},                                                0,     0,   0,   0 }
rom_table["adam"]                    = {"P1",          true,  700,   {},                                                0,     0,   0,   0 }
rom_table["apple2e"]                 = {"P1",          true,  600,   {},                                                3,     1,   -110,0 }
rom_table["apple2e_dk"]              = {"P1",          true,  600,   {500,"S"},                                         3,     1,   -110,0 }
rom_table["apple2e_applekong"]       = {"WAIT TO START",true, 1420,  {440,"R",540,"A"},                                 3,     1,   -110,0 }
rom_table["apple2e_budgiekong"]      = {"WAIT TO START",false,2100,  {},                                                3,     1,   -110,0 }
rom_table["apple2e_cannonball"]      = {"P1",          true,  700,   {},                                                3,     1,   -110,0 }
rom_table["bbcb"]                    = {"JJ",          false, 300,   {60,'*EXEC !BOOT\n'},                              5.5,   15,  0,   0 }
rom_table["bbcb_dk_junior"]          = {"P1",          true,  1300,  {60,'*EXEC !BOOT\n',300,"{S5}{S5}"},               0,     2,   0,   0 }
rom_table["bbcb_krazyjohn"]          = {"",            false, 500,   {60,'*EXEC !BOOT\n',400,"N"},                      0,     2,   0,   0 }
rom_table["bbcb_krazyape2"]          = {"",            false, 1400,  {60,'*EXEC !BOOT\n',540,"{SPACE}",600,"{SPACE}",
																	  660,"{SPACE}",720,"{SPACE}",780,"{SPACE}"},       0,     2,   0,   0 }
rom_table["bbcb_builder"]            = {"JJ",          false, 360,   {60,'*EXEC !BOOT\n',180,"{SPACE}"},                5.5,   15,  0,   0 }
rom_table["bbcb_killergorilla"]      = {"P1",          false, 360,   {60,'*EXEC !BOOT\n',300,"{SPACE}"},                5.5,   15,  0,   0 }
rom_table["bbcb_killergorilla2"]     = {"P1",          true,  800,   {60,'*EXEC !BOOT\n',300,"{ENTER}"},                5.5,   15,  0,   10}
rom_table["plus4"]                   = {"P1",          false, 360,   {150,"RUN\n"},                                     1.33,  2,   0,   0 }
rom_table["c64"]                     = {"P1",          true,  550,   {150,"RUN\n"},                                     1.33,  2,   0,   0 }
rom_table["c64p"]                    = {"P1",          true,  550,   {150,"RUN\n"},                                     1.33,  2,   0,   0 }
rom_table["c64_fast_eddie"]          = {"JJ TT JJ AA", true,  700,   {150,"RUN\n"},                                     1.33,  2,   0,   0 }
rom_table["c64_ck64"]                = {"P1",          true,  900,   {150,"RUN\n"},                                     1.33,  2,   0,   0 }
rom_table["c64_dk_x"]                = {"JJ TT P1",    false, 750,   {150,"RUN\n",300,"{ENTER}"},                       1.33,  2,   0,   0 }
rom_table["c64_kong"]                = {"JJ",          true,  550,   {150,"RUN\n"},                                     1.33,  2,   0,   0 }
rom_table["c64_kongokong"]           = {"P1",          true,  1430,  {150,"RUN\n",1250,"{F7}",1400,"{F1}"},             1.33,  2,   0,   0 }
rom_table["c64_bonkeykong"]          = {"JJ",          true,  14000, {150,'LOAD"*",8,1\n',13000,"RUN\n"},               1.33,  2,   0,   0 }
rom_table["c64_monkeykong"]          = {"WAIT TO START",true, 5900,  {150,'LOAD"*",8,1\n',2100,"RUN\n",2900,"{F1}",
																	3000,"{F1}",3100,"{F1}",3400,"{F3}{F3}{F3}{F3}"},	1.33,  2,   0,   0 }
rom_table["c64_felix"]               = {"JJ TT JJ AA", true,  550,   {150,'RUN\n'},                                     1.33,  2,   0,   0 }
rom_table["c64_krazykong64"]         = {"JJ",          true,  550,   {150,"RUN\n"},                                     1.33,  2,   0,   0 }
rom_table["c64_logger"]              = {"JJ",          true,  550,   {150,"RUN\n"},                                     1.33,  2,   0,   0 }
rom_table["c64_mariosbrewery"]       = {"JJ",          true,  550,   {150,"RUN\n"},                                     1.33,  2,   0,   0 }
rom_table["c64p_dk_junior"]          = {"JJ",          true,  550,   {150,"RUN\n"},                                     1.33,  2,   0,   0 }
rom_table["c64_jumpman"]             = {"P1",          true,  550,   {150,"RUN\n",500,"1"},                             1.33,  2,   0,   0 }
rom_table["c64_kong_sputnik"]        = {"JJ",          true,  850,   {150,"RUN\n",800,"{TAB}"},                         1.33,  2,   0,   0 }
rom_table["cgenie_colourkong"]       = {"P1",          true,  3800,  {60,"\n",200,"SYSTEM\n",320,"KONG\n",
																	   400,"{PLAY}",3500,"/\n"},                        4.1,   3,   0,   0 }
rom_table["cgenie_colourkong32"]     = {"P1",          true,  5000,  {60,"\n",200,"SYSTEM\n",320,"KONG32\n",
																	   400,"{PLAY}",4800,"/\n"},                        4.1,   3,   0,   0 }
rom_table["coco3"]                   = {"JJ",          true,  5200,  {},                                                4.25,  4,   0,   0 }
rom_table["coco3_dk_emu"]            = {"JJ TT JJ AA", true,  6700,  {60,'LOADM"EMULATOR":EXEC\n'},                     4.25,  4,   0,   0 }
rom_table["coco3_dk_remixed"]        = {"JJ TT JJ AA", true,  6700,  {60,'LOADM"DKREMIX":EXEC\n'},                      4.25,  4,   0,   0 }
rom_table["coco3_donkeyking"]        = {"P1 TT P2",    true,  1600,  {60,'LOADM"DONKEY":EXEC\n',1100,"{SPACE}"},        4.25,  4,   0,   0 }
rom_table["coco3_dunkeymonkey"]      = {"JJ",          true,  6400,  {60,'LOADM"DUNKEYM":EXEC\n'},                      4.25,  4,   0,   0 }
rom_table["coco3_monkeykong"]        = {"P1 TT P1 AA", true,  5200,  {60,'LOADM"MONKEYK":EXEC\n'},                      4.25,  4,   0,   0 }
rom_table["coleco"]                  = {"P1",          true,  720,   {},                                                0,     0,   0,   0 }
rom_table["cpc6128"]                 = {"P1",          false, 1450,  {60,'RUN"DONKEY\n'},                               6,     4,   0,   0 }
rom_table["cpc6128_dk"]              = {"P1",          false, 1450,  {60,'RUN"DONKEY\n'},                               6,     4,   0,   0 }
rom_table["cpc6128_climbit"]         = {"P1",          false, 1450,  {60,'RUN"CLIMBIT\n'},                              6,     4,   0,   0 }
rom_table["cpc6128_killergorilla"]   = {"JJ",          false, 1450,  {60,'RUN"KGORILA\n'},                              6,     4,   0,   0 }
rom_table["cpc6128_kongsrevenge"]    = {"",            false, 1260,  {60,'RUN"KONG\n',360,"1\n",420,"n\n",
																		960,"{SPACE}",1080,"{ENTER}",1200,"{ENTER}"},   6,     4,   0,   0 }
rom_table["crvision"]                = {"P2 TT P1",    false, 0,     {},                                                0,     0,   0,   0 }
rom_table["dragon32"]                = {"JJ",          true,  0,     {120,"CLOADM\n"},                                  0,     0,   0,   16}
rom_table["dragon32_kingcuthbert"]   = {"P1 TT P1 AA", true,  3250,  {120,"CLOADM\n",2900,"EXEC\n"},                    0,     0,   0,   16}
rom_table["dragon32_donkeyking"]     = {"JJ",          false, 7300,  {120,"CLOADM\n"},                                  0,     0,   0,   16}
rom_table["dragon32_dunkeymonkey"]   = {"JJ",          false, 6200,  {180,"CLOADM\n",6000,"EXEC\n"},                    0,     0,   0,   16}
rom_table["dragon32_juniorsrevenge"] = {"JJ",          false, 20000, {120,"CLOADM\n"},                                  0,     0,   0,   16}
rom_table["fds"]                     = {"P1",          false, 600,   {},                                                0,     0,   0,   0 }
rom_table["gameboy"]                 = {"P1",          false, 300,   {},                                                1.5,   0,   0,   10}
rom_table["gbcolor"]                 = {"P1",          false, 180,   {},                                                1.5,   0,   0,   10}
rom_table["hbf900a"]                 = {"P1",          true , 2300,  {},                                                5,     12,  0,   0 }
rom_table["hbf900a_tokekong"]        = {"JJ",          true , 3700,  {},                                                5,     12,  0,   0 }
rom_table["hbf900a_apeman"]          = {"JJ",          true,  5300,  {},                                                5,     12,  0,   0 }
rom_table["hbf900a_congo"]           = {"JJ",          true,  14500, {660,'RUN"CAS:"\n'},                               5,     12,  0,   0 }
rom_table["cdkong"]                  = {"P1",          false, 0,     {},                                                18,    32,  0,   40}
rom_table["gckong"]                  = {"P1",          false, 0,     {},                                                18,    32,  0,   40}
rom_table["intv"]                    = {"P1",          true,  900,   {},                                                0,     0,   0,   0 }
rom_table["intv_beautybeast"]        = {"JJ",          false, 0,     {},                                                0,     0,   0,   0 }
rom_table["intv_monkey"]             = {"JJ",          false, 0,     {},                                                0,     0,   0,   0 }
rom_table["intv_intykong"]           = {"",            false, 0,     {},                                                0,     0,   0,   0 }
rom_table["jupace"]                  = {"JJ",          false, 180,   {},                                                2.25,  3,   0,   0 }
rom_table["mo5"]                     = {"P1",          false, 5000,  {90,'RUN""\n'},                                    0,     0,   0,   0 }
rom_table["mz700_jumpman"]           = {"JJ",          false, 10000, {180,"LOAD\n",300,"{PLAY}"},                       0.5,   0,   0,   0 }
rom_table["mz700_crazykong"]         = {"",            true,  20650, {180,"LOAD\n",300,"{PLAY}",18000," ",18500," ",
								  19000," ", 19500," ",20300,"L",20330,"R",20360,"U",20390,"D",20420,"Z",20450,"2"}, 	0.5,   0,   0,   0 }
rom_table["mz700_donkeygorilla"]     = {"JJ",          true,  17500, {180,"LOAD\n",300,"{PLAY}"},                       0.5,   0,   0,   0 }
rom_table["nes"]                     = {"P1",          false, 0,     {},                                                0.5,   0,   0,   0 }
rom_table["oric1"]                   = {"P1",          true,  0,     {180,'CLOAD ""\n'},                                0,     0,   0,   16}
rom_table["oric1_honeykong"]         = {"LR TT JJ",    true,  10000, {180,'CLOAD ""\n',10500,"S"},                      0,     0,   0,   16}
rom_table["oric1_orickong"]          = {"P1",          true,  4700,  {180,'CLOAD ""\n',4500,"RUN\n"},                   0,     0,   0,   16}
rom_table["oric1_dinkykong"]         = {"P1",          true,  6400,  {180,'CLOAD ""\n',5000,'CLOAD ""\n'},              0,     0,   0,   16}
rom_table["pet4032"]                 = {"P1",          false, 240,   {180,"RUN\n"},                                     0,     0,   0,   0 }
rom_table["pet4032_petscii_kong"]    = {"JJ",          false, 240,   {180,"RUN\n"},                                     0,     0,   0,   0 }
rom_table["snes"]                    = {"P1",          false, 360,   {},                                                2.5,   0,   0,   0 }
rom_table["spectrum"]                = {"P1",          false, 0,     {},                                                2,     4,   0,   0 }
rom_table["spectrum_ape_escape"]     = {"P1",          true,  16000, {150,'J""\n', 300, "{PLAY}"},                      2,     4,   0,   0 }
rom_table["spectrum_crazykongcity"]  = {"P1",          true,  12700, {150,'J""\n', 300, "{PLAY}",12500,"M",12600,"1"},  2,     4,   0,   0 }
rom_table["spectrum_kongs_revenge"]  = {"P1",          true,  15000, {150,'J""\n', 300, "{PLAY}"},                      2,     4,   0,   0 }
rom_table["spectrum_killerkong"]     = {"P1",          false, 500,   {},                                                2,     4,   0,   0 }
rom_table["spectrum_killerknight"]   = {"POOR", 	   false, 0,   {},                                                2,     4,   0,   0 }
rom_table["spectrum_kong"]           = {"JJ",          false, 200,   {60,"{SPACE}"},                                    2,     4,   0,   0 }
rom_table["spectrum_krazykong"]      = {"JJ",          false, 0,     {15,"y"},                                          2,     4,   0,   0 }
rom_table["spectrum_wallykong"]      = {"P1",          false, 200,   {60,"SS",100,"0",140,"0"},                         2,     4,   0,   0 }
rom_table["spectrum_monkeybiz"]      = {"P1",          true,  360,   {200,"{SPACE}",300,"{SPACE}"},                     2,     4,   0,   0 }
rom_table["ti99_4a"]                 = {"JJ",          true,  600,   {60,"  2"},                                        0,     0,   0,   0 }
rom_table["vic20"]                   = {"",            true,  400,   {360,"RUN\n"},                                     1.33,  2,   0,   0 }
rom_table["vic20_minikong"]          = {"BUG",         true,  3200,  {360,'LOAD"*",8,1\n',1400,"RUN\n",2200,"N\n"},	    1.33,  2,   0,   0 }
rom_table["vic20_mickybricky"]       = {"P1",          false, 18000, {280,'LOAD\n',400,"{PLAY}"},					    1.33,  2,   0,   0 }
rom_table["vic20_dk_ackenhausen"]    = {"P1",          false, 580,   {360,"RUN\n", 450, "1\n"},                         1.33,  2,   0,   0 }
rom_table["vic20_fast_eddie"]        = {"",            false, 0,     {},                                                1.33,  2,   0,   0 }
rom_table["vic20_hardhatclimber"]    = {"",            false, 600,   {360, "4 CH=99\n", 460,"RUN\n"},                   1.33,  2,   0,   0 }
rom_table["vic20_cannonball"]        = {"",            false, 0,     {},                                                1.33,  2,   0,   0 }
rom_table["vic20_logrun"]            = {"JJ",          true,  700,   {360,"RUN\n",500,"{SPACE}"},                       1.33,  2,   0,   0 }
rom_table["vic20_littlekong"]        = {"",            true,  1100,  {360,"RUN\n"},                                     1.33,  2,   0,   0 }
rom_table["vic20_dkjr_gnw"]          = {"JJ",          false, 500,   {360,"RUN\n"},                                     1.33,  2,   0,   0 }
rom_table["vic20_kongokong"]         = {"P1",          true,  400,   {360,"RUN\n"},                                     1.33,  2,   0,   0 }
rom_table["vic20_krazykong_nufecop"] = {"P1",          true,  550,   {360,"RUN\n"},                                     1.33,  2,   0,   0 }
rom_table["vic20_logger"]            = {"P1",          false, 4600,  {360,"LOAD\n",420,"{PLAY}",4100,"RUN\n",
													 5000,"{SHIFT}",5000,"{HOME}"},   1.33,  2,   0,   0 }
rom_table["zx81_crazykong"]          = {"",            true,  10750, {360,'J""\n',420,"{PLAY}",10400,"\n",10500,"1\n"}, 2,     4,   0,   0 }
rom_table["zx81_kongsrevenge"]       = {"",            false, 20200, {360,'J""\n',420,"{PLAY}",20100, "n\n"},           2,     4,   0,   0 }
rom_table["zx81_krazykong_pss"]      = {"JJ",          true,  11660, {360,'J""\n',420,"{PLAY}",11500," ",11600," "},    2,     4,   0,   0 }
rom_table["zx81_zonkeykong"]         = {"",            true,  16150, {360,'J""\n',420,"{PLAY}",
														  16000,"L", 16030,"R", 16060, "U", 16090, "D", 16120, "Y"},    2,     4,   0,   0 }

-- Read rom data
rom_data = rom_table[shell_name] or rom_table[emu:romname()]
if rom_data then
	start_msg = rom_data[1]
	if start_msg ~= "" and start_msg ~= "BUG" and start_msg ~= "POOR" and start_msg ~= "WAIT TO START" then
		start_msg = "PUSH "..rom_data[1].." TO START"
	end
	state = rom_data[2]
	quick_start = rom_data[3]
	inputs = rom_data[4]
	scale = rom_data[5]
	y_pad = rom_data[6]
	x_off = rom_data[7]
	y_off = rom_data[8]

	-- Substitutions
	start_msg = string.gsub(start_msg, "JJ", "JUMP")
	start_msg = string.gsub(start_msg, "TT", "THEN")
	start_msg = string.gsub(start_msg, "AA", "AGAIN")
	start_msg = string.gsub(start_msg, "LR", "LEFT,RIGHT,UP,DOWN")
	start_msg = string.gsub(start_msg, "BUG", "KNOWN SCREEN ISSUE :(")
	start_msg = string.gsub(start_msg, "POOR", "POOR CONTROLS :(")
end

local start_time = os.time()

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function shell_main()
	if mac ~= nil then
		if screen and screen:frame_number() <= quick_start then
			start_time = os.time()
		end
		time_played = os.time() - start_time

		-- Speed up the inital loading screens
		if quick_start > 0 then
			-- States are automatically used to save/restore the machine start up steps
			if state and file_exists(shell_state) then
				-- state is found so use it and ignore quick_start and any inputs
				quick_start = 0
				inputs = {}
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
					if quick_start > 240 then
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
		if screen and keyb then
			for i = 1, #inputs do
				if i % 2 == 0 then
					if screen:frame_number() == inputs[i-1] then
						if inputs[i] == "{PLAY}" then
							cass:play()
						elseif inputs[i] == "{RESET}" then
							mac:soft_reset()
						elseif string.match(inputs[i], "{") then
							coded = string.gsub(inputs[i], "{S5}", "{SPACE}{SPACE}{SPACE}{SPACE}{SPACE}")
							keyb:post_coded(coded)
						else
							keyb:post(inputs[i])
						end
						if i == #inputs then
							-- All inputs are done,  so clear the table
							inputs = {}
						end
					end
				end
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