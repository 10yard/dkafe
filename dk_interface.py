import dk_system as _s
from dk_config import *


def lua_interface(rom=None):
    preset=False
    if "dkong" in rom:
        preset=True
        scores = ["030000", "020000", "010000", "010000", "010000"]
        players = ["D  ", "K  ", "A  ", "F  ", "E  "]
        title = ["YOU NEED"]

        os.environ["DK_RAM_HIGH_ADDR"] = DK_RAM_HIGH_ADDR
        os.environ["DK_RAM_HIGH_DATA"] = _s.format_numeric_data(scores, first_only=True)
        os.environ["DK_RAM_SCORES_ADDR"] = DK_RAM_SCORES_ADDR
        os.environ["DK_RAM_SCORES_DATA"] = _s.format_numeric_data(scores)
        os.environ["DK_RAM_PLAYERS_DATA"] = _s.format_hex_data(players)
        os.environ["DK_RAM_PLAYERS_ADDR"] = DK_RAM_PLAYERS_ADDR
        os.environ["DK_ROM_TITLE_ADDR"] = DK_ROM_TITLE_ADDR
        os.environ["DK_ROM_TITLE_DATA"] = _s.format_hex_data(title, width=10)
    return preset


if __name__ == "__main__":
    # for interactive testing
    if lua_interface("dkong"):
        os.chdir('c:\\emus\\mame')
        os.system("mame64 -rompath c:\\emus\\roms -console -autoboot_script c:\\dkafe\\interface\\dkong.lua dkong")


