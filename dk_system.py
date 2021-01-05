import os
from platform import platform
from datetime import datetime
from glob import glob
from shutil import copy
os.environ['PYGAME_HIDE_SUPPORT_PROMPT'] = '1'
from dk_config import *


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
    with open("romlist.csv", "r") as rl:
        for rom_line in rl.readlines()[1:]:  # ignore the first/header line
            if not rom_line.startswith("#") and rom_line.count(",") == 8:
                name, sub, des, slot, emu, state, unlock, _min, bonus, *_ = [x.strip() for x in rom_line.split(",")]
                if name and des and SLOTS[int(slot) - 1]:
                    icx, icy = SLOTS[int(slot) - 1]
                    # target = name + (".sh", ".bat")[is_windows()] if subfolder == "shell" else name + ".zip"
                    # if os.path.exists(os.path.join((ROM_DIR, ROOT_DIR)[subfolder == "shell"], subfolder, target)):
                    romlist.append((name, sub, des, icx, icy, int(emu), state, int(unlock), _min, bonus))
    return romlist


def get_emulator(emu_number):
    return f'{(EMU_1, EMU_2, EMU_3, EMU_4, EMU_5, EMU_6, EMU_7, EMU_8)[emu_number - 1]}'


def build_shell_command(info):
    # Receives subfolder (optional), name, emulator and rom state from info
    # A homebew emulator is preferred for rom hacks but a good alternative is to provide a subfolder which holds a
    # variant of the main rom e.g. roms/skipstart/dkong.zip is a variant of roms/dkong.zip.  If mame emulator supports
    # rompath then the rom can be launched direct from the subfolder otherwise the file will be copied over the main
    # rom to avoid a CRC check fail.
    competing = False
    sub, name, emu, state, unlock, _min, bonus = info
    emu_command = get_emulator(emu).replace("<NAME>", name).replace("<DATETIME>", get_datetime())
    shell_command = f'{emu_command} {name}'
    emu_directory = os.path.dirname(emu_command.split(" ")[0])

    if sub:
        if sub == "shell":
            # Launch shell script / batch file
            shell_command = os.path.join(ROOT_DIR, "shell", name + (".sh", ".bat")[is_windows()])
            emu_directory = None
        elif "-rompath" in emu_command:
            # Launch rom and provide rom path
            shell_command = f'{emu_command}{os.sep}{sub} {name}'
        else:
            # Copy rom to the fixed rom path. Useful for emulators like advmame when -rompath argument is not supported.
            rom_source = os.path.join(ROM_DIR, sub, name + ".zip")
            rom_target = os.path.join(ROM_DIR, name + ".zip")
            if os.path.exists(rom_source):
                copy(rom_source, rom_target)

    if not FULLSCREEN:
        shell_command += " -window"

    # MAME/LUA interface
    if "-record" not in shell_command and "DISABLED" not in _min:
        from dk_interface import lua_interface
        if lua_interface(name, sub, _min):
            competing = True
            shell_command += f' -noconsole -autoboot_script {os.path.join(ROOT_DIR, "interface", "dkong.lua")}'

    if state:
        shell_command += f' -state {state.strip()}'
    return shell_command, emu_directory, competing


def get_bonus_timer(duration):
    return TIMER_START + 100 - (duration * 50)


def calculate_bonus(duration):
    # return bonus_display, colour, warning status, end of countdown
    bonus_timer = get_bonus_timer(duration)
    bonus_display = " 000" if bonus_timer <= 100 else str(int(bonus_timer)).rjust(4)[:2] + "00"
    return bonus_display, (CYAN, MAGENTA)[bonus_timer < 1000], bonus_timer < 1000, bonus_timer <= -200


def format_K(text):
    if text.endswith("000000"):
        return text[:-6] + "M"
    elif text.endswith("000"):
        return text[:-3] + "K"
    else:
        return text

