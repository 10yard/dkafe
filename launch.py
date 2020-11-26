import sys
import dk_global as _g
import dk_system as _s
from dk_config import *
from random import randint
from glob import glob
from shutil import copy


def exit_program(confirm=False):
    if confirm:
        open_menu(_g.exitmenu)
    else:
        pygame.quit()
        sys.exit()


def initialise_screen(reset=False):
    clock.tick(CLOCK_RATE)
    flags = pygame.FULLSCREEN * int(FULLSCREEN) | pygame.NOFRAME * int(not FULLSCREEN) | pygame.SCALED
    _g.screen = pygame.display.set_mode(GRAPHICS, flags=flags)
    pygame.mouse.set_visible(False)
    if not reset:
        _g.screen_map = _g.screen.copy()
        _g.screen_map.blit(get_image("artwork/map.png"), [0, 0])


def update_screen(frame_delay=0):
    pygame.display.update()
    pygame.time.delay(frame_delay)


def clear_screen(frame_delay=0, colour=BLACK, and_reset_display=False):
    _g.screen.fill(colour)
    update_screen(frame_delay)
    if and_reset_display:
        initialise_screen(reset=True)


def write_text(text=None, font=pl_font, x=0, y=0, fg=WHITE, bg=None, bubble=False, box=False, rj_adjust=0):
    # Write text to screen at given position using fg and bg colour (None for transparent)
    if text:
        img = font.render(text, False, fg, bg)
        w, h = img.get_width(), img.get_height()
        _x = x - w + rj_adjust if rj_adjust else x  # align x left or right
        _g.screen.blit(img, (_x, y))

        if box or bubble:
            w += 1
            pygame.draw.rect(_g.screen, fg, (_x - 2, y - 1, w + 2, h + 2), 1)
            pygame.draw.line(_g.screen, bg, (_x - 1, y), (_x - 1, y + 5))
            if bubble:
                for point in ((_x - 2, y - 1), (_x + w, y - 1), (_x - 2, y + h), (_x + w, y + h)):
                    _g.screen.set_at(point, BLACK)
                pygame.draw.polygon(_g.screen, bg, [(_x - 2, y + 2), (_x - 6, y + 3), (_x - 2, y + 4)])
                pygame.draw.lines(_g.screen, fg, False, [(_x - 2, y + 2), (_x - 6, y + 3), (_x - 2, y + 4)], 1)


def flash_message(message, x, y):
    clear_screen()
    for i in (0, 1, 2) * 7:
        write_text(message, font=dk_font, x=x, y=y, fg=(BROWN, PINK, RED)[i])
        update_screen(FRAME_DELAY * 2)
    clear_screen()


def get_image(image_key):
    # Load image or read prevously loaded image from the dictionary/cache
    if image_key not in _g.image_cache:
        _g.image_cache[image_key] = pygame.image.load(image_key).convert_alpha()
    return _g.image_cache[image_key]


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
        # Check for blocks on the screen map
        if read_map(_x - SPRITE_HALF, _y) == 254:
            map_info.append("BLOCKED_LEFT")
        if read_map(_x + SPRITE_HALF, _y) == 254:
            map_info.append("BLOCKED_RIGHT")
        if read_map(_x, _y) == 236:
            map_info.append("FOOT_UNDER_PLATFORM")
        if read_map(_x, _y + 1) == 0:
            map_info.append("FOOT_ABOVE_PLATFORM")

        # ladder detection based on direction of travel
        _r = read_map(_x - 2, _y + (direction == "d"))
        for zone in LADDER_ZONES:
            if _r in zone[1]:
                map_info.append(zone[0])
    except IndexError:
        map_info.append("ERROR_READING_SCREEN_MAP")
    return map_info


def check_for_input():
    _g.jump = False  # don't string jumps when key is pressed down
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
            if event.key == CONTROL_MENU:
                open_menu(_g.menu)
            if event.key == CONTROL_INFO:
                _g.showinfo = not _g.showinfo
                display_icons()


def play_sound_effect(effect=None, stop=False):
    if stop:
        pygame.mixer.stop()
    if effect:
        pygame.mixer.Sound(effect).play()


