--Pattern Trainer for Pac-Man
--by Jon Wilson (10yard)
--
--The Pac-Man Trainer is an aid to learning the common patterns for completing boards.  
--You follow an on-screen path through each board.  For the pattern to hold,  you must
--stay on track and turn the corners quickly.  
--
--The HUD shows information which can help during gameplay.  
--On the left of the screen you will see the current level (e.g. "L. 001"),  the current
--pattern (e.g. "P. 1/3"), and the current status (e.g. S. ACE).  The status will change 
--if you start falling behind to "OK" and finally "BAD" based on the number of dropped 
--movements/frames.  It is still possible to complete the board with a "BAD" status but 
--following the path will not guarantee success and you should be more cautious.  
--If you die then the pattern will automatically fail and you will see a blinking "FAIL" 
--message.  You are on your own to complete the board.
--
--Press P2 button to toggle between the currently available pattern sets.
--    
--PACSTRATS set:
--    Use only three patterns to clear boards 1 through 255 and get to the kill screen!
--    Pattern 1 is used on boards 1 through 4
--    Pattern 2 is used on boards 5 through 20
--    Pattern 3 is used on boards 21 through 255
--    All three patterns clear the entire board and get both prizes.
--	
--	  More information about following these patterns in the video at:
--	  https://www.youtube.com/watch?v=wKQy8LTTzC4
--    
--KILLERCLOWN set:
--    Uses 5 patterns but some of them are very similar so should be easier to learn.
--    These patterns are robust until near to the end of each board.  You may need to
--    freestyle to tidy up some remaining pellets on your own.
--    Pattern 1 is for board 1 only.  It's freestyle near the end if you prefer.
--    Pattern 2 is for boards 2 through 4.  It's a slight variation from pattern 1.
--    Pattern 3 if for boards 5 through 16.
--    Pattern 4 is for boards 17, 19 and 20.  You'll need to freestyle near the end.
--    Pattern 5 is for boards 21 through 255
--	
--	  More information about Killerclown's patterns is to be found at
--    https://www.mameworld.info/net/pacman/patterns.html
--
--PERFECT_NRC set:
--    An advanced pattern set for attaining the Perfect Pacman score by NR Chapman
--    There are many patterns.
--
--    The archive web information can be found at
--    https://web.archive.org/web/20061103090947/http://nrchapman.com/pacman/
--
--Minimum start up arguments:
--    mame pacman -plugin pactrainer
--
--Compatible with all MAME versions from 0.226 upwards.
--Works with "pacman" and "puckman" roms only.
-----------------------------------------------------------------------------------------
local exports = {
	name = "pactrainer",
	version = "0.1j",
	description = "Pac-Man Pattern Trainer",
	license = "GNU GPLv3",
	author = { name = "Jon Wilson (10yard)" } }

local pactrainer = exports

