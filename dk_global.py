from stopwatch import Stopwatch

# Jumpman start position
xpos = 39
ypos = 232

# Controls input are received
left = False
right = False
up = False
down = False
jump = False
start = False

# Jumpman status
active = True    # Jumpman is active - see INACTIVE_TIME
jumping = False  # Jumpman is currently jumping
jumping_seq = 0  # Sequence number of jump
lastmove = 0     # Time of last movement
facing = 1       # Direction Jumpman is facing 0=Left, Right=1
score = 0        # Jumpman's score

# Toggle display options
showinfo = False    # Press coin2 to show description above the icons
skip = False        # Skip the animation
countdown = False   # Coundown timer active
ready = False       # Jumpman is ready to play a game
grab = False        # DK grabbed a coin
cointype = 0        # Type of coin being grabbed by DK (0=No Coin, 1 Low Value, 2=High Value)

# Sprites
icons = []           # List of icons and screen locations
coins = []           # List of active coin screen locations
sprite_index = 0

# Game Timer
timer = Stopwatch()
pause_ticks = 0

# Image cache for performance
image_cache = {}

# Screen buffers
screen, screen_map, screen_copy, last_image = (None,) * 4

# Menu
menu, exitmenu = (None,) * 2
