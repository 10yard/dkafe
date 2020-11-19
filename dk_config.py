import pygame
import pygame_menu
import os

# Graphic Config
TARGET_SIZE = (224, 256)     # x, y resolution of game (x, y)
CLOCK_RATE = 60              # Clock rate/timing. Integer
FRAME_DELAY = 23             # Default delay for screen update. Integer

# Controls
CONTROL_LEFT = pygame.K_LEFT
CONTROL_RIGHT = pygame.K_RIGHT
CONTROL_UP = pygame.K_UP
CONTROL_DOWN = pygame.K_DOWN
CONTROL_JUMP = pygame.K_LCTRL
CONTROL_P1_START = pygame.K_1
CONTROL_P2_START = pygame.K_2
CONTROL_COIN = pygame.K_5
CONTROL_EXIT = pygame.K_ESCAPE

# Options
INACTIVE_TIME = 15           # Screensaver with game instructions after period (in seconds) of inactivity
TIMER_START = 5000           # Timer starts countdown from
PLAY_COST = 100              # How much it cost to play an arcade machine.  Jumpman must have collected enough coins.
FREE_PLAY = True             # Jumpman does not have to pay to play
COIN_VALUES = [0, 50, 100]   # How many points awarded for collecting a coin
COIN_FREQUENCY = 3           # How frequently DK will grab a coin (1 = always, 2 = 1/2,  3 = 1/3 etc). Integer
COIN_SPEED = 1.6             # Number of pixels to move coin per display update. Decimal
COIN_CYCLE = 0.15            # How often the coin sprite is updated. Decimal
LADDER_CHANCE = 3            # Chance of coin dropping down a ladder (1 = always, 2 = 1/2,  3 = 1/3 etc). Integer

# Emulator and rom paths
OPTIONS = "-skip_gameinfo -video gdi -keepaspect -nounevenstretch"
ROM_DIR = ""
EMU_1 = ""                   # MAME      e.g. 'C:\\mame\\mame64 <OPTIONS> -rompath <ROM_DIR>'
EMU_2 = ""                   # HBMAME    e.g. 'C:\\hbmame\\hbmame64 <OPTIONS> -rompath <ROM_DIR>'
EMU_3 = ""                   # WOLFMAME  e.g. 'C:\\wolfmame\\mame64 -record <NAME>.inp <OPTIONS> -rompath <ROM_DIR>'

ROOT_DIR = os.getcwd()

# Defaults can be overridden in the settings.txt files
if os.path.exists("settings.txt"):
    with open("settings.txt", 'r') as sf:
        for setting in sf.readlines():
            if setting.count("=") == 1:
                key, value = setting.split("=")
                try:
                    globals()[key.strip()] = value.replace("<OPTIONS>", OPTIONS).replace("<ROM_DIR>", ROM_DIR).strip()
                except KeyError:
                    print(f'Unknown setting "{key.strip()}" in settings.txt file')
                    pygame.quit()
                    exit()

# Colours
RED = (232, 7, 10)
BLUE = (4, 3, 255)
BLACK = (0, 0, 0)
BROWN = (172, 5, 7)
CYAN = (20, 243, 255)
MAGENTA = (236, 49, 148)
WHITE = (254, 252, 255)
PINK = (255, 188, 160)

# Defines scene numbers when sounds should be played
SCENE_SOUNDS = [
    (160, "sounds/climb.wav"),
    (481, "sounds/stomp.wav"),
    (712, "sounds/roar.wav"),
    (856, "sounds/howhigh.wav")]

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

# Ladder zone detection
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
    ("APPROACHING_LADDER", (200,))]

# Relative pixels for jump
JUMP_PIXELS = [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

COIN_INFO = [' HEY JUMPMAN!', '', ' COLLECT COINS', ' TO PLAY GAMES', '', ' PUSH COIN', ' FOR GAME INFO', '']
FREE_INFO = [' HEY JUMPMAN!', '', ' ALL MACHINES', ' ARE FREE TO PLAY', '', ' PUSH COIN', ' FOR GAME INFO', '']

INSTRUCTION = """

Donkey Kong has captured
Pauline and carried her to
the top of an abandoned
construction site. 

The shock of shaking up the 
building during his climb to
the top has uncovered many
hidden arcade machines from 
the 1980's era and they are 
scattered around the 
platforms.

Yes, the plot is a bit thin
and I can't explain why Kong 
has decided to throw coins 
instead of barrels. 

Anyway, the coins must be 
collected by Jumpman so that
he has money to play all of 
the arcade machines.

"""

CONTROLS = """
The Controls are as follows

Left/   -  Move Jumpman 
Right      along the 
           platforms

Up/     -  Move Jumpman up
Down       and down ladders. 
           Up faces Jumpman
           towards a machine

Jump/   -  Play the arcade
P1 Start   machine that 
           Jumpman is facing

P2 Start-  Quickly select 
           from a game list

Coin    -  Show game info
           above machines
                      
Esc     -  Exit


Good luck!
"""

# pygame setup
pygame.mixer.init(frequency=48000)
music_channel = pygame.mixer.Channel(0)
pygame.init()
pygame.mouse.set_visible(False)
dk_font = pygame.font.Font('fonts/PressStart2P-vaV7.ttf', 8)
pl_font = pygame.font.Font('fonts/tiny.ttf', 6)
clock = pygame.time.Clock()

screen = pygame.display.set_mode(TARGET_SIZE, flags=pygame.FULLSCREEN | pygame.SCALED)
pygame.mouse.set_visible(False)
screenmap = screen.copy()
screen_with_icons = screen.copy()

# Store the background as a frame and make the screen map for collision detection
background_image = pygame.image.load("artwork/background.png").convert()
background_map = pygame.image.load("artwork/map.png").convert()
screenmap.blit(background_map, [0, 0])

# menu theme
dkafe_theme = pygame_menu.themes.THEME_DEFAULT.copy()
dkafe_theme.widget_font = 'fonts/PressStart2P-vaV7.ttf'
dkafe_theme.title_font = 'fonts/PressStart2P-vaV7.ttf'
dkafe_theme.title_font_size = 8
dkafe_theme.widget_font_size = 8
dkafe_theme.background_color = RED
dkafe_theme.title_background_color = BLACK
dkafe_theme.widget_font_color = CYAN
dkafe_theme.title_bar_style = pygame_menu.widgets.MENUBAR_STYLE_UNDERLINE
dkafe_theme.title_offset = (2, 2)
dkafe_theme.scrollbar_thick = 2
dkafe_theme.widget_margin = (0, -0.01)
dkafe_theme.widget_selection_effect = \
    pygame_menu.widgets.LeftArrowSelection(arrow_size=(10, 15), arrow_right_margin=5, arrow_vertical_offset=-1)

# Override the default pygame-menu keys
pygame_menu.controls.KEY_APPLY = CONTROL_JUMP
pygame_menu.controls.KEY_CLOSE_MENU = CONTROL_P2_START