import sys
import glob
import shutil
import dk_global as _g
import dk_system as _s
from dk_config import *
from random import randint


def update_screen(frame_delay=0):
    pygame.display.update()
    pygame.time.delay(frame_delay)
    clock.tick(CLOCK_RATE)


def clear_screen(frame_delay=0, colour=BLACK, and_quit_program=False, and_reset_display=False):
    from dk_config import screen as _screen
    pygame.mouse.set_visible(False)
    _screen.fill(colour)
    update_screen(frame_delay)
    if and_reset_display:
        _screen = pygame.display.set_mode(TARGET_SIZE, flags=pygame.FULLSCREEN | pygame.SCALED)
    if and_quit_program:
        pygame.quit()
        sys.exit()


def write_text(text=None, font=pl_font, x=0, y=0, fg=WHITE, bg=None, bubble=False, box=False, rj=False):
    # Write text to screen at given position using fg and bg colour (None for transparent)
    if text:
        img = font.render(text, False, fg, bg)
        w, h = img.get_width(), img.get_height()
        _x = x - ((w - 12) * rj)  # align x left or right
        screen.blit(img, (_x, y))

        if box or bubble:
            pygame.draw.rect(screen, fg, (_x - 1, y - 1, w + 2, h + 1), 1)
            if bubble:
                # make box into a speech bubble
                for point in ((_x - 1, y - 1), (_x + w, y - 1), (_x - 1, y + h - 1), (_x + w, y + h - 1)):
                    screen.set_at(point, BLACK)
                pygame.draw.polygon(screen, bg, [(_x - 1, y + 2), (_x - 6, y + 3), (_x - 1, y + 4)])
                pygame.draw.lines(screen, fg, False, [(_x - 1, y + 2), (_x - 6, y + 3), (_x - 1, y + 4)], 1)


def check_for_input():
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            clear_screen(and_quit_program=True)

        if event.type == pygame.KEYDOWN:
            _g.active = True
            _g.lastmove = _g.timer.duration

            if event.key == CONTROL_EXIT:
                clear_screen(and_quit_program=True)
            if event.key == CONTROL_P2_START:
                open_menu()
                _g.left, _g.right, _g.up, _g.down, _g.jump, _g.start = (False,) * 6
            if event.key == CONTROL_COIN:
                _g.showinfo = not _g.showinfo
                display_icons()
            _g.jump = True if event.key == CONTROL_JUMP else _g.jump
            _g.start = True if event.key == CONTROL_P1_START else _g.start
            _g.left = True if event.key == CONTROL_LEFT else _g.left
            _g.right = True if event.key == CONTROL_RIGHT else _g.right
            _g.up = True if event.key == CONTROL_UP else _g.up
            _g.down = True if event.key == CONTROL_DOWN else _g.down

        if event.type == pygame.KEYUP:
            _g.jump = False if event.key == CONTROL_JUMP else _g.jump
            _g.start = False if event.key == CONTROL_P1_START else _g.start
            _g.left = False if event.key == CONTROL_LEFT else _g.left
            _g.right = False if event.key == CONTROL_RIGHT else _g.right
            _g.up = False if event.key == CONTROL_UP else _g.up
            _g.down = False if event.key == CONTROL_DOWN else _g.down


def play_sound_effect(effect=None, stop=False):
    if stop:
        pygame.mixer.stop()
    if effect:
        pygame.mixer.Sound(effect).play()


def intro_screen():
    screen.blit(pygame.image.load("artwork/intro/launch.png").convert(), [0, 0])
    update_screen(500)
    play_sound_effect(effect="sounds/jump.wav", stop=True)

    # Flash the DK Logo
    for i in range(0, 100): 
        check_for_input()
        if _g.start or _g.jump or _g.skip:
            _g.skip = True
            play_sound_effect(stop=True)
            break
        screen.blit(pygame.image.load("artwork/intro/f%s.png" % (str(i % 2) if i <= 40 else "1")).convert(), [0, 0])
        update_screen(40)


