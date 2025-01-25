-- Wobble Kong is Vector Kong with an adjustment to the vector function
-- It introduces randomness by +/- 1 pixel to all vector co-ordinates.
-- Girders are output twice to make them appear thicker
-----------------------------------------------------------------------------------------
-- Copied from
-- Vector Kong by Jon Wilson (10yard)
-- This plugin replaces DK pixel graphics with high resolution vectors
--
-- Tested with MAME version 0.241
-- Compatible with MAME versions from 0.196
-----------------------------------------------------------------------------------------

local exports = {}
exports.name = "wobblekong"
exports.version = "0.1"
exports.description = "Wobble Kong"
exports.license = "GNU GPLv3"
exports.author = { name = "Jon Wilson (10yard)" }
local wobblekong = exports

function wobblekong.startplugin()
	local mame_version
	local vector_count, vector_color
	local game_mode, last_mode, zigzags
	local vector_lib = {}
	local barrel_state = {}

	-- Constants
	local MODE, STAGE, LEVEL = 0x600a, 0x6227, 0x6229
	local VRAM_TR, VRAM_BL = 0x7440, 0x77bf  -- top-right and bottom-left bytes of video ram
	local BLK, WHT, YEL, RED, BLU, MBR = 0xff000000, 0xffffffff, 0xfff0f050, 0xfff00000, 0xff0000f0, 0xe0f27713 -- color
	local BRN, MAG, PNK, LBR, CYN, GRY = 0xffD60609, 0xfff057e8, 0xffffd1dc, 0xfff4b98b, 0xff14f3ff, 0xffb0b0b0
	local STACKED_BARRELS = {{173,0},{173,10},{189,0},{189,10}}
	local BARRELS = {0x6700,0x6720,0x6740,0x6760,0x6780,0x67a0,0x67c0,0x67e0,0x6800,0x6820}
	local FIREBALLS = {0x6400, 0x6420, 0x6440, 0x6460, 0x6480}
	local BR = 0xffff  -- instruction to break in a vector chain

	local characters = "0123456789       ABCDEFGHIJKLMNOPQRSTUVWXYZ@-"

	function initialize()
		if emu.romname() == "dkong" then
			mame_version = tonumber(emu.app_version())
			if  mame_version >= 0.196 then
				if type(manager.machine) == "userdata" then
					mac = manager.machine
					bnk = mac.memory
				else
					mac = manager:machine()
					bnk = mac:memory()
				end
			else
				print("ERROR: The wobblekong plugin requires MAME version 0.196 or greater.")
			end
		end
		if mac ~= nil then
			scr = mac.screens[":screen"]
			cpu = mac.devices[":maincpu"]
			mem = cpu.spaces["program"]
			clear_graphic_banks()
			mem:write_direct_u32(0x01ea, 0x0000063e) -- force game to start on the title screen
			mem:write_direct_u16(0x07d3, 0xff3e)     -- increase timer for title screen
			
			-- ROM modifications
			write_rom_message(0x36b4, "WOBBLEKONG")		
		end
		vector_lib = load_vector_library()
		zigzags = false
	end

	function main()
		if cpu ~= nil then
			vector_count = 0
			vector_color = WHT
			game_mode = read(MODE)

			if read(VRAM_BL, 0xf0) then draw_girder_stage() end
			--if read(VRAM_BL, 0xb0) then draw_rivet_stage() end
			mode_specific_changes()
			draw_vector_characters()

			--debug_limits(3000)
			--debug_vector_count()
			last_mode = game_mode
		end
	end

	---- Draw stage backgrounds
	---------------------------
	function draw_girder_stage()
		local _growling = game_mode == 0x16 and read(0x6388) >= 4

		-- 1st girder
		draw_girder(1, 0, 1, 111, "R")  -- flat section
		draw_girder(1, 111, 8, 223, "L")  -- sloped section
		draw_ladder(8, 80, 8) -- broken ladder bottom
		draw_ladder(32, 80, 4) -- broken ladder top
		draw_ladder(13, 184, 17) -- right ladder
		draw_oilcan_and_flames(8, 16)
		-- 2nd Girder
		draw_girder(41, 0, 29, 207)
		draw_ladder(46, 32, 17)  -- left ladder
		draw_ladder(42, 96, 25)  -- right ladder
		-- 3rd Girder
		draw_girder(62, 16, 74, 223)
		draw_ladder(72, 64, 9)  -- broken ladder bottom
		draw_ladder(96, 64, 7)  -- broken ladder top
		draw_ladder(75, 112, 25)  -- middle ladder
		draw_ladder(79, 184, 17)  -- right ladder
		-- 4th Girder
		draw_girder(107, 0, 95, 207)
		draw_ladder(112, 32, 17)  -- left ladder
		draw_ladder(110, 72, 21)  -- middle ladder
		draw_ladder(104, 168, 9)  -- broken ladder bottom
		draw_ladder(128, 168, 9)  -- broken ladder top
		-- 5th girder
		draw_girder(128, 16, 140, 223)
		draw_ladder(139, 88, 13)  -- broken ladder bottom
		draw_ladder(160, 88, 5)  -- broken ladder top
		draw_ladder(145, 184, 17)  -- right ladder
		-- 6th girder
		draw_girder(165, 0, 165, 143, "R")  -- flat section
		draw_girder(165, 143, 161, 207, "L")  -- sloped section
		draw_ladder(172, 64, 52)  -- left ladder
		draw_ladder(172, 80, 52)  -- middle ladder
		draw_ladder(172, 128, 21)  -- right ladder
		draw_stacked_barrels()
		-- Pauline's girder
		draw_girder(193, 88, 193, 136, "L")
		draw_pauline(90)
		draw_loveheart()

		-- Other sprites
		draw_kong(172, 24, _growling)
		draw_hammers(56,168,148,17)
		draw_jumpman()
		draw_barrels()
		draw_fireballs()
		draw_points()
	end

	--function draw_rivet_stage()
	--	-- Work in progress
	--	vector_lib[0xb0] = {BR,GRY,3,2,3,4,4,4,4,2,3,2}  -- update basic block
	--	zigzags = false
	--
	--	-- 1st floor
	--	draw_girder(1, 0, 1, 223)
	--	draw_ladder(8, 8, 33) -- left ladder
	--	draw_ladder(8, 104, 33) -- middle ladder
	--	draw_ladder(8, 208, 33) -- right ladder
	--	-- 2nd floor
	--	draw_girder(41, 8, 41, 56)
	--	draw_girder(41, 64, 41, 160)
	--	draw_girder(41, 168, 41, 216)
	--	draw_ladder(48, 16, 33) -- ladder 1
	--	draw_ladder(48, 72, 33) -- ladder 2
	--	draw_ladder(48, 144, 33) -- ladder 3
	--	draw_ladder(48, 200, 33) -- ladder 4
	--	-- 3rd floor
	--	draw_girder(81, 16, 81, 56)
	--	draw_girder(81, 64, 81, 160)
	--	draw_girder(81, 168, 81, 208)
	--	draw_ladder(88, 24, 33) -- left ladder
	--	draw_ladder(88, 104, 33) -- middle ladder
	--	draw_ladder(88, 192, 33) -- right ladder
	--	-- 4th floor
	--	draw_girder(121, 24, 121, 56)
	--	draw_girder(121, 64, 121, 160)
	--	draw_girder(121, 168, 121, 200)
	--	draw_ladder(128, 32, 33) -- ladder 1
	--	draw_ladder(128, 64, 33) -- ladder 2
	--	draw_ladder(128, 152, 33) -- ladder 3
	--	draw_ladder(128, 184, 33) -- ladder 4
	--	-- 5th floor
	--	draw_girder(161, 32, 161, 56)
	--	draw_girder(161, 64, 161, 160)
	--	draw_girder(161, 168, 161, 192)
	--	-- Pauline's floor
	--	draw_girder(201, 56, 201, 168)
	--	draw_pauline(104)
	--	draw_loveheart()
	--	-- Sprites
	--	draw_hammers(149,105,108,8)
	--	draw_kong(168, 92)
	--	draw_jumpman()
	--	draw_fireballs()
	--	draw_points()
	--end

	function mode_specific_changes()
		local _y, _x
		if game_mode == 0x06 and last_mode == 0x06 then
			-- display a growling Kong on the title screen
			draw_kong(48, 92, true)
			-- show vector logo and "vectorised by 10yard" in the footer
			draw_object("logo", 128, 16,  0xff444444 + math.random(0xbbbbbb))
			for _k, _v in ipairs({0x26,0x15,0x13,0x24,0x1f,0x22,0x19,0x23,0x15,0x14,0x10,0x12,0x29,0x10,0x01,0x00,0x29,0x11,0x22,0x14}) do
				draw_object(_v, 8, _k*8+25, GRY)
			end
			-- restore the game startup logic
			if mem:read_direct_u32(0x01ea) ~= 0xaf622732 then
				mem:write_direct_u32(0x01ea, 0xaf622732)
			end
		elseif game_mode == 0x07 then
			-- skip the DK climbing/intro scene
			write(MODE, 0x08)
		elseif game_mode == 0x08 and last_mode == 0x16 then
			-- stay on the girders stage
			write(STAGE, 1)
			write(LEVEL, read(LEVEL) + 1)
		elseif game_mode == 0x10 then
			-- emphasise the game over message
			scr:draw_box(64, 64, 88, 160, BLK, BLK)
		elseif game_mode == 0x15 then
			-- highlight selected character during name registration
			_y, _x = math.floor(read(0x6035) / 10) * -16 + 156, read(0x6035) % 10 * 16 + 36
			draw_object("select", _y, _x, CYN)
		elseif game_mode == 0xa then
			-- display multiple kongs on the how high can you get screen
			_y, _x = 24, 92
			for _=1, mem:read_u8(0x622e) do
				draw_kong(_y, _x)
				_y = _y + 32
			end
		end
	end

	---- Basic vector drawing functions
	-----------------------------------
	
	function vector(y1, x1, y2, x2)
		-- draw a single vector
		local _adjust = ({vector_color, vector_color, vector_color, 0xaaffffff, 0xffffffff})[math.random(5)]
		local _width = ({0,0,0,0,0,1,1,1,1,2})[math.random(10)]
		scr:draw_line(y1 + _width ,x1 + _width, y2 + _width, x2 + _width, _adjust)
		vector_count = vector_count + 1
	end

	function polyline(data, offset_y, offset_x, flip_x, flip_y)
		-- draw multiple chained lines from a table of y,x points.  Optional offset for start y,x.
		local _offy, _offx = offset_y or 0, offset_x or 0
		local _savey, _savex, _datay, _datax
		if data then
			for _i=1, #data, 2 do
				_datay, _datax = data[_i], data[_i+1]
				if _savey and _savey ~= BR and _datay ~= BR then
					if flip_y and flip_y > 0 then
						vector(flip_y-_datay+_offy, _datax+_offx, flip_y-_savey+_offy, _savex+_offx)
					elseif flip_x and flip_x > 0 then
						vector(_datay+_offy, flip_x-_datax+_offx, _savey+_offy, flip_x-_savex+_offx)
					else
						vector(_datay+_offy, _datax+_offx, _savey+_offy, _savex+_offx)
					end
				else
					-- break in the vector chain and maybe change colour
					if _datax > 0x00ffffff then vector_color = _datax end
				end
				_savey, _savex = _datay, _datax
			end
		end
	end

	function box(y, x, h, w)
		-- draw a simple box at given position with height and width
		polyline({y,x,y+h,x,y+h,x+w,y,x+w,y,x})
	end

	function circle(y, x, r, color)
		-- draw a segmented circle at given position with radius
		local _save_segy, _save_segx
		vector_color = color or vector_color
		for _segment=0, 360, 24 do
			local _angle = _segment * (math.pi / 180)
			local _segy, _segx = y + r * math.sin(_angle), x + r * math.cos(_angle)
			if _save_segy then vector(_save_segy, _save_segx, _segy, _segx) end
			_save_segy, _save_segx = _segy, _segx
		end
		vector_color = WHT
	end

	function draw_vector_characters()
		-- Output vector characters based on contents of video ram ($7400-77ff)
		local _addr = VRAM_TR
		for _x=223, 0, -8 do
			for _y=255, 0, -8 do
				if _y == 255 then
					draw_object(mem:read_u8(_addr), _y - 6, _x - 6, RED)
				else
					draw_object(mem:read_u8(_addr), _y - 6, _x - 6)
				end
				_addr = _addr + 1
			end
		end
	end

	function draw_object(name, y, x, color, flip_x, flip_y)
		-- draw object from the vector library
		vector_color = color or vector_color
		polyline(vector_lib[name], y, x, flip_x, flip_y)
		vector_color = WHT
	end

	---- Draw game objects
	----------------------
	function draw_ladder(y, x, h)
		-- draw a single ladder at given y, x position of given height in pixels
		polyline({0,0,h,0,BR,BR,0,8,h,8},y,x)  -- left and right legs
		for i=0, h-2 do  -- draw rung every 4th pixel (skipping 2 pixels at bottom)
			if i % 4 == 0 then vector(y+i+2, x, y+i+2, x+8) end
		end
	end

	function draw_girder(y1, x1, y2, x2, open)
		-- draw girder at given y,x position.  Girders are based on parallel vectors (offset by 7 pixels).
		for _=1, 2 do
			polyline({y1,x1,y2,x2,BR,BR,y1+7,x1,y2+7,x2})
			if not open or open ~= "L" then	polyline({y1,x1,y1+7,x1}) end  -- close the girder ends
			if not open or open ~= "R" then polyline({y2,x2,y2+7,x2}) end
			if zigzags then
				for _x=x1, x2 - 1, 16 do  -- Fill the girders with zig zags
					draw_object("zigzag", y1 + (((y2 - y1) / (x2 - x1)) * (_x - x1)), _x, GRY)
				end
			end
		end
	end

	function draw_stacked_barrels()
		for _, _v in ipairs(STACKED_BARRELS) do
			draw_object("stacked", _v[1], _v[2], LBR)
		end
	end

	function draw_hammers(hammer1_y, hammer1_x, hammer2_y, hammer2_x)
		if read(0x6a1c) > 0 and read(0x6691, 0) then draw_object("hammer-up", hammer1_y, hammer1_x, MBR) end
		if read(0x6a18) > 0 and read(0x6681, 0) then draw_object("hammer-up", hammer2_y, hammer2_x, MBR) end
	end

	function draw_oilcan_and_flames(y, x)
		draw_object("oilcan",  y, x)
		if read(0x6a29, 0x40, 0x43) then  -- oilcan is on fire
			draw_object("flames", y+16, x, YEL)  -- draw base of flames
			draw_object("flames", y+16+math.random(0,3), x, RED) -- draw flames extending upwards
		end
	end

	---- Sprites
	------------
	function draw_barrels()
		local _y, _x, _type, _state
		for _, _addr in ipairs(BARRELS) do
			if read(_addr) == 1 and read(0x6200, 1) and read(_addr+3) > 0 then  -- barrel active and Jumpman alive
				_y, _x = 251 - read(_addr+5), read(_addr+3) - 20
				_type = read(_addr+0x15) + 1 -- type of barrel: 1 is normal, 2 is blue/skull

				if read(_addr+1, 1) or bits(read(_addr+2))[1] == 1 then -- barrel is crazy or going down a ladder
					_state = read(_addr+0xf)
					draw_object("down", _y, _x-2, ({LBR, CYN})[_type])
					draw_object("down-"..tostring(_state % 2 + 1), _y, _x - 2, ({MBR, BLU})[_type])
				else  -- barrel is rolling
					_state = barrel_state[_addr] or 0
					if scr:frame_number() % 10 == 0 then
						if read(_addr+2, 2) then _state = _state - 1 else _state = _state+1 end -- roll left or right?
						barrel_state[_addr] = _state
					end
					draw_object("rolling", _y, _x, ({LBR, CYN})[_type])
					draw_object(({"roll-", "skull-"})[_type]..tostring(_state % 4 + 1), _y, _x,({MBR, BLU})[_type])
				end
			end
		end
	end

	function draw_fireballs()
		local _y, _x, _flip

		fireball_color = YEL
		flame_color = RED
		if read(0x6217) == 1 then
			fireball_color = BLU
			flame_color = CYN
		end

		for _, _addr in ipairs(FIREBALLS) do
			if read(_addr, 1) then  -- fireball is active
				_y, _x = 247 - read(_addr+5), read(_addr+3) - 22
				if read(_addr+0xd, 1) then _flip = 13 end  -- fireball moving right so flip the vectors
				draw_object("fireball", _y, _x, fireball_color, _flip) -- draw body
				draw_object("fb-flame", _y+math.random(0,3), _x, flame_color, _flip) -- draw flames extending upwards
			end
		end
	end

	function draw_pauline(x)
		local _y = 235 - read(0x6903)
		if read(0x6905) ~= 17 and read(0x6a20, 0) then _y = _y + 3 end  -- Pauline jumps when heart not showing
		draw_object("pauline", _y, x, MAG)
	end

	function draw_loveheart()
		_y, _x = 250 - read(0x6a23), read(0x6a20) - 23
		if _x > 0 then draw_object(read(0x6a21) + 0xf00, _y, _x, MAG) end
	end

	function draw_jumpman()
		local _y, _x = 255 - read(0x6205), read(0x6203) - 15
		local _sprite = read(0x694d)
		local _sprite_mod = _sprite % 128
		local _smash_offset = 9
		local _grab

		if _y < 255 then
			if vector_lib["jm-"..tostring(_sprite_mod)] then
				-- right facing sprites are mirrored.
				-- < 128 are left facing sprites
				-- (0,1,2) = walking, (3,4,5,6) = climbing, (8,9,10,11,12,13) = hammer smashing,
				-- (14,15) = jumping, (120,121,122) = dead

				_grab = read(0x6218, 1)
				if _grab then -- grabbing hammer
					if _sprite < 128 then _sprite = 10 else _sprite = 138 end  -- change default sprite to a hammer grab
				end

				-- Display one of Jumpman's various sprites
				if _sprite < 128 then
					draw_object("jm-"..tostring(_sprite), _y-7, _x-7, CYN)
				elseif _sprite == 248 then
					draw_object("jm-"..tostring(_sprite-128), _y, _x-7, CYN, nil, 8)  -- flip y
				else
					draw_object("jm-"..tostring(_sprite-128), _y-7, _x, CYN, 8)  -- flip x
				end

				-- Add the hammer?
				if _grab then -- grabbing hammer
					draw_object("hammer-up", _y+9, _x-3, MBR)
				elseif _sprite_mod >= 8 and _sprite_mod <= 13 then  -- using hammer
					if _sprite == 8 or _sprite == 10 then
						draw_object("hammer-up", _y+9, _x-3, MBR)
					elseif _sprite == 12 or _sprite == 140 then
						draw_object("hammer-up", _y+9, _x-4, MBR)
					elseif _sprite == 136 or _sprite == 138 then
						draw_object("hammer-up", _y+9, _x-5, MBR)
					elseif _sprite == 9 or _sprite == 11 or _sprite == 13 then
						draw_object("hammer-down", _y-4, _x-16, MBR)
						_smash_offset = -4
					elseif _sprite == 137 or _sprite == 139 or _sprite == 141 then
						draw_object("hammer-down", _y-4, _x+13, MBR, 4)
						_smash_offset = -4
					end
				end

				-- Add smashed item?
				_sprite = read(0x6a2d)
				if read(0x6a2c) > 0 and _sprite >= 0x60 and _sprite <= 0x63 then
					-- v0.14 - prefer growing circle effect to the sprites
					circle(_y+_smash_offset+4, read(0x6a2c) - 13, (_sprite - 95) * 5, 0xff444444 + math.random(0xbbbbbb))
					--draw_object(0xf00 + _sprite, _y+_smash_offset, read(0x6a2c) - 17, BLU)
				end
			end
		end
	end

	function draw_kong(y, x, growl)
		local _state = read(0x691d) -- state of kong - is he deploying a barrel?
		local _data = {"roll-1", LBR, MBR} -- default barrel data
		if read(0x6a20, 0) and (_state == 173 or _state == 45 or _state == 42) then
			if read(0x6382,0x80,0x81) then _data = {"skull-1",CYN,BLU} end  -- blue barrel, not the default data
			-- Kong deploying a barrel
			if _state == 173 then
				-- Releasing barrel to right
				draw_object("dk-side", y, x+1, BRN)
				draw_object("rolling", y, x+44, _data[2])
				draw_object(_data[1], y, x+44, _data[3])
			elseif _state == 45 then
				-- Grabbing barrel from left (mirrored)
				draw_object("dk-side", y, x-3, BRN, 42)
				draw_object("rolling", y, x-15, _data[2])
				draw_object(_data[1], y, x-15, _data[3])
			elseif _state == 42 then
				-- Holding barrel in front
				draw_object("dk-hold", y, x, BRN)  -- left side
				draw_object("dk-hold", y, x+20, BRN, 20) -- mirrored right side
				draw_object("down", y+2, x+12.4, _data[2])
				draw_object("down-1", y+2, x+12.4, _data[3])
			end
		else
			-- Default front facing Kong
			draw_object("dk-front", y, x, BRN)  -- left side
			draw_object("dk-front", y, x+20, BRN, 20) -- mirrored right side
			if growl then
				draw_object("dk-growl", y, x, MBR)  --left side
				draw_object("dk-growl", y, x+20, MBR,20)  -- mirrored right side
			end
		end
	end

	function draw_points()
		-- draw 100, 300, 500 or 800 when points awarded
		if read(0x6a30) > 0 then
			_y, _x = 254 - read(0x6a33), read(0x6a30) - 22
			draw_object(read(0x6a31) + 0xf00, _y+3, _x, YEL)  -- move points up a little so they don't overlap as much
		end
	end

	---- General functions
	----------------------
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

	function bits(num)
		--return a table of bits, least significant first
		local _t={}
		while num>0 do
			rest=math.fmod(num,2)
			_t[#_t+1]=rest
			num=(num-rest)/2
		end
		return _t
	end

	---- Debugging functions
	------------------------
	function debug_vector_count()
		if scr:frame_number() % 60 == 0 then
			mac:popmessage(tostring(vector_count).." vectors")
		end
	end

	function debug_limits(limit)
		local _rnd, _ins = math.random, table.insert
		local _cycle = math.floor(scr:frame_number() % 540 / 180)  -- cycle through the 3 tests, each 3 seconds long
		vector_color = 0x44ffffff
		if _cycle == 0 then
			for _=1, limit do vector(256, 224, _rnd(248), _rnd(224)) end  -- single vectors
		elseif _cycle == 1 then
			_d={}; for _=0,limit do _ins(_d,_rnd(256)); _ins(_d,_rnd(224)) end; polyline(_d)  -- polylines
		else
			for _=1, limit / 4 do box(_rnd(216), _rnd(200), _rnd(32)+8, _rnd(24)+8) end  -- boxes
		end
		vector_color = WHT
	end

	---- Graphics memory
	--------------------
	function clear_graphic_banks()
		-- clear the contents of the DK graphics banks 1 and 2
		local _bank1, _bank2 = bnk.regions[":gfx1"], bnk.regions[":gfx2"]
		if _bank1 and _bank2 then
			for _addr=0, 0xfff do _bank1:write_u8(_addr, 0) end
			for _addr=0, 0x1fff do _bank2:write_u8(_addr, 0) end
		end
	end

	---- Vector library
	--------------------
	function load_vector_library()
		local _lib = {}
		_lib[0x00] = {0,2,0,4,2,6,4,6,6,4,6,2,4,0,2,0,0,2} -- 0
		_lib[0x01] = {0,0,0,6,BR,BR,0,3,6,3,5, 1} -- 1
		_lib[0x02] = {0,6,0,0,5,6,6,3,5,0} -- 2
		_lib[0x03] = {1,0,0,1,0,5,1,6,2,6,3,5,3,2,6,6,6,1} -- 3
		_lib[0x04] = {0,5,6,5,2,0,2,7} -- 4
		_lib[0x05] = {1,0,0,1,0,5,2,6,4,5,4,0,6,0,6,5} -- 5
		_lib[0x06] = {3,0,1,0,0,1,0,5,1,6,2,6,3,5,3,0,6,2,6,5} -- 6
		_lib[0x07] = {6,0,6,6,0,2} -- 7
		_lib[0x08] = {2,0,0,1,0,5,2,6,5,0,6,1,6,4,5,5,2,0} -- 8
		_lib[0x09] = {0,1,0,4,2,6,5,6,6,5,6,1,5,0,4,0,3,1,3,6} -- 9
		_lib[0x10] = {} -- space
		_lib[0x11] = {0,0,4,0,6,3,4,6,0,6,BR,BR,2,6,2,0}  -- A
		_lib[0x12] = {0,0,6,0,6,5,5,6,4,6,3,5,2,6,1,6,0,5,0,0,BR,BR,3,0,3,5}  -- B
		_lib[0x13] = {1,6,0,5,0,2,2,0,4,0,6,2,6,5,5,6} -- C
		_lib[0x14] = {0,0,6,0,6,4,4,6,2,6,0,4,0,0} -- D
		_lib[0x15] = {0,5,0,0,6,0,6,5,BR,BR,3,0,3,4} -- E
		_lib[0x16] = {0,0,6,0,6,6,BR,BR,3,0,3,5} -- F
		_lib[0x17] = {3,4,3,6,0,6,0,2,2,0,4,0,6,2,6,6} -- G
		_lib[0x18] = {0,0,6,0,BR,BR,3,0,3,6,BR,BR,0,6,6,6} -- H
		_lib[0x19] = {0,0,0,6,BR,BR,0,3,6,3,BR,BR,6,0,6,6} -- I
		_lib[0x1a] = {1,0,0,1,0,5,1,6,6,6} -- J
		_lib[0x1b] = {0,0,6,0,BR,BR,3,0,0,6,BR,BR,3,0,6,6} -- K
		_lib[0x1c] = {6,0,0,0,0,5} -- L
		_lib[0x1d] = {0,0,6,0,2,3,6,6,0,6}  -- M
		_lib[0x1e] = {0,0,6,0,0,6,6,6} -- N
		_lib[0x1f] = {1,0,5,0,6,1,6,5,5,6,1,6,0,5,0,1,1,0} -- O
		_lib[0x20] = {0,0,6,0,6,5,5,6,3,6,2,5,2,0} -- P
		_lib[0x21] = {1,0,5,0,6,1,6,5,5,6,2,6,0,4,0,1,1,0,BR,BR,0,6,2,3} -- Q
		_lib[0x22] = {0,0,6,0,6,5,5,6,4,6,2,3,2,0,2,3,0,6} -- R
		_lib[0x23] = {1,0,0,1,0,5,1,6,2,6,4,0,5,0,6,1,6,4,5,5} -- S
		_lib[0x24] = {6,0,6,6,BR,BR,6,3,0,3} -- T
		_lib[0x25] = {6,0,1,0,0,1,0,5,1,6,6,6} -- U
		_lib[0x26] = {6,0,3,0,0,3,3,6,6,6} -- V
		_lib[0x27] = {6,0,2,0,0,1,4,3,0,5,2,6,6,6}  -- W
		_lib[0x28] = {0,0,6,6,3,3,6,0,0,6} -- X
		_lib[0x29] = {6,0,3,3,6,6,BR,BR,3,3,0,3} -- Y
		_lib[0x2a] = {6,0,6,6,0,0,0,6} -- Z
		_lib[0x2b] = {0,0,1,0,1,1,0,1,0,0}  -- dot
		_lib[0x2c] = {3,0,3,5} -- dash
		_lib[0x2d] = {5,0,5,6} -- underscore
		_lib[0x2e] = {4,3,4,3,BR,BR,2,3,2,3} -- colon
		_lib[0x2f] = {5,0,5,6} -- Alt underscore
		_lib[0x30] = {0,2,2,0,4,0,6,2} -- Left bracket
		_lib[0x31] = {0,2,2,4,4,4,6,2} -- Right bracket
		_lib[0x32] = {0,0,0,4,BR,BR,6,0,6,4,BR,BR,0,2,6,2} -- I
		_lib[0x33] = {0,-1,0,6,BR,BR,6,-1,6,6,BR,BR,0,1,6,1,BR,BR,0,4,6,4} -- II
		_lib[0x34] = {2,0,2,5,BR,BR,4,0,4,5} -- equals
		_lib[0x35] = {3,0,3,5} -- dash
		_lib[0x39] = {0,0,7,0,7,7,0,7,0,0} -- smash
		_lib[0x44] = {0,5,4,5,4,7,2,7,0,8,BR,BR,2,5,2,7,BR,BR,4,10,1,10,0,11,0,12,1,13,4,13,BR,BR,0,15,4,15,4,17,2,17,2,18,0,18,0,15,BR,BR,2,15,2,17,BR,BR,0,23,0,21,4,21,4,23,BR,BR,2,21,2,22,BR,BR,0,25,4,25,0,28,4,28,BR,BR,0,30,4,30,4,32,3,33,1,33,0,32,0,30} -- rub / end
		_lib[0x49] = {0,4,2,2,5,2,7,4,7,8,5,10,2,10,0,8,0,4,BR,BR,2,7,2,5,5,5,5,7} -- copyright
		_lib[0x6c] = {2,0,2,4,3,5,4,4,5,5,6,4,6,0,2,0,BR,BR,4,4,4,0,BR,BR,3,7,2,8,2,11,3,12,5,12,6,11,6,8,5,7,3,7,BR,BR,2,14,6,14,2,19,6,19,BR,BR,6,21,3,21,2,22,2,25,3,26,6,26,BR,BR,2,28,2,31,4,31,4,28,5,28,6,29,6,31,BR,BR,6,-2,6,-5,-12,-5,-12,36,6,36,6,33,BR,BR,0,-3,-10,-3,-10,34,0,34,0,-3} -- bonus
		_lib[0x70] = {BR,RED,0,2,0,4,2,6,4,6,6,4,6,2,4,0,2,0,0,2} -- Alternative 0-9 coloured red
		_lib[0x71] = {BR,RED,0,0,0,6,BR,BR,0,3,6,3,5, 1}
		_lib[0x72] = {BR,RED,0,6,0,0,5,6,6,3,5,0}
		_lib[0x73] = {BR,RED,1,0,0,1,0,5,1,6,2,6,3,5,3,2,6,6,6,1}
		_lib[0x74] = {BR,RED,0,5,6,5,2,0,2,7}
		_lib[0x75] = {BR,RED,1,0,0,1,0,5,2,6,4,5,4,0,6,0,6,5}
		_lib[0x76] = {BR,RED,3,0,1,0,0,1,0,5,1,6,2,6,3,5,3,0,6,2,6,5}
		_lib[0x77] = {BR,RED,6,0,6,6,0,2}
		_lib[0x78] = {BR,RED,2,0,0,1,0,5,2,6,5,0,6,1,6,4,5,5,2,0}
		_lib[0x79] = {BR,RED,0,1,0,4,2,6,5,6,6,5,6,1,5,0,4,0,3,1,3,6}
		_lib[0x80] = _lib[0x00] -- Alternative 0-9
		_lib[0x81] = _lib[0x01] --
		_lib[0x82] = _lib[0x02] --
		_lib[0x83] = _lib[0x03] --
		_lib[0x84] = _lib[0x04] --
		_lib[0x85] = _lib[0x05] --
		_lib[0x86] = _lib[0x06] --
		_lib[0x87] = _lib[0x07] --
		_lib[0x88] = _lib[0x08] --
		_lib[0x89] = _lib[0x09] --
		_lib[0x8a] = _lib[0x1d] -- Alternative M's
		_lib[0x8b] = _lib[0x1d] --
		_lib[0x9f] = {} -- {2,0,0,2,0,13,2,15,5,15,7,13,7,2,5,0,2,0,BR,BR,5,3,5,7,BR,BR,5,5,2,5,BR,BR,2,8,5,8,4,10,5,12,2,12} -- TM (default logo is cleared)
		_lib[0xb0] = {} -- basic block used for title screen (default logo is cleared)
		_lib[0xb1] = {0,0,7,0,7,7,0,7,0,0} -- Box
		_lib[0xb7] = {BR,YEL,0,0,1,0,1,1,6,1,6,0,7,0,7,6,6,6,6,5,1,5,1,6,0,6,0,0} -- Rivet
		_lib[0xdd] = {0,0,7,0,BR,BR,4,0,4,4,BR,BR,1,4,7,4,BR,BR,2,9,1,6,7,6,7,9,BR,BR,5,6,5,9,BR,BR,7,11,2,11,3,14,BR,BR,3,16,7,16,7,18,6,19,5,18,5,16,BR,BR,7,22,5,21,BR,BR,3,21,3,21} -- Help (big H)
		_lib[0xed] = {7,1,5,1,BR,BR,6,1,6,5,BR,BR,7,5,4,5,BR,BR,7,10,7,7,4,7,3,10,BR,BR,5,7,5,10,BR,BR,7,12,3,12,2,15,BR,BR,1,17,7,17,7,20,3,20,3,17,BR,BR,7,23,2,22,BR,BR,0,21,0,22} -- Help (little H)
		_lib[0xfb] = {5,1,6,2,6,5,5,6,4,6,2,3,BR,BR,0,3,1,4,BR,BR,1,3,0,4} -- question mark
		_lib[0xfd] = {-1,0,8,0,BR,BR,-1,-1,8,-1} -- vertical line
		_lib[0xfe] = {0,0,7,0,7,7,0,7,0,0} -- cross
		_lib[0xff] = {5,2,7,2,7,4,5,4,5,2,BR,BR,5,3,2,3,0,1,BR,BR,2,3,0,5,BR,BR,4,0,3,1,3,5,4,6} -- jumpman / stick man
		-- Bonus points
		_lib[0xf7b] = {5,0,6,1,0,1,BR,BR,0,0,0,2,BR,BR,0,4,0,8,6,8,6,4,0,4,BR,BR,0,10,0,14,6,14,6,10,0,10}  -- 100 Points
		_lib[0xf7d] = {0,0,0,4,2,4,3,1,6,4,6,0,BR,BR,0,6,0,9,6,9,6,6,0,6,BR,BR,0,11,0,14,6,14,6,11,0,11} -- 300 Points
		_lib[0xf7e] = {1,0,0,1,0,3,1,4,3,4,4,0,6,0,6,4,BR,BR,0,6,0,9,6,9,6,6,0,6,BR,BR,0,11,0,14,6,14,6,11,0,11} -- 500 Points
		_lib[0xf7f] = {1,0,2,0,4,4,5,4,6,3,6,1,5,0,4,0,2,4,1,4,0,3,0,1,1,0,BR,BR,0,6,0,9,6,9,6,6,0,6,BR,BR,0,11,0,14,6,14,6,11,0,11} -- 800 Points
		-- Love heart
		_lib[0xf76] = {0,8,5,2,7,1,10,1,12,3,12,6,10,8,12,10,12,13,10,15,7,15,5,14,0,8}  -- full heart
		_lib[0xf77] = {0,7,5,1,7,0,10,0,12,5,11,6,10,5,8,7,5,4,2,7,0,7,BR,BR,1,9,2,9,5,7,8,10,10,8,12,10,12,13,10,15,7,15,5,14,1,9} -- broken heart
		-- Item was smashed
		_lib[0xf60] = {6,1,9,1,13,5,13,10,9,14,6,14,2,10,2,5,6,1,BR,YEL,6,2,9,2,12,5,12,10,9,13,6,13,3,10,3,5,6,2}
		_lib[0xf61] = {7,3,4,6,4,9,7,12,8,12,11,9,11,6,8,3,7,3,BR,YEL,7,4,5,6,5,9,7,11,8,11,10,9,10,6,8,4,7,4,BR,RED,7,5,6,6,6,9,7,10,8,10,9,9,9,6,8,5,7,5}
		_lib[0xf62] = _lib[0xf60]  -- simplify smash animation
		_lib[0xf63] = _lib[0xf61]  -- simplify smash animation
		--_lib[0xf62] = {7,5,5,7,5,8,7,10,8,10,10,8,10,7,8,5,7,5,BR,YEL,7,6,6,7,6,8,7,9,8,9,9,8,9,7,8,6,7,6,BR,RED,7,7,7,8,8,8,8,7,7,7}
		--_lib[0xf63] = {BR,YEL,8,3,8,0,BR,BR,5,4,1,0,BR,BR,4,7,1,7,BR,BR,5,11,1,15,BR,BR,8,12,8,15,BR,BR,10,11,14,15,BR,BR,11,7,14,7,BR,BR,10,4,14,0,BR,RED,8,6,8,8,BR,BR,7,7,9,7}

		-- Non-character objects:
		_lib["logo"] = {0,32,39,32,BR,BR,20,32,0,55,BR,BR,20,32,39,55,BR,BR,0,64,0,87,39,87,39,64,0,64,BR,BR,0,96,39,96,0,119,39,119,BR,BR,20,140,20,151,0,151,0,128,39,128,39,151} -- kong logo
		_lib["select"] = {0,0,16,0,16,16,0,16,0,0}  -- selection box
		_lib["zigzag"] = {3,4,4,8,3,12} -- zig zags for girders
		_lib["oilcan"] = {1,1,15,1,BR,BR,1,15,15,15,BR,BR,5,1,5,15,BR,BR,12,1,12,15,BR,BR,7,4,10,4,10,7,7,7,7,4,BR,BR,7,9,10,9,BR,BR,7,13,7,11,10,11,BR,BR,15,0,16,0,16,16,15,16,15,0,BR,BR,1,0,0,0,0,16,1,16,1,0}
		_lib["flames"] = {0,4,2,2,3,3,8,0,4,5,5,6,9,4,5,8,4,7,2,10,2,11,4,12,9,10,4,14,0,12}
		_lib["stacked"] = {3,0,12,0,15,2,15,7,12,9,3,9,0,7,0,7,0,2,3,0,BR,BR,1,2,1,7,BR,BR,14,2,14,7,BR,MBR,2,3,13,3,BR,BR,2,6,13,6}
		_lib["rolling"] = {3,0,6,0,8,2,9,4,9,7,8,9,6,11,3,11,1,9,0,7,0,4,1,2,3,0}  -- barrel outline
		_lib["roll-1"] = {2,3,3,4,BR,BR,3,3,2,4,BR,BR,6,5,3,8}  -- regular barrel
		_lib["roll-2"] = {2,7,3,8,BR,BR,3,7,2,8,BR,BR,3,3,6,6}
		_lib["roll-3"] = {6,7,7,8,BR,BR,7,7,6,8,BR,BR,6,3,3,6}
		_lib["roll-4"] = {6,3,7,4,BR,BR,7,3,6,4,BR,BR,3,5,6,8}
		_lib["skull-1"] = {3,3,5,3,6,4,6,7,7,8,6,9,5,8,3,8,2,7,2,4,3,3,BR,BR,5,4,3,6}  -- skull/blue barrel
		_lib["skull-2"] = {5,8,3,8,2,7,2,4,3,3,5,3,6,2,7,3,6,4,6,7,5,8,BR,BR,3,5,5,7}
		_lib["skull-3"] = {7,4,7,7,6,8,4,8,3,7,3,4,2,3,3,2,4,3,6,3,7,4,BR,BR,6,5,4,7}
		_lib["skull-4"] = {4,3,6,3,7,4,7,7,6,8,4,8,3,9,2,8,3,7,3,4,4,3,BR,BR,6,6,4,4}
		_lib["down"] = {2,0,7,0,9,3,9,12,7,15,2,15,0,12,0,3,2,0,BR,BR,1,1,8,1,BR,BR,1,14,8,14}  -- barrel going down ladder or crazy barrel
		_lib["down-1"] = {3,3,3,12,BR,BR,6,3,6,12}
		_lib["down-2"] = {2,3,2,12,BR,BR,7,3,7,12}
		_lib["pauline"] = {14,11,1,12,4,0,10,7,15,6,15,7,13,9,14,11,BR,BLU,10,7,9,12,BR,PNK,20,14,21,13,21,8,15,1,15,6,15,7,20,10,20,14,18,14,16,12,16,10,14,10,BR,BR,19,12,19,13,BR,BR,2,5,0,6,1,2,3,3,2,5,BR,BR,13,6,12,2,11,2,11,7,BR,BR,10,12,9,15,10,15,12,11,BR,BR,1,12,0,13,0,9,2,9,1,12}
		_lib["hammer-up"] = {5,0,7,0,8,1,8,8,7,9,5,9,4,8,4,1,5,0,BR,BR,4,4,0,4,0,5,4,5,BR,BR,8,4,9,4,9,5,8,5}
		_lib["hammer-down"] = {8,-1,9,0,9,3,8,4,1,4,0,3,0,0,1,-1,8,-1,BR,BR,5,-1,5,-2,4,-2,4,-1,BR,BR,5,4,5,9,4,9,4,4,BR,GRY,-2,3,0,5,BR,BR,-2,-2,0,-4}
		_lib["fireball"] = {12,2,5,0,3,0,1,1,0,3,0,8,1,10,3,11,6,12,11,13,9,10,13,12,10,9,15,11,10,7,13,8,10,5,14,7,9,3,12,2,BR,RED,6,3,7,4,6,5,5,4,6,3,BR,BR,6,6,7,7,6,8,5,7,6,6}
		_lib["fb-flame"] = {12,2,5,0,BR,BR,6,12,11,13,9,10,13,12,10,9,15,11,10,7,13,8,10,5,14,7,9,3,12,2}
		_lib["dk-front"] = {31,20,31,17,27,13,25,13,25,15,28,15,29,16,30,18,30,19,29,20,BR,BR,25,20,25,18,24,18,24,20,BR,BR,21,15,22,16,22,20,BR,BR,26,18,27,18,27,19,26,19,26,18,BR,BR,6,20,6,16,2,12,BR,BR,2,4,4,4,5,3,7,3,11,7,13,7,13,4,16,1,19,1,23,6,24,8,24,10,BR,BR,7,15,8,14,10,14,BR,BR,19,6,17,10,16,13,BR,BR,10,13,11,10,BR,MBR,27,13,27,11,26,10,25,10,21,11,20,14,19,14,18,16,18,20,BR,BR,2,12,0,11,0,0,2,2,2,4,BR,BR,16,13,16,15,15,18,14,19,12,19,10,17,10,13,BR,BR,6,17,7,17,8,16,BR,BR,6,19,7,19,8,18,BR,BR,1,10,2,11,BR,BR,1,5,2,6,BR,BR,28,17,28,19,26,19,26,17,28,17,BR,LBR,26,18,27,18,27,19,26,19,26,18}
		_lib["dk-hold"] = {31,20,31,17,27,13,25,13,25,15,28,15,29,16,30,18,30,19,29,20,BR,BR,25,20,25,18,24,18,24,20,BR,BR,21,15,22,16,22,20,BR,BR,26,18,27,18,27,19,26,19,26,18,BR,BR,2,4,4,4,5,3,7,3,11,1,14,0,17,0,21,1,26,6,26,8,25,10,BR,BR,7,3,4,6,BR,BR,15,11,17,10,15,8,11,8,BR,BR,11,12,11,16,13,18,15,18,16,17,16,12,15,11,12,11,11,12,BR,MBR,BR,BR,13,14,14,15,BR,BR,14,14,13,15,BR,BR,27,13,27,11,26,10,25,10,21,11,20,14,19,14,18,16,18,20,BR,BR,2,12,0,11,0,0,2,2,2,4,BR,BR,1,10,2,11,BR,BR,1,5,2,6,BR,BR,28,17,28,19,26,19,26,17,28,17,BR,BR,4,6,3,9,3,11,4,11,5,10,8,10,9,12,10,12,10,11,11,8,BR,LBR,26,18,27,18,27,19,26,19,26,18}
		_lib["dk-side"] = {7,1,7,5,9,7,11,7,17,13,23,15,26,18,28,23,28,26,30,28,31,30,31,35,30,36,BR,BR,2,6,3,7,3,13,5,15,5,23,4,23,2,22,BR,BR,2,30,5,31,10,28,BR,BR,3,35,10,28,18,21,23,21,24,22,BR,BR,7,39,13,35,17,32,BR,BR,19,35,21,37,21,41,BR,BR,26,38,26,40,25,40,25,38,26,38,BR,BR,6,16,7,17,10,23,10,25,BR,BR,6,22,8,24,9,26,BR,BR,30,36,30,35,27,31,24,34,22,34,21,33,21,32,BR,MBR,7,1,1,1,0,2,0,8,2,6,BR,BR,5,2,5,3,BR,BR,1,2,2,3,BR,BR,2,22,0,22,0,34,2,32,2,30,BR,BR,1,24,2,24,BR,BR,1,29,2,28,BR,BR,3,35,0,39,0,41,1,42,2,42,4,40,5,40,6,42,7,42,7,39,BR,BR,17,32,17,36,18,39,21,42,22,42,24,41,25,40,BR,BR,26,38,30,36,BR,BR,21,32,23,30,25,30,26,29,26,28,25,27,24,27,20,31,17,32,BR,BR,28,36,28,34,26,34,26,36,28,36,BR,LBR,27,36,27,35,26,35,26,36,27,36}
		_lib["dk-growl"] = {22,20,22,16,23,15,23,14,22,13,20,14,19,17,19,20,BR,LBR,21,15,21,17,BR,BR,22,16,20,16,BR,BR,21,19,21,20,BR,BR,22,20,20,20}
		_lib["jm-0"] = {6,6,6,7,5,7,5,6,6,6,BR,BR,8,6,7,5,BR,BR,2,5,1,5,1,4,0,4,0,7,2,7,2,5,BR,BR,2,10,1,10,1,9,0,9,0,12,2,12,2,10,BR,BR,10,3,11,3,11,5,10,5,10,3,BR,BR,11,3,10,5,BR,BR,10,3,11,5,BR,BR,14,8,13,9,11,8,11,9,12,10,12,11,10,11,10,13,14,11,BR,BR,8,10,8,11,7,12,5,12,3,10,BR,BR,7,9,6,10,5,9,BR,RED,14,3,14,11,16,10,16,8,14,5,BR,BR,6,9,7,8,7,5,5,4,3,4,2,5,BR,BR,2,7,3,8,3,9,2,10,BR,BR,4,11,2,12,BR,BR,14,6,13,5,12,3,11,2,11,3,10,4,9,4,8,6,BR,BR,8,10,10,11,BR,BR,5,9,4,8,3,9,3,10,BR,BR,13,6,13,7,12,7,12,6,13,6}
		_lib["jm-1"] = {10,3,11,3,11,5,10,5,10,3,BR,BR,11,3,10,5,BR,BR,10,3,11,5,BR,BR,14,8,13,9,11,8,11,9,12,10,12,11,10,11,10,13,14,11,BR,BR,8,2,8,6,BR,BR,6,3,6,5,BR,BR,8,10,8,12,BR,BR,6,11,6,12,5,14,BR,BR,6,7,6,8,5,8,5,7,6,7,BR,BR,5,2,2,2,2,4,4,4,4,3,5,3,5,2,BR,BR,3,13,2,14,0,13,0,12,1,12,2,11,3,13,BR,RED,14,3,14,11,16,10,16,8,14,5,BR,BR,4,4,7,6,7,9,6,11,3,13,BR,BR,2,4,3,7,3,8,2,11,BR,BR,14,6,13,5,12,3,11,2,11,3,10,4,9,4,8,6,BR,BR,8,10,10,11,BR,BR,13,6,13,7,12,7,12,6,13,6,BR,BR,8,2,8,1,7,1,6,2,6,3,BR,BR,7,14,7,15,5,15,5,14}
		_lib["jm-2"] = {9,2,10,2,10,4,9,4,9,2,BR,BR,10,2,9,4,BR,BR,9,2,10,4,BR,BR,13,7,12,8,10,7,10,8,11,9,11,10,9,10,9,12,13,10,BR,BR,6,4,7,9,7,11,6,12,5,11,4,4,BR,BR,2,6,2,8,0,8,0,5,1,5,1,6,2,6,BR,BR,4,13,4,15,1,15,1,14,2,14,2,13,4,13,BR,RED,13,2,13,10,15,9,15,7,13,4,BR,BR,4,4,2,6,BR,BR,2,8,3,8,3,9,2,13,BR,BR,6,12,4,13,BR,BR,13,5,12,4,11,2,10,1,10,2,9,3,8,3,7,5,BR,BR,7,9,9,10,BR,BR,12,5,12,6,11,6,11,5,12,5,BR,BR,6,4,6,2,5,2,4,4}
		_lib["jm-3"] = {14,2,11,1,8,3,7,3,BR,BR,14,4,11,3,9,5,BR,BR,9,10,10,12,10,13,9,14,7,12,BR,BR,4,3,4,6,3,6,3,2,4,3,BR,BR,2,7,2,10,1,11,1,7,2,7,BR,BR,14,5,13,4,10,4,9,6,9,9,10,11,13,11,14,10,BR,RED,15,5,15,10,14,10,13,9,13,6,14,5,15,5,BR,BR,4,3,5,2,6,2,7,3,8,5,9,5,9,6,8,6,8,7,7,8,8,9,9,9,9,10,8,10,7,12,4,12,2,10,BR,BR,14,2,15,3,15,4,14,4}
		_lib["jm-4"] = {15,6,13,6,14,5,12,2,11,1,10,1,10,2,11,4,BR,BR,15,11,13,11,14,12,13,14,10,14,BR,BR,6,4,6,7,5,7,5,3,6,4,BR,BR,3,7,3,10,2,11,2,7,3,7,BR,RED,15,6,15,11,14,10,14,7,15,6,BR,BR,6,4,8,2,9,2,11,4,12,6,13,6,13,7,12,7,11,8,11,9,12,10,13,10,13,11,12,11,11,13,10,14,7,14,3,10}
		_lib["jm-5"] = {7,1,7,5,6,5,6,1,7,1,BR,BR,3,7,3,10,2,11,2,7,3,7,BR,BR,11,12,9,14,7,15,6,15,BR,RED,7,1,8,0,9,0,11,2,12,4,12,6,11,7,11,8,12,9,12,10,11,12,9,13,5,13,3,10,BR,BR,3,7,5,9,6,9,7,7,7,5,BR,BR,6,13,5,14,5,15,6,15}
		_lib["jm-6"] = {14,5,13,4,10,4,9,6,9,9,10,11,13,11,14,10,BR,BR,5,1,7,1,9,3,9,5,BR,BR,9,10,9,12,7,14,4,14,BR,BR,0,3,0,7,1,7,1,4,0,3,BR,BR,1,8,0,8,0,12,1,11,1,8,BR,RED,15,5,15,10,14,10,13,9,13,6,14,5,15,5,BR,BR,1,7,2,6,3,7,3,8,2,9,1,8,BR,BR,1,4,2,3,6,3,8,5,9,5,9,6,7,6,6,7,6,8,7,9,9,9,9,10,8,10,6,12,2,12,1,11,BR,BR,5,1,4,1,4,2,5,3,BR,BR,5,12,4,13,4,14,5,14}
		_lib["jm-8"] = {11,3,11,5,10,5,10,3,11,3,BR,BR,10,3,11,5,BR,BR,11,3,10,5,BR,BR,14,11,10,13,10,10,12,11,12,9,BR,BR,14,7,9,7,7,9,6,11,7,12,8,11,9,9,14,9,BR,BR,8,6,7,5,BR,RED,16,9,16,10,14,11,14,9,BR,BR,14,3,14,7,BR,BR,14,5,16,8,BR,BR,14,7,16,8,16,9,14,9,BR,BR,13,6,13,7,12,7,12,6,13,6,BR,BR,14,6,13,5,12,3,11,2,BR,BR,10,4,9,4,8,6,BR,BR,10,10,9,10,BR,RED,7,9,7,5,5,4,3,4,2,5,BR,BR,7,12,2,12,BR,BR,2,7,3,8,3,9,2,10,BR,CYN,6,6,6,7,5,7,5,6,6,6,BR,BR,2,5,2,7,0,7,0,4,1,4,1,5,2,5,BR,BR,2,10,2,12,0,12,0,9,1,9,1,10,2,10}
		_lib["jm-9"] = {11,3,11,5,10,5,10,3,11,3,BR,BR,11,3,10,5,BR,BR,10,3,11,5,BR,BR,14,8,13,9,11,8,11,9,12,10,12,11,10,11,10,13,14,11,BR,BR,8,2,8,10,7,11,6,10,6,2,BR,RED,14,3,14,11,16,10,16,8,14,5,BR,BR,13,6,13,7,12,7,12,6,13,6,BR,BR,14,6,13,5,12,3,11,2,11,3,BR,BR,10,4,9,4,8,5,BR,BR,8,10,10,10,BR,BR,8,2,8,0,7,0,6,2,BR,RED,6,4,3,4,2,5,BR,BR,2,7,3,8,3,9,2,10,BR,BR,2,12,5,11,7,11,BR,CYN,6,6,5,6,5,7,6,7,BR,BR,2,5,2,7,0,7,0,4,1,4,1,5,2,5,BR,BR,2,10,2,12,0,12,0,9,1,9,1,10,2,10}
		_lib["jm-10"] = {11,3,11,5,10,5,10,3,11,3,BR,BR,10,3,11,5,BR,BR,11,3,10,5,BR,BR,14,11,10,13,10,10,12,11,12,9,BR,BR,14,7,9,7,7,9,6,11,7,12,8,11,9,9,14,9,BR,BR,8,6,7,5,BR,RED,16,9,16,10,14,11,14,9,BR,BR,14,3,14,7,BR,BR,14,5,16,8,BR,BR,14,7,16,8,16,9,14,9,BR,BR,13,6,13,7,12,7,12,6,13,6,BR,BR,14,6,13,5,12,3,11,2,BR,BR,10,4,9,4,8,6,BR,BR,10,10,9,10,BR,RED,7,9,7,5,4,4,BR,BR,2,4,3,7,3,8,2,11,BR,BR,7,12,5,11,3,13,BR,CYN,4,4,4,3,5,3,5,2,2,2,2,4,4,4,BR,BR,2,11,3,13,2,14,0,13,0,12,1,12,2,11,BR,BR,6,6,6,7,5,7,5,6,6,6}
		_lib["jm-11"] = {11,3,11,5,10,5,10,3,11,3,BR,BR,11,3,10,5,BR,BR,10,3,11,5,BR,BR,14,8,13,9,11,8,11,9,12,10,12,11,10,11,10,13,14,11,BR,BR,8,2,8,10,7,11,6,10,6,2,BR,RED,14,3,14,11,16,10,16,8,14,5,BR,BR,13,6,13,7,12,7,12,6,13,6,BR,BR,14,6,13,5,12,3,11,2,11,3,BR,BR,10,4,9,4,8,5,BR,BR,8,10,10,10,BR,BR,8,2,8,0,7,0,6,2,BR,RED,6,5,4,4,BR,BR,2,4,3,7,3,8,2,11,BR,BR,7,11,5,11,3,13,BR,CYN,6,6,5,6,5,7,6,7,BR,BR,5,2,5,3,4,3,4,4,2,4,2,2,5,2,BR,BR,2,11,3,13,2,14,0,13,0,12,1,12,2,11}
		_lib["jm-12"] = {11,2,11,4,10,4,10,2,11,2,BR,BR,10,2,11,4,BR,BR,11,2,10,4,BR,BR,14,10,10,12,10,9,12,10,12,8,BR,BR,14,6,9,6,7,8,6,10,7,11,8,10,9,8,14,8,BR,BR,8,5,7,4,BR,RED,16,8,16,9,14,10,14,8,BR,BR,14,2,14,6,BR,BR,14,4,16,7,BR,BR,14,6,16,7,16,8,14,8,BR,BR,13,5,13,6,12,6,12,5,13,5,BR,BR,14,5,13,4,12,2,11,1,BR,BR,10,3,9,3,8,6,BR,BR,10,9,9,9,BR,RED,7,8,7,4,4,4,2,6,BR,BR,2,8,3,8,3,9,2,13,BR,BR,7,11,6,11,4,13,BR,CYN,6,6,6,7,5,7,5,6,6,6,BR,BR,0,5,0,8,2,8,2,6,1,6,1,5,0,5,BR,BR,4,13,4,15,1,15,1,14,2,14,2,13,4,13}
		_lib["jm-13"] = {11,2,11,4,10,4,10,2,11,2,BR,BR,11,2,10,4,BR,BR,10,2,11,4,BR,BR,14,7,13,8,11,7,11,8,12,9,12,10,10,10,10,12,14,10,BR,BR,8,2,8,10,7,11,6,10,6,2,BR,RED,14,2,14,10,16,9,16,7,14,4,BR,BR,13,5,13,6,12,6,12,5,13,5,BR,BR,14,5,13,4,12,2,11,1,11,2,BR,BR,10,3,9,3,8,4,BR,BR,8,10,10,10,BR,BR,8,2,8,0,7,0,6,2,BR,RED,6,4,4,4,2,6,BR,BR,2,8,3,8,3,9,2,13,BR,BR,4,13,6,11,7,11,BR,CYN,6,6,5,6,5,7,6,7,BR,BR,2,6,1,6,1,5,0,5,0,8,2,8,2,6,BR,BR,4,13,4,15,1,15,1,14,2,14,2,13,4,13}
		_lib["jm-14"] = {9,3,10,3,10,5,9,5,9,3,BR,BR,10,3,9,5,BR,BR,9,3,10,5,BR,BR,13,8,12,9,10,8,10,9,11,10,11,11,9,11,9,13,13,11,BR,BR,1,1,4,1,4,2,3,2,3,3,1,3,1,1,BR,BR,3,12,5,13,3,15,2,15,3,14,2,13,3,12,BR,BR,7,3,7,6,BR,BR,5,2,5,5,BR,BR,7,10,8,13,BR,BR,5,11,6,14,BR,BR,5,7,5,8,4,8,4,7,5,7,BR,RED,13,3,13,11,15,10,15,8,13,5,BR,BR,3,3,6,6,6,9,5,11,3,11,3,12,BR,BR,1,3,2,7,2,8,0,10,0,11,2,13,BR,BR,13,6,12,5,11,3,10,2,10,3,9,4,8,4,7,6,BR,BR,7,10,9,11,BR,BR,12,6,12,7,11,7,11,6,12,6,BR,BR,7,3,7,1,6,1,5,2,BR,BR,8,13,8,15,7,15,6,14}
		_lib["jm-15"] = {10,4,11,4,11,6,10,6,10,4,BR,BR,11,4,10,6,BR,BR,10,4,11,6,BR,BR,14,9,13,10,11,9,11,10,12,11,12,12,10,12,10,14,14,12,BR,BR,9,11,9,13,7,16,6,16,BR,BR,6,12,7,13,6,14,BR,BR,7,3,8,4,9,6,9,8,BR,BR,5,4,6,5,7,7,7,8,BR,BR,2,1,3,2,2,3,3,4,1,5,0,3,2,1,BR,BR,2,6,3,7,2,8,3,9,1,10,0,8,2,6,BR,RED,14,4,14,12,16,11,16,9,14,6,BR,BR,3,4,4,5,6,6,7,8,7,10,6,12,3,13,1,10,BR,BR,1,5,2,6,BR,BR,3,9,4,10,BR,BR,14,7,13,6,12,4,11,3,11,4,10,5,9,5,9,6,BR,BR,8,11,10,12,BR,BR,13,7,13,8,12,8,12,7,13,7,BR,BR,7,3,6,2,5,2,4,3,5,4,BR,BR,6,14,5,14,4,15,4,16,6,16,BR,BR,0,12,1,13,2,15,BR,BR,0,14,1,16}
		_lib["jm-120"] = {14,4,10,3,10,4,14,6,BR,BR,14,11,10,12,14,9,BR,BR,11,5,11,6,10,7,10,8,11,9,11,11,10,10,10,9,9,8,9,7,10,6,10,5,11,5,BR,BR,9,5,8,4,9,2,BR,BR,9,10,8,11,9,13,BR,BR,6,4,6,3,8,1,BR,BR,6,11,6,12,8,14,BR,BR,6,5,6,6,5,6,5,5,6,5,BR,BR,6,9,6,10,5,10,5,9,6,9,BR,BR,4,3,2,5,1,4,2,1,3,1,4,3,BR,BR,2,10,4,12,3,13,3,14,2,14,1,11,2,10,BR,RED,14,4,15,5,16,7,16,8,15,10,14,11,14,4,BR,BR,4,3,6,4,7,5,8,5,8,6,7,6,6,7,6,8,7,9,8,9,8,10,7,10,6,11,4,12,BR,BR,2,5,3,7,3,8,2,10,BR,BR,13,6,13,7,12,7,12,6,13,6,BR,BR,13,8,13,9,12,9,12,8,13,8,BR,BR,10,4,8,6,BR,BR,10,11,8,9,BR,BR,8,1,9,0,10,0,10,1,9,2,BR,BR,9,13,10,14,10,15,9,15,8,14,BR,BR,10,4,12,4,BR,BR,10,11,12,11}
		_lib["jm-121"] = {10,2,11,1,14,2,14,3,13,3,12,4,10,2,BR,BR,5,2,3,4,2,3,1,3,1,2,4,1,5,2,BR,BR,10,5,10,6,9,6,9,5,10,5,BR,BR,6,5,6,6,5,6,5,5,6,5,BR,BR,11,6,12,6,14,8,BR,BR,10,9,11,8,13,9,BR,BR,4,6,3,6,1,8,BR,BR,5,9,4,8,2,9,BR,BR,9,14,11,10,12,10,11,14,BR,BR,6,14,4,10,3,10,4,14,BR,BR,10,11,9,11,8,10,7,10,6,11,4,11,5,10,6,10,7,9,8,9,9,10,10,10,10,11,BR,RED,11,14,10,15,8,16,7,16,5,15,4,14,11,14,BR,BR,12,4,11,6,10,7,10,8,9,8,9,7,8,6,7,6,6,7,6,8,5,8,5,7,4,6,3,4,BR,BR,10,2,8,3,7,3,5,2,BR,BR,14,8,15,9,15,10,14,10,13,9,BR,BR,2,9,1,10,0,10,0,9,1,8,BR,BR,9,8,11,10,BR,BR,6,8,4,10,BR,BR,9,12,9,13,8,13,8,12,9,12,BR,BR,7,12,7,13,6,13,6,12,7,12}
		_lib["jm-122"] = {10,2,12,3,11,7,10,7,10,6,9,5,10,2,BR,BR,6,5,6,6,5,6,5,5,6,5,BR,BR,2,2,2,5,4,7,3,8,2,8,0,6,0,0,1,0,2,2,BR,BR,8,10,8,11,5,11,5,10,8,10,BR,BR,8,10,5,11,BR,BR,8,11,5,10,BR,BR,0,14,0,9,1,8,1,11,2,11,1,13,2,14,BR,RED,0,14,8,14,BR,BR,0,14,1,16,3,16,6,14,BR,BR,10,2,9,1,6,0,4,0,2,1,BR,BR,9,5,8,4,7,4,6,7,5,8,BR,BR,2,2,2,1,1,0,0,0,0,2,BR,BR,5,8,5,9,6,10,BR,BR,8,11,9,11,8,12,6,13,5,14,BR,BR,5,12,5,13,4,13,4,12,5,12}
		return _lib
	end

	function write_rom_message(start_addr, text)
		-- write characters of message to ROM
		for key=1, string.len(text) do
			mem:write_direct_u8(start_addr + (key - 1), string.find(characters, string.sub(text, key, key)) - 1)
		end
	end	

	---- event registration
	-----------------------
	emu.register_start(function()
		initialize()
	end)

	emu.register_frame_done(main, "frame")
end
return exports