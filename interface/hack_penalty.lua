-- DKAFE Penalty Hack
-- Lose a set number of penalty points instead of lives. Penalty points are displayed top left and will flash when there are not enough points to survive.
-- Drives the "DK Last Man Standing" hack 

function get_dipswitch()
	DSW0 = ports[":DSW0"]
	for field_name, field in pairs(DSW0.fields) do
		if field_name == "Bonus Life" then
			dipswitch = number_to_binary(field.port:read())
		end
	end
	return dipswitch
end

function get_score()
	-- read the score data from ram and convert to a number
	score1 = tonumber(string.format("%x", mem:read_i8(0xc60b4)))
	score2 = tonumber(string.format("%x", mem:read_i8(0xc60b3)))
	score3 = tonumber(string.format("%x", mem:read_i8(0xc60b2)))
	score = 0
	if score1 ~= nil then score = score + (score1 * 10000) end
	if score2 ~= nil then score = score + (score2 * 100) end
	if score3 ~= nil then score = score + score3 end
	return score
end

function set_score(score)
	padded_score = string.format("%06d", score)
	-- update score in ram
	score1 = string.sub(padded_score, 1, 2)
	score2 = string.sub(padded_score, 3, 4)
	score3 = string.sub(padded_score, 5, 6)
	mem:write_i8(0xc60b4, tonumber(score1, 16))
	mem:write_i8(0xc60b3, tonumber(score2, 16))
	mem:write_i8(0xc60b2, tonumber(score3, 16))
	-- update score on screen
	write_message(0xc7781, padded_score) -- update screen as it otherwise may not be updated
end


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
end


if mem:read_i8(0xc600F) == 0 then                 -- 0 is a 1 player game
	dip = string.sub(get_dipswitch(),7,8)         -- use number of lives dip to set penalty points
	if dip == "00" then
		penalty_points = 25000
	elseif dip == "01" then
		penalty_points = 50000
	elseif dip == "10" then
		penalty_points = 75000
	elseif dip == "11" then
		penalty_points = 90000
	end
	
	score = get_score()
	jumpman_status = mem:read_i8(0xc6200)         -- 1 = alive, 0 = dead

	--Force remaining lives to 2 (so we can lose lives without ending the game if necessary)
	mem:write_i8(0xc6020, 2)	

	-- Clear the standard bonus life award as it's not needed
	mem:write_i8(0xc6021, 0)	

	-- Check if life was lost and sufficient points for penalty are available
	if mode1 == 3 and mode2 >= 0xc and jumpman_status == 0 then	
		-- deduct penalty from score
		if score >= penalty_points then
			set_score(score - penalty_points)
			
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
	if score >= penalty_points or blink_toggle ~= 16 then
		write_message(0xc77a3, "@=     ")
		write_message(0xc77a3, "@="..tonumber(penalty_points))
	else
		write_message(0xc77a3, "       ")
	end
end