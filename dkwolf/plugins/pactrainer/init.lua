--Pattern Trainer for Pac-Man
--by Jon Wilson (10yard)
--
--The Pac-Man Trainer is an aid to learning the common patterns for completing boards.  
--You follow an on-screen path through each board.  For the pattern to hold,  you must
--stay on track and turn the corners quickly.  
--The HUD shows you some information which can help you on your way during gameplay.  
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
--Pacstrats set:
--    Use only three patterns to clear boards 1 through 255 and get to the kill screen!
--    Pattern 1 is used on boards 1 through 4
--    Pattern 2 is used on boards 5 through 20
--    Pattern 3 is used on boards 21 through 255
--    All three patterns clear the entire board and get both prizes.
--	
--	  More information about following these patterns in the video at:
--	  https://www.youtube.com/watch?v=wKQy8LTTzC4
--    
--Killerclown set:
--    Uses 5 patterns but some of them are very similar so should be easier to learn.
--    These patterns are robust until near the end of each board.  You may then need to 
--    freestyle to tidy up the few remaining pellets on your own. 
--    Pattern 1 is for board 1 only.  It's freestyle near the end if you prefer.
--    Pattern 2 is for boards 2 through 4.  It's a slight variation from pattern 1.
--    Pattern 3 if for boards 5 through 16.
--    Pattern 4 is for boards 17, 19 and 20.  You may need to freestyle near the end.
--    Pattern 5 is for boards 21 through 255
--	
--	  More information about Killerclown's patterns is to be found at
--    https://www.mameworld.info/net/pacman/patterns.html
--
--Minimum start up arguments:
--    mame pacman -plugin pactrainer
--
--Compatible with all MAME versions from 0.226 upwards.
--Works with "pacman" and "puckman" roms only.
-----------------------------------------------------------------------------------------
local exports = {
	name = "pactrainer",
	version = "0.1",
	description = "Pac-Man Pattern Trainer",
	license = "GNU GPLv3",
	author = { name = "Jon Wilson (10yard)" } }

local pactrainer = exports

function pactrainer.startplugin()
	local mac, cpu, mem, scr
	local patx, paty, pacx, pacy, oldpacx, oldpacy, lagx, lagy
	local mode, level, patid, patgroup, maxgroup, state, pills, oldstate, folder
	local seq, switch = 0, 0
	local pattern, group = {}, {}
	local loaded, valid, first, failed, adjusted, lagging, ignore = false, false, false, false, false, false, false
	local YELLOW, RED = 0xff00ff00, 0xffff0000
	local LAG_PIXELS = 5
		
		
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
				
		-- look for the active pattern folder or use the default - pacstrats
		if not folder then
			file = io.open("plugins/pactrainer/patterns/active.dat", "r")
			if file then
				content = file:read("*all")
				if #content > 2 then
					folder = content
				end
				file:close()
			end
		end
		if not folder then folder = "pacstrats" end
														
		-- Each level can have a pattern but we want as few patterns as possible to help with learning
		-- If a pattern is not found then the previous level patterns is used.  This allows patterns to be grouped.
		-- Typically there will only be a few patterns like 1,2,3,4 are similar,  5-20 are all the same,  21+ are all the same		
		pattern = {}
		for l=1, 256 do
			for g=1, 21 do
				file = io.open("plugins/pactrainer/patterns/"..folder.."/"..tostring(l).."_"..tostring(g)..".dat", "r")
				if file then
					valid = true
					-- store the starting level and group associated with the level
					group[l] = {l, g}
					maxgroup = g
					
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
		loaded = true				
	end
	
	function pattern_toggle()
		-- Check for pattern change when P2 key press is detected
		if mode == 1 and state == 0 then
			mac:popmessage("Using '"..string.upper(folder).."' patterns.  Push 'P2' to toggle.")		
		end
		
		if scr:frame_number() > switch + 30 and string.sub(integer_to_binary(mem:read_u8(0x5040)), 2, 2) == "0" then
			if folder == "pacstrats" then
				folder = "killerclown"
			else
				folder = "pacstrats"
			end
			pactrainer_patterns()
			if not(mode == 1 and state == 0) then
				mac:popmessage("Switched to '"..string.upper(folder).."' patterns.  Active from next level start.")
			end
			switch = scr:frame_number()
		end
	end
	
	function reset()
		seq = 0
		failed, lagging, ignore = false, false, false
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
		ret = tostring(x)..ret
		return string.format("%08d", ret)
    end
	
	function display_status()
		if loaded then
			--level info
			local _sub = string.sub
			local _lev = string.format("%03d", level)
			local _s3, s4, s5
			local _lag
			
			--level info
			write_bytes(0x43ac, 0x4c, 0x25, tonumber(_sub(_lev, 1, 1)) + 0x30, tonumber(_sub(_lev, 2, 2)) + 0x30, tonumber(_sub(_lev, 3, 3)) + 0x30)
			--pattern info
			write_bytes(0x43b2, 0x50, 0x25, patgroup + 0x30, 0x3a, maxgroup + 0x30)	
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
			-- failed info (flash on fail)
			if failed then
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
						
						-- Ignore lagging when pacman turns back on himself.  Look for ------ and +++++++ in data.
						if data == "------" then
							ignore = true
							data = nil
						elseif data == "++++++" then
							ignore = false
							data = nil
						end

						for _f = seq + 80, seq, -1 do
							local data = pattern[(patid * 100000) + _f]																					
							if data then
								paty, patx = tonumber(string.sub(data, 1, 3)), tonumber(string.sub(data, 4, 6))
								if paty and patx then
									if (seq - _f) % 5 == 0 then
										-- only draw every 5th line segment
										local _color = YELLOW
										if lagging then _color = RED end
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
						
						if paty and patx then
							if state == 3 and not adjusted and not ignore then
								-- Are we behind the pattern?
								lagx = math.abs(patx - pacx)
								lagy = math.abs(paty - pacy)
								if (lagx >= LAG_PIXELS and lagx < 100) or lagy >= LAG_PIXELS then
									lagging = true
								end
							end
						end
						
						oldpacx, oldpacy = pacx, pacy
					end
		
					display_status()
				else
					reset()
				end
				oldstate = state
			end
		end
	end

	function pactrainer_stop()
		if not folder then folder = "pacstrats" end
		file = io.open("plugins/pactrainer/patterns/active.dat", "w")
		if file then
			file:write(folder)
			file:close()
		end
	end

	if emu.app_version() >= "0.256" then	
		pactrainer_postload = emu.add_machine_post_load_notifier(reset)
		pactrainer_initialize = emu.add_machine_reset_notifier(pactrainer_initialize)
		pactrainer_stop = emu.add_machine_stop_notifier(pactrainer_stop)
	else
		emu.register_start(function() reset() end)
		emu.register_stop(function() pactrainer_stop() end)
		emu.register_prestart(function() pactrainer_initialize() end)		
	end
		
	emu.register_frame_done(function() pactrainer_main() end)
	
end
return exports