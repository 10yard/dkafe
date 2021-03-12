# Donkey Kong Arcade Frontend (DKAFE) by Jon Wilson
import sys
import dk_system as _s
import dk_global as _g
from dk_config import *
from dk_interface import get_award, format_K
from dk_patch import apply_patches
from random import randint
import pickle


def exit_program(confirm=False):
    # Exit and prompt for confirmation if required.  Exit is temporarily disabled after returning from an emulator.
    if _g.lastexit == 0 or since_last_exit() > 0.25:
        if confirm:
            open_menu(_g.exitmenu)
        else:
            # Save frontend state and exit
            _g.timer_adjust = _g.timer.duration + _g.timer_adjust - 4
            pickle.dump([_g.score, _g.timer_adjust], open("save.p", "wb"))
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


def update_screen(delay_ms=0):
    pygame.display.update()
    pygame.time.delay(delay_ms)
    clock.tick(CLOCK_RATE)


def load_frontend_state():
    try:
        _g.score, _g.timer_adjust = pickle.load(open("save.p", "rb"))
    except FileNotFoundError:
        _g.score, _g.timer_adjust = SCORE_START, 0


def check_patches_available():
    applied_patches = apply_patches()
    if applied_patches:
        clear_screen()
        x_offset, y_offset = 8, 24
        write_text(f"APPLYING PATCH FILES...", font=dk_font, x=8, y=8, fg=RED)
        for i, patch in enumerate(applied_patches):
            write_text(patch, font=dk_font, x=x_offset, y=y_offset, fg=WHITE)
            update_screen(delay_ms=20)
            y_offset += 9
            if y_offset > 220:
                x_offset, y_offset = 128, 24
        flash_message("ALL GOOD!", x=8, y=232, clear=False, cycles=4)
        jump_to_continue()


def check_roms_available():
    # Check roms are provided in the configured rom folder and warn if necessary
    if not _s.glob(os.path.join(ROM_DIR, "*.zip")):
        clear_screen()
        for i, line in enumerate(NO_ROMS_MESSAGE):
            write_text(line, font=dk_font, x=4, y=8+(i*12), fg=[WHITE, RED][i == 0])
            update_screen(delay_ms=80)
        jump_to_continue()


def jump_to_continue():
    # Show Jump to continue message at foot of screen and wait for button press
    flash_message("PRESS JUMP TO CONTINUE", x=8, y=242, clear=False, cycles=8)
    while True:
        check_for_input(force_exit=True)
        if _g.jump or _g.start:
            break


def write_text(text=None, font=pl_font, x=0, y=0, fg=WHITE, bg=None, bubble=False, box=False, rj_adjust=0):
    # Write text to screen at given position using fg and bg colour (None for transparent)
    if text:
        img = font.render(text, False, fg, bg)
        w, h = img.get_width(), img.get_height()
        _x = x - w + rj_adjust if rj_adjust else x
        _g.screen.blit(img, (_x, y))
        if box or bubble:
            pygame.draw.line(_g.screen, bg, (_x - 1, y - 1), (_x + w, y - 1))
            pygame.draw.rect(_g.screen, fg, (_x - 2, y - 2, w + 3, h + 3), 1)
            pygame.draw.line(_g.screen, bg, (_x - 1, y), (_x - 1, y + 5))
            if bubble:
                for point in ((_x - 2, y - 2), (_x + w, y - 2), (_x - 2, y + h), (_x + w, y + h)):
                    _g.screen.set_at(point, BLACK)
                pygame.draw.polygon(_g.screen, bg, [(_x - 2, y + 2), (_x - 6, y + 3), (_x - 2, y + 4)])
                pygame.draw.lines(_g.screen, fg, False, [(_x - 2, y + 2), (_x - 6, y + 3), (_x - 2, y + 4)], 1)


def flash_message(message, x, y, clear=True, bright=False, cycles=6, delay_ms=40):
    if clear:
        clear_screen()
    for i in (0, 1, 2) * cycles:
        write_text(message, font=dk_font, x=x, y=y, fg=(BROWN, PINK, RED, BROWN, WHITE, CYAN)[i + (bright * 3)])
        update_screen(delay_ms=delay_ms)
    if clear:
        clear_screen()


