import os
import pygame
import pygame_menu as pymenu

# Graphic Config
TITLE = 'DONKEY KONG ARCADE FE'
GRAPHICS = (224, 256)  # internal x, y resolution of game graphics
TOPLEFT = (0, 0)       # position of top left corner
CLOCK_RATE = 45        # Clock rate/timing - tweak this to get the right speed

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

# Joystick Options and Button Assignments (Device 1 buttons start from 0,  Device 2 buttons start from 20)
USE_JOYSTICK = False
BUTTON_JUMP = 0
BUTTON_ACTION = 1
BUTTON_P1 = 9
BUTTON_P2 = 29
BUTTON_EXIT = 3
BUTTON_COIN = 7

# Options
CONFIRM_EXIT = True
FULLSCREEN = True
FREE_PLAY = True             # Jumpman does not have to pay to play
UNLOCK_MODE = True           # Arcade machines are unlocked as Jumpman's score increases
ENABLE_MENU = True           # Allow selection from the quick access game list
ENABLE_HAMMERS = True        # Show hammers and enable teleport between hammers in the frontend

AWARDS = [0, 1000, 2000]     # Coins awared for competing. Fail, minimum and bonus scores when competing
PLAY_COST = 100              # How much it costs to play an arcade machine. Integer
LIFE_COST = 150              # How many coins Jumpman loses when time runs out
CREDITS = 0                  # Automatically set credits in MAME at start of game - when using interface
AUTOSTART = 0                # Automatically start the game in MAME (by simulating P1 start) when using interface
INACTIVE_TIME = 20           # Screensaver with game instructions after period in seconds of inactivity. Integer
TIMER_START = 5000           # Timer starts countdown from. Integer
COIN_VALUES = [0, 50, 100]   # How many points awarded for collecting a coin. Integer
COIN_FREQUENCY = 2           # How frequently DK will grab a coin (1 = always, 2 = 1/2,  3 = 1/3 etc). Integer
COIN_HIGH = 4                # Frequency of coin being higher value (1 = always, 2 = 1/2,  3 = 1/3 etc). Integer
COIN_SPEED = 1.6             # Number of pixels to move coin per display update. Decimal
COIN_CYCLE = 0.15            # How often the coin sprite is updated. Decimal
LADDER_CHANCE = 3            # Chance of coin dropping down a ladder (1 = always, 2 = 1/2,  3 = 1/3 etc). Integer

# Hacks
HACK_TELEPORT = 0            # Hack DK to allow teleport between hammers. 0 or 1
HACK_NOHAMMERS = 0           # Hack DK to remove hammers.  0 or 1
HACK_PENALTY = 0             # Hack DK to lose penalty points instead of lives.
HACK_LAVA = 0                # Hack DK to limit time for ascending the stage due to rising lava. 0 or 1.

# Root directory of frontend
ROOT_DIR = os.getcwd()

# Emulator and rom path defaults
OPTIONS = '-skip_gameinfo -video gdi -keepaspect -unevenstretch'
ROM_DIR = '<ROOT>/roms'
EMU_1 = '<ROOT>/dkwolf/dkwolf196 <OPTIONS> -rompath <ROM_DIR>'
EMU_2 = '<ROOT>/dkwolf/dkwolf196 -record <NAME>_<DATETIME>.inp <OPTIONS> -rompath <ROM_DIR>'
EMU_3, EMU_4, EMU_5, EMU_6, EMU_7, EMU_8 = (None,) * 6

# Patch directory (for provided patch files)
PATCH_DIR = os.path.join(ROOT_DIR, "patch")

# Above defaults can be overridden in the settings.txt file
if os.path.exists("settings.txt"):
    with open("settings.txt", 'r') as sf:
        for setting in sf.readlines():
            if setting.count("=") == 1 and not setting.startswith("#"):
                key, value = setting.replace("\n", "").split("=")
                key = key.strip()
                value = value.strip()
                try:
                    if key.startswith("CONTROL_"):
                        globals()[key] = pygame.key.key_code(value)
                    elif value.isnumeric():
                        globals()[key] = int(value)
                    else:
                        globals()[key] = value.replace("<ROOT>", ROOT_DIR)\
                            .replace("<ROM_DIR>", ROM_DIR).replace("<OPTIONS>", OPTIONS)
                except KeyError:
                    print(f'Unknown setting "{key.strip()}" in settings.txt file')
                    pygame.quit()
                    exit()

# Expected location of original DK zip (not provided with software)
DKONG_ZIP = os.path.join(ROM_DIR, "dkong.zip")

# Colours
RED = (232, 7, 10)
BLUE = (4, 3, 255)
BLACK = (0, 0, 0)
BROWN = (172, 5, 7)
CYAN = (20, 243, 255)
MAGENTA = (236, 49, 148)
WHITE = (254, 252, 255)
PINK = (255, 188, 160)
GREY = (128, 128, 128)

# Alpha value for faded/locked arcade machines
FADE_LEVEL = 85

