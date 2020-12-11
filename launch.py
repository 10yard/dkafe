import sys
import dk_system as _s
import dk_global as _g
from dk_config import *
from random import randint
import pygetwindow


def exit_program(confirm=False):
    if confirm:
        open_menu(_g.exitmenu)
    else:
        pygame.quit()
        sys.exit()


def initialise_screen(reset=False):
    _g.screen = pygame.display.set_mode(GRAPHICS, pygame.FULLSCREEN * int(FULLSCREEN) | pygame.SCALED)
    pygame.mouse.set_visible(False)
    if not reset:
        _g.screen_map = _g.screen.copy()
        _g.screen_map.blit(get_image("artwork/map.png"), TOPLEFT)
    pygame.display.set_caption(TITLE)
    pygame.display.set_icon(get_image("artwork/dkafe.ico"))


def clear_screen(colour=BLACK, and_reset_display=False):
    _g.screen.fill(colour)
    update_screen()
    if and_reset_display:
        initialise_screen(reset=True)
        _g.window.maximize() if FULLSCREEN else _g.window.activate()


def update_screen(delay_ms=0):
    pygame.display.update()
    pygame.time.delay(delay_ms)
    clock.tick(CLOCK_RATE)


def write_text(text=None, font=pl_font, x=0, y=0, fg=WHITE, bg=None, bubble=False, box=False, rj_adjust=0):
    # Write text to screen at given position using fg and bg colour (None for transparent)
    if text:
        img = font.render(text, False, fg, bg)
        w, h = img.get_width(), img.get_height()
        _x = x - w + rj_adjust if rj_adjust else x
        _g.screen.blit(img, (_x, y))
        if box or bubble:
            pygame.draw.rect(_g.screen, fg, (_x - 2, y - 1, w + 3, h + 2), 1)
            pygame.draw.line(_g.screen, bg, (_x - 1, y), (_x - 1, y + 5))
            if bubble:
                for point in ((_x - 2, y - 1), (_x + w + 1, y - 1), (_x - 2, y + h), (_x + w + 1, y + h)):
                    _g.screen.set_at(point, BLACK)
                pygame.draw.polygon(_g.screen, bg, [(_x - 2, y + 2), (_x - 6, y + 3), (_x - 2, y + 4)])
                pygame.draw.lines(_g.screen, fg, False, [(_x - 2, y + 2), (_x - 6, y + 3), (_x - 2, y + 4)], 1)


def flash_message(message, x, y):
    clear_screen()
    for i in (0, 1, 2) * 7:
        write_text(message, font=dk_font, x=x, y=y, fg=(BROWN, PINK, RED)[i])
        update_screen(delay_ms=40)
    clear_screen()


def get_image(image_key, fade=False):
    # Load image or read prevously loaded image from the dictionary/cache
    _key = image_key + str(fade)
    if _key not in _g.image_cache:
        _g.image_cache[_key] = pygame.image.load(image_key).convert_alpha()
        if fade:
            _g.image_cache[_key].set_alpha(100)
    return _g.image_cache[_key]


def read_map(x, y):
    # Return R colour value from pixel at provided x, y position on the screen map
    try:
        return _g.screen_map.get_at((int(x), int(y)))[0]
    except IndexError:
        return 254


def get_map_info(direction=None, x=0, y=0):
    # Return information from map e.g. ladders and obstacles preventing movement in intended direction
    map_info = []
    _x = int(x) if x else int(_g.xpos) + SPRITE_HALF
    _y = int(y) if y else int(_g.ypos) + SPRITE_FULL
    try:
        if read_map(_x - SPRITE_HALF, _y) == 254:
            map_info.append("BLOCKED_LEFT")
        if read_map(_x + SPRITE_HALF, _y) == 254:
            map_info.append("BLOCKED_RIGHT")
        if read_map(_x, _y) == 236:
            map_info.append("FOOT_UNDER_PLATFORM")
        if read_map(_x, _y + 1) == 0:
            map_info.append("FOOT_ABOVE_PLATFORM")

        # ladder detection based on direction of travel
        _r = read_map(_x - 1, _y + (direction == "d"))
        for zone_name, zone_values in LADDER_ZONES:
            if _r in zone_values:
                map_info.append(zone_name)
    except IndexError:
        map_info.append("ERROR_READING_SCREEN_MAP")
    return map_info


