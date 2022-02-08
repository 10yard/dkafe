-- GalaKong: A Galaga Themed Shoot 'Em Up Plugin for Donkey Kong
-- by Jon Wilson (10yard)
--
-- Tested with latest MAME version 0.240
-- Fully compatible with all MAME versions from 0.227
--
-- Jumpman is assisted by an accompanying ship which can take out barrels, fireballs, firefoxes, pies and springs.  
-- Bonus points are awarded for destroying multiple targets.
--
-- The default mode is single player,  with your ship following Jumpman's position.
-- The jump button also shoots.
-- Jumpman can control the ship independently when he is on a ladder .
--
-- There is also a 2 player co-op mode where a 2nd player controls the ship using separate controls.
-- 		P1 Start = Left
--      P2 Start = Right
--      Coin     = Fire
--
-- The hack features a scrolling starfield background and animated explosions.
-- You can disable some features by setting environmental variables before you launch MAME.
-- SET GALAKONG_NOSTARS=1
-- SET GALAKONG_NOEXPLOSIONS=1
--
-- Minimum start up arguments:
--   mame dkong -plugin galakong
-----------------------------------------------------------------------------------------
local exports = {}
exports.name = "galakong"
exports.version = "0.61"
exports.description = "GalaKong: A Galaga Themed Shoot 'Em Up Plugin for Donkey Kong"
exports.license = "GNU GPLv3"
exports.author = { name = "Jon Wilson (10yard)" }
local galakong = exports


