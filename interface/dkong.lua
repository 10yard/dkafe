--[[
#      ___   ___                    .-.
#     (   ) (   )                  /    \
#   .-.| |   | |   ___     .---.   | .`. ;    .--.
#  /   \ |   | |  (   )   / .-, \  | |(___)  /    \
# |  .-. |   | |  ' /    (__) ; |  | |_     |  .-. ;
# | |  | |   | |,' /       .'`  | (   __)   |  | | |
# | |  | |   | .  '.      / .'| |  | |      |  |/  |
# | |  | |   | | `. \    | /  | |  | |      |  ' _.'
# | '  | |   | |   \ \   ; |  ; |  | |      |  .'.-.
# ' `-'  /   | |    \ .  ' `-'  |  | |      '  `-' /  Donkey Kong Arcade Frontend
#  `.__,'   (___ ) (___) `.__.'_. (___)      `.__.'   by Jon Wilson

 DKAFE Interface for Donkey Kong
------------------------------------------------------------------------------------------------
 Set target score, registered player names and player scores.
 Dump highscore to file when finished.
 Show prizes and progress in the game (optional).
 Enable some DKAFE specific hacks (optional).
------------------------------------------------------------------------------------------------
]]

data_includes_folder = os.getenv("DATA_INCLUDES")
package.path = package.path .. ";" .. data_includes_folder .. "/?.lua;"
require "functions"
require "graphics"
require "globals"

-- Register function for each frame
------------------------------------------------------------------------------------------------
emu.register_frame(function()
	_, loaded = pcall(get_loaded)
  
	if loaded == nil then
		-- Update ROM on start
		emu["loaded"] = 1
		for key, value in pairs(rom_scores) do
			mem:write_direct_i8(value, data_scores[key])				
		end
	end
  
	if loaded == 1 then
    if data_allow_skip_intro == "1" and emu.romname() == "dkongx" then 
      -- quickly skip past startup screen of DK2
      max_frameskip(1) 
    end
		-- Update RAM when ready	
		if mem:read_i8(ram_players[1]) > 0 and ( emu.romname() ~= "dkongx" or mem:read_i8("0xc0000") < 0 ) then
			emu["loaded"] = 2
			for key, value in pairs(ram_high) do
				mem:write_i8(value, data_high[key])				
			end						
			for key, value in pairs(ram_high_DOUBLE) do
				mem:write_i8(value, data_high_DOUBLE[key])				
			end
			for key, value in pairs(ram_scores) do
				mem:write_i8(value, data_scores[key])
			end
			for key, value in pairs(ram_scores_DOUBLE) do
				mem:write_i8(value, data_scores_DOUBLE[key])				
			end		
			for key, value in pairs(ram_players) do
				mem:write_i8(value, data_players[key])
			end
		end
	end
  
	if loaded == 2 then
    -- Reset frameskip after fast start of DK2
    if data_allow_skip_intro == "1" and emu.romname() == "dkongx" then 
      max_frameskip(0) 
    end
		-- Optionally set number of coins inserted into the machine
		if tonumber(data_credits) > 0 and tonumber(data_credits) < 90 then
			mem:write_i8(0x6001, data_credits)
		end
		-- Optionally start the game by pressing P1 start.
		if data_autostart == "1" then
			ports[":IN2"].fields["1 Player Start"]:set_value(1)
		end
		emu["loaded"] = 3
	end
  
	if loaded == 3 then
		mode1 = mem:read_i8(0xc6005)  -- 1-attract mode, 2-credits entered waiting to start, 3-when playing game    
		mode2 = mem:read_i8(0xc600a)  -- Status of note: 7-climb scene, 10-how high, 15-dead, 16-game over 
		stage = mem:read_i8(0xc6227)  -- 1-girders, 2-pie, 3-elevator, 4-rivets, 5-extra/bonus
		score = get_score()
              
    -- Release P1 Start button (after autostart)
		if data_autostart == "1" then
			if mode1 == 3 and mode2 == 7 then
				ports[":IN2"].fields["1 Player Start"]:set_value(0)
				data_autostart = "0"
			end
		end
    
    -- Fast skip through the DK climb scene when jump button is pressed (optional)
    fast_skip_intro()
				    
		-- Show award targets and progress during gameplay (optional)
		display_awards()

		-- Optional hacks
		if hack_teleport == "1" then
			dofile(data_includes_folder.."/hack_teleport.lua")
		elseif hack_nohammers == "1" then
			dofile(data_includes_folder.."/hack_nohammers.lua")
		end
		if hack_lava == "1" then
			dofile(data_includes_folder.."/hack_lava.lua")
		end
		if hack_penalty == "1" then
			dofile(data_includes_folder.."/hack_penalty.lua")
		end
	end
end)


-- Register callback function on exit
------------------------------------------------------------------------------------------------
emu.register_stop(function()
  record_in_compete_file()
end)
