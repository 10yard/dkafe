-- Penalty Points Hack
-- Lose a set number of points instead of lives

penalty_intot = 3                       -- life cost in tens of thousands (1 - 9)
game_mode = mem:read_i8(0xc6005)        -- 3 = playing the game
lives_remaining = mem:read_i8(0xc6228)

--Force lives to 2
mem:write_i8(0xc6020, 2)	
mem:write_i8(0xc6040, 2)	
mem:write_i8(0xc6228, 2)

-- Clear the standard bonus life award as not needed
mem:write_i8(0xc6021, 0)	

-- Check if life was lost and sufficient points for penalty
if game_mode == 3 and lives_remaining < 2 then
    -- deduct penalty from score
	score_intot = mem:read_i8(0xc60B4)
	if score_intot >= penalty_intot then
		-- score is held in #6084, #6083, #6082
		-- we are only concerned with tens of thousands in first byte
		mem:write_i8(0xc60B4, score_intot - penalty_intot)

		-- display score appears in #7781, #7761, #7741, #7721, #7701, #76E1
		-- we are only concerned with first 2 bytes
		digits = string.format("%02d", score_intot - penalty_intot)
   	    mem:write_i8(0xc7781, string.sub(digits, 1, 1))
	    mem:write_i8(0xc7761, string.sub(digits, 2, 2))
	else
mem:write_i8(0xc6020, 1)	
mem:write_i8(0xc6040, 1)	
mem:write_i8(0xc6228, 1)
	end
end

-- Display jumpman penalty instead of the remaining lives
mem:write_i8(0xc77A3, 255) -- Jumpman icon
mem:write_i8(0xc7783, 52)  -- Equals sign
mem:write_i8(0xc7763, penalty_intot)
mem:write_i8(0xc7743, 00)  -- 0
mem:write_i8(0xc7723, 27)  -- K
mem:write_i8(0xc7703, 10)  --
mem:write_i8(0xc76E3, 10)  --

