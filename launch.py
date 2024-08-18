"""
ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
 888    88o  888  o88        888       888          888
 888    888  888888         8  88      888ooo8      888ooo8
 888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
                                        by Jon Wilson (10yard)

Main program
------------
"""
import os
import sys
sys.path.append("c:\\dkafe")

os.environ['PYGAME_HIDE_SUPPORT_PROMPT'] = '1'
import pygame.cursors
import pickle
from math import floor, ceil
from random import randint, choice, sample
from subprocess import call, run, Popen, CREATE_NO_WINDOW
import dk_global as _g
import dk_system as _s
from dk_config import *
from dk_interface import get_award, format_K
from dk_patch import apply_patches_and_addons, validate_rom


def exit_program(confirm=False):
    """Exit and prompt for confirmation if required."""
    if since_last_exit() <= 0 or since_last_exit() > 0.5:
        if confirm:
            open_menu(_g.exitmenu)
        else:
            # Save frontend state and exit
            _g.timer_adjust = _g.timer.duration + _g.timer_adjust - 2
            for attempt in 1, 2, 3:
                try:
                    with open('save.p', 'wb') as f:
                        pickle.dump([_g.score, _g.timer_adjust, _g.last_selected, _g.achievements], f)
                    break
                except (EOFError, FileNotFoundError, IOError):
                    pygame.time.delay(250 * attempt)
            rotate_display(exiting=True)
            if ARCH == "win64":
                kill_pc_external(program="remap_pc.exe")  # ensure keyboard remaps are ended
            if EMU_EXIT:
                # system command to issue prior to exit
                os.system(EMU_EXIT)

            pygame.quit()
            sys.exit()


def kill_pc_external(pid=None, program=None):
    from subprocess import call, DEVNULL, STDOUT, CREATE_NO_WINDOW
    if pid:
        call(f"taskkill /f /PID {pid}", stdout=DEVNULL, stderr=STDOUT, creationflags=CREATE_NO_WINDOW)
    elif program:
        call(f"taskkill /f /IM {os.path.basename(program)}", stdout=DEVNULL, stderr=STDOUT, creationflags=CREATE_NO_WINDOW)


def rotate_display(exiting=False, initial=False, rotate=ROTATION):
    # Windows only display rotation
    if _s.get_system() == "win":
        windows_version = sys.getwindowsversion()
        if windows_version[0] > 5:
            import rotatescreen
            # noinspection PyBroadException
            try:
                primary = rotatescreen.get_primary_display()
                if primary:
                    if initial:
                        # Remember the default orientation from startup
                        _g.initial_rotation = primary.current_orientation
                    _rotate = _g.initial_rotation if exiting else rotate
                    if _rotate in [0, 90, 180, 270]:
                        primary.rotate_to(_rotate)
            except Exception:
                pass

def initialise_screen(reset=False):
    try:
        _g.screen = pygame.display.set_mode(DISPLAY, pygame.FULLSCREEN * int(FULLSCREEN) | pygame.SCALED | pygame.WINDOWFOCUSGAINED)
    except AttributeError:
        # Target doesn't support WINDOWFOCUSGAINED
        _g.screen = pygame.display.set_mode(DISPLAY, pygame.FULLSCREEN * int(FULLSCREEN) | pygame.SCALED)
    pygame.event.set_grab(FULLSCREEN == 1)
    pygame.mouse.set_visible(False)

    # Hack to force hide of the mouse cursor in the menus by making cursor transparent
    try:
        cursor_img = pygame.image.load('artwork/transparent.png').convert_alpha()
        cursor = pygame.cursors.Cursor((9, 0), cursor_img)
        pygame.mouse.set_cursor(cursor)
    except AttributeError:
        # Target doesn't support a custom Cursor
        pass

    if not reset:
        _g.screen_map = _g.screen.copy()
        _g.screen_map.blit(get_image(f"artwork/map{_g.stage}.png"), TOPLEFT)
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
    clock.tick(CLOCK_RATE + (SPEED_ADJUST * 5))


def load_frontend_state():
    try:
        with open('save.p', "rb") as f:
            _g.score, _g.timer_adjust, _g.last_selected, _g.achievements = pickle.load(f)
    except (EOFError, FileNotFoundError, IOError, ValueError):
        _g.score, _g.timer_adjust, _g.last_selected, _g.achievements = SCORE_START, 0, None, {}


def check_patches_available():
    if validate_rom():
        applied_patches, installed_addons = apply_patches_and_addons()
        if applied_patches:
            clear_screen()
            x_offset, y_offset = 0, 11
            write_text(f"APPLYING {str(len(applied_patches))} ARCADE PATCHES", font=dk_font, y=0, fg=RED)
            for i, patch in enumerate(applied_patches):
                write_text(patch.upper().replace("_","-"), font=pl_font7, x=x_offset, y=y_offset)
                update_screen(delay_ms=20)
                y_offset += 7
                if y_offset > 232:
                    x_offset += 75
                    y_offset = 11
        if installed_addons:
            if not applied_patches:
                # Do we need a heading?
                clear_screen()
                write_text(f"INSTALLING ADD-ONS...       ", font=dk_font, y=0, fg=RED)
            _, _count = _s.read_romlist("romlist_addon.csv")
            write_text(f"+ {str(_count)} DK VARIANTS WERE INSTALLED WITH THE ADD-ON PACK", font=pl_font, x=0, y=239, fg=PINK)
        if applied_patches or installed_addons:
            jump_to_continue(0)
    else:
        for i, line in enumerate(INVALID_ROM_MESSAGE + ROM_CONTENTS):
            write_text(line, font=dk_font, x=8, y=17 + (i * 9), fg=[WHITE, RED][i == 0])
        jump_to_continue()


def check_roms_available():
    """Check roms are provided in the configured rom folder and warn if necessary."""
    if not _s.glob(os.path.join(ROM_DIR, "*.zip")):
        clear_screen()
        for i, line in enumerate(NO_ROMS_MESSAGE):
            write_text(line, font=dk_font, x=4, y=0 + (i * 12), fg=[WHITE, RED][i == 0])
            update_screen(delay_ms=80)
        jump_to_continue()


def jump_to_continue(xpos=8):
    """Show Jump to continue message at foot of screen and wait for button press."""
    flash_message("PUSH JUMP TO CONTINUE", x=xpos, y=249, cycles=8, clear=False)
    while True:
        check_for_input(force_exit=True, continue_only=True)
        if _g.jump or _g.start:
            # Reset inputs
            _g.jump, _g.start = False, False
            break


def write_text(text=None, font=pl_font, x=0, y=0, fg=WHITE, bg=None, bubble=False, box=False, rj_adjust=0):
    """Write text to screen at given position using fg and bg colour (None for transparent)"""
    if text:
        img = font.render(text, False, fg, bg)
        w, h = img.get_width(), img.get_height()
        _x = x - w + rj_adjust if rj_adjust else x
        _g.screen.blit(img, (_x, y))
        if box or bubble:
            # fill missing parts of box inside
            pygame.draw.line(_g.screen, bg, (_x - 1, y - 1), (_x + w - 1, y - 1))
            pygame.draw.line(_g.screen, bg, (_x - 1, y), (_x - 1, y + 5))

            # draw box outline
            pygame.draw.line(_g.screen, fg, (_x - 1, y - 2), (_x + w - 1, y - 2))
            pygame.draw.line(_g.screen, fg, (_x - 1, y + h), (_x + w - 1, y + h))
            pygame.draw.line(_g.screen, fg, (_x - 2, y - 1), (_x - 2, y + h - 1))
            pygame.draw.line(_g.screen, fg, (_x + w, y - 1), (_x + w, y + h - 1))

            if bubble:
                # make box into a speech bubble
                pygame.draw.polygon(_g.screen, bg, [(_x - 2, y + 1), (_x - 6, y + 2), (_x - 2, y + 3)])
                pygame.draw.lines(_g.screen, fg, False, [(_x - 2, y + 1), (_x - 6, y + 2), (_x - 2, y + 3)])


def flash_message(message, x=0, y=0, cycles=6, delay_ms=50, clear=True):
    if clear:
        clear_screen()
    for i in (0, 1, 2) * cycles:
        write_text(message, font=dk_font, x=x, y=y, fg=(BROWN, PINK, RED)[i])
        update_screen(delay_ms=delay_ms)
    if clear:
        clear_screen()


def get_image(image_key, fade=False):
    """Load image or read prevously loaded image from the dictionary/cache"""
    _key = image_key + str(fade)
    if _key not in _g.image_cache:
        _g.image_cache[_key] = pygame.image.load(image_key).convert_alpha()
        if fade:
            _g.image_cache[_key].set_alpha(FADE_LEVEL)
    return _g.image_cache[_key]


def read_map(x, y):
    """Return R colour value from pixel at provided x, y position on the screen map"""
    try:
        return _g.screen_map.get_at((int(x), int(y)))[0]
    except IndexError:
        return 254


