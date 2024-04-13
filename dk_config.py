"""
ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
 888    88o  888  o88        888       888          888
 888    888  888888         8  88      888ooo8      888ooo8
 888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
                                        by Jon Wilson (10yard)

Configuration options
---------------------
"""
import os
os.environ['PYGAME_HIDE_SUPPORT_PROMPT'] = '1'
import sys
import pygame
import pygame_menu as pymenu

# Graphic Config
TITLE = 'DKAFE'
DISPLAY = (224, 256)           # Internal x, y resolution of game graphics
TOPLEFT = (0, 0)               # Position of top left corner
ROTATION = 0                   # Frontend rotation (0, 90, 180, 270).   Rotates the primary display only.
CLOCK_RATE = 45                # Clock rate
SPEED_ADJUST = 0               # Adjustment to above clock rate (e.g. 0=45, 1=50, +2=55, +3=60, +4=65, +5=70, +6=75)

# Default Keyboard Controls
CONTROL_LEFT = pygame.K_LEFT
CONTROL_RIGHT = pygame.K_RIGHT
CONTROL_UP = pygame.K_UP
CONTROL_DOWN = pygame.K_DOWN
CONTROL_JUMP = pygame.K_LCTRL
CONTROL_ACTION = pygame.K_LALT
CONTROL_P1 = pygame.K_1
CONTROL_P2 = pygame.K_2
CONTROL_COIN = pygame.K_5
CONTROL_EXIT = pygame.K_ESCAPE
CONTROL_TAB = pygame.K_TAB
CONTROL_SNAP = pygame.K_F12
CONTROL_PLAYLIST = pygame.K_p
CONTROL_SKIP = pygame.K_s
CONTROL_PAGEUP = pygame.K_PAGEUP
CONTROL_PAGEDOWN = pygame.K_PAGEDOWN

# Joystick Options and Button Assignments
USE_JOYSTICK = 0
# Note: DPAD and first analog axis are automatically mapped to directions
# Device 1 buttons start from 0,  Device 2 buttons start from 20
BUTTON_JUMP = 0
BUTTON_ACTION = 1
BUTTON_P1 = 9
BUTTON_P2 = 29
BUTTON_EXIT = 3
BUTTON_COIN = 7

# Options
CONFIRM_EXIT = 1
FULLSCREEN = 1
FREE_PLAY = 1                  # Jumpman does not have to pay to play
UNLOCK_MODE = 1                # Arcade machines are unlocked as Jumpman's score increases
SKILL_LEVEL = 1                # How difficult are the target scores. 1 (Beginner) to 10 (Expert).
START_STAGE = 0                # Stage to start the frontend on. 0 (Barrels), 1 (Rivets), 2 (Pies)
ENABLE_MENU = 1                # Allow selection from the quick access game list
ENABLE_ADDONS = 1              # Enable add-on packs.  Set to 0 to disable previously installed add-ons.
INACTIVE_TIME = 20             # Screensaver with game instructions after period in seconds of inactivity. Integer
SHOW_SPLASHSCREEN = 1          # Show the DKAFE splash screen and animation on startup
SHOW_GAMETEXT = 1              # Show the game text description when Jumpman faces an arcade machine
ENABLE_HAMMERS = 1             # Show hammers and enable teleport between hammers in the frontend
ENABLE_SHUTDOWN = 0            # Allow system shutdown from menu
ENABLE_PLAYLIST = 1            # Play background music from playlist folder
PLAYLIST_VOLUME = 5            # Volume of playlist music from 0 to 10

# DKWolf/Interface options
HIGH_SCORE_SAVE = 1            # Retain high scores (they are specific to each hack)
CREDITS = 1                    # Automatically set credits in MAME at start of game - when using interface
AUTOSTART = 1                  # Automatically start the game in MAME (by simulating P1 start) when using interface
ALLOW_SKIP_INTRO = 1           # Allow the DK climb scene to be quickly skipped in game by pressing Jump button
SHOW_AWARD_PROGRESS = 1        # Show award progress when playing game (appears top of screen replacing high score)
SHOW_AWARD_TARGETS = 1         # Show award targets when playing game (appears during the DK intro/climb scene)
SHOW_HUD = 1                   # Show in game HUD by default (in top right corner) and use P2 to toggle data
REFOCUS_WINDOW = 0             # Attempt to refocus DKAFE window after exiting LUA interface (Windows Only)

