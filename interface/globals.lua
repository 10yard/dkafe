--[[
#      ___   ___                    .--.
#     (   ) (   )                  /    \
#   .-.| |   | |   ___     .---.   | .`. ;    .--.
#  /   \ |   | |  (   )   / .-, \  | |(___)  /    \
# |  .-. |   | |  ' /    (__) ; |  | |_     |  .-. ;
# | |  | |   | |,' /       .'`  | (   __)   |  | | |
# | |  | |   | .  '.      / .'| |  | |      |  |/  |
# | |  | |   | | `. \    | /  | |  | |      |  ' _.'
# | '  | |   | |   \ \   ; |  ; |  | |      |  .'.-.
# ' `-'  /   | |    \ .  ' `-'  |  | |      '  `-' /  Donkey Kong Arcade Frontend
#  `.__,'   (___ ) (___) `.__.'_. (___)      `.__.'   by Jon Wilson

 Global variables
------------------------------------------------------------------------------------------------
]]

-- Options data
------------------------------------------------------------------------------------------------
data_emulator = os.getenv("DATA_EMULATOR")
data_file = os.getenv("DATA_FILE")
data_subfolder = os.getenv("DATA_SUBFOLDER")
data_credits = os.getenv("DATA_CREDITS")
data_autostart = os.getenv("DATA_AUTOSTART")

--Award targets and progress data
------------------------------------------------------------------------------------------------
data_show_award_targets = os.getenv("DATA_SHOW_AWARD_TARGETS")
data_show_award_progress = os.getenv("DATA_SHOW_AWARD_PROGRESS")
data_allow_skip_intro = os.getenv("DATA_ALLOW_SKIP_INTRO")
data_show_hud = os.getenv("DATA_SHOW_HUD")
data_toggle_hud = tonumber(data_show_hud)
data_last_toggle = 0

--Award coins data
------------------------------------------------------------------------------------------------
data_award1 = os.getenv("DATA_AWARD1")
data_award2 = os.getenv("DATA_AWARD2")
data_award3 = os.getenv("DATA_AWARD3")

--1st, 2nd and 3rd target scores for prize awards data
------------------------------------------------------------------------------------------------
data_score1 = tonumber(os.getenv("DATA_SCORE1"))
data_score1_k = os.getenv("DATA_SCORE1_K")
data_score1_award = os.getenv("DATA_SCORE1_AWARD")
data_score2 = tonumber(os.getenv("DATA_SCORE2"))
data_score2_k = os.getenv("DATA_SCORE2_K")
data_score2_award = os.getenv("DATA_SCORE2_AWARD")
data_score3 = tonumber(os.getenv("DATA_SCORE3"))
data_score3_k = os.getenv("DATA_SCORE3_K")
data_score3_award = os.getenv("DATA_SCORE3_AWARD")

-- Score data
------------------------------------------------------------------------------------------------
data_scores = get_formatted_data("DATA_SCORES")
data_scores_DOUBLE = get_formatted_data("DATA_SCORES_DOUBLE")
data_high = get_formatted_data("DATA_HIGH")
data_high_DOUBLE = get_formatted_data("DATA_HIGH_DOUBLE")
data_scores = get_formatted_data("DATA_SCORES")
data_players = get_formatted_data("DATA_PLAYERS")

-- ROM addresses
------------------------------------------------------------------------------------------------
rom_scores = get_formatted_data("ROM_SCORES")

-- RAM addresses
------------------------------------------------------------------------------------------------
ram_high = get_formatted_data("RAM_HIGH")
ram_high_DOUBLE = get_formatted_data("RAM_HIGH_DOUBLE")
ram_scores = get_formatted_data("RAM_SCORES")
ram_scores_DOUBLE = get_formatted_data("RAM_SCORES_DOUBLE")
ram_players = get_formatted_data("RAM_PLAYERS")

-- Memory/state
------------------------------------------------------------------------------------------------
machine = manager:machine()
ports = machine:ioport().ports
video = machine:video()
screen = machine.screens[":screen"]
cpu = machine.devices[":maincpu"]
mem = cpu.spaces["program"]
soundcpu = machine.devices[":soundcpu"]
soundmem = soundcpu.spaces["data"]

-- Optional hack flags
------------------------------------------------------------------------------------------------
hack_teleport = os.getenv("HACK_TELEPORT")
hack_nohammers = os.getenv("HACK_NOHAMMERS")
hack_lava = os.getenv("HACK_LAVA")
hack_penalty = os.getenv("HACK_PENALTY")

-- Colours
------------------------------------------------------------------------------------------------
BLACK = 0xff000000
WHITE = 0xffffffff
YELLOW = 0xffffbd2e
RED = 0xffe8070a
BLUE = 0xff0402dc
CYAN = 0xff14f3ff
BROWN = 0xfff5bca0
ORANGE = 0xfff4bA15
