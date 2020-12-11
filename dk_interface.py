import dk_system as _s
from dk_config import *


def lua_interface(rom=None, min_score=None):
    preset=False
    if min_score:
        # Remove compete file if it still exists
        compete_file = f'{os.path.join(ROOT_DIR, "interface", "compete.dat")}'
        if os.path.exists(compete_file):
            os.remove(compete_file)

        # We are only concerned with the minimum score at this stage so we can set the default highscore and
        # establish it has been beaten.
        if "dkong" in rom:
            preset=True
            scores = [min_score.zfill(6)] * 5
            players = ["D  ", "K  ", "A  ", "F  ", "E  "]

            # Data
            high_score = scores[0]
            os.environ["DATA_FILE"] = compete_file
            os.environ["DATA_HIGH"] = _s.format_numeric_data(scores, first_only=True)
            os.environ["DATA_HIGH_DBL"] = _s.format_double_data(high_score)
            os.environ["DATA_SCORES"] = _s.format_numeric_data(scores)
            os.environ["DATA_PLAYERS"] = _s.format_hex_data(players)

            # Memory addresses
            os.environ["RAM_HIGH"] = RAM_HIGH
            os.environ["RAM_HIGH_DBL"] = RAM_HIGH_DBL
            os.environ["RAM_SCORES"] = RAM_SCORES
            os.environ["RAM_PLAYERS"] = RAM_PLAYERS
            os.environ["ROM_SCORES"] = ROM_SCORES
        return preset


def read_compete_file(rom, min_score):
    # Read data from the compete.dat file to detemine if points should be awarded to Jumpman.
    compete_file = f'{os.path.join(ROOT_DIR, "interface", "compete.dat")}'
    score = 0
    if os.path.exists(compete_file):
        with open(compete_file, "r") as cf:
            for line in cf.readlines():
                score = line
                break
        os.remove(compete_file)
    return score


if __name__ == "__main__":
    pass
    #print(read_compete_file("dkong", "10000"))
    # for interactive testing
    #if lua_interface("dkong"):
    #    os.chdir('c:\\emus\\mame')
    #    os.system("mame64 -rompath c:\\emus\\roms -console -autoboot_script c:\\dkafe\\interface\\dkong.lua dkong")