# Basic mode switch overrides some settings
BASIC_MODE = 0                 # Equivalent to FREE_PLAY = 1, UNLOCK_MODE = 0 and all interface options disabled

# Additional options
AWARDS = 500, 1500, 2500       # Coins awarded for reaching score target for 3rd, 2nd, 1st when competing
PLAY_COST = 100                # How much it costs to play an arcade machine
LIFE_COST = 150                # How many coins Jumpman drops when time runs out
SCORE_START = 500              # How many coins Jumpman starts with
TIMER_START = 8000             # Timer starts countdown from this number
COIN_VALUES = 0, 50, 100       # How many points awarded for collecting a coin. Integer
COIN_FREQUENCY = 3             # How frequently DK will grab a coin (1 = always, 2 = 1/2,  3 = 1/3 etc.)
COIN_HIGH = 4                  # Frequency of coin being higher value (1 = always, 2 = 1/2,  3 = 1/3 etc.)
COIN_SPEED = 1.6               # Number of pixels to move coin per display update. Decimal
COIN_CYCLE = 0.15              # How often the coin sprite is updated. Decimal
INP_FAVOURITE = 10             # Flag .inp recordings of this duration or greater (in minutes) by prefixing with ♥

# Root directory of frontend
ROOT_DIR = os.getcwd()

# Emulator and rom path defaults
ROM_DIR = '<ROOT>/roms'
OPTIONS = '-rompath "<ROM_DIR>" -view "Pixel Aspect (7:8)"'
EMU_1 = '<ROOT>/dkwolf/dkwolf <OPTIONS>'
EMU_2 = '<ROOT>/dkwolf/dkwolf <OPTIONS> -nvram_directory NUL -record <RECORD_ID>'
EMU_3, EMU_4, EMU_5, EMU_6, EMU_7, EMU_8 = (None,) * 6

# External command to issue when emulator starts up
EMU_ENTER = ""

# External command to issue after exiting emulator e.g. return focus to frontend
EMU_EXIT = ""

# Allow roms in ROM_DIR to be overwritten.  Set to 1 when using an emulator that doesn't support -rompath argument.
ALLOW_ROM_OVERWRITE = 0

# Patch directory (for provided patch files)
PATCH_DIR = os.path.join(ROOT_DIR, "patch")

# Above defaults can be overridden in the settings.txt file
if os.path.exists("settings.txt"):
    with open("settings.txt") as sf:
        for setting in sf.readlines():
            if setting.count("=") == 1 and not setting.startswith("#"):
                key, value = setting.split("=")
                key = key.strip()
                value = value.strip()
                try:
                    if key.startswith("CONTROL_"):
                        globals()[key] = pygame.key.key_code(value)
                    elif value.isnumeric():
                        globals()[key] = int(value)
                    elif value.lower() == "true":
                        globals()[key] = 1
                    elif value.lower() == "false":
                        globals()[key] = 0
                    else:
                        globals()[key] = value.replace("<ROOT>", ROOT_DIR).replace("<OPTIONS>", OPTIONS)
                except KeyError:
                    print(f'Unknown setting "{key.strip()}" in settings.txt file')
                    pygame.quit()
                    exit()


# Override settings when debugging
if sys.gettrace():
    globals()["FULLSCREEN"] = 0
    globals()["TITLE"] = "DKAFE (Debugging Mode)"

# Validate some settings
if not os.path.exists("romlist_addon.csv"):
    globals()["ENABLE_ADDONS"] = 0
STAGES = 4 if ENABLE_ADDONS else 3
if PLAYLIST_VOLUME > 10: globals()["PLAYLIST_VOLUME"] = 10
if PLAYLIST_VOLUME < 0: globals()["PLAYLIST_VOLUME"] = 0
if SPEED_ADJUST > 8:  globals()["SPEED_ADJUST"] = 8
if SPEED_ADJUST < 0:  globals()["SPEED_ADJUST"] = 0
if START_STAGE > STAGES: START_STAGE = 0