def play_intro_animation():
    play_sound_effect(effect="sounds/jump.wav", stop=True)
    for _key in list(range(0, 100)) + list(sorted(glob("artwork/scene/scene_*.png"))):
        check_for_input()
        if _g.jump or _g.start or _g.skip:
            _g.skip = True
            play_sound_effect(stop=True)
            break

        if type(_key) is int:
            # Flash the DK Logo
            _g.screen.blit(get_image("artwork/intro/f%s.png" % (str(_key % 2) if _key <= 40 else "1")), [0, 0])
        else:
            # Show DK climb scene.
            _g.screen.blit(get_image(_key), [0, 0])
            current_scene = int(_key.split("scene_")[1][:4])

            # play sound if required for the current frame
            for scene_number, scene_sound in SCENE_SOUNDS:
                if current_scene == scene_number:
                    play_sound_effect(scene_sound)

            # display nearby icons as girders are broken
            for from_scene, to_scene, below_y, above_y, smash_scene in SCENE_ICONS:
                if from_scene < current_scene < to_scene:
                    display_icons(below_y=below_y, above_y=above_y, smash=current_scene < smash_scene)

            # Change text to show "What game will you play?"
            if 855 < current_scene < 1010:
                write_text(QUESTION, font=dk_font, x=12, y=240, fg=WHITE, bg=BLACK)

            # Title
            write_text(" DK ARCADE ", font=dk_font, x=69, y=0, fg=RED, bg=BLACK)
            write_text(" FRONT END ", font=dk_font, x=69, y=8, fg=WHITE, bg=BLACK)

        update_screen(frame_delay=int(FRAME_DELAY * 2))


def display_icons(detect_only=False, below_y=None, above_y=None, smash=False, no_info=False):
    proximity = None
    # display icons and return icon in proximity to jumpman.  Alternate between looping forwards and reverse.
    for _x, _y, name, sub, desc, emu, state in [_g.icons, reversed(_g.icons)][_g.timer.duration % 3 < 1.5]:
        if _x and _y:
            if not below_y or not above_y or (below_y >= _y >= above_y):
                icon_image = os.path.join("artwork/icon", sub, name + ".png")
                if not os.path.exists(icon_image):
                    icon_image = os.path.join("artwork/icon/default_machine.png")
                if smash:
                    icon_image = f"artwork/sprite/smash{str(randint(0,3))}.png"
                img = get_image(icon_image)
                w, h = img.get_width(), img.get_height()
                if _x < _g.xpos + SPRITE_HALF < _x + w and (_y < _g.ypos + SPRITE_HALF < _y + h):
                    # Pauline to announce the game found near Jumpman.  Return the game launch information.
                    if not int(FREE_PLAY) and _g.score < PLAY_COST and _g.timer.duration % 2 < 1:
                        desc = f'${str(PLAY_COST)} TO PLAY'
                    write_text(desc.upper(), x=108, y=37, fg=WHITE, bg=MAGENTA, bubble=True)
                    proximity = (sub, name, emu, state)
                if _g.showinfo and not no_info:
                    # Show game info above icons
                    write_text(desc, x=_x, y=_y - 6, fg=MAGENTA, bg=WHITE, box=True, rj_adjust=(_x > 180) * w)
                if not detect_only:
                    _g.screen.blit(img, (_x, _y))
    return proximity


def adjust_jumpman():
    # Adjust Jumpman's vertical position with the sloping platform
    map_info = get_map_info("l")
    if "FOOT_UNDER_PLATFORM" in map_info:
        _g.ypos += -1
    elif "FOOT_ABOVE_PLATFORM" in map_info:
        _g.ypos += +1


