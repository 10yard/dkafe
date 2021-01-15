-- DKAFE Global variables for interface

-- Load data
data_file = os.getenv("DATA_FILE")
data_subfolder = os.getenv("DATA_SUBFOLDER")
data_credits = os.getenv("DATA_CREDITS")
data_scores = get_formatted_data("DATA_SCORES")
data_scores_DOUBLE = get_formatted_data("DATA_SCORES_DOUBLE")
data_high = get_formatted_data("DATA_HIGH")
data_high_DOUBLE = get_formatted_data("DATA_HIGH_DOUBLE")
data_scores = get_formatted_data("DATA_SCORES")
data_players = get_formatted_data("DATA_PLAYERS")

-- Get ROM addresses
rom_scores = get_formatted_data("ROM_SCORES")

-- Get RAM addresses
ram_high = get_formatted_data("RAM_HIGH")
ram_high_DOUBLE = get_formatted_data("RAM_HIGH_DOUBLE")
ram_scores = get_formatted_data("RAM_SCORES")
ram_scores_DOUBLE = get_formatted_data("RAM_SCORES_DOUBLE")
ram_players = get_formatted_data("RAM_PLAYERS")

-- Memory state
cpu = manager:machine().devices[":maincpu"]
mem = cpu.spaces["program"]
screen = manager:machine().screens[":screen"]

-- Optional hacks
hack_teleport = os.getenv("HACK_TELEPORT")
hack_nohammers = os.getenv("HACK_NOHAMMERS")
hack_lava = os.getenv("HACK_LAVA")
hack_penaltypoints = os.getenv("HACK_PENALTYPOINTS")

-- Colours
BLACK = 0xff000000
WHITE = 0xffffffff
YELLOW = 0xffffbd2e
RED = 0xffe8070a
BLUE = 0xff0402dc
CYAN = 0xff14f3ff
BROWN = 0xfff5bca0
ORANGE = 0xfff4bA15