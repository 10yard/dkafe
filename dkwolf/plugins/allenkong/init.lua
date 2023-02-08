-- Allen Kong
-- by Jon Wilson (10yard)
--
-- Tested with latest MAME version 0.247
-- Fully compatible with all MAME versions from 0.196
--
-- Minimum start up arguments:
--   mame dkong -plugin allenkong
-----------------------------------------------------------------------------------------
local exports = {}
exports.name = "allenkong"
exports.version = "1.3"
exports.description = "Allen Kong"
exports.license = "GNU GPLv3"
exports.author = { name = "Jon Wilson (10yard)" }
local allenkong = exports

package.path = package.path .. ";plugins/allenkong/resources.lua"
require("resources")

function allenkong.startplugin()
	-- load graphics
	local pic_big, pic_small = define_allen_big(), define_allen_small()
	local pic_fack_l, pic_fack_r = define_fack_left(), define_fack_right()
	local pic_10yard, pic_lukey = define_10yard(), define_lukey()
	local level_lookup, level_data = define_level_lookup(), define_level_data()
	local pic_finger = define_finger()
	local pic_restrict = define_restricted()
	local pic_balloon = define_balloon()

	-- Load characters
	local char_table = define_chars()

	-- load sound groups
	local sounds = define_sounds()

	-- load texts
	local texts = define_texts()

	-- Plugin variables
	local mame_version, is_pi, mac, scr, cpu, mem, frame, speed_avg
	local mode1, mode2, stage, level, jumpx, jumpy, sprte, facing, score, input
	local last, starfield = {}, {}
	local backjump_count, smash_count, speed_net = 0, 0, 0
	local soundplay_index, random_index, streak_index = 1, 1, 1
	local celebrating, lukey, selected = false, false, false
	local level_select = 17

	function initialize()
		mame_version = tonumber(emu.app_version())
		is_pi = package.config:sub(1,1) == "/"
		math.randomseed(os.time())

		if emu.romname() == "dkong" then
			if mame_version >= 0.196 then
				if type(manager.machine) == "userdata" then
					mac = manager.machine
					vid = mac.video
				else
					mac =  manager:machine()
					vid = mac:video()
				end
			else
				print("ERROR: The allenkong plugin requires MAME version 0.196 or greater.")
			end
		end
		if mac ~= nil then
			if validate_sounds() then
				scr = mac.screens[":screen"]
				cpu = mac.devices[":maincpu"]
				mem = cpu.spaces["program"]
				mem:write_direct_u32(0x01ea, 0x0000063e)  -- force game to start on the title screen

				random_play("startup")  -- initialise sound and play startup restriction/warning

				change_title()
				change_scores()

				--Generate a starfield (of ballons)
				for _=1, 40 do
					table.insert(starfield, math.random(255))
					table.insert(starfield, math.random(223))
					table.insert(starfield, math.random(0xffaaaaaa, 0xffffffff))
				end
			end
		end
	end

	function main()
		if cpu ~= nil then
			frame = scr:frame_number()
			jumpx, jumpy = read(0x6203), read(0x6205)
			mode1, mode2 = read(0x6005), read(0x600a)
			stage, level = read(0x6227), read(0x6229)
			sprte, facing = read(0x694d) % 128, read(0x6207)
			score = tonumber(get_score_segment(0x60b4)..get_score_segment(0x60b3)..get_score_segment(0x60b2))

			-- start up logo and run a short performance test.
			if frame > 0 and frame <= 120 then
				write(0x600a, 6) -- force logo screen
				write(0x6001, 0) -- force no credit entry
				write_ram_message(0x77bf, "                            ")  -- hide credits during initialisation

				scr:draw_box(0, 0, 224, 256, 0xff000000, 0xff000000)
				draw_graphic(pic_restrict, 152, 72)
				scr:draw_box(84, 72, 88, 72 + frame / 1.5, 0xffff0000, 0xffff0000)  -- progress bar

				-- draw hidden fack graphic to add some stress to the performance test
				-- If average emulation for 120 frames is less than 98.5% then we will disable some extra graphics
				if mame_version >= 0.227 then
					speed_net = speed_net + vid.speed_factor
					draw_graphic(pic_fack_r, 80, 80, frame % 20 < 10, 0xff000000)
				else
					speed_avg = 1
				end
			end
			if not speed_avg and frame > 120 then speed_avg = speed_net / 120 end  -- calculate average emu speed

			-- logo screen -------------------------------------------------------------------------------------------
			if mode1 ~= 3 then
				if frame > 120 and mode2 >= 6 and mode2 <= 7 then
					scr:draw_box(48, 80, 88, 144, 0xff000000, 0xff000000)
					draw_graphic(pic_big, 86, 96, true)
				end
				if mode2 == 7 then
					if get("mode2") ~= 7 and frame - get("logo") >= 120 then
						random_play("logo")
						store("logo")
						random_index = math.random(1, #texts)
					end
					write_ram_message(0x777c, "         []2022         ")
					write_ram_message(0x777d, texts[random_index])
				end
			end

			-- high score screen -------------------------------------------------------------------------------------
			if mode2 == 1 then
				write_ram_message(0x77be, " VERS "..exports.version)
				if read(0x6007) == 1 then   -- no credits inserted
					if get("mode2") ~= 1 and frame > get("dead") + 540 then
						random_play("highscore")
					end
					draw_graphic(pic_finger, 140, 152, frame % 180 <= 90)
					scr:draw_box(0, 136, 8, 224, 0xff000000, 0xff000000)
					draw_graphic(pic_10yard, 20, 178)
				end
			end
			if get("mode2") == 1 and mode2 ~= 1 then
				-- clear the version text
				write_ram_message(0x77be, "         ")
			end

			-- level selection screen --------------------------------------------------------------------------------
			if mode1 == 3 and mode2 == 7 then
				if get("mode2") ~= 7 then selected = false end

				draw_level_selection()
				input = read(0x6011)  -- 1=right, 2=left, 4=up, 8=down, 16=jump

				if not selected and input ~= get("input") then
					if level_lookup[input] then
						level_select = level_lookup[input]
						play("c"..tostring(level_select))
						store("input", input)
					end
				end
				write_ram_message(0x74c3, string.format("%02d", level_select))

				local _adds, _data, _start, _y, _x
				if read(0x600d, 0) then _adds = {0x7781, 0x60b2} else _adds = {0x7521, 0x60b5} end  -- p1/p2 scores
				_data = level_data[level_select]
				_start, _y, _x = _data[1], _data[2], _data[3]

				write_ram_message(_adds[1], _start)
				set_score_segment(_adds[2]+2, string.sub(_start,1,2))
				set_score_segment(_adds[2]+1, string.sub(_start,3,4))
				set_score_segment(_adds[2]+0, string.sub(_start,5,6))
				selection_box(_y, _x)

				if input == 16 then
					write(0x6229, level_select)
					selected = true
					if read(0x6385, 5) then play("letsgostart") end
					if level_select >= 5 then write(0x622a, 0x73) end  -- update level pattern to point to level 5+
					write(0x6385, 7)  -- skip the climb scene
				elseif not selected then
					-- pause climb scene timer
					write(0x6385, 5)
				end
			end

			-- how high screen --------------------------------------------------------------------------------------
			if mode1 == 3 and mode2 == 8 and get("mode2") ~= 8 then
				if frame > get("hesitated") + 500 and math.random(1, 3) == 1 then
					play("fackyou")
				end
				-- restore the game startup logic
				if mem:read_direct_u32(0x01ea) ~= 0xaf622732 then
					mem:write_direct_u32(0x01ea, 0xaf622732)
				end
			end

			-- name/score registration ------------------------------------------------------------------------------
			if mode2 == 0x15 and get("mode2") ~= 0x15 then
				random_play("highscore")
			end

			-- game over --------------------------------------------------------------------------------------------
			if mode2 == 0x10 and get("mode2") ~= 0x10 and math.random(1,2) then
				random_play("gameover")
			end

			-- announce points --------------------------------------------------------------------------------------
			local _bonus_sprite, _bonus_timer = read(0x6a31), read(0x6341)
			if _bonus_timer == 15 and _bonus_sprite >= 123 and _bonus_sprite <= 127 then

				---- double back jump on top girder to score 2 x 100
				if stage == 1 and _bonus_sprite == 123 then
					if frame <= get("100") + 150 then
						if jumpx > 200 and backjump_count == 1 then
							random_play("jumpdouble")
						else
							backjump_count = 0
						end
					end
					if jumpy <= 80 and jumpx >= 175 and jumpx <= 200 then
						backjump_count = 1
						store("100")
					end
				end

				-- regular point scoring
				if _bonus_sprite > 123 and (_bonus_sprite >= 126 or math.random(1, 5) <= 2) then
					-- don't announce all the trivial scoring
					if stage == 3 and jumpx >= 200 and jumpy <= 100 then
						play("topshelf")  -- grabbing item from top right of rivets board
					elseif _bonus_sprite == 125 or _bonus_sprite == 126 then -- 300, 500
						if _bonus_sprite == 125 and math.random(1, 2) == 1 then
							random_play("bonus300")
						else
							random_play("bonus")
						end
					elseif _bonus_sprite == 127 then
						if read(0x6217, 0) then
							random_play("jump800")  -- multi barrel jump
						else
							random_play("bonus800") -- 800 hammer smash
						end
					end
				end
				store("points")
			end

			-- count hammer smashes.  announce when count reaches the random streak index ---------------------------
			local _smash = read(0x63b9)
			if read(0x6217, 1) then
				if _smash ~= 1 and get("smash") == 1 then
					smash_count = smash_count + 1
					if smash_count >= streak_index and smash_count <= 18 then
						play("c"..tostring(smash_count))
					end
				end
			else
				smash_count = 0
				streak_index = math.random(1, 10)  -- the next smash streak will start at a random count of smashes
			end
			store("smash", _smash)

			-- stage / level completion -----------------------------------------------------------------------------
			if mode2 == 8 or mode2 == 22 then
				if mode2 == 22 then
					-- stage completion
					if get("mode2") ~= 22 then
						store("finger")
						if level == 4 and stage == 4 and score < 100000 then
							random_play("shitscore")
						else
							random_play("complete")
						end
					end
					if frame < get("finger") + 120 then
						draw_graphic(pic_finger, 156, 80)
					end
				end
				-- reposition Jumpman on stage completion
				jumpx = read(0x694c)
				jumpy = read(0x694f)
				if jumpx >= 112 then facing = 0 else facing = 128 end
			end

			-- Gameplay ---------------------------------------------------------------------------------------------
			if (mode1 == 1 and mode2 >= 3 and mode2 <=4) or ((mode2 >= 11 and mode2 <= 13) or mode2 == 22 or mode2 == 8) then
				if jumpy > 0 then
					if sprte >= 120 and sprte <=122 then
						-- dead
						jumpx = jumpx + 1
						write(0x694d, 120)

						if jumpx <= 150 then
							draw_graphic(pic_small, 274 - jumpy, jumpx - 26) -- facing right
						else
							draw_graphic(pic_small, 274 - jumpy, jumpx - 25, true) -- facing left
						end

						if frame > get("dead") + 300 then
							store("fack")
							if stage == 3 and jumpy <= 80 then  -- rivets on the top girder
								random_play("hesitated")
								store("hesitated")
							elseif read(0x6215, 1) then
								play("stuck_on_ladder")
							else
								if mode1 == 3 and read(0x6228, 1) then
									random_play("lastmandead")
								else
									play("single_fack")
								end
							end
							store("dead")
						end

						if frame < get("fack") + 120 then
							if jumpx <= 150 then
								draw_graphic(pic_fack_l, 345 - jumpy, jumpx - 26)
							else
								draw_graphic(pic_fack_r, 345 - jumpy, jumpx - 86)
							end
						end
					else
						-- Allen faces the right way
						if facing >= 128 then
							draw_graphic(pic_small, 274 - jumpy, jumpx - 24) -- facing right
						else
							draw_graphic(pic_small, 274 - jumpy, jumpx - 23, true)  -- facing left
						end

						-- freezer mode
						if mode2 ~= 22 and frame > get("freezer") + 900 then
							if read(0x63d9, 0) and (read(0x643c) > 0 or read(0x647c) > 0) and math.random(1,3) == 1 then -- not dead & freezer detected
								play("freezer")
							end
							store("freezer")
						end

						-- Thanks to Lukey for his help
						if not lukey and frame <= get("lukey_legend") + 256 then
							draw_graphic(pic_lukey, frame - get("lukey_legend"), 12, false, math.random(0xffaaaaaa, 0xffffffff))
							if frame >= get("lukey_legend") + 256 then lukey = true end
						end
					end

					-- manouevre:  1) avoiding springs or 2) grabbing left hammer on rivets.
					if frame > get("manoeuvre") + 900 then
						if stage == 3 and jumpy <= 80 and jumpx < 128 and facing < 128 and math.random(1,3) == 1 then
							play("manoeuvre")
							store("manoeuvre")
						end

						-- grabbing hammer
						if frame > get("manoeuvre") + 900 and read(0x6218, 1) then
							if stage == 4 and jumpx < 50 and read(0x6210,255) and math.random(1,3) == 1 then
								play("manoeuvre")
							else
								random_play("grab")
							end
							store("manoeuvre")
						end
					end

					 -- Allen's occasional countdown timer
					if frame > get("countdown") + 300 and (read(0x62b1, 9) or read(0x62b1, 4)) and math.random(1, 8) == 1 then
						play("poppop_countdown")
						store("countdown")
					end

					-- If it's been a while since allen said something then we should say something random
					if frame - get("sound") > 900 then
						random_play("ambient")
					end

					-- If ticking over at 1M or KS then it's party time!
					if (score <= 8000 and get("score") > 992000) or (level == 22 and mode2 ~= 22 and mode2 ~= 8) then
						if frame > get("celebrate") + 900 then
							play("celebrate", true)
							store("celebrate")
						end
					end
				end
			end
			if mode1 == 3 and get("celebrate") > 0 and frame < get("celebrate") + 1260 then
				draw_stars()
				write(0x7d86, toggle(read(0x7d86)))
				write(0x7d87, toggle(read(0x7d87)))
				celebrating = true
			else
				celebrating = false
			end

			store("mode1", mode1)
			store("mode2", mode2)
			store("score", score)
		end
	end

	function store(var, val)
		-- store value for given variable.  When val not provided,  store the current frame number
		_val = val or frame
		last[var] = _val
	end

	function get(var)
		-- return the last stored value of given counter
		return last[var] or 0
	end

	function toggle(var)
		if var == 0 then return 1 else return 0 end
	end

	function optimise(line)
		-- optimise horizontal line drawing by grouping like pixels with a pixel count e.g. {("#", 10), ("@", 1)}
		local _list = {}
		local _char, _next
		local _count = 0
		for i=1, #line do
			_char = string.sub(line, i, i)
			_next = string.sub(line, i+1, i+1)
			if _char ~= _next then
				table.insert(_list, {_char, _count})
				_count = 0
			else
				_count = _count + 1
			end
		end
		return _list
	end

	function selection_box(y, x)
		local _col = math.random(0xffaaaaaa, 0xffffffff)
		if mac.paused then _col = 0xffffffff end
		if selected then _col = 0xffff0000 end
		scr:draw_box(y-7,x,y+15,x+2, _col, _col)
		scr:draw_box(y+13,x,y+15,x+79, _col, _col)
		scr:draw_box(y+15,x+79,y-7,x+77, _col, _col)
		scr:draw_box(y-5,x+79,y-7,x, _col, _col)
	end


	function draw_graphic(graphic, pos_y, pos_x, flip, override_color)
		-- draw graphic using palette at given y, x position
		local _data, _pal = graphic[1], graphic[2]
		local _col, _x, _line, _pixel_col

		-- disable optional large graphics when performance is slow
		if (graphic == "pic_fack_l" or graphic == "pic_fack_r" or graphic == "pic_finger") and speed_avg < 0.985 then
			return
		end

		for i, line in ipairs(_data) do
			_line = line
			if flip then
				_line = string.reverse(line)
			end
			_x = 0
			for _, v in ipairs(optimise(_line)) do
				_col = v[1]
				if _col ~= " " then
					_pixel_col = override_color or _pal[_col]
					scr:draw_box(pos_y -i, pos_x + _x, pos_y -i + 1, pos_x + _x + v[2] + 1, _pixel_col, _pixel_col)
				end
				_x = _x + v[2] + 1
			end
		end
	end

	function draw_level_selection()
		draw_graphic(pic_big, 163, 96, true)

		write_ram_message(0x7669, "LEVEL 01")
		write_ram_message(0x778e, "LEVEL 05")
		write_ram_message(0x754e, "LEVEL 12")
		write_ram_message(0x7673, "LEVEL 17")
		write_ram_message(0x771a, "SELECT START LEVEL")
		write_ram_message(0x771c, "  THEN PUSH JUMP  ")
	end

	function change_title()
		write_rom_message(0x36b4,"ALLEN KONG")
		write_rom_message(0x36ce,"HOW HIGH CAN ALLEN GET ? ")

		-- Change logo to "ALLEN" KONG
		local _logo = {
			0x05,0x48,0x77, 0x01,0x28,0x77, 0x01,0x2a,0x77, 0x01,0x08,0x77, 0x01,0x0a,0x77, 0x05,0xe8,0x76,  -- A
			0x05,0xa8,0x76, 0x01,0x8c,0x76, 0x01,0x6c,0x76, 0x01,0x4c,0x76, -- L
			0x05,0x08,0x76, 0x01,0xec,0x75, 0x01,0xcc,0x75, 0x01,0xac,0x75, -- L
			0x05,0x68,0x75, 0x01,0x48,0x75, 0x01,0x4a,0x75, 0x01,0x4c,0x75, 0x01,0x28,0x75, 0x01,0x2a,0x75, 0x01,0x2c,0x75, 0x01,0x08,0x75, 0x01,0x0a,0x75, 0x01,0x0c,0x75, -- E
			0x05,0xc8,0x74, 0x02,0xa9,0x74, 0x02,0x8a,0x74, 0x05,0x68,0x74}  -- N
		for k, v in ipairs(_logo) do
			mem:write_direct_u8(0x3d07+k, v)
		end
	end

	--0xc356c,0xc356d,0xc356e,0xc356f,0xc3570,0xc3571,0xc358e,0xc358f,0xc3590,0xc3591,0xc3592,0xc3593,0xc35b0,0xc35b1,0xc35b2,0xc35b3,0xc35b4,0xc35b5,0xc35d2,0xc35d3,0xc35d4,0xc35d5,0xc35d6,0xc35d7,0xc35f4,0xc35f5,0xc35f6,0xc35f7,0xc35f8,0xc35f9
	function change_scores()
		-- Change player scores and names in ROM.  Each line in the table represents a score entry (0x11m, 0x1c, 0x23 = ALS).
		high_table = {
			0x94, 0x77, 0x01, 0x23, 0x24, 0x10, 0x10, 0x09, 0x09, 0x02, 0x09, 0x00, 0x00, 0x10, 0x10, 0x11, 0x1c, 0x23, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x3F, 0x00, 0x00, 0x29, 0x99, 0xF4, 0x76,
			0x96, 0x77, 0x02, 0x1E, 0x14, 0x10, 0x10, 0x08, 0x05, 0x09, 0x01, 0x00, 0x00, 0x10, 0x10, 0x11, 0x1c, 0x23, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x3F, 0x00, 0x00, 0x91, 0x85, 0xF6, 0x76,
			0x98, 0x77, 0x03, 0x22, 0x14, 0x10, 0x10, 0x07, 0x09, 0x07, 0x00, 0x00, 0x00, 0x10, 0x10, 0x11, 0x1c, 0x23, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x3F, 0x00, 0x00, 0x70, 0x79, 0xF8, 0x76,
			0x9A, 0x77, 0x04, 0x24, 0x18, 0x10, 0x10, 0x07, 0x07, 0x05, 0x01, 0x00, 0x00, 0x10, 0x10, 0x11, 0x1c, 0x23, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x3F, 0x00, 0x00, 0x51, 0x77, 0xFA, 0x76,
			0x9C, 0x77, 0x05, 0x24, 0x18, 0x10, 0x10, 0x07, 0x06, 0x01, 0x00, 0x00, 0x00, 0x10, 0x10, 0x11, 0x1c, 0x23, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x3F, 0x00, 0x00, 0x10, 0x76, 0xFC, 0x76}
		for k, v in ipairs(high_table) do
			mem:write_direct_u8(0x3565 + k - 1, v)
		end

		-- change high score
		mem:write_direct_u32(0x01bf, 0x992900aa)

	end

	function get_score_segment(address)
		local _format = string.format
		return _format("%02d", _format("%x", read(address)))
	end

	function set_score_segment(address, segment)
		write(address, tonumber(segment, 16))
	end

	function read(address, equal_from, to)
		-- return data from memory address, or boolean when equal or to & from values are provided
		_d = mem:read_u8(address)
		if to and equal_from then
			return _d >= equal_from and _d <= to
		elseif equal_from then
			return _d == equal_from
		else
			return _d
		end
	end

	function write(address, value)
		mem:write_u8(address, value)
	end

	function write_rom_message(start_address, text)
		-- write characters of message to DK's ROM
		local _table = char_table
		for key=1, #text do
			mem:write_direct_u8(start_address + (key - 1), _table[string.sub(text, key, key)])
		end
	end

	function write_ram_message(start_address, text)
		local _table = char_table
		-- write characters of message to DK's video ram
		for key=1, #text do
			mem:write_u8(start_address - ((key - 1) * 32), _table[string.sub(text, key, key)])
		end
	end

	function validate_sounds()
		local _path
		local _valid = true
		for _, sound_group in pairs(sounds) do
			for _, sound in pairs(sound_group) do
				_path = "plugins/allenkong/sounds/" .. sound .. ".mp3"
				if not file_exists(_path) then
					print("Error loading sound file: " .. _path )
					_valid = false
				end
			end
		end
		return _valid
	end

	function play(sound, uninterrupted)
		if celebrating and not uninterrupted then
			return
		end
		if is_pi then
			io.popen("pkill aplay &")
			io.popen("aplay -q allenkong/sounds/".._sound..".mp3 &")
		else
			if uninterrupted then
				io.popen("start /B /HIGH taskkill /IM mp3play*.exe /F 2> nul")
				io.popen("start /B /HIGH plugins/allenkong/bin/mp3play0.exe plugins/allenkong/sounds/"..sound..".mp3")
			else
				if get("sound") > 0 then
					io.popen("start /B /HIGH taskkill /IM mp3play" .. tostring(soundplay_index) .. ".exe /F 2> nul")
				end
				if sound == "lukey_legend" then store("lukey_legend") end

				if soundplay_index == 1 then soundplay_index = 2 else soundplay_index = 1 end
				io.popen("start /B /HIGH plugins/allenkong/bin/mp3play".. tostring(soundplay_index) ..".exe plugins/allenkong/sounds/"..sound..".mp3")
			end
		end
		store("sound")
	end

	function random_play(sound_table)
		-- play random clip from a provided table
		play(sounds[sound_table][math.random(1, #sounds[sound_table])])
	end

	function file_exists(filename)
		local file = io.open(filename, "r")
		if (file) then
			-- Obviously close the file if it did successfully open.
			file:close()
			return true
		end
		return false
	end

	function draw_stars()
		-- draw the starfield background
		local _ypos, _xpos, _col

		for key=1, 40, 3 do
			_ypos, _xpos, _col = starfield[key], starfield[key+1], starfield[key+2]

			pic_balloon[2]["a"] = _col
			draw_graphic(pic_balloon, _ypos, _xpos)

			--scroll the starfield during gameplay
			if not mac.paused then
				starfield[key] = starfield[key] - 0.75
				if starfield[key] < 0 then
					starfield[key] = 255
				end
			end
		end

		if frame - get("starfield") > 10 then
			store("starfield")
		end
	end

	emu.register_start(function()
		initialize()
	end)

	emu.register_stop(function()
		random_play("bye")
	end)

	emu.register_frame_done(main, "frame")
end
return exports