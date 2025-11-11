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
from glob import glob

# Determine system
def get_system(return_video=False):
    if "uname" in dir(os) and os.uname().machine.startswith("arm"):
        return ("pi", "accel")[int(return_video)]
    elif "uname" in dir(os) and os.uname().sysname == "Linux":
        return ("linux", "opengl")[int(return_video)]
    else:
        windows_version = sys.getwindowsversion()
        if windows_version[0] > 5:
            return ("win", "opengl")[int(return_video)]
        else:
            return ("win (old)", "gdi")[int(return_video)]


def is_pi():
    return get_system() == "pi" or get_system() == "linux"


pygame.init()

# Graphic Config
TITLE = 'DKAFE'
DISPLAY = (224, 256)           # Internal x, y resolution of game graphics
TOPLEFT = (0, 0)               # Position of top left corner
ROTATION = 0                   # Frontend rotation (0, 90, 180, 270).   Rotates the primary display only.
CLOCK_RATE = 45                # Clock rate
SPEED_ADJUST = 0               # Adjustment to above clock rate (e.g. 0=45, 1=50, +2=55, +3=60, +4=65, +5=70, +6=75)

# Default Keyboard Controls - they match MAME
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
CONTROL_DEBUG_DROP = pygame.K_HOME

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
ANNOUNCE_AWARD_INGAME = 1      # Play award sounds during gameplay
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
COIN_FREQUENCY = 2             # How frequently DK will grab a coin (1 = always, 2 = 1/2,  3 = 1/3 etc.)
COIN_HIGH = 3                  # Frequency of coin being higher value (1 = always, 2 = 1/2,  3 = 1/3 etc.)
COIN_SPEED = 1.6               # Number of pixels to move coin per display update. Decimal
COIN_CYCLE = 0.15              # How often the coin sprite is updated. Decimal
INP_FAVOURITE = 10             # Flag .inp recordings of this duration or greater (in minutes) by prefixing with ♥

# Root directory of frontend
ROOT_DIR = os.getcwd()

# Emulator and rom path defaults
ROM_DIR = '<ROOT>/roms'
OPTIONS = '-rompath "<ROM_DIR>" -view "Pixel Aspect (7:8)" -nofilter -nosleep'
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
    globals()["FREE_PLAY"] = 1

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
elif is_pi():
    ARCH = "pi"

# Validate some settings
ADDONS_CONSIDERED = ENABLE_ADDONS
if not os.path.exists("romlist_addon.csv") and not glob("dkafe_*_addon_*.zip"):
    globals()["ENABLE_ADDONS"] = 0

if ENABLE_ADDONS:
    STAGES = 8
else:
    STAGES = 3

if PLAYLIST_VOLUME > 10: globals()["PLAYLIST_VOLUME"] = 10
if PLAYLIST_VOLUME < 0: globals()["PLAYLIST_VOLUME"] = 0
if SPEED_ADJUST > 8:  globals()["SPEED_ADJUST"] = 8
if SPEED_ADJUST < 0:  globals()["SPEED_ADJUST"] = 0
if START_STAGE > STAGES: START_STAGE = 0

# Expected location of original DK zips (not provided with software)
DKONG_ZIP = os.path.join(ROM_DIR, "dkong.zip")
DKONGJR_ZIP = os.path.join(ROM_DIR, "dkongjr.zip")
DKONG3_ZIP = os.path.join(ROM_DIR, "dkong3.zip")

ARCADE_JUNIOR = "dkongjr", "dkongjre", "dkongjrm", "dkongjrmc"
ARCADE_DK3 = "dkong3",
ARCADE_CRAZY = "ckong", "ckongpt2", "ckongpt2a", "ckongpt2b", "ckongs", "ckongg", "ckongdks", "ckongmc"
ARCADE_BIG = "bigkong", "bigkonggx"
ARCADE_LOGGER = "logger", "loggerr2"
ARCADE_TRAINERS = ("dkongtrn", "dkongpace", "dkongbcc", "dkongsprites", "dkongbarrelboss", "dkongsprfin", "dkongst2",
                   "dkongcoach", "dkongcoachsprings", "dkongl05")
ARCADE_2PLAYER = "dkongduel", "pc_dkbros"
ARCADE_CORE_ORDER = "Donkey Kong", "Donkey Kong Junior", "Donkey Kong 3", "PC: DK Bros.", "Crazy Kong (Part I)", "Crazy Kong (Part II)", "Big Kong"
SYSTEM_CORE_ORDER = "Arcade (Donkey Kong)", "Arcade (Donkey Kong Junior)", "Arcade (Donkey Kong 3)", "Arcade (Crazy Kong)", "Arcade (Big Kong)", "Arcade (Logger)", "Arcade (Two Players)", "Arcade (Practice)", "Arcade (Other)"

# Generated list of arcade other roms - included in add-on pack.  Users can also drop additional arcade roms in here.
ARCADE_OTHER = []
for _rom in glob(os.path.join(ROM_DIR, "other", "*.zip")):
    ARCADE_OTHER.append(os.path.basename(_rom).split(".")[0])