def get_map_info(direction=None, x=0, y=0, platforms_only=False):
    """Return information from map e.g. ladders and obstacles preventing movement in intended direction"""
    map_info = []
    _x = int(x) if x else int(_g.xpos) + SPRITE_HALF
    _y = int(y) if y else int(_g.ypos) + SPRITE_FULL
    try:
        if read_map(_x - SPRITE_HALF, _y) == 254:
            map_info.append("BLOCKED_LEFT")
        if read_map(_x + SPRITE_HALF, _y) == 254:
            map_info.append("BLOCKED_RIGHT")
        if read_map(_x, _y) in [236, 150]:
            map_info.append("FOOT_UNDER_PLATFORM")
        if read_map(_x, _y + 1) in [0, 90] or (platforms_only and read_map(_x, _y + 1) in [20, 100]):
            map_info.append("FOOT_ABOVE_PLATFORM")
        if read_map(_x, _y + 1) == 150:
            map_info.append("FOOT_ABOVE_OILCAN")

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
    """Push KEYUP events which can be lost after calling external programs"""
    _s.debounce()
    for attr, control in CONTROL_ASSIGNMENTS:
        event = pygame.event.Event(pygame.KEYUP, {'key': control})
        pygame.event.post(event)


def detect_joysticks():
    for i in range(0, pygame.joystick.get_count()):
        _g.joysticks.append(pygame.joystick.Joystick(i))
        _g.joysticks[-1].init()


def check_for_input(force_exit=False, continue_only=False):
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
            if event.key == CONTROL_TAB and not continue_only:
                open_settings_menu()
            if event.key == CONTROL_P2 and ENABLE_MENU and not continue_only:
                build_menus()
                open_menu(_g.menu, remember_selection=True)
            if event.key == CONTROL_COIN and not continue_only:
                if _g.ready:
                    # globals()["SHOW_GAMETEXT"] = 1 if SHOW_GAMETEXT == 0 else 0
                    set_gametext(None, SHOW_GAMETEXT, external=True)  # Fix pygamemenu issue
                else:
                    _g.showinfo = not _g.showinfo
            if event.key == CONTROL_ACTION and not continue_only:
                _g.showslots = not _g.showslots
            if event.key == CONTROL_SNAP:
                take_screenshot()
            if event.key == CONTROL_SKIP:
                if ENABLE_PLAYLIST and playlist.get_busy():
                    play_from_tracklist()
            if event.key == CONTROL_PLAYLIST:
                globals()["ENABLE_PLAYLIST"] = 1 if ENABLE_PLAYLIST == 0 else 0
                set_playlist(None, ENABLE_PLAYLIST, external=True)  # Fix pygamemenu issue

        # Optional joystick controls
        if USE_JOYSTICK:
            if event.type == pygame.JOYAXISMOTION:
                _g.active = True
                _g.lastmove = _g.timer.duration
                if event.axis == 0:
                    _g.left = event.value < -0.5
                    _g.right = event.value > 0.5
                elif event.axis == 1:
                    _g.up = event.value < -0.5
                    _g.down = event.value > 0.5
            if event.type == pygame.JOYHATMOTION:
                _g.left = event.value[0] == -1
                _g.right = event.value[0] == 1
                _g.up = event.value[1] == 1
                _g.down = event.value[1] == -1
            if event.type == pygame.JOYBUTTONDOWN:
                button = event.button if event.joy == 0 else event.button + 20
                _g.jump = button == BUTTON_JUMP
                _g.start = button == BUTTON_P1
                if button == BUTTON_EXIT:
                    exit_program(confirm=CONFIRM_EXIT and not force_exit)
                if button == BUTTON_P2 and ENABLE_MENU:
                    build_menus()
                    open_menu(_g.menu, remember_selection=True)
                if button == BUTTON_COIN:
                    if _g.ready:
                        globals()["SHOW_GAMETEXT"] = 1 if SHOW_GAMETEXT == 0 else 0
                        set_gametext(None, SHOW_GAMETEXT, external=True)  # Fix pygamemenu issue
                    else:
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
        pygame.mixer.Sound.play(pygame.mixer.Sound(os.path.join(ROOT_DIR, "sounds", effect)))


def play_sound_callback(effect=None, callback_id=None):
    # Validate that the callback relates to the current game session
    if callback_id == os.getenv("DKAFE_CALLBACK_ID"):
        pygame.mixer.Sound.play(pygame.mixer.Sound(os.path.join(ROOT_DIR, "sounds", effect)))


def play_intro_animation():
    play_sound_effect("jump.wav")
    if SHOW_SPLASHSCREEN:
        _delay = int(CLOCK_RATE * 0.88)
        for _key in _s.intro_frames():
            check_for_input()
            if _g.jump or _g.start or _g.skip:
                play_sound_effect(stop=True)
                break
            if type(_key) is int:
                # Flash DK Logo
                _g.screen.blit(get_image("artwork/intro/f%s.png" % (str(_key % 2) if _key <= 40 else "1")), TOPLEFT)
                display_slots(version_only=True, logo_scene=True)
            else:
                # Show DK climb scene
                _g.screen.blit(get_image(_key), TOPLEFT)

                # play sound if required for the current frame
                current = int(_key[-8:-4])  # get frame number as integer
                if current in SCENE_SOUNDS:
                    play_sound_effect(SCENE_SOUNDS[current])

                if 480 < current < 840:
                    write_text(f"{str(_g.romcount)} versions of DK detected!", x=108, y=38, bg=MAGENTA, fg=PINK, bubble=True)
                    _delay = int(CLOCK_RATE * 0.8)

                # display nearby icons as girders are broken
                for from_scene, to_scene, below_y, above_y, smash_scene in SCENE_ICONS:
                    if from_scene < current < to_scene:
                        display_icons(below_y=below_y, above_y=above_y, intro=True, smash=current < smash_scene)
                    #    display_slots()
                    #else:
                    #    display_slots(version_only=True)

                # Title and messages
                write_text(("", QUESTION)[855 < current < 1010], font=dk_font, x=12, y=240, bg=BLACK)
                write_text(" DK ARCADE ", font=dk_font, x=69, fg=RED, bg=BLACK)
                write_text(" FRONT END ", font=dk_font, x=69, y=8, bg=BLACK)

            show_score()
            update_screen(delay_ms=_delay)


def display_slots(version_only=False, logo_scene=False):
    if _g.showslots or logo_scene:
        if not version_only:
            for i, slot in enumerate(SLOTS):
                if i in range(*SLOTS_PER_STAGE[_g.stage]):
                    _g.screen.blit(get_image("artwork/icon/slot.png", fade=True), SLOTS[i])
                    _id = str(i + 1).zfill(2)
                    write_text(" " * len(_id), x=SLOTS[i][0] + 1, y=SLOTS[i][1] + 1, bg=BLACK)
                    write_text(_id, x=SLOTS[i][0] + 1, y=SLOTS[i][1] + 2, bg=BLACK)
        write_text(text="VERSION", font=dk_font, x=224, fg=RED, bg=BLACK, rj_adjust=True)
        write_text(text=VERSION, font=dk_font, x=224, y=8, bg=BLACK, rj_adjust=True)


def display_icons(detect_only=False, with_background=False, below_y=None, above_y=None, intro=False, smash=False):
    if with_background:
        _g.screen.blit(get_image(f"artwork/background{_g.stage}.png"), TOPLEFT)
        show_hammers()
        show_score()

    nearby = None
    info_list = []
    # Display icons and return icon that is near to Jumpman
    for _x, _y, name, sub, des, alt, slot, emu, rec, unlock, st3, st2, st1 in _g.icons:
        if int(slot) - 1 in range(*SLOTS_PER_STAGE[_g.stage]):
            p_des = alt.replace("№","00") if alt.strip() else des
            unlocked = True
            up_arrow = False
            if _g.score < unlock and UNLOCK_MODE and not BASIC_MODE and not intro:
                unlocked = False
            if not below_y or not above_y or (below_y >= _y >= above_y):
                icon_image = os.path.join("artwork/icon", sub, name + ".png")
                if smash:
                    icon_image = f"artwork/sprite/smash{str(randint(0, 3))}.png"
                if not os.path.exists(icon_image):
                    icon_image = os.path.join("artwork/icon/default.png")
                img = get_image(icon_image, fade=not unlocked)
                w, h = img.get_width(), img.get_height()
                if _x < _g.xpos + SPRITE_HALF < _x + w and (_y < _g.ypos + SPRITE_HALF < _y + h) and not intro:
                    # Pauline to announce the game found near Jumpman.  Return the game icon information.
                    if not unlocked and since_last_move() % 4 > 2:
                        p_des = f"Unlock at {unlock}"
                    elif unlocked and st3 and st2 and st1 and not BASIC_MODE:
                        _mins = " mins" if sub == "shell" else ""
                        if since_last_move() % 5 > 4:
                            p_des = f'1st prize at {format_K(st1, st3)}' + _mins
                        elif since_last_move() % 5 > 3:
                            p_des = f'2nd prize at {format_K(st2, st3)}' + _mins
                        elif since_last_move() % 5 > 2:
                            p_des = f'3rd prize at {format_K(st3, st3)}' + _mins
                    elif '-record' in _s.get_emulator(emu) and since_last_move() % 4 > 2:
                        # In case the default emu is for recordings
                        p_des = 'For recording!'
                    elif not st3.strip() and since_last_move() % 4 > 2:
                        p_des = 'For practice!'
                    elif not int(FREE_PLAY or BASIC_MODE) and since_last_move() % 4 > 2:
                        p_des = f'${str(PLAY_COST)} to play'
                    if not _g.awarded and not _g.ready:
                        # don't announce if Pauline already informing of an award
                        write_text(p_des, x=108 + _g.psx, y=38 + _g.psy, bg=MAGENTA, fg=PINK, bubble=True)
                    if unlocked:
                        nearby = (sub, name, alt, emu, rec, unlock, st3, st2, st1)
                        _g.selected = p_des
                        up_arrow = True

                if not detect_only:
                    if img:
                        _g.screen.blit(img, (_x, _y))
                        if sub+name in _g.achievements:
                            # Show previously awarded trophy against the machine
                            _tx = _x + (w / 2) - 9
                            _tx = _tx if _tx > 0 else 0
                            _g.screen.blit(get_image(f"artwork/sprite/sm_cup{str(_g.achievements[sub+name])}.png"), (_tx, _y + 14))
                    if up_arrow and not _g.ready:
                        if pygame.time.get_ticks() % 550 < 275:
                            _g.screen.blit(get_image(f"artwork/sprite/up.png"), (_x+1, _y+22))
                    if "-record" in _s.get_emulator(emu).lower() and not _g.showinfo:
                        # Show recording text above icon
                        if _g.timer.duration % 2 < 1:
                            write_text("REC", x=_x, y=_y - 6, bg=RED)
                if _g.showinfo:
                    info_list.append((des, _x, _y, w, unlocked))

    if _g.showinfo:
        # Show game info above icons.  Done as last step so that icons do not overwrite the text.
        for des, x, y, w, unlocked in [info_list, reversed(info_list)][_g.timer.duration % 4 < 2]:
            write_text(des, x=x, y=y - 6, fg=[BLACK, MAGENTA][unlocked], bg=[GREY, WHITE][unlocked], box=True,
                       rj_adjust=(not (len(des) * 4) + x <= 224) * (w - 1))
    return nearby


