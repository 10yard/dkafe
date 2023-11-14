-- Continue Plugin for MAME
-- by Jon Wilson (10yard)
--
-- A continue option appears before your game is over with a 10 second countdown timer.
-- Push P1-Start button to continue your game and your score will be reset.
-- A tally of the number of continues appears at the top of screen.
--
-- Tested with latest MAME version 0.242
-- Compatible with all MAME versions from 0.196
--
-- Minimum start up arguments:
--   mame mspacman -plugin continue
-----------------------------------------------------------------------------------------
local exports = {}
exports.name = "continue"
exports.version = "0.20"
exports.description = "Continue plugin"
exports.license = "GNU GPLv3"
exports.author = { name = "Jon Wilson (10yard)" }
local continue = exports

function continue.startplugin()
	-- mame system objects
	local mac, scr, cpu, mem

	-- general use variables
	local h_mode, h_start_lives, h_remain_lives
	local i_frame, i_stop, i_start, i_tally, i_attenuation
	local b_1p_game, b_game_restart, b_almost_gameover, b_reset_continue, b_reset_tally, b_show_tally, b_push_p1

	-- colours
	local BLK, WHT, RED, YEL, CYN, GRN = 0xff000000, 0xffffffff, 0xffff0000, 0xfff8f91a, 0xff14f3ff, 0xff1fff1f

	-- compatible roms with associated function and position data
	local rom_data, rom_table = {}, {}
	local r_function, r_tally_yx, r_yx, r_color, r_flip, r_rotate, r_scale, r_tally_colors
	-- supported rom name     function       tally yx    msg yx    col  flip   rotate scale
	rom_table["asteroid"]   = {"aster_func", {008,008}, {540,240}, WHT, false, true,  2}
	rom_table["berzerk"]    = {"bzerk_func", {-01,001}, {160,072}, YEL, true,  true,  1}
	rom_table["bzone"]      = {"bzone_func", {008,008}, {320,160}, WHT, true,  true,  1}
	rom_table["centiped"]   = {"centi_func", {001,001}, {102,054}, GRN, false, false, 1}
	rom_table["cclimber"]   = {"climb_func", {010,049}, {156,080}, CYN, true,  true,  1}
	rom_table["defender"]   = {"dfend_func", {000,001}, {188,080}, YEL, true,  true,  1}
	rom_table["ckong"]      = {"ckong_func", {234,009}, {096,044}, CYN, false, false, 1}
	rom_table["ckongpt2"]   = {"ckong_func", {234,009}, {096,044}, CYN, false, false, 1}
	rom_table["ckongpt2b"]  = {"ckong_func", {234,009}, {096,044}, CYN, false, false, 1}
	rom_table["bigkong"]    = {"ckong_func", {234,009}, {096,044}, CYN, false, false, 1}
	rom_table["ckongs"]     = {"ckgal_func", {052,216}, {328,032}, WHT, true,  false, 3}
	rom_table["dkong"]      = {"dkong_func", {234,009}, {096,044}, CYN, false, false, 1}
	rom_table["dkongx"]     = {"dkong_func", {234,009}, {096,044}, CYN, false, false, 1}
	rom_table["dkongx11"]   = {"dkong_func", {234,009}, {096,044}, CYN, false, false, 1}
	rom_table["dkongpe"]    = {"dkong_func", {234,009}, {096,044}, CYN, false, false, 1}
	rom_table["dkonghrd"]   = {"dkong_func", {234,009}, {096,044}, CYN, false, false, 1}
	rom_table["dkongf"]     = {"dkong_func", {234,009}, {096,044}, CYN, false, false, 1}
	rom_table["dkongj"]     = {"dkong_func", {234,009}, {096,044}, CYN, false, false, 1}
	rom_table["dkongjr"]    = {"dkong_func", {234,002}, {096,044}, YEL, false, false, 1}
	rom_table["frogger"]    = {"frogr_func", {052,219}, {336,032}, WHT, true,  false, 3}
	rom_table["galaga"]     = {"galag_func", {016,219}, {092,045}, WHT, true,  false, 1}
	rom_table["galagamf"]   = {"galag_func", {016,219}, {092,045}, WHT, true,  false, 1}
	rom_table["galagamk"]   = {"galag_func", {016,219}, {092,045}, WHT, true,  false, 1}
	rom_table["galaxian"]   = {"galax_func", {052,216}, {328,032}, WHT, true,  false, 3}
	rom_table["superg"]     = {"galax_func", {052,216}, {328,032}, WHT, true,  false, 3}
	rom_table["moonaln"]    = {"galax_func", {052,216}, {328,032}, WHT, true,  false, 3}
	rom_table["invaders"]   = {"invad_func", {237,009}, {102,054}, GRN, false, false, 1}
	rom_table["missile"]    = {"missl_func", {001,001}, {164,080}, YEL, true,  true,  1}
	rom_table["suprmatk"]   = {"missl_func", {001,001}, {152,080}, WHT, true,  true,  1}
	rom_table["pacman"]     = {"pacmn_func", {018,216}, {120,044}, WHT, true,  false, 1}
	rom_table["pacmanf"]    = {"pacmn_func", {018,216}, {120,044}, WHT, true,  false, 1}
	rom_table["mspacman"]   = {"pacmn_func", {018,216}, {120,044}, WHT, true,  false, 1}
	rom_table["mspacmnf"]   = {"pacmn_func", {018,216}, {120,044}, WHT, true,  false, 1}
	rom_table["mspacmat"]   = {"pacmn_func", {018,216}, {120,044}, WHT, true,  false, 1}
	rom_table["pacplus"]    = {"pacmn_func", {018,216}, {120,044}, WHT, true,  false, 1}
	rom_table["qbert"]      = {"qbert_func", {217,016}, {102,053}, WHT, false, false, 1}
	rom_table["qberta"]     = {"qbert_func", {217,016}, {102,053}, WHT, false, false, 1}
	rom_table["robotron"]   = {"rbtrn_func", {000,015}, {184,096}, YEL, true,  true,  1}
	rom_table["robotrontd"] = {"rbtrn_func", {000,015}, {184,096}, YEL, true,  true,  1}
	rom_table["robotron12"] = {"rbtrn_func", {000,015}, {184,096}, YEL, true,  true,  1}
	rom_table["robotronyo"] = {"rbtrn_func", {000,015}, {184,096}, YEL, true,  true,  1}
	rom_table["robotron87"] = {"rbtrn_func", {000,015}, {184,096}, YEL, true,  true,  1}
	rom_table["scramble"]   = {"scram_func", {055,206}, {240,032}, YEL, true,  false, 3}
	rom_table["sinistar"]   = {"snstr_func", {287,001}, {102,052}, WHT, false, false, 1}
	rom_table["sinistar2"]  = {"snstr_func", {287,001}, {102,052}, WHT, false, false, 1}
	rom_table["sinistarp"]  = {"snstr_func", {287,001}, {102,052}, WHT, false, false, 1}

	-- encoded message data
	message_data = {"*","*","*","*","*","*","*","*","8&@2@3@2&3@3@9&@5@93&4&@3@!3&@3&@8","8@3@1@3@1@2@2@3@9@3@3@!92@2@5@4@1@2@3@4@91",
		"8@3@1@3@1@6@3@9@3@4@92@9@3@3@1@3@4@91","8@3@1@3@2&!2&@!9@3@4@93&!5@3@3@1@2@!4@91","8&@2@3@6@1@3@9&@5@97@4@3&@!1&!6@91",
		"8@6@3@1@3@1@3@9@9@92@3@4@3@3@1@1@!5@91","8@7&!3&!2@3@9@7&@91&!5@3@3@1@2@!4@91","*","98&@2&!93&3&!2@3@2&@2&@1@3@1@3@1&@!97",
		"991@3@3@91@2@1@3@1@!2@4@6@3@!2@1@3@1@993","991@3@3@9@6@3@1&1@4@6@3&1@1@3@1@993","991@3@3@9@6@3@1?4@6@3?1@3@1&@98",
		"991@3@3@9@6@3@1@1&4@6@3@1&1@3@1@993","991@3@3@91@2@1@3@1@2@!4@6@3@2@!1@3@1@993","991@4&!93&3&!2@3@4@4&@1@3@2&!2&@!97","*","*","*","*","*",
		"*","*","*","*","8ABCDEFGHIJKLMNOPQRSTUVWXYabcdefghijklmnopqrstuvwwxyy8","8ABCDEFGHIJKLMNOPQRSTUVWXYabcdefghijklmnopqrstuvwwxyy8",
		"8ABCDEFGHIJKLMNOPQRSTUVWXYabcdefghijklmnopqrstuvwwxyy8","8ABCDEFGHIJKLMNOPQRSTUVWXYabcdefghijklmnopqrstuvwwxyy8",
		"8ABCDEFGHIJKLMNOPQRSTUVWXYabcdefghijklmnopqrstuvwwxyy8","8ABCDEFGHIJKLMNOPQRSTUVWXYabcdefghijklmnopqrstuvwwxyy8",
		"8ABCDEFGHIJKLMNOPQRSTUVWXYabcdefghijklmnopqrstuvwwxyy8","*","*","*","*","*","*","*","*","*"}
	message_data_rotated = {"+","+","+","+","+","+","+","+","9A97?8","9A97?8","9B99!3!8","9B99!3!8","9C99!3!8","9C99&!8","9D991@!9","9D9994",
		"9E98&@8","9E95!1?8","9F95!1!95","9F8?1!95","9G8?1!95","9G95!1?8","9H95!2&@8","9H9994","9I9&!3!2@9","9I8?1@1&8","9J8!5!1!2!2!8",
		"9J8!5!1!2!2!8","9K8!5!1!2!1@8","9K8?1&1!9","9L9&!3@93","9L9994","9M97?8","9M97?8","9N991!92","9N991!92","9O991!92","9O97?8","9P97?8",
		"9P9994","9Q91@!99","9Q9&!98","9R8@3@97","9R8!5!97","9S8!5!97","9S8@3@97","9T9!3!98","9T9994","9U9&!2?8","9U8?1?8","9V8!5!3!3!8",
		"9V8!5!3!3!8","9W8!5!3!3!8","9W8?3&!8","9X9&!5@!9","9X9994","9Y8?97","9Y8?1!95","9a92@!2!4!9","9a91@!3?8","9b9@!4?8","9b8?1!95","9c8?1!95",
		"9c9994","9d9994","9d95!97","9e95!97","9e8?97","9f8?97","9f95!97","9g95!97","9g9994","9h98!2@9","9h8!5!1@1&8","9i8!5!1!2!2!8","9i8?1!2!2!8",
		"9j8?1!2!1@8","9j8!5!1&1!9","9k8!5!2@93","9k9994","9l8?97","9l8?7!8","9m92@!8!8","9m91@!3?8","9n9@!4?8","9n8?7!8","9o8?7!8","9o9994",
		"9p9&@1&!91","9p8?1&@9","9q8!9!2@8","9q8!9!3!8","9r8!9!2@8","9r8?1&@9","9s9&@1&!91","9s9994","9t8?1?8","9t8?1?8","9u8!2!2!3!3!8",
		"9u8!2!2!2@3!8","9v8!2!2!1&2!8","9v8!2!2!1@1&8","9w8!5!1!2@!9","9w9994","9w9994","9x994!8","9x994!8","9x97?8","9y97?8","9y994!8","9y994!8",
		"+","+","+","+","+","+","+","+"}

	---------------------------------------------------------------------------
	-- Game specific functions
	---------------------------------------------------------------------------
	function scram_func()
		-- ROM disassembly at http://seanriddle.com/scramble.asm
		h_mode = read(0x4006)  -- 1 == playing
		h_remain_lives = read(0x4108)
		h_start_lives = read(0x4007)
		b_show_tally = h_mode == 1
		b_reset_tally = h_mode ~= 1 or i_tally == nil
		b_1p_game = read(0x400e, 0)
		b_push_p1 = i_stop and to_bits(ports[":IN1"]:read())[8] == nil
		b_almost_gameover = h_mode == 1 and h_remain_lives == 0 and read(0x438f, 0x67)  -- 0x438c is explosion counter

		if b_1p_game then
			if b_almost_gameover and not i_stop then
				i_stop = i_frame + 300
				video.throttle_rate = 0.5
			end
			if i_stop and i_stop > i_frame then
				mem:write_u8(0x438f, 0x10)
				draw_continue_box(2)
				if b_push_p1 then
					i_tally = i_tally + 1 ; i_stop = nil
					mem:write_u8(0x4108, h_start_lives)  -- reset lives
					reset(0x40a2, 3)  -- reset score in memory
					-- reset score on screen
					mem:write_u8(0x4ee1, 0); mem:write_u8(0x4f01, 0)
					for _addr=0x4f21, 0x4fc1, 0x20 do mem:write_u8(_addr, 0x10) end
				end
			end
		end
	end

	function dfend_func()
		-- ROM disassembly at https://computerarcheology.com/Arcade/Defender
		h_mode = read(0xa17d)  -- not playing == 0
		h_remain_lives = read(0xa1c9)
		h_start_lives = 3
		b_show_tally = h_mode > 0
		b_reset_tally = read(0x3e80, 1) or i_tally == nil  -- 0x3e80 is gameover flag
		b_1p_game = read(0xa08b, 1) and read(0xa08c, 1)
		b_push_p1 = i_stop and to_bits(ports[":IN0"]:read())[6] == 1
		b_almost_gameover = h_mode > 0 and h_remain_lives == 0 and read(0xa031, 7)  -- death flag goes from 00 (alive) to FF (dead)

		if _reset_frame and i_frame >= _reset_frame then
			mem:write_u8(0xa1c9, h_start_lives - 2)  -- adjust lives down so number of ships displays correctly on next death
			_reset_frame = nil
		end

		if b_1p_game then
			if b_almost_gameover and not i_stop then
				i_stop = i_frame + 135
				video.throttle_rate = 0.225 -- adjust emulation speed to allow 10 seconds to make decision
				sound.attenuation = -32 -- mute sounds
			end
			if i_stop and i_stop > i_frame then
				draw_continue_box(4)
				if b_push_p1 then
					_reset_frame = i_stop + 30  -- lives are adjusted down at this frame
					i_tally = i_tally + 1 ; i_stop = nil
					reset(0xa1c2, 5)  -- reset score
					mem:write_u8(0xa1c9, h_start_lives)  -- reset lives
				end
			end
		end
	end

	function bzerk_func()
		-- ROM disassembly at http://seanriddle.com/berzerk.asm
		h_mode = read(0x436e)  --0=playing, otherwise demo mode
		h_remain_lives = read(0x4349)
		h_start_lives = 3
		b_1p_game = read(0x4376, 1)
		b_show_tally = h_mode == 0 and read(0x4344, 1) -- 1 player playing and not in demo mode
		b_reset_tally = h_mode ~= 0 or not read(0x4344, 1) or i_tally == nil
		b_push_p1 = i_stop and to_bits(ports[":SYSTEM"]:read())[1] == 0

		_hit = read(mem:read_u16(0x0876)) >= 128 -- read player vector structure to determine if player was hit
		b_almost_gameover = b_1p_game and h_mode == 0 and h_remain_lives == 1 and _hit

		if b_1p_game then
			if b_almost_gameover and not i_stop then
				i_stop = i_frame + 120
				video.throttle_rate = 0.18 -- adjust emulation speed to allow 10 seconds to make decision
				sound.attenuation = -32 -- mute sounds
			end
			if i_stop and i_stop > i_frame then
				draw_continue_box(5)
				if b_push_p1 then
					i_tally = i_tally + 1 ; i_stop = nil
					mem:write_u8(0x4349, h_start_lives + 1)
					reset(0x433e, 3)  -- reset score in memory
					reset(0x436d, 1, 0xff)  -- set score update flag
				end
			end
		end
	end

	function bzone_func()
		-- ROM disassembly at https://6502disassembly.com/va-battlezone/
		h_mode = read(0xce) -- 0x0=not playing, 0xff=playing
		h_remain_lives = read(0xcc)
		h_start_lives = (to_bits(ports[":DSW0"]:read())[1] + to_bits(ports[":DSW0"]:read())[2]*2) + 2 -- lives from dips
		b_push_p1 = i_stop and to_bits(ports[":IN3"]:read())[6] == 1
		b_1p_game = true
		b_show_tally = h_mode == 0xff
		b_reset_tally = h_mode == 0x0 or i_tally == nil
		b_almost_gameover = b_1p_game and h_mode == 0xff and h_remain_lives == 0 and not read(0xcd, 0)
		r_tally_colors = {WHT, WHT}  -- override tally colours to work with the red/green overlay

		if b_1p_game then
			if b_almost_gameover and not i_stop then
				i_stop = i_frame + 600
				_enemy = {mem:read_u16(0x2f), mem:read_u16(0x33)}
			end
			if i_stop and i_stop > i_frame then
				mem:write_u8(0xc7, 30)  -- suspend game
				mem:write_u16(0x2f, _enemy[1])  -- freeze the enemy locations
				mem:write_u16(0x33, _enemy[2])
				draw_continue_box()
				if b_push_p1 then
					i_tally = i_tally + 1 ; i_stop = nil
					mem:write_u8(0xcc, h_start_lives)
					mem:write_u8(0xcd, 0)  -- set alive flag
					reset(0xb8, 2) -- reset score in memory
				end
			end
		end
	end

	function centi_func()
		-- ROM disassembly at https://6502disassembly.com/va-centipede/
		h_mode = read(0x86) -- 0xff=attract mode
		h_start_lives = read(0xa4)
		h_remain_lives = read(0xa5)
		b_1p_game = read(0x89, 1)
		b_push_p1 = i_stop and to_bits(ports[":IN1"]:read())[1] == 0
		b_show_tally = h_mode ~= 0xff
		b_reset_tally = h_mode == 0xff or i_tally == nil
		b_almost_gameover = b_1p_game and h_mode == 0x0 and h_remain_lives == 0 and read(0xb7, 10)

		if b_1p_game then
			if b_almost_gameover and not i_stop then
				i_stop = i_frame + 600
			end
			if i_stop and i_stop > i_frame then
				mem:write_u8(0x87, 20)  -- suspend game
				draw_continue_box()
				if b_push_p1 then
					i_tally = i_tally + 1 ; i_stop = nil
					mem:write_u8(0xa5, h_start_lives)
					reset(0xa8, 6) -- reset score in memory
				end
			end
		end
	end

	function missl_func()
		-- ROM disassembly at https://6502disassembly.com/va-missile-command/
		h_mode = read(0x93)  -- 0x0=not playing, 0xff=playing
		h_remain_lives = read(0xc0)  -- remaining cities
		b_push_p1 = i_stop and to_bits(ports[":IN0"]:read())[5] == 0
		b_1p_game = read(0xae, 0)
		b_reset_tally = h_mode == 0x0 or i_tally == nil
		b_show_tally = h_mode == 0xff
		if b_reset_tally or not h_start_lives then
			h_start_lives = 3 + to_bits(ports[":R8"]:read())[1]*2 + to_bits(ports[":R8"]:read())[2] -- read lives from dips
			if h_start_lives == 3 then
				h_start_lives = 7
			end
		end
		b_almost_gameover = b_1p_game and h_mode == 0xff and h_remain_lives == 0

		---- Logic
		if b_1p_game then
			if b_almost_gameover and not i_stop then
				i_stop = i_frame + 190
				_hide_stop = i_stop + 90  -- hide the playfield during message and for 90 frames after pushing continue
				video.throttle_rate = 0.35 -- adjust emulation speed to allow more time for decision
				sound.attenuation = -32 -- mute sounds
			end
			if _hide_stop and _hide_stop > i_frame then box(0,8, 256, 232, BLK, BLK) end  -- hide the playfield
			if i_stop and i_stop > i_frame then
				draw_continue_box(3)
				if b_push_p1 then
					i_tally = i_tally + 1 ; i_stop = nil
					mem:write_u8(0xc0, h_start_lives)
					mem:write_u8(0xcf, 0)
					reset(0x01d6, 6) -- reset score in memory
					reset(0xd4, 1, 0xff) -- set flag to redraw the score
				end
			end
		end
	end

	function rbtrn_func()
		-- Figured out using MAME debugger & ROM disassembly at http://seanriddle.com/willy3.html#soft
		h_mode = read(0x98d1)  -- 0=high score screen, 1=attract mode, 2=playing
		h_start_lives = 3
		h_remain_lives = read(0xbdec)
		b_1p_game = read(0x983f, 1)
		b_push_p1 = i_stop and to_bits(ports[":IN0"]:read())[5] == 1
		b_reset_tally = h_mode ~= 2 or i_tally == nil
		b_show_tally = b_1p_game and h_mode == 2
		b_almost_gameover = h_mode == 2 and h_remain_lives == 0 and read(0x9859, 0x1b)  -- 0x1b when player dies

		if b_1p_game then
			if b_almost_gameover and not i_stop then
				i_stop = i_frame + 100
				_hide_stop = i_stop + 35  -- hide the playfield during message and for 35 frames after pushing continue
				video.throttle_rate = 0.17 -- -- adjust emulation speed to allow 10 seconds to make decision
				sound.attenuation = -32  -- mute sounds
			end
			if _hide_stop and _hide_stop > i_frame then box(8,17, 282, 228, BLK, BLK) end  -- hide the playfield
			if i_stop and i_stop > i_frame then
				mem:write_u8(0x9848, 0)  -- switch off player collisions while waiting for decision
				draw_continue_box(6)
				if b_push_p1 then
					i_tally = i_tally + 1 ; i_stop = nil
					mem:write_u8(0xbdec, h_start_lives)
					reset(0xbde4, 4)  -- reset score in memory
				end
			end
		end
	end

	function qbert_func()
		-- No commented rom disassembly available. I worked this one out using MAME debugger.
		--   0000-1fff RAM
		--   3800-3fff video RAM
		_demo = to_bits(read(0x5800))[4] == 1  -- unlimited lives/demo mode.  Disable continue option
		h_mode =  read(0x1fee) -- 0xf4=waiting to start
		h_start_lives = 3
		h_remain_lives = read(0xd00)
		b_1p_game = read(0xb2, 0)
		_dead = read(0x1fed, 0xbb) or read(0x1fed, 0xbd)
		if _dead then _dead_count = _dead_count + 1 else _dead_count = 0 end -- count the dead status flag
		b_almost_gameover = h_remain_lives == 1 and _dead and _dead_count == 50 -- react to dead status at 50 ticks
		b_reset_tally = h_mode == 0xf4 or i_tally == nil
		b_show_tally = h_remain_lives >= 1 and h_mode ~=0xf4 and not read(0x3da3, 0xa5) --0xa5 is a tile on level screen
		b_push_p1 = i_stop and to_bits(ports[":IN1"]:read())[1] == 1

		-- Logic
		if b_1p_game and not _demo then
			if b_show_tally then
				for _k, _v in ipairs({0x3835, 0x3833, 0x3831}) do  -- redraw lives as game does not refresh them
					if _k < h_remain_lives then mem:write_u16(_v, 0xadac) else mem:write_u16(_v, 0x2424) end
				end
			end

			if b_almost_gameover and not i_stop then
				i_stop = i_frame + 600
			end
			if i_stop and i_stop > i_frame then
				cpu.state["CX"].value = 5  -- force delay timer to keep running
				draw_continue_box()

				if b_push_p1 then
					i_tally = i_tally + 1 ; i_stop = nil
					mem:write_u8(0xd00, h_start_lives + 1)
					mem:write_u8(0xd24, 0x30)  -- reset counter to fix a glitch wih blank lines being written to screen
					reset(0xbc, 6)  -- reset score in memory (do we need to clear more bytes?)
					reset(0xcb, 3) -- and also here in memory
					reset(0xc6, 5, 0x24)  -- and also here in memory
					reset(0x385c, 1)  -- reset score on screen
					for _addr=0x387c, 0x397c, 0x20 do reset(_addr, 1, 0x24) end  -- also here on screen
				end
			end
		end
	end

	function dkong_func()
		-- ROM disassembly at https://github.com/furrykef/dkdasm/blob/master/dkong.asm
		h_mode = read(0x600a)
		h_start_lives = read(0x6020)
		h_remain_lives = read(0x6228)
		b_1p_game = read(0x600f, 0)
		b_almost_gameover = h_mode == 13 and read(0x6228, 1) and read(0x639d, 2)
		b_reset_tally = h_mode == 7 or i_tally == nil
		b_show_tally = h_mode >= 8 and h_mode <= 16
		b_push_p1 = i_stop and to_bits(read(0x7d00))[3] == 1

		-- Logic
		if b_1p_game then
			if b_almost_gameover and not i_stop then
				i_stop = i_frame + 600
			end
			if i_stop and i_stop > i_frame then
				mem:write_u8(0x6009, 8) -- suspend game
				draw_continue_box()
				if b_push_p1 then
					i_tally = i_tally + 1 ; i_stop = nil
					mem:write_u8(0x6228, h_start_lives + 1)
					reset(0x60b2, 3)  -- reset score in memory
					for _addr = 0x76e1, 0x7781, 0x20 do reset(_addr, 1) end  -- reset score on screen
				end
			end
		end
	end

	function ckong_func()
		-- Memory map similar to dkong
		h_mode = read(0x600a)
		h_start_lives = read(0x6020)
		h_remain_lives = read(0x6228)
		b_1p_game = read(0x600f, 0)
		b_almost_gameover = h_mode == 13 and read(0x6228, 1) and read(0x639d, 2)
		b_reset_tally = h_mode == 7 or i_tally == nil
		b_show_tally = h_mode >= 8 and h_mode <= 16		
		b_push_p1 = i_stop and to_bits(ports[":SYSTEM"]:read())[3] == 0
	
		-- Logic
		if b_1p_game then
			if b_almost_gameover and not i_stop then
				i_stop = i_frame + 600
			end
			if i_stop and i_stop > i_frame then
				mem:write_u8(0x6009, 8) -- suspend game
				draw_continue_box()
				if b_push_p1 then
					i_tally = i_tally + 1 ; i_stop = nil
					mem:write_u8(0x6228, h_start_lives + 1)
					reset(0x60b2, 3)  -- reset score in memory
					for _addr = 0x76e1 + 0x1c00, 0x7781 + 0x1c00, 0x20 do reset(_addr, 1) end  -- reset score on screen
				end
			end
		end
	end

	function ckgal_func()
		-- Crazy Kong conversions on Galaxian Hardware
		h_mode = read(0x600a)
		h_start_lives = read(0x6020)
		h_remain_lives = read(0x6228)
		b_1p_game = read(0x600f, 0)
		b_almost_gameover = h_mode == 13 and read(0x6228, 1) and read(0x639d, 2)
		b_reset_tally = h_mode == 7 or i_tally == nil
		b_show_tally = h_mode >= 8 and h_mode <= 16		
		b_push_p1 = i_stop and to_bits(ports[":IN1"]:read())[8] ~= 1
	
		-- Logic
		if b_1p_game then
			if b_almost_gameover and not i_stop then
				i_stop = i_frame + 600
			end
			if i_stop and i_stop > i_frame then
				mem:write_u8(0x6009, 8) -- suspend game
				draw_continue_box()
				if b_push_p1 then
					i_tally = i_tally + 1 ; i_stop = nil
					mem:write_u8(0x6228, h_start_lives + 1)
					reset(0x60b2, 3)  -- reset score in memory
					for _addr = 0x76e1 + 0x1c00, 0x7781 + 0x1c00, 0x20 do reset(_addr, 1) end  -- reset score on screen
				end
			end
		end
	end


	function galax_func()
		-- ROM disassembly at http://seanriddle.com/galaxian.asm
		h_mode = read(0x400a)
		h_start_lives = 2 + read(0x401f)  -- read dip switch
		if emu:romname() == "moonaln" then
			h_start_lives = 3 + (read(0x401f) * 2)  -- read dip switch
		end
		h_remain_lives = read(0x421d)
		b_1p_game = read(0x400e, 0)
		b_almost_gameover = read(0x4201, 1) and read(0x421d, 0) and read(0x4205, 10)
		b_show_tally = read(0x4006)  -- game is in play
		b_reset_tally = h_mode == 1 or i_tally == nil
		b_push_p1 = i_stop and read(0x6800, 1)

		-- Logic
		if b_1p_game then
			if b_almost_gameover and not i_stop then
				i_stop = i_frame + 600
			end
			if i_stop and i_stop > i_frame then
				mem:write_u8(0x4205, 0x10)  -- suspend game by setting the animation counter
				draw_continue_box()
				if b_push_p1 then
					i_tally = i_tally + 1 ; i_stop = nil
					mem:write_u8(0x421d, h_start_lives)
					reset(0x40a2, 3) -- reset score in memory
					for _addr = 0x52e1, 0x53a1, 0x20 do reset(_addr, 1, 16) end  -- reset score on screen
					reset(0x5301, 1) -- rightmost zeros on screen
					reset(0x52e1, 1) -- rightmost zeros on screen
				end
			end
		end
	end

	function galag_func()
		-- ROM disassembly at https://github.com/hackbar/galaga
		h_mode = read(0x9201)  -- 0=game ended, 1=attract, 2=ready to start, 3=playing
		h_start_lives = read(0x9982) + 1  --refer file "mrw.s" ram2 0x9800 + offset
		h_remain_lives = read(0x9820)
		b_1p_game = read(0x99b3, 0)
		b_reset_tally = h_mode == 2 or i_tally == nil
		b_show_tally = h_mode == 3
		b_push_p1 = i_stop and to_bits(ports[':IN1']:read())[3] == 0

		-- check video ram for "CAPT" (part of FIGHTER CAPTURED message)
		_capt = read(0x81f1, 0xc) and read(0x81d1, 0xa) and read(0x81b1, 0x19) and read(0x8191, 0x1d)
		-- no more ships and (explosion animation almost done or fighter was captured)
		b_almost_gameover = read(0x9820, 0) and (read(0x8863, 3) or _capt)

		if b_1p_game then
			if b_almost_gameover and not i_stop then
				i_stop = i_frame + 600
			end
			if i_stop and i_stop > i_frame then
				if not _capt then
					mem:write_u8(0x92a0, 1)  -- suspend game by resetting the timer (counts upward to 255)
				end
				draw_continue_box()
				if b_push_p1 then
					i_tally = i_tally + 1 ; i_stop = nil
					mem:write_u8(0x9820, h_start_lives)
					reset(0x83f9, 1) -- reset score in memory
					reset(0x83fa, 5, 0x24) -- reset score on screen
				end
			end
		end
	end

	function frogr_func()
		-- No commented rom disassembly available. I worked this one out using MAME debugger.
		-- Useful map info from MAME Driver:
		--   map(0x8000, 0x87ff) is ram
		--   map(0xa800, 0xabff) is videoram
		h_mode = read(0x803f) -- 1=not playing, 3=playing game (can mean attract mode too)
		h_start_lives = read(0x83e4)
		h_remain_lives = read(0x83e5)
		b_1p_game = read(0x83fe, 1)
		b_push_p1 = i_stop and not to_bits(ports[":IN1"]:read())[8]
		b_reset_tally = h_mode == 1 or i_tally == nil
		b_show_tally = h_mode == 3 and b_1p_game

		if h_mode == 0 and read(0x83dd, 0) and read(0x83dc) < 10 then
			mem:write_u8(0x803f, 3) -- force death just before timer expiry so we can display the continue message
			mem:write_u8(0x8004, 1)
		end

		b_almost_gameover = h_remain_lives == 0 and  h_mode == 3 and read(0x8045, 0x3c)

		if b_1p_game then
			if b_almost_gameover and not i_stop then
				i_stop = i_frame + 600
				sound.attenuation = -32  -- mute sounds
			end
			if i_stop and i_stop > i_frame then
				cpu.state["HL"].value = 0xffff  -- force delay timer to keep running
				draw_continue_box()
				if b_push_p1 then
					i_tally = i_tally + 1 ; i_stop = nil
					mem:write_u8(0x83e5, h_start_lives + 1)
					mem:write_u8(0x83ae, 1)
					mem:write_u8(0x83ea, 0)
					reset(0x83ec, 3)  -- reset score in memory
				end
			end
		end
	end

	function invad_func()
		-- ROM Disassembly at https://computerarcheology.com
		h_mode = read(0x20ef)  -- 1=game running, 0=demo or splash screens
		h_remain_lives = read(0x21ff)
		b_1p_game = read(0x20ce, 0)
		b_reset_tally = h_mode == 0 or i_tally == nil
		b_show_tally = h_mode == 1
		b_push_p1 = i_stop and to_bits(ports[':IN1']:read())[3] == 1
		-- player was blown up on last life. Animation sprite and timer indicate a specific frame
		b_almost_gameover = read(0x2015) < 128 and h_remain_lives == 0 and read(0x2016, 1) and read(0x2017, 1)
		h_start_lives = 3
		if to_bits(ports[':IN2']:read())[1] == 1 then h_start_lives = h_start_lives + 1 end  -- dip adjust start lives
		if to_bits(ports[':IN2']:read())[2] == 1 then h_start_lives = h_start_lives + 1 end  -- ...and the next dip

		if b_1p_game then
			if b_almost_gameover and not i_stop then
				i_stop = i_frame + 600
			end
			if i_stop and i_stop > i_frame then
				mem:write_u8(0x20e9, 0) -- suspend game
				draw_continue_box()
				if b_push_p1 then
					i_tally = i_tally + 1 ; i_stop = nil
					mem:write_u8(0x21ff, h_start_lives)
					mem:write_u8(0x20e9, 1) -- unsuspend game
					reset(0x20f8, 2)  -- update score in memory
					reset(0x20f1, 1, 1) -- adjust score flag for dummy screen update
				end
			else
				mem:write_u8(0x20e9, 1) -- unsuspend game
				reset(0x20f1, 1, 1) -- adjust score flag for dummy screen update
				reset(0x20f2, 2) -- score adjustment
			end
		end
	end

	function climb_func()
		-- ROM Disassembly at https://computerarcheology.com
		h_mode = read(0x8075)
		h_start_lives = read(0x807e)
		h_remain_lives = read(0x80d8)
		b_1p_game = read(0x8080, 0)
		b_almost_gameover = read(0x8073, 0) and h_remain_lives == 0
		b_show_tally = h_mode == 1
		b_reset_tally = h_mode == 0 or i_tally == nil
		b_push_p1 = i_stop and to_bits(read(0xb800))[3] == 1

		if b_1p_game then
			if b_almost_gameover and not i_stop then
				i_stop = i_frame + 600
			end
			if i_stop and i_stop > i_frame then
				cpu.state["HL"].value = 0xffff  -- force delay timer to keep running
				box(0, 224, 256, 80, BLK, BLK)  -- partially hide the background
				draw_continue_box()
				if b_push_p1 then
					i_tally = i_tally + 1 ; i_stop = nil
					mem:write_u8(0x80d8, h_start_lives + 1)
					mem:write_u8(0x8073, 1)
					reset(0x80d9, 3)  -- reset score in memory
				end
			end
		end
	end

	function pacmn_func()
		-- ROM disassembly at https://github.com/BleuLlama/GameDocs/blob/master/disassemble/mspac.asm
		h_mode = read(0x4e00)
		h_start_lives = read(0x4e6f)
		h_remain_lives = read(0x4e14)
		b_1p_game = read(0x4e70, 0)
		b_game_restart = read(0x4e04, 2)
		b_almost_gameover = h_mode == 3 and h_remain_lives == 0 and read(0x4e04,4)
		b_reset_tally = h_mode == 2 or i_tally == nil
		b_show_tally = h_mode == 3
		b_push_p1 = i_stop and to_bits(read(0x5040))[6] == 0

		-- Logic
		if b_1p_game then
			if b_almost_gameover and not i_stop then
				i_stop = i_frame + 600
				_pills_eaten = read(0x4e0e)
				_level = read(0x4e13)
			end
			if i_stop and i_stop > i_frame then
				mem:write_u8(0x4e04, 4)  -- suspend game
				draw_continue_box()
				if b_push_p1 then
					i_tally = i_tally + 1 ; i_stop = nil
					mem:write_u8(0x4e04, 0)  -- unsuspend
					mem:write_u8(0x4e14, h_start_lives)  --update number of lives
					mem:write_u8(0x4e15, h_start_lives - 1)  --update displayed number of lives
					reset(0x4e80, 3) -- reset score in memory
					for _i=0,7 do if _i < 2 then _v=0 else _v=64 end reset(0x43f7+_i,1,_v) end  --reset score on screen
				end
			end
			if b_game_restart then
				mem:write_u8(0x4e0e, _pills_eaten)  -- restore the number of pills eaten after continue
				mem:write_u8(0x4e13, _level)  -- restore level
			end
		end
	end

	function aster_func()
		-- Rom disassembly at https://github.com/nmikstas/asteroids-disassembly/tree/master/AsteroidsSource
		h_mode = read(0x21b)
		h_start_lives = read(0x56)
		h_remain_lives = read(0x57)
		b_1p_game = read(0x1c, 1)
		b_reset_tally = not b_1p_game or i_tally == nil
		b_show_tally = b_1p_game
		b_almost_gameover = h_mode == 160 and h_remain_lives == 0
		b_push_p1 = i_stop and read(0x2403, 128)

		-- Logic
		if b_1p_game then
			if b_almost_gameover and not i_stop then
				i_stop = i_frame + 600
			end
			if i_stop and i_stop > i_frame then
				mem:write_u8(0x21b, 160)  -- suspend game by setting the game mode counter
				message_data = flip_table(message_data_rotated)
				box(348, 248, 660, 280, BLK, BLK)  -- blackout the GAME OVER text
				draw_continue_box()
				if b_push_p1 then
					i_tally = i_tally + 1 ; i_stop = nil
					mem:write_u8(0x57, h_start_lives)
					mem:write_u8(0x21b, 200)  -- skip some of the explosion animation
					reset(0x52, 2)  --reset score in memory
				end
			end
		end
	end

	function snstr_func()
		-- Sinistar source at https://github.com/historicalsource/sinistar
		-- NOTE: Should we reset sinibombs on continue?  This game is hard as balls so maybe keep sinibombs for now.
		r_tally_colors = {0xffffd900, 0xffff0000}  -- override tally colours
		if not _ships then _ships={}; --  ship sprite used for redraws
			_ships[1]={0,0,0xffaeaea0,0,0}; _ships[2]={0,0,0xffffffa0,0,0}; _ships[3]={0,0xffffffa0,WHT,0xff8989a0,0};
			_ships[4]={0xff8989a0,0xffffffa0,WHT,0xff5176a0,0xffff5176a0};
			_ships[5]={0xff00515f,0xff00515f,0xff8989a0,0xff00515f,0xff00515f}
		end

		if emu.romname() == "sinistarp" then _offset = 3 else _offset = 0 end  -- prototype has some memory offset
		h_mode = read(0x9896 - _offset)  -- 1==attract mode, 0==playing
		h_start_lives = read(0xcc05) - 0xf0 -- read lives from CMOS
		h_remain_lives = read(0x9ffc)
		b_1p_game = read(0x988a - _offset, 1)
		b_reset_tally = not b_1p_game or i_tally == nil
		b_show_tally = h_mode == 0
		b_push_p1 = i_stop and to_bits(ports[":IN1"]:read())[5] == 1
		if _dead_cnt and read(0xa1ba, 1) then _dead_cnt = _dead_cnt + 1 else _dead_cnt = 0 end
		b_almost_gameover = h_mode == 0 and h_remain_lives == 0 and read(0xa1ba, 1) and _dead_cnt == 40

		if h_mode == 0 and read(0x9896 - _offset, 0) then  -- 0x9896==0 when not in attract mode. redraw remaining ships
			for _i=1, h_remain_lives - bool_to_int(dead_cnt and dead_cnt > 0) do draw_sprite(_ships,251,6+(_i*6)) end
		end

		----testing difficulty
		if h_mode == 0 then
			--aggress = mem:read_u8(0xa03c)
			--if not last_aggress or aggress ~= last_aggress then
			--	print(aggress)
			--	print(scr:frame_number())
			--	print("----")
			--end
			--last_aggress = aggress
			--mem:write_direct_u8(0xa03c, 0)  -- incrementing warrior aggression - we could cap it
			--mem:write_direct_u8(0xa03c, 65)  -- incrementing warrior aggression - we could cap it
			
			--print(mem:read_u8(0xa019))
			--mem:write_u8(0xa050, 0x3f)  -- test
			--mem:write_u8(0xa013, 10)  -- have a bunch of sinibombs
			--mem:write_u8(0x9ffc, 0x03)  -- retain 3 lives
		end
		----end testing

		-- Logic
		if b_1p_game then
			if b_almost_gameover and not i_stop then
				i_start = i_frame
				i_stop = i_frame + 610
				mem:write_direct_u32(0x7e0e, 0x7e7e0c33)  -- freeze game by injecting an infinite loop
			end
			if i_stop then
				if i_frame > i_stop - 10 then
					mem:write_direct_u32(0x7e0e, 0xb7ca0033)  -- unfreeze game before countdown ends
				end
				if (i_stop > i_frame) and (i_frame > i_start + 10) then  -- allow 10 frames for infinite loop logic reset
					draw_continue_box()
					if b_push_p1 and cpu.state["PC"].value ~= 0x7e0f then  -- prevent lock up by avoiding specific PC
						i_tally = i_tally + 1 ; i_stop = nil
						mem:write_direct_u32(0x7e0e, 0xb7ca0033)   -- unfreeze game
						mem:write_u8(0x9ffc, h_start_lives)  -- reset lives
						reset(0x9ffd, 4)  -- reset score
						reset(0xa00b, 1, 1)  -- update score changed flag
					end
				end
			end
		end
	end

	---------------------------------------------------------------------------
	-- Plugin functions
	---------------------------------------------------------------------------
	function continue_initialize()
		if tonumber(emu.app_version()) >= 0.227 then
			mac = manager.machine
			ports = mac.ioport.ports
			video = mac.video
			sound = mac.sound
		elseif tonumber(emu.app_version()) >= 0.196 then
			mac = manager:machine()
			ports = mac:ioport().ports
			video = mac:video()
			if tonumber(emu.app_version()) >= 0.212 then sound = mac:sound() else sound = {} end  -- sound from v0.212
		else
			print("ERROR: The continue plugin requires MAME version 0.196 or greater.")
		end
		if mac ~= nil then
			if rom_table[emu:romname()] then
				scr = mac.screens[":screen"]
				cpu = mac.devices[":maincpu"]
				mem = cpu.spaces["program"]

				--store the default sound level
				i_attenuation = sound.attenuation

				-- read rom data and split into convenient variables
				rom_data = rom_table[emu:romname()]
				r_function = _G[rom_data[1]]
				r_tally_yx = rom_data[2]
				r_yx = rom_data[3]
				r_color = rom_data[4]
				r_flip = rom_data[5]
				r_rotate = rom_data[6]
				r_scale = rom_data[7]
				r_tally_colors = { WHT, CYN}

				-- flip/rotate the message data to suit the rom if necessary
				if r_rotate then message_data = message_data_rotated end
				if r_flip then message_data = flip_table(message_data) end
			else
				print("WARNING: The continue plugin does not support this rom.")
			end
		end
	end

	function continue_main()
		if r_function ~= nil then
			i_frame = scr:frame_number()
			r_function()
			b_reset_continue = h_remain_lives > 1 or i_tally == nil  -- default can be overridden in game function
			if b_reset_tally then i_tally = 0 end
			if b_1p_game then
				if b_reset_continue then
					i_stop = nil
					-- Restore speed and sound.  Some roms slow down to allow time for continue message.
					video.throttle_rate = 1
					sound.attenuation = i_attenuation
				end
				if b_show_tally then
					draw_tally(i_tally)
				end
			end
		end
	end

	function draw_continue_graphic(data, pos_y, pos_x, percent, speed_factor)
		local _len, _sub, _byte, _floor = string.len, string.sub, string.byte, math.floor
		local _per = percent  or 100
		local _speed = speed_factor or 1
		local _pixel, _wide, _col
		local _pos = _floor(_per/2)
		local _index = _sub("ABCDEFGHIJKLMNOPQRSTUVWXYabcdefghijklmnopqrstuvwxy", _pos * _speed, _pos * _speed)
		for _y, line in pairs(data) do
			_x = 1
			for _i=1, _len(line) do
				_pixel = _sub(line, _i, _i)
				_col = BLK
				if _pixel >= "1" and _pixel <= "9" then	_wide = tonumber(_pixel)
				elseif _pixel == "*" then _wide = 119
				elseif _pixel == "+" then _wide = 47
				elseif _pixel == "!" then _col = r_color; _wide = 1
				elseif _pixel == "@" then _col = r_color; _wide = 2
				elseif _pixel == "&" then _col = r_color; _wide = 4
				elseif _pixel == "?" then _col = r_color; _wide = 7
				elseif (_pixel >= "a" and _pixel <= "z") or (_pixel >= "A" and _pixel <= "Z") then
					if r_rotate then _wide = 7 else _wide = 2 end
					if _byte(_index) and _byte(_pixel) <= _byte(_index) then
						if _pos <= (20/_speed) and (_speed > 1 or _per % 4 > 2) then _col = RED else _col = r_color end
					end
				end
				box(pos_y-(_y*r_scale), pos_x+_x, pos_y-(_y*r_scale)+r_scale, pos_x+_x+_wide, _col, 0)
				_x = _x + _wide
			end
		end
	end

	function draw_continue_box(speed_factor)
		_speed = speed_factor or 1
		_cnt = math.floor((i_stop - i_frame) / 6) + 1
		local _y, _x = r_yx[1], r_yx[2]
		if r_flip then
			draw_continue_graphic(message_data, _y+(24*r_scale), _x+(7*r_scale), _cnt, _speed)
		else
			draw_continue_graphic(message_data, _y+(40*r_scale), _x+(7*r_scale), _cnt, _speed)
		end
	end

	function draw_tally(n)
		-- chalk up the number of continues
		local _y, _x = r_tally_yx[1], r_tally_yx[2]
		local _col
		for _i=0, n - 1 do
			_col = r_tally_colors[((math.floor(_i / 5)) % 2) + 1]
			if r_flip and not r_rotate then
				box(_y-1, _x-(_i*4)-1, _y+(4*r_scale)+1, _x+2-(_i*4)+1, BLK ,BLK)  -- black background
				box(_y, _x-(_i*4), _y+(4*r_scale), _x+2-(_i*4), _col ,_col)  --flipped
			else
				box(_y-1, _x+(_i*4)-1, _y+(4*r_scale)+1, _x+2+(_i*4)+1, BLK ,BLK) -- black background
				box(_y, _x+(_i*4), _y+(4*r_scale), _x+2+(_i*4), _col ,_col) -- regular
			end
		end
	end

	function draw_sprite(data, y, x)
		-- draw a matrix of coloured sprites as y,x position
		for _row=1, #data do for _col=1, #data[_row] do
			box(y-_row-1, x+_col-1, y-_row, x+_col, data[_row][_col], 0)
		end end
	end

	function box(y1, x1, y2, x2, c1, c2)
		-- Handle the version specific arguments of draw_box
		if tonumber(emu.app_version()) >= 0.227 then
			scr:draw_box(y1, x1, y2, x2, c2, c1)
		else
			scr:draw_box(y1, x1, y2, x2, c1, c2)
		end
	end

	function flip_table(t)
		local _f = {}
		for k, v in ipairs(t) do
			_f[#t+1-k] = string.reverse(v)
		end
		return _f
	end

	function bool_to_int(boolean)
		if boolean then return 1 else return 0 end
	end

	function to_bits(num)
		--return a table of bits, least significant first
		local _t={}
		while num>0 do
			rest=math.fmod(num,2)
			_t[#_t+1]=rest
			num=(num-rest)/2
		end
		return _t
	end

	function read(address, comparison)
		-- return data from memory address or boolean when the comparison value is provided
		_d = mem:read_u8(address)
		if comparison then
			return _d == comparison
		else
			return _d
		end
	end

	function reset(start_address, number, value)
		-- Reset a number of addresses from the specified offset.  Default value being 0.
		_value = value or 0x0
		_end_address = start_address + number - 1  -- including the start address
		for _addr=start_address, _end_address do
			mem:write_u8(_addr, _value)
		end
	end

	emu.register_start(function()
		continue_initialize()
	end)

	emu.register_frame_done(continue_main, "frame")
end

return exports

