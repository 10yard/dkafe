from stopwatch import Stopwatch

# Jumpman start position
xpos = 33
ypos = 232

# Controls input are received
left = False
right = False
up = False
down = False
jump = False
start = False
joysticks = []

# Jumpman status
active = True      # Jumpman is active - see INACTIVE_TIME
lastmove = 0       # Time of last movement
lastexit = 0       # Time of exiting last emulated game
score = 0          # Jumpman's score
facing = 1         # Direction Jumpman is facing 0=Left, Right=1
jump_sequence = 0  # Sequence number of jump.  0 = Not jumping.  Refer to JUMP_PIXELS array.
wall_bounce = 1    # Adjustment for bouncing off edges. -1 will flip direction of Jumpman's movement

# Toggle display options
showinfo = False    # Press coin2 to show description above the icons
showslots = False   # Press S to show the arcade machine slots (to assist with front end setup)
skip = False        # Skip the animation
warning = False     # Warning timer active
grab = False        # DK grabbed a coin
ready = False       # Jumpman is ready to play a game
competing = False   # Jumpman is chasing a minimum score to gain points on the current game
awarded = False     # Awarded coins are dropped and in play
cointype = 0        # Type of coin being grabbed by DK (0=No Coin, 1 Low Value, 2=High Value)

# Sprites
icons = []           # List of icons and screen locations
coins = []           # List of active coin screen locations
sprite_index = 0

# Game Timer
timer = Stopwatch()
timer_adjust = 0
pause_ticks = 0
teleport_ticks = 0

# Image cache for performance
image_cache = {}

# Screen buffers
screen, screen_map, screen_copy, last_image = (None,) * 4

# Menu
menu, exitmenu = (None,) * 2

# Active Window
window = None
