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
from time import sleep, time
from glob import glob
from shutil import copy, move
os.environ['PYGAME_HIDE_SUPPORT_PROMPT'] = '1'
from dk_config import *
from dk_interface import lua_interface


def debounce():
    sleep(0.2)


def is_pi():
    # Check for Raspberry Pi.  Are we running on Arm architecture?
    try:
        if os.uname().machine.startswith("arm"):
            return True
        else:
            return False
    except AttributeError:
        return False


def get_datetime():
    return datetime.now().strftime("%Y%m%d-%H%M%S")


def format_datetime(datestring, suffix=""):
    datetime_object = datetime.strptime(datestring, '%Y%m%d-%H%M%S')
    return datetime_object.strftime(f"%d %b %y at %H:%M{suffix}")


def intro_frames(climb_scene_only=False):
    return list(range(0, 100 * int(not climb_scene_only))) + list(sorted(glob("artwork/scene/scene_*.png")))


def apply_skill(base_score):
    score = base_score
    if score and score.isnumeric() and 1 <= SKILL_LEVEL <= 10:
        score = str(int(score) * SKILL_LEVEL)
    return score


def read_romlist():
    # read romlist and return info about available roms (and shell scripts)
    romlist = []
    with open("romlist.csv", "r") as rl:
        for row in rl.readlines():
            data = row.replace('"', '')
            if not data.startswith("#") and data.count(",") >= 10:
                name, sub, des, alt, slot, emu, rec, unlock, st3, st2, st1, *_ = [x.strip() for x in data.split(",")]
                if not emu.strip():
                    emu = "1"
                if not rec.strip():
                    rec = "0"
                if not unlock:
                    unlock = "0"

                # DK Junior is optional in the default frontend so replace with DK Pies if not available
                if not os.path.exists(os.path.join(ROM_DIR, "dkongjr.zip")):
                    if name == "dkongjr" and slot == "3":
                        name, sub, des, alt = "dkong", "dkongpies", "DK Pies", "DK Pies Only"
                    elif sub == "dkongpies" and slot == "99":
                        continue

                if "-record" in get_emulator(int(emu)).lower():
                    # Score targets are not considered for recordings
                    st3, st2, st1 = ("",) * 3

                if name and des:
                    if not alt:
                        alt = des
                    icx, icy = -1, -1
                    if 0 < int(slot) <= len(SLOTS):
                        icx, icy = SLOTS[int(slot) - 1]
                    st1 = apply_skill(st1)
                    st2 = apply_skill(st2)
                    st3 = apply_skill(st3)
                    romlist.append((name, sub, des, alt, icx, icy, int(emu), int(rec), int(unlock), st3, st2, st1))
    return romlist


def get_emulator(emu_number):
    return f'{(EMU_1, EMU_2, EMU_3, EMU_4, EMU_5, EMU_6, EMU_7, EMU_8)[emu_number - 1]}'


def get_inp_dir(emu):
    return os.path.join(os.path.dirname(get_emulator(emu).split(" ")[0]), "inp")


def get_inp_files(emu, name, sub, num):
    # Return the 5 most recent .inp recordings for the specified rom
    _recordings = glob(os.path.join(get_inp_dir(emu), f"{name}_{sub}_*.inp"))
    return sorted(_recordings, reverse=True)[:num]


def build_launch_command(info, basic_mode=False, launch_plugin=None):
    # Receives subfolder (optional), name, emulator, unlock and target scores from info
    # If mame emulator supports a rompath (recommended) then the rom can be launched direct from the subfolder
    # otherwise the file will be copied over the main rom to avoid a CRC check fail.  See ALLOW_ROM_OVERWRITE option.
    subfolder, name, emu, rec, unlock, score3, score2, score1 = info
    emu_args = get_emulator(emu)
    inp_file = f"{name}_{subfolder}_{get_datetime()}_0m.inp"
    emu_args = emu_args.replace("<RECORD_ID>", inp_file)
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

        # Does the rom have a plugin?
        for plugin, plugin_folder in PLUGINS:
            if plugin == subfolder:
                launch_command += f" -plugin {plugin_folder}"
                break

    else:
        launch_command = launch_command.replace("<ROM_DIR>", ROM_DIR)

    # Are we using coaching?
    if launch_plugin and not "-plugin" in launch_command:
        launch_command += f" -plugin {launch_plugin}"

    if not FULLSCREEN:
        launch_command += " -window"

    launch_command += " -skip_gameinfo -nonvram_save"

    if not basic_mode and not launch_plugin and "-record" not in launch_command:
        script = lua_interface(get_emulator(emu), name, subfolder, score3, score2, score1, basic_mode)
        if script:
            # An interface script is available
            competing = True
            launch_command += f' -noconsole -autoboot_script {os.path.join(ROOT_DIR, "interface", script)}'

    if competing or launch_plugin:
        # Update options
        os.environ["DATA_CREDITS"] = str(CREDITS)
        os.environ["DATA_AUTOSTART"] = str(AUTOSTART) if CREDITS > 0 else "0"  # need credits to autostart
        os.environ["DATA_ALLOW_COIN_TO_END_GAME"] = str(ALLOW_COIN_TO_END_GAME)
        os.environ["DATA_ALLOW_SKIP_INTRO"] = str(ALLOW_SKIP_INTRO)

    return launch_command, launch_directory, competing, inp_file


def get_bonus_timer(duration):
    return TIMER_START + 100 - (duration * 50)


def calculate_bonus(duration):
    # return bonus_display, colour, warning status, end of countdown
    bonus_timer = get_bonus_timer(duration)
    bonus_display = " 000" if bonus_timer <= 100 else str(int(bonus_timer)).rjust(4)[:2] + "00"
    return bonus_display, (CYAN, MAGENTA)[bonus_timer < 1000], bonus_timer < 1000, bonus_timer <= -200