def climb_animation():
    # Animate DK climb scene.
    for png_file in sorted(glob.glob("artwork/scene/scene_*.png")):
        scene = int(png_file.split("scene_")[1][:4])
        check_for_input()
        if _g.start or _g.jump or _g.skip:
            _g.skip = True
            play_sound_effect(stop=True)
            break

        # display the current frame
        frame = pygame.image.load(png_file).convert()
        screen.blit(frame, [0, 0])

        # play sound if required for frame
        for scene_id, scene_sound in SCENE_SOUNDS:
            if scene == scene_id:
                play_sound_effect(scene_sound)

        # display icons as girders are broken
        for from_scene, to_scene, below, above, smash_scene in SCENE_ICONS:
            if from_scene < scene < to_scene:
                display_icons(below_ypos=below, above_ypos=above, smash=scene < smash_scene)

        # What game will you play scenes
        if 855 < scene < 1010:
            write_text("WHAT GAME WILL YOU PLAY ?", font=dk_font, x=12, y=240, fg=WHITE, bg=BLACK)

        # Title
        write_text(" DK ARCADE ", font=dk_font, x=69, y=0, fg=RED, bg=BLACK)
        write_text(" FRONT END ", font=dk_font, x=69, y=8, fg=WHITE, bg=BLACK)

        update_screen(40 * (scene <= 1009))
    return


def read_map(x, y):
    # Return R colour value from pixel at provided x, y position on the screen map
    return screenmap.get_at((x, y))[0]


def get_map_info(direction=None, x=None, y=None, x_offset=None, y_offset=None):
    # Return information from map e.g. ladders and obstacles preventing movement in intended direction
    map_info = []
    if not x and not y and not x_offset and not y_offset:
        # Assume defaults when parameters are not provided
        x, y, x_offset, y_offset = _g.xpos, int(_g.ypos), 8, 15
    try:
        # Check for blocks on the screen map
        if read_map(x - 1, y + y_offset) == 254 or _g.xpos < 2:
            map_info.append("BLOCKED_LEFT")
        if read_map(x + x_offset * 2, y + y_offset) == 254 or _g.xpos > 206:
            map_info.append("BLOCKED_RIGHT")
        if read_map(x + x_offset, y + y_offset) == 236:
            map_info.append("FOOT_UNDER_PLATFORM")
        if read_map(x + x_offset, y + y_offset + 1) == 0:
            map_info.append("FOOT_ABOVE_PLATFORM")

        # ladder detection based on direction of travel
        _r = read_map(x + x_offset - 1, y + y_offset + (direction == "d"))
        for zone in LADDER_ZONES:
            if _r in zone[1]:
                map_info.append(zone[0])
    except IndexError:
        map_info.append("ERROR_READING_SCREEN_MAP")
    return map_info


def display_icons(detect_only=False, below_ypos=None, above_ypos=None, smash=False, no_info=False):
    proximity = None
    # display icons and return icon in proximity to jumpman.  Alternate between looping forwards and reverse.
    for icx, icy, name, sub, desc, emu, load in [_g.icons, reversed(_g.icons)][_g.timer.duration % 3 < 1.5]:
        if icx and icy:
            if not below_ypos or not above_ypos or (below_ypos >= icy >= above_ypos):
                icon_image = os.path.join("artwork/icon", sub, name + ".png")
                if not os.path.exists(icon_image):
                    icon_image = os.path.join("artwork/icon/default_machine.png")
                if smash:
                    icon_image = f"artwork/sprite/smash{str(randint(0,3))}.png"
                img = pygame.image.load(icon_image).convert_alpha()
                w, h = img.get_width(), img.get_height()
                if (icx < _g.xpos + 9 < icx + w) and (int(_g.ypos) + 8 > icy and int(_g.ypos) + 9 < icy + h):
                    # Pauline to announce the game found near Jumpman.  Return the game launch information.
                    if not int(FREE_PLAY) and _g.score < PLAY_COST and _g.timer.duration % 2 < 1:
                        write_text(f' ${str(PLAY_COST)} TO PLAY ', x=108, y=37, fg=WHITE, bg=MAGENTA, bubble=True)
                    else:
                        write_text(f' {desc.upper()} ', x=108, y=37, fg=WHITE, bg=MAGENTA, bubble=True)
                    proximity = (sub, name, emu, load)
                if _g.showinfo and not no_info:
                    # Show game info above icons
                    write_text(desc, x=icx, y=icy - 6, fg=MAGENTA, bg=WHITE, box=True, rj=icx > 180)
                if not detect_only:
                    screen.blit(img, (icx, icy))
    return proximity