def animate_jumpman(direction=None, horizontal_movement=1):
    sprite_file = f"artwork/sprite/jm{direction}<I>.png"
    sound_file = None

    map_info = get_map_info(direction)
    if direction in ("l", "r"):
        _g.ready = False
        ladder_info = get_map_info("u") + get_map_info("d")
        if "LADDER_DETECTED" in ladder_info and "END_OF_LADDER" not in ladder_info:
            _g.screen.blit(_g.last_image, (_g.xpos, int(_g.ypos)))
            return 0

        if direction == "l" and "BLOCKED_LEFT" not in map_info:
            _g.facing = 0
            _g.xpos += horizontal_movement * -1
        elif direction == "r" and "BLOCKED_RIGHT" not in map_info:
            _g.facing = 1
            _g.xpos += horizontal_movement
        else:
            _g.screen.blit(_g.last_image, (_g.xpos, int(_g.ypos)))
            return 0

        adjust_jumpman()

        _g.sprite_index += 0.5
        sprite_file = sprite_file.replace("<I>", str(int(_g.sprite_index) % 3))
        for walk in (1, "0"), (5, "1"), (9, "2"):
            if _g.sprite_index % 12 == walk[0]:
                sound_file = f"sounds/walk{walk[1]}.wav"

    if direction in ("u", "d"):
        if "LADDER_DETECTED" in map_info:
            if "END_OF_LADDER" in map_info:
                sprite_file = sprite_file.replace("<I>", "0")
            elif "NEARING_END_OF_LADDER" in map_info:
                sprite_file = sprite_file.replace("<I>", "3")
            elif "APPROACHING_END_OF_LADDER" in map_info:
                sprite_file = sprite_file.replace("<I>", "4")
            else:
                # Slower movement and animation on the ladders
                sprite_file = sprite_file.replace("<I>", ("1", "2")[_g.sprite_index % 10 < 5])
            _g.ypos += (0.5, -0.5)[direction == "u"]

            if int(_g.sprite_index % 9) == 5:
                sound_file = "sounds/walk0.wav"
            _g.sprite_index += 1

        elif direction == "u":
            proximity = display_icons(detect_only=True)
            if proximity:
                # Jumpman is in position to play a game
                sprite_file = sprite_file.replace("<I>", "0")
                _g.ready = True

    if direction == "j":
        # Jumpman is jumping.  Check for landing platform and blocks
        if _g.jumping_seq == 1:
            sound_file = f"sounds/jump.wav"
        if "BLOCKED_LEFT" in map_info or "BLOCKED_RIGHT" in map_info:
            # Jump into a block so drop down
            sprite_file = f'artwork/sprite/jm{("l", "r")[_g.facing]}0.png'
        else:
            sprite_file = sprite_file.replace("<I>", str(_g.facing))
            _g.xpos += _g.right + (_g.left * -1)
        if "FOOT_UNDER_PLATFORM" not in map_info or JUMP_PIXELS[_g.jumping_seq] < 0:
            _g.ypos += JUMP_PIXELS[_g.jumping_seq]

    if "<I>" in sprite_file:
        img = _g.last_image
    else:
        img = get_image(sprite_file)
    _g.screen.blit(img, (_g.xpos, int(_g.ypos)))
    _g.last_image = img
    play_sound_effect(sound_file)


def build_menus():
    _g.menu = pymenu.Menu(GRAPHICS[1], GRAPHICS[0], QUESTION, mouse_visible=False, mouse_enabled=False,
                          theme=dkafe_theme, onclose=close_menu)
    _g.menu.add_vertical_margin(5)
    for name, sub, desc, icx, icy, emu, state in read_romlist():
        _g.icons.append((int(icx), int(icy), name, sub, desc, emu, state))
        _g.menu.add_button(desc, launch_rom, (sub, name, emu, state))
    _g.menu.add_button('Close Menu', close_menu)
    _g.exitmenu = pymenu.Menu(70, 200, "Really want to leave ?", mouse_visible=False, mouse_enabled=False,
                              theme=dkafe_theme, onclose=close_menu)
    _g.exitmenu.add_button('Take me back', close_menu)
    _g.exitmenu.add_button('Exit', exit_program)


def open_menu(menu):
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


def read_romlist():
    # read romlist and return info about available roms (and shell scripts)
    romlist = []
    if os.path.exists("romlist.txt"):
        with open("romlist.txt", "r") as rl:
            for rom_line in rl.readlines()[1:]:  # ignore the first/header line
                if rom_line.count("|") == 7:
                    name, subfolder, desc, icx, icy, emu, state, *_ = [x.strip() for x in rom_line.split("|")]
                    if name and desc and icx and icy:
                        target = name + (".sh", ".bat")[_s.is_windows()] if subfolder == "shell" else name + ".zip"
                        if os.path.exists(os.path.join((ROM_DIR, ROOT_DIR)[subfolder == "shell"], subfolder, target)):
                            romlist.append((name, subfolder, desc, int(icx), int(icy), int(emu), state))
    return romlist