def adjust_jumpman():
    """Adjust Jumpman's vertical position with the sloping platform"""
    for i in range(0, 4):
        map_info = get_map_info(platforms_only=True)
        if "FOOT_UNDER_PLATFORM" in map_info or "TOP_OF_ANY_LADDER" in map_info:
            _g.ypos += -1
        elif "FOOT_ABOVE_PLATFORM" in map_info and "TOP_OF_ANY_LADDER" not in map_info:
            _g.ypos += 1
        else:
            break

    # Jumpman can grab a ladder when jumping from the oilcan
    if pygame.time.get_ticks() - _g.lastwarpready < 1000 and _g.xpos >= 188 and _g.ypos < 152:
        _g.xpos = 190
        if "CLIMBING_LADDER" in get_map_info(platforms_only=True):
            animate_jumpman("u")


def animate_jumpman(direction=None, horizontal_movement=1, midjump=False):
    sprite_file = f"artwork/sprite/jm{direction}#.png"
    sound_file = None
    map_info = get_map_info(direction)

    if midjump:
        sprite_file = f"artwork/sprite/jmj{direction}.png"
        sprite_file = sprite_file.replace("#", "1")
        if _g.jump_sequence == 8:
            sound_file = "jump.wav"
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
            if _g.last_image:
                _g.screen.blit(_g.last_image, (_g.xpos, int(_g.ypos)))
            return 0
        if direction == "l" and "BLOCKED_LEFT" not in map_info:
            _g.facing = 0
        elif direction == "r" and "BLOCKED_RIGHT" not in map_info:
            _g.facing = 1
        else:
            if _g.last_image:
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
            # Centre Jumpman on ladder
            for c in LADDER_CENTRES:
                if c - 4 <= _g.xpos <= c + 4:
                    _g.xpos = c
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

            if int(_g.sprite_index % 15) == 8:
                sound_file = f"walk{('1', '0')[direction == 'u']}.wav"
            _g.sprite_index += 1
        elif direction == "u":
            if display_icons(detect_only=True):
                # Jumpman is in position to play a game
                sprite_file = sprite_file.replace("#", "0")
                _g.ready = True
            #else:
            #    play_sound_effect("bump.wav")
        elif direction == "d" and _g.ready:
            # Step away from the machine
            sprite_file = f'artwork/sprite/jmr0.png'
            _g.ready = False
        elif direction == "d" and "FOOT_ABOVE_OILCAN" in get_map_info():
            if pygame.time.get_ticks() - _g.lastwarp > 1000:
                play_sound_effect("warp.wav")
                stage_check(warp=True)
    else:
        # Ensure jumpman is not left floating after jumping from the oilcan
        if "FOOT_ABOVE_PLATFORM" not in get_map_info():
            _g.lastwarpready = 0
        if pygame.time.get_ticks() - _g.lastwarpready < 1000:
            adjust_jumpman()

    img = _g.last_image if "#" in sprite_file else get_image(sprite_file)
    if img:
        _g.screen.blit(img, (_g.xpos, int(_g.ypos)))
    _g.last_image = img
    play_sound_effect(sound_file)


def get_system_description(name):
    _system = name.split("_")[0].replace("-", "_")
    if _system == "pc":
        # Some PC are emulated and can be categorised as other systems
        for s in RECOGNISED_SYSTEMS:
            if s in name and s != "pc":
                _system = s
                break
    if _system in RECOGNISED_SYSTEMS:
        return RECOGNISED_SYSTEMS[_system]
    else:
        return ""


def sort_key(x):
    key0 = get_system_description(x[0])
    key1 = (x[3] or x[0]).replace("Bonus:", "ZZBonus:")
    slot = str(x[4])
    if slot == "9999":
        slot = "0"
    return key0.ljust(30) + key1.ljust(30) + slot.zfill(4)