def get_image(image_key, fade=False):
    # Load image or read prevously loaded image from the dictionary/cache
    _key = image_key + str(fade)
    if _key not in _g.image_cache:
        _g.image_cache[_key] = pygame.image.load(image_key).convert_alpha()
        if fade:
            _g.image_cache[_key].set_alpha(FADE_LEVEL)
    return _g.image_cache[_key]


def read_map(x, y):
    # Return R colour value from pixel at provided x, y position on the screen map
    try:
        return _g.screen_map.get_at((int(x), int(y)))[0]
    except IndexError:
        return 254


def get_map_info(direction=None, x=0, y=0, platforms_only=False):
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
        if read_map(_x, _y + 1) in [0, 90] or (platforms_only and read_map(_x, _y + 1) in [20, 100]):
            map_info.append("FOOT_ABOVE_PLATFORM")

        # ladder detection based on direction of travel
        _r = read_map(_x - 1, _y + (direction == "d"))
        for zone_name, zone_values in LADDER_ZONES:
            if _r in zone_values:
                map_info.append(zone_name)
    except IndexError:
        map_info.append("ERROR_READING_SCREEN_MAP")
    return map_info


def take_screenshot():
    if _g.active:
        animate_jumpman()
        activity_check()
    update_screen()
    pygame.image.save(_g.screen, f"artwork/snap/dkafe_{_s.get_datetime()}.png")


def reset_all_inputs():
    # Push KEYUP events which can be lost after calling external programs
    _s.debounce()
    for attr, control in CONTROL_ASSIGNMENTS:
        event = pygame.event.Event(pygame.KEYUP, {'key': control})
        pygame.event.post(event)


def detect_joysticks():
    for i in range(0, pygame.joystick.get_count()):
        _g.joysticks.append(pygame.joystick.Joystick(i))
        _g.joysticks[-1].init()


def check_for_input(force_exit=False):
    for event in pygame.event.get():
        # Keyboard controls
        if event.type in (pygame.KEYDOWN, pygame.KEYUP) and event.key != CONTROL_SNAP:
            _g.active = True
            _g.lastmove = _g.timer.duration
            for attr, control in CONTROL_ASSIGNMENTS:
                if event.key == control:
                    setattr(_g, attr, event.type == pygame.KEYDOWN)
        if event.type == pygame.KEYDOWN:
            if event.key == CONTROL_EXIT:
                exit_program(confirm=CONFIRM_EXIT and not force_exit)
            if event.key == CONTROL_P2 and ENABLE_MENU:
                build_menus(initial=False)
                open_menu(_g.menu)
            if event.key == CONTROL_COIN:
                _g.showinfo = not _g.showinfo
            if event.key == CONTROL_ACTION:
                _g.showslots = not _g.showslots
            if event.key == CONTROL_SNAP:
                take_screenshot()

        # Optional joystick controls
        if USE_JOYSTICK and event.type == pygame.JOYAXISMOTION:
            _g.active = True
            _g.lastmove = _g.timer.duration
            _g.left = event.axis == 0 and int(event.value) == -1
            _g.right = event.axis == 0 and int(event.value) == 1
            _g.up = event.axis == 1 and int(event.value) == -1
            _g.down = event.axis == 1 and int(event.value) == 1
        if USE_JOYSTICK and event.type == pygame.JOYBUTTONDOWN:
            button = event.button if event.joy == 1 else event.button + 20
            _g.jump = button == BUTTON_JUMP
            _g.start = button == BUTTON_P1
            if button == BUTTON_EXIT:
                exit_program(confirm=CONFIRM_EXIT and not force_exit)
            if button == BUTTON_P2 and ENABLE_MENU:
                build_menus(initial=False)
                open_menu(_g.menu)
            if button == BUTTON_COIN:
                _g.showinfo = not _g.showinfo
            if button == BUTTON_ACTION:
                _g.showslots = not _g.showslots

        if event.type == pygame.QUIT:
            exit_program()