def reset_all_inputs():
    # Push KEYUP events which can be lost after calling external programs
    for attr, control in CONTROL_ASSIGNMENTS:
        event = pygame.event.Event(pygame.KEYUP, {'key': control})
        pygame.event.post(event)


def check_for_input():
    for event in pygame.event.get():
        # General jumpman controls
        if event.type in (pygame.KEYDOWN, pygame.KEYUP):
            for attr, control in CONTROL_ASSIGNMENTS:
                if event.key == control:
                    setattr(_g, attr, event.type == pygame.KEYDOWN)

        # Special controls
        if event.type == pygame.KEYDOWN:
            _g.active = True
            _g.lastmove = _g.timer.duration
            if event.key == CONTROL_EXIT:
                exit_program(confirm=CONFIRM_EXIT)
            if event.key in (CONTROL_P2, CONTROL_ACTION) and ENABLE_MENU:
                open_menu(_g.menu)
            if event.key == CONTROL_COIN:
                _g.showinfo = not _g.showinfo
                display_icons()
        if event.type == pygame.QUIT:
            exit_program()


def play_sound_effect(effect=None, stop=False):
    if stop:
        pygame.mixer.stop()
    elif effect:
        pygame.mixer.Sound(effect).play()


def play_intro_animation():
    play_sound_effect(effect="sounds/jump.wav")
    for _key in _s.intro_frames():
        check_for_input()
        if _g.jump or _g.start or _g.skip:
            play_sound_effect(stop=True)
            break

        if type(_key) is int:
            # Flash DK Logo
            _g.screen.blit(get_image("artwork/intro/f%s.png" % (str(_key % 2) if _key <= 40 else "1")), TOPLEFT)
        else:
            # Show DK climb scene
            _g.screen.blit(get_image(_key), TOPLEFT)
            current = int(_key.split("scene_")[1][:4])

            # play sound if required for the current frame
            if current in SCENE_SOUNDS:
                play_sound_effect(SCENE_SOUNDS[current])

            # display nearby icons as girders are broken
            for from_scene, to_scene, below_y, above_y, smash_scene in SCENE_ICONS:
                if from_scene < current < to_scene:
                    display_icons(below_y=below_y, above_y=above_y, intro=True, smash=current < smash_scene)

            # Title and messages
            write_text(("", QUESTION)[855 < current < 1010], font=dk_font, x=12, y=240, fg=WHITE, bg=BLACK)
            write_text(" DK ARCADE ", font=dk_font, x=69, y=0, fg=RED, bg=BLACK)
            write_text(" FRONT END ", font=dk_font, x=69, y=8, fg=WHITE, bg=BLACK)

        update_screen(delay_ms=40)