def build_menus(initial=False):
    """Game selection menu"""
    _g.menu = None
    if not UNLOCK_MODE and not initial:
        # Restore full addon menu from cache for improved performance
        if ENABLE_ADDONS and _g.stage >= 2:
            if _g.menu_cache_addon:
                _g.menu = _g.menu_cache_addon
        else:
            if _g.menu_cache_arcade:
                _g.menu = _g.menu_cache_arcade
        if not _g.menu:
            # Pauline announces that the game list is being generated
            write_text("                           ", x=108 + _g.psx, y=38 + _g.psy, bg=BLACK, fg=BLACK, bubble=True)
            write_text("Generating game list..", x=108 + _g.psx, y=38 + _g.psy, bg=MAGENTA, fg=PINK, bubble=True)
            process_interrupts()
            animate_jumpman()
            update_screen()

    if not _g.menu:
        _g.menu = pymenu.Menu(DISPLAY[1], DISPLAY[0], QUESTION, mouse_visible=False, mouse_enabled=False, theme=dkafe_theme_left, onclose=close_menu)
        _g.menu.add_vertical_margin(4)

        _lastname, _lastsystem = "", ""
        _count = 0
        for name, sub, desc, alt, slot, icx, icy, emu, rec, unlock, st3, st2, st1, add in _g.romlist:
            _system = get_system_description(name)
            if _g.score >= unlock or not UNLOCK_MODE or BASIC_MODE:
                if sub != "shell" or name != _lastname:
                    if (_g.stage < 2 and not add) or (_g.stage >= 2 and (add and ENABLE_ADDONS or not add and not ENABLE_ADDONS)):
                        if _system and _system != _lastsystem:
                            _g.menu.add_label(f'{_system} {"_"*70}', font_color=GREY, font_name="fonts/tom-thumb.bdf")
                            _lastsystem = _system
                        # Don't show duplicates in the gamelist.  If the button_id already exists then don't provide one.
                        if ":" in alt:
                            alt = alt.split(":")[1].strip()
                        if not initial and ENABLE_ADDONS and not UNLOCK_MODE and _g.stage >= 2:
                            _percent = ceil(_count / len(_g.romlist) * 100)
                            write_text(f"Generating game list..{str(_percent)}%", x=108 + _g.psx, y=38 + _g.psy, bg=MAGENTA, fg=PINK, bubble=True)
                            update_screen()
                        try:
                           widget = _g.menu.add_button(alt, launch_rom, (sub, name, alt, emu, rec, unlock, st3, st2, st1), button_id=sub+name)
                        except (IndexError, ValueError) as error:
                           widget = _g.menu.add_button(alt, launch_rom, (sub, name, alt, emu, rec, unlock, st3, st2, st1))
                        if _system:
                            widget.set_margin(8,2)
            if initial and int(icx) >= 0 and int(icy) >= 0:
                _g.icons.append((int(icx), int(icy), name, sub, desc, alt, slot, emu, rec, unlock, st3, st2, st1))
            _lastname = name
            _count += 1

        if UNLOCK_MODE:
            _g.menu.add_vertical_margin(4)
            _g.menu.add_label("* Earn coins to add more games to this list.", font_color=GREY, font_name="fonts/tom-thumb.bdf")
        _g.menu.add_vertical_margin(6)
        _g.menu.add_button('Settings', open_settings_menu)
        _g.menu.add_button('Close Menu', close_menu)

        if not UNLOCK_MODE:
            # Cache the full unlocked menu build
            if ENABLE_ADDONS and _g.stage >= 2:
                if not _g.menu_cache_addon:
                    _g.menu_cache_addon = _g.menu
            else:
                if not _g.menu_cache_arcade:
                    _g.menu_cache_arcade = _g.menu

    if initial:
        # Exit menu
        _g.exitmenu = pymenu.Menu(70, 200, "Really want to leave ?", mouse_visible=False, mouse_enabled=False, theme=dkafe_theme, onclose=close_menu)
        _g.exitmenu.add_button('Take me back', close_menu)
        _g.exitmenu.add_button('Exit', exit_program)
        if ENABLE_SHUTDOWN:
            _g.exitmenu.add_button('Shutdown', shutdown_system)

        # Setting menu
        _g.setmenu = pymenu.Menu(DISPLAY[1], DISPLAY[0], "    FRONTEND SETTINGS", mouse_visible=False, mouse_enabled=False, theme=dkafe_theme, onclose=close_menu)
        _g.setmenu.add_selector('   Unlock Mode: ', [('Off', 0), ('On', 1)], default=UNLOCK_MODE, onchange=set_unlock)
        _g.setmenu.add_selector('      Free Play: ', [('Off', 0), ('On', 1)], default=FREE_PLAY, onchange=set_freeplay)
        _g.setmenu.add_selector('    Fullscreen: ', [('Off', 0), ('On', 1)], default=FULLSCREEN, onchange=set_fullscreen)
        if _s.get_system() == "win":
            _g.setmenu.add_selector('     Rotation: ',[('0', 0), ('90', 90), ('180', 180), ('270', 270)], default=ROTATION//90, onchange=set_rotate)
        _g.setmenu.add_selector('  Confirm Exit: ', [('Off', 0), ('On', 1)], default=CONFIRM_EXIT, onchange=set_confirm)
        _g.setmenu.add_selector('Show Game Text: ', [('Off', 0), ('On', 1)], default=SHOW_GAMETEXT, onchange=set_gametext)
        _g.setmenu.add_selector('   Show Splash: ', [('Off', 0), ('On', 1)], default=SHOW_SPLASHSCREEN, onchange=set_splash)
        _g.setmenu.add_selector(' Speed Adjust: ',[('0', 0), ('+1', 1), ('+2', 2), ('+3', 3), ('+4', 4), ('+5', 5), ('+6', 6), ('+7', 7), ('+8', 8)], default=SPEED_ADJUST, onchange=set_speed)
        _g.setmenu.add_vertical_margin(6)
        _g.setmenu.add_selector('Highscore Save: ', [('Off', 0), ('On', 1)], default=HIGH_SCORE_SAVE, onchange=set_high)
        _g.setmenu.add_selector('Music Playlist: ', [('Off', 0), ('On', 1)], default=ENABLE_PLAYLIST, onchange=set_playlist)
        _g.setmenu.add_selector('   Music Volume: ',[('0%', 0), ('10%', 1), ('20%', 2), ('30%', 3), ('40%', 4), ('50%', 5), ('60%', 6), ('70%', 7), ('80%', 8), ('90%', 9), ('100%', 10)], default=PLAYLIST_VOLUME, onchange=set_volume)
        if ARCH in ["win32", "win64"] and ADDONS_CONSIDERED and not ENABLE_ADDONS:
            _g.setmenu.add_vertical_margin(6)
            _g.setmenu.add_button('♥ Get Console Add-On Pack', get_addon)
        _g.setmenu.add_vertical_margin(6)
        _g.setmenu.add_button('Save Changes to File', save_menu_settings)
        _g.setmenu.add_button('Close Menu', close_menu)
        if ENABLE_ADDONS and sys.gettrace():
            # reset add-ons option available in debug mode
            _g.setmenu.add_vertical_margin(6)
            _g.setmenu.add_button('Reset Add-Ons (Advanced)', reset_addon_state_files)


def get_addon():
    if ARCH in ["win32", "win64"]:
        import requests
        latest_addon_path = os.path.join(ROOT_DIR, "dkafe_console_addon_pack_latest.zip")
        clear_screen()
        write_text("DOWNLOADING ADD-ON PACK", font=dk_font, y=0, fg=RED)
        write_text("The console add-on pack is being downloaded.", font=pl_font, y=14, fg=RED)
        _g.screen.blit(get_image("artwork/sprite/pauline.png"), (0, 215))
        _g.screen.blit(get_image("artwork/sprite/dk0.png"), (167, 205))
        write_text("Please wait...", x=22, y=218, bg=MAGENTA, fg=PINK, bubble=True)
        pygame.draw.rect(_g.screen, GREY, [0, 245, 224, 8], 0)
        update_screen()
        try:
            r = requests.get(ADDON_URL, stream=True, headers={'user-agent': 'Wget/1.16 (linux-gnu)'})
            total_size = int(r.headers.get("Content-length"))
        except:
            r = None
            total_size = 0
        if total_size > 0:
            chunk_size, download_size = 1024, 0
            with open(latest_addon_path, 'wb') as f:
                for chunk in r.iter_content(chunk_size=chunk_size):
                    if chunk:
                        f.write(chunk)
                        download_size += chunk_size
                        if pygame.time.get_ticks() % 30 == 0:
                            _progress = round((download_size / total_size) * DISPLAY[0])
                            _percent = (download_size / total_size) * 100
                            _g.screen.blit(get_image("artwork/sprite/dkblank.png"), (167, 205))
                            if pygame.time.get_ticks() % 5000 < 2000:
                                _g.screen.blit(get_image("artwork/sprite/dk0.png"), (167, 205))
                            elif pygame.time.get_ticks() % 5000 < 3000:
                                _g.screen.blit(get_image("artwork/sprite/dk1.png"), (167, 205))
                            elif pygame.time.get_ticks() % 5000 < 4000:
                                _g.screen.blit(get_image("artwork/sprite/dk2.png"), (167, 205))
                            else:
                                _g.screen.blit(get_image("artwork/sprite/dk3.png"), (167, 205))
                            pygame.draw.rect(_g.screen, RED, [0, 245, _progress, 8], 0)
                            write_text(f'{_percent:.2f}' + "% downloaded", x=22, y=218, bg=MAGENTA, fg=PINK, bubble=True)
                            update_screen()

            # Allow up to 10 seconds for the file to save fully.
            for i in range(0, 10):
                if os.path.exists(latest_addon_path):
                    break
                _s.sleep(1)

            clear_screen()
            if os.path.exists(latest_addon_path):
                write_text("♥ DOWNLOAD FINISHED", font=dk_font, y=0, fg=WHITE)
                write_text("DKAFE will now exit and you must relaunch it to", font=pl_font, y=14, fg=WHITE)
                write_text("complete the add-on pack installation.", font=pl_font, y=22, fg=WHITE)
                jump_to_continue()
                pygame.quit()
                sys.exit()
            else:
                write_text("PROBLEM WITH DOWNLOAD", font=dk_font, y=0, fg=WHITE)
                write_text("Sorry!  A problem was encountered while attempting", font=pl_font, y=14, fg=WHITE)
                write_text("to download the add-on pack.", font=pl_font, y=22, fg=WHITE)
                jump_to_continue()
        else:
            clear_screen()
            write_text("PROBLEM WITH DOWNLOAD", font=dk_font, y=0, fg=WHITE)
            write_text("The download target is not currently reachable.", font=pl_font, y=14, fg=WHITE)
            write_text("Please check your internet connectivity.", font=pl_font, y=22, fg=WHITE)
            jump_to_continue()


def reset_addon_state_files():
    count = 0
    for (dirname, dirs, files) in os.walk(os.path.join(ROM_DIR)):
        for file in files:
            if file.endswith('.state'):
                os.remove(os.path.join(dirname, file))
                count += 1
    flash_message(f"{str(count)} STATE FILES REMOVED", x=16, y=120, cycles=10)  # Gameplay recording (i.e. Wolfmame)


def build_launch_menu():
    """Special launch menu"""
    nearby = display_icons(detect_only=True)
    if nearby:
        sub, name, alt, emu, rec, unlock, st3, st2, st1 = nearby
        show_chorus = sub in CHORUS_FRIENDLY or (not sub and name in CHORUS_FRIENDLY)
        show_continue = sub in CONTINUE_FRIENDLY or (not sub and name in CONTINUE_FRIENDLY)
        show_start5 = sub in START5_FRIENDLY or (not sub and name in START5_FRIENDLY)
        show_stage = sub in STAGE_FRIENDLY  or (not sub and name in STAGE_FRIENDLY)
        show_coach = sub in COACH_FRIENDLY or (not sub and name in COACH_FRIENDLY)
        show_coach_l5 = sub in COACH_L5_FRIENDLY or (not sub and name in COACH_L5_FRIENDLY)
        show_shoot = sub in SHOOT_FRIENDLY or (not sub and name in SHOOT_FRIENDLY)
        inps = _s.get_inp_files(rec, name, sub, 12 - show_coach - show_coach_l5 - show_chorus - show_continue - show_shoot - show_start5 - (show_stage*4))
        _g.launchmenu = pymenu.Menu(256, 224, _g.selected.center(26), mouse_visible=False, mouse_enabled=False, theme=dkafe_theme, onclose=close_menu)
        if '-record' not in _s.get_emulator(emu):
            _g.launchmenu.add_button('Launch game               ', launch_rom, nearby)
        if rec > 0:
            _g.launchmenu.add_button('Launch and record game    ', launch_rom, nearby, False, rec)
            if inps:
                _g.launchmenu.add_vertical_margin(10)
                _g.launchmenu.add_label('Playback latest recordings:')
                for inp in inps:
                    try:
                        *_, time_stamp, time_mins = os.path.splitext(inp)[0].split("_")
                        if time_mins.endswith("m"):
                            bullet = "♥ " if int(time_mins[:-1]) >= INP_FAVOURITE else "- "
                            entry = _s.format_datetime(time_stamp, ' +{0: <4}'.format(time_mins))
                            _g.launchmenu.add_button(bullet + entry, playback_rom, nearby, inp)
                    except ValueError:
                        pass

        if show_coach or show_chorus or show_continue or show_shoot or show_start5 or show_coach_l5:
            _g.launchmenu.add_vertical_margin(10)
            if show_start5:
                _g.launchmenu.add_button('↑ Launch at level 5       ', launch_rom, nearby, "dkstart5")
            if show_continue:
                _g.launchmenu.add_button('» Launch with continues   ', launch_rom, nearby, "continue")
            if show_coach:
                _g.launchmenu.add_button('Č Launch with coach       ', launch_rom, nearby, "dkcoach")
            if show_coach_l5:
                _g.launchmenu.add_button('Č Launch with coach at L=5', launch_rom, nearby, "dkcoach,dkstart5")
            if show_chorus:
                _g.launchmenu.add_button('♪ Launch with chorus      ', launch_rom, nearby, "dkchorus")
            if show_shoot:
                _g.launchmenu.add_button('▲ Launch with shooter     ', launch_rom, nearby, "galakong")

        if show_stage:
            _g.launchmenu.add_vertical_margin(10)
            if name == "dkongjr":
                _g.launchmenu.add_button('- Practice springboard    ', launch_rom, nearby, "dkstart5:1")
                _g.launchmenu.add_button('- Practice vines          ', launch_rom, nearby, "dkstart5:2")
                _g.launchmenu.add_button('- Practice chains         ', launch_rom, nearby, "dkstart5:3")
                _g.launchmenu.add_button('- Practice hideout        ', launch_rom, nearby, "dkstart5:4")
            else:
                _g.launchmenu.add_button('- Practice barrels        ', launch_rom, nearby, "dkstart5:1")
                _g.launchmenu.add_button('- Practice pies           ', launch_rom, nearby, "dkstart5:2")
                _g.launchmenu.add_button('- Practice springs        ', launch_rom, nearby, "dkstart5:3")
                _g.launchmenu.add_button('- Practice rivets         ', launch_rom, nearby, "dkstart5:4")

        _g.launchmenu.add_vertical_margin(10)
        _g.launchmenu.add_button('Close', close_menu)


def open_settings_menu():
    open_menu(_g.setmenu)
    reset_all_inputs()


def save_menu_settings():
    if os.path.exists("settings.txt"):
        _s.copy("settings.txt", "settings_backup.txt")
        if os.path.exists("settings_backup.txt"):
            with open("settings.txt", "w") as f_out:
                with open("settings_backup.txt") as f_in:
                    for line in f_in.readlines():
                        line_packed = line.replace(" ", "")
                        if "UNLOCK_MODE=" in line_packed:
                            f_out.write(f"UNLOCK_MODE = {UNLOCK_MODE}\n")
                        elif "FREE_PLAY=" in line_packed:
                            f_out.write(f"FREE_PLAY = {FREE_PLAY}\n")
                        elif "FULLSCREEN=" in line_packed:
                            f_out.write(f"FULLSCREEN = {FULLSCREEN}\n")
                        elif "ROTATION=" in line_packed:
                            f_out.write(f"ROTATION = {ROTATION}\n")
                        elif "CONFIRM_EXIT=" in line_packed:
                            f_out.write(f"CONFIRM_EXIT = {CONFIRM_EXIT}\n")
                        elif "BASIC_MODE=" in line_packed:
                            f_out.write(f"BASIC_MODE = {BASIC_MODE}\n")
                        elif "SHOW_SPLASHSCREEN=" in line_packed:
                            f_out.write(f"SHOW_SPLASHSCREEN = {SHOW_SPLASHSCREEN}\n")
                        elif "SHOW_GAMETEXT=" in line_packed:
                            f_out.write(f"SHOW_GAMETEXT = {SHOW_GAMETEXT}\n")
                        elif "SPEED_ADJUST=" in line_packed:
                            f_out.write(f"SPEED_ADJUST = {SPEED_ADJUST}\n")
                        elif "HIGH_SCORE_SAVE=" in line_packed:
                            f_out.write(f"HIGH_SCORE_SAVE = {HIGH_SCORE_SAVE}\n")
                        elif "ENABLE_PLAYLIST=" in line_packed:
                            f_out.write(f"ENABLE_PLAYLIST = {ENABLE_PLAYLIST}\n")
                        elif "PLAYLIST_VOLUME=" in line_packed:
                            f_out.write(f"PLAYLIST_VOLUME = {PLAYLIST_VOLUME}\n")
                        else:
                            f_out.write(line)
            # os.remove("settings_backup.txt")
            write_text(text="  Changes have been saved  ", font=dk_font, y=232, fg=PINK, bg=RED)
            update_screen(delay_ms=750)


def set_unlock(_, setting_value):
    globals()["UNLOCK_MODE"] = setting_value


def set_freeplay(_, setting_value):
    globals()["FREE_PLAY"] = setting_value


def set_splash(_, setting_value):
    globals()["SHOW_SPLASHSCREEN"] = setting_value


def set_speed(_, setting_value):
    globals()["SPEED_ADJUST"] = setting_value


def set_volume(_, setting_value):
    globals()["PLAYLIST_VOLUME"] = setting_value
    playlist.set_volume(setting_value / 10)


def set_high(_, setting_value):
    globals()["HIGH_SCORE_SAVE"] = setting_value


def set_confirm(_, setting_value):
    globals()["CONFIRM_EXIT"] = setting_value


def set_gametext(_, setting_value, external=False):
    globals()["SHOW_GAMETEXT"] = setting_value
    if external:
        update_menu_selection("Show Game Text", int(SHOW_GAMETEXT))


def set_playlist(_, setting_value, external=False):
    globals()["ENABLE_PLAYLIST"] = setting_value
    if setting_value == 1:
        background_channel.stop()
    else:
        background_channel.play(pygame.mixer.Sound('sounds/background.wav'), -1)
        playlist.stop()
    if external:
        update_menu_selection("Music Playlist", int(ENABLE_PLAYLIST))


def set_fullscreen(_, setting_value):
    if FULLSCREEN != setting_value:
        globals()["FULLSCREEN"] = setting_value
        pygame.display.toggle_fullscreen()
        pygame.event.set_grab(FULLSCREEN == 1)
        pygame.display.init()
        pygame.display.set_icon(get_image("artwork/dkafe.ico"))


def set_rotate(_, setting_value):
    if ROTATION != setting_value:
        globals()["ROTATION"] = setting_value
        rotate_display(rotate=setting_value)


# noinspection PyProtectedMember
def update_menu_selection(title, index):
    # Hack to update pygamemenu selection outside the menu
    for i, w in enumerate(_g.setmenu._widgets):
        if title in w._title:
            _g.setmenu._widgets[i]._index = index
            break


def open_menu(menu, remember_selection=False):
    _g.timer.stop()
    #pygame.mouse.set_visible(False)
    pygame.mixer.pause()
    if not ENABLE_PLAYLIST:
        intermission_channel.play(pygame.mixer.Sound('sounds/menu.wav'), -1)
    if menu:
        if remember_selection:
            # remember previous selection on large lists
            _widget = _g.last_selected or _g.last_launched
            try:
                menu.select_widget(widget=_widget)
            except (AssertionError, AttributeError):
                # Item was not found in the active list
                pass
        _g.current_menu_title = menu.get_title()
        menu.enable()
        menu.mainloop(_g.screen, bgfun=menu_callback)
        reset_all_inputs()


def menu_callback():
    # Keep playlist playing while in menu
    if ENABLE_PLAYLIST and not playlist.get_busy():
        play_from_tracklist()

    # Allow menu scroll using left/right cursor or page up/page down keys
    keys=pygame.key.get_pressed()
    # Long press of up/down also scrolls
    _g.last_up = _g.last_up + 1 if keys[CONTROL_UP] else 0
    _g.last_down = _g.last_down + 1 if keys[CONTROL_DOWN] else 0
    game_menu = _g.current_menu_title == QUESTION

    if keys and (_s.time() - _g.last_press > 0.1 or _g.last_up > 8 or _g.last_down > 8):
        k = None
        if (keys[CONTROL_LEFT] and game_menu) or keys[CONTROL_PAGEUP] or _g.last_up > 10:
            k = CONTROL_UP
        elif (keys[CONTROL_RIGHT] and game_menu) or keys[CONTROL_PAGEDOWN] or _g.last_down > 10:
            k = CONTROL_DOWN
        if k:
            # Simulate up or down keypress 10 times for quicker scrolling
            step = 1 if _g.last_up > 8 or _g.last_down > 8 else 6
            for i in range(0, step):
                event = pygame.event.Event(pygame.KEYDOWN, {'key': k})
                pygame.event.post(event)
                event = pygame.event.Event(pygame.KEYUP, {'key': k})
                pygame.event.post(event)
            _g.last_press = _s.time()


def close_menu():
    pygame.mouse.set_visible(False)
    intermission_channel.stop()
    # Remember the last selected item from the game menu
    if _g.current_menu_title == QUESTION:
        try:
            widget = _g.menu.get_selected_widget()
            _g.last_selected = widget._args[0][0] + widget._args[0][1]
        except:
            _g.last_selected = None
    _g.menu.disable()
    _g.exitmenu.disable()
    _g.setmenu.disable()
    if _g.launchmenu:
        _g.launchmenu.disable()
    update_screen()
    _g.active = True
    _g.timer.start()
    _g.lastmove = _g.timer.duration


def shutdown_system():
    if _s.is_pi():
        os.system("shutdown -h now")
    else:
        os.system("shutdown /s /f /t 00")


def launch_rom(info, launch_plugin=None, override_emu=None):
    """Launch the rom using provided info.
       Override is used to change emu number in case of recordings (to rec number)."""
    if _g.active and info:
        sub, name, alt, emu, rec, unlock, st3, st2, st1 = info
        if override_emu:
            emu = override_emu
            info = sub, name, alt, emu, rec, unlock, st3, st2, st1
        _g.timer.stop()  # Stop timer while playing arcade
        _g.menu.disable()
        if _g.launchmenu:
            _g.launchmenu.disable()
        intermission_channel.stop()
        award_channel.stop()
        if ENABLE_PLAYLIST:
            playlist.pause()
        else:
            background_channel.pause()

        launch_command, launch_directory, competing, inp_file = \
            _s.build_launch_command(info, BASIC_MODE, HIGH_SCORE_SAVE, REFOCUS_WINDOW, FULLSCREEN, launch_plugin)

        if FREE_PLAY or BASIC_MODE or _g.score >= PLAY_COST:
            _g.score -= (PLAY_COST, 0)[int(FREE_PLAY or BASIC_MODE)]  # Deduct coins if not freeplay
            play_sound_effect("coin.wav")
            if not competing and "-record" in launch_command:
                flash_message("R E C O R D I N G", x=40, y=120)  # Gameplay recording (i.e. Wolfmame)

            clear_awarded_coin_status(_g.coins)
            reset_all_inputs()
            if os.path.exists(launch_directory):
                os.chdir(launch_directory)
            clear_screen()

            if EMU_ENTER:
                Popen(EMU_ENTER)
            if EMU_EXIT:
                launch_command += f"; {EMU_EXIT}"
            time_start = _s.time()

            # Temporary keyboard remapping
            remap_program = None
            if name in KEYBOARD_REMAP:
                if ARCH == "win64":
                    for remap_program in os.path.join(ROOT_DIR, "remap_pc.exe"), os.path.join(ROOT_DIR, "dist", "remap_pc.exe"), os.path.join(ROM_DIR, "pc", "remap_pc.exe"):
                        if os.path.exists(remap_program):
                            _keys = KEYBOARD_REMAP[name]
                            Popen(f'"{remap_program}" "{name}" "{_keys}', creationflags=CREATE_NO_WINDOW)
                            break

            if name.split("_")[0] in WIN64_ONLY_SYSTEMS:
                if name.startswith("pc_"):
                    os.chdir(os.path.join(ROM_DIR, "pc", name))
                if competing:
                    # Use threading callback to play sounds when target scores are achieved.
                    # Each thread is unique to the game and time of launch - so not played if game is exited.
                    from threading import Thread as _Thread
                    _id = name + str(pygame.time.get_ticks())
                    os.environ["DKAFE_CALLBACK_ID"] = _id
                    _t3 = _Thread(target=lambda: (_s.sleep((int(st3) * 60) - 4), play_sound_callback(f"award3.wav", _id)))
                    _t2 = _Thread(target=lambda: (_s.sleep((int(st2) * 60) - 4), play_sound_callback(f"award2.wav", _id)))
                    _t1 = _Thread(target=lambda: (_s.sleep((int(st1) * 60) - 4), play_sound_callback(f"award1.wav", _id)))
                    for _t in _t3, _t2, _t1:
                        _t.daemon = True
                        _t.start()
                if name.startswith("_pc"):
                    run(name, shell=True, creationflags=CREATE_NO_WINDOW)
                else:
                    run(launch_command, creationflags=CREATE_NO_WINDOW)
                os.environ["DKAFE_CALLBACK_ID"] = ""
                os.chdir(ROOT_DIR)
            else:
                if len(sys.argv) >= 2 and sys.argv[1] == "SHOWCONSOLE":
                    # Don't hide the console output
                    run(launch_command)
                else:
                    run(launch_command, creationflags=CREATE_NO_WINDOW)

            # Terminate any temporary keyboard mappings
            if remap_program:
                kill_pc_external(program=remap_program)

            # If there was a specific config file then copy it back to account for any changes
            if sub == "shell":
                cfg_file = os.path.join(ROOT_DIR, "dkwolf", "cfg", name + ".cfg")
                if os.path.exists(cfg_file):
                    _system = name.split("_")[0].replace("-", "_")
                    cfg_system = os.path.join(ROOT_DIR, "dkwolf", "cfg", _system + ".cfg")
                    if os.path.exists(cfg_system):
                        _s.copy(cfg_system, cfg_file)

            time_end = _s.time()
            _s.debounce()
            _g.lastexit = _g.timer.duration

            os.chdir(ROOT_DIR)

            clear_screen(and_reset_display=True)
            if competing:
                # Check to see if Jumpman achieved 1st, 2nd or 3rd score target to earn coins
                scored = get_award(sub, name, st3, st2, st1, time_start=time_start, time_end=time_end)
                if scored > 0:
                    _g.awarded = scored
                    _g.ready = False
                    _g.facing = 1
                    _g.timer.reset()
                    _g.lastexit = _g.timer.duration
                    _g.timer_adjust = 0
                    place = get_prize_placing(scored)[0]
                    if sub+name not in _g.achievements or place < _g.achievements[sub+name]:
                        # record your best trophy achievement
                        _g.achievements[sub+name] = place
                    for i, coin in enumerate(range(0, scored, COIN_VALUES[-1])):
                        movement = choice([-1, 1]) if _g.stage == 1 else 1
                        drop_coin(x=COIN_AWARD_POSX[_g.stage], y=i * 2, coin_type=len(COIN_VALUES) - 1, awarded=scored, movement=movement)
                    _g.timer.reset()
                    _g.lastexit = _g.timer.duration
                    award_channel.play(pygame.mixer.Sound("sounds/win.wav"))
            elif "-record" in launch_command:
                # Update .inp with gameplay time in minutes
                inp_path = os.path.join(_s.get_inp_dir(emu), inp_file)
                if os.path.exists(inp_path):
                    time_mins = round((time_end - time_start) / 60)
                    if time_mins > 0:
                        _s.move(inp_path, inp_path.replace("_0m", f"_{time_mins}m"))
        else:
            play_sound_effect("error.wav")
            flash_message("YOU DON'T HAVE ENOUGH COINS !!", x=4, y=120)

        _g.skip = True
        _g.timer.start()  # Restart the timer
        if ENABLE_PLAYLIST:
            playlist.unpause()
        _g.last_selected = sub + name
        _g.last_launched = sub + name


def playback_rom(info, inpfile):
    """playback the specified inp file"""
    launch_command, launch_directory, competing, _ = \
        _s.build_launch_command(info, basic_mode=True,  playback=True, refocus=REFOCUS_WINDOW, fullscreen=FULLSCREEN)

    if os.path.exists(launch_directory):
        close_menu()
        clear_screen(and_reset_display=True)

        playback_command = ""
        retain = True
        for arg in launch_command.split(" "):
            if arg == "-record" or arg == "-nvram_directory":
                retain = False
            else:
                if retain:
                    playback_command += arg + " "
                retain = True
        os.chdir(launch_directory)
        if ENABLE_PLAYLIST:
            playlist.pause()
        playback_command += f" -playback {os.path.basename(inpfile)} -exit_after_playback"
        intermission_channel.stop()
        award_channel.stop()
        if EMU_ENTER:
            Popen(EMU_ENTER)
        if EMU_EXIT:
            launch_command += f"; {EMU_EXIT}"

        run(playback_command, creationflags=CREATE_NO_WINDOW)

        _g.lastexit = _g.timer.duration
        os.chdir(ROOT_DIR)
        if ENABLE_PLAYLIST:
            playlist.unpause()


def show_hammers():
    if ENABLE_HAMMERS:
        for position in HAMMER_POSXY[_g.stage]:
            _g.screen.blit(get_image(f"artwork/sprite/{dk_ck()}hammer.png"), position)


def show_score():
    """Flashing 1UP, score and level"""
    write_text("1UP", font=dk_font, x=25, fg=(BLACK, RED)[pygame.time.get_ticks() % 550 < 275])
    write_text(str(_g.score).zfill(6), font=dk_font, x=9, y=8, bg=BLACK)
    if _g.active:
        write_text(f"L={str(SKILL_LEVEL).zfill(2)}", font=dk_font, x=169, y=24, fg=DARKBLUE, bg=BLACK)


def drop_coin(x=67, y=73, rotate=2, movement=1, use_ladders=True, coin_type=1, awarded=0):
    """Drop a coin at x, y location, rotate sprite no, movement direction, use ladders?,
       coin type id, coin was awarded?"""
    _g.coins.append((x, y, rotate, movement, use_ladders, coin_type, awarded))


def clear_awarded_coin_status(coins):
    _g.coins = []
    for coin in coins:
        _g.coins.append(coin[:6] + (0,))


def show_timeup_animation(sprite_number, loss=0):
    # Show coins during the out of time animation
    display_icons(with_background=True)
    display_slots()
    animate_moving_ladders()
    _g.screen.blit(get_image(f"artwork/sprite/out{sprite_number}.png"), (_g.xpos, int(_g.ypos)))

    # Display items that don't get updated in this loop
    show_score()
    write_text(" 000", font=dk_font, x=177, y=48, fg=BONUS_COLORS[_g.stage][1])
    _g.screen.blit(get_image(f"artwork/sprite/{dk_ck()}0.png"), (11 + _g.dkx, 52 + _g.dky))

    if loss > 0:
        write_text(f"-{str(loss)}", x=_g.xpos, y=_g.ypos - 10, bg=RED, box=True)

    animate_rolling_coins(out_of_time=True)
    update_screen()


def process_interrupts():
    ticks = pygame.time.get_ticks()

    # Start up messages from Pauline
    if not _g.lastmove and not display_icons(detect_only=True):
        message = (COIN_INFO, FREE_INFO)[int(FREE_PLAY or BASIC_MODE)]
        write_text(message[int(int(_g.timer.duration) % (len(message) * 2) / 2)], x=108 + _g.psx, y=38 + _g.psy, bg=MAGENTA, fg=PINK, bubble=True)
    # show_score()

    # Bonus timer
    previous_warning = _g.warning
    bonus_display, bonus_colour, _g.warning, out_of_time = _s.calculate_bonus(_g.timer.duration + _g.timer_adjust)
    if _g.warning:
        if not previous_warning and not ENABLE_PLAYLIST:
            background_channel.play(pygame.mixer.Sound('sounds/countdown.wav'), -1)
        if out_of_time:
            # Jumpman drops coins if he can afford it.
            loss, i = 0, 0
            for coin_type in [2, 1]:
                for coin in range(loss, LIFE_COST, COIN_VALUES[coin_type]):
                    if _g.score >= COIN_VALUES[coin_type] and loss + COIN_VALUES[coin_type] <= LIFE_COST:
                        loss += COIN_VALUES[coin_type]
                        _g.score -= COIN_VALUES[coin_type]
                        if _g.stage == 1:
                            movement = choice([-1, 1])
                        else:
                            movement = 1 if _g.ypos <= 73 or (139 >= _g.ypos > 106) or (205 >= _g.ypos > 172) else -1
                        drop_coin(x=_g.xpos + i, y=_g.ypos, coin_type=coin_type, movement=movement)
                        i += 1

            # Show time up animation
            background_channel.stop()
            play_sound_effect("timeup.wav")
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
            _g.lastexit = _g.timer.duration
            if not ENABLE_PLAYLIST:
                background_channel.play(pygame.mixer.Sound('sounds/background.wav'), -1)

    write_text(bonus_display, font=dk_font, x=177, y=48, fg=BONUS_COLORS[_g.stage][bonus_colour])

    if _g.awarded:
        # Animate DK grabbing the trophy
        place, place_text = get_prize_placing(_g.awarded)
        if _g.timer.duration > 1:
            if _g.timer.duration < 2:
                _g.screen.blit(get_image(f"artwork/sprite/{dk_ck()}g1.png"), (11 + _g.dkx, 52 + _g.dky))
                _g.screen.blit(get_image(f"artwork/sprite/cup{str(place)}.png"), (5 + _g.dkx, 62 + _g.dky))
            elif _g.timer.duration < 3:
                _g.screen.blit(get_image(f"artwork/sprite/{dk_ck()}a1.png"), (11 + _g.dkx, 52 + _g.dky))
                _g.screen.blit(get_image(f"artwork/sprite/cup{str(place)}.png"), (33 + _g.dkx, 60 + _g.dky))
            else:
                if place == 1:
                    # Grinning DK on 1st place trophy
                    _g.screen.blit(get_image(f"artwork/sprite/{dk_ck()}a3.png"), (11 + _g.dkx, 45 + _g.dky))
                else:
                    _g.screen.blit(get_image(f"artwork/sprite/{dk_ck()}a2.png"), (11 + _g.dkx, 45 + _g.dky))
                _g.screen.blit(get_image(f"artwork/sprite/cup{str(place)}.png"), (33 + _g.dkx, 29 + _g.dky))
        else:
            _g.screen.blit(get_image(f"artwork/sprite/{dk_ck()}0.png"), (11 + _g.dkx, 52 + _g.dky))
            _g.screen.blit(get_image(f"artwork/sprite/cup{str(place)}.png"), (5 + _g.dkx, 62 + _g.dky))
    elif _g.timer.duration - _g.lastaward < 2:
        _g.screen.blit(get_image(f"artwork/sprite/{dk_ck()}0.png"), (11 + _g.dkx, 52 + _g.dky))
    else:
        # Animate DK stomping,  sometimes DK will grab a coin
        prefix = (dk_ck(), f"{dk_ck()}g")[_g.grab]
        if _g.grab and _g.cointype == 0:
            # Determine next coin to be grabbed by DK. Higher value coins are released less frequenly
            _g.cointype = int(randint(1, COIN_HIGH) == 1) + 1

        for i, mod in enumerate((500, 1000, 1500)):
            if ticks % 5000 < mod:
                _g.screen.blit(get_image(f"artwork/sprite/{prefix}{str(i + 1)}.png"), (11 + _g.dkx, 52 + _g.dky))
                if _g.grab:
                    _g.screen.blit(get_image(f"artwork/sprite/coin{_g.cointype}3.png"), ((12, 38, 64)[i] + _g.dkx, 74 + _g.dky))
                break

        # If DK grabbed a coin then it will start rolling
        if ticks % 5000 >= 1500:
            if ticks % 5000 < 2000:
                if _g.grab:
                    drop_coin(x=COIN_GRAB_POSXY[_g.stage][0], y=COIN_GRAB_POSXY[_g.stage][1], coin_type=_g.cointype)
                _g.grab = False
                _g.cointype = 0
            if ticks % 5000 > 4500:
                # Will DK grab a coin?
                _g.grab = randint(1, COIN_FREQUENCY) == 1
            _g.screen.blit(get_image(f"artwork/sprite/{prefix}0.png"), (11 + _g.dkx, 52 + _g.dky))

    animate_rolling_coins()

    # Purge coins
    _g.coins = [i for i in _g.coins if -10 < i[0] < 234]

    if _g.ready:
        icons = display_icons(detect_only=True)
        if icons:
            sub, name, alt, _, _, _, st3, st2, st1 = icons
        else:
            sub, name, alt, st3, st2, st1 = ("",) * 6

        # Pauline announces the launch options
        if SHOW_GAMETEXT and alt:
            # Gametext already informs about JUMP and P1 Start buttons,  so announce the score targets instead.
            _mins = " mins" if sub == "shell" else ""
            if since_last_move() % 4 > 3:
                p_des = f'1st prize at {format_K(st1, st3)}' + _mins
            elif since_last_move() % 4 > 2:
                p_des = f'2nd prize at {format_K(st2, st3)}' + _mins
            elif since_last_move() % 4 > 1:
                p_des = f'3rd prize at {format_K(st3, st3)}' + _mins
            else:
                p_des = alt.replace(" :", ":").replace("№","00")
            if p_des:
                write_text(p_des, x=108 + _g.psx, y=38 + _g.psy, bg=MAGENTA, fg=PINK, bubble=True)
        else:
            if since_last_move() % 4 <= 2:
                write_text("Push JUMP to play or..", x=108 + _g.psx, y=38 + _g.psy, bg=MAGENTA, fg=PINK, bubble=True)
                write_text("JUMP", x=128 + _g.psx, y=38 + _g.psy, bg=MAGENTA)
            else:
                write_text("P1 START for options", x=108 + _g.psx, y=38 + _g.psy, bg=MAGENTA, fg=PINK, bubble=True)
                write_text("P1 START", x=108 + _g.psx, y=38 + _g.psy, bg=MAGENTA)

        # Display game text
        if SHOW_GAMETEXT and not "LADDER_DETECTED" in get_map_info():
            selected = sub if sub and sub != "shell" else name
            for rom, text_lines in _g.gametext:
                if rom == selected and text_lines:
                    # Text appears above or below Jumpman based on his Y position
                    text_y = _g.ypos - (len(text_lines)+5) * 6 if _g.ypos >= 138 else _g.ypos + 30
                    # Clear a space for text and draw borders
                    pygame.draw.rect(_g.screen, DARKGREY, (0, text_y-5, 224, len(text_lines)*6+8))
                    pygame.draw.rect(_g.screen, MIDGREY, (0, text_y - 5, 224, 14))
                    pygame.draw.rect(_g.screen, MIDGREY, (0, text_y-5, 224, len(text_lines)*6+8), width=2)
                    pygame.draw.rect(_g.screen, MIDGREY, (0, text_y+len(text_lines)*6+2, 224, 14))
                    # Display the game text
                    for i, line in enumerate(text_lines + TEXT_INFO):
                        text = line.strip()
                        _fg = WHITE
                        if text.startswith("!!") or text.startswith("!Y") or text.startswith("!R"):
                            # Highlight this line red or yellow
                            _fg = BRIGHTRED if text.startswith("!R") else YELLOW
                            text = text[2:]
                        if i == 0:
                            # Center align the title
                            text = " "*int((55 - len(text.strip())) / 2) + text
                        write_text(text[:55], x=4, y=text_y+(i*6), fg=_fg)
                    break

    if _g.lastwarp > 0 and ticks - _g.lastwarp < 1000:
        # After warping, Jumpman appears from inside the oilcan
        write_text("Warp Pipe!", x=108 + _g.psx, y=38 + _g.psy, bg=MAGENTA, fg=PINK, bubble=True)
        _g.screen.blit(get_image(f"artwork/sprite/{dk_ck()}oilcan.png"), OILCAN_POSXY[_g.stage])
    if not _g.lastwarp or ticks - _g.lastwarp > 600:
        # Flash a down arrow when Jumpman is stood on an oilcan to indicate he can warp to next/previous stage.
        if "FOOT_ABOVE_OILCAN" in get_map_info():
            _g.lastwarpready = ticks
            if pygame.time.get_ticks() % 550 < 275:
                _g.screen.blit(get_image(f"artwork/sprite/down.png"), WARP_ARROW_POSXY[_g.stage])


def get_prize_placing(awarded):
    """Return the awarded prize placing e.g. '1', '1st'"""
    place = 3 - AWARDS.index(awarded)
    return place, PRIZE_PLACINGS[place]


def animate_moving_ladders():
    if _g.stage == 2:
        _index = MOVING_LADDER_OFFSETS[floor(_g.frames / 4) % len(MOVING_LADDER_OFFSETS)]
        _x0, _x1 = MOVING_LADDER_POSXY[0][0], MOVING_LADDER_POSXY[1][0]
        _y = MOVING_LADDER_POSXY[0][1]
        _g.screen.blit(get_image("artwork/sprite/ladder.png"), (_x0, _y + _index))
        _g.screen.blit(get_image("artwork/sprite/ladder.png"), (_x1, _y + _index))
        if _index == 0:
            _g.screen_map.blit(get_image("artwork/sprite/ladder_open.png"), (_x0, _y - 8))
            _g.screen_map.blit(get_image("artwork/sprite/ladder_open.png"), (_x1, _y - 8))
        else:
            _g.screen_map.blit(get_image("artwork/sprite/ladder_block.png"), (_x0, _y - 8))
            _g.screen_map.blit(get_image("artwork/sprite/ladder_block.png"), (_x1, _y - 8))

def animate_rolling_coins(out_of_time=False):
    _g.awarded = 0
    for i, coin in enumerate(_g.coins):
        co_x, co_y, co_rot, co_dir, co_ladder, co_type, co_awarded = coin
        if co_awarded:
            place, place_text = get_prize_placing(co_awarded)
            write_text(f"You won {place_text} prize!", x=108 + _g.psx, y=38 + _g.psy, bg=MAGENTA, fg=PINK, bubble=True)
            _g.awarded = co_awarded
            _g.lastaward = _g.timer.duration

        _g.screen.blit(get_image(f"artwork/sprite/coin{str(co_type)}{str(int(co_rot % 4))}.png"),
                       (int(co_x), int(co_y)))

        if (co_x - SPRITE_HALF <= _g.xpos < co_x + SPRITE_HALF) and (co_y >= _g.ypos > co_y - SPRITE_HALF):
            if not out_of_time and _g.timer.duration > 0.2:  # Jumpman cannot collect coins immediately after start/out of time
                _g.score += COIN_VALUES[co_type]  # Jumpman collected the coin
                play_sound_effect("getitem.wav")
                co_x = -999

        map_info = get_map_info(direction="d", x=int(co_x + (9, 4)[co_dir == 1]), y=int(co_y + 9))

        # Toggle ladders.  Virtual ladders are always active.
        if "APPROACHING_LADDER" in map_info or ("TOP_OF_LADDER" in map_info and _g.stage == 1):
            co_ladder = not randint(1, LADDER_CHANCE[_g.stage]) == 1
        elif _g.stage != 1 and "VIRTUAL_LADDER" not in map_info and "FOOT_ABOVE_PLATFORM" not in map_info and co_ladder:
            map_info = []

        # Move the coin along the platform and down ladders
        if "FOOT_UNDER_PLATFORM" in map_info and _g.stage != 0 and _g.stage != 4:
            co_y -= 1  # correct coin position by moving it up the girder
        elif "FOOT_ABOVE_PLATFORM" in map_info:
            co_y += 1  # coin moves down the sloped girder to touch the platform
            if (_g.stage == 1 or _g.stage == 3) and int(co_y) in (232, 192, 152, 112):
                co_dir *= -1  # Flip horizontal direction when falling off platform on rivets
        elif "ANY_LADDER" in map_info and co_y < 238:
            if "TOP_OF_ANY_LADDER" in map_info and _g.stage != 1:
                co_dir *= -1  # Flip horizontal direction after taking a ladder on barrels
            elif "APPROACHING_END_OF_LADDER" in map_info and _g.stage == 1:
                co_dir = choice([-1, 1])  # Random direction change after taking a ladder on rivets
            co_y += COIN_SPEED  # Move down the ladder
        else:
            co_x += co_dir * COIN_SPEED  # Increment horizontal movement
        co_rot += co_dir * COIN_CYCLE
        _g.coins[i] = co_x, co_y, co_rot, co_dir, co_ladder, co_type, co_awarded  # Update coin data


def inactivity_check():
    if _g.timer.duration - _g.lastmove > INACTIVE_TIME:
        _g.ready = False  # Jumpman status changed to be not ready to play.
        _g.facing = 1
        pause_mod = ((pygame.time.get_ticks() - _g.pause_ticks) % 51000) - 3000
        if pause_mod < 0:
            _g.screen.blit(get_image(f"artwork/intro/f{randint(0, 1)}.png"), TOPLEFT)
        else:
            lines = (INSTRUCTION, MORE_INSTRUCTION, CONTROLS, THANKS_TO)[floor(pause_mod / 12000)]
            for i, line in enumerate(lines.split("\n")):
                write_text(line + (" " * 28), y=i * 8 + 20, fg=CYAN, bg=BLACK, font=dk_font)
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


def stage_check(warp=False):
    # Reset Jumpmans position when exiting the stage via ladders or warping through an oilcan
    if warp:
        _g.jump = True
        _g.lastwarp = pygame.time.get_ticks()

    current_stage = _g.stage
    if warp:
        _g.stage = (_g.stage + 1) % STAGES
        _g.xpos, _g.ypos = OILCAN_POSXY[_g.stage]
    elif _g.ypos > 239 and not _g.jump:
        _g.stage = (current_stage - 1) % STAGES
        _g.ypos = 20
    elif _g.ypos < 20 and not _g.jump:
        _g.stage = (current_stage + 1) % STAGES
        _g.ypos = 238

    # Set Donkey Kong and Pauline position
    _g.dkx, _g.dky = KONG_POSXY[_g.stage]
    _g.psx, _g.psy = PAULINE_POSXY[_g.stage]

    if current_stage != _g.stage:
        # Update when switching stage
        _g.coins = []
        _g.screen_map.blit(get_image(f"artwork/map{_g.stage}.png"), TOPLEFT)
        update_screen()

def teleport_between_hammers():
    if ENABLE_HAMMERS:
        if pygame.time.get_ticks() - _g.teleport_ticks > 700:
            o1, o2 = _g.xpos, _g.ypos
            h1, h2 = HAMMER_POSXY[_g.stage]
            t1, t2 = TELEPORT_TO_POSXY[_g.stage]
            if h1[0] - 6 <= _g.xpos <= h1[0] + 6 and h1[1] - 7 <= _g.ypos <= h1[1] + 2:
                _g.xpos, _g.ypos = t1
            elif h2[0] - 6 <= _g.xpos <= h2[0] + 6 and h2[1] - 7 <= _g.ypos <= h2[1] + 2:
                _g.xpos, _g.ypos = t2
            if (o1, o2) != (_g.xpos, _g.ypos):
                _g.teleport_ticks = pygame.time.get_ticks()
                play_sound_effect("teleport.wav")

        if pygame.time.get_ticks() - _g.teleport_ticks < 1000:
            write_text("Teleport Jump!", x=108 + _g.psx, y=38 + _g.psy, bg=MAGENTA, fg=PINK, bubble=True)


def play_from_tracklist():
    #  Play a random track from the track list.  Remember the last played tracks - history holds 1/2 available tracks.
    #  If there's more than 1 track available then we don't repeat play.
    if _g.tracklist:
        while True:
            track = sample(_g.tracklist, 1)[0]
            if track not in _g.trackhistory or len(_g.tracklist) == 1:
                playlist.load(track)
                playlist.play()
                _g.trackhistory.append(track)
                _g.trackhistory = _g.trackhistory[int(len(_g.tracklist) / 2) * -1:]
                break


def dk_ck():
    # DK or CK graphics
    return "ck" if _g.stage == 4 else "dk"


def main(initial=True):
    # Prepare front end
    assert (VERSION.startswith("v")), "The version number could not be determined"
    _g.active = False
    _g.stage = START_STAGE

    rotate_display(initial=True)
    initialise_screen()
    load_frontend_state()
    detect_joysticks()
    check_patches_available()

    _g.romlist, _g.romcount = _s.read_romlist()
    _g.romlist = sorted(_g.romlist, key=sort_key)
    build_menus(initial=True)
    _g.gametext = _s.load_game_texts()

    # Launch front end
    check_roms_available()

    if initial:
        play_intro_animation()

    # Initialise Jumpman
    _s.debounce()
    animate_jumpman("r", horizontal_movement=0)
    _g.lastmove, _g.lastwarp = 0, 0
    _g.timer.reset()
    _g.lastexit = _g.timer.duration
    _g.active = True

    # Initialise playlist/background music
    _g.tracklist = _s.glob("playlist/*.mp3") + _s.glob("playlist/*.ogg") + _s.glob("playlist/*.wav")
    if not ENABLE_PLAYLIST:
        background_channel.play(pygame.mixer.Sound('sounds/background.wav'), -1)
    playlist.set_volume(PLAYLIST_VOLUME / 10)

    # Main game loop
    while True:
        if ENABLE_PLAYLIST and _g.frames % 30 == 0 and not playlist.get_busy():
            play_from_tracklist()
        if _g.active:
            display_icons(with_background=True)
            display_slots()
            animate_moving_ladders()
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
        elif _g.ready and (_g.jump or _g.start):
            _g.start = False
            if _g.jump:
                launch_rom(display_icons(detect_only=True))
            else:
                build_launch_menu()
                open_menu(_g.launchmenu)
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

        stage_check()
        activity_check()
        inactivity_check()
        update_screen()
        _g.frames += 1

        # -- restart game after level is completed --
        # if _g.score >= 90000:
        #     import importlib
        #     importlib.reload(_g)
        #     main(initial=False)


if __name__ == "__main__":
    main()
