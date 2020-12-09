from platform import platform
from datetime import datetime
from glob import glob
from dk_config import *
from shutil import copy
os.environ['PYGAME_HIDE_SUPPORT_PROMPT'] = "1"


def is_windows():
    # Is this a Windows OS?
    return "windows" in platform().lower()


def get_datetime():
    return datetime.now().strftime("%d%m%Y-%H%M%S")


def intro_frames():
    return list(range(0, 100)) + list(sorted(glob("artwork/scene/scene_*.png")))


def read_romlist():
    # read romlist and return info about available roms (and shell scripts)
    romlist = []
    if os.path.exists("romlist.txt"):
        with open("romlist.txt", "r") as rl:
            for rom_line in rl.readlines()[1:]:  # ignore the first/header line
                if rom_line.count("|") == 7:
                    name, subfolder, desc, icx, icy, emu, state, unlock, *_ = [x.strip() for x in rom_line.split("|")]
                    if name and desc and icx and icy:
                        target = name + (".sh", ".bat")[is_windows()] if subfolder == "shell" else name + ".zip"
                        if os.path.exists(os.path.join((ROM_DIR, ROOT_DIR)[subfolder == "shell"], subfolder, target)):
                            romlist.append((name, subfolder, desc, int(icx), int(icy), int(emu), state, int(unlock)))
    return romlist


def build_shell_command(info):
    # Receives subfolder (optional), name, emulator and rom state from info
    # A homebew emulator is preferred for rom hacks but a good alternative is to provide a subfolder which holds a
    # variant of the main rom e.g. roms/skipstart/dkong.zip is a variant of roms/dkong.zip.  If mame emulator supports
    # rompath then the rom can be launched direct from the subfolder otherwise the file will be copied over the main
    # rom to avoid a CRC check fail.
    subfolder, name, emu, state, unlock = info
    emu_command = f'{(EMU_1, EMU_2, EMU_3, EMU_4, EMU_5, EMU_6, EMU_7, EMU_8)[emu - 1]}'
    emu_command = emu_command.replace("<NAME>", name).replace("<DATETIME>", get_datetime())
    shell_command = f'{emu_command} {name}'
    emu_directory = os.path.dirname(emu_command.split(" ")[0])

    if subfolder:
        if subfolder == "shell":
            # Launch shell script / batch file
            shell_command = os.path.join(ROOT_DIR, "shell", name + (".sh", ".bat")[is_windows()])
        elif "-rompath" in emu_command:
            # Launch rom and provide rom path
            shell_command = f'{emu_command}{os.sep}{subfolder} {name}'
        else:
            # Copy rom from subfolder to the fixed rom path
            rom_source = os.path.join(ROM_DIR, subfolder, name + ".zip")
            rom_target = os.path.join(ROM_DIR, name + ".zip")
            if os.path.exists(rom_source):
                copy(rom_source, rom_target)

    #test
    if "-record" not in shell_command:
        from dk_interface import lua_interface
        if lua_interface(name):
            shell_command += ' -fontpath c:\\dkafe\\fonts'
            shell_command += f' -noconsole -autoboot_script {os.path.join(ROOT_DIR, "interface", "dkong.lua")}'

    if state:
        shell_command += f' -state {state.strip()}'
    return shell_command, emu_directory, state.lower() == "hide"


def calculate_bonus(duration):
    # return bonus_display, colour, warning status, end of countdown
    bonus_timer = TIMER_START + 100 - (duration * 50)
    bonus_display = " 000" if bonus_timer <= 100 else str(int(bonus_timer)).rjust(4)[:2] + "00"
    warning = bonus_timer < 1000
    return bonus_display, (CYAN, MAGENTA)[warning], warning, bonus_timer <= -200


def hex2dec(_hex):
    return str(int(_hex, 16))


def format_double_data(score, width=6):
    data = ""
    for i in range(0, 6, 2):
        data += str(int(score[i:i+2], 16)) + ","
    return data.strip(",")


def format_numeric_data(top_scores, width=6, first_only=False):
    data = ""
    for score in top_scores:
        for char in score.zfill(width)[:width]:
            data += char + ","
        if first_only:
            break
    return data.strip(",")


def format_hex_data(player_names, width=3):
    data = ""
    for player in player_names:
        for char in player.center(width)[:width]:
            if char in DK_CHARMAP:
                data += hex2dec(DK_CHARMAP[char]) + ","
            else:
                data += "16,"
    return data.strip(",")