def display_icons(detect_only=False, with_background=False, below_y=None, above_y=None, intro=False, smash=False):
    if with_background:
        _g.screen.blit(get_image("artwork/background.png"), TOPLEFT)
    nearby = None
    # Display icons and return icon that is near to Jumpman.  Alternate between looping the list forwards and reversed.
    for _x, _y, name, sub, des, emu, state, unlock, _min, bonus in \
            [_g.icons, reversed(_g.icons)][_g.timer.duration % 2 < 1]:
        unlocked = True
        if _g.score < unlock and UNLOCK_MODE and not intro:
            unlocked = False
        if not below_y or not above_y or (below_y >= _y >= above_y):
            icon_image = os.path.join("artwork/icon", sub, name + ".png")
            if smash:
                icon_image = f"artwork/sprite/smash{str(randint(0,3))}.png"
            if not os.path.exists(icon_image):
                icon_image = os.path.join("artwork/icon/default_machine.png")
            img = get_image(icon_image, fade=not unlocked)
            w, h = img.get_width(), img.get_height()
            if _g.showinfo:
                # Show game info above icons
                write_text(des, x=_x, y=_y - 6, fg=MAGENTA, bg=WHITE, box=True, rj_adjust=(_x > 180) * w)
            if _x < _g.xpos + SPRITE_HALF < _x + w and (_y < _g.ypos + SPRITE_HALF < _y + h):
                # Pauline to announce the game found near Jumpman.  Return the game icon information.
                if not unlocked and _g.timer.duration % 2 < 1:
                    des = f"UNLOCK at {unlock}"
                elif int(UNLOCK_MODE) and unlocked:
                        if _g.timer.duration % 4 < 1:
                            des = f'{_s.format_K(_min)} Minimum'
                        elif _g.timer.duration % 4 < 2:
                            des = f'{_s.format_K(bonus)} Bonus!'
                elif not int(FREE_PLAY) and _g.timer.duration % 2 < 1:
                    des = f'${str(PLAY_COST)} TO PLAY'
                write_text(des.upper(), x=108, y=37, fg=WHITE, bg=MAGENTA, bubble=True)
                if unlocked:
                    nearby = (sub, name, emu, state, unlock, _min, bonus)
            if not detect_only:
                _g.screen.blit(img, (_x, _y))
    return nearby


def adjust_jumpman():
    # Adjust Jumpman's vertical position with the sloping platform
    map_info = get_map_info("l")
    if "FOOT_UNDER_PLATFORM" in map_info or "TOP_OF_ANY_LADDER" in map_info:
        _g.ypos += -1
    elif "FOOT_ABOVE_PLATFORM" in map_info:
        _g.ypos += +1


def animate_jumpman(direction=None, horizontal_movement=1, midjump=False):
    sprite_file = f"artwork/sprite/jm{direction}#.png"
    sound_file = None
    map_info = get_map_info(direction)

    if midjump:
        # Jumpman is jumping.  Check for landing platform and blocks
        if _g.jump_sequence == 1:
            sound_file = f"sounds/jump.wav"
        if "BLOCKED_LEFT" in map_info or "BLOCKED_RIGHT" in map_info:
            sprite_file = sprite_file.replace("#", "0")
        else:
            sprite_file = sprite_file.replace("#", "1")
            _g.xpos += _g.right + (_g.left * -1)
        if "FOOT_UNDER_PLATFORM" not in map_info or JUMP_PIXELS[_g.jump_sequence] < 0:
            _g.ypos += JUMP_PIXELS[_g.jump_sequence]

    elif direction in ("l", "r"):
        _g.ready = False
        ladder_info = get_map_info("u") + get_map_info("d")
        if "LADDER_DETECTED" in ladder_info and "END_OF_LADDER" not in ladder_info:
            _g.screen.blit(_g.last_image, (_g.xpos, int(_g.ypos)))
            return 0

        if direction == "l" and "BLOCKED_LEFT" not in map_info:
            _g.facing = 0
        elif direction == "r" and "BLOCKED_RIGHT" not in map_info:
            _g.facing = 1
        else:
            _g.screen.blit(_g.last_image, (_g.xpos, int(_g.ypos)))
            return 0
        _g.xpos += horizontal_movement * [-1, 1][_g.facing]
        _g.sprite_index += 0.5
        adjust_jumpman()

        sprite_file = sprite_file.replace("#", str(int(_g.sprite_index) % 3))
        if _g.sprite_index % 12 in WALK_SOUNDS:
            sound_file = WALK_SOUNDS[_g.sprite_index % 12]

    elif direction in ("u", "d"):
        if "LADDER_DETECTED" in map_info:
            if "END_OF_LADDER" in map_info:
                sprite_file = sprite_file.replace("#", "0")
            elif "NEARING_END_OF_LADDER" in map_info:
                sprite_file = sprite_file.replace("#", "3")
            elif "APPROACHING_END_OF_LADDER" in map_info:
                sprite_file = sprite_file.replace("#", "4")
            else:
                # Slower movement on the ladders
                sprite_file = sprite_file.replace("#", ("1", "2")[_g.sprite_index % 10 < 5])
            _g.ypos += (0.5, -0.5)[direction == "u"]

            if int(_g.sprite_index % 9) == 5:
                sound_file = "sounds/walk0.wav"
            _g.sprite_index += 1

        elif direction == "u" and display_icons(detect_only=True):
            # Jumpman is in position to play a game
            sprite_file = sprite_file.replace("#", "0")
            _g.ready = True

    img = _g.last_image if "#" in sprite_file else get_image(sprite_file)
    _g.screen.blit(img, (_g.xpos, int(_g.ypos)))
    _g.last_image = img
    play_sound_effect(sound_file)