# noinspection PyArgumentList
def play_sound_effect(effect=None, stop=False):
    if stop:
        pygame.mixer.stop()
    if effect:
        pygame.mixer.Sound.play(pygame.mixer.Sound(effect))


def play_intro_animation():
    play_sound_effect(effect="sounds/jump.wav")

    # Preload images
    for _key in _s.intro_frames(climb_scene_only=True):
        get_image(_key)

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
                    display_slots()
                else:
                    display_slots(version_only=True)

            # Title and messages
            write_text(("", QUESTION)[855 < current < 1010], font=dk_font, x=12, y=240, fg=WHITE, bg=BLACK)
            write_text(" DK ARCADE ", font=dk_font, x=69, y=0, fg=RED, bg=BLACK)
            write_text(" FRONT END ", font=dk_font, x=69, y=8, fg=WHITE, bg=BLACK)

        show_score()
        update_screen(delay_ms=40)


def display_slots(version_only=False):
    if _g.showslots:
        if not version_only:
            for i, slot in enumerate(SLOTS):
                _g.screen.blit(get_image("artwork/icon/slot.png", fade=True), SLOTS[i])
                write_text("  ", pl_font, SLOTS[i][0] + 1, SLOTS[i][1] + 1, bg=BLACK)
                write_text(str(i + 1).zfill(2), pl_font, SLOTS[i][0] + 2, SLOTS[i][1] + 2, bg=BLACK, fg=WHITE)
        write_text(text="VERSION", font=dk_font, x=224, y=0, fg=RED, bg=BLACK, rj_adjust=True)
        write_text(text=VERSION, font=dk_font, x=224, y=8, fg=WHITE, bg=BLACK, rj_adjust=True)


def display_icons(detect_only=False, with_background=False, below_y=None, above_y=None, intro=False, smash=False):
    if with_background:
        _g.screen.blit(get_image("artwork/background.png"), TOPLEFT)
        show_hammers()
        show_score()

    nearby = None
    info_list = []
    # Display icons and return icon that is near to Jumpman
    for _x, _y, name, sub, des, alt, emu, unlock, score3, score2, score1 in _g.icons:
        unlocked = True
        if _g.score < unlock and UNLOCK_MODE and not intro:
            unlocked = False
        if not below_y or not above_y or (below_y >= _y >= above_y):
            icon_image = os.path.join("artwork/icon", sub, name + ".png")
            if smash:
                icon_image = f"artwork/sprite/smash{str(randint(0,3))}.png"
            if not os.path.exists(icon_image):
                icon_image = os.path.join("artwork/icon/default.png")
            img = get_image(icon_image, fade=not unlocked)
            w, h = img.get_width(), img.get_height()
            if _x < _g.xpos + SPRITE_HALF < _x + w and (_y < _g.ypos + SPRITE_HALF < _y + h):
                # Pauline to announce the game found near Jumpman.  Return the game icon information.
                if not unlocked and since_last_move() % 4 > 2:
                    des = f"Unlock at {unlock}"
                elif unlocked and score3 and score2 and score1:
                    if since_last_move() % 5 > 4:
                        des = f'1st Prize {format_K(score1)}'
                    elif since_last_move() % 5 > 3:
                        des = f'2nd Prize {format_K(score2)}'
                    elif since_last_move() % 5 > 2:
                        des = f'3rd Prize {format_K(score3)}'
                elif '-record' in _s.get_emulator(emu) and since_last_move() % 4 > 2:
                    des = 'FOR RECORDING!'
                elif not score3.strip() and since_last_move() % 4 > 2:
                    des = 'FOR PRACTICE!'
                elif not int(FREE_PLAY) and since_last_move() % 4 > 2:
                    des = f'${str(PLAY_COST)} TO PLAY'
                write_text(des.upper(), x=108, y=37, fg=WHITE, bg=MAGENTA, bubble=True)
                if unlocked:
                    nearby = (sub, name, emu, unlock, score3, score2, score1)
            if not detect_only:
                _g.screen.blit(img, (_x, _y))
                if "-record" in _s.get_emulator(emu) and not _g.showinfo:
                    # Show recording text above icon
                    write_text("REC", x=_x, y=_y - 6, fg=(BLACK, RED)[_g.timer.duration % 2 < 1], bg=None)
            if _g.showinfo:
                info_list.append((des, _x, _y, w, unlocked))
    if _g.showinfo:
        # Show game info above icons.  Done as last step so that icons do not overwrite the text.
        for des, x, y, w, unlocked in [info_list, reversed(info_list)][_g.timer.duration % 4 < 2]:
            write_text(des, x=x, y=y - 6, fg=[BLACK, MAGENTA][unlocked], bg=[GREY, WHITE][unlocked], box=True,
                       rj_adjust=(not (len(des) * 4) + x <= 224) * w)
    return nearby


