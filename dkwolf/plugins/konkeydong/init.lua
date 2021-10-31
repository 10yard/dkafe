-- Konkey Dong Plugin for MAME/WolfMAME
-- by Jon Wilson (10yard)
--
-- Tested with latest MAME version 0.236
-- Compatible with MAME versions from 0.196
--
-- Minimum start up arguments:
--   mame dkong -plugin konkeydong
-----------------------------------------------------------------------------------------

local exports = {}
exports.name = "konkeydong"
exports.version = "0.1"
exports.description = "Konkey Dong"
exports.license = "GNU GPLv3"
exports.author = { name = "Jon Wilson (10yard)" }
local konkeydong = exports

function konkeydong.startplugin()
	local BLACK, RED = 0xff000000, 0xffE8070A
	local flipped = false
	local reposition = false
	local char_table = {}

	function initialize()
		-- MAME LUA machine initialisation
		-- Handles historic changes to back to MAME v0.196 release
		if tonumber(emu.app_version()) >= 0.196 then
			if type(manager.machine) == "userdata" then
				mac = manager.machine
				tgt = mac.render.targets[1]
			else
				mac =  manager:machine()
				if type(mac:render().targets) == "table" then
					tgt = mac:render().targets[0]
				else
					tgt = mac:render():targets()[0]
				end
			end			
		else
			print("ERROR: The konkeydong plugin requires MAME version 0.196 or greater.")
		end				
		
		if tgt ~= nil then
			scr = mac.screens[":screen"]
			cpu = mac.devices[":maincpu"]
			mem = cpu.spaces["program"]
			initial_orientation = tgt.orientation
			char_table = build_character_table()
		end
	end
	
	function main()
		if scr ~= nil and mem ~= nil then
			mode = mem:read_u8(0x600a)   -- Status of gameplay
			stage = mem:read_u8(0x6227)  -- 1-girders, 2-pie, 3-elevator, 4-rivets, 5-extra/bonus
						
			-- Underline title and hide the high score
			scr:draw_box(248, 72, 240, 152, BLACK, BLACK) 
			scr:draw_box(248, 73, 247, 152, RED, RED) 
			
			-- Force 1 player gameplay only
			if mem:read_u8(0x600f) == 0x01 then
				mem:write_direct_u8(0x600d, 0x00)
				mem:write_direct_u8(0x600e, 0x00)
				mem:write_direct_u8(0x600f, 0x00)
			end
			
			if stage == 2 then
				if mode == 0xb then
					reposition = false
				elseif mode == 0xc then
					-- Jumpman dies on pies if he drops off the bottom of screen
					if mem:read_u8(0x6205) >= 247 then
						mem:write_u8(0xc6200, 0)
					end
					-- Move jumpman start position on pies
					if not reposition then
						mem:write_u8(0x694c, 30)
						mem:write_u8(0x6203, 30)
						reposition = true
					end
				end
			end
			
			if stage == 1 and ((mode >= 0x0b and mode <= 0x0d) or (mode >=02 and mode <= 0x04) or  mode == 0x10 or mode == 0x16) then
				-- Barrels stage during gameplay or attract mode
				if not flipped then
					-- flip the screen horizontally
					tgt.orientation = tgt.orientation ~ 1
					
					-- Flip Jumpman's left/right movement logic
					mem:write_direct_u8(0x1af1, 0x4f)
					mem:write_direct_u8(0x1afa, 0x47)					
					mem:write_direct_u8(0x1b82, 0x00)
					mem:write_direct_u8(0x1b7b, 0xff)

					-- Flip Pauline's "Help!" callout graphic
					mem:write_direct_u8(0x049b, 0xbf)

					-- Flip the bonus point sprites (100, 300, 500, 800)
					mem:write_direct_u8(0x1e01, 0x6d)
					mem:write_direct_u8(0x1e09, 0x6e)
					mem:write_direct_u8(0x1e11, 0x6f)
					mem:write_direct_u8(0x3e74, 0x6b)
					mem:write_direct_u8(0x3e7c, 0x6d)
					mem:write_direct_u8(0x3e84, 0x6f)

					-- Flip the oil can sprite
					mem:write_u8(0x69fd, 0x59)
					
					flipped = true
				end
								
				-- Flip the level number graphic and move to opposite side of screen
				write_graphics(0x7783, "       ")
				level = string.format('%02X', mem:read_u8(0x6229))
				level = string.sub(level, 2, 2)..string.sub(level, 1, 1)
				write_graphics(0x7743, level.."=l")
				
				-- Flip Jumpman's lives graphics and move to opposite side of screen
				write_graphics(0x7503, "       ")
				lives = (mem:read_u8(0x6228))
				for i=1, lives-1 do
					mem:write_u8(0x7443 + (i*0x20), 0xfa)
				end
								
				-- Flip the "BONUS" wording in the countdown timer
				write_graphics(0x74e5, "<>()")

				-- Flip the coundown timer digits
				offset = 0x90
				timer = string.format('%02X', mem:read_u8(0x638c)).."00"				
				for i=1, string.len(timer) do
					digit = string.sub(timer, i, i)
					if tonumber(timer) < 1000 then
						--use red digits when time runs low
						if tonumber(digit) <= 4 then
							offset = 0xe8
						else
							offset = 0xd3
						end
					end
					mem:write_u8(0x7466 + (0x20 * i), tonumber(digit + offset))
				end
				
				-- Move 1UP to top-left.  Flash 1UP and some characters in the "KONKYDONG" title.
				if mem:read_u8(0x7740) ~= 0x10 then
					write_graphics(0x74e0, "pu1")
					write_graphics(0x7680, "gnodyeknok")
				else
					write_graphics(0x74e0, "   ")
					write_graphics(0x7680, "gnoDyeknoK")
				end				

				-- Move players score to opposite side of screen
				s1 = mem:read_u8(0x7781)
				if s1 ~= nil and sl ~= 0x10 then
					mem:write_u8(0x7461, s1 + 0x90)
					mem:write_u8(0x7481, mem:read_u8(0x7761) + 0x90)
					mem:write_u8(0x74a1, mem:read_u8(0x7741) + 0x90)
					mem:write_u8(0x74c1, mem:read_u8(0x7721) + 0x90)
					mem:write_u8(0x74e1, mem:read_u8(0x7701) + 0x90)
					mem:write_u8(0x7501, mem:read_u8(0x76E1) + 0x90)
				end
	
				-- Hide original 1UP and score (as they were moved to opposite side of screen)
				scr:draw_box(256, 0, 240, 64, BLACK, BLACK)

				if mode == 0x10 then
					-- Flip the GAME OVER wording
					write_graphics(0x7696, "revo  emag")
				end
								
			else
				-- Flash the "KONKEYDONG" title
				if mem:read_u8(0x7740) ~= 0x10 then
					write_graphics(0x7680, "KONKEYDONG")
				else
					write_graphics(0x7680, "kONKEYdONG")
				end				

				if flipped then
					-- reset screen orientation
					tgt.orientation = initial_orientation
	
					-- Reset Jumpmans's left/right movement logic
					mem:write_direct_u8(0x1af1, 0x47)
					mem:write_direct_u8(0x1afa, 0x4f)
					mem:write_direct_u8(0x1b7b, 0x00)
					mem:write_direct_u8(0x1b82, 0xff)
					
					-- Reset Paulines "Help!" callout
					mem:write_direct_u8(0x049b, 0xbf)
					
					-- Reset the oil can sprite
					mem:write_u8(0x69fd, 0x49)

					-- Reset the bonus point sprites
					mem:write_direct_u8(0x1e01, 0x7d)
					mem:write_direct_u8(0x1e09, 0x7e)
					mem:write_direct_u8(0x1e11, 0x7f)
					mem:write_direct_u8(0x3e74, 0x7b)
					mem:write_direct_u8(0x3e7c, 0x7d)
					mem:write_direct_u8(0x3e84, 0x7f)
					
					-- Clear score, 1UP, lives and level graphics as they have now reverted to default positions
					write_graphics(0x7501, "      ")
					write_graphics(0x74e0, "   ")
					write_graphics(0x7503, "       ")
					write_graphics(0x7783, "       ")
					
					flipped = false
				end				
			end
		end
	end

	function write_graphics(start_address, text)
		-- write characters of message to DK's video ram
		for key=1, string.len(text) do
			mem:write_u8(start_address - ((key - 1) * 32), char_table[string.sub(text, key, key)])
		end
	end
	
	function build_character_table()
		-- Character conversion table when writing to video ram
		local c = {}	
		c[" "] = 0x10
		c["A"] = 0x11
		c["B"] = 0x12
		c["C"] = 0x13
		c["D"] = 0x14
		c["E"] = 0x15
		c["F"] = 0x16
		c["G"] = 0x17
		c["H"] = 0x18
		c["I"] = 0x19
		c["J"] = 0x1a
		c["K"] = 0x1b
		c["L"] = 0x1c
		c["M"] = 0x1d
		c["N"] = 0x1e
		c["O"] = 0x1f
		c["P"] = 0x20
		c["Q"] = 0x21
		c["R"] = 0x22
		c["S"] = 0x23
		c["T"] = 0x24
		c["U"] = 0x25
		c["V"] = 0x26
		c["W"] = 0x27
		c["X"] = 0x28
		c["Y"] = 0x29
		c["Z"] = 0x2a
		c["="] = 0x34		
		-- The following are alternative/flipped characters in sprite bank
		c["0"] = 0x90
		c["1"] = 0x91
		c["2"] = 0x92
		c["3"] = 0x93
		c["4"] = 0x94
		c["5"] = 0x95
		c["6"] = 0x96
		c["7"] = 0x97
		c["8"] = 0x98
		c["9"] = 0x99
		c["k"] = 0xaa
		c["o"] = 0xab
		c["n"] = 0xac
		c["y"] = 0xad
		c["d"] = 0xae
		c["g"] = 0xaf
		c["e"] = 0xc8
		c["l"] = 0xc9
		c["u"] = 0xcb
		c["p"] = 0xca
		c["r"] = 0xcc
		c["a"] = 0x9b
		c["m"] = 0x9c
		c["v"] = 0x9d
		
		-- The following 4 characters make the BONUS graphic
		c["<"] = 0xb9
		c[">"] = 0xba
		c["("] = 0xbb
		c[")"] = 0xbc
		return c
	end
	
	emu.register_start(function()
		initialize()
	end)

	emu.register_frame_done(main, "frame")
	
end
return exports