def build_menus():
    # Game selection menu
    _g.menu = pymenu.Menu(GRAPHICS[1], GRAPHICS[0], QUESTION, mouse_visible=False, mouse_enabled=False,
                          theme=dkafe_theme, onclose=close_menu)
    _g.menu.add_vertical_margin(5)
    for name, sub, desc, icx, icy, emu, state, unlock, _min, bonus in _s.read_romlist():
        _g.icons.append((int(icx), int(icy), name, sub, desc, emu, state, unlock, _min, bonus))
        _g.menu.add_button(desc, launch_rom, (sub, name, emu, state, unlock, _min, bonus))
    _g.menu.add_button('Close Menu', close_menu)

    # Exit menu
    _g.exitmenu = pymenu.Menu(70, 200, "Really want to leave ?", mouse_visible=False, mouse_enabled=False,
                              theme=dkafe_theme, onclose=close_menu)
    _g.exitmenu.add_button('Take me back', close_menu)
    _g.exitmenu.add_button('Exit', exit_program)


def open_menu(menu):
    reset_all_inputs()
    pygame.mouse.set_visible(False)
    pygame.mixer.pause()
    intermission_channel.play(pygame.mixer.Sound('sounds/menu.wav'), -1)
    menu.enable()
    menu.mainloop(_g.screen)


def close_menu():
    pygame.mouse.set_visible(False)
    intermission_channel.stop()
    _g.menu.disable()
    _g.exitmenu.disable()
    update_screen()
    _g.active = True
    _g.lastmove = _g.timer.duration


def launch_rom(info):
    if info:
        _g.menu.disable()
        intermission_channel.stop()
        music_channel.pause()
        shell_command, emu_directory, competing, hide_window = _s.build_shell_command(info)

        if int(FREE_PLAY) or _g.score >= PLAY_COST:
            _g.timer.stop()                                       # Stop timer while playing arcade
            _g.score = _g.score - (PLAY_COST, 0)[int(FREE_PLAY)]  # Deduct coins if not freeplay
            play_sound_effect("sounds/coin.wav")
            clear_screen()
            if "-record" in shell_command:
                flash_message("R E C O R D I N G", x=40, y=120)   # Gameplay recording (i.e. Wolfmame)
            if hide_window:
                _g.window.hide()                                  # Hide frontend window to give game focus id needed
            if emu_directory:
                os.chdir(emu_directory)
            os.system(shell_command)
            os.chdir(ROOT_DIR)
            if hide_window:
                _g.window.restore()                               # Restore focus to frontend
            if competing:
                # Check to see if Jumpman achieved minimum or bonus scores and award earned points
                pass
            reset_all_inputs()
            _g.timer.start()  # Restart the timer
        else:
            play_sound_effect("sounds/error.wav")
            flash_message("YOU DON'T HAVE ENOUGH COINS !!", x=4, y=120)

        clear_screen(and_reset_display=True)                      # Reset the screen
        music_channel.unpause()
        os.chdir(ROOT_DIR)
        _g.skip = True