function galakong.startplugin()
	-- Mode of play is set with "P1 Start" and "P2 Start" at beginning of game.  
	-- 1) Single player mode:  mirrors Jumpman's movements
	-- 2) Co-op mode:  the ship is controlled by player 2 using "P1", "P2" and "Coin" buttons.
	local play_mode = 1
	local ship_y = -10
	local ship_x = 230
	local missile_y
	local missile_x
	local jumpman_y
	local jumpman_x
	local enemy_y
	local enemy_x
	local pickup_y
	local pickup_x
	local pickup = false

	local starfield = {}
	local explosions = {}
	local total_shots = {}
	local total_hits = {}

	local started = false
	local howhigh_ready = false
	local end_of_level = false
	local dead = false
	local name_entry = 0
	
	local score = "000000"
	local last_score = "000000"
	local million_wraps = 0
	local bonus = 0
	local hit_count = 0
	
	local last_bonus = 0
	local last_hit_cleanup = 0
	local number_of_stars
	local last_starfield = 0
	
	local BLACK = 0xff000000
	local WHITE = 0xffdedede
	local RED = 0xffff0000
	local BLUE = 0xff0068de	

	local graphics_palette = {}
	graphics_palette["@"] = 0xff095562
	graphics_palette[":"] = 0xff4ba49c
	graphics_palette["?"] = 0xfffc0202
	graphics_palette["%"] = 0xfffb512c
	graphics_palette["&"] = 0xffd2aa49
	graphics_palette["'"] = 0xff6161ff
	graphics_palette["+"] = 0xff0d9ca3
	graphics_palette["!"] = 0xffff0000
	graphics_palette["#"] = 0xffffff00
	graphics_palette["$"] = 0xffdedede
	graphics_palette["("] = WHITE
	graphics_palette["*"] = BLACK
	
	local galakong_logo_data = {
		"                                           %%?%%%%&&&&&&&%%%%%%%",
		"                                      %%?%%&&&::::::::::::::::&&&%%%      :",
		"                                   %?%&&&:::::&&&&&&&&&&&&&&&&:::::&&%%% :",
		"                                %?%&&::::&&&&&%%????%%%%%????%%%&&&&::&%%%",
		"                              %%&&::::&&&%%?%%                 %%%?%%&:&:&&%%              %%%&&%",
		"                            %%&&:::&&&%?%%   %%                     %?&%&&::&%%         %%&&::::&%",
		"                          %%&:::&&&%?%     %%&&%                     (: %?%&&:&&%     %%&::&&&::&?",
		"                %?%%%%%%%%&:::&&%?%      %%&::&%                    (&     %?%&:&&% %%&::&%??&::&%",
		"              ?%&&&::&&&&:::&&%?%      %%&::::&%                   (&        %?%&&&%&::&&?% %&:&%",
		"            %%&:::&&&:::::&&%?%      %?&&&::::&%                  ((            ?%&:::&%%   &::&%",
		"           ?&&:&&&%%&::::&%?%        %%%%?&:::&%         :       ((               ?%&:&?   %&:&?",
		"         %%&::&&?%%?&::&&?%              ?::::&%          %     ((:                 ?&&&% %&:&%",
		"        %%&:&&%%   %::&%%                ?::::%%          && : ((&                   %%&&%&:&%",
		"        %&:&&?     %&&?%                 ?::::%%           (:(((&                      ?&::&&%",
		"       %&:&&?     %&&?   %?%             ?::::%            &((((::@                    :%:&&%",
		"      ?&::&%      ?%?  %?&%              %::::%      :%:&&&(((((@:  ::':::@:':      @:&:::&@:&&::",
		"     %&::&&%      ?? %%&&&%     %%%%%    %::::%       %?%%@&(((&&&:@&&%&'&%%%&:@&: :&??&@&@&%?%%&'",
		"     %:::&?      %??%&&:&?  %%%&&&:&&%   %::::%    %%&&&:@@%(((??&::???%@?????%:%& :&??%@@%??????&@",
		"    ?&::&&%      ?%&:::&%??%&&::::::&%   %::::%%%%&&:::::::&@@(??&@&???&???%%??&@%::&??%:&????????&:",
		"   %&:::&?        ?&:::&&&&&&::::::::&   %::::&&&&::::::::&&%@&??&@&???:??%':%??&?&@&???:???%:&%??&:",
		"   %&:::&%         %:::&?%???&:::::::&   &::::%????%&::::@:&%*&??%(%??%@??& :&??& ?&&???&??%:  &%%&@",
		"  %&:::&&%         %:::&%  %&::::::::%  %&::::%  %%&::::@::&*:& ??????%@::: :&??&@??????& ?&:   ::'",
		"  %::::&%         %&::::% %&::::&::::%  %&::::%  %::::&&:::&**&???????&@     ::&%'??????%@?& @:':",
		" %&:@@@:%        ?&:@@@:&%%:@@:%%:@@:%  %:@@@:% %&@@:&?:@@@%**&???????:&@      &%'??????%@?::&%%&&&:",
		" ?&@@@@:&%     %%&:@@@@@:?%:@@&%%:@@:% %?:@@@:% %:@@:%%:@@:%*:&???????&@'    @&%&@???????:%::&????&:",
		" %:@@@@:&%?%%%%&:@@@@@@@:&&@@@&%%@@@:%%&&:@@@:% %:@@&?%:@@:%?%&????????:     :??& ???????&%:::&???&:",
		"%&:@@@@@::&&&&::@@@@@@@@@&&@@@&&:@@@:&&&%:@@@:% %:@@&&:@@@:&&:&???%%???%@@:: :??&??%%????&?&: :???& ",
		"%&@@@@@@@@@@@@@@@@@@@@@@:&&@@@@@@@@@@@:%?:@@@:?%&@@@@@@@@@@@:%:???%@%???&@%&::??:??::????& %&:&???& ",
		"%&@@@@@@@@@@@@@@@@@@@@:&%%:@@@@@@:@@@:?%?:@@@&?%&@@@@@@:@@@:%%:???%@:????:?%&&?& ??&@&???%@??%????:",
		"%%@@@@@@@@@@@::@@@@@:&%?%%:@@@@:&&@:&?**?:@@:&%%&@@@@::&@@:%%*:???%::%???&@???%'???&:@%??%@???????:",
		" %:@@@@@@@@@:%:@@@:&%?%**?&:@:&&?%:&?***?::&&?*%&:::&%?%:&?***'%??%'*&??%&:??%:@???&:*:%&&@??????%'",
		" ?&:@@@@@::%??:@:&%?%    %%%%%?% ?%?    ?&&%%   ?%%%?% ?&?    :&%&&@ :::@':&&' :?%%&:  :::@&&&:&?&:",
		"  ?%&&&&&%??%%:&%?%        %            %??%     %%    %%      ::         ::   ::::            :''",
		"   %?????%  %&%?",
		"            ??"}

	local yard_logo_data = {
		"  +",
		" ++                               ++",
		"+++    ++++                         +",
		"  +   +    +                         +",
		"  +   +    +                         +",
		"  +   +    +                         +",
		"  +   +    +  +  +    +++   +++   ++++",
		"  +   +    + ++  +  ++  +  + +  ++   +",
		"  +    +  +   + ++ + +  + +  + + +  ++",
		"  +     ++    ++ ++  +++++   ++  ++++",
		"                 +",
		"                 +",
		"                 +",
		"              +  +",
		"               ++"}

	local explode1_data = {
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"                !",
		"            !",
		"             !#!",
		"           ! #!# !",
		"             !#!!",
		"           ! !## !",
		"            ! !!",
		"                !"}

	local explode2_data = {
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"                 !",
		"             !",
		"           ## ! !  #",
		"            #  ! ! #",
		"           ! ! $$",
		"          !  ### !$! $",
		"            $$$#$$$",
		"             #$!#$  !",
		"          $ !$$$$  !",
		"             ##!$$! #",
		"           !#### !  ##",
		"             ##!  !",
		"             $  !"}

	local explode3_data = {
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"        !     !   #",
		"           !  $ !  !   #",
		"            # #  $$  !",
		"         !  ##$   $ #",
		"              $ !  !  !",
		"           !  $  !   !",
		"        ##  !  !   # $",
		"          $        # $ !",
		"           $     !  !",
		"        !  $## !",
		"          ! $     !  ! !",
		"             ! !   ## $",
		"         !   !   $ ## $",
		"           !$$   $",
		"           $ $$$       $",
		"        #  # # $  !"}

	local explode4_data = {
		"",
		"",
		"          !",
		"",
		"             ##    $     !",
		"                  $   !",
		"         $      $    $",
		"           $        $",
		"      ##      !  $",
		"   $       #  !       !  $",
		"        $ ##   $##  #",
		"                   $   $     $",
		"                     ##  $",
		"    !   !$            #    !",
		"     $  !        !  $     $",
		"       #    $        !",
		"       # $             $ ##",
		"    $                      !",
		"       !      $     $$    $",
		"                      $",
		"       #  $         #   $",
		"      #  $   !  $!  #    ##",
		"            # $       !",
		"        !   #$    #    $",
		"    !  $       $   $    $",
		"                $    #",
		"           $         #",
		"             $    !",
		"",
		"                    $"}

	local explode5_data = {
		"                !",
		"           #          $       $",
		"   $       #",
		"    #         $             $",
		"",
		"        !$        #",
		"                               #",
		"                        $",
		"   $         $",
		"                           #",
		"",
		"                      !",
		"       !",
		"          #                    !",
		"",
		" ##                     $",
		"     !                      #$",
		"                            #",
		"",
		"",
		"      $",
		"                              #",
		" $",
		"                        $",
		"              #",
		"",
		"      $   $",
		"             $       $   !   #",
		"  !      #                    #",
		"                  !",
		"   #                       $",
		"  #"}

	local animation = {explode5_data, explode4_data, explode3_data, explode2_data, explode1_data}
	local animation_frames = 30

	local enemy_data = 
		{0x6700, 0x6720, 0x6740, 0x6760, 0x6780, 0x67a0, 0x67c0, 0x67e0, 
		 0x6400, 0x6420, 0x6440, 0x6460, 0x6480, 
		 0x6500, 0x6510, 0x6520, 0x6530, 0x6540, 0x6550, 0x6550,
		 0x65a0, 0x65b0, 0x65c0, 0x65d0, 0x65e0, 0x65f0}

	-- Position of shield pickup by stage number
	local pickup_table = {}
	pickup_table[1] = {15, 212}
	pickup_table[2] = {8, 208}
  	pickup_table[3] = {121, 73}
	pickup_table[4] = {8, 192}
	
	local char_table = {}
	char_table["0"] = 0x0
	char_table["1"] = 0x1
	char_table["2"] = 0x2
	char_table["3"] = 0x3
	char_table["4"] = 0x4
	char_table["5"] = 0x5
	char_table["6"] = 0x6
	char_table["7"] = 0x7
	char_table["8"] = 0x8
	char_table["9"] = 0x9
	char_table[" "] = 0x10
	char_table["A"] = 0x11
	char_table["B"] = 0x12
	char_table["C"] = 0x13
	char_table["D"] = 0x14
	char_table["E"] = 0x15
	char_table["F"] = 0x16
	char_table["G"] = 0x17
	char_table["H"] = 0x18
	char_table["I"] = 0x19
	char_table["J"] = 0x1a
	char_table["K"] = 0x1b
	char_table["L"] = 0x1c
	char_table["M"] = 0x1d
	char_table["N"] = 0x1e
	char_table["O"] = 0x1f
	char_table["P"] = 0x20
	char_table["Q"] = 0x21
	char_table["R"] = 0x22
	char_table["S"] = 0x23
	char_table["T"] = 0x24
	char_table["U"] = 0x25
	char_table["V"] = 0x26
	char_table["W"] = 0x27
	char_table["X"] = 0x28
	char_table["Y"] = 0x29
	char_table["Z"] = 0x2a
	char_table["-"] = 0x2c
	char_table["."] = 0x2b
	char_table[":"] = 0x2e
	char_table["("] = 0x30
	char_table[")"] = 0x31
	char_table["!"] = 0x38
	char_table["'"] = 0x3a
	char_table["="] = 0x7c -- horizontal bar
	char_table["?"] = 0xfb

	local mame_version
	local is_pi
	local mac, scr, cpu, mem, s_cpu, s_mem

	function initialize()
		mame_version = tonumber(emu.app_version())
		is_pi = is_pi()
		play("load")	
		if mame_version >= 0.196 then
			if type(manager.machine) == "userdata" then
				mac = manager.machine
			else
				mac =  manager:machine()
			end			
		else
			print("ERROR: The galakong plugin requires MAME version 0.196 or greater.")
		end
		if mac ~= nil then
			scr = mac.screens[":screen"]
			cpu = mac.devices[":maincpu"]
			mem = cpu.spaces["program"]
			s_cpu = mac.devices[":soundcpu"]
			s_mem = s_cpu.spaces["data"]

			change_title()

			--Generate a starfield
			number_of_stars = 255 --(85x3)
			--Option to disable the starfield
			if os.getenv("GALAKONG_NOSTARS") == "1" then
				number_of_stars = 0
			end
			for _=1, number_of_stars do
				table.insert(starfield, math.random(255))
				table.insert(starfield, math.random(223))
				table.insert(starfield, BLACK)
			end	

			--Option to disable explosion animation
			if os.getenv("GALAKONG_NOEXPLOSIONS") == "1" then
				animation = {}
				animation_frames = 0
			end

			--Add more delay to the GAME OVER screen
			mem:write_direct_u8(0x132f, 0xff)
		end
	end
	
	function main()
		--optimise access to library functions
		local _random = math.random
		local _floor = math.floor
		local _ceil = math.ceil
		local _format = string.format
		local _sub = string.sub
		local _music
		local _sprite
		local _exp_y, _exp_x

		if cpu ~= nil then
			local stage = mem:read_u8(0x6227)  -- 1-girders, 2-pies, 3-elevator, 4-rivets
			local level = mem:read_u8(0x6229)
			local mode2 = mem:read_u8(0x600a)
			local left, right, fire
			local _frame = scr:frame_number()

			if mode2 == 0x1 then -- Initial screen
				started = false

				-- Coins entered fixed at 2. Don't display number of credits on bottom line
				scr:draw_box(0,0, 8, 224, BLACK, BLACK)
				if mem:read_u8(0x6001) ~= 2 then
					mem:write_direct_u8(0x6001, 0x2)
				end

				-- Display GalaKong logo and other bits
				draw_graphic(galakong_logo_data, 224, 60)
				draw_graphic(yard_logo_data, 19, 175)
				write_ram_message(0x77be, " VERSION "..exports.version)

				-- Alternative coin entry sound
				if mem:read_u8(0x6083) == 2 then
					clear_sounds()
					play("coin")
				end

				-- For CO-OP mode.  Do not allow alternating 1UP-2UP style gameplay.
				mem:write_direct_u8(0x6048, 0x0)
				if mem:read_u8(0x600f) == 1 then  -- 2 player game
					play_mode = 2
					mem:write_direct_u8(0x600d, 0x0)
					mem:write_direct_u8(0x600e, 0x0)
					mem:write_direct_u8(0x600f, 0x0)
				end
			else
				draw_stars()
			end

			-- CO-OP appears top-right for 2 player mode
			if play_mode == 2 then
				write_ram_message(0x7504, "CO-OP")
			end

			if mode2 == 0x7 then  -- Intro screen
				if mem:read_u8(0x608a) == 1 then
					clear_sounds()
					if not started then
						play("start")
					end
					started = true
					score, last_score = "000000", "000000"
					million_wraps = 0
					total_shots, total_hits = {}, {}
				end
			end

			if mode2 == 0x8 then -- before how high screen
				howhigh_ready = true
			end

			if mode2 == 0xa then  --how high screen
				dead = false
				explosions = {}
				draw_ship(24, 160, 1)
				if started then
					stop("start")
					started = false
				end
				if howhigh_ready then
					-- random chance of displaying alternative message
					if _random(2) == 1 then
						write_ram_message(0xc777e, "    ALL YOUR BASE ARE       ")
						write_ram_message(0xc777f, "     BELONG TO US !!        ")
					end
					howhigh_ready = false
				end
			end

			if mode2 == 0x10 then -- end of game
				game_stats()
				play_mode = 1
			end

			if mode2 >= 0xb and mode2 <= 0xd then  -- during gameplay
				jumpman_x = mem:read_u8(0x6203) - 15
				jumpman_y = mem:read_u8(0x6205)

				if pickup then
					-- shield was collected so the ship can now be controlled
					left, right, fire = get_inputs()
				end

				if mode2 == 0xb then
					-- reset some things
					pickup = false
					missile_y = nil
					bonus = 0
					name_entry = 0
					explosions = {}
				elseif mode2 == 0xc then
					-- adjust ship y with jumpman when at screen bottom
					ship_y = 230 - jumpman_y
					if ship_y > 0 then
						ship_y = 0
					end
				elseif mode2 == 0xd then
					if mem:read_u8(0x639d) == 1 and not dead then
						dead = true
						clear_sounds()
						play("dead")
					end

					-- animate ship downwards
					if ship_y >= -8 then
						ship_y = ship_y - 0.5
					end
				end

				if not pickup and mode2 ~= 0xd then
					pickup_y, pickup_x = pickup_table[stage][1], pickup_table[stage][2]
					draw_pickup(pickup_y, pickup_x)

					-- Check for Jumpman collision with pickup
					if jumpman_x >= pickup_x and jumpman_x <= pickup_x + 7 and 256 - jumpman_y <= pickup_y + 12 and 256 - jumpman_y >= pickup_y then
						if not pickup then
							play("pickup")
						end
						ship_x = jumpman_x
						pickup = true
					end
				else
					-- move ship
					if play_mode == 1 and mem:read_u8(0x6215) ~= 1 then
						-- The ship follows Jumpman X position unless on a ladder
						if ship_x < jumpman_x then
							ship_x = _floor(ship_x + 1)
						elseif ship_x > jumpman_x then
							ship_x = _floor(ship_x - 1)
						end
					else
						if left and ship_x >= 7 then
							ship_x = ship_x - 1.25
						end
						if right and ship_x <= 216 then
							ship_x = ship_x + 1.25
						end
					end

					if mode2 == 0xc then
						-- fire a missile
						if fire and not missile_y then
							play("shoot")
							missile_y = 8
							missile_x = ship_x
							hit_count = 0

							if total_shots[level] == nil then
								total_shots[level] = 1
							else
								total_shots[level] = total_shots[level] + 1
							end
						end

						-- animate the missile
						if missile_y ~= nil then
							-- check for enemy hit
							for _, address in pairs(enemy_data) do
								enemy_x = mem:read_u8(address + 3)
								enemy_y = mem:read_u8(address + 5)

								if mem:read_u8(address) ~= 0 and enemy_y > 0 and enemy_x ~= 250 then
									enemy_x = enemy_x - 15
									enemy_y = 256 - enemy_y
									if missile_y > enemy_y - 7 and missile_y < enemy_y + 7 and missile_x > enemy_x - 7 and missile_x < enemy_x + 7 then
										hit_count = hit_count + 1
										_exp_y = _format("%03d", enemy_y)
										_exp_x = _format("%03d", enemy_x)

										if (address >= 0x6400 and address < 0x6500) or (address >= 0x65a0 and address < 0x6600) then
											-- destroy a fireball, firefox or pie.  Move off screen and clean up later.
											explosions[_exp_y.._exp_x] = animation_frames
											mem:write_u8(address+0x3, 250)
											mem:write_u8(address+0x5, 8)
											mem:write_u8(address+0xe, 250)
											mem:write_u8(address+0xf, 8)
											last_hit_cleanup = _frame
											missile_y = missile_y + 10     -- move missile further to prevent double-hit
										elseif address >= 0x6500 and address < 0x65a0 then
											-- destroy a spring. Move the spring off screen
											explosions[_exp_y.._exp_x] = animation_frames
											mem:write_u8(address + 3, 2)
											mem:write_u8(address + 5, 80)
										else
											-- destroy a barrel
											explosions[_exp_y.._exp_x] = _ceil(animation_frames / 2)
											mem:write_u8(address + 3, 0)
											mem:write_u8(address + 5, 0)
										end
										-- play bonus sound
										mem:write_u8(0x6085, 0)
										mem:write_u8(0x6085, 1)

										-- calculate bonus for destroying multiple enemies.
										if hit_count == 1 then
											bonus = 300
											_sprite = 0x7d
										elseif hit_count == 2 then
											bonus = 200  -- +200 = 500 total
											_sprite = 0x7e
										elseif hit_count == 3 then  -- stop awarding when 800 points is reached
											bonus = 300  -- +300 = 800 total
											_sprite = 0x7f
										else
											bonus = 0
										end

										if bonus > 0 then
											--display bonus points
											mem:write_u8(0x6a30, missile_x + 15)
											mem:write_u8(0x6a31, _sprite)
											mem:write_u8(0x6a32, 0x7)
											mem:write_u8(0x6a33, 256 - missile_y)
											last_bonus = _frame

											--7 digits for the calculation purposes incase we tick over the million
											score = _format("%07d", tonumber(get_score_segment(0x60b4)..get_score_segment(0x60b3)..get_score_segment(0x60b2)) + bonus)
											--update 6 digit score in ram
											score = _sub(score, 2, 7)
											set_score_segment(0x60b4, _sub(score, 1,2))
											set_score_segment(0x60b3, _sub(score, 3,4))
											set_score_segment(0x60b2, _sub(score, 5,6))

											-- update score on screen
											write_ram_message(0x7781, score)
										end
									end
								end
							end

							draw_missile(missile_y, missile_x)
							if not mac.paused then
								missile_y = missile_y + 6
							end

							if missile_y >= 224 then
								if bonus > 0 then
									-- register that the shot was a hit
									if total_hits[level] == nil then
										total_hits[level] = 1
									else
										total_hits[level] = total_hits[level] + 1
									end
								end
								missile_y = nil
								bonus = 0
							end
						end
					end

					-- Clean up any destroyed fireballs
					if _frame - last_hit_cleanup > 1 then
						for _, address in pairs(enemy_data) do
							if mem:read_u8(address + 3) == 250 then
								mem:write_u8(address, 0)         -- set status to inactive
							end
						end
					end

					-- clear awarded point sprites
					if last_bonus ~= 0 and _frame - last_bonus > 60 then
						mem:write_u8(0x6a30, 0x0)
						last_bonus = 0
					end

					if mode2 == 0xc then
						draw_ship(ship_y, ship_x)
					end

					-- animate explosions
					for location, phase in pairs(explosions) do
						if phase > 0 then
							_exp_y = _sub(location, 1,3) + 16
							_exp_x = _sub(location, 4,6) - 16
							draw_graphic(animation[_ceil(phase / (animation_frames / 5))], _exp_y, _exp_x)
							if not mac.paused then
								explosions[location] = phase - 1
							end
						end
					end
				end

				-- Check for wrapping of score at million
				score = _format("%06d", tonumber(get_score_segment(0x60b4)..get_score_segment(0x60b3)..get_score_segment(0x60b2)))
				if tonumber(score) < 5000 and tonumber(score) < tonumber(last_score) then
					million_wraps = million_wraps + 1
				end
				last_score = score

				-- write millions on screen
				if million_wraps > 0 then
					mem:write_u8(0x77a1, 0x70 + million_wraps)
				end
			end

			if mode2 == 0x16 then  -- end of level
				_music = mem:read_u8(0x608a)
				if _music == 12 or _music == 5 then
					level_stats(total_shots[level], total_hits[level])
					clear_sounds()
					if not end_of_level then
						play("level")
					end
					end_of_level = true
				end
			else
				end_of_level = false
			end

			if mode2 == 0x15 then  -- name entry screen
				clear_sounds()
				if name_entry == 0 then
					name_entry = 1
					play("name")
				end
			end
			if mode2 == 0x14 and name_entry == 1 then
				stop("name")
				name_entry = 2
			end
		end
	end

	function get_inputs()
		local _left, _right, _fire = false, false, false
		local _input = 0
		if play_mode == 2 then
			_input = mem:read_u8(0xc7d00)
			if _input >= 128 then
				_fire = true
				_input = _input - 128
			end		
			if _input == 4 then
				_left = true
			end
			if _input == 8 then
				_right = true
			end
		else
			_input = mem:read_u8(0xc7c00)
			if _input >= 16 and _input <= 31 then
				_fire = true
				_input = _input - 16
			end
			if _input == 2 then
				_left = true
			end
			if _input == 1 then
				_right = true
			end
		end
		return _left, _right, _fire
	end

	function draw_missile(y, x)
		scr:draw_box(y+4, x-1, y+6, x+2, BLUE, BLUE)
		scr:draw_box(y, x, y+4, x+1, RED, RED)
		scr:draw_box(y+4, x, y+5, x+1, WHITE, WHITE)
		scr:draw_box(y+5, x, y+8, x+1, BLUE, BLUE)
	end

	function draw_pickup(y, x)
		scr:draw_box(y+3, x, y+12, x+7, WHITE, WHITE)
		scr:draw_box(y+2, x+1, y+3, x+6, WHITE, WHITE)
		scr:draw_box(y+1, x+2, y+2, x+5, WHITE, WHITE)
		scr:draw_box(y, x+3, y+1, x+4, WHITE, WHITE)
		scr:draw_box(y+6, x, y+8, x+7, RED, RED)
		scr:draw_box(y+9, x, y+11, x+7, RED, RED)
		scr:draw_box(y+4, x+1, y+5, x+2, BLUE, BLUE)
		scr:draw_box(y+3, x+2, y+4, x+3, BLUE, BLUE)
		scr:draw_box(y+2, x+3, y+3, x+4, BLUE, BLUE)
		scr:draw_box(y+3, x+4, y+4, x+5, BLUE, BLUE)
		scr:draw_box(y+4, x+5, y+5, x+6, BLUE, BLUE)
	end

	function draw_ship(y, x)
		-- y, x relates to gun of ship.
		-- _y, _x relates to bottom left corner
		local _y = y
		local _x = x - 7
		scr:draw_box(_y+2, _x+6, _y+13, _x+9, WHITE, WHITE)
		scr:draw_box(_y, _x+7, _y+16, _x+8, WHITE, WHITE)
		scr:draw_box(_y+3, _x+3, _y+8, _x+12, WHITE, WHITE)
		scr:draw_box(_y+8, _x+5, _y+9, _x+10, WHITE, WHITE)
		scr:draw_box(_y+2, _x+7, _y+3, _x+9, WHITE, WHITE)		
		scr:draw_box(_y, _x, _y+8, _x+1, WHITE, WHITE)
		scr:draw_box(_y, _x+14, _y+8, _x+15, WHITE, WHITE)
		scr:draw_box(_y+1, _x+1, _y+4, _x+2, WHITE, WHITE)
		scr:draw_box(_y+2, _x+2, _y+5, _x+3, WHITE, WHITE)
		scr:draw_box(_y+1, _x+13, _y+4, _x+14, WHITE, WHITE)
		scr:draw_box(_y+2, _x+12, _y+5, _x+13, WHITE, WHITE)
		scr:draw_box(_y+6, _x, _y+8, _x+1, RED, RED)
		scr:draw_box(_y+6, _x+14, _y+8, _x+15, RED, RED)
		scr:draw_box(_y+8, _x+3, _y+10, _x+4, RED, RED)
		scr:draw_box(_y+8, _x+11, _y+10, _x+12, RED, RED)
		scr:draw_box(_y+1, _x+4, _y+3, _x+6, RED, RED)
		scr:draw_box(_y+1, _x+9, _y+3, _x+11, RED, RED)
		scr:draw_box(_y+3, _x+5, _y+4, _x+6, RED, RED)
		scr:draw_box(_y+3, _x+9, _y+4, _x+10, RED, RED)
		scr:draw_box(_y+5, _x+6, _y+7, _x+7, RED, RED)
		scr:draw_box(_y+6, _x+7, _y+8, _x+8, RED, RED)
		scr:draw_box(_y+5, _x+8, _y+7, _x+9, RED, RED)
		scr:draw_box(_y+6, _x+3, _y+7, _x+4, BLUE, BLUE)
		scr:draw_box(_y+7, _x+4, _y+8, _x+5, BLUE, BLUE)
		scr:draw_box(_y+6, _x+11, _y+7, _x+12, BLUE, BLUE)
		scr:draw_box(_y+7, _x+10, _y+8, _x+11, BLUE, BLUE)
	end

	function draw_stars()
		-- draw the starfield background
		local _ypos, _xpos, _col
		local _stars = number_of_stars
		local _random = math.random
		local _frame = scr:frame_number()

		for key=1, _stars, 3 do
			_ypos, _xpos, _col = starfield[key], starfield[key+1], starfield[key+2]

			-- Draw a coloured pixel as a star
			if _col ~= BLACK then
				--Only display a star when the background pixel is black (for MAME versions from 0.227 which support pixel()).
				--This ensures stars only appear in background.
				--NOTE: There is an offset when reading pixels (0, 16).  This was a pain in the ass to work out!
				if mame_version < 0.227 or (scr:pixel(_ypos, _xpos + 16) == BLACK) then
					scr:draw_box(_ypos, _xpos, _ypos + 1, _xpos + 1, _col, _col)
				end
			end

			--do we regenerate the starfield colours
			if _frame - last_starfield > 15 then
				_col = BLACK
				_r = _random(255)
				if _r > 128 then
					-- generate a random bright colour
					_col = BLACK + (_r << 16) + (_random(128, 255) << 8) + _random(128, 255)
				end
				starfield[key+2] = _col
			end

			--scroll the starfield during gameplay
			if not mac.paused then
				starfield[key] = starfield[key] - 0.75
				if starfield[key] < 0 then
					starfield[key] = 255
				end
			end
		end

		if _frame - last_starfield > 15 then
			last_starfield = _frame
		end
	end
	
	function draw_graphic(data, pos_y, pos_x)
		local _len = string.len
		local _sub = string.sub
		local _col
		for _y, line in pairs(data) do
			for _x=1, _len(line) do
				_col = _sub(line, _x, _x)
				if _col ~= " " then
					scr:draw_box(pos_y -_y, pos_x + _x, pos_y -_y + 1, pos_x +_x + 1, graphics_palette[_col], graphics_palette[_col])
				end
			end
		end
	end
		
	function level_stats(shots, hits)
		local _format = string.format
		local _shots = shots or 0
		local _hits = hits or 0
		local _ratio = 0
		if _shots > 0 and _hits > 0 then
			_ratio = (_hits / _shots) * 100
		end
		stats_box("LEVEL STATS", 1, _format("%d", _shots), _format("%d", _hits), _format("%.1f", _ratio))
	end
	
	function game_stats()
		local _format = string.format
		local _shots = 0
		local _hits = 0
		local _ratio = 0
		for _level=1,22 do
			if total_shots[_level] ~= nil then
				_shots = _shots + total_shots[_level]
			end
			if total_hits[_level] ~= nil then
				_hits = _hits + total_hits[_level]
			end
		end
		if _shots > 0 and _hits > 0 then
			_ratio = (_hits / _shots) * 100
		end
		stats_box("GAME OVER", 7, _format("%d", _shots), _format("%d", _hits), _format("%.1f", _ratio))
	end

	function stats_box(title, offset, var1, var2, var3)
		write_ram_message(0x774e + offset, "======================")
		write_ram_message(0x768e + offset, title)
		write_ram_message(0x774f + offset, "                      ")
		write_ram_message(0x7750 + offset, "                      ")
		write_ram_message(0x7751 + offset, "                      ")
		write_ram_message(0x7752 + offset, "                      ")
		write_ram_message(0x7753 + offset, "                      ")
		write_ram_message(0x7754 + offset, "======================")
		write_ram_message(0x7730 + offset, "SHOTS FIRED:   "..var1)
		write_ram_message(0x7731 + offset, "NUMBER OF HITS:"..var2)
		write_ram_message(0x7732 + offset, "HIT-MISS RATIO:"..var3)
	end

	function write_ram_message(start_address, text)
		local _sub = string.sub
		local _len = string.len
		local _table = char_table
		-- write characters of message to DK's video ram
		for key=1, _len(text) do
			mem:write_u8(start_address - ((key - 1) * 32), _table[_sub(text, key, key)])
		end
	end	
	
	function write_rom_message(start_address, text)
		-- write characters of message to DK's ROM
		local _len = string.len
		local _sub = string.sub
		local _table = char_table
		for key=1, _len(text) do
			mem:write_direct_u8(start_address + (key - 1), _table[_sub(text, key, key)])
		end
	end
	
	function get_score_segment(address)
		local _format = string.format
		return _format("%02d", _format("%x", mem:read_u8(address)))
	end

	function set_score_segment(address, segment)
		mem:write_u8(address, tonumber(segment, 16))
	end
	
	function change_title()
		if emu.romname() == "dkong" then
			-- no error checking, pay attention to string lengths, also you need to YELL, only caps
			-- change "HIGH SCORE" to "DK SHOOTER"
			-- HIGH SCORE is 10 characters, pad with space if necessary
			--                        1234567890
			write_rom_message(0x36b4," GALAKONG ")

			-- Change "HOW HIGH CAN YOU GET" text in rom to "HOW UP CAN YOU SCHMUP ?"
			-- how high is 23 characters, pad with space if necessary
			--                        12345678901234567890123
			write_rom_message(0x36ce,"HOW UP CAN YOU SCHMUP?")
			
			-- high score entries are 12 character no need to pad with spaces
			--                          123456789012
			--1st
			--write_rom_message(0x3574,"PAC-MAN")
			--2nd
			--write_rom_message(0x3596,"ATE")
			--3rd
			--write_rom_message(0x35b8,"MY")
			--4th
			--write_rom_message(0x35da,"HAMSTER")
			--5th
			--write_rom_message(0x35fc,"!!!:::::!!!!")
		end
	end
	
	function clear_sounds()
		-- clear music on soundcpu
		for key=0, 32 do
			s_mem:write_u8(0x0 + key, 0x0)
		end
		-- clear soundfx buffer (retain the walking 0x6080 sound)
		for key=0, 11 do
			mem:write_u8(0x6081 + key, 0x0)
		end
	end

	function is_pi()
		return package.config:sub(1,1) == "/"
	end
	
	function play(sound)
		if is_pi then
			io.popen("aplay -q plugins/galakong/sounds/"..sound..".wav &")
		else
			io.popen("start /B /HIGH plugins/galakong/bin/sounder.exe /id "..sound.." /stopbyid "..sound.." plugins/galakong/sounds/"..sound..".wav")
		end
	end
	
	function stop()
		if is_pi then
			io.popen("pkill aplay &")
		else
			io.popen("start /B /HIGH plugins/galakong/bin/sounder.exe /stop")
		end
	end
	
	emu.register_start(function()
		initialize()
	end)
	
	emu.register_stop(function()
		stop()
	end)
	
	emu.register_frame_done(main, "frame")
end
return exports