def animate_jumpman(direction=None, reset=False):
    sprite_file = f"artwork/sprite/jm{direction}<I>.png"
    sound_file = None

    map_info = get_map_info(direction)
    if direction in ("l", "r") and not reset:
        _g.ready = False
        if "LADDER_DETECTED" in map_info and "END_OF_LADDER" not in map_info:
            screen.blit(_g.last_img, (_g.xpos, int(_g.ypos)))
            return 0

        if direction == "l" and "BLOCKED_LEFT" not in map_info:
            _g.facing = 0
            _g.xpos += -1
        elif direction == "r" and "BLOCKED_RIGHT" not in map_info:
            _g.facing = 1
            _g.xpos += 1
        else:
            screen.blit(_g.last_img, (_g.xpos, int(_g.ypos)))
            return 0

    # Adjust jumpmans vertical position with the sloping platform
    if direction in ("l", "r"):
        if "FOOT_UNDER_PLATFORM" in map_info:
            _g.ypos += -1
        elif "FOOT_ABOVE_PLATFORM" in map_info:
            _g.ypos += +1

        _g.sprite_index += 0.5
        # update jumpman walking sprites and sounds
        if reset:
            sprite_file = sprite_file.replace("<I>", "0")
        else:
            sprite_file = sprite_file.replace("<I>", str(int(_g.sprite_index) % 3))
        for walk in (1, "0"), (5, "1"), (9, "2"):
            if _g.sprite_index % 12 == walk[0]:
                sound_file = f"sounds/walk{walk[1]}.wav"

    if direction in ("u", "d"):
        if "LADDER_DETECTED" in map_info:
            if "END_OF_LADDER" in map_info:
                sprite_file = sprite_file.replace("<I>", "0")
                _g.halfstep = True
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
        if "BLOCKED_LEFT" not in map_info and "BLOCKED_RIGHT" not in map_info and "FOOT_UNDER_PLATFORM" not in map_info:
            if _g.jumping_seq == 1:
                sound_file = f"sounds/jump.wav"
            sprite_file = sprite_file.replace("<I>", str(_g.facing))
            _g.xpos += (_g.right * 1) + (_g.left * -1)
        _g.ypos += JUMP_PIXELS[_g.jumping_seq]

    if "<I>" not in sprite_file:
        img = pygame.image.load(sprite_file).convert_alpha()
    else:
        img = _g.last_img
    screen.blit(img, (_g.xpos, int(_g.ypos)))
    _g.last_img = img

    if sound_file:
        play_sound_effect(sound_file)


def build_menu():
    _g.menu = pygame_menu.Menu(TARGET_SIZE[1]-2, TARGET_SIZE[0]-2, 'SELECT A GAME', mouse_visible=False,
                               mouse_enabled=False, menu_position=(2, 2), theme=dkafe_theme, onclose=close_menu)
    for name, sub, desc, icx, icy, emu, load in read_romlist():
        _g.icons.append((int(icx), int(icy), name, sub, desc, emu, load))
        _g.menu.add_button(desc, launch_rom, (sub, name, emu, load))
    _g.menu.add_button('Close Menu', close_menu)


def open_menu():
    _g.screenshot = screen.copy()
    pygame.mixer.pause()
    _g.menu.enable()
    _g.menu.mainloop(screen)
    pygame.event.clear()


def close_menu():
    _g.menu.disable()
    screen.blit(_g.screenshot, [0, 0])
    update_screen()
    pygame.mouse.set_visible(False)
    _g.active = True
    _g.lastmove = _g.timer.duration


def launch_rom(info):
    # Receives subfolder (optional), name, emulator and load state
    # A homebew emulator is preferred for rom hacks but a good alternative is to provide a subfolder which holds a
    # variant of the main rom e.g. roms/skipstart/dkong.zip is a variant of roms/dkong.zip.  If mame emulator supports
    # rompath then the rom can be launched direct from the subfolder otherwise the file will be copied over the main
    # rom to avoid CRC fail.
    subfolder, name, emu, load = info
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
                shutil.copy(rom_source, rom_target)
    if load:
        shell_command += f' -state {load.strip()}'

    _g.menu.disable()                      # Close menu if open
    _g.screenshot = screen.copy()

    if int(FREE_PLAY) or _g.score >= PLAY_COST:
        music_channel.pause()
        _g.score = _g.score - (PLAY_COST, 0)[int(FREE_PLAY)]
        play_sound_effect("sounds/coin.wav")
        clear_screen()

        # Pause timer. Show "recording" message if emulator is recording gameplay (i.e. Wolfmame)
        _g.timer.stop()
        if "-record" in shell_command:
            for i in ([0, 1] * 17):
                write_text("R E C O R D I N G", font=dk_font, x=40, y=120, fg=(BLACK, RED)[i], bg=None)
                update_screen(40)
        clear_screen()

        # Launch the rom
        os.system(shell_command)
        _g.timer.start()
    else:
        for i in ([0, 1] * 12):
            clear_screen()
            write_text("YOU DON'T HAVE ENOUGH COINS !!", font=dk_font, x=4, y=120, bg=BLACK, fg=(BLACK, RED)[i])
            update_screen(40)

    # Redraw the screen
    clear_screen(and_reset_display=True)
    screen.blit(_g.screenshot, [0, 0])
    update_screen()
    music_channel.unpause()

    os.chdir(ROOT_DIR)
    _g.skip = True