def adjust_jumpman():
    # Adjust Jumpman's vertical position with the sloping platform
    for i in range(0, 10):
        map_info = get_map_info(platforms_only=True)
        if "FOOT_UNDER_PLATFORM" in map_info or "TOP_OF_ANY_LADDER" in map_info:
            _g.ypos += -1
        elif "FOOT_ABOVE_PLATFORM" in map_info and "TOP_OF_ANY_LADDER" not in map_info:
            _g.ypos += +1
        else:
            break


def animate_jumpman(direction=None, horizontal_movement=1, midjump=False):
    sprite_file = f"artwork/sprite/jm{direction}#.png"
    sound_file = None
    map_info = get_map_info(direction)

    if midjump:
        sprite_file = f"artwork/sprite/jmj{direction}.png"
        sprite_file = sprite_file.replace("#", "1")
        if _g.jump_sequence == 8:
            sound_file = "sounds/jump.wav"
        # Jumpman is jumping.  Check for landing platform and blocks
        if "BLOCKED_LEFT" in map_info or "BLOCKED_RIGHT" in map_info and _g.wall_bounce == 1:
            if _g.left or _g.right:
                # Wall bounce
                _g.wall_bounce = -1
                _g.facing = int(not _g.facing)
                # Allow full jump if started near to wall.  Don't keep ascending after bounce.
                if 3 < _g.jump_sequence <= len(JUMP_PIXELS) / 2:
                    _g.jump_sequence = len(JUMP_PIXELS) - _g.jump_sequence + 1
        _g.xpos += ((_g.right + (_g.left * -1)) * _g.wall_bounce) / JUMP_SHORTEN
        if "FOOT_UNDER_PLATFORM" not in get_map_info(direction) or JUMP_PIXELS[_g.jump_sequence] < 0:
            if "FOOT_ABOVE_PLATFORM" not in get_map_info(direction) or _g.jump_sequence < len(JUMP_PIXELS) - 3:
                _g.ypos += JUMP_PIXELS[_g.jump_sequence]
            else:
                sprite_file = f"artwork/sprite/jm{direction}0.png"

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


def build_menus(initial=False):
    # Game selection menu
    _g.menu = pymenu.Menu(GRAPHICS[1], GRAPHICS[0], QUESTION, mouse_visible=False, mouse_enabled=False,
                          theme=dkafe_theme, onclose=close_menu)
    _g.menu.add_vertical_margin(5)
    for name, sub, desc, alt, icx, icy, emu, unlock, score3, score2, score1 in _s.read_romlist():
        if _g.score >= unlock or not UNLOCK_MODE:
            _g.menu.add_button(alt, launch_rom, (sub, name, emu, unlock, score3, score2, score1))
        if initial and int(icx) >= 0 and int(icy) >= 0:
            _g.icons.append((int(icx), int(icy), name, sub, desc, alt, emu, unlock, score3, score2, score1))

    _g.menu.add_button('Close Menu', close_menu)

    # Exit menu
    _g.exitmenu = pymenu.Menu(70, 200, "Really want to leave ?", mouse_visible=False, mouse_enabled=False,
                              theme=dkafe_theme, onclose=close_menu)
    _g.exitmenu.add_button('Take me back', close_menu)
    _g.exitmenu.add_button('Exit', exit_program)
    if _s.is_raspberry():
        _g.exitmenu.add_button('Shutdown', shutdown_rpi)


def open_menu(menu):
    _g.timer.stop()
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
    _g.timer.start()
    _g.lastmove = _g.timer.duration