def process_interrupts():
    ticks = pygame.time.get_ticks()

    # Start up messages from Pauline
    if not _g.lastmove:
        message = (COIN_INFO, FREE_INFO)[int(FREE_PLAY)]
        write_text(message[int(_g.timer.duration) % len(message)], x=108, y=37, fg=WHITE, bg=MAGENTA, bubble=True)

    # Flashing 1UP and score
    write_text("1UP", font=dk_font, x=25, y=0, fg=(BLACK, RED)[ticks % 500 < 250], bg=None)
    write_text(str(_g.score).zfill(6), font=dk_font, x=9, y=8, fg=WHITE, bg=BLACK)

    # Bonus timer
    previous_warning = _g.warning
    bonus_display, bonus_colour, _g.warning, out_of_time = _s.calculate_bonus(_g.timer.duration)
    if _g.warning:
        if not previous_warning:
            music_channel.play(pygame.mixer.Sound('sounds/countdown.wav'), -1)
        if out_of_time:
            music_channel.stop()
            play_sound_effect("sounds/timeup.wav")
            for repeat in range(0, 3):
                for i in range(0, 6):
                    if i <= 3 or repeat == 2:
                        display_icons(with_background=True)
                        _g.screen.blit(get_image(f"artwork/sprite/out{int(i)}.png"), (_g.xpos, int(_g.ypos)))

                        # Display items that don't get updated in this loop
                        write_text("1UP", font=dk_font, x=25, y=0, fg=RED, bg=None)
                        write_text(" 000", font=dk_font, x=177, y=48, fg=bonus_colour, bg=None)
                        _g.screen.blit(get_image("artwork/sprite/dk0.png"), (11, 52))
                        update_screen(delay_ms=110)
            pygame.time.delay(1500)

            # Reset timer and coins then restart the regular background music loop
            _g.timer.reset()
            _g.coins = []
            music_channel.play(pygame.mixer.Sound('sounds/background.wav'), -1)

    write_text(bonus_display, font=dk_font, x=177, y=48, fg=bonus_colour, bg=None)

    # animated DK,  sometimes DK will grab a coin
    prefix = ("dk", "dkg")[_g.grab]
    if _g.grab and _g.cointype == 0:
        # Determine next coin to be grabbed by DK. Higher value coins are released less frequenly
        _g.cointype = int(randint(1, 3) == 1) + 1

    for i, mod in enumerate((500, 1000, 1500)):
        if ticks % 5000 < mod:
            _g.screen.blit(get_image(f"artwork/sprite/{prefix}{str(i + 1)}.png"), (11, 52))
            if _g.grab:
                _g.screen.blit(get_image(f"artwork/sprite/coin{_g.cointype}3.png"), ((12, 38, 64)[i], 74))
            break

    # If DK grabbed a coin then it will start rolling
    if ticks % 5000 >= 1500:
        if ticks % 5000 < 2000:
            if _g.grab:
                _g.coins.append((67, 73, 2, 1, True, _g.cointype))  # x, y, sprite no, x direction, use Ladders, type
            _g.grab = False
            _g.cointype = 0
        if ticks % 5000 > 4500:
            _g.grab = randint(1, COIN_FREQUENCY) == 1
        _g.screen.blit(get_image(f"artwork/sprite/{prefix}0.png"), (11, 52))

    # Animate rolling coins
    for i, coin in enumerate(_g.coins):
        co_x, co_y, co_id, co_dir, co_ladder, co_type = coin
        _g.screen.blit(get_image(f"artwork/sprite/coin{str(co_type)}{str(int(co_id % 4))}.png"), (int(co_x), int(co_y)))

        if (co_x - SPRITE_HALF <= _g.xpos < co_x + SPRITE_HALF) and (co_y >= _g.ypos > co_y - SPRITE_HALF):
            _g.score += COIN_VALUES[co_type]  # Jumpman collected the coin
            play_sound_effect("sounds/getitem.wav")
            co_x = -999

        map_info = get_map_info(direction="d", x=int(co_x + (9, 4)[co_dir == 1]), y=int(co_y + 9))

        # Toggle ladders.  Virtual ladders are always active.
        if "APPROACHING_LADDER" in map_info:
            co_ladder = not randint(1, LADDER_CHANCE) == 1
        elif "VIRTUAL_LADDER" not in map_info and "FOOT_ABOVE_PLATFORM" not in map_info and co_ladder:
            map_info = []

        # Move the coin along the platform and down ladders
        if "FOOT_ABOVE_PLATFORM" in map_info:
            co_y += 1  # coin moves down the sloped girder to touch the platform
        elif "ANY_LADDER" in map_info:
            if "TOP_OF_ANY_LADDER" in map_info:
                co_dir *= -1  # Flip horizontal movement
            co_y += COIN_SPEED
        else:
            co_x += co_dir * COIN_SPEED  # Increment horizontal movement
        co_id += co_dir * COIN_CYCLE
        _g.coins[i] = co_x, co_y, co_id, co_dir, co_ladder, co_type  # Update coin data

    # Purge coins
    _g.coins = [i for i in _g.coins if i[0] > -10]


