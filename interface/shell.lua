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
- Show and announce prize award when targets reached for 3rd, 2nd and 1st.
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

local white, black = 0xffffffff, 0xff000000
local attenuation = sound.attenuation

-- Adjustments for systems
local target_time = 5
local time_played = 0

--defaults
local start_msg = "PUSH P1 TO START"
local state = false
local quick_start = 0
local inputs = {}

-- score targets achieved
local st1, st2, st3 = false, false, false

-- compatible roms with associated data
local rom_data, rom_table = {}, {}
--                                                              Quick
-- System or rom name                  Message           State  Start  Inputs
rom_table["a2600"]                   = {"JJ",            false, 0,     {}}
rom_table["a2600_dk_kingkong"]       = {"P1",            false, 0,     {}}
rom_table["a2600_dk_junior"]         = {"P1 TT JJ",      false, 0,     {}}
rom_table["a5200"]                   = {"P1",            true,  600,   {}}
rom_table["a7800"]                   = {"P1",            false, 200,   {}}
rom_table["a7800_dk_remix"]          = {"P1",            true,  750,   {}}
rom_table["a7800_dk_xm"]             = {"P1",            false, 480,   {250,"1"}}
rom_table["a800xl"]                  = {"P1",            false, 400,   {}}
rom_table["adam"]                    = {"P1",            true,  700,   {}}
rom_table["apple2e"]                 = {"P1",            true,  600,   {}}
rom_table["apple2e_dk"]              = {"P1",            true,  600,   {500,"S"}}
rom_table["apple2e_applekong"]       = {"WAIT TO START", true,  1420,  {440,"R",540,"A"}}
rom_table["apple2e_budgiekong"]      = {"WAIT TO START", false, 2000,  {}}
rom_table["apple2e_cannonball"]      = {"P1",            true,  700,   {}}
rom_table["bbcb"]                    = {"JJ",            false, 300,   {60,'*EXEC !BOOT\n'}}
rom_table["bbcb_dk_junior"]          = {"P1",            true,  1300,  {60,'*EXEC !BOOT\n',300,"{S5}{S5}"}}
rom_table["bbcb_krazyjohn"]          = {"",              false, 500,   {60,'*EXEC !BOOT\n',400,"N"}}
rom_table["bbcb_krazyape2"]          = {"",              false, 1400,  {60,'*EXEC !BOOT\n',540,"{SPACE}",600,"{SPACE}",660,"{SPACE}",720,"{SPACE}",780,"{SPACE}"}}
rom_table["bbcb_builder"]            = {"JJ",            false, 360,   {60,'*EXEC !BOOT\n',180,"{SPACE}"}}
rom_table["bbcb_killergorilla"]      = {"P1",            false, 360,   {60,'*EXEC !BOOT\n',300,"{SPACE}"}}
rom_table["bbcb_killergorilla2"]     = {"P1",            true,  800,   {60,'*EXEC !BOOT\n',300,"{ENTER}"}}
rom_table["plus4"]                   = {"P1",            false, 360,   {150,"RUN\n"}}
rom_table["c64"]                     = {"P1",            true,  550,   {150,"RUN\n"}}
rom_table["c64p"]                    = {"P1",            true,  550,   {150,"RUN\n"}}
rom_table["c64_fast_eddie"]          = {"JJ TT JJ AA",   true,  700,   {150,"RUN\n"}}
rom_table["c64_ck64"]                = {"P1",            true,  900,   {150,"RUN\n"}}
rom_table["c64_dk_x"]                = {"JJ TT P1",      false, 750,   {150,"RUN\n",300,"{ENTER}"}}
rom_table["c64_kong"]                = {"JJ",            true,  550,   {150,"RUN\n"}}
rom_table["c64_kongokong"]           = {"P1",            true,  1430,  {150,"RUN\n",1250,"{F7}",1400,"{F1}"}}
rom_table["c64_bonkeykong"]          = {"JJ",            true,  14000, {150,'LOAD"*",8,1\n',13000,"RUN\n"}}
rom_table["c64_monkeykong"]          = {"WAIT TO START", true,  5900,  {150,'LOAD"*",8,1\n',2100,"RUN\n",2900,"{F1}",3000,"{F1}",3100,"{F1}",3400,"{F3}{F3}{F3}{F3}"}}
rom_table["c64_felix"]               = {"JJ TT JJ AA",   true,  550,   {150,'RUN\n'}}
rom_table["c64_krazykong64"]         = {"JJ",            true,  550,   {150,"RUN\n"}}
rom_table["c64_logger"]              = {"JJ",            true,  550,   {150,"RUN\n"}}
rom_table["c64_mariosbrewery"]       = {"JJ",            true,  550,   {150,"RUN\n"}}
rom_table["c64p_dk_junior"]          = {"JJ",            true,  550,   {150,"RUN\n"}}
rom_table["c64_jumpman"]             = {"P1",            true,  550,   {150,"RUN\n",500,"1"}}
rom_table["c64_kong_sputnik"]        = {"JJ",            true,  850,   {150,"RUN\n",800,"{TAB}"}}
rom_table["cgenie_colourkong"]       = {"P1",            true,  3800,  {60,"\n",200,"SYSTEM\n",320,"KONG\n",400,"{PLAY}",3500,"/\n"}}
rom_table["cgenie_colourkong32"]     = {"P1",            true,  5000,  {60,"\n",200,"SYSTEM\n",320,"KONG32\n",400,"{PLAY}",4800,"/\n"}}
rom_table["coco3"]                   = {"JJ",            true,  5200,  {}}
rom_table["coco3_dk_emu"]            = {"JJ TT JJ AA",   true,  6700,  {60,'LOADM"EMULATOR":EXEC\n'}}
rom_table["coco3_dk_remixed"]        = {"JJ TT JJ AA",   true,  6700,  {60,'LOADM"DKREMIX":EXEC\n'}}
rom_table["coco3_donkeyking"]        = {"P1 TT P2",      true,  1600,  {60,'LOADM"DONKEY":EXEC\n',1100,"{SPACE}"}}
rom_table["coco3_dunkeymonkey"]      = {"JJ",            true,  6400,  {60,'LOADM"DUNKEYM":EXEC\n'}}
rom_table["coco3_monkeykong"]        = {"P1 TT P1 AA",   true,  5200,  {60,'LOADM"MONKEYK":EXEC\n'}}
rom_table["coleco"]                  = {"P1",            true,  720,   {}}
rom_table["cpc6128"]                 = {"P1",            false, 1450,  {60,'RUN"DONKEY\n'}}
rom_table["cpc6128_dk"]              = {"P1",            false, 1450,  {60,'RUN"DONKEY\n'}}
rom_table["cpc6128_climbit"]         = {"P1",            false, 1450,  {60,'RUN"CLIMBIT\n'}}
rom_table["cpc6128_killergorilla"]   = {"JJ",            false, 1450,  {60,'RUN"KGORILA\n'}}
rom_table["cpc6128_kongsrevenge"]    = {"",              false, 1260,  {60,'RUN"KONG\n',360,"1\n",420,"n\n",960,"{SPACE}",1080,"{ENTER}",1200,"{ENTER}"}}
rom_table["crvision"]                = {"P2 TT P1",      false, 0,     {}}
rom_table["dragon32"]                = {"JJ",            true,  0,     {120,"CLOADM\n"}}
rom_table["dragon32_kingcuthbert"]   = {"P1 TT P1 AA",   true,  3250,  {120,"CLOADM\n",2900,"EXEC\n"}}
rom_table["dragon32_donkeyking"]     = {"JJ",            false, 5000,  {120,"CLOADM\n"}}
rom_table["dragon32_dunkeymonkey"]   = {"JJ",            false, 6200,  {180,"CLOADM\n",6000,"EXEC\n"}}
rom_table["dragon32_juniorsrevenge"] = {"JJ",            false, 10000, {180,"CLOADM\n"}}
rom_table["fds"]                     = {"P1",            false, 600,   {}}
rom_table["gameboy"]                 = {"P1",            false, 300,   {}}
rom_table["gbcolor"]                 = {"P1",            false, 180,   {}}
rom_table["gbcolor_dk_arcade"]       = {"",              false, 220,   {}}
rom_table["hbf900a"]                 = {"P1",            true , 2300,  {}}
rom_table["hbf900a_tokekong"]        = {"JJ",            true , 3700,  {}}
rom_table["hbf900a_apeman"]          = {"JJ",            true,  5300,  {}}
rom_table["hbf900a_congo"]           = {"JJ",            true,  14500, {660,'RUN"CAS:"\n'}}
rom_table["cdkong"]                  = {"P1",            false, 0,     {}}
rom_table["gckong"]                  = {"P1",            false, 0,     {}}
rom_table["intv"]                    = {"P1",            true,  900,   {}}
rom_table["intv_beautybeast"]        = {"JJ",            false, 0,     {}}
rom_table["intv_monkey"]             = {"JJ",            false, 0,     {}}
rom_table["intv_intykong"]           = {"",              false, 0,     {}}
rom_table["jupace"]                  = {"JJ",            false, 180,   {}}
rom_table["mo5"]                     = {"P1",            false, 5000,  {90,'RUN""\n'}}
rom_table["mz700_jumpman"]           = {"JJ",            false, 10000, {180,"LOAD\n",300,"{PLAY}"}}
rom_table["mz700_crazykong"]         = {"",              true,  20650, {180,"LOAD\n",300,"{PLAY}",18000," ",18500," ",19000," ", 19500," ",20300,"L",20330,"R",20360,"U",20390,"D",20420,"Z",20450,"2"}}
rom_table["mz700_donkeygorilla"]     = {"JJ",            true,  17500, {180,"LOAD\n",300,"{PLAY}"}}
rom_table["nes"]                     = {"P1",            false, 0,     {}}
rom_table["orica"]                   = {"JJ",            true,  1850,  {180,'CLOAD ""\n'}}
rom_table["oric1"]                   = {"P1",            true,  0,     {180,'CLOAD ""\n'}}
rom_table["oric1_honeykong"]         = {"",              true,  10180, {180,'CLOAD ""\n',9700,"{SPACE}",9860,"5",9920,"6",9980,"7",10040,"8",10120,"{SPACE}"}}
rom_table["oric1_orickong"]          = {"P1",            true,  4700,  {180,'CLOAD ""\n',4500,"RUN\n"}}
rom_table["oric1_dinkykong"]         = {"P1",            true,  6400,  {180,'CLOAD ""\n',5000,'CLOAD ""\n'}}
rom_table["pet4032"]                 = {"P1",            false, 240,   {180,"RUN\n"}}
rom_table["pet4032_petscii_kong"]    = {"JJ",            false, 240,   {180,"RUN\n"}}
rom_table["pcw10"]                   = {"",              false, 2900,  {1500,"2"}}
rom_table["sg1000"]                  = {"JJ",            false, 0,     {}}
rom_table["snes"]                    = {"P1",            false, 360,   {}}
rom_table["spectrum"]                = {"P1",            false, 0,     {}}
rom_table["spectrum_ape_escape"]     = {"P1",            true,  16000, {150,'J""\n',300,"{PLAY}"}}
rom_table["spectrum_dk3_micro_vs"]   = {"P1",            true,  14500, {150,'J""\n',300,"{PLAY}"}}
rom_table["spectrum_crazykongcity"]  = {"P1",            true,  12700, {150,'J""\n',300,"{PLAY}",12500,"M",12600,"1"}}
rom_table["spectrum_kongs_revenge"]  = {"P1",            true,  15000, {150,'J""\n',300,"{PLAY}"}}
rom_table["spectrum_killerkong"]     = {"P1",            false, 500,   {}}
rom_table["spectrum_killerknight"]   = {"POOR", 	     false, 0,     {}}
rom_table["spectrum_kong"]           = {"JJ",            false, 200,   {60,"{SPACE}"}}
rom_table["spectrum_krazykong"]      = {"JJ",            false, 0,     {15,"y"}}
rom_table["spectrum_wallykong"]      = {"P1",            false, 200,   {60,"SS",100,"0",140,"0"}}
rom_table["spectrum_monkeybiz"]      = {"P1",            true,  360,   {200,"{SPACE}",300,"{SPACE}"}}
rom_table["spectrum_spec_kong"]      = {"",			     true,  9360,  {150,'J""\n',300,"{PLAY}",9000,"\n",9100,"\n",9200,"\n",9300,"1\n"}}
rom_table["spectrum_wrathofkong"]    = {"P1",            true,  5100,  {150,'J""\n',300,"{PLAY}",5050,"{STOP}"}}
rom_table["spectrum_dk_reloaded"]    = {"",              true,  12910, {150,'J""\n',300,"{PLAY}",12900,"2"}}
rom_table["spec128_dk_reload_again"] = {"",              false, 130,   {60,"x",120,"1"}}
rom_table["spec128_dk_arcade"]       = {"",              false, 70,    {60,"0"}}
rom_table["ti99_4a"]                 = {"JJ",            true,  600,   {60,"  2"}}
rom_table["vic20"]                   = {"",              true,  400,   {360,"RUN\n"}}
rom_table["vic20_se"]                = {"",              false, 500,   {360,"SYS4096\n"}}
rom_table["vic20-se_mickybricky"]    = {"P1",            false, 18000, {360,'LOAD\n',420,"{PLAY}"}}
rom_table["vic20-se_dk_ackenhausen"] = {"P1",            false, 580,   {360,"RUN\n", 450, "1\n"}}
rom_table["vic20_fast_eddie"]        = {"",              false, 0,     {}}
rom_table["vic20-se_witchway"]       = {"",              false, 180,   {}}
rom_table["vic20_hardhatclimber"]    = {"",              false, 600,   {360, "4 CH=99\n", 460,"RUN\n"}}
rom_table["vic20_cannonball"]        = {"",              false, 0,     {}}
rom_table["vic20-se_logrun"]         = {"JJ",            true,  700,   {360,"RUN\n",500,"{SPACE}"}}
rom_table["vic20_littlekong"]        = {"",              true,  1100,  {360,"RUN\n"}}
rom_table["vic20-se_dkjr_gnw"]       = {"JJ",            false, 500,   {360,"RUN\n"}}
rom_table["vic20_konkeykong"]        = {"",              true,  8900,  {360,"LOAD\n",450,"{PLAY}",3300,"RUN\n"}}
rom_table["vic20_kongokong"]         = {"P1",            true,  400,   {360,"RUN\n"}}
rom_table["vic20_krazykong_nufecop"] = {"P1",            true,  550,   {360,"RUN\n"}}
rom_table["vic20-se_logger"]         = {"P1",            false, 4600,  {360,"LOAD\n",420,"{PLAY}",4100,"RUN\n",5000,"{SHIFT}",5000,"{HOME}"}}
rom_table["x1"]                      = {"",              false, 2100,  {}}
rom_table["zx81"]                    = {"",              false, 0,     {360,'J""\n',420,"{PLAY}"}}
rom_table["zx81_kong"]               = {"",              true,  19500, {360,'J""\n',420,"{PLAY}"}}
rom_table["zx81_crazykong"]          = {"",              true,  10750, {360,'J""\n',420,"{PLAY}",10400,"\n",10500,"1\n"}}
rom_table["zx81_kongsrevenge"]       = {"",              false, 20200, {360,'J""\n',420,"{PLAY}",20100, "n\n"}}
rom_table["zx81_krazykong_pss"]      = {"JJ",            true,  11660, {360,'J""\n',420,"{PLAY}",11500," ",11600," "}}
rom_table["zx81_zonkeykong"]         = {"",              true,  16150, {360,'J""\n',420,"{PLAY}",16000,"L", 16030,"R", 16060, "U", 16090, "D", 16120, "Y"}}

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