def read_romlist():
    # read romlist and return info about available roms (and shell scripts)
    romlist = []
    if os.path.exists("romlist.txt"):
        with open("romlist.txt", "r") as rl:
            for rom_line in rl.readlines()[1:]:  # ignore the first/header line
                if rom_line.count("|") == 7:
                    name, subfolder, desc, icx, icy, emu, load, *_ = [x.strip() for x in rom_line.split("|")]
                    if name and desc and icx and icy:
                        target = name + (".sh", ".bat")[_s.is_windows()] if subfolder == "shell" else name + ".zip"
                        if os.path.exists(os.path.join((ROM_DIR, ROOT_DIR)[subfolder == "shell"], subfolder, target)):
                            romlist.append((name, subfolder, desc, int(icx), int(icy), int(emu), load))
    return romlist


def graphic_interrupts():
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
    bonus_display = str(int(bonus_timer)).rjust(4)[:2] + "00"      # rightmost 2 digits set as zero

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
                    backimg = pygame.image.load(f"artwork/background.png").convert_alpha()
                    screen.blit(backimg, (_g.xpos, int(_g.ypos)), (_g.xpos, int(_g.ypos), 16, 16))
                    
                    img = pygame.image.load(f"artwork/sprite/out{int(i)}.png").convert_alpha()
                    screen.blit(img, (_g.xpos, int(_g.ypos)))
                
                    # Display items that don't get updated in this loop
                    write_text("1UP", font=dk_font, x=25, y=0, fg=RED, bg=None)
                    write_text(" 000", font=dk_font, x=177, y=48, fg=bonus_colour, bg=None)
                    img = pygame.image.load("artwork/sprite/dk0.png").convert_alpha()
                    screen.blit(img, (11, 52))
                    update_screen(120)
        pygame.time.delay(1500)
        
        # Set out of time event and restart the regular background music loop
        event = "OUTOFTIME"
        music_channel.play(pygame.mixer.Sound('sounds/background.wav'), -1)
        
    write_text(bonus_display, font=dk_font, x=177, y=48, fg=bonus_colour, bg=None)

    # animated DK,  sometimes DK will grab a coin
    prefix = ("dk", "dkg")[_g.grab]
    if _g.grab and _g.cointype == 0:
        # Determine next coin to be grabbed by DK. Higher value coins are released less frequenly
        _g.cointype = (randint(0, 1) * randint(0, 1) * randint(0, 1)) + 1

    for i, mod in enumerate((500, 1000, 1500)):
        if ticks % 5000 < mod:
            img = pygame.image.load(f"artwork/sprite/{prefix}{str(i + 1)}.png").convert_alpha()
            screen.blit(img, (11, 52))
            if _g.grab:
                coin_img = pygame.image.load(f"artwork/sprite/coin{_g.cointype}3.png").convert_alpha()
                screen.blit(coin_img, ((12, 38, 64)[i], 74))
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
        # Default DK sprite
        img = pygame.image.load(f"artwork/sprite/{prefix}0.png").convert_alpha()
        screen.blit(img, (11, 52))

    # Animate rolling coins
    for i, coin in enumerate(_g.coins):
        coinx, coiny, coinid, coindir, use_ladder, cointype = coin
        img = pygame.image.load(f"artwork/sprite/coin{str(cointype)}{str(int(coinid % 4))}.png").convert_alpha()
        screen.blit(img, (int(coinx), int(coiny)))

        if (coinx - 8 <= _g.xpos < coinx + 8) and (coiny >= _g.ypos > coiny - 10):
            _g.score += COIN_VALUES[cointype]  # Jumpman collected the coin
            play_sound_effect("sounds/getitem.wav")
            coinx = -999

        map_info = get_map_info(direction="d", x=int(coinx), y=int(coiny), x_offset=(7, 3)[coindir == 1], y_offset=9)

        # Toggle ladders.  Virtual ladders are always active.
        if "APPROACHING_LADDER" in map_info:
            use_ladder = not randint(1, LADDER_CHANCE) == 1
        elif "VIRTUAL_LADDER" not in map_info and "FOOT_ABOVE_PLATFORM" not in map_info and use_ladder:
            map_info = []

        # Move the coin along the platform and down ladders
        if "FOOT_ABOVE_PLATFORM" in map_info:
            coiny += 1  # coin moves down the sloped girder to touch the platform
        elif "LADDER_DETECTED" in map_info or "BROKEN_LADDER" in map_info or "VIRTUAL_LADDER" in map_info:
            if "TOP_OF_LADDER" in map_info or "TOP_OF_BROKEN_LADDER" in map_info or "TOP_OF_VIRTUAL_LADDER" in map_info:
                coindir = coindir * -1  # Flip the horizontal movement direction
            coiny += COIN_SPEED
        else:
            coinx += coindir * COIN_SPEED  # Increment the horizontal movement

        coinid += coindir * COIN_CYCLE
        _g.coins[i] = coinx, coiny, coinid, coindir, use_ladder, cointype  # Update coin data

    # Purge coins
    _g.coins = [i for i in _g.coins if i[0] > -10]
    return event


