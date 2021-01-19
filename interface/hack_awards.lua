-- Display score awards during the DK intro
dkclimb = mem:read_i8(0xc638e)
if dkclimb > 0 then
	--display awards text
	if dkclimb == 20 then
		write_message(0xc7774, data_bonus_score.." SCORE")
		write_message(0xc7574, data_bonus_award.." COINS")
	elseif dkclimb == 25 then
		write_message(0xc7778, data_min_score.." SCORE")
		write_message(0xc7578, data_min_award.." COINS")
	elseif dkclimb == 30 then
		write_message(0xc777c, "PLAY TO WIN")
		write_message(0xc777d, "   COINS   ")
	end
		
	--clear awards text
	dkbounce = mem:read_i8(0xc638d)
	if dkbounce == 4 then
		write_message(0xc7774, "           ")	
		write_message(0xc7574, "           ")
	elseif dkbounce == 3 then
		write_message(0xc7778, "           ")
		write_message(0xc7578, "           ")
	elseif dkbounce == 2 then
		write_message(0xc777c, "           ")
		write_message(0xc777d, "           ")
	end

end
