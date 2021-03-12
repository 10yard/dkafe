-- DKAFE Block and Text Graphics by Jon Wilson
------------------------------------------------------------------------

-- Optimise access to globals used in functions
local string_sub = string.sub
local string_len = string.len
local math_floor = math.floor
local math_fmod = math.fmod

function draw_block(x, y, color1, color2)
  -- Draw a single block
	screen:draw_box(x, y, x+8, y+8, color1, 0)
	screen:draw_box(x, y, x+1, y+8, color2, 0)
	screen:draw_box(x+6, y, x+7, y+8, color2, 0)
	screen:draw_box(x+2, y+2, x+6, y+6, 0xcff000000, 0)
	screen:draw_box(x+3, y+1, x+5, y+7, 0xcff000000, 0)
end

function block_text(text, x, y, color1, color2)
	-- Write large block characters made up from individual blocks (using draw_block)
  local _dkblock = dkblock
	local _x, _y, width, blocks = x, y, 0, ""
	for i=1, string_len(text) do 
		blocks = _dkblock[string_sub(text, i, i)]
		width = math_floor(string_len(blocks) / 5)
		for b=1, string_len(blocks) do
			if string_sub(blocks, b, b) == "#" then
				draw_block(_x, _y, color1, color2)
			end
			if math_fmod(b, width) == 0 then
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

function write_message(start_address, text)
	-- write characters of message to DK's video ram
  local _dkchars = dkchars
  for key=1, string_len(text) do
		mem:write_i8(start_address - ((key - 1) * 32), _dkchars[string_sub(text, key, key)])
	end
end

-- Characters
dkchars = {}
dkchars["0"] = 0x00
dkchars["1"] = 0x01
dkchars["2"] = 0x02
dkchars["3"] = 0x03
dkchars["4"] = 0x04
dkchars["5"] = 0x05
dkchars["6"] = 0x06
dkchars["7"] = 0x07
dkchars["8"] = 0x08
dkchars["9"] = 0x09
dkchars[" "] = 0x10
dkchars["A"] = 0x11
dkchars["B"] = 0x12
dkchars["C"] = 0x13
dkchars["D"] = 0x14
dkchars["E"] = 0x15
dkchars["F"] = 0x16
dkchars["G"] = 0x17
dkchars["H"] = 0x18
dkchars["I"] = 0x19
dkchars["J"] = 0x1a
dkchars["K"] = 0x1b
dkchars["L"] = 0x1c
dkchars["M"] = 0x1d
dkchars["N"] = 0x1e
dkchars["O"] = 0x1f
dkchars["P"] = 0x20
dkchars["Q"] = 0x21
dkchars["R"] = 0x22
dkchars["S"] = 0x23
dkchars["T"] = 0x24
dkchars["U"] = 0x25
dkchars["V"] = 0x26
dkchars["W"] = 0x27
dkchars["X"] = 0x28
dkchars["Y"] = 0x29
dkchars["Z"] = 0x2a
dkchars["."] = 0x2b
dkchars["-"] = 0x2c
dkchars[":"] = 0x2e
dkchars["<"] = 0x30
dkchars[">"] = 0x31
dkchars["="] = 0x34
dkchars["$"] = 0x36  -- double exclamations !!
dkchars["!"] = 0x38
dkchars["'"] = 0x3a
dkchars[","] = 0x43
dkchars["["] = 0x49 -- copyright part 1
dkchars["]"] = 0x4a -- copyright part 2
dkchars["("] = 0x4b -- ITC part 1
dkchars[")"] = 0x4c -- ITC part 2
dkchars["^"] = 0xb0 -- rivet block
dkchars["?"] = 0xfb
dkchars["@"] = 0xff -- extra mario icon

-- Block characters
dkblock = {}
dkblock["A"] = "####.#####.##.#"
dkblock["B"] = "##.#.###.#.###."
dkblock["C"] = "####..#..#..###"
dkblock["D"] = "##.# ## ## ###."
dkblock["E"] = "####..####..###"
dkblock["F"] = "####--####--#--"
dkblock["G"] = "#####---#-###--#####"
dkblock["H"] = "#.##.#####.##.#"
dkblock["I"] = "###.#..#..#.###"
dkblock["J"] = "###-#--#--#-##-"
dkblock["K"] = "#..##.#.###.#.#.#..#"
dkblock["L"] = "#..#..#..#..###"
dkblock["M"] = "#...###.###.#.##.#.##.#.#"
dkblock["N"] = "#..###.######.###..#"
dkblock["O"] = "####.##.##.####"
dkblock["P"] = "####.#####..#.."
dkblock["Q"] = "####-#--#-#--#-#-##-#####"
dkblock["R"] = "####-######-#-#"
dkblock["S"] = "####..###..####"
dkblock["T"] = "###.#..#..#..#."
dkblock["U"] = "#-##-##-##-####"
dkblock["V"] = "#-##-##-##-#-#-"
dkblock["W"] = "#.#.##.#.##.#.###.###...#"
dkblock["X"] = "#-##-#-#-#-##-#"
dkblock["Y"] = "#-##-##-#-#--#-"
dkblock["Z"] = "####--#--#--#---####"
dkblock[" "] = "     "
dkblock["!"] = " # # #   #"
dkblock["'"] = "##   "
dkblock["1"] = "##--#--#--#-###"
dkblock["2"] = "###--#####--###"
dkblock["3"] = "###--####--####"
dkblock["4"] = "#---#---#-#-####--#-"
dkblock["5"] = "####--###--####"
dkblock["6"] = "####--####-####"
dkblock["7"] = "###--#-#--#--#-"
dkblock["8"] = "####-#####-####"
dkblock["9"] = "####-####--#--#"