def main():
    pygame.display.set_caption('DONKEY KONG ARCADE FE')

    # launch front end
    build_menu()
    intro_screen()
    climb_animation()
    
    # Start background music
    music_channel.play(pygame.mixer.Sound('sounds/background.wav'), -1)
    music_channel.set_volume(1.5)
        
    # loop the game
    _g.timer.reset()

    # Build the screen with icons to use as background
    screen.blit(background_image, [0, 0])
    display_icons(no_info=True)
    _g.screen_with_icons = screen.copy()

    animate_jumpman("r")
    _g.lastmove = 0

    while True:
        if _g.active:
            screen.blit(_g.screen_with_icons, (0, 0))

        if _g.jumping:
            animate_jumpman("j")
        else:
            check_for_input()
            for direction in (_g.right, "r"), (_g.left, "l"), (_g.up, "u"), (_g.down, "d"), (True, ""):
                if direction[0]:
                    animate_jumpman(direction[1])
                    break

        if (_g.jump or _g.start) and _g.ready:
            proximity = display_icons(detect_only=True)
            if proximity:
                launch_rom(proximity)
            animate_jumpman()
        elif (_g.jump and _g.timer.duration > 0.25) or _g.jumping:    # Jumpman not to jump when screen starts
            _g.jumping = True
            _g.jumping_seq += 1
            if _g.jumping_seq >= len(JUMP_PIXELS):
                _g.jumping = False
                _g.jumping_seq = 0
                for _ in (0, 1):
                    animate_jumpman(("l", "r")[_g.facing], reset=True)

        # Check for inactivity
        if _g.timer.duration - _g.lastmove > INACTIVE_TIME:
            if ((pygame.time.get_ticks() - _g.pause_ticks) % 25000) < 3000:
                screen.blit(pygame.image.load(f"artwork/intro/f{randint(0,1)}.png").convert(), [0, 0])
            else:
                lines = (INSTRUCTION, CONTROLS)[(pygame.time.get_ticks() - _g.pause_ticks) % 25000 > 14000]
                for i, line in enumerate(lines.split("\n")):
                    write_text(line+(" "*28), x=0, y=20 + (i * 9), fg=CYAN, bg=BLACK, font=dk_font)
            write_text("1UP", font=dk_font, x=25, y=0, fg=(BLACK, RED)[pygame.time.get_ticks() % 700 < 350], bg=None)
            write_text(str(_g.score).zfill(6), font=dk_font, x=9, y=8, fg=WHITE, bg=BLACK)
            if _g.active:
                _g.timer.stop()
                _g.pause_ticks = pygame.time.get_ticks()
                pygame.mixer.pause()
            _g.active = False

        if _g.active:
            _g.timer.start()
            pygame.mixer.unpause()

            event = graphic_interrupts()
            if event == "OUTOFTIME":
                _g.coins = []             # Reset the coins
                _g.timer.reset()          # Reset the bonus timer
            display_icons(detect_only=True)

        update_screen(FRAME_DELAY)


if __name__ == "__main__":
    main()
