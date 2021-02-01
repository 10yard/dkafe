-- DKAFE Global variables for interface

-- Data
data_file = os.getenv("DATA_FILE")
data_subfolder = os.getenv("DATA_SUBFOLDER")
data_credits = os.getenv("DATA_CREDITS")
data_autostart = os.getenv("DATA_AUTOSTART")
data_bronze_score = os.getenv("DATA_BRONZE_SCORE")
data_bronze_award = os.getenv("DATA_BRONZE_AWARD")
data_silver_score = os.getenv("DATA_SILVER_SCORE")
data_silver_award = os.getenv("DATA_SILVER_AWARD")
data_gold_score = os.getenv("DATA_GOLD_SCORE")
data_gold_award = os.getenv("DATA_GOLD_AWARD")

-- Score data
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
ports = manager:machine():ioport().ports

-- Optional hacks
hack_teleport = os.getenv("HACK_TELEPORT")
hack_nohammers = os.getenv("HACK_NOHAMMERS")
hack_lava = os.getenv("HACK_LAVA")
hack_penalty = os.getenv("HACK_PENALTY")

-- Colours
BLACK = 0xff000000
WHITE = 0xffffffff
YELLOW = 0xffffbd2e
RED = 0xffe8070a
BLUE = 0xff0402dc
CYAN = 0xff14f3ff
BROWN = 0xfff5bca0
ORANGE = 0xfff4bA15

-- Characters
dkchars = {}
dkchars["0"] = 0x00
dkchars["1"] = 0x01
dkchars["2"] = 0x02
dkchars["3"] = 0x03
dkchars["4"] = 0x04
dkchars["5"] = 0x05
dkchars["6"] = 0x06
dkchars["7"] = 0x07
dkchars["8"] = 0x08
dkchars["9"] = 0x09
dkchars[" "] = 0x10
dkchars["A"] = 0x11
dkchars["B"] = 0x12
dkchars["C"] = 0x13
dkchars["D"] = 0x14
dkchars["E"] = 0x15
dkchars["F"] = 0x16
dkchars["G"] = 0x17
dkchars["H"] = 0x18
dkchars["I"] = 0x19
dkchars["J"] = 0x1a
dkchars["K"] = 0x1b
dkchars["L"] = 0x1c
dkchars["M"] = 0x1d
dkchars["N"] = 0x1e
dkchars["O"] = 0x1f
dkchars["P"] = 0x20
dkchars["Q"] = 0x21
dkchars["R"] = 0x22
dkchars["S"] = 0x23
dkchars["T"] = 0x24
dkchars["U"] = 0x25
dkchars["V"] = 0x26
dkchars["W"] = 0x27
dkchars["X"] = 0x28
dkchars["Y"] = 0x29
dkchars["Z"] = 0x2a
dkchars["."] = 0x2b
dkchars["-"] = 0x2c
dkchars[":"] = 0x2e
dkchars["<"] = 0x30
dkchars[">"] = 0x31
dkchars["="] = 0x34
dkchars["$"] = 0x36  -- double exclamations !!
dkchars["!"] = 0x38
dkchars["'"] = 0x3a
dkchars[","] = 0x43
dkchars["^"] = 0xb0 -- rivet block
dkchars["?"] = 0xfb
dkchars["@"] = 0xff -- extra mario icon

-- Block characters
dkblock = {}
dkblock["A"] = "####.#####.##.#"
dkblock["B"] = "##.#.###.#.###."
dkblock["C"] = "####..#..#..###"
dkblock["D"] = "##.# ## ## ###."
dkblock["E"] = "####..####..###"
dkblock["F"] = "####--####--#--"
dkblock["G"] = "#####---#-###--#####"
dkblock["H"] = "#.##.#####.##.#"
dkblock["I"] = "###.#..#..#.###"
dkblock["J"] = "###-#--#--#-##-"
dkblock["K"] = "#..##.#.###.#.#.#..#"
dkblock["L"] = "#..#..#..#..###"
dkblock["M"] = "#...###.###.#.##.#.##.#.#"
dkblock["N"] = "#..###.######.###..#"
dkblock["O"] = "####.##.##.####"
dkblock["P"] = "####.#####..#.."
dkblock["Q"] = "####-#--#-#--#-#-##-#####"
dkblock["R"] = "####-######-#-#"
dkblock["S"] = "####..###..####"
dkblock["T"] = "###.#..#..#..#."
dkblock["U"] = "#-##-##-##-####"
dkblock["V"] = "#-##-##-##-#-#-"
dkblock["W"] = "#.#.##.#.##.#.###.###...#"
dkblock["X"] = "#-##-#-#-#-##-#"
dkblock["Y"] = "#-##-##-#-#--#-"
dkblock["Z"] = "####--#--#--#---####"
dkblock[" "] = "     "
dkblock["!"] = " # # #   #"
dkblock["'"] = "##   "
dkblock["1"] = "##--#--#--#-###"
dkblock["2"] = "###--#####--###"
dkblock["3"] = "###--####--####"
dkblock["4"] = "#---#---#-#-####--#-"
dkblock["5"] = "####--###--####"
dkblock["6"] = "####--####-####"
dkblock["7"] = "###--#-#--#--#-"
dkblock["8"] = "####-#####-####"
dkblock["9"] = "####-####--#--#"
