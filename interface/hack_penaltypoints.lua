-- DKAFE Penalty Points Hack
-- Lose a set number of points instead of lives

if mem:read_i8(0xc600F) == 0 then                 -- 0 is a 1 player game
	score_intot = mem:read_i8(0xc60B4)            -- score in tens of thousands part
	penalty_points = tonumber(hack_penaltypoints) -- penalty points to lose (in tens of thousands)
	jumpman_status = mem:read_i8(0xc6200)         -- 1 = alive, 0 = dead

	--Force remaining lives to 2
	mem:write_i8(0xc6020, 2)	

	-- Clear the standard bonus life award as it's not needed
	mem:write_i8(0xc6021, 0)	

	-- Check if life was lost and sufficient points for penalty
	if mode1 == 3 and mode2 >= 0xC and jumpman_status == 0 then	
		-- deduct penalty from score
		if score_intot >= penalty_points then
			-- score is held in #6084, #6083, #6082
			-- we are only concerned with tens of thousands in first byte
			mem:write_i8(0xc60B4, score_intot - penalty_points)

			-- display score appears in #7781, #7761, #7741, #7721, #7701, #76E1
			-- we are only concerned with first 2 bytes
			digits = string.format("%02d", score_intot - penalty_points)
			mem:write_i8(0xc7781, string.sub(digits, 1, 1))
			mem:write_i8(0xc7761, string.sub(digits, 2, 2))
			
   	        --set jumpman status to alive instead of dead
			mem:write_i8(0xc6200, 1)
			
			--set remaining lives to 2
			mem:write_i8(0xc6228, 2)			
		else
			--Force Game over
			--set remaining lives to 1
			mem:write_i8(0xc6228, 1)			
		end
	end

	-- Display jumpman penalty instead of the remaining lives
	-- Flash when the penalty is greater than score to indicate player won't survive
	blink_toggle = mem:read_i8(0xc7720) -- sync with the flashing 1UP 	
	if score_intot >= penalty_points or blink_toggle ~= 16 then
		mem:write_i8(0xc77A3, 255)
		mem:write_i8(0xc7783, 52)  -- Equals sign
		mem:write_i8(0xc7763, penalty_points)
		mem:write_i8(0xc7743, 00)  -- 0
		mem:write_i8(0xc7723, 27)  -- K
		mem:write_i8(0xc7703, 10)  --
		mem:write_i8(0xc76E3, 10)  --
	else
		mem:write_i8(0xc77A3, 10)
		mem:write_i8(0xc7783, 10)
		mem:write_i8(0xc7763, 10)
		mem:write_i8(0xc7743, 10) 
		mem:write_i8(0xc7723, 10) 
		mem:write_i8(0xc7703, 10)
		mem:write_i8(0xc76E3, 10)
	end
end