def shutdown_rpi():
    os.system("shutdown -h now")


def launch_rom(info):
    if info:
        sub, name, emu, unlock, score3, score2, score1 = info

        _g.timer.stop()  # Stop timer while playing arcade
        _g.menu.disable()
        intermission_channel.stop()
        music_channel.pause()
        launch_command, launch_directory, competing = _s.build_launch_command(info)

        if FREE_PLAY or _g.score >= PLAY_COST:
            _g.score = _g.score - (PLAY_COST, 0)[int(FREE_PLAY)]  # Deduct coins if not freeplay
            play_sound_effect("sounds/coin.wav")
            clear_screen()
            if competing and (not name.startswith("dkong") or sub == 'dkongtj'):
                # Flash message showing awards before game starts. Most dkong roms have the message displayed in game.
                write_text(f"PLAY TO WIN COINS", font=dk_font, x=8, y=4, fg=RED)
                update_screen(delay_ms=500)
                for i, s in enumerate((score3, score2, score1)):
                    write_text(f"BEAT {format_K(s)} FOR {AWARDS[i]} COINS", font=dk_font, x=8, y=40 + (i*24), fg=WHITE)
                    update_screen(delay_ms=500)
                flash_message("GO FOR IT!", x=8, y=232, clear=False, cycles=4)
                jump_to_continue()
            elif "-record" in launch_command:
                flash_message("R E C O R D I N G", x=40, y=120)   # Gameplay recording (i.e. Wolfmame)

            reset_all_inputs()
            if os.path.exists(launch_directory):
                os.chdir(launch_directory)
            clear_screen()
            if _s.is_raspberry() and EMU_EXIT_RPI:
                os.system(EMU_ENTER_RPI)
            os.system(launch_command)
            _g.lastexit = _g.timer.duration
            os.chdir(ROOT_DIR)

            if competing:
                # Check to see if Jumpman achieved 1st, 2nd or 3rd score target to earn coins
                scored = get_award(name, score3, score2, score1)
                if scored > 0:
                    _g.awarded = True
                    for i, coin in enumerate(range(0, scored, COIN_VALUES[-1])):
                        drop_coin(x=0, y=i * 2, coin_type=len(COIN_VALUES) - 1, awarded=True)
                    _g.timer.reset()
                    award_channel.play(pygame.mixer.Sound("sounds/win.wav"))
            clear_screen(and_reset_display=True)
        else:
            play_sound_effect("sounds/error.wav")
            flash_message("YOU DON'T HAVE ENOUGH COINS !!", x=4, y=120)

        _g.skip = True
        _g.timer.start()  # Restart the timer


def show_hammers():
    if ENABLE_HAMMERS:
        for position in [(16, 98), (167, 190)]:
            _g.screen.blit(get_image(f"artwork/sprite/hammer.png"), position)


def show_score():
    # Flashing 1UP and score
    write_text("1UP", font=dk_font, x=25, y=0, fg=(BLACK, RED)[pygame.time.get_ticks() % 550 < 275], bg=None)
    write_text(str(_g.score).zfill(6), font=dk_font, x=9, y=8, fg=WHITE, bg=BLACK)


def drop_coin(x=67, y=73, rotate=2, movement=1, use_ladders=True, coin_type=1, awarded=False):
    # Drop a coin at x, y location, rotate sprite no, movement direction, use ladders?, coin type id, coin was awarded?
    _g.coins.append((x, y, rotate, movement, use_ladders, coin_type, awarded))


def show_timeup_animation(sprite_number, loss=0):
    # Show coins during the out of time animation
    display_icons(with_background=True)
    display_slots()
    _g.screen.blit(get_image(f"artwork/sprite/out{sprite_number}.png"), (_g.xpos, int(_g.ypos)))

    # Display items that don't get updated in this loop
    show_score()
    write_text(" 000", font=dk_font, x=177, y=48, fg=MAGENTA, bg=None)
    _g.screen.blit(get_image("artwork/sprite/dk0.png"), (11, 52))

    if loss > 0:
        write_text(f"-{str(loss)}", x=_g.xpos, y=_g.ypos - 10, fg=WHITE, bg=RED, box=True)

    animate_rolling_coins(out_of_time=True)
    update_screen(delay_ms=22)