# Optional rom names
OPTIONAL_NAMES = "dkong", "dkongjr", "dkong3"

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
    ("dkongcoach","dkcoach"),
    ("dkongcoachsprings","dkcoach"),
    ("dkongjrfree", "dkfree"),
    ("dkong3free", "dkfree"),
    ("dkongjrlavapanic", "dklavapanic"),
    ("bigkong_free", "dkfree"),
    ("ckongpt2_free", "dkfree"),
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
    ("dkongvectorwild", "vectorkong"),
    ("dkongdizzy", "dizzykong"),
    ("dkongdizzylava", "dizzykong,dklavapanic"),
    ("dkongallenl22","allenkong:22"),
    ("dkongwobble", "wobblekong"),
    ("dkongallen", "allenkong"),
    ("dkongchorus", "dkchorus"),
    ("dkonginsanity", "dkinsanity"),
    ("ckongpt2_insanity", "dkinsanity"),
    ("dkongcontinue", "continue"),
    ("dkongjrcontinue", "continue"),
    ("dkong3continue", "continue"),
    ("ckongpt2_continue", "continue"),
    ("bigkong_continue", "continue"),
    ("bigkong_lava", "dklavapanic"),
    ("bigkong_insanity", "dkinsanity"),
    ("dkongl22", "dklevel22"),
    ("ckongpt2_l22", "dklevel22"),
    ("bigkong_l22", "dklevel22"),
    ("dkongl00", "dklevel0"),
    ("ckongpt2_l00", "dklevel0"),
    ("bigkong_l00", "dklevel0"),
    ("bigkonggx_barrels", "dkstart5:1"),
    ("dkongjrspringboard", "dkstart5:1"),
    ("dkongjrvines", "dkstart5:2"),
    ("dkongjrchains", "dkstart5:3"),
    ("dkongjrhideout", "dkstart5:4"),
    ("dkongjrl22", "dklevel22"),
    ("ckongpt2_lava","dklavapanic"),
    ("ckongpt2_barrels", "dkstart5:1"),
    ("ckongpt2_pies", "dkstart5:2"),
    ("ckongpt2_springs", "dkstart5:3"),
    ("ckongpt2_rivets", "dkstart5:4"),
    ("bigkong_barrels", "dkstart5:1"),
    ("dkongvectorgala","galakong,vectorkong"),
    ("dkong3blue", "dk3stage:0"),
    ("dkong3gray", "dk3stage:1"),
    ("dkong3yellow", "dk3stage:2"),
    ("dkongfoundryonly", "dkstart5:5"),
    ("logger_barrels", "loggerstage:0"),
    ("logger_pies", "loggerstage:1"),
    ("logger_springs", "loggerstage:2"),
    ("logger_rivets", "loggerstage:3"),
    ("loggerr2_barrels", "loggerstage:0"),
    ("loggerr2_pies", "loggerstage:1"),
    ("loggerr2_springs", "loggerstage:2"),
    ("loggerr2_rivets", "loggerstage:3"),
    ("logger_continue", "continue"),
    ("loggerr2_continue", "continue")
)

# Above plugin is launched with parameters and can compete (unlike a menu launch plugin).
PARAMETER_PLUGINS = "dkongend1", "dkongend3", "dkonglava1", "dkonglava2", "dkonglava3", "dkonglava4"

# Roms that are compatible with my plugins
COACH_FRIENDLY = ("dkongspringy", "dkongbarrels", "dkongcb", "dkonghrd", "dkong")
COACH_L5_FRIENDLY = ("dkongspringy", "dkongbarrels")
CHORUS_FRIENDLY = ("dkong", "dkongspringy", "dkongbarrels", "dkongcb", "dkonghrd", "dkongrivets", "dkongrnd",
                   "dkongwbh", "dkongpies", "dkongjapan", "dkongpauline", "dkongfr", "dkongl05", "dkongce", "dkongrev",
                   "dkong2nut", "dkongoctomonkey", "dkonghalf", "dkongquarter", "dkongksfix", "dkonginsanity",
                   "dkongl00")
CONTINUE_FRIENDLY = ("dkong", "dkongjr", "dkongd2k", "dkongjapan", "dkongpauline", "ckong", "ckongpt2", "ckongpt2b",
                     "ckongpt2_117", "dkongspooky", "dkongxmas", "dkongrdemo", "dkongrev", "dkongcb", "dkong40",
                     "dkongitd", "dkong2600", "dkongtj", "dkongfoundry", "dkongotr", "dkonghrthnt", "dkongkana",
                     "dkongnoluck", "dkongwbh", "dkongjapan", "dkongpac", "dkonghrd", "dkongrainbow", "dkongksfix",
                     "dkongl05", "dkongbarrels", "dkongspringy", "dkongpies", "dkongrivets", "ckongs", "dkongwizardry",
                     "dkongoctomonkey", "dkongaccelerate", "dkonghalf", "dkongquarter", "dkongwho", "dkonglava",
                     "dkong2600", "dkongchorus", "dkonggalakong", "dkongjrgala", "dkongxgalakong", "dkongpacmancross",
                     "ckongpt2a_2023", "ckongpt2_dk", "dkonginsanity", "dkong3", "logger", "loggerr2",
                     "pacman", "mspacman", "pacplus", "pacmanf", "mspacmnf", "mspacmat", "qbert", "frogger", "invaders",
                     "galaga", "galaxian")
SHOOT_FRIENDLY = ("dkongspringy", "dkongbarrels", "dkongpies", "dkongrivets", "dkongpacmancross", "dkonginsanity")
START5_FRIENDLY = ("dkong", "dkongjr", "dkongpies", "dkonggalakong", "dkongspooky", "dkongwizardry", "dkong40",
                   "dkongspringy", "dkonglava", "dkongwho", "ckongpt2", "dkongitd", "dkongxmas", "dkongvector",
                   "dkongjrgala", "dkong2600", "dkongtj", "dkongfr", "dkongrivets", "dkongfoundry", "dkongotr",
                   "dkonghrthnt", "bigkong", "dkongd2k", "dkongrev", "dkongrdemo", "dkongcb", "dkongkana",
                   "dkongrndmzr", "dkongnoluck", "dkongwbh", "dkongpauline", "dkongjapan", "dkongpac", "dkongbarrels",
                   "dkonghrd", "ckong", "ckongpt2b", "dkongchorus", "dkongkonkey", "dkongrainbow", "dkongcontinue",
                   "dkongjrcontinue", "ckongs", "ckongg", "ckongmc", "dkongksfix", "dkongbcc", "dkongbarrelboss",
                   "dkongsprfin", "bigkonggx", "ckongdks", "ckongpt2_117", "ckongpt2b", "dkongpacmancross",
                   "ckongpt2a_2023", "ckongpt2_dk", "dkongwobble", "dkongvectorwild", "dkongdizzy", "dkongvectorgala")
STAGE_FRIENDLY = ("dkong", "dkongjr", "dkonggalakong", "dkongwizardry", "dkong40", "dkonglava", "dkongwho", "dkongfr",
                  "dkongaccelerate", "ckongpt2", "dkongitd", "dkongjrgala", "dkong2600", "dkongtj", "dkongfoundry",
                  "dkongotr", "dkonghrthnt", "dkongxgalakong", "bigkong", "dkongd2k", "dkongrev", "dkongkana",
                  "dkongrndmzr", "dkongnoluck", "dkongwbh", "dkongpauline", "dkongjapan", "dkongpac", "dkonghrd",
                  "ckong", "ckongpt2b", "dkong2600", "dkongchorus", "dkongkonkey", "dkongrainbow", "ckongs", "ckongg",
                  "ckongmc", "dkongksfix", "bigkonggx", "ckongdks", "ckongpt2_117", "dkongpacmancross",
                  "ckongpt2a_2023", "ckongpt2_dk", "dkonginsanity", "dkong3", "logger", "loggerr2", "dkongl00")
