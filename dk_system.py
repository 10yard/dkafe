import os
from datetime import datetime
from time import sleep
from glob import glob
from shutil import copy
os.environ['PYGAME_HIDE_SUPPORT_PROMPT'] = '1'
from dk_config import *
from dk_interface import lua_interface


def debounce():
    sleep(0.2)


def get_datetime():
    return datetime.now().strftime("%d%m%Y-%H%M%S")


def intro_frames(climb_scene_only=False):
    return list(range(0, 100 * int(not climb_scene_only))) + list(sorted(glob("artwork/scene/scene_*.png")))


def read_romlist():
    # read romlist and return info about available roms (and shell scripts)
    romlist = []
    with open("romlist.csv", "r") as rl:
        for rom_line in rl.readlines()[1:]:  # ignore the first/header line
            if not rom_line.startswith("#") and rom_line.count(",") == 8:
                name, sub, des, slot, emu, unlock, score3, score2, score1, *_ = [x.strip() for x in rom_line.split(",")]
                if name and des:
                    icx, icy = -1, -1
                    if 0 < int(slot) <= len(SLOTS):
                        icx, icy = SLOTS[int(slot) - 1]
                    romlist.append((name, sub, des, icx, icy, int(emu), int(unlock), score3, score2, score1))
    return romlist


def get_emulator(emu_number):
    return f'{(EMU_1, EMU_2, EMU_3, EMU_4, EMU_5, EMU_6, EMU_7, EMU_8)[emu_number - 1]}'


def build_launch_command(info):
    # Receives subfolder (optional), name, emulator, unlock and target scores from info
    # A homebew emulator is preferred for rom hacks but a good alternative is to provide a subfolder which holds a
    # variant of the main rom e.g. roms/skipstart/dkong.zip is a variant of roms/dkong.zip.  If mame emulator supports
    # rompath then the rom can be launched direct from the subfolder otherwise the file will be copied over the main
    # rom to avoid a CRC check fail.
    sub, name, emu, unlock, score3, score2, score1 = info
    emu_args = get_emulator(emu).replace("<NAME>", name).replace("<DATETIME>", get_datetime())
    launch_directory = os.path.dirname(emu_args.split(" ")[0])
    launch_command = f'{emu_args} {name}'
    competing = False

    if sub:
        if sub == "shell":
            # Launch a batch file or shell script from the shell subfolder
            launch_command = os.path.join(ROOT_DIR, "shell", name)
        elif "-rompath" in emu_args:
            # Launch a rom and provide rom path
            launch_command = f'{emu_args}{os.sep}{sub} {name}'
        else:
            # Copy rom to the fixed rom path. Useful for emulators like advmame when -rompath argument is not supported.
            rom_source = os.path.join(ROM_DIR, sub, name + ".zip")
            rom_target = os.path.join(ROM_DIR, name + ".zip")
            if os.path.exists(rom_source):
                copy(rom_source, rom_target)

    if not FULLSCREEN:
        launch_command += " -window"

    if "-record" not in launch_command:
        if lua_interface(get_emulator(emu), name, sub, score3, score2, score1):
            # MAME/LUA interface is available
            competing = True
            launch_command += f' -noconsole -autoboot_script {os.path.join(ROOT_DIR, "interface", "dkong.lua")}'
            launch_command += f' -fontpath {os.path.join(ROOT_DIR, "fonts")} -debugger_font_size 11 -uifont {ui_font}'

    return launch_command, launch_directory, competing


def get_bonus_timer(duration):
    return TIMER_START + 100 - (duration * 50)


def calculate_bonus(duration):
    # return bonus_display, colour, warning status, end of countdown
    bonus_timer = get_bonus_timer(duration)
    bonus_display = " 000" if bonus_timer <= 100 else str(int(bonus_timer)).rjust(4)[:2] + "00"
    return bonus_display, (CYAN, MAGENTA)[bonus_timer < 1000], bonus_timer < 1000, bonus_timer <= -200
