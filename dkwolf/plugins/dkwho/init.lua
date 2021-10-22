-- DK Who and the Daleks by Jon Wilson (10yard)
--
-- Tested with latest MAME version 0.236
-- Compatible with MAME versions from 0.196
--
-- Requires the rom patch for dkongwho from:
--   https://github.com/10yard/dkafe/tree/master/patch
--
-- Minimum start up arguments:
--   mame dkong -plugin dkwho
-----------------------------------------------------------------------------------------

local exports = {}
exports.name = "dkwho"
exports.version = "0.1"
exports.description = "DK Who and the Daleks"
exports.license = "GNU GPLv3"
exports.author = { name = "Jon Wilson (10yard)" }
local dkwho = exports

function dkwho.startplugin()
	local math_floor = math.floor
	local math_fmod = math.fmod
	local math_random = math.random
	local string_sub = string.sub
	local string_len = string.len
	local last_teleport = 0

	-- Colours
	BLACK = 0xff000000
	YELLOW = 0xffffbd2e
	RED = 0xffe8070a
	BLUE = 0xff0402dc
	CYAN = 0xff14f3ff
	BROWN = 0xfff5bca0

	-- Character table
	dkchars = {}
	dkchars["0"] = 0x00
	dkchars["1"] = 0x01
	dkchars["2"] = 0x02
	dkchars["3"] = 0x03
	dkchars["4"] = 0x04
	dkchars["5"] = 0x05
	dkchars["6"] = 0x06
	dkchars["7"] = 0x07
	dkchars["8"] = 0x08
	dkchars["9"] = 0x09
	dkchars[" "] = 0x10
	dkchars["A"] = 0x11
	dkchars["B"] = 0x12
	dkchars["C"] = 0x13
	dkchars["D"] = 0x14
	dkchars["E"] = 0x15
	dkchars["F"] = 0x16
	dkchars["G"] = 0x17
	dkchars["H"] = 0x18
	dkchars["I"] = 0x19
	dkchars["J"] = 0x1a
	dkchars["K"] = 0x1b
	dkchars["L"] = 0x1c
	dkchars["M"] = 0x1d
	dkchars["N"] = 0x1e
	dkchars["O"] = 0x1f
	dkchars["P"] = 0x20
	dkchars["Q"] = 0x21
	dkchars["R"] = 0x22
	dkchars["S"] = 0x23
	dkchars["T"] = 0x24
	dkchars["U"] = 0x25
	dkchars["V"] = 0x26
	dkchars["W"] = 0x27
	dkchars["X"] = 0x28
	dkchars["Y"] = 0x29
	dkchars["Z"] = 0x2a
	dkchars["."] = 0x2b
	dkchars["-"] = 0x2c
	dkchars[":"] = 0x2e
	dkchars["<"] = 0x30
	dkchars[">"] = 0x31
	dkchars["="] = 0x34
	dkchars["$"] = 0x36  -- double exclamations !!
	dkchars["!"] = 0x38
	dkchars["'"] = 0x3a
	dkchars[","] = 0x43
	dkchars["["] = 0x49 -- copyright part 1
	dkchars["]"] = 0x4a -- copyright part 2
	dkchars["("] = 0x4b -- ITC part 1
	dkchars[")"] = 0x4c -- ITC part 2
	dkchars["^"] = 0xb0 -- rivet block
	dkchars["?"] = 0xfb
	dkchars["@"] = 0xff -- extra mario icon

	-- Block characters
	dkblocks = {}
	dkblocks["A"] = "####.#####.##.#"
	dkblocks["B"] = "##.#.###.#.###."
	dkblocks["C"] = "####..#..#..###"
	dkblocks["D"] = "##.# ## ## ###."
	dkblocks["E"] = "####..####..###"
	dkblocks["F"] = "####--####--#--"
	dkblocks["G"] = "#####---#-###--#####"
	dkblocks["H"] = "#.##.#####.##.#"
	dkblocks["I"] = "###.#..#..#.###"
	dkblocks["J"] = "###-#--#--#-##-"
	dkblocks["K"] = "#..##.#.###.#.#.#..#"
	dkblocks["L"] = "#..#..#..#..###"
	dkblocks["M"] = "#...###.###.#.##.#.##.#.#"
	dkblocks["N"] = "#..###.######.###..#"
	dkblocks["O"] = "####.##.##.####"
	dkblocks["P"] = "####.#####..#.."
	dkblocks["Q"] = "####-#--#-#--#-#-##-#####"
	dkblocks["R"] = "####-######-#-#"
	dkblocks["S"] = "####..###..####"
	dkblocks["T"] = "###.#..#..#..#."
	dkblocks["U"] = "#-##-##-##-####"
	dkblocks["V"] = "#-##-##-##-#-#-"
	dkblocks["W"] = "#.#.##.#.##.#.###.###...#"
	dkblocks["X"] = "#-##-#-#-#-##-#"
	dkblocks["Y"] = "#-##-##-#-#--#-"
	dkblocks["Z"] = "####--#--#--#---####"
	dkblocks[" "] = "     "

	function initialize()
		mame_version = tonumber(emu.app_version())
		if mame_version >= 0.227 then
			mac = manager.machine
		elseif mame_version >= 0.196 then
			mac = manager:machine()
		else
			print("ERROR: The dkwho plugin requires MAME version 0.196 or greater.")
		end
		if mac ~= nil then
			scr = mac.screens[":screen"]
			cpu = mac.devices[":maincpu"]
			mem = cpu.spaces["program"]

			--Generate a starfield
			number_of_stars = 400
			starfield={}
			math.randomseed(os.time())
			for _=1, number_of_stars do
				table.insert(starfield, math_random(255))
				table.insert(starfield, math_random(223))
			end
		end
	end

	function main()
		if cpu ~= nil then
			mode1 = mem:read_u8(0x6005)  -- 1-attract mode, 2-credits entered waiting to start, 3-when playing game
			mode2 = mem:read_u8(0x600a)  -- Status of note: 7-climb scene, 10-how high, 15-dead, 16-game over
			stage = mem:read_u8(0x6227)  -- 1-girders, 2-pie, 3-elevator, 4-rivets, 5-extra/bonus
			local _rand = 1
			if mode1 == 1 and mode2 >= 6 and mode2 <= 7 then
				-- Title screen
				version_draw_box(96, 16, 136, 208, BLACK, 0x0)
				version_draw_box(152, 8, 198, 208, BLACK, 0x0)
				block_characters("DK WHO", 191, 16, BLUE, CYAN)
				write_message(0xc766d, "AND THE")
				block_characters("DALEKS", 128, 16, BLUE, CYAN)
				-- Bottom text
				version_draw_box(16, 0, 32, 224, BLACK, 0x0)
				write_message(0xc777e, "DK WHO OF GALLIFREY INC.")

				-- Tardis travelling left/right
				if math.fmod(mem:read_u8(0xc601a), 84) <=42 then
					draw_tardis(56, 40, 56, 40)
				else
					draw_tardis(56, 172, 56, 172)
				end
			end

			-- Display alternative messages on How High screens other than stage 1
			if stage ~= 1 then
				if mode2 == 8 then
					howhigh_prepare = 1
				elseif mode2 == 10 and howhigh_prepare == 1 then
					if stage == 3 then
						write_message(0xc779e, "WARNING - DALEK'S CAN FLY $")
					elseif stage == 2 then
						write_message(0xc779e, "DON'T LOOK AWAY OR BLINK $")
					elseif stage == 4 then
						math.randomseed(os.time())
						_rand = math_random(3)
						if _rand == 1 then
							write_message(0xc777e, "WHERE'S MY             ")
							write_message(0xc777f, "    SONIC SCREWDRIVER ?")
						elseif _rand == 2 then
							write_message(0xc777e, "WE MUST SEARCH FOR K-9 $")
						else
							write_message(0xc77be, "THE MASTER WANTS HIS WATCH $")
						end
					end
					howhigh_prepare = 0
				end
			end

			if (mode1 == 3 and (mode2 == 11 or mode2 == 12 or mode2 == 13 or mode2 == 22)) or (mode1 == 1 and mode2 >= 2 and mode2 <= 4) then
				-- During play or during attact mode (including just before and just after)
				if stage == 1 then
					animate_broken_ship(18, 22, 0)
				elseif stage == 2 then
					animate_broken_ship(122, 110, 1)
					adjust_weeping_angels()
				end

				check_teleports()

				if mem:read_u8(0xc6A18) ~= 0 then
					-- Draw tardis graphics.  The hammer hasn't been used.
					if stage == 1 then        -- Girders
						draw_tardis(55, 165, 148, 14)
					elseif stage == 2 then    -- Pies/Conveyors
						draw_tardis(68, 101, 107, 13)
					elseif stage == 4 then    -- Rivets
						draw_tardis(148, 102, 108, 5)
					end
				else
					if mem:read_u8(0xc6200) ~= 0 then
						-- Switch the palette.  The hammer has been used and jumpman is not dead.
						if stage == 1 then        -- Girders
							mem:write_u8(0xc7d86, 1)
							mem:write_u8(0xc7d87, 0)
						elseif stage == 2 then    -- Pies/Conveyors
							mem:write_u8(0xc7d86, 0)
							mem:write_u8(0xc7d87, 1)
						elseif stage == 4 then    -- Rivets
							mem:write_u8(0xc7d86, 0)
						end
					end
				end
			end
			draw_stars()
		end
	end

	function version_draw_box(y1, x1, y2, x2, c1, c2)
		-- Handle the version specific syntax of draw_box
		if mame_version >= 0.227 then
			scr:draw_box(y1, x1, y2, x2, c2, c1)
		else
			scr:draw_box(y1, x1, y2, x2, c1, c2)
		end
	end

	function write_message(start_address, text)
		-- write characters of message to DK's video ram
	  	local _dkchars = dkchars
  		for key=1, string_len(text) do
			mem:write_u8(start_address - ((key - 1) * 32), _dkchars[string_sub(text, key, key)])
		end
	end

	function block_characters(text, y, x, color1, color2)
		-- Write large characters made up from individual blocks
		local _dkblocks = dkblocks
		local _y, _x, width, blocks = y, x, 0, ""
		for i=1, string_len(text) do
			blocks = _dkblocks[string_sub(text, i, i)]
			width = math_floor(string_len(blocks) / 5)
			for b=1, string_len(blocks) do
				if string_sub(blocks, b, b) == "#" then
					version_draw_box(_y, _x, _y+6, _x+8, color1, 0x0)
					version_draw_box(_y+6, _x, _y+8, _x+8, color2, 0x0)
				end
				if math_fmod(b, width) == 0 then
					_y = _y - 8
					_x = _x - (width - 1) * 8
				else
					_x = _x + 8
				end
			end
			_y = y
			_x = _x + (width * 8) + 8
		end
	end

	function toggle(sync)
  		-- Sync timing with the flashing 1UP (default) or the countdown timer
		local sync = sync or "1UP"
		if sync == "1UP" and math_fmod(mem:read_u8(0xc601a), 32) <= 16 then
			return 1
		elseif sync == "TIMER" and math_fmod(mem:read_u8(0xc638c), 2) == 0 then
			return 1
		else
			return 0
		end
	end

	function check_teleports()
		if stage ~= 3 and mem:read_u8(0xc6218) ~= 0 and os.clock() - last_teleport > 1 then
			-- Jumpman is attempting to grab a hammer
			local jumpman_y = mem:read_i8(0xc6205)  -- Jumpman's Y position			
			if stage == 1 then
				if jumpman_y < 0 then
					update_teleport_ram(36, 100, 113)
				else
					update_teleport_ram(187, 192, -46)
				end
			elseif stage == 2 then
				if jumpman_y < -100 then
					update_teleport_ram(124, 180, -45)
				else
					update_teleport_ram(27, 140, -96)
				end
			elseif stage == 4 then
				if jumpman_y > 100 then
					update_teleport_ram(33, -110, -96)
				else
					update_teleport_ram(126, 106, 120)
				end
			elseif stage == 5 then
				if jumpman_y > -40 then
					update_teleport_ram(90, -78, -65)
				else
					update_teleport_ram(65, -30, -17)
				end
			end
		end
	end

	function update_teleport_ram(update_x, update_y, update_ly)
		-- force 0 to disable the hammer
		mem:write_u8(0xc6217, 0)
		mem:write_u8(0xc6218, 0)
		mem:write_u8(0xc6345, 0)
		mem:write_u8(0xc6350, 0)
		
		-- update position
		mem:write_u8(0xc6203, update_x)   -- Update Jumpman's X position
		mem:write_u8(0xc6205, update_y)   -- Update Jumpman's Y position
		mem:write_u8(0xc620E, update_ly)  -- Update launch Y position to prevent excessive fall

		-- clear all hammers
		mem:write_u8(0xc6A18, 0)    -- top
		mem:write_u8(0xc6680, 0)
		mem:write_u8(0xc6A1C, 0)    -- bottom
		mem:write_u8(0xc6690, 0)

		-- change music after teleporting
		if stage ~= 2 then
			mem:write_u8(0xc6089, 9)
		else
			mem:write_u8(0xc6089, 11)
		end
		
		last_teleport = os.clock()
	end

	function draw_tardis(y1, x1, y2, x2)
		if toggle("TIMER") == 0  then -- sync flashing with bonus timer
			_xpos, _ypos = x1, y1
		else
			_xpos, _ypos = x2, y2
		end
		--box and bottom
		version_draw_box(_ypos, _xpos+1, _ypos+15, _xpos+14, BLUE, 0x0)
		version_draw_box(_ypos, _xpos, _ypos+1, _xpos+15, BLUE, 0x0)
		--windows
		version_draw_box(_ypos+9, _xpos+3, _ypos+12, _xpos+7, YELLOW, BROWN)
		version_draw_box(_ypos+9, _xpos+8, _ypos+12, _xpos+12, YELLOW, BROWN)
		version_draw_box(_ypos+5, _xpos+3, _ypos+8, _xpos+7, BLUE, CYAN)
		version_draw_box(_ypos+5, _xpos+8, _ypos+8, _xpos+12, BLUE, CYAN)
		version_draw_box(_ypos+1, _xpos+3, _ypos+4, _xpos+7, BLUE, CYAN)
		version_draw_box(_ypos+1, _xpos+8, _ypos+4, _xpos+12, BLUE, CYAN)
		-- blinking light
		if toggle() == 1 then
			version_draw_box(_ypos+15, _xpos+7, _ypos+16, _xpos+8, YELLOW, 0x0)
		else
			version_draw_box(_ypos+15, _xpos+7, _ypos+16, _xpos+8, RED, 0x0)
		end
	end

	function draw_stars()
		-- draw the starfield background
		local _starfield = starfield
	  	local _ypos, _xpos = 0, 0
		for key=1, number_of_stars, 2 do
			_ypos, _xpos = _starfield[key], _starfield[key+1]
			scr:draw_line(_ypos, _xpos, _ypos, _xpos, 0xbbffffff)
			
			--slowly scroll the starfield
			_starfield[key], _starfield[key+1] = math_fmod(_ypos + 0.01, 256), math_fmod(_xpos + 0.05,224)
		end
	end

	function animate_broken_ship(x, y, dont_check_lit)
		-- flash flames on the ship when fire is lit
		if dont_check_lit == 1 or mem:read_u8(0xc6348) == 1 then
		local flame_color = RED
			if toggle() == 1 then
				flame_color = YELLOW
			end
			version_draw_box(x, y, x+4, y+4, flame_color, 0x0)
		end
	end

	function adjust_weeping_angels()
		-- adjust Y position of angel sprites by 4 pixels as they are taller than pies
		for _, value in pairs({0xc65a5,0xc65b5,0xc65c5,0xc65d5,0xc65e5,0xc65f5}) do
		_y = mem:read_u8(value)
		if _y == 124 or _y == 204 then
				mem:write_u8(value, _y - 4)
			end
		end
	end

	emu.register_start(function()
		initialize()
	end)

	emu.register_frame_done(main, "frame")

end
return exports