function pactrainer.startplugin()
	local GREEN, YELLOW, RED = 0xff00ff00, 0xffffff00, 0xffff0000
	local SETS = {"pacstrats", "killerclown", "perfect_nrc"}
	local LAG_PIXELS_DEFAULT = 5

	local mac, cpu, mem, scr
	local patx, paty, pacx, pacy, oldpacx, oldpacy, lagx, lagy
	local mode, level, patid, patgroup, state, pills, oldstate, folder, first
	local seq, switch = 0, 0
	local pattern, group = {}, {}
	local loaded, valid, failed, adjusted, lagging, ignore, freestyle, perfect = false, false, false, false, false, false, false, false
	local lag_pixels = LAG_PIXELS_DEFAULT
	
	
	function get_next(table, id)
		local found = false
		nextid = "pacstrats" -- default
		for k, v in ipairs(table) do
			if found then
				nextid = v
				break
			end
			if v == id then found = true end
		end		
		return nextid
	end
	
	function pactrainer_initialize()
		mac = manager.machine
		if mac then
			if emu.romname() == "pacman" or emu.romname() == "puckman" then
				cpu = mac.devices[":maincpu"]
				mem = cpu.spaces["program"]
				scr = mac.screens[":screen"]								
			else
				print("The Pac-Man trainer works only with 'pacman' and 'puckman' roms.")
			end
		end
	end
	
	function pactrainer_patterns()
		local content, file, prev_line
				
		-- look for the active pattern folder
		if not folder then
			file = io.open("plugins/pactrainer/patterns/active.dat", "r")
			if file then
				folder = file:read("*all")
				file:close()
			end
		end
		if not folder or #folder <= 2 then
			folder = get_next(SETS)
		end
														
		-- Each level can have a pattern but we want as few patterns as possible to help with learning
		-- If a pattern is not found then the previous level patterns is used.  This allows patterns to be grouped.
		-- Typically there will only be a few patterns like 1,2,3,4 are similar,  5-20 are all the same,  21+ are all the same		
		pattern = {}
		group = {}
		for l=1, 256 do
			for g=1, 21 do
				file = io.open("plugins/pactrainer/patterns/"..folder.."/"..tostring(l).."_"..tostring(g)..".dat", "r")
				if file then
					valid = true
					-- store the starting level and group associated with the level
					group[l] = {l, g}

					local _i = 0
					for line in file:lines() do 
						if line ~= prev_line then
							pattern[_i + (l * 100000)] = line
							_i = _i + 1
							prev_line = line
						end
					end				
					file:close()
					break
				end
			end
			if group[l] == nil then 
				group[l] = group[l - 1]  -- use previous pattern for this level
			end
		end
		perfect = string.find(folder, "perfect") ~= nil
		lag_pixels = LAG_PIXELS_DEFAULT + (perfect and 1 or 0)
		loaded = true				
	end
	
	function pattern_toggle()
		-- Check for pattern change when P2 key press is detected
		if mode == 1 and state == 0 then
			mac:popmessage("Using '"..string.upper(folder).."' patterns.  Push 'P2' to toggle.")		
		end
		
		if scr:frame_number() > switch + 30 and string.sub(integer_to_binary(mem:read_u8(0x5040)), 2, 2) == "0" then
			folder = get_next(SETS, folder)
			pactrainer_patterns()
			if not(mode == 1 and state == 0) then
				mac:popmessage("Switched to '"..string.upper(folder).."' patterns.  Active from next level start.")
			end
			switch = scr:frame_number()
			
			-- save as default
			file = io.open("plugins/pactrainer/patterns/active.dat", "w")
			if file then
				file:write(folder)
				file:close()
			end
		end
	end
	
	function reset()
		seq = 0
		failed, lagging, ignore, freestyle = false, false, false, false
	end

	function write_bytes(address, b1, b2, b3, b4, b5)
		--write 5 bytes to video memory at starting address
		--horizontal text if offset by -0x20, vertical by 0x01
		if loaded then
			for k, v in ipairs({b1, b2, b3, b4, b5}) do
				if v then
					mem:write_u8(address - ((k - 1) * 0x20), v)
				end
			end
		end
	end
	
	function integer_to_binary(x)
		local ret = ""
		while x~=1 and x~=0 do
			ret = tostring(x%2) .. ret
			x=math.modf(x/2)
		end
		return string.format("%08d", tostring(x)..ret)
    end
	
	function display_status()
		if loaded then
			local _sub = string.sub
			local _lev = string.format("%03d", level)
			local _grp = string.format("%02d", patgroup)
			local _lag, _s3, _s4, _s5

			--level info
			write_bytes(0x43ac, 0x4c, 0x25, tonumber(_sub(_lev, 1, 1)) + 0x30, tonumber(_sub(_lev, 2, 2)) + 0x30, tonumber(_sub(_lev, 3, 3)) + 0x30)
			--pattern info
			write_bytes(0x43b2, 0x50, 0x25, tonumber(_sub(_grp, 1, 1)) + 0x30, tonumber(_sub(_grp, 2, 2)) + 0x30, 0x40)	
			--status info
			if mem:read_u8(0x40cc) ~= 0x53 then
				write_bytes(0x40cc, 0x53, 0x25, 0x41, 0x43, 0x45)
			end
			if lagx or lagy or failed then
				if lagging or failed then
					_s3, _s4, _s5 = 0x42, 0x41, 0x44
				else
					if lagx > lagy then _lag = lagx else _lag = lagy end
					if _lag <= 1 then
						_s3, _s4, _s5 = 0x41, 0x43, 0x45
					else
						_s3, _s4, _s5 = 0x4f, 0x4b, 0x40
					end
				end
				if scr:frame_number() % 30 == 0 then
					write_bytes(0x40cc, 0x53, 0x25, _s3, _s4, _s5)
				end
			end
			-- freestyle time or failed (flash on fail)
			if freestyle then
				write_bytes(0x40cc, 0x53, 0x25, 0x46, 0x3a, 0x53)
				write_bytes(0x40b2, 0x46, 0x52, 0x45, 0x45)
			elseif failed then
				if scr:frame_number() % 40 < 20 then
					write_bytes(0x40b2, 0x46, 0x41, 0x49, 0x4c)
				else
					write_bytes(0x40b2, 0x40, 0x40, 0x40, 0x40)
				end
			end			
		end
	end
	
	function pactrainer_main()
		if mem and not mac.paused then									
			if not loaded then
				if  scr:frame_number() > 300 then
					-- Load patterns after pacman has fully booted
					pactrainer_patterns()
					if not valid then
						print("Patterns are not found")
						mac:exit()
					end
				end
			else				
				mode = mem:read_u8(0x4e00)
				state = mem:read_u8(0x4e04)
				pacx = mem:read_u8(0x4d09)
				pacy = mem:read_u8(0x4d08)
				level = mem:read_u8(0x4e13) + 1
				pills = mem:read_u8(0x4e0e)						

				pattern_toggle()	
									
				if mode == 3 then
					patid, patgroup = group[level][1], group[level][2]
					
					if (state == 3 and oldstate ~= 3) or state == 36 then
						reset()
					end

					if state == 3 then
						if seq == 0 and pills > 0 then
							failed = true
							seq = 99999
						end
					end

					if not failed then
						first = true
						adjusted = false
						
						data = pattern[(patid * 100000) + seq]
						
						--Debugging---------
						--print(data)
						--ignore = true
						--print(pacy, pacx)
						--------------------
						
						-- Perfect pattern folders should include the term perfect
						-- We won't adjust the path as all ghosts are intended to be eaten
						if perfect then
							ignore = true
						end						
						
						if not (state > 12 and state < 36) then
						
							if data == "------" then
								-- Ignore lagging behind when turning back on self
								ignore = true
								data = nil
							elseif data == "++++++" then
								-- Reactivate lagging
								ignore = false
								data = nil
							elseif data == "######" then
								-- For partial patterns, turn the path yellow to indicate freestyle to complete the board													
								freestyle = true
								data = nil
							elseif data and #data > 6 and string.sub(data, 1, 6) == "REMARK" then
								-- Display an instruction to assist at current pattern position
								mac:popmessage(string.sub(data, 8, #data))
								data = nil
							end
							
							for _f = seq + 80, seq, -1 do
								local data = pattern[(patid * 100000) + _f]																					
								if data then
									paty, patx = tonumber(string.sub(data, 1, 3)), tonumber(string.sub(data, 4, 6))
									if paty and patx then
										if (seq - _f) % 5 == 0 then
											-- draw every 5th line segment
											
											local _color = GREEN
											if freestyle then 
												_color = YELLOW 
											elseif lagging then 
												_color = RED 
											end										
											scr:draw_box(paty+15, patx-15, paty+16, patx-16, _color, _color)
											if first then
												scr:draw_box(paty+14, patx-14, paty+17, patx-17, _color, _color)
												first = false
											end						
										end
										if not ignore and state == 3 and patx == pacx and paty == pacy and _f - seq > 0 then
											-- Pacman has speeded ahead of pattern (by eating a ghost).  Make an adjustment.
											seq = seq + (_f - seq)
											adjusted = true
										end
									end
								end
							end
						
							if state == 3 and (pacx ~= oldpacx or pacy ~= oldpacy) then
								seq = seq + 1
							end
						
							if state == 3 and paty and patx then
								if state == 3 and (not adjusted and not ignore) or perfect then									
									-- Are we behind the pattern?
									lagx = math.abs(patx - pacx)
									lagy = math.abs(paty - pacy)
									if (lagx >= lag_pixels and lagx < 100) or lagy >= lag_pixels then
										lagging = true
									end
								end
							end
						
							oldpacx, oldpacy = pacx, pacy
						end
					end
		
					display_status()
				else
					reset()
				end
				oldstate = state
			end
		end
	end

	if emu.app_version() >= "0.256" then	
		pactrainer_postload = emu.add_machine_post_load_notifier(reset)
		pactrainer_initialize = emu.add_machine_reset_notifier(pactrainer_initialize)
	else
		emu.register_start(function() reset() end)
		emu.register_prestart(function() pactrainer_initialize() end)		
	end
		
	emu.register_frame_done(function() pactrainer_main() end)
	
end
return exports