def process_interrupts():
    ticks = pygame.time.get_ticks()

    # Start up messages from Pauline
    if not _g.lastmove:
        message = (COIN_INFO, FREE_INFO)[int(FREE_PLAY)]
        write_text(message[int(_g.timer.duration) % len(message)], x=108, y=37, fg=WHITE, bg=MAGENTA, bubble=True)
    show_score()

    # Bonus timer
    previous_warning = _g.warning
    bonus_display, bonus_colour, _g.warning, out_of_time = _s.calculate_bonus(_g.timer.duration + _g.timer_adjust)
    if _g.warning:
        if not previous_warning:
            music_channel.play(pygame.mixer.Sound('sounds/countdown.wav'), -1)
        if out_of_time:
            # Jumpman drops coins if he can afford it.
            loss, i = 0, 0
            for coin_type in [2, 1]:
                for coin in range(loss, LIFE_COST, COIN_VALUES[coin_type]):
                    if _g.score >= COIN_VALUES[coin_type] and loss + COIN_VALUES[coin_type] <= LIFE_COST:
                        loss += COIN_VALUES[coin_type]
                        _g.score -= COIN_VALUES[coin_type]
                        movement = 1 if _g.ypos <= 73 or (139 >= _g.ypos > 106) or (205 >= _g.ypos > 172) else -1
                        drop_coin(x=_g.xpos, y=_g.ypos + i, coin_type=coin_type, movement=movement)
                        i += 1

            # Show time up animation
            music_channel.stop()
            play_sound_effect("sounds/timeup.wav")
            for repeat in range(0, 3):
                for i in range(0, 6):
                    if i <= 3 or repeat == 2:
                        for coin_update in range(0, 5):
                            show_timeup_animation(sprite_number=int(i), loss=loss)
            # Delay for 1500ms while Jumpman is dazed.  Ensure rolling coins continue to update
            for coin_update in range(0, 75):
                show_timeup_animation(sprite_number=5, loss=loss)

            # Reset timer and music
            _g.timer.reset()
            _g.timer_adjust = 0
            music_channel.play(pygame.mixer.Sound('sounds/background.wav'), -1)

    write_text(bonus_display, font=dk_font, x=177, y=48, fg=bonus_colour, bg=None)

    # animated DK,  sometimes DK will grab a coin
    prefix = ("dk", "dkg")[_g.grab]
    if _g.grab and _g.cointype == 0:
        # Determine next coin to be grabbed by DK. Higher value coins are released less frequenly
        _g.cointype = int(randint(1, COIN_HIGH) == 1) + 1

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
                drop_coin(coin_type=_g.cointype)
            _g.grab = False
            _g.cointype = 0
        if ticks % 5000 > 4500:
            _g.grab = randint(1, COIN_FREQUENCY) == 1
        _g.screen.blit(get_image(f"artwork/sprite/{prefix}0.png"), (11, 52))

    # Animate rolling coins
    animate_rolling_coins()

    # Purge coins
    _g.coins = [i for i in _g.coins if i[0] > -10]


def animate_rolling_coins(out_of_time=False):
    _g.awarded = False
    for i, coin in enumerate(_g.coins):
        co_x, co_y, co_rot, co_dir, co_ladder, co_type, co_awarded = coin
        if co_awarded:
            _g.awarded = True
        _g.screen.blit(get_image(f"artwork/sprite/coin{str(co_type)}{str(int(co_rot % 4))}.png"), (int(co_x), int(co_y)))

        if (co_x - SPRITE_HALF <= _g.xpos < co_x + SPRITE_HALF) and (co_y >= _g.ypos > co_y - SPRITE_HALF):
            if not out_of_time and _g.timer.duration > 0.2:  # Jumpman cannot collect coins immediately after start/out of time
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
        co_rot += co_dir * COIN_CYCLE
        _g.coins[i] = co_x, co_y, co_rot, co_dir, co_ladder, co_type, co_awarded  # Update coin data


