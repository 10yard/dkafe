"""
ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
 888    88o  888  o88        888       888          888
 888    888  888888         8  88      888ooo8      888ooo8
 888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
                                        by Jon Wilson (10yard)

MAME Interface routines
-----------------------
"""
import os
from dk_config import ROOT_DIR, AWARDS
from dk_config import SHOW_AWARD_TARGETS, SHOW_AWARD_PROGRESS, SHOW_HUD, HUD_UNFRIENDLY

COMPETE_FILE = os.path.join(ROOT_DIR, "interface", "compete.dat")


def lua_interface(emulator=None, rom=None, subfolder=None, score3=None, score2=None, score1=None, basic=0):
    # Logic is driven by the rom name but there are exceptions were the subfolder name of a specific rom is needed.
    script = None
    if not basic:
        if rom in ("dkong", "dkongjr", "dkongpe", "dkongf", "dkongx", "dkongx11", "dkonghrd", "dkongj"):
            script = "dkong.lua"
        elif rom in ("ckong", "ckongpt2", "ckongpt2b", "bigkong", "ckongs", "ckongg", "ckongmc", "kong"):
            script = "ckong.lua"

    if script and score3:
        if os.path.exists(COMPETE_FILE):
            os.remove(COMPETE_FILE)

        os.environ["LUA_PATH"] = os.path.join(ROOT_DIR, "interface")
        os.environ["DATA_INCLUDES"] = os.path.join(ROOT_DIR, "interface")
        os.environ["DATA_EMULATOR"] = os.path.basename(emulator.split(" ")[0])
        os.environ["DATA_FILE"] = COMPETE_FILE
        os.environ["DATA_SUBFOLDER"] = subfolder

        # Are we going to show the awards targets and progress while playing the game
        os.environ["DATA_SHOW_AWARD_TARGETS"] = str(SHOW_AWARD_TARGETS)
        os.environ["DATA_SHOW_AWARD_PROGRESS"] = str(SHOW_AWARD_PROGRESS)
        os.environ["DATA_SHOW_HUD"] = "0" if (subfolder in HUD_UNFRIENDLY or rom == "dkongjr") else str(SHOW_HUD)

        for i, award in enumerate([("SCORE3", score3), ("SCORE2", score2), ("SCORE1", score1)]):
            os.environ[f"DATA_{award[0]}"] = str(award[1])
            os.environ[f"DATA_{award[0]}_K"] = format_K(str(award[1]))
            os.environ[f"DATA_{award[0]}_AWARD"] = str(AWARDS[i])

        return script


def get_award(rom, score3, score2, score1):
    # Read data from the compete.dat file to detemine if coins should be awarded to Jumpman.
    try:
        with open(COMPETE_FILE, "r") as cf:
            name = cf.readline().replace("\n", "")
            score = cf.readline().replace("\n", "")
        os.remove(COMPETE_FILE)
        if rom == name and score.isnumeric():
            if int(score) >= int(score1):
                return AWARDS[2]  # Got 1st prize award
            elif int(score) >= int(score2):
                return AWARDS[1]  # Got 2nd prize award
            elif int(score) >= int(score3):
                return AWARDS[0]  # Got 3rd prize award
            else:
                return 0  # Got nothing
    except (EOFError, FileNotFoundError, IOError):
        return 0
    return 0


def format_K(number):
    num = float('{:.3g}'.format(float(number)))
    magnitude = 0
    while abs(num) >= 1000:
        magnitude += 1
        num /= 1000.0
    return '{}{}'.format('{:f}'.format(num).rstrip('0').rstrip('.'), ['', 'K', 'M', 'B', 'T'][magnitude])


if __name__ == "__main__":
    pass
