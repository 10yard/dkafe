-- DK Lava Panic! by Jon Wilson (10yard)
--
-- Tested with latest MAME versions 0.235 and 0.196
-- Compatible with MAME versions from 0.196
--
-- Minimum start up arguments:
--   mame dkong -plugin dklavapanic
-----------------------------------------------------------------------------------------

local exports = {}
exports.name = "dklavapanic"
exports.version = "0.12"
exports.description = "Donkey Kong Lava Panic!"
exports.license = "GNU GPLv3"
exports.author = { name = "Jon Wilson (10yard)" }
local dklavapanic = exports

function dklavapanic.startplugin()
	local math_floor = math.floor
	local math_fmod = math.fmod
	local math_random = math.random
	local string_sub = string.sub
	local string_len = string.len

	-- Block characters
	local dkblocks = {}
	dkblocks["P"] = "####.#####..#.."
	dkblocks["A"] = "####.#####.##.#"
	dkblocks["N"] = "#..###.######.###..#"
	dkblocks["I"] = "###.#..#..#.###"
	dkblocks["C"] = "####..#..#..###"
	dkblocks["!"] = " # # #   #"

	function initialize()
		mame_version = tonumber(emu.app_version())
		if mame_version >= 0.227 then
			cpu = manager.machine.devices[":maincpu"]
			scr = manager.machine.screens[":screen"]
		elseif mame_version >= 0.196 then
			cpu = manager:machine().devices[":maincpu"]
			scr = manager:machine().screens[":screen"]
		else
			print("--------------------------------------------------------------")
			print("The dklavapanic plugin requires MAME version 0.196 or greater.")
			print("--------------------------------------------------------------")
		end
		if cpu ~= nil then
			mem = cpu.spaces["program"]
			change_text()
		end
	end

	function change_text()
		-- Change high score text in rom to LAVA PANIC
		for k, i in pairs({0x1c,0x11,0x26,0x11,0x10,0x20,0x11,0x1e,0x19,0x13}) do
			mem:write_direct_u8(0x36b4 + k - 1, i)
		end
		-- Change "HOW HIGH CAN YOU GET" text in rom to "Help! LAVA IS RISING UP!!"
		for k, i in pairs({0xdd,0xde,0xdf,0x10,0x1c,0x11,0x26,0x11,0x10,0x19,0x23,0x10,0x22,0x19,0x23,0x19,0x1e,0x17,0x10,0x25,0x20,0x36,0x10}) do
			mem:write_direct_u8(0x36ce + k - 1, i)
		end
	end

	function main()
		if cpu ~= nil then
			mode1 = mem:read_u8(0x6005)  -- 1-attract mode, 2-credits entered waiting to start, 3-when playing game
			mode2 = mem:read_u8(0x600a)  -- Status of note: 7-climb scene, 10-how high, 15-dead, 16-game over
			stage = mem:read_u8(0x6227)  -- 1-girders, 2-pie, 3-elevator, 4-rivets, 5-extra/bonus
			draw_lava()
		end
	end

	function draw_lava()
		-- Before and after gameplay
		---------------------------------------------------------------------------------
		if mode2 == 7 or mode2 == 10 or mode2 == 11 or mode2 == 1 then
			-- recalculate difficulty at start of level or when in attract mode
			local level = mem:read_u8(0x6229)
			if stage == 4 then
				lava_difficulty = math_floor(1.5 * (22 - level))  -- more time for rivets
			elseif stage == 3 then
				lava_difficulty = math_floor(0.75 * (22 - level))  -- less time for elevators
			else
				lava_difficulty = math_floor(1.2 * (22 - level))			
			end
			-- reset lava level
			lava_y = -7
			-- remember default music
			music = mem:read_u8(0x6089)
		elseif mode2 == 21 and lava_y > 15 then
			-- Adjust lava level on high score entry screen to avoid obstruction.
			lava_y = 15
		elseif mode2 == 16 and lava_y > 60 then
			-- Adjust lava level on game over screens to avoid obstruction.
			lava_y = 60
		end

		-- During gameplay
		---------------------------------------------------------------------------------
		if mode1 == 3 or (mode1 == 1 and mode2 >= 2 and mode2 <= 4) then
			-- Draw rising lava
			version_draw_box(0, 0, lava_y, 224, 0xddff0000, 0x0)

			if mode2 == 12 or (mode1 == 1 and mode2 >= 2 and mode2 <= 3) then
				jumpman_y = 264 - mem:read_u8(0x6205)
				if lava_y + 10 > jumpman_y then
					-- Dim the screen above lava flow
					version_draw_box(256, 224, lava_y, 0, 0x44000000, 0x0)

					-- PANIC! text with flashing colour palette for dramatic effect
					if math_fmod(mem:read_u8(0x601a), 32) <= 16 then
						mem:write_u8(0x7d86, 0)
						block_characters("PANIC!", 128, 16, 0xffff0000, 0xffffff99)
					else
						mem:write_u8(0x7d86, 1)
					end

					-- Temporary change music for added drama
					if stage ~= 2 then
						mem:write_u8(0x6089, 9)
					else
						mem:write_u8(0x6089, 11)
					end
				else
					-- Reset palette
					if stage == 1 or stage == 3 then
						mem:write_u8(0x7d86, 0)
					else
						mem:write_u8(0x7d86, 1)
					end
					-- Reset music
					mem:write_u8(0x6089, music)
				end

				if lava_y > jumpman_y + 1 then
					-- The lava has engulfed Jumpman. Set status to dead
					mem:write_u8(0x6200, 0)
				elseif math_fmod((mem:read_u8(0x601A)), lava_difficulty) == 0 then
					-- Game is active.  Lava rises periodically based on the lava_difficulty
					if mem:read_u8(0x6350) == 0 then
						-- Lava shouldn't rise when an item is being smashed by the hammer
						lava_y = lava_y + 1
					end
				end
			end

			-- Add dancing flames above lava
			for _, i in pairs({8, 24, 40, 56, 72, 88, 104, 120, 136, 152, 168, 184, 200, 216}) do
			  	if math_random(3) == 1 then
					local flame_y = lava_y + math_random(-5, 4)
					if flame_y > 0 then
						-- Draw flame graphic
						version_draw_box(flame_y + 1, i - 1, flame_y + 2, i - 2, 0xfff4bA15, 0x0)
						version_draw_box(flame_y + 2, i - 2, flame_y + 3, i - 3, 0xfff4bA15, 0x0)
						version_draw_box(flame_y + 3, i - 1, flame_y + 4, i - 2, 0xfff4bA15, 0x0)
						version_draw_box(flame_y + 4, i - 0, flame_y + 5, i - 1, 0xfff4bA15, 0x0)
						version_draw_box(flame_y + 5, i - 1, flame_y + 6, i - 2, 0xfff4bA15, 0x0)
					end
				end
			end
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

	emu.register_start(function()
		initialize()
	end)

	emu.register_frame_done(main, "frame")

end
return exports