function is_raspberry_pi()
	return package.config:sub(1,1) == "/"
end


function play_wav(sound)
	if is_raspberry_pi() then
		io.popen("aplay -q ../sounds/"..sound..".wav &")
	else
		if file_exists("plugins/galakong/bin/wavplay.exe") then
			-- on Windows reuse the bundled galakong wavplay utility - which also has an XP version
			io.popen("start /B /HIGH plugins/galakong/bin/wavplay.exe ../sounds/"..sound..".wav")
		end
	end
end


function shell_main()
	if mac ~= nil then
		if screen and screen:frame_number() <= quick_start then
			start_time = os.time()
		end
		time_played = os.time() - start_time

		-- Speed up the initial loading screens
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
						if state and not file_exists(shell_state) then
							mac:popmessage('LOADING...'.._remain..'\n\nNOTE: SUBSEQUENT LOADS WILL BE INSTANT')
						else
							mac:popmessage('LOADING...'.._remain)
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
						elseif inputs[i] == "{STOP}" then
							cass:stop()
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
				-- Draw time targets at startup (or when paused)
				if time_played > 0 and (time_played <= target_time or mac.paused) then
					if not mac.paused and start_msg ~= "" then
						screen:draw_text(0, 4,  start_msg.." ", black, black) -- clear block for message
						screen:draw_text(0, 0,  start_msg.." ", white, black)
					end
					--Simple prize target message
					mac:popmessage('DKAFE Prizes:\n1st at '..tostring(data_score1)..' mins, 2nd at '..tostring(data_score2)..' mins, 3rd at '..tostring(data_score3)..' mins')
				end

				if not mac.paused then
					-- Show prize award for 5 seconds when time target achieved
					if data_score1 > 0 and time_played > data_score1 * 60 and time_played < data_score1 * 60 + 5 then
						mac:popmessage('Won 1st Prize of '..tostring(data_score1_award)..' coins')
						if not st1 then
							play_wav("award1_short")
							st1 = true
						end
					elseif data_score2 > 0 and time_played > data_score2 * 60 and time_played < data_score2 * 60 + 5 then
						mac:popmessage('Won 2nd Prize of '..tostring(data_score2_award)..' coins')
						if not st2 then
							play_wav("award2_short")
							st2 = true
						end
					elseif data_score3 > 0 and time_played > data_score3 * 60 and time_played < data_score3 * 60 + 5 then
						mac:popmessage('Won 3rd Prize of '..tostring(data_score3_award)..' coins')
						if not st3 then
							play_wav("award3_short")
							st3 = true
						end
					end
				end
			end
		end
	end
end

emu.register_frame_done(shell_main, "frame")