JANKY3D_FRIENDLY = ("dkong", "dkongjr", "ckong", "ckongpt2", "bigkong",
                    "pacman", "puckman", "mspacman", "panic",
                    "a2600_dk", "a2600_dk", "a2600_dk_2", "a2600_dk_ghouls", "a2600_dk_popeye2",
                    "a2600_dk_vector_bw", "a2600_dk_xmas_dp", "a2600_dk_dragon", "a2600_dk_new", "coleco_dk",
                    "intv_intykong")
PACTRAINER_FRIENDLY = ("pacman", "puckman")

# Roms that are not fully compatible
HUD_UNFRIENDLY = ["dkongduel", "dkongkonkey"]
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
LIGHTBROWN = (238, 117, 17)
BROWN = (172, 5, 7)
LIGHTGREY = (164, 164, 164)
GREY = (128, 128, 128)
MIDGREY = (104, 104, 104)
DARKGREY = (40, 40, 40)
BRIGHTRED = (238, 75, 43)

# Alpha channel value for faded/locked arcade machines
FADE_LEVEL = 40

# Sequential list of arcade machine slot locations (x, y) starting with location 1.
SLOTS = (
    (2, 226), (34, 226), (50, 226), (94, 226), (114, 225), (130, 224), (146, 223), (162, 222), (210, 219),
    (194, 198), (146, 195), (130, 194), (114, 193), (82, 191), (66, 190), (50, 189), (2, 186),
    (18, 165), (50, 163), (82, 161), (130, 158), (146, 157), (162, 156), (210, 153),
    (194, 132), (146, 129), (130, 128), (98, 126), (82, 125), (50, 123), (18, 121), (2, 120),
    (50, 97), (98, 94), (114, 93), (130, 92), (146, 91), (162, 90), (210, 87),
    (194, 66), (162, 64), (146, 63), (112, 62), (92, 62), (2, 62),
    (90, 34),

    (18, 226), (34, 226), (50, 226), (90, 226), (114, 226), (130, 226), (146, 226), (162, 226), (178, 226), (194, 226),
    (26, 186), (42, 186), (58, 186), (82, 186), (114, 186), (130, 186), (154, 186), (170, 186), (186, 186),
    (34, 146), (50, 146), (82, 146), (114, 146), (130, 146), (154, 146),
    (42, 106), (74, 106), (90, 106), (122, 106), (138, 106), (170, 106),
    (42, 66), (82, 66), (170, 66),
    (106, 26),

    (2, 226), (34, 226), (50,226), (90, 226), (106, 226), (122, 226), (138, 226), (154, 226), (178, 226), (209, 226),
    (34, 196), (82, 193), (99, 192), (114, 192), (130, 193), (146, 194), (178, 196),
    (34, 162), (82, 165), (116, 166), (131, 165), (146, 164), (178, 162), (210, 160),
    (34, 132), (82, 129), (98, 128), (114, 128), (130, 129), (146, 130),
    (34, 98), (67, 100), (83, 101), (130, 98), (146, 97), (162, 96), (210, 93),
    (178, 65), (162, 64), (146, 63), (112, 62), (92, 62), (2, 62),
    (90, 34),

    (2, 226), (34, 226), (50, 226), (90, 226), (106, 226), (122, 226), (146, 226), (162, 226), (178, 226), (209, 226),
    (8, 186), (34, 186), (50, 186), (90, 186), (122, 186), (154, 186), (174, 186), (202, 186),
    (2, 146), (34, 146), (50, 146), (90, 146), (106, 146), (122, 146), (154, 146), (174, 146), (202, 146),
    (33, 106), (52, 106), (67, 106), (90, 106), (122, 106), (154, 106), (174, 106), (210, 106),
    (2, 66), (90, 66), (106, 66), (138, 66), (154, 66), (170, 66), (186, 66), (208, 66),
    (90, 34),

    (2, 226), (18, 226), (50, 226), (116, 226), (134, 226), (152, 226), (178, 226), (194, 226),
    (18, 195), (34, 191), (50, 195), (66, 195), (98, 191), (116, 195), (134, 195), (152, 195), (178, 195), (194, 195),
    (34, 162), (50, 166), (98, 162), (134, 166), (152, 166), (178, 166), (194, 166),
    (130, 136), (149, 136), (164, 136), (194, 136), (210, 136),
    (34, 102), (50, 106), (98, 102), (116, 106), (132, 106), (148, 106), (194, 106),
    (194, 76),
    (154, 66), (138, 66), (110, 66), (90, 66), (2, 66),
    (90, 34),

    (2, 226), (34, 226), (50, 226), (94, 226), (114, 225), (130, 224), (146, 223), (162, 222), (194, 220), (210, 219),
    (146, 195), (130, 194), (114, 193), (82, 191), (66, 190), (50, 189), (20, 187), (1, 186),
    (50, 163), (82, 161), (130, 158), (146, 157), (162, 156), (194, 154), (210, 153),
    (146, 129), (130, 128), (98, 126), (82, 125), (50, 123), (20, 121), (1, 120),
    (50, 97), (98, 94), (114, 93), (130, 92), (146, 91), (162, 90), (194, 88), (210, 87),
    (162, 64), (146, 63), (114, 62), (90, 62), (2, 62),
    (98, 34),

    (2, 226), (34, 226), (50, 226), (94, 226), (114, 225), (130, 224), (146, 223), (162, 222), (194, 220), (210, 219),
    (194, 198), (146, 195), (130, 194), (114, 193), (82, 191), (66, 190), (34, 188), (18, 187), (1, 186),
    (31, 164), (82, 161), (98, 160), (130, 158), (162, 156), (194, 154), (210, 153),
    (194, 132), (130, 128), (98, 126), (82, 125), (66, 124), (1, 120),
    (66, 96), (98, 94), (114, 93), (130, 92), (146, 91), (162, 90), (194, 88), (210, 87),
    (194, 66), (162, 64), (146, 63), (130, 62), (90, 62), (2, 62),
    (98, 34),

    (2, 226), (34, 226), (50, 226), (66, 226), (93, 226), (109, 226), (125, 226), (141, 226), (157, 226), (178, 225), (210, 223),
    (194, 195), (178, 195), (160, 194), (140, 194), (124, 194), (108, 194), (82, 194), (66, 194), (50, 194), (34, 193), (2, 191),
    (18, 164), (34, 163), (50, 162), (78, 162), (94, 162), (124, 162), (140, 162), (156, 162), (178, 161), (210, 159),
    (194, 130), (178, 131), (147, 130), (131, 130), (115, 130), (99, 130), (83, 130), (50, 130), (34, 129), (2, 128),
    (18, 100), (34, 99), (50, 98), (66, 98), (99, 98), (115, 98), (131, 98), (147, 98), (162, 97), (178, 96), (210, 95),
    (194, 63), (178, 63), (162, 62), (146, 62), (112, 62), (92, 62), (2, 62),
    (90, 34)
)

