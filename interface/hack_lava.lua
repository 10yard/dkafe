--[[
#      ___   ___                    .--.
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

 DKAFE Lava Hack
------------------------------------------------------------------------------------------------
 Drives features of the "DK Lava Panic" hack:
 Jumpman must keep his cool and move quickly to avoid the rising Lava.
------------------------------------------------------------------------------------------------
]]

local math_floor = math.floor
local math_fmod = math.fmod
local math_random = math.random
function draw_lava()

-- Before and after gameplay
------------------------------------------------------------------------------------------------
	if mode2 == 7 or mode2 == 10 or mode2 == 11 or mode2 == 1 then    
    -- recalculate difficulty at start of level or when in attract mode
    local level = mem:read_i8(0xc6229)
    lava_difficulty = math_floor(1.2 * (22 - level))
    if stage == 4 then
      lava_difficulty = math_floor(1.5 * (22 - level))  -- more time for rivets
    elseif stage == 3 then
      lava_difficulty = math_floor(0.75 * (22 - level))  -- less time for elevators
    end    
    -- reset lava level
		lava_y = -7
    -- remember default music
		music = mem:read_i8(0xc6089)
	elseif mode2 == 21 and lava_y > 15 then
    -- Reduce lava level on high score entry screen to avoid obstruction.
		lava_y = 15
	elseif mode2 == 16 and lava_y > 60 then
    -- Reduce lava level on game over screens to avoid obstruction.    
		lava_y = 60
	end
	
------------------------------------------------------------------------------------------------
-- During gameplay
------------------------------------------------------------------------------------------------
	if mode1 == 3 or (mode1 == 1 and mode2 >= 2 and mode2 <= 4) then
		-- draw rising lava
		screen:draw_box(0, 0, lava_y, 224, 0xddff0000, 0)
		
		if mode2 == 12 or (mode1 == 1 and mode2 >= 2 and mode2 <= 3) then	
			jumpman_y = get_jumpman_y()
			if lava_y + 10 > jumpman_y then
        -- Issue warning to Jumpman
        
				-- Dim the screen above lava flow
				screen:draw_box(256, 224, lava_y, 0, 0xc77990000, 0)
				
				-- Flash colour palette for dramatic effect
				if toggle() == 1 then
					mem:write_i8(0xc7d86, 1)
					block_text("PANIC!", 128, 16, 0xcffEE7511, 0xcffF5BCA0) 					
				else					
					mem:write_i8(0xc7d86, 0)
				end

				-- Temporary change to music for added drama
				if stage ~= 2 then
					mem:write_i8(0xc6089, 9)
				else
					mem:write_i8(0xc6089, 11)
				end
			else
				-- Reset palette to default
				if stage == 1 or stage == 3 then
					mem:write_i8(0xc7d86, 0)
				else
					mem:write_i8(0xc7d86, 1)
				end
				-- Set music back to default
				mem:write_i8(0xc6089, music)
			end
		
			if lava_y > jumpman_y + 1 then
				-- The lava has engulfed Jumpman. Set status to dead
				mem:write_i8(0xc6200, 0)
			elseif math_fmod((mem:read_i8(0xc601A)), lava_difficulty) == 0 then
				-- Game is active.  Lava rises periodically based on the lava_difficulty
				if mem:read_i8(0xc6350) == 0 then
					-- Lava shouldn't rise when an item is being smashed by the hammer
					lava_y = lava_y + 1
				end
			end
		end
						
		-- Add dancing flames above lava
		for k, i in pairs({8, 24, 40, 56, 72, 88, 104, 120, 136, 152, 168, 184, 200, 216}) do
      local adjust_y = math_random(-3, 3)
			local flame_y = lava_y + adjust_y
			local flame_color = ORANGE
			if flame_y > 0 then
			  if adjust_y > 0  then 
          flame_color = ORANGE
				else
          flame_color = RED
        end
        -- Draw flame graphic
       	screen:draw_box(flame_y + 0, i - 0, flame_y + 1, i - 1, flame_color)
       	screen:draw_box(flame_y + 1, i - 1, flame_y + 2, i - 2, flame_color)
       	screen:draw_box(flame_y + 2, i - 2, flame_y + 3, i - 3, flame_color)
       	screen:draw_box(flame_y + 3, i - 1, flame_y + 4, i - 2, flame_color)
       	screen:draw_box(flame_y + 4, i - 0, flame_y + 5, i - 1, flame_color)
       	screen:draw_box(flame_y + 5, i - 1, flame_y + 6, i - 2, flame_color)
      end
		end
	end
end

-- Program start
------------------------------------------------------------------------------------------------
if loaded == 3 then
	if lava_hack_started ~= 1 then
		--register the frame drawing callbackz
		emu.register_frame_done(draw_lava, "frame")
	end
	lava_hack_started = 1
end