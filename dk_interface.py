import os
from dk_config import ROOT_DIR, AWARDS, CREDITS, AUTOSTART, SHOW_AWARD_TARGETS, SHOW_AWARD_PROGRESS
from dk_config import HACK_TELEPORT, HACK_NOHAMMERS, HACK_LAVA, HACK_PENALTY

# Memory addresses for scores and players data
# 6 Bytes per score
ROM_SCORES = "0xc356c,0xc356d,0xc356e,0xc356f,0xc3570,0xc3571,0xc358e,0xc358f,0xc3590,0xc3591,0xc3592,0xc3593,0xc35b0,0xc35b1,0xc35b2,0xc35b3,0xc35b4,0xc35b5,0xc35d2,0xc35d3,0xc35d4,0xc35d5,0xc35d6,0xc35d7,0xc35f4,0xc35f5,0xc35f6,0xc35f7,0xc35f8,0xc35f9"""
RAM_SCORES = "0xc6107,0xc6108,0xc6109,0xc610a,0xc610b,0xc610c,0xc6129,0xc612a,0xc612b,0xc612c,0xc612d,0xc612e,0xc614b,0xc614c,0xc614d,0xc614e,0xc614f,0xc6150,0xc616d,0xc616e,0xc616f,0xc6170,0xc6171,0xc6172,0xc618f,0xc6190,0xc6191,0xc6192,0xc6193,0xc6194"""
RAM_HIGH = "0xc7641,0xc7621,0xc7601,0xc75e1,0xc75c1,0xc75a1"

# 7 bytes per group
RAM_SCORES_LONG = "0xc6107,0xc6108,0xc6109,0xc610a,0xc610b,0xc610c,0xc610d,0xc6129,0xc612a,0xc612b,0xc612c,0xc612d,0xc612e,0xc612f,0xc614b,0xc614c,0xc614d,0xc614e,0xc614f,0xc6150,0xc6151,0xc616d,0xc616e,0xc616f,0xc6170,0xc6171,0xc6172,0xc6173,0xc618f,0xc6190,0xc6191,0xc6192,0xc6193,0xc6194,0xc6194"

# 3 bytes per score with 2 digits per byte
RAM_SCORES_DOUBLE = "0xc611f,0xc611e,0xc611d,0xc6141,0xc6140,0xc613f,0xc6163,0xc6162,0xc6161,0xc6185,0xc6184,0xc6183,0xc61A7,0xc61A6,0xc61A5"
RAM_HIGH_DOUBLE = "0xc60ba,0xc60b9,0xc60b8"

# 4 bytes per score with 2 digits per byte
RAM_SCORES_DOUBLE_LONG = "0xc611f,0xc611e,0xc611d,0xc611c,0xc6141,0xc6140,0xc613f,0xc613e,0xc6163,0xc6162,0xc6161,0xc6160,0xc6185,0xc6184,0xc6183,0xc6182,0xc61a7,0xc61a6,0xc61a5,0xc61a4"
RAM_HIGH_DOUBLE_LONG = "0xc60ba,0xc60b9,0xc60b8,0xc60b7"

# Memory addresses for players
RAM_PLAYERS = "0xc610f,0xc6110,0xc6111,0xc6131,0xc6132,0xc6133,0xc6153,0xc6154,0xc6155,0xc6175,0xc6176,0xc6177,0xc6197,0xc6198,0xc6199"
DATA_PLAYERS = "20,16,16,27,16,16,17,16,16,22,16,16,21,16,16"


def apply_rom_specific_hacks(rom=None, subfolder=None):
    if rom == "dkong":
        if subfolder == "dkonglava":
            os.environ["HACK_LAVA"] = "1"
        elif subfolder == "dkongwho":
            os.environ["HACK_TELEPORT"] = "1"
        elif subfolder == "dkonglastman":
            os.environ["HACK_PENALTY"] = "1"