# Range of slots that appear on each stage
SLOTS_PER_STAGE = (0, 46), (46, 81), (81, 125), (125, 169), (169, 213), (213, 259), (259, 306), (306, 367)

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

# Stage specific positions, colours etc
GRAPHICS_THEME = "dk", "dk", "dk", "dk", "dk", "ck", "ck", "pm"
BONUS_COLORS = ((CYAN, MAGENTA), (YELLOW, MIDBLUE), (WHITE, WHITE), (WHITE, LIGHTBROWN), (CYAN, MAGENTA), (WHITE, WHITE),
                (WHITE, WHITE), (WHITE, BLUE))
HAMMER_POSXY = (((16, 98), (167, 190)), ((8, 140), (104, 100)), ((195, 128), (195, 192)), ((12, 140), (104, 178)),
                ((3, 159), (206, 70)), ((32, 96), (167, 190)), ((32, 96), (167, 190)), ((52, 94), (158, 191)))
TELEPORT_TO_POSXY = (((164, 193), (20, 92)), ((101, 98), (11, 138)), ((192, 190), (192, 126)), ((104, 180), (16, 140)),
                     ((206, 72), (3, 161)), ((164, 193), (32, 92)), ((164, 193), (32, 92)), ((158, 198), (52, 98)))
OILCAN_POSXY = (16, 232), (172, 152), (16, 232), (104, 128), (68, 112), (16, 232), (16, 232), (16, 232)
WARP_ARROW_POSXY = (20, 246), (176, 166), (20, 246), (108, 142), (72, 126), (20, 246), (20, 246), (20, 246)
PAULINE_POSXY = (0, 0), (16, -8), (0, 0), (0, 0), (0, 0), (8, 0), (8, 0), (0, 0)
KONG_POSXY = (0, 0), (80, 4), (0, 0), (0, 4), (0, 4), (0, 0), (0, 0), (0, 0)
COIN_GRAB_POSXY = (67, 73), (147, 77), (67, 73), (67, 77), (67, 77), (67, 73), (67, 73), (67, 73)
COIN_AWARD_POSX = 0, 112, 0, 28, 0, 0, 0, 0
LADDER_CHANCE = 3, 2, 3, 3, 3, 3, 3, 3   # Chance of coin rolling down a ladder (1 = always, 2 = 1/2 etc.) by stage

# Jumpman's x position when centre of ladder by stage
LADDER_CENTRES = ((28, 60, 68, 76, 84, 92, 108, 124, 164, 180),
                  (4, 12, 20, 28, 60, 68, 76, 100, 140, 148, 180, 188, 196, 204, ),
                  (20, 50, 60, 76, 116, 124, 156, 164, 175, 188),
                  (12, 20, 60, 76, 124, 132, 140, 188, 196),
                  (4, 12, 60, 76, 116, 124, 164, 180, 204),
                  (28, 60, 68, 76, 84, 92, 108, 124, 164, 180),
                  (12, 28, 60, 44, 76, 84, 92, 108, 148, 164, 180),
                  (20, 60, 68, 76, 84, 92, 108, 124, 164, 188))

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
INSTALL_INFO = ["Hey, we're installing everything now", "Hang tight while we sort it all out", "It shouldn't take too much longer"]
DOWNLOAD_INFO = ["Hey, we're downloading the add-on", "It's jam packed with cool stuff",  "Hang on in there"]

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
    "The zip should contain only",
    "the following files:", ""]

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
through all the challenging 
stages and rescues Pauline 
from the top of the building.  

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
  killscreen at level 22-1?

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
  Paul Goes, Sockmaster,
  Jeff Kulczycki, 
  Mike Mika & Clay Cowgill,
  Kirai Shouen & 125scratch,
  Don Hodges, Tim Appleton, 
  Vic20 George

Donkey Kong hack resource:
  furrykef

Feedback and feature ideas:
  Superjustinbros

Playlist music:
  LeviR.star's Music,
  Nintega Dario,
  MyNameIsBanks,
  SanHolo,
  MotionRide Music,
  Buckner & Garcia,
  Sascha Zeidler,
  Mitchel Gatzke,
  Chiptunema,
  RetroKid and Pringles