# Console Addon Specific
ROMLIST_FILES = ["romlist.csv", "romlist_addon.csv" if ENABLE_ADDONS else ""]
RECOGNISED_SYSTEMS = ["nes", "coleco", "fds", "gameboy", "gbcolor", "intv", "a2600", "a5200", "a7800", "a800xl",
                      "hbf900a", "ti99_4a", "coco3", "cpc6128", "apple2e", "bbcb", "c64", "c64p", "pet4032", "spectrum",
                      "oric1", "snes", "dragon32", "adam", "gnw", "genesis", "lcd", "pc", "dos", "vic20"]
# System specific media switches when not simply "-cart"
SYSTEM_MEDIA = {"apple2e": "-gameio joy -flop1",
                "bbcb": "-flop1",
                "fds": "-flop1",
                "hbf900a": "-flop1",
                "coco3": "-flop1",
                "cpc6128": "-flop1",
                "c64": "-joy1 joy -quik",
                "c64p": "-joy1 joy -quik",
                "pet4032": "-quik",
                "spectrum": "-dump",
                "oric1": "-cass",
                "dragon32": "-cass",
                "adam": "-cart1",
                "vic20": "-quik"}
# Game specific media to override the system media
GAME_MEDIA = {"c64_felix":"-flop", "c64_jumpman":"-quik", "c64_dk_junior":"-quik", "c64_dk_x":"-quik", "c64_bonkeykong":"-flop", "c64p_dk_ocean":"-quik", "c64p_dk_junior":"-quik"}
WIN64_ONLY_SYSTEMS = "pc", "dos"
# use scan code or see keycodes at: https://github.com/boppreh/keyboard/blob/master/keyboard/_canonical_names.py
KEYBOARD_REMAP = {"pc_raiders":"ctrl>space",
                  "pc_fixitfelix":"ctrl>num 1",
                  "pc_jumpman_rtx":"num 1>enter,ctrl>space,esc>forcequit",
                  "pc_dk_remake":"num 1>enter,ctrl>space,esc>forcequit",
                  "pc_dk_jr_remake": "num 1>enter,ctrl>space,esc>forcequit",
                  "pc_dk_craze": "esc>forcequit:stdrt.exe",
                  "pc_dk_plus": "left>a,right>d,up>w,down>s,1>enter,ctrl>space",
                  "dos_aldo3": "ctrl>space",
                  "dos_aldo": "ctrl>space",
                  "dos_dk": "ctrl>space,esc>forcequit:dosbox-x.exe",
                  "dos_kong": "num 1>enter,esc>forcequit:dosbox-x.exe"}

# Frontend version
VERSION = ''
if os.path.exists("VERSION"):
    with open("VERSION") as vf:
        VERSION = vf.readline().strip()

# Target system architecture
ARCH = 'win64'  # default
if os.path.exists("ARCH"):
    with open("ARCH") as af:
        ARCH = af.readline().strip()

# Expected location of original DK zips (not provided with software)
DKONG_ZIP = os.path.join(ROM_DIR, "dkong.zip")
DKONGJR_ZIP = os.path.join(ROM_DIR, "dkongjr.zip")
DKONG3_ZIP = os.path.join(ROM_DIR, "dkong3.zip")

# Optional rom names
OPTIONAL_NAMES = "dkong", "dkongjr", "dkong3", "logger", "congo"

# Plugins add functionality to certain roms
PLUGINS = (
    ("dkonglava", "dklavapanic"),
    ("dkonglava1", "dklavapanic"),
    ("dkonglava1", "dkstart5:1"),
    ("dkonglava2", "dklavapanic"),
    ("dkonglava2", "dkstart5:2"),
    ("dkonglava3", "dklavapanic"),
    ("dkonglava3", "dkstart5:3"),
    ("dkonglava4", "dklavapanic"),
    ("dkonglava4", "dkstart5:4"),
    ("dkonggalakong", "galakong"),
    ("dkonggalakong1", "galakong"),
    ("dkonggalakong1", "dkstart5:1"),
    ("dkonggalakong2", "galakong"),
    ("dkonggalakong2", "dkstart5:2"),
    ("dkonggalakong3", "galakong"),
    ("dkonggalakong3", "dkstart5:3"),
    ("dkonggalakong4", "galakong"),
    ("dkonggalakong4", "dkstart5:4"),
    ("dkongxgalakong", "galakong"),
    ("dkongjrgala", "galakong"),
    ("dkongwho", "dkwho"),
    ("dkongwho1", "dkwho"),
    ("dkongwho1", "dkstart5:1"),
    ("dkongwho2", "dkwho"),
    ("dkongwho2", "dkstart5:2"),
    ("dkongwho3", "dkwho"),
    ("dkongwho3", "dkstart5:3"),
    ("dkongwho4", "dkwho"),
    ("dkongwho4", "dkstart5:4"),
    ("dkongend1", "dkend:1"),
    ("dkongend2", "dkend:2"),
    ("dkongend3", "dkend:3"),
    ("dkongend4", "dkend:4"),
    ("dkongkonkey", "konkeydong"),
    ("dkong2600", "gingerbreadkong"),
    ("dkongvector", "vectorkong"),
    ("dkongallen", "allenkong"),
    ("dkongchorus", "dkchorus"),
    ("dkongcontinue", "continue"),
    ("dkongjrcontinue", "continue"),
    ("ckongpt2_continue", "continue"),
    ("dkongl22", "dklevel22"),
    ("ckongpt2_l22", "dklevel22")
)