def lua_interface(rom=None, subfolder=None, score3=None, score2=None, score1=None):
    # receive rom name, subfolder name and the target scores
    # Logic is mostly driven by the rom name but there are some exceptions were the subfolder name of a specific
    # rom is needed.
    preset = False
    if score3:
        # Remove compete file if it still exists
        compete_file = os.path.join(ROOT_DIR, "interface", "compete.dat")
        if os.path.exists(compete_file):
            os.remove(compete_file)
        os.environ["LUA_PATH"] = os.path.join(ROOT_DIR, "interface")
        os.environ["DATA_INCLUDES"] = os.path.join(ROOT_DIR, "interface")
        os.environ["DATA_FILE"] = compete_file
        os.environ["DATA_SUBFOLDER"] = subfolder
        os.environ["DATA_CREDITS"] = str(CREDITS)
        os.environ["DATA_AUTOSTART"] = str(AUTOSTART) if CREDITS > 0 else "0"  # need credits to autostart
        for i, award in enumerate([("SCORE3", score3), ("SCORE2", score2), ("SCORE1", score1)]):
            os.environ[f"DATA_{award[0]}"] = str(award[1])
            os.environ[f"DATA_{award[0]}_K"] = format_K(str(award[1]))
            os.environ[f"DATA_{award[0]}_AWARD"] = str(AWARDS[i])

        # Apply hacks based on front end settings
        os.environ["HACK_TELEPORT"] = str(HACK_TELEPORT)
        os.environ["HACK_NOHAMMERS"] = str(HACK_NOHAMMERS)
        os.environ["HACK_LAVA"] = str(HACK_LAVA) if rom == "dkong" else "0"
        os.environ["HACK_PENALTY"] = str(HACK_PENALTY) if rom == "dkong" else "0"

        # Apply rom specific Lua hacks such as the lava hack in dkonglava
        apply_rom_specific_hacks(rom, subfolder)

        # Are we going to show the awards targets and progress while playing the game
        os.environ["DATA_SHOW_AWARD_TARGETS"] = str(SHOW_AWARD_TARGETS)
        os.environ["DATA_SHOW_AWARD_PROGRESS"] = str(SHOW_AWARD_PROGRESS)

        # We are concerned with 3rd score to set the game highscore and to later establish if it was beaten.
        if rom in ("dkong", "dkongjr", "dkongpe", "dkongf", "dkongx", "dkongx11", "dkonghrd"):
            preset = True
            score_width, double_width = 6, 6
            if rom == "dkongx" or rom == "dkongx11" or subfolder == "dkongrdemo":
                score_width, double_width = 7, 8
            # We must set the high score in DK memory to be slightly less than score3 target.
            # This ensures user will register their high score if game ends with the exact target score.
            min_score = str(int(score3) - 100)
            scores = [min_score.zfill(score_width)] * 5

            # Default memory addresses
            os.environ["RAM_HIGH"] = RAM_HIGH
            os.environ["RAM_HIGH_DOUBLE"] = RAM_HIGH_DOUBLE
            os.environ["RAM_SCORES"] = RAM_SCORES
            os.environ["RAM_SCORES_DOUBLE"] = RAM_SCORES_DOUBLE
            os.environ["RAM_PLAYERS"] = RAM_PLAYERS
            os.environ["ROM_SCORES"] = ROM_SCORES

            # Default data
            os.environ["DATA_HIGH"] = format_numeric_data(scores, first_only=True)
            os.environ["DATA_HIGH_DOUBLE"] = format_double_data(scores, width=double_width, first_only=True)
            os.environ["DATA_SCORES"] = format_numeric_data(scores, width=score_width)
            os.environ["DATA_SCORES_DOUBLE"] = format_double_data(scores, width=double_width)
            os.environ["DATA_PLAYERS"] = DATA_PLAYERS

            # Adjustments based on ROM
            if rom == "dkongf":
                os.environ["ROM_SCORES"] = ""
            if rom == "dkongjr":
                os.environ["RAM_PLAYERS"] = adjust_addresses(RAM_PLAYERS, 4)
            if rom == "dkongx":
                os.environ["DATA_SCORES_DOUBLE"] = \
                    format_double_data(scores, width=double_width, justify_single_digit_right=True)
                os.environ["RAM_SCORES"] = adjust_addresses(RAM_SCORES_LONG, -1)
                os.environ["RAM_SCORES_DOUBLE"] = adjust_addresses(RAM_SCORES_DOUBLE_LONG, 1)
                os.environ["RAM_HIGH_DOUBLE"] = ""
                os.environ["ROM_SCORES"] = ""
                os.environ["RAM_HIGH"] = ""
            if rom == "dkongx11" or subfolder == "dkongrdemo":
                os.environ["RAM_HIGH_DOUBLE"] = RAM_HIGH_DOUBLE_LONG
                os.environ["RAM_SCORES"] = RAM_SCORES_LONG
                os.environ["RAM_SCORES_DOUBLE"] = RAM_SCORES_DOUBLE_LONG
                os.environ["RAM_PLAYERS"] = adjust_addresses(RAM_PLAYERS, 1)
                os.environ["ROM_SCORES"] = ""
                os.environ["RAM_HIGH"] = ""
        return preset


def adjust_addresses(array, offset):
    # adjust all the memory addresses in the array by a given offset
    new_array = ""
    for address in array.replace("\n", "").split(","):
        new_array += str(int(address, 16) + offset) + ","
    return new_array.strip(",")


def get_award(rom, score3, score2, score1):
    # Read data from the compete.dat file to detemine if coins should be awarded to Jumpman.
    compete_file = f'{os.path.join(ROOT_DIR, "interface", "compete.dat")}'
    try:
        with open(compete_file, "r") as cf:
            score = cf.readline().replace("\n", "")
            name = cf.readline().replace("\n", "")
        os.remove(compete_file)
        if rom == name and score.isnumeric():
            if int(score) > int(score1):
                return AWARDS[2]  # Got 1st prize award
            elif int(score) > int(score2):
                return AWARDS[1]  # Got 2nd prize award
            elif int(score) > int(score3):
                return AWARDS[0]  # Got 3rd prize award
            else:
                return 0  # Got nothing
    except Exception:
        return 0
    return 0


def format_double_data(scores, width=6, first_only=False, justify_single_digit_right=False):
    data = ""
    for score in scores:
        score_text = (score.ljust(width), score.rjust(width))[int(justify_single_digit_right)].replace(" ", "0")
        for i in range(0, width, 2):
            data += str(int(score_text[i:i+2], 16)) + ","
        if first_only:
            break
    return data.strip(",")


def format_numeric_data(top_scores, width=6, first_only=False):
    data = ""
    for score in top_scores:
        for char in score.zfill(width)[:width]:
            data += char + ","
        if first_only:
            break
    return data.strip(",")


def format_K(text):
    if text.endswith("000000"):
        return text[:-6] + "M"
    elif text.endswith("000"):
        return text[:-3] + "K"
    else:
        return text


if __name__ == "__main__":
    pass