# Sequential list of arcade machine slot locations (x, y) starting with location 1.
SLOTS = [
    (2, 226), (34, 226), (50, 226), (66, 226), (98, 226), (114, 225), (130, 224), (146, 223), (162, 222), (210, 219),
    (194, 198), (146, 195), (130, 194), (114, 193), (82, 191), (66, 190), (50, 189), (2, 186),
    (18, 165), (50, 163), (82, 161), (130, 158), (146, 157), (162, 156), (210, 153),
    (194, 132), (146, 129), (130, 128), (98, 126), (82, 125), (50, 123), (18, 121), (2, 120),
    (50, 97), (98, 94), (114, 93), (130, 92), (146, 91), (162, 90), (210, 87),
    (194, 66), (162, 64), (146, 63), (114, 62), (90, 62), (2, 62)
]

# Control assignments. Links global variables to event data.  These shouldn't be changed.
CONTROL_ASSIGNMENTS = [
  ("left", CONTROL_LEFT),
  ("right", CONTROL_RIGHT),
  ("up", CONTROL_UP),
  ("down", CONTROL_DOWN),
  ("jump", CONTROL_JUMP),
  ("start", CONTROL_P1)]

# Sounds that are played during walk sequence. Not all steps will trigger a sound.
WALK_SOUNDS = {
  1: "sounds/walk0.wav",
  5: "sounds/walk1.wav",
  9: "sounds/walk2.wav"}

# Defines scene numbers in the intro when sounds should be played
SCENE_SOUNDS = {
  160: "sounds/climb.wav",
  481: "sounds/stomp.wav",
  712: "sounds/roar.wav",
  856: "sounds/howhigh.wav"}

# Defines when icons should be displayed on the climb intro.  The entries relate to the various platforms.
# data is: appear from scene, appear to scene, below y, above y, smash animation to scene)
SCENE_ICONS = [
    (481, 856, 68, 40, 502),
    (544, 856, 101, 68, 565),
    (580, 856, 134, 101, 601),
    (613, 856, 167, 134, 634),
    (646, 856, 200, 167, 667),
    (679, 856, 999, 200, 700),
    (700, 856, 999, 0, 0)]

# Ladder zone detection. The R read from screen map determines were jumpman is relative to a ladder
LADDER_ZONES = [
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
    ("TOP_OF_ANY_LADDER", (60, 170, 180))]

# Sprite helpers
SPRITE_FULL = 15
SPRITE_HALF = 8
JUMP_PIXELS = [-1, ] * 15 + [1, ] * 13

# In game messages and instructions
QUESTION = "WHAT GAME WILL YOU PLAY ?"
COIN_INFO = ['HEY JUMPMAN!', '', 'COLLECT COINS', 'TO PLAY GAMES', '', 'PUSH COIN', 'FOR GAME INFO', '']
FREE_INFO = ['HEY JUMPMAN!', '', 'ALL MACHINES', 'ARE FREE TO PLAY', '', 'PUSH COIN', 'FOR GAME INFO', '']

NO_ROMS_MESSAGE = [
    "NO ROMS WERE FOUND!", "", "", "",
    "FOR THE DEFAULT FRONTEND",
    "PUT DKONG.ZIP & DKONGJR.ZIP",
    "INTO THE DKAFE\ROMS FOLDER",
    "THEN RESTART.", "", "", "",
    "PRESS JUMP BUTTON",
    "TO CONTINUE"]

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

Yes, the plot is thin and I
can't explain why Donkey
Kong has decided to throw
coins instead of barrels.

Anyway, the coins must be
collected by Jumpman and he
must play games well to win
coins and unlock arcade
machines as he works his
way up the building to
rescue Pauline.  

Pauline will ♥ it when you
beat all of the machines.

"""

CONTROLS = """

The Controls are as follows:


Left/  —  Move Jumpman along
Right     the platforms

Up/    —  Move Jumpman up
Down      and down ladders.
          Up faces Jumpman
          towards a machine

P1/    —  Play machine that
Jump      Jumpman is facing.
          Jump also jumps :)
         
P2     —  Call up the quick
          access game list

Coin   -  Show game info
          above machines
                      
Action -  Show slot numbers

Exit   -  Exit DKAFE


Good luck!
"""

# Sound setup
pygame.mixer.init(frequency=48000)
music_channel = pygame.mixer.Channel(1)
intermission_channel = pygame.mixer.Channel(2)
award_channel = pygame.mixer.Channel(3)

# Initialisation
pygame.init()
clock = pygame.time.Clock()

# Font setup (pygame)
dk_font = pygame.font.Font('fonts/PressStart2P-vaV7.ttf', 8)
pl_font = pygame.font.Font('fonts/tom-thumb.bdf', 5)
# Font setup (lua)
ui_font = 'gohufont.bdf'

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
dkafe_theme.title_offset = (12, 1)

dkafe_theme.scrollbar_color = BLACK
dkafe_theme.scrollbar_slider_color = BLACK

dkafe_theme.selection_color = RED
dkafe_theme.widget_font_color = PINK
dkafe_theme.widget_margin = (0, 4)
dkafe_theme.widget_selection_effect = pymenu.widgets.LeftArrowSelection(arrow_right_margin=15, arrow_vertical_offset=-1)
dkafe_theme.widget_selection_effect = pymenu.widgets.HighlightSelection(border_width=3, margin_x=3, margin_y=1)

# Override default pygame-menu keys
pymenu.controls.KEY_APPLY = CONTROL_JUMP
pymenu.controls.KEY_CLOSE_MENU = CONTROL_EXIT
