-- DK Coach by Jon Wilson (10yard)
--
-- Tested with latest MAME versions 0.235 and 0.196
-- Compatible with MAME versions from 0.196
-- Use P2 to toggle the helpfulness setting between 3 (Max), 2 (Min) and 1 (None)
--
-- Minimum start up arguments:
--   mame dkong -plugin dkcoach

local exports = {}
exports.name = "dkcoach"
exports.version = "0.21"
exports.description = "Donkey Kong Coach"
exports.license = "GNU GPLv3"
exports.author = { name = "Jon Wilson (10yard)" }
local dkcoach = exports

function dkcoach.startplugin()
	local barrel_data = {0x6700, 0x6720, 0x6740, 0x6760, 0x6780, 0x67a0, 0x67c0, 0x67e0}
	local spring_data = {0x6500, 0x6510, 0x6520, 0x6530, 0x6540, 0x6550}

	local message_table = {}
	-- Barrels stage
	message_table["-START HERE"] = 0x7619
	message_table["% WILD %"] = 0x77a5
	message_table["%      %"] = 0x77a5

	-- Springs stage
	message_table["START"] = 0x75ed
	message_table["HERE__"] = 0x75ee
	message_table["'LONG' "] = 0x77a6
	message_table["'SHORT'"] = 0x77a6

	local char_table = {}
	char_table["0"] = 0x00
	char_table["1"] = 0x01
	char_table["2"] = 0x02
	char_table["3"] = 0x03
	char_table["4"] = 0x04
	char_table["5"] = 0x05
	char_table["6"] = 0x06
	char_table["7"] = 0x07
	char_table["8"] = 0x08
	char_table["9"] = 0x09
	char_table[" "] = 0x10
	char_table["A"] = 0x11
	char_table["B"] = 0x12
	char_table["C"] = 0x13
	char_table["D"] = 0x14
	char_table["E"] = 0x15
	char_table["F"] = 0x16
	char_table["G"] = 0x17
	char_table["H"] = 0x18
	char_table["I"] = 0x19
	char_table["J"] = 0x1a
	char_table["K"] = 0x1b
	char_table["L"] = 0x1c
	char_table["M"] = 0x1d
	char_table["N"] = 0x1e
	char_table["O"] = 0x1f
	char_table["P"] = 0x20
	char_table["Q"] = 0x21
	char_table["R"] = 0x22
	char_table["S"] = 0x23
	char_table["T"] = 0x24
	char_table["U"] = 0x25
	char_table["V"] = 0x26
	char_table["W"] = 0x27
	char_table["X"] = 0x28
	char_table["Y"] = 0x29
	char_table["Z"] = 0x2a
	char_table["_"] = 0x2f
	char_table["<"] = 0x30
	char_table[">"] = 0x31
	char_table["="] = 0x34
	char_table["-"] = 0x35
	char_table["!"] = 0x38
	char_table["'"] = 0x3d
	char_table["p"] = 0xdf
	char_table["%"] = 0xfe

	local help_setting_name = {}
	help_setting_name[1] = " NO"
	help_setting_name[2] = "MIN"
	help_setting_name[3] = "MAX"
	local help_setting = 3
	local spring_startx_default = 22
	local spring_starty_default = 224
	local spring_startx_coach = 180
	local spring_starty_coach = 112
	local barrel_startx_default = 63
	local barrel_starty_default = 240
	local barrel_startx_coach = 115
	local barrel_starty_coach = 206

	function initialize()
		last_help_toggle = os.clock()
		mame_version = tonumber(emu.app_version())
		
		data_credits = os.getenv("DATA_CREDITS")
		data_autostart = os.getenv("DATA_AUTOSTART")
		data_allow_skip_intro = os.getenv("DATA_ALLOW_SKIP_INTRO")
		
		if mame_version >= 0.227 then
			cpu = manager.machine.devices[":maincpu"]
			scr = manager.machine.screens[":screen"]
			video = manager.machine.video
			ports = manager.machine.ioport.ports
			mem = cpu.spaces["program"]
		elseif mame_version >= 0.196 then
			cpu = manager:machine().devices[":maincpu"]
			scr = manager:machine().screens[":screen"]
			video = manager:machine():video()
			ports = manager:machine():ioport().ports			
			mem = cpu.spaces["program"]
		else
			print("----------------------------------------------------------")
			print("The dkcoach plugin requires MAME version 0.196 or greater.")
			print("----------------------------------------------------------")
		end
	end

	function main()
		if cpu ~= nil then
			stage, mode1, mode2 = mem:read_i8(0x6227), mem:read_u8(0xc6005), mem:read_u8(0xc600a)

			dkafe_specific_features()
			
			-- overwrite the rom's highscore text with title and display the active help setting.
			write_message(0x76e0, "    DK COACH   TOGGLE")
			write_message(0x7521, help_setting_name[help_setting].." HELP")

			-- check for P2 button press.
			if string.sub(int_to_bin(mem:read_i8(0x7d00)), 5, 5) == "1" then
				if os.clock() - last_help_toggle > 0.25 then
					-- toggle the active help setting
					help_setting = help_setting - 1
					if help_setting < 1 then
						help_setting = 3
					end
					last_help_toggle = os.clock()
				end
			end

			if mode2 == 0xc or mode2 == 0xd or mode2 == 0x16 then
				-- get Jumpman's position and convert to drawing system coordinates (ignoring jump)
				jm_x = mem:read_u8(0x6203)
				jm_y = mem:read_u8(0x6205)
				if mem:read_u8(0x6216) == 0 or ds_x == nil or ds_y == nil then
					ds_x = jm_x - 16
					ds_y = 250 - jm_y
				end

				-- Mark Jumpman's location with a spot and output x, y position to console
				-- version_draw_box(ds_y - 1, ds_x - 1, ds_y + 1, ds_x + 1, 0xffffffff, 0xffffffff)
				-- print(ds_x.."  "..ds_y)

				-- stage specific action during gamplay
				if stage == 1 then
					barrel_coach()
				elseif stage == 3 then
					spring_coach()
				end
			end
		end
	end

    function barrel_coach()
		local wild = false

		if help_setting > 1 and mode2 == 0xc then
			-- Display safe spots
			-- 3rd girder
			draw_zone("safe", 95, 142, 76, 162)

			-- 4th girder
			draw_zone("safe", 125, 130, 105, 150)
			draw_zone("safe", 131, 64, 110, 74)

			-- 5th girder
			draw_zone("safe", 155, 11, 135, 28)

			-- Display barrel steering probability as a percentage
			internal_difficulty = mem:read_u8(0x6380)
			if internal_difficulty >= 4 then
				steering = "75p"
			elseif internal_difficulty >= 2 then
				steering = "50p"
			else
				steering = "25p"
			end
			write_message(0x7784, "BC="..steering)
			version_draw_box(217,52, 224, 55, 0xff000000, 0xff000000)
			version_draw_box(217,48, 224, 49, 0xff000000, 0xff000000)

			-- Detect wild barrels
			for _, address in pairs(barrel_data) do
				local b_status, b_crazy, b_y = mem:read_u8(address), mem:read_u8(address + 1), mem:read_u8(address + 5)
				if b_status ~= 0 and b_crazy == 1 and b_y <= jm_y then
					wild = true
				end
			end

			-- Issue wild barrel warning
			if wild then
				if flash() then
					write_from_table({"% WILD %"})
				else
					write_from_table({"%      %"})
				end
			else
				clear_from_table({"% WILD %"})
			end

			-- display hammer timer
			if mem:read_u8(0x6217) > 0 or mem:read_u8(0x6218) > 0 then
				hammer_duration = (mem:read_u8(0x6394) + (256 * mem:read_u8(0x6395))) / 2
				if hammer_duration >= 200 then
					col = 0xffff0000
				elseif hammer_duration >= 160 then
					col = 0xffffd800
				else
					col = 0xff00ff00
				end
				version_draw_box(0,0, 256 - hammer_duration, 4, col, col)
				version_draw_box(0,220, 256 - hammer_duration, 224, col, col)
			end


			if help_setting == 3 then
				-- Display mostly safe spots
				--2nd girder
				draw_zone("mostlysafe", 62, 74, 43, 96)

				-- 3rd girder
				draw_zone("mostlysafe", 94, 120, 75, 142)

				-- 4th girder
				draw_zone("mostlysafe", 132, 11, 113, 34)

				-- 5th girder
				draw_zone("mostlysafe", 160, 96, 140, 118)

				-- Change Jumpman's start position to focus coaching on DK's Girder.
				if mem:read_u8(0x694c) == barrel_startx_default and mem:read_u8(0x694f) == barrel_starty_default then
					write_from_table({"-START HERE"})
					change_jumpman_position(barrel_startx_coach, barrel_starty_coach)
				elseif mem:read_u8(0x694f) ~= barrel_starty_coach then
					clear_from_table({"-START HERE"})
				end

				-- Show wild barrel crosshair warning
				if wild then
					_ds_x = jm_x - 16
					_ds_y = 250 - jm_y
					draw_zone("crosshair", _ds_y, _ds_x, _ds_y, _ds_x)
				end

				-- Display steering guides
				if ds_x >= 62 and ds_x <= 96 and ds_y <= 62 and ds_y >= 43 then
					--2nd girder
					draw_zone("ladder", 67, 96, 42, 104)
				elseif ds_x >= 72 and ds_x <= 162 and ds_y <= 94 and ds_y >= 75 then
					--3rd girder
					draw_zone("ladder", 103, 64, 72, 72)
					if ds_x >= 120 then
						draw_zone("ladder", 100, 112, 74, 120)
					end
				elseif ds_x >= 80 and ds_x <= 168 and ds_y <= 125 and ds_y >= 105 then
					--4th girder (right)
					draw_zone("ladder", 136, 168, 104, 176)
				elseif ds_x <= 74 and ds_y <= 131 and ds_y >= 111 then
					--4th girder (left)
					draw_zone("ladder", 136, 168, 104, 176)
					draw_zone("ladder", 131, 72, 110, 80)
					if ds_x <= 32 then
						draw_zone("ladder", 128, 32, 112, 40)
					end
				elseif ds_x >= 96 and ds_x <= 184 and ds_y <= 160 and ds_y >= 140 then
					--5th girder (left)
					draw_zone("ladder", 164, 88, 139, 96)
				elseif ds_x >= 192 and ds_x <= 208 and ds_y <= 162 and ds_y >= 146 then
					--5th girder (right)
					draw_zone("ladder", 164, 88, 139, 96)
					draw_zone("ladder", 161, 184, 145, 192)
				end
			end
		else
			clear_from_table({"% WILD %"})
			clear_from_table({"-START HERE"})
		end
		if help_setting <= 2 or mode2 ~= 0xc then
			clear_from_table({"-START HERE"})
			write_message(0x7784, "      ")
			-- Change Jumpman's position back to default if necessary.
			if os.clock() - last_help_toggle < 0.05 then
				if mem:read_u8(0x694c) == barrel_startx_coach and mem:read_u8(0x694f) == barrel_starty_coach then
					change_jumpman_position(barrel_startx_default, barrel_starty_default)
				end
			end
		end
	end

	function spring_coach()
		if help_setting > 1 and mode2 == 0xc then
			-- Reset spring types at start of stage
			if mode2 == 0xb then
				s_type, s_type_trailing = nil, nil
			end
			
			-- Change Jumpman's start position to focus coaching on DK's Girder.
			if mem:read_u8(0x694c) == spring_startx_default and mem:read_u8(0x694f) == spring_starty_default then
				write_from_table({"START", "HERE__"})
				change_jumpman_position(spring_startx_coach, spring_starty_coach)
			else
				if mem:read_u8(0x694f) < spring_starty_coach then
					clear_from_table({"START", "HERE__"})
				end
			end

			if help_setting == 3 then
				-- Draw safe spots.  Box includes a transparent bottom so you can reference jumpman's feet.  Feet need to stay within box to be safe.
				draw_zone("safe", 185, 148, 168, 168)
				draw_zone("safe", 185, 100, 168, 118)
			end

			-- Determine the spring type (0-15) of generated springs
			for _, address in pairs(spring_data) do
				local s_x, s_y = mem:read_u8(address + 3), mem:read_u8(address + 5)
				if s_y == 80 then             -- y start position of new springs is always 80
					if s_x >= 248 then        -- x start position is between 248 and 7
						s_type = s_x - 248
					elseif s_x <= 7 then
						s_type = s_x + 8
					end
				end
				if (s_x >= 130 and s_x < 170 and s_y == 80) or s_type_trailing == nil or mem:read_i8(0x6229) < 4 then
					-- Remember type of the trailing string.
					s_type_trailing = s_type
				end
			end

			if s_type ~= nil then
				-- Update screen with spring info
				write_message(0x77a5, "T="..string.format("%02d", s_type))
				clear_from_table({"'LONG' ","'SHORT'"})
				if s_type >= 13 then
					write_from_table({"'LONG' "})
				elseif s_type <= 5 then
					write_from_table({"'SHORT'"})
				end
				if help_setting == 3 then
					--1st and 2nd bounce boxes use the latest spring type.
					draw_zone("hazard", 183, 20 + s_type, 168, 33 + s_type)
					draw_zone("hazard", 183, 20 + s_type + 50, 168, 33 + s_type + 50)
					--3rd bounce box uses the trailing spring type on levels 4 and above
					draw_zone("hazard", 183, 20 + s_type_trailing + 100, 168, 33 + s_type_trailing + 100)
				end
			end
		else
			write_message(0x77a5, "      ")
			clear_from_table({"'LONG' ","'SHORT'"})
			clear_from_table({"START", "HERE__"})
			-- Change Jumpman's position back to default if necessary.
			if os.clock() - last_help_toggle < 0.05 then
				if mem:read_u8(0x694c) == spring_startx_coach and mem:read_u8(0x694f) == spring_starty_coach then
					change_jumpman_position(spring_startx_default, spring_starty_default)
				end
			end
		end
	end

	function change_jumpman_position(x, y)
		mem:write_u8(0x694c, x)
		mem:write_u8(0x694f, y)
		mem:write_u8(0x6203, x)
		mem:write_u8(0x6205, y)
	end

	function write_message(start_address, text)
		-- write characters of message to DK's video ram
		local _char_table = char_table
		for key=1, string.len(text) do
			mem:write_i8(start_address - ((key - 1) * 32), _char_table[string.sub(text, key, key)])
		end
	end	

	function write_from_table(messages)
		-- load messages from table and display on screen
		local _message_table = message_table
		for _, message in pairs(messages) do
			local address = _message_table[message]
			if address ~= nil then
				write_message(address, message)
			end
		end
	end

	function clear_from_table(messages)
		-- load messages from table and clear from screen
		local _message_table = message_table
		for _, message in pairs(messages) do
			local address = _message_table[message]
			if address ~= nil then
				local _spaces = string.format("%"..string.len(message).."s","")
				write_message(address, _spaces)
			end
		end
	end

	function version_draw_box(y1, x1, y2, x2, c1, c2)
		-- Handle the version specific syntax of draw_box
		if mame_version >= 0.227 then
			scr:draw_box(y1, x1, y2, x2, c1, c2)
		else
			scr:draw_box(y1, x1, y2, x2, c2, c1)
		end
	end

	function draw_zone(type, y1, x1, y2, x2)
		if type == "crosshair" then
			for i = -9, 8 do
				version_draw_box(y1 + 6 + i, x1 + i, y1 + 6 + i + 1, x1 + i + 1,0xccff0000, 0xccff0000)
				version_draw_box(y1 + 6 + i, x1 - i, y1 + 6 + i + 1, x1 - i + 1,0xccff0000, 0xccff0000)
			end
		elseif y1 > ds_y or y2 > ds_y then
			if type == "hazard" then
				version_draw_box(y1, x1, y2, x2, 0xffff0000, 0x66ff0000)
				scr:draw_line(y1, x1, y2, x2, 0xffff0000)
				scr:draw_line(y2, x1, y1, x2, 0xffff0000)
			elseif type == "safe" then
				version_draw_box(y1, x1, y2, x2, 0xff00ff00, 0x00000000)
				version_draw_box(y1, x1, y2 + 3, x2, 0x00000000, 0x6000ff00)
			elseif type == "mostlysafe" then
				version_draw_box(y1, x1, y2, x2, 0xffffd800, 0x00000000)
				version_draw_box(y1, x1, y2 + 3, x2, 0x00000000, 0x60ffd800)
			elseif type == "ladder" then
				if flash() then
					version_draw_box(y1, x1, y2 , x2, 0x0, 0x990000ff)
				else
					version_draw_box(y1, x1, y2 , x2, 0x0, 0x330000ff)
				end
			end
		end
	end

	function flash()
		-- flash in time with 1UP
		return math.fmod(mem:read_u8(0xc601a), 32) <= 16
	end

	function int_to_bin(x)
		-- convert integer to binary
		local ret = ""
		while x~=1 and x~=0 do
			ret = tostring(x%2) .. ret
			x=math.modf(x/2)
		end
		ret = tostring(x)..ret
		return string.format("%08d", ret)
    end

	function max_frameskip(switch)
		if switch == 1 then
			video.throttled = false
			video.throttle_rate = 1000
			video.frameskip = 8
		else
			video.throttled = true
			video.throttle_rate = 1
			video.frameskip = 0
		end
	end

	function dkafe_specific_features()
		-- Optionally set number of coins inserted into the machine
		if data_credits ~= nil then
			if tonumber(data_credits) > 0 and tonumber(data_credits) < 90 then
				mem:write_i8(0x6001, data_credits)
			end
			data_credits = "0"
		end

		-- Optionally start the game by pressing P1 start.
		if data_autostart == "1" then
			ports[":IN2"].fields["1 Player Start"]:set_value(1)
			data_autostart = "0"
		end
		
		-- Optioanlly fast skip through the DK climb scene when jump button is pressed
		if data_allow_skip_intro == "1" then
			if mode1 == 3 then
				if mode2 == 7 then
					if string.sub(int_to_bin(mem:read_i8(0xc7c00)), 4, 4) == "1" then
						max_frameskip(1)
					end
				else
					max_frameskip(0)
				end
			end
		end
	end

	emu.register_start(function()
		initialize()
	end)

	emu.register_frame_done(main, "frame")
end
return exports