def launch_rom(info):
    # Receives subfolder (optional), name, emulator and rom state from info
    # A homebew emulator is preferred for rom hacks but a good alternative is to provide a subfolder which holds a
    # variant of the main rom e.g. roms/skipstart/dkong.zip is a variant of roms/dkong.zip.  If mame emulator supports
    # rompath then the rom can be launched direct from the subfolder otherwise the file will be copied over the main
    # rom to avoid a CRC check fail.
    if not info:
        return
    subfolder, name, emu, state = info
    emu_command = f'{(EMU_1, EMU_2, EMU_3)[emu - 1]}'.replace("<NAME>", name).replace("<DATETIME>", _s.get_datetime())
    shell_command = f'{emu_command} {name}'
    if subfolder:
        if subfolder == "shell":     # Launch shell script / batch file
            shell_command = os.path.join(ROOT_DIR, "shell", name + (".sh", ".bat")[_s.is_windows()])
        elif "-rompath" in emu_command:  # Launch rom and provide rom path
            shell_command = f'{emu_command}{os.sep}{subfolder} {name}'
        else:                        # Copy rom from subfolder to the fixed rom path
            rom_source = os.path.join(ROM_DIR, subfolder, name + ".zip")
            rom_target = os.path.join(ROM_DIR, name + ".zip")
            if os.path.exists(rom_source):
                copy(rom_source, rom_target)
    if state:
        shell_command += f' -state {state.strip()}'

    _g.menu.disable()  # Close menu if open

    if int(FREE_PLAY) or _g.score >= PLAY_COST:
        music_channel.pause()
        intermission_channel.stop()
        _g.score = _g.score - (PLAY_COST, 0)[int(FREE_PLAY)]
        play_sound_effect("sounds/coin.wav")

        clear_screen()
        _g.timer.stop()  # Stop the timer while playing rom
        if "-record" in shell_command:
            flash_message("R E C O R D I N G", x=40, y=120)  # Gameplay recording (i.e. Wolfmame)
        os.system(shell_command)
        _g.timer.start()  # Restart the timer
    else:
        play_sound_effect("sounds/error.wav")
        flash_message("YOU DON'T HAVE ENOUGH COINS !!", x=4, y=120)

    # Redraw the screen
    clear_screen(and_reset_display=True)
    update_screen()
    music_channel.unpause()
    os.chdir(ROOT_DIR)
    _g.skip = True


def process_interrupts():
    ticks = pygame.time.get_ticks()
    event = None

    # Start up messages from Pauline
    if not _g.lastmove:
        message = (COIN_INFO, FREE_INFO)[int(FREE_PLAY)]
        write_text(message[int(_g.timer.duration) % len(message)], x=108, y=37, fg=WHITE, bg=MAGENTA, bubble=True)

    # Flashing 1UP and score
    write_text("1UP", font=dk_font, x=25, y=0, fg=(BLACK, RED)[ticks % 700 < 350], bg=None)
    write_text(str(_g.score).zfill(6), font=dk_font, x=9, y=8, fg=WHITE, bg=BLACK)

    # Bonus timer - starts above 5000 so we see the 5000 bonus for a time
    bonus_timer = TIMER_START + 100 - (_g.timer.duration * 50)
    bonus_display = str(int(bonus_timer)).rjust(4)[:2] + "00"

    bonus_colour = CYAN
    if bonus_timer < 1000:
        bonus_colour = MAGENTA
        if not _g.countdown:    # Start warning timer and play countdown music loop
            _g.countdown = True
            music_channel.play(pygame.mixer.Sound('sounds/countdown.wav'), -1)
    if bonus_timer <= 100:
        bonus_display = " 000"
    if bonus_timer <= -200:
        _g.countdown = False
        music_channel.stop()
        play_sound_effect("sounds/timeup.wav")

        # Out of time animation
        for repeat in range(0, 3):
            for i in range(0, 6):
                if i <= 3 or repeat == 2:
                    backimg = get_image(f"artwork/background.png")
                    _g.screen.blit(backimg, (_g.xpos, int(_g.ypos)), (_g.xpos, int(_g.ypos), 16, 16))

                    img = get_image(f"artwork/sprite/out{int(i)}.png")
                    _g.screen.blit(img, (_g.xpos, int(_g.ypos)))

                    # Display items that don't get updated in this loop
                    write_text("1UP", font=dk_font, x=25, y=0, fg=RED, bg=None)
                    write_text(" 000", font=dk_font, x=177, y=48, fg=bonus_colour, bg=None)
                    img = get_image("artwork/sprite/dk0.png")
                    _g.screen.blit(img, (11, 52))
                    update_screen(FRAME_DELAY * 3)
        pygame.time.delay(1500)

        # Set out of time event and restart the regular background music loop
        event = "OUTOFTIME"
        music_channel.play(pygame.mixer.Sound('sounds/background.wav'), -1)

    write_text(bonus_display, font=dk_font, x=177, y=48, fg=bonus_colour, bg=None)

    # animated DK,  sometimes DK will grab a coin
    prefix = ("dk", "dkg")[_g.grab]
    if _g.grab and _g.cointype == 0:
        # Determine next coin to be grabbed by DK. Higher value coins are released less frequenly
        _g.cointype = int(randint(1, 3) == 1) + 1

    for i, mod in enumerate((500, 1000, 1500)):
        if ticks % 5000 < mod:
            img = get_image(f"artwork/sprite/{prefix}{str(i + 1)}.png")
            _g.screen.blit(img, (11, 52))
            if _g.grab:
                coin_img = get_image(f"artwork/sprite/coin{_g.cointype}3.png")
                _g.screen.blit(coin_img, ((12, 38, 64)[i], 74))
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
        img = get_image(f"artwork/sprite/{prefix}0.png")
        _g.screen.blit(img, (11, 52))

    # Animate rolling coins
    for i, coin in enumerate(_g.coins):
        co_x, co_y, co_id, co_dir, co_ladder, co_type = coin
        img = get_image(f"artwork/sprite/coin{str(co_type)}{str(int(co_id % 4))}.png")
        _g.screen.blit(img, (int(co_x), int(co_y)))

        if (co_x - SPRITE_HALF <= _g.xpos < co_x + SPRITE_HALF) and (co_y >= _g.ypos > co_y - SPRITE_HALF):
            # Jumpman collected the coin
            _g.score += COIN_VALUES[co_type]
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
                co_dir = co_dir * -1  # Flip horizontal movement
            co_y += COIN_SPEED
        else:
            co_x += co_dir * COIN_SPEED  # Increment horizontal movement

        co_id += co_dir * COIN_CYCLE
        _g.coins[i] = co_x, co_y, co_id, co_dir, co_ladder, co_type  # Update coin data

    # Purge coins
    _g.coins = [i for i in _g.coins if i[0] > -10]
    return event