# Above plugin is launched with parameters and can compete (unlike a menu launch plugin).
PARAMETER_PLUGINS = "dkongend1", "dkongend3", "dkonglava1", "dkonglava2", "dkonglava3", "dkonglava4"

# Roms that are compatible with my plugins
COACH_FRIENDLY = ("dkongspringy", "dkongbarrels", "dkongcb", "dkonghrd", "dkong")
COACH_L5_FRIENDLY = ("dkongspringy", "dkongbarrels")
CHORUS_FRIENDLY = ("dkong", "dkongspringy", "dkongbarrels", "dkongcb", "dkonghrd", "dkongrivets", "dkongrnd",
                   "dkongwbh", "dkongpies", "dkongjapan", "dkongpauline", "dkongfr", "dkongl05", "dkongce", "dkongrev",
                   "dkong2nut", "dkongoctomonkey", "dkonghalf", "dkongquarter", "dkongksfix")
CONTINUE_FRIENDLY = ("dkong", "dkongjr", "dkongd2k", "dkongjapan", "dkongpauline", "ckong", "ckongpt2", "ckongpt2b",
                     "ckongpt2_117", "dkongspooky", "dkongxmas", "dkongrdemo", "dkongrev", "dkongcb", "dkong40",
                     "dkongitd", "dkong2600", "dkongtj", "dkongfoundry", "dkongotr", "dkonghrthnt", "dkongkana",
                     "dkongnoluck", "dkongwbh", "dkongjapan", "dkongpac", "dkonghrd", "dkongrainbow", "dkongksfix",
                     "dkongl05", "dkongbarrels", "dkongspringy", "dkongpies", "dkongrivets", "ckongs", "dkongwizardry",
                     "dkongoctomonkey", "dkongaccelerate", "dkonghalf", "dkongquarter", "dkongwho", "dkonglava",
                     "dkong2600", "dkongchorus", "dkonggalakong", "dkongjrgala", "dkongxgalakong", "dkongpacmancross",
                     "ckongpt2a_2023")
SHOOT_FRIENDLY = ("dkongspringy", "dkongbarrels", "dkongpies", "dkongrivets", "dkongpacmancross")
START5_FRIENDLY = ("dkong", "dkongjr", "dkongpies", "dkonggalakong", "dkongspooky", "dkongwizardry", "dkong40",
                   "dkongspringy", "dkonglava", "dkongwho", "ckongpt2", "dkongitd", "dkongxmas", "dkongvector",
                   "dkongjrgala", "dkong2600", "dkongtj", "dkongfr", "dkongrivets", "dkongfoundry", "dkongotr",
                   "dkonghrthnt", "bigkong", "dkongd2k", "dkongrev", "dkongrdemo", "dkongcb", "dkongkana",
                   "dkongrndmzr", "dkongnoluck", "dkongwbh", "dkongpauline", "dkongjapan", "dkongpac", "dkongbarrels",
                   "dkonghrd", "ckong", "ckongpt2b", "dkongchorus", "dkongkonkey", "dkongrainbow", "dkongcontinue",
                   "dkongjrcontinue", "ckongs", "ckongg", "ckongmc", "dkongksfix", "dkongbcc", "dkongbarrelboss",
                   "dkongsprfin", "bigkonggx", "ckongdks", "ckongpt2_117", "ckongpt2b", "dkongpacmancross",
                   "ckongpt2a_2023")
