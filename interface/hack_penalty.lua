-- DKAFE Penalty Hack
---------------------
-- Lose a set number of penalty points instead of lives. 
-- Penalty points are displayed top left and will flash when there are not enough points to survive.
--
-- Drives the "DK Last Man Standing" hack:
-- You will lose penalty points instead of lives so don't make mistakes unless you have earned enough points to survive.
-- Press COIN button to stop playing and register your points - unless you want to go for a kill screen.

function dkonglastman_overlay()
	if mode1 == 1 and mode2 >= 6 and mode2 <= 7 then
		-- Title screen
		screen:draw_box(96, 16, 136, 208, BLACK, 0)
		screen:draw_box(152, 8, 198, 208, BLACK, 0)
		block_text("LAST", 184, 48, BLUE, CYAN) 
		block_text("MAN", 136, 48, BLUE, CYAN) 
		write_message(0xc76f4, "^^ STANDING ^^")
	end
end

-- PROGRAM START

if loaded == 3 and data_subfolder == "dkonglastman" then
	-- rom specific hack for DK Last Man Standing
	if lastman_hack_started ~= 1 then	
		-- Register callback function to add extra graphics
		emu.register_frame_done(dkonglastman_overlay, "frame")
	end
	lastman_hack_started = 1
  lastman_penalty_dips = {}
  lastman_penalty_dips["00"] = 25000
  lastman_penalty_dips["11"] = 40000
  lastman_penalty_dips["10"] = 60000
  lastman_penalty_dips["01"] = 75000
end

if mem:read_i8(0xc600F) == 0 then         -- 0 is a 1 player game
  if mode1 == 2 then
    -- Player finish flag is reset before game starts
    -- Player presses COIN to finish game and record their points - it's the only way to register points without reaching a killscreen
    player_finish = 0
  end
  
  penalty_points = lastman_penalty_dips[string.sub(number_to_binary(mem:read_i8(0xc7d80)), 7, 8)]  -- number of lives dip determines the penalty	
	jumpman_status = mem:read_i8(0xc6200)         -- 1 = alive, 0 = dead

	--Force remaining lives to 2 (so we can lose lives without ending the game if necessary)
	mem:write_i8(0xc6020, 2)	

	-- Clear the standard bonus life award as it's not needed
	mem:write_i8(0xc6021, 0)	

	-- Check if life was lost and sufficient points for penalty are available
	if mode1 == 3 and mode2 >= 0xc and jumpman_status == 0 and player_finish ~= 1 then	
		-- deduct penalty from score
		if score >= penalty_points then
			set_score(score - penalty_points)
			
      --set jumpman status to alive instead of dead
			mem:write_i8(0xc6200, 1)
			
			--set remaining lives to 2
			mem:write_i8(0xc6228, 2)			
		else
			set_score(0)
			--Force Game over
			--set remaining lives to 1
			mem:write_i8(0xc6228, 1)			
		end
	end

  -- Player ends game to keep current score by pressing COIN.
  if string.sub(number_to_binary(mem:read_i8(0xc7d00)), 1, 1) == "1" then
    mem:write_i8(0xc6228, 1)		
    mem:write_i8(0xc6200, 0)
    player_finish = 1
  end

	-- Display jumpman penalty instead of the remaining lives
	-- Flash when the penalty is greater than score to indicate player won't survive
	if score >= penalty_points or toggle("1UP") == 0 or (mode1 == 1 and mode2 == 1) then 
		write_message(0xc77a3, "@=     ")
		write_message(0xc77a3, "@="..tonumber(penalty_points))
	else
		write_message(0xc77a3, "       ")
	end
end