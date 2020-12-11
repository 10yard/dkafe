import dk_system as _s
from dk_config import *


def lua_interface(rom=None):
    data_file = f'{os.path.join(ROOT_DIR, "interface", rom + ".txt")}'
    preset=False
    if "dkong" in rom:
        preset=True
        scores = ["001000", "001000", "001000", "001000", "001000"]
        players = ["D  ", "K  ", "A  ", "F  ", "E  "]

        # Data
        high_score = scores[0]
        os.environ["DATA_FILE"] = data_file
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


if __name__ == "__main__":
    pass
    # for interactive testing
    #if lua_interface("dkong"):
    #    os.chdir('c:\\emus\\mame')
    #    os.system("mame64 -rompath c:\\emus\\roms -console -autoboot_script c:\\dkafe\\interface\\dkong.lua dkong")