"""

# Console Addon Specific
if ARCH == "win64":
    ADDON_URL = "https://www.dropbox.com/scl/fi/q2my1al3f3tncjxsje6ye/dkafe_console_addon_pack_v11.zip?rlkey=cazdr42gk275qjyoo505rgyaf&dl=0"
else:
    ADDON_URL = "https://www.dropbox.com/scl/fi/0sfvyyko5wbemhj2brv15/dkafe_console_addon_pack_v11_reduced.zip?rlkey=5jnoj84fn0ww7eqnrpllh59co&dl=0"
if ENABLE_ADDONS:
    VERSION += "+"
ROMLIST_FILES = ["romlist.csv", "romlist_addon.csv" if ENABLE_ADDONS else ""]

RECOGNISED_SYSTEMS = {
    "arcade": "Arcade",
    "a2600": "Atari 2600",
    "a5200": "Atari 5200",
    "a7800": "Atari 7800",
    "a800xl": "Atari 8 Bit Computer (A800)",
    "apfimag": "APF Imagination Machine",
    "atarist": "Atari ST",
    "adam": "Coleco Adam",
    "amiga": "Commodore Amiga",
    "apple2e": "Apple ][",
    "arduboy": "Arduino Arduboy Handheld",
    "atom":"Acorn Atom",
    "bbcb": "BBC Micro",
    "c64": "Commodore 64",
    "c64p": "Commodore 64",
    "cgenie": "EACA Colour Genie EG2000",
    "coco3": "Tandy Colour Computer 3",
    "coleco": "Colecovision",
    "cpm": "CP/M",
    "cpc6128":"Amstrad CPC",
    "crvision":"VTech Creativision",
    "dos":"Microsoft DOS",
    "dragon32":"Dragon 32",
    "ecv":"Epoch Cassette Vision",
    "exl100":"Exelvision EXL 100",
    "fds":"Famicom Disk System",
    "gameboy":"Nintendo Gameboy",
    "gbcolor":"Nintendo Gameboy Color",
    "genesis":"Sega Genesis/Megadrive",
    "gnw":"Game and Watch",
    "hbf900a":"MSX",
    "intv":"Intellivision",
    "jupace":"Jupiter ACE",
    "laser310":"VTech Laser-VZ",
    "lcd":"LCD and Handheld Games",
    "lowresnx":"LowRes NX Fantasy Console",
    "mc10":"Tandy MC10",
    "mo5":"Thomson MO5",
    "mz700":"Sharp MZ-700",
    "nes":"Nintendo Entertainment System",
    "nds":"Nintendo DS",
    "oric1":"Tangerine ORIC",
    "orica":"Tangerine ORIC",
    "pc":"Microsoft Windows",
    "pc88":"NEC PC-88",
    "pcw10":"Amstrad PCW",
    "pet4032":"Commodore PET",
    "pico8":"Pico-8 Fantasy Console",
    "pokitto":"Pokitto DIY Handheld",
    "plus4":"Commodore C16/Plus4",
    "sg1000":"Sega SG-1000",
    "sms":"Sega Master System",
    "smskr":"Sega Master System",
    "snes":"Super Nintendo Entertainment System",
    "spectrum":"Sinclair ZX Spectrum 48K",
    "spec128":"Sinclair ZX Spectrum 128K",
    "supervision":"Watara Supervision",
    "ti99_4a":"Texas Instruments TI-99",
    "tic80":"TIC-80 Fantasy Console",
    "trs80":"Tandy TRS-80",
    "vic20":"Commodore VIC-20",
    "vic20_se":"Commodore VIC-20",
    "uzebox":"Uzebox - Atmega Game Console",
    "x1":"Sharp X1",
    "zx81":"Sinclair ZX80/81"}

# System specific media switches when not simply "-cart"
SYSTEM_MEDIA = {
    "adam": "-cart1",
    "apple2e": "-gameio joy -flop1",
    "apfimag": "-cart basic -cass",
    "bbcb": "-flop1",
    "c64": "-joy1 joy -quik",
    "c64p": "-joy1 joy -quik",
    "cgenie": "-ram 32k -cass",
    "coco3": "-flop1",
    "cpc6128": "-flop1",
    "dragon32": "-cass",
    "fds": "-flop1",
    "hbf900a": "-flop1",
    "jupace": "-ram 32k -dump",
    "laser310": "-dump",
    "mo5": "-cass",
    "mz700": "-cass",
    "oric1": "-cass",
    "orica": "-cass",
    "pcw10": "-flop",
    "pet4032": "-quik",
    "plus4": "-quik",
    "spectrum": "-nokeepaspect -dump",
    "spec128": "-nokeepaspect -dump",
    "vic20": "-quik",
    "vic20_se": "-quik",
    "x1": "-floppydisk1",
    "zx81": "-cass"}

# Game specific media to override the system media
GAME_MEDIA = {
    "adam_dk_junior":"-flop1",
    "adam_dk_super":"-flop1",
    "apfimag_dk": "-speed 1.1 -cart basic -cass",
    "c64_bonkeykong":"-flop",
    "c64_superbonkeykong":"-flop",
    "c64_eskimo_eddie":"-flop",
    "c64_monkeykong":"-flop",
    "c64_barrel_bunger":"-flop",
    "c64_logger":"-speed 1.5 -quik",
    "dragon32_baby_monkey":"-ramsize 64k -flop1",
    "dragon32_dk_reloaded":"-ramsize 64k -flop1",
    "gbcolor_dk_arcade":"-plugin gbstage -cart",
    "hbf900a_apeman":"-cart1",
    "hbf900a_congo":"-cass",
    "plus4_crazyjump":"-joy1 joy -quik",
    "plus4_dkplus":"-joy1 joy -quik",
    "spectrum_ape_escape":"-cass",
    "spectrum_dk3_micro_vs":"-cass",
    "spectrum_dk_reloaded":"-cass",
    "spectrum_dk_remake":"-cass",
    "spectrum_baby_monkey":"-cass",
    "spectrum_eskimo_eddie":"-cass",
    "spectrum_kongs_revenge":"-cass",
    "spectrum_crazykongcity":"-cass",
    "spectrum_dk_techdemo":"-cass",
    "spectrum_spec_kong":"-speed 1.1 -cass",
    "spectrum_crazycong":"-cass",
    "spectrum_wrathofkong":"-speed 1.1 -cass",
    "vic20_konkeykong": "-cass",
    "vic20-se_logger": "-cass",
    "vic20-se_mickybricky": "-cass",
    "vic20_fast_eddie":"-cart",
    "vic20-se_witchway":"-cart",
    "vic20-se_dkjr_gnw":"-exp 16k -quik",
    "vic20-se_dk_ackenhausen":"-exp 16k -quik"}

STATEKEEP_MEDIA_EXCEPTIONS = ("gbcolor_dk_gw_gallery2", "gbcolor_dk_gw_gallery3", "apfimag_dk", "apfimag_dk2",
                              "apfimag_dk_jr", "apfimag_heartattack")

WIN64_ONLY_STAGES = 5, 6
WIN64_ONLY_SYSTEMS = "pc", "dos", "cpm"

# use scan code or see keycodes at: https://github.com/boppreh/keyboard/blob/master/keyboard/_canonical_names.py
KEYBOARD_REMAP = {
    "cpm_ladder": "down>z|up>a|1>p|2>l|5>i|right>.|left>,|ctrl>space|alt>b|esc>forcequit:dosbox-x.exe",
    "dos_aldo": "ctrl>space",
    "dos_aldo2": "ctrl>space",
    "dos_aldo3": "ctrl>space",
    "dos_davikong": "ctrl>f1|num 2>n,enter|num 1>1,enter|esc>forcequit:dosbox-x.exe",
    "dos_heroman": "ctrl>enter,space|alt>space|esc>forcequit:dosbox-x.exe",
    "dos_dk": "y>n|ctrl>space|esc>forcequit:dosbox-x.exe|esc>forcequit:dosbox-x.exe",
    "dos_dkpc": "ctrl>space,f1|1>f1|2>f2|3>f3|esc>forcequit:dosbox-x.exe",
    "dos_kong": "num 1>enter|tab>esc|esc>forcequit:dosbox-x.exe",  # TAB to access and save in-game settings
    "dos_kongsrev": "esc>forcequit:dosbox-x.exe",
    "dos_mamedk": "num 5>num 3|num 2>enter",
    "dos_willy": "num 1>enter|ctrl>space",
    "pc_arduboy_kong":"ctrl>a|alt>b|p>s|1>a|2>b|esc>forcequit:projectabe.exe",
    "pc_arduboy_kong2":"ctrl>a|alt>b|p>s|1>a|2>b|esc>forcequit:projectabe.exe",
    "pc_arduboy_dkjr":"ctrl>a|alt>b|p>s|1>a|2>b|esc>forcequit:projectabe.exe",
    "pc_atarist_mb":"ctrl>space",
    "pc_atarist_kidkong": "delayspace>22",
    "pc_atarist_junior":"ctrl>ctrl,space|num 1>a|num 2>b|delayspace>5.25",
    "pc_atom_kong":"left>z|right>c|up>s|down>x|ctrl>shift,space|esc>forcequit:atomulator.exe",
    "pc_atom_crazykongcity1":"left>o|right>p|up>q|down>a|ctrl>m,q,1|2>1|3>1|esc>forcequit:atomulator.exe",
    "pc_atom_crazykongcity2":"left>o|right>p|up>q|down>a|ctrl>m,q,1|2>1|3>1|esc>forcequit:atomulator.exe",
    "pc_atom_dkjunior":"left>o|right>p|up>q|down>a|ctrl>m,q,1|2>1|3>1|esc>forcequit:atomulator.exe",
    "pc_atom_dkjunior2":"left>o|right>p|up>q|down>a|ctrl>m,q,1|2>1|3>1|esc>forcequit:atomulator.exe",
    "pc_atom_dkreloaded":"left>o|right>p|up>q|down>a|ctrl>space,m,1|2>1|3>1|esc>forcequit:atomulator.exe",
    "pc_atom_dkreloadedagain":"left>o|right>p|up>q|down>a|ctrl>space,m,1|2>1|3>1|esc>forcequit:atomulator.exe",
    "pc_atom_baby_monkey_alba":"left>o|right>p|up>q|down>a|ctrl>space,m,1|2>1|3>1|esc>forcequit:atomulator.exe",
    "pc_crashtime_plumber": "ctrl>space",
    "pc_dk_aa": "1>enter|2>enter|ctrl>x",
    "pc_dk_craze": "esc>forcequit:stdrt.exe",
    "pc_dk_jr_remake": "num 1>enter|ctrl>space|esc>forcequit",
    "pc_dk_plus": "left>a|right>d|up>w|down>s|1>enter|ctrl>space,enter",
    "pc_dk_remake":"num 1>enter|ctrl>space|esc>forcequit",
    "pc_dkjr_beat":"left>f|right>j|ctrl>space|up>f,j",
    "pc_cookout":"ctrl>z|alt>x",
    "pc_ecv_monster_mansion": "left>a|right>d|ctrl>h|1>e|esc>forcequit|maximize>?PD777",
    "pc_exl100_kong":"ctrl>space|1>space,alt+enter|esc>forcequit|maximize>KONG pour Windows",
    "pc_exl100_monkeykong":"5>n|2>n|alt>n|ctrl>space|esc>forcequit",
    "pc_jumpman_rtx":"num 1>enter|num 5>enter|ctrl>space|esc>forcequit|delayenter>8.25",
    "pc_hbf900a_congo":"1>space|ctrl>space|esc>forcequit:zesarux.exe",
    "pc_lowresnx_denis_kogne":"ctrl>z",
    "pc_mc10_kong":"ctrl>space|left>a|right>s|up>w|down>z",
    "pc_nes_dk_hdpack":"alt>ctrl",
    "pc_nes_dkjr_hdpack":"alt>ctrl",
    "pc_pico8_ape":"ctrl>z|esc>forcequit:zepto8.exe",
    "pc_pico8_denis_kogne": "ctrl>x|esc>forcequit:zepto8.exe",
    "pc_pico8_dinkyking": "ctrl>x|esc>forcequit:zepto8.exe",
    "pc_pico8_dinkyking1": "ctrl>x|esc>forcequit:zepto8.exe",
    "pc_pico8_dinkyking2": "ctrl>x|esc>forcequit:zepto8.exe",
    "pc_pico8_dinkyking3": "ctrl>x|esc>forcequit:zepto8.exe",
    "pc_pico8_dinkyking4": "ctrl>x|esc>forcequit:zepto8.exe",
    "pc_pokitto_dkjr":"ctrl>a|alt>b",
    "pc_pokitto_kong2":"ctrl>a|alt>b",
    "pc_dkme_alien":"ctrl>space|esc>forcequit:dkme.exe",
    "pc_dkme_bigtrouble": "ctrl>space|esc>forcequit:dkme.exe",
    "pc_dkme_conan": "ctrl>space|esc>forcequit:dkme.exe",
    "pc_dkme_exorcist": "ctrl>space|esc>forcequit:dkme.exe",
    "pc_dkme_firstblood": "ctrl>space|esc>forcequit:dkme.exe",
    "pc_dkme_flashgordon": "ctrl>space|esc>forcequit:dkme.exe",
    "pc_dkme_gremlins": "ctrl>space|esc>forcequit:dkme.exe",
    "pc_dkme_raiders":"ctrl>space|esc>forcequit:dkme.exe",
    "pc_dkme_starwars": "ctrl>space|esc>forcequit:dkme.exe",
    "pc_dkme_totalrecall": "ctrl>space|esc>forcequit:dkme.exe",
    "pc_kidnappers_inc":"ctrl>space|1>space|esc>forcequit",
    "pc_tic80_denis_kogne":"tab>esc|ctrl>z|alt>x|esc>forcequit:tic80.exe",
    "pc_kong_jr_gnw":"ctrl>x|esc>forcequit",
    "pc_pc88_dk3":"ctrl>space|esc>forcequit:quasi88.exe",
    "pc_snes_dk4_riseandrepeat":"alt>5|esc>forcequit:snes9x.exe",
    "pc_supervision_superkong":"ctrl>a|alt>b|esc>forcequit:wataroo.exe",
    "pc_tic80_kongremake":"tab>esc|ctrl>z|esc>forcequit:tic80.exe",
    "pc_trs80_ape":"ctrl>space|p>enter,1|num 2>home|num 1>enter,1",
    "pc_trs80_kong":"ctrl>space|num 1>home",
    "pc_trs80_dk":"ctrl>space|num 1>enter,1",
    "pc_trs80_killergorilla":"ctrl>space",
    "pc_trs80_skyscraper":"ctrl>space|1>1,n,\\,enter",
    "pc_trs80_dk_reloaded":"ctrl>space,1|2>1|left>o|right>p|up>q|down>a",
    "pc_trs80_dk_reloaded_again":"ctrl>space,1|2>1|left>o|right>p|up>q|down>a",
    "pc_trs80_dk_junior":"ctrl>space,1|2>1|left>o|right>p|up>q|down>a",
    "pc_trs80_dk_junior2":"ctrl>space,1|2>1|left>o|right>p|up>q|down>a",
    "pc_trs80_baby_monkey":"ctrl>space,1|2>1|left>o|right>p|up>q|down>a",
    "pc_trs80_crazykongcity":"left>o|right>p|up>q|down>a|ctrl>space,q,1|2>1",
    "pc_uzebox_dkong":"ctrl>a|1>enter|esc>forcequit:uzem.exe",
    "pc_spectrum_dkjr2":"left>o|right>p|up>q|down>a|ctrl>m|num 2>num 1|num 3>num 1|alt>n|esc>forcequit:zesarux.exe"}

# Sound setup
pygame.mixer.init(frequency=48000)
background_channel = pygame.mixer.Channel(1)
intermission_channel = pygame.mixer.Channel(2)
award_channel = pygame.mixer.Channel(3)
playlist = pygame.mixer.music

# Initialisation
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
dkafe_theme.title_background_color = BLACK
dkafe_theme.title_font_color = RED
dkafe_theme.title_bar_style = pymenu.widgets.MENUBAR_STYLE_SIMPLE
dkafe_theme.title_offset = (12, 0)
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
pymenu.controls.JOY_BUTTON_BACK = BUTTON_EXIT


if ARCH == "win32" or ARCH == "win64":
    # Optimise append of menu items by monkey patching the pymenu function
    def _new_append_widget(self, widget):
        if self._columns > 1:
            max_elements = self._columns * self._rows
            if len(self._widgets) + 1 > max_elements:
                raise ValueError(f'total widgets cannot be greater than columns*rows ({max_elements} elements)')

        if not self._widgets:
            self._widgets_tmp = []

        if len(self._widgets) <= 50:
            self._widgets.append(widget)
        else:
            self._widgets_tmp.append(widget)

        if widget._title == "Close Menu":
            self._widgets.extend(self._widgets_tmp)
            self._widgets_tmp.clear()

        if self._index < 0 and widget.is_selectable:
            widget.set_selected()
            self._index = len(self._widgets) - 1

        if self._center_content:
            self.center_content()

        self._widgets_surface = True
        self._render()
    pymenu.Menu._append_widget = _new_append_widget

    # Optimise scrolling speed in large menus by monkey patching the pymenu function
    import pygame_menu.controls as _controls
    import pygame_menu.events as _events
    import pygame_menu.utils as _utils
    import pygame_menu.widgets as _widgets
    def _new_update(self, events):
        """
        Update the status of the Menu using external events.
        The update event is applied only on the current Menu.

        .. note::

            This method should not be used along :py:meth:`pygame_menu.Menu.get_current()`

        :param events: Pygame events as a list
        :type events: list[:py:class:`pygame.event.Event`]
        :return: True if mainloop must be stopped
        :rtype: bool
        """
        assert isinstance(events, list)

        # Check if window closed
        for event in events:
            if event.type == _events.PYGAME_QUIT or (
                    event.type == pygame.KEYDOWN and event.key == pygame.K_F4 and (
                    event.mod == pygame.KMOD_LALT or event.mod == pygame.KMOD_RALT)) or \
                    event.type == _events.PYGAME_WINDOWCLOSE:
                self._current._exit()
                return True

        # If any widget status changes, set the status as True
        updated = False

        # Update mouse
        pygame.mouse.set_visible(self._current._mouse_visible)

        # noinspection PyTypeChecker
        selected_widget = None  # (type: _widgets.core.Widget, None)
        if len(self._current._widgets) >= 1:
            index = self._current._index % len(self._current._widgets)
            selected_widget = self._current._widgets[index]
            if not selected_widget.visible or not selected_widget.is_selectable:
                selected_widget = None

        # Update scroll bars
        if self._current._scroll.update(events):
            updated = True

        # Update the menubar, it may change the status of the widget because
        # of the button back/close
        elif self._current._menubar.update(events):
            updated = True

        # Check selected widget
        elif selected_widget is not None and selected_widget.update(events):
            updated = True

        # Check others
        else:

            # If mouse motion enabled, add the current mouse position to event list
            if self._current._mouse and self._current._mouse_motion_selection:
                mouse_x, mouse_y = pygame.mouse.get_pos()
                events.append(pygame.event.Event(pygame.MOUSEMOTION, {'pos': (mouse_x, mouse_y)}))

            for event in events:  # type: pygame.event.Event

                if event.type == pygame.KEYDOWN:

                    # Check key event is valid
                    if not _utils.check_key_pressed_valid(event):
                        continue

                    if event.key == _controls.KEY_MOVE_DOWN:
                        self._current._select(self._current._index - 1)
                        self._current._sounds.play_key_add()
                    elif event.key == _controls.KEY_MOVE_UP:
                        self._current._select(self._current._index + 1)
                        self._current._sounds.play_key_add()
                    elif event.key == _controls.KEY_LEFT and self._current._columns > 1:
                        self._current._left()
                        self._current._sounds.play_key_add()
                    elif event.key == _controls.KEY_RIGHT and self._current._columns > 1:
                        self._current._right()
                        self._current._sounds.play_key_add()
                    elif event.key == _controls.KEY_BACK and self._top._prev is not None:
                        self._current._sounds.play_close_menu()
                        self.reset(1)  # public, do not use _current
                    elif event.key == _controls.KEY_CLOSE_MENU:
                        self._current._sounds.play_close_menu()
                        if self._current._close():
                            updated = True

                elif self._current._joystick and event.type == pygame.JOYHATMOTION:
                    if event.value == _controls.JOY_UP:
                        self._current._select(self._current._index - 1)
                    elif event.value == _controls.JOY_DOWN:
                        self._current._select(self._current._index + 1)
                    elif event.value == _controls.JOY_LEFT and self._current._columns > 1:
                        self._current._left()
                    elif event.value == _controls.JOY_RIGHT and self._current._columns > 1:
                        self._current._right()

                elif self._current._joystick and event.type == pygame.JOYAXISMOTION:
                    prev = self._current._joy_event
                    self._current._joy_event = 0
                    if event.axis == _controls.JOY_AXIS_Y and event.value < -_controls.JOY_DEADZONE:
                        self._current._joy_event |= self._current._joy_event_up
                    if event.axis == _controls.JOY_AXIS_Y and event.value > _controls.JOY_DEADZONE:
                        self._current._joy_event |= self._current._joy_event_down
                    if event.axis == _controls.JOY_AXIS_X and event.value < -_controls.JOY_DEADZONE and \
                            self._current._columns > 1:
                        self._current._joy_event |= self._current._joy_event_left
                    if event.axis == _controls.JOY_AXIS_X and event.value > _controls.JOY_DEADZONE and \
                            self._current._columns > 1:
                        self._current._joy_event |= self._current._joy_event_right
                    if self._current._joy_event:
                        self._current._handle_joy_event()
                        if self._current._joy_event == prev:
                            pygame.time.set_timer(self._current._joy_event_repeat, _controls.JOY_REPEAT)
                        else:
                            pygame.time.set_timer(self._current._joy_event_repeat, _controls.JOY_DELAY)
                    else:
                        pygame.time.set_timer(self._current._joy_event_repeat, 0)

                elif event.type == self._current._joy_event_repeat:
                    if self._current._joy_event:
                        self._current._handle_joy_event()
                        pygame.time.set_timer(self._current._joy_event_repeat, _controls.JOY_REPEAT)
                    else:
                        pygame.time.set_timer(self._current._joy_event_repeat, 0)

                # Select widget by clicking
                elif self._current._mouse and event.type == pygame.MOUSEBUTTONDOWN and \
                        event.button in (1, 2, 3):  # Don't consider the mouse wheel (button 4 & 5)

                    # If the mouse motion selection is disabled then select a widget by clicking
                    if not self._current._mouse_motion_selection:
                        for index in range(len(self._current._widgets)):
                            widget = self._current._widgets[index]
                            # Don't consider the mouse wheel (button 4 & 5)
                            if widget.is_selectable and widget.visible and \
                                    self._current._scroll.collide(widget, event):
                                self._current._select(index)
                                break

                    # If mouse motion selection, clicking will disable the active state
                    # only if the user clicked outside the widget
                    else:
                        if selected_widget is not None:
                            if not self._current._scroll.collide(selected_widget, event):
                                selected_widget.active = False

                # Select widgets by mouse motion, this is valid only if the current selected widget
                # is not active and the pointed widget is selectable
                elif self._current._mouse_motion_selection and event.type == pygame.MOUSEMOTION and \
                        (selected_widget is not None and not selected_widget.active or selected_widget is None):
                    for index in range(len(self._current._widgets)):
                        widget = self._current._widgets[index]  # type: _widgets.core.Widget
                        if self._current._scroll.collide(widget, event) and widget.is_selectable and widget.visible:
                            self._current._select(index)
                            break

                # Mouse events in selected widget
                elif self._current._mouse and event.type == pygame.MOUSEBUTTONUP and selected_widget is not None:
                    self._current._sounds.play_click_mouse()
                    # Don't consider the mouse wheel (button 4 & 5)
                    if event.button in (1, 2, 3) and self._current._scroll.collide(selected_widget, event):
                        new_event = pygame.event.Event(event.type, **event.dict)
                        new_event.dict['origin'] = self._current._scroll.to_real_position((0, 0))
                        new_event.pos = self._current._scroll.to_world_position(event.pos)
                        selected_widget.update((new_event,))  # This widget can change the current Menu to a submenu
                        updated = True  # It is updated
                        break

                # Touchscreen event:
                elif self._current._touchscreen and event.type == pygame.FINGERDOWN:
                    # If the touchscreen motion selection is disabled then select a widget by clicking
                    if not self._current._touchscreen_motion_selection:
                        for index in range(len(self._current._widgets)):
                            widget = self._current._widgets[index]
                            # Don't consider the mouse wheel (button 4 & 5)
                            if self._current._scroll.collide(widget, event) and \
                                    widget.is_selectable and widget.visible:
                                self._current._select(index)
                                break

                    # If touchscreen motion selection, clicking will disable the active state
                    # only if the user clicked outside the widget
                    else:
                        if selected_widget is not None:
                            if not self._current._scroll.collide(selected_widget, event):
                                selected_widget.active = False

                # Select widgets by touchscreen motion, this is valid only if the current selected widget
                # is not active and the pointed widget is selectable
                elif self._current._touchscreen_motion_selection and event.type == pygame.FINGERMOTION and \
                        (selected_widget is not None and not selected_widget.active or selected_widget is None):
                    for index in range(len(self._current._widgets)):
                        widget = self._current._widgets[index]  # type: _widgets.core.Widget
                        if self._current._scroll.collide(widget, event) and widget.is_selectable:
                            self._current._select(index)
                            break

                # Touchscreen events in selected widget
                elif self._current._touchscreen and event.type == pygame.FINGERUP and selected_widget is not None:
                    self._current._sounds.play_click_mouse()

                    if self._current._scroll.collide(selected_widget, event):
                        new_event = pygame.event.Event(pygame.MOUSEBUTTONUP, **event.dict)
                        new_event.dict['origin'] = self._current._scroll.to_real_position((0, 0))
                        finger_pos = (event.x * self._current._window_size[0],
                                      event.y * self._current._window_size[1])
                        new_event.pos = self._current._scroll.to_world_position(finger_pos)
                        selected_widget.update((new_event,))  # This widget can change the current Menu to a submenu
                        updated = True  # It is updated
                        break

        # Check if the menu widgets size changed, if True, updates the surface
        # forcing the rendering of all widgets
        menu_surface_needs_update = False
        if len(self._current._widgets) > 0:
            for widget in self._current._widgets:  # type: _widgets.core.Widget
                menu_surface_needs_update = menu_surface_needs_update or widget.surface_needs_update()

        # 10 yard -  patch for improved speed on large menus
        menu_surface_needs_update = False

        if menu_surface_needs_update:
            self._current._widgets_surface = None

        # A widget has closed the Menu
        if not self.is_enabled():
            updated = True

        return updated
    pymenu.Menu.update = _new_update