def inactivity_check():
    if _g.timer.duration - _g.lastmove > INACTIVE_TIME:
        pause_mod = (pygame.time.get_ticks() - _g.pause_ticks) % 21000
        if pause_mod < 3000:
            _g.screen.blit(get_image(f"artwork/intro/f{randint(0,1)}.png"), TOPLEFT)
        else:
            lines = (INSTRUCTION, CONTROLS)[pause_mod > 12000]
            for i, line in enumerate(lines.split("\n")):
                write_text(line+(" "*28), x=0, y=i * 8 + 20, fg=CYAN, bg=BLACK, font=dk_font)
        write_text("1UP", font=dk_font, x=25, y=0, fg=(BLACK, RED)[pygame.time.get_ticks() % 700 < 350], bg=None)
        write_text(str(_g.score).zfill(6), font=dk_font, x=9, y=8, fg=WHITE, bg=BLACK)
        if _g.active:
            _g.timer.stop()
            _g.pause_ticks = pygame.time.get_ticks()
            pygame.mixer.pause()
        _g.active = False


def activity_check():
    if _g.active:
        _g.timer.start()
        pygame.mixer.unpause()
        process_interrupts()


def main():
    initialise_screen()
    _g.window = pygetwindow.getWindowsWithTitle(TITLE)[0]

    # launch front end
    build_menus()
    play_intro_animation()
    music_channel.play(pygame.mixer.Sound('sounds/background.wav'), -1)

    # Initialise Jumpman
    animate_jumpman("r", horizontal_movement=0)
    _g.lastmove = 0
    _g.timer.reset()

    # loop the game
    while True:
        if _g.active:
            display_icons(with_background=True)

        if _g.jump_sequence:
            animate_jumpman(["l", "r"][_g.facing], midjump=True)
        else:
            check_for_input()
            for keypress, direction in (_g.right, "r"), (_g.left, "l"), (_g.up, "u"), (_g.down, "d"), (True, ""):
                if keypress:
                    animate_jumpman(direction)
                    break

        if (_g.jump or _g.start) and _g.ready:
            launch_rom(display_icons(detect_only=True))
        elif (_g.jump or _g.jump_sequence) and _g.timer.duration > 0.2:
            # Jumpman has started a jump or is actively jumping
            ladder_info = get_map_info(direction="d") + get_map_info(direction="u")
            if _g.jump_sequence or "LADDER_DETECTED" not in ladder_info or "END_OF_LADDER" in ladder_info:
                _g.jump_sequence += 1
                if _g.jump_sequence >= len(JUMP_PIXELS):
                    _g.jump, _g.jump_sequence, _g.sprite_index = False, 0, 0
                    adjust_jumpman()
                    animate_jumpman(("l", "r")[_g.facing], horizontal_movement=0)

        activity_check()
        inactivity_check()
        update_screen()


if __name__ == "__main__":
    main()