STAGE_FRIENDLY = ("dkong", "dkongjr", "dkonggalakong", "dkongwizardry", "dkong40", "dkonglava", "dkongwho", "dkongfr",
                  "dkongaccelerate", "ckongpt2", "dkongitd", "dkongjrgala", "dkong2600", "dkongtj", "dkongfoundry",
                  "dkongotr", "dkonghrthnt", "dkongxgalakong", "bigkong", "dkongd2k", "dkongrev", "dkongkana",
                  "dkongrndmzr", "dkongnoluck", "dkongwbh", "dkongpauline", "dkongjapan", "dkongpac", "dkonghrd",
                  "ckong", "ckongpt2b", "dkong2600", "dkongchorus", "dkongkonkey", "dkongrainbow", "ckongs", "ckongg",
                  "ckongmc", "dkongksfix", "bigkonggx", "ckongdks", "ckongpt2_117", "dkongpacmancross",
                  "ckongpt2a_2023")

# Roms that are not fully compatible
HUD_UNFRIENDLY = ["dkongwizardry", "dkongduel", "dkongkonkey", "dkongaccelerate"]
HISCORE_UNFRIENDLY = ["dkongd2k"]
AUTOSTART_UNFRIENDLY = ["dkongduel", "dkongchorus"]
SKIPINTRO_UNFRIENDLY = ["dkongchorus"]
ADDITIONAL_CREDIT = ["dkongduel"]

# Colours
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
RED = (232, 7, 10)
PINK = (255, 210, 190)
MAGENTA = (236, 49, 148)
CYAN = (20, 243, 255)
BLUE = (4, 3, 255)
DARKBLUE = (4, 2, 220)
MIDBLUE = (4, 3, 255)
YELLOW = (244, 186, 21)
BROWN = (172, 5, 7)
LIGHTBROWN = (238, 117, 17)
GREY = (128, 128, 128)
MIDGREY = (104, 104, 104)
DARKGREY = (40, 40, 40)

# Alpha channel value for faded/locked arcade machines
FADE_LEVEL = 75

# Sequential list of arcade machine slot locations (x, y) starting with location 1.
SLOTS = (
    (2, 226), (34, 226), (50, 226), (94, 226), (114, 225), (130, 224), (146, 223), (162, 222), (210, 219),
    (194, 198), (146, 195), (130, 194), (114, 193), (82, 191), (66, 190), (50, 189), (2, 186),
    (18, 165), (50, 163), (82, 161), (130, 158), (146, 157), (162, 156), (210, 153),
    (194, 132), (146, 129), (130, 128), (98, 126), (82, 125), (50, 123), (18, 121), (2, 120),
    (50, 97), (98, 94), (114, 93), (130, 92), (146, 91), (162, 90), (210, 87),
    (194, 66), (162, 64), (146, 63), (114, 62), (90, 62), (2, 62),
    (90, 34),

    (18, 226), (34, 226), (50, 226), (90, 226), (114, 226), (130, 226), (146, 226), (162, 226), (178, 226), (194, 226),
    (26, 186), (42, 186), (58, 186), (82, 186), (114, 186), (130, 186), (154, 186), (170, 186), (186, 186),
    (34, 146), (50, 146), (82, 146), (114, 146), (130, 146), (154, 146),
    (42, 106), (74, 106), (90, 106), (122, 106), (138, 106), (170, 106),
    (42, 66), (82, 66), (170, 66),
    (106, 26),

    (2, 226), (34, 226), (50,226), (90, 226), (106, 226), (122, 226), (146, 226), (162, 226), (178, 226), (208, 226),
    (8, 186), (34, 186), (50, 186), (90, 186), (122, 186), (154, 186), (174, 186), (202, 186),
    (2, 146), (34, 146), (50, 146), (90, 146), (106, 146), (122, 146), (154, 146), (174, 146), (202, 146),
    (33, 106), (52, 106), (67, 106), (90, 106), (122,106), (154, 106), (174, 106), (210, 106),
    (2, 66), (90, 66), (106, 66), (138, 66), (154, 66), (170, 66), (186, 66), (208, 66),
    (90, 34),

    (2, 226), (18, 226), (50, 226), (116, 226), (134, 226), (152, 226), (178, 226), (194, 226),
    (18, 195), (34, 191), (50, 195), (66, 195), (98, 191), (116, 195), (134, 195), (152, 195), (178, 195), (194, 195),
    (34, 162), (50, 166), (98, 162), (134, 166), (152, 166), (178, 166), (194, 166),
    (132, 136), (148, 136), (164, 136), (194, 136), (210, 136),
    (34, 102), (50, 106), (98, 102), (116, 106), (132, 106), (148, 106), (194, 106),
    (194, 76),
    (154, 66), (138, 66), (114, 66), (90, 66), (2, 66),
    (90, 34),

    (2, 226), (34, 226), (50, 226), (94, 226), (114, 225), (130, 224), (146, 223), (162, 222), (194, 220), (210, 219),
    (146, 195), (130, 194), (114, 193), (82, 191), (66, 190), (50, 189), (18, 187), (2, 186),
    (50, 163), (82, 161), (130, 158), (146, 157), (162, 156), (194, 154), (210, 153),
    (146, 129), (130, 128), (98, 126), (82, 125), (50, 123), (18, 121), (2, 120),
    (50, 97), (98, 94), (114, 93), (130, 92), (146, 91), (162, 90), (194, 88), (210, 87),
    (162, 64), (146, 63), (114, 62), (90, 62), (2, 62),
    (98, 34)
)