def inactivity_check():
    if _g.timer.duration - _g.lastmove > INACTIVE_TIME:
        pause_mod = (pygame.time.get_ticks() - _g.pause_ticks) % 21000
        if pause_mod < 3000:
            _g.screen.blit(get_image(f"artwork/intro/f{randint(0,1)}.png"), TOPLEFT)
        else:
            lines = (INSTRUCTION, CONTROLS)[pause_mod > 12000]
            for i, line in enumerate(lines.split("\n")):
                write_text(line+(" "*28), x=0, y=i * 8 + 20, fg=CYAN, bg=BLACK, font=dk_font)
        show_score()
        if _g.active:
            _g.timer.stop()
            _g.pause_ticks = pygame.time.get_ticks()
            pygame.mixer.pause()
        _g.active = False


def since_last_move():
    return _g.timer.duration - _g.lastmove


def since_last_exit():
    return _g.timer.duration - _g.lastexit


def activity_check():
    if _g.active:
        _g.timer.start()
        if not _g.awarded:
            award_channel.stop()
            pygame.mixer.unpause()
        process_interrupts()

        if _g.lastexit > 0 and since_last_exit() < 0.2:
            if _s.is_raspberry() and EMU_EXIT_RPI:
                os.system(EMU_EXIT_RPI)


def teleport_between_hammers():
    if ENABLE_HAMMERS:
        if pygame.time.get_ticks() - _g.teleport_ticks > 700:
            if 160 <= _g.xpos <= 172 and 188 <= _g.ypos <= 195:
                _g.xpos = 14
                _g.ypos = 91 - (190 - _g.ypos)
                _g.teleport_ticks = pygame.time.get_ticks()
            elif 10 <= _g.xpos <= 22 and 91 <= _g.ypos <= 100:
                _g.xpos = 165
                _g.ypos = 188 - (92 - _g.ypos)
                _g.teleport_ticks = pygame.time.get_ticks()
        if pygame.time.get_ticks() - _g.teleport_ticks < 1000:
            write_text("TELEPORT JUMP!", x=108, y=37, fg=WHITE, bg=MAGENTA, bubble=True)


def main():
    # Prepare front end
    _g.active = False
    initialise_screen()
    load_frontend_state()
    detect_joysticks()
    check_patches_available()
    build_menus(initial=True)

    # Launch front end
    check_roms_available()
    play_intro_animation()
    music_channel.play(pygame.mixer.Sound('sounds/background.wav'), -1)

    # Initialise Jumpman
    _s.debounce()
    animate_jumpman("r", horizontal_movement=0)
    # pygame.time.delay(150)
    _g.lastmove = 0
    _g.timer.reset()
    _g.active = True

    # Main game loop
    while True:
        if _g.active:
            display_icons(with_background=True)
            display_slots()
        if _g.jump_sequence:
            animate_jumpman(["l", "r"][_g.facing], midjump=True)
        else:
            check_for_input()
            for keypress, direction in (_g.right, "r"), (_g.left, "l"), (_g.up, "u"), (_g.down, "d"), (True, ""):
                if keypress:
                    animate_jumpman(direction)
                    break

        if _g.jump and _s.get_bonus_timer(_g.timer.duration + _g.timer_adjust) <= -165:
            # Block jump button when almost out of time
            _g.jump = False
        elif (_g.jump or _g.start) and _g.ready:
            # Launch a game
            launch_rom(display_icons(detect_only=True))
        elif (_g.jump or _g.jump_sequence) and _g.timer.duration > 0.5:
            # Jumpman has started a jump or is actively jumping
            teleport_between_hammers()
            ladder_info = get_map_info(direction="d") + get_map_info(direction="u")
            if _g.jump_sequence or "LADDER_DETECTED" not in ladder_info or "END_OF_LADDER" in ladder_info:
                _g.jump_sequence += 1
                if _g.jump_sequence >= len(JUMP_PIXELS):
                    _g.jump, _g.jump_sequence, _g.sprite_index, _g.wall_bounce = False, 0, 0, 1
                    adjust_jumpman()
                    animate_jumpman(("l", "r")[_g.facing], horizontal_movement=0)

        activity_check()
        inactivity_check()
        update_screen()


if __name__ == "__main__":
    main()
