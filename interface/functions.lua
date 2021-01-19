function string:split(sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end
      
function get_formatted_data(var_name)
	-- read environment variable and convert comma separated values to a table
	local content = os.getenv(var_name)
	if content ~= nil then
		content = content:split(",")
	else content = {}
	end
	return content
end   

function get_loaded()
	return emu["loaded"]
end   

function query_highscore()
	local highscore = ""
	if emu.romname() == "dkongx11" or data_subfolder == "dkongrdemo" then
		for key, value in pairs(ram_scores) do
			if key <= 7 then
				highscore = highscore .. mem:read_i8(value)
			end
		end	
	else
		for key, value in pairs(ram_high) do
			highscore = highscore .. mem:read_i8(value)
		end	
		if highscore == "161616161616" then 
			highscore = "000000" 
		end
	end
	return highscore
end


function sleep(n)  -- seconds
   local clock = os.clock
   local t0 = clock()
   while clock() - t0 <= n do
   end
end

function draw_block(x, y, color1, color2)
	black = 0xcff000000
	s = manager:machine().screens[":screen"]
	s:draw_box(x, y, x+8, y+8, color1, 0)
	s:draw_box(x, y, x+1, y+8, color2, 0)
	s:draw_box(x+6, y, x+7, y+8, color2, 0)
	s:draw_box(x+2, y+2, x+6, y+6, black, 0)
	s:draw_box(x+3, y+1, x+5, y+7, black, 0)
end

function get_block_character(char)
	-- data for the large block characters
	blocks = ""
	width = 3
	if char == "A" then 
		blocks = "####.#####.##.#"
	elseif char == "B" then
		blocks = "##.#.###.#.###." 
	elseif char == "C" then
		blocks = "####..#..#..###"
	elseif char == "D" then
		blocks = "##.# ## ## ###."
	elseif char == "E" then
		blocks = "####..####..###"
	elseif char == "H" then
		blocks = "#.##.#####.##.#"
	elseif char == "I" then
		blocks = "###.#..#..#.###"
	elseif char == "K" then
		blocks = "#..##.#.###.#.#.#..#"
		width = 4
	elseif char == "L" then
		blocks = "#..#..#..#..###"
	elseif char == "O" then
		blocks = "####.##.##.####"
	elseif char == "P" then
		blocks = "####.#####..#.."
	elseif char == "M" then
		blocks = "#...###.###.#.##.#.##.#.#"
		width = 5
	elseif char == "N" then
		blocks = "#..###.######.###..#"
		width = 4
	elseif char == "S" then
		blocks = "####..###..####"
	elseif char == "T" then
		blocks = "###.#..#..#..#."
	elseif char == "W" then
		blocks = "#.#.##.#.##.#.###.###...#"
		width = 5
	elseif char == " " then
		blocks = "     "
		width = 1
	elseif char == "!" then
		blocks = " # # #   #"
		width = 2
	elseif char == "'" then
		blocks = "##   "
		width = 1
	end
	return blocks, width
end

function block_text(text, x, y, color1, color2)
	-- Write large block characters
	_x = x
	_y = y
	s = manager:machine().screens[":screen"]
	for i=1, string.len(text) do 
		_char = string.sub(text, i, i)
		blocks, width = get_block_character(_char)
		for b=1, string.len(blocks) do
			if string.sub(blocks, b, b) == "#" then
				draw_block(_x, _y, color1, color2)
			end
			if math.fmod(b, width) == 0 then
				_y = _y - (width - 1) * 8 
				_x = _x - 8
			else
				_y = _y + 8
			end
		end
		_x = x
		_y = _y + (width * 8) + 8
	end
end

function toggle()
	-- Sync with flashing 1UP
	--if mem:read_i8(0xc7720) == 16 then
	if math.fmod(mem:read_i8(0xc601a) + 128, 32) <= 16 then	
		return 1
	else
		return 0
	end
end

function write_message(start_address, text)
	-- write characters of message to DK's video ram
	for key=1, string.len(text) do
		_char = string.sub(text, key, key)
		mem:write_i8(start_address - ((key - 1) * 32), dkchars[string.sub(text, key, key)])
	end
end