# Range of slots that appear on each stage
SLOTS_PER_STAGE = (0, 46), (46, 81), (81, 125), (125, 169), (169, 215)

# Control assignments. Links global variables to event data.  These shouldn't be changed.
CONTROL_ASSIGNMENTS = (
  ("left", CONTROL_LEFT),
  ("right", CONTROL_RIGHT),
  ("up", CONTROL_UP),
  ("down", CONTROL_DOWN),
  ("jump", CONTROL_JUMP),
  ("start", CONTROL_P1))

# Text description of prize placing
PRIZE_PLACINGS = {1: "1ST", 2: "2ND", 3: "3RD"}

# Sounds that are played during walk sequence. Not all steps will trigger a sound.
WALK_SOUNDS = {1: "walk0.wav", 5: "walk1.wav", 9: "walk2.wav"}

# Defines scene numbers in the intro when sounds should be played
SCENE_SOUNDS = {
  160: "climb.wav",
  481: "stomp.wav",
  712: "roar.wav",
  856: "howhigh.wav"}

# Defines when icons should be displayed on the climb intro.  The entries relate to the various platforms.
# data is: appear from scene, appear to scene, below y, above y, smash animation to scene
SCENE_ICONS = (
    (481, 856, 68, 40, 502),
    (544, 856, 101, 68, 565),
    (580, 856, 134, 101, 601),
    (613, 856, 167, 134, 634),
    (646, 856, 200, 167, 667),
    (679, 856, 999, 200, 700),
    (700, 856, 999, 0, 0))

# Ladder zone detection. The R read from screen map determines were jumpman is relative to a ladder
LADDER_ZONES = (
    ("LADDER_DETECTED", (20, 30, 60, 90, 240)),
    ("END_OF_LADDER", (60, 90)),
    ("TOP_OF_LADDER", (60,)),
    ("NEARING_END_OF_LADDER", (30,)),
    ("APPROACHING_END_OF_LADDER", (240,)),
    ("CLIMBING_LADDER", (20,)),
    ("BROKEN_LADDER", (160, 170, 180)),
    ("TOP_OF_BROKEN_LADDER", (170, 180)),
    ("TOP_OF_VIRTUAL_LADDER", (180,)),
    ("VIRTUAL_LADDER", (180, 190)),
    ("APPROACHING_LADDER", (200,)),
    ("ANY_LADDER", (20, 30, 60, 90, 160, 170, 180, 190, 240)),
    ("TOP_OF_ANY_LADDER", (60, 170, 180)))

# Jumpman's x position when centre of ladder
LADDER_CENTRES = (4, 12, 20, 28, 36, 60, 68, 76, 84, 92, 100, 108, 116, 124, 132, 140, 148, 164, 180, 188, 196, 204)