def check_for_inactivity():
    if _g.timer.duration - _g.lastmove > INACTIVE_TIME:
        if ((pygame.time.get_ticks() - _g.pause_ticks) % 25000) < 3000:
            _g.screen.blit(get_image(f"artwork/intro/f{randint(0,1)}.png"), [0, 0])
        else:
            lines = (INSTRUCTION, CONTROLS)[(pygame.time.get_ticks() - _g.pause_ticks) % 25000 > 14000]
            for i, line in enumerate(lines.split("\n")):
                write_text(line+(" "*28), x=0, y=20 + (i * 8), fg=CYAN, bg=BLACK, font=dk_font)
        write_text("1UP", font=dk_font, x=25, y=0, fg=(BLACK, RED)[pygame.time.get_ticks() % 700 < 350], bg=None)
        write_text(str(_g.score).zfill(6), font=dk_font, x=9, y=8, fg=WHITE, bg=BLACK)
        if _g.active:
            _g.timer.stop()
            _g.pause_ticks = pygame.time.get_ticks()
            pygame.mixer.pause()
        _g.active = False


def check_for_activity():
    if _g.active:
        _g.timer.start()
        pygame.mixer.unpause()

        event = process_interrupts()
        if event == "OUTOFTIME":
            _g.coins = []             # Reset the coins
            _g.timer.reset()          # Reset the bonus timer
        display_icons(detect_only=True)


def main():
    pygame.display.set_caption(TITLE)
    initialise_screen()

    # launch front end
    build_menus()
    play_intro_animation()

    # Start background music
    music_channel.play(pygame.mixer.Sound('sounds/background.wav'), -1)

    # Build the screen with icons to use as background
    _g.screen.blit(get_image("artwork/background.png"), [0, 0])
    display_icons(no_info=True)
    _g.screen_icons = _g.screen.copy()

    # Initialise Jumpman
    animate_jumpman("r")
    _g.lastmove = 0
    _g.timer.reset()

    # loop the game
    while True:
        if _g.active:
            _g.screen.blit(_g.screen_icons, (0, 0))

        if _g.jumping:
            animate_jumpman("j")
        else:
            check_for_input()
            for direction in (_g.right, "r"), (_g.left, "l"), (_g.up, "u"), (_g.down, "d"), (True, ""):
                if direction[0]:
                    animate_jumpman(direction[1])
                    break

        if (_g.jump or _g.start) and _g.ready:
            launch_rom(display_icons(detect_only=True))
        elif (_g.jump and _g.timer.duration > 0.25) or _g.jumping:
            # Jumpman has started a jump or is actively jumping
            ladder_info = get_map_info(direction="d") + get_map_info(direction="u")
            if not(_g.jumping_seq == 0 and "LADDER_DETECTED" in ladder_info and "END_OF_LADDER" not in ladder_info):
                _g.jumping = True
                _g.jumping_seq += 1
                if _g.jumping_seq >= len(JUMP_PIXELS):
                    _g.jumping = False
                    _g.jumping_seq, _g.sprite_index = 0, 0
                    animate_jumpman(("l", "r")[_g.facing], horizontal_movement=0)

        check_for_inactivity()
        check_for_activity()
        update_screen(FRAME_DELAY)


if __name__ == "__main__":
    main()
