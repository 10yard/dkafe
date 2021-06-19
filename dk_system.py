#
#       ___   ___                    .-.
#      (   ) (   )                  /    \
#    .-.| |   | |   ___     .---.   | .`. ;    .--.
#   /   \ |   | |  (   )   / .-, \  | |(___)  /    \
#  |  .-. |   | |  ' /    (__) ; |  | |_     |  .-. ;
#  | |  | |   | |,' /       .'`  | (   __)   |  | | |
#  | |  | |   | .  '.      / .'| |  | |      |  |/  |
#  | |  | |   | | `. \    | /  | |  | |      |  ' _.'
#  | '  | |   | |   \ \   ; |  ; |  | |      |  .'.-.
#  ' `-'  /   | |    \ .  ' `-'  |  | |      '  `-' /  Donkey Kong Arcade Frontend
#   `.__,'   (___ ) (___) `.__.'_. (___)      `.__.'   by Jon Wilson
#
# ----------------------------------------------------------------------------------------------
#  System related functions
# ----------------------------------------------------------------------------------------------
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


def is_raspberry():
    # Check for Raspberry Pi.  Are we running on Arm architecture?
    try:
        if os.uname().machine.startswith("arm"):
            return True
        else:
            return False
    except AttributeError:
        return False


def get_datetime():
    return datetime.now().strftime("%d%m%Y-%H%M%S")


def intro_frames(climb_scene_only=False):
    return list(range(0, 100 * int(not climb_scene_only))) + list(sorted(glob("artwork/scene/scene_*.png")))


def read_romlist():
    # read romlist and return info about available roms (and shell scripts)
    romlist = []
    with open("romlist.csv", "r") as rl:
        for row in rl.readlines():
            if not row.startswith("#") and row.count(",") == 9:
                name, sub, des, alt, slot, emu, unlock, score3, score2, score1, *_ = [x.strip() for x in row.split(",")]
                if not emu.strip():
                   emu = "1"

                # DK Junior is optional in the default frontend so replace with DK Pies if not available
                if name == "dkongjr" and slot == "5" and not os.path.exists(os.path.join(ROM_DIR, "dkongjr.zip")):
                    name, sub, des, alt = "dkong", "dkongpies", "DK Pies", "DK Pies Only"

                # In record mode checks.
                if "-record" in get_emulator(int(emu)).lower():
                    if sub in LUA_HACKS:
                        # Recording is not supported for LUA hacks at the moment
                        emu = "1"
                    else:
                        # Score targets are not considered for recordings
                        score3, score2, score1 = ("",) * 3

                if name and des:
                    if not alt:
                        alt = des
                    icx, icy = -1, -1
                    if 0 < int(slot) <= len(SLOTS):
                        icx, icy = SLOTS[int(slot) - 1]
                    romlist.append((name, sub, des, alt, icx, icy, int(emu), int(unlock), score3, score2, score1))
    return romlist


def get_emulator(emu_number):
    return f'{(EMU_1, EMU_2, EMU_3, EMU_4, EMU_5, EMU_6, EMU_7, EMU_8)[emu_number - 1]}'


def build_launch_command(info, basic_mode):
    # Receives subfolder (optional), name, emulator, unlock and target scores from info
    # If mame emulator supports a rompath (recommended) then the rom can be launched direct from the subfolder
    # otherwise the file will be copied over the main rom to avoid a CRC check fail.  See ALLOW_ROM_OVERWRITE option.
    subfolder, name, emu, unlock, score3, score2, score1 = info
    emu_args = get_emulator(emu).replace("<NAME>", name).replace("<DATETIME>", get_datetime())
    launch_directory = os.path.dirname(emu_args.split(" ")[0])
    launch_command = f'{emu_args} {name}'
    competing = False

    if subfolder:
        if subfolder == "shell":
            # Launch a batch file or shell script from the shell subfolder
            launch_command = os.path.join(ROOT_DIR, "shell", name)
        elif "<ROM_DIR>" in emu_args:
            # Launch a rom and provide rom path
            launch_command = launch_command.replace("<ROM_DIR>", os.path.join(ROM_DIR, subfolder))
        elif int(ALLOW_ROM_OVERWRITE):
            # Copy rom to fixed rom path before launch. For emulators without a rompath argument e.g. Advmame.
            rom_source = os.path.join(ROM_DIR, subfolder, name + ".zip")
            rom_target = os.path.join(ROM_DIR, name + ".zip")
            if os.path.exists(rom_source):
                copy(rom_source, rom_target)
    else:
        launch_command = launch_command.replace("<ROM_DIR>", ROM_DIR)

    if not FULLSCREEN:
        launch_command += " -window"

    if (not basic_mode and "-record" not in launch_command) or subfolder in LUA_HACKS:
        script = lua_interface(get_emulator(emu), name, subfolder, score3, score2, score1, basic_mode)
        if script:
            # An interface script is available
            competing = True
            launch_command += f' -noconsole -autoboot_script {os.path.join(ROOT_DIR, "interface", script)}'
            launch_command += f' -fontpath {os.path.join(ROOT_DIR, "fonts")} -debugger_font_size 11 -uifont {ui_font}'

    return launch_command, launch_directory, competing


def get_bonus_timer(duration):
    return TIMER_START + 100 - (duration * 50)


def calculate_bonus(duration):
    # return bonus_display, colour, warning status, end of countdown
    bonus_timer = get_bonus_timer(duration)
    bonus_display = " 000" if bonus_timer <= 100 else str(int(bonus_timer)).rjust(4)[:2] + "00"
    return bonus_display, (CYAN, MAGENTA)[bonus_timer < 1000], bonus_timer < 1000, bonus_timer <= -200