# Stage specific positions, colours etc
BONUS_COLORS = (CYAN, MAGENTA), (YELLOW, MIDBLUE), (WHITE, LIGHTBROWN), (CYAN, MAGENTA), (WHITE, WHITE)
HAMMER_POSXY = ((16, 98), (167, 190)), ((8, 140), (104, 100)), ((12, 140), (104, 178)), ((3, 159), (206, 70)), ((32, 96), (167, 190))
TELEPORT_TO_POSXY = ((164, 193), (20, 92)), ((101, 98), (11, 138)), ((104, 180), (16, 140)), ((206, 72), (3, 161)), ((164, 193), (32, 92))
OILCAN_POSXY = (16, 232), (172, 152), (104, 128), (68, 112), (16, 232)
WARP_ARROW_POSXY = (20, 246), (176, 166), (108, 142), (72, 126), (20, 246)
PAULINE_POSXY = (0, 0), (16, -8), (0, 0), (0, 0), (0, 0)
KONG_POSXY = (0, 0), (80, 4), (0, 4), (0, 4), (0, 0)
COIN_GRAB_POSXY = (67, 73), (147, 77), (67, 77), (67, 77), (67, 73)
COIN_AWARD_POSX = 0, 112, 28, 0, 0
LADDER_CHANCE = 3, 2, 3, 3,3   # Chance of coin rolling down a ladder (1 = always, 2 = 1/2,  3 = 1/3 etc.) by stage

# Pies specific.  Location of the 2 moving ladder sections
MOVING_LADDER_POSXY = (15, 96), (199, 96)
MOVING_LADDER_OFFSETS = list((0,)*48) + list(range(1,16)) + list((16,)*8) + list(range(15,0,-1))

# Sprite helpers
SPRITE_FULL = 15
SPRITE_HALF = 8
JUMP_PIXELS = [-1, ] * 15 + [1, ] * 13
JUMP_SHORTEN = 1.25

# In game messages and instructions
QUESTION = "WHAT GAME WILL YOU PLAY ?"
COIN_INFO = ["Hey Jumpman!", '', "You must collect coins..", "to unlock more games", "", "Push COIN for game info", ""]
FREE_INFO = ["Hey Jumpman!", '', "All arcades are free to play", "", "Push COIN to for game info", ""]
TEXT_INFO = ["", "Push 'JUMP' to play or 'P1 START' for game options"]

NO_ROMS_MESSAGE = [
    "NO ROMS WERE FOUND!", "",
    "FOR THE DEFAULT FRONTEND",
    "PUT DKONG.ZIP INTO THE",
    "DKAFE\\ROMS DIRECTORY",
    "THEN RESTART.", "",
    "DKONG.ZIP    IS REQUIRED",
    "DKONGJR.ZIP  IS OPTIONAL",
    "DKONG3.ZIP   IS OPTIONAL"]

# Expected content of the original DK rom
ROM_CONTENTS = ["c_5at_g.bin", "c_5bt_g.bin", "c_5ct_g.bin", "c_5et_g.bin", "c-2j.bpr", "c-2k.bpr", "l_4m_b.bin",
                "l_4n_b.bin", "l_4r_b.bin", "l_4s_b.bin", "s_3i_b.bin", "s_3j_b.bin", "v_3pt.bin", "v_5h_b.bin",
                "v-5e.bpr"]

# MD5 checksum of expected DK base rom and various fixes/patches to align the provided rom with the expected rom.
DKONG_MD5 = "a13e81d6ef342d763dc897fe03893392"
FIX_MD5 = ("f116efa820a7cedd64bcc66513be389d", "d57b26931fc953933ee2458a9552541e", "aa282b72ac409793b36780c99b26d07b",
           "e883b4225a76a79f38cf1db7c340aa8e", "eb6571036ff25e8e5db5289f5524ab76", "5897e79286e19c91eb3eca657a8c574c",
           "480d0f113e8c7069b50ba807cf4b2a24", "394a7d367c9926c1d151dd87814c77f4")

INVALID_ROM_MESSAGE = [
    "ERROR WITH DONKEY KONG ROM", "",
    "Your DKONG.ZIP file is not",
    "valid. Please replace it.", "",
    "The zip should contain the",
    "following files:", ""]

INSTRUCTION = """

Donkey Kong has captured
Pauline and carried her to
the top of an abandoned
construction site.

The shock of shaking up the
building during his ascent
has uncovered many hidden
arcade machines from the
1980's era and they are
scattered around the site.

The coins thrown by Donkey
Kong must be collected by 
Jumpman so he has money to
play the arcades.

Jumpman must play well to
win prizes and unlock arcade
machines as he works his way 
through 4 challenging stages
and rescues Pauline from the
top of the building.  

Pauline will ♥ it when you
beat all of the machines.
"""

MORE_INSTRUCTION = """
If you are not up for the 
challenge then it is
possible to adjust things 
and have all machines 
unlocked and set to free 
play. 

Helpful hints:

• Pauline shouts out game
  information, score targets
  and unlock requirements as 
  you walk towards a machine.         

• Navigate between stages by
  climbing an exit ladder or
  by warping down an oilcan.

• Use hammers to teleport
  over short distances. 

• Use practice modes to get 
  better at each stage.  
  Can you reach the infamous 
  killscreen at level 22-1.

Good luck!
"""

CONTROLS = """

The Controls are as follows:


Left/  — Move Jumpman along
Right    the platforms

Up/    - Move Jumpman up and
Down     down ladders.
         Up faces a machine.

Jump   - Launch machine that
         Jumpman is facing.

P1     - Show launch options
         for a machine that 
         Jumpman is facing
          
P2     - Call up a quick
         access game list

Coin   - Show game info
         above machines
                      
Action - Show slot numbers

Exit   - Exit DKAFE
"""

THANKS_TO = """
Thanks to these folks!

Donkey Kong rom hacks: 
   Paul Goes
   Sockmaster
   Jeff Kulczycki, 
   Mike Mika & Clay Cowgill
   Don Hodges
   Tim Appleton 
   Vic20 George
   Kirai Shouen & 125scratch

Donkey Kong hacking resource:
   furrykef

Feedback and feature ideas:
   Superjustinbros

Playlist music:
   LeviR.star's Music
   Nintega Dario
   MyNameIsBanks
   SanHolo
   MotionRide Music
   Buckner & Garcia
   Sascha Zeidler
   Mitchel Gatzke
   Chiptunema
"""

# Sound setup
pygame.mixer.init(frequency=48000)
background_channel = pygame.mixer.Channel(1)
intermission_channel = pygame.mixer.Channel(2)
award_channel = pygame.mixer.Channel(3)
playlist = pygame.mixer.music

# Initialisation
pygame.init()
clock = pygame.time.Clock()

# Font setup (pygame)
dk_font = pygame.font.Font('fonts/PressStart2P-vaV7.ttf', 8)
pl_font = pygame.font.Font('fonts/tom-thumb.bdf', 5)
pl_font7 = pygame.font.Font('fonts/tom-thumb.bdf', 7)

# Menu theme setup
dkafe_theme = pymenu.themes.THEME_DEFAULT.copy()
dkafe_theme.widget_font = 'fonts/PressStart2P-vaV7.ttf'
dkafe_theme.title_font = 'fonts/PressStart2P-vaV7.ttf'
dkafe_theme.title_font_size = 8
dkafe_theme.widget_font_size = 8

dkafe_theme.background_color = BLACK
dkafe_theme.title_background_color = WHITE
dkafe_theme.title_font_color = RED
dkafe_theme.title_bar_style = pymenu.widgets.MENUBAR_STYLE_UNDERLINE
dkafe_theme.title_offset = (12, 2)
dkafe_theme.widget_alignment = pymenu.locals.ALIGN_CENTER

dkafe_theme.scrollbar_color = BLACK
dkafe_theme.scrollbar_slider_color = BLACK
dkafe_theme.scrollbar_slider_pad = 0
dkafe_theme.scrollbar_thick = 2
dkafe_theme.selection_color = RED
dkafe_theme.widget_font_color = PINK
dkafe_theme.widget_margin = (0, 2)
dkafe_theme.widget_selection_effect = pymenu.widgets.HighlightSelection(margin_x=10, margin_y=1)

dkafe_theme_left = dkafe_theme.copy()
dkafe_theme_left.widget_alignment = pymenu.locals.ALIGN_LEFT

# Override default pygame-menu keys
pymenu.controls.KEY_APPLY = CONTROL_JUMP
pymenu.controls.KEY_CLOSE_MENU = CONTROL_EXIT
