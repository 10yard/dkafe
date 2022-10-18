"""
ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
 888    88o  888  o88        888       888          888
 888    888  888888         8  88      888ooo8      888ooo8
 888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
                                        by Jon Wilson (10yard)

System related functions
------------------------
"""
import os
from datetime import datetime
from time import sleep, time
from glob import glob
from shutil import copy, move, copytree
os.environ['PYGAME_HIDE_SUPPORT_PROMPT'] = '1'
from dk_config import *
from dk_interface import lua_interface


def debounce():
    sleep(0.2)


def is_pi():
    # Check for Raspberry Pi.  Are we running on Arm architecture?
    return "uname" in dir(os) and os.uname().machine.startswith("arm")


def get_datetime():
    return datetime.now().strftime("%Y%m%d-%H%M%S")


def format_datetime(datestring, suffix=""):
    return datetime.strptime(datestring, '%Y%m%d-%H%M%S').strftime(f"%d %b,%y at %H:%M{suffix}")


def intro_frames(climb_scene_only=False):
    return list(range(0, 100 * int(not climb_scene_only))) + list(sorted(glob("artwork/scene/scene_*.png")))


def apply_skill(base_score):
    if base_score and base_score.isnumeric() and 1 <= SKILL_LEVEL <= 10:
        return str(int(base_score) * SKILL_LEVEL)
    return base_score


def load_game_texts():
    # load game texts
    texts = []
    for filename in glob(os.path.join(PATCH_DIR, "*kong*.txt")):
        with open(filename, 'r') as f_in:
            texts.append([os.path.basename(filename).split(".")[0], f_in.readlines()])
    return texts


def read_romlist():
    # read romlist and return info about available roms (and shell scripts)
    romlist = []
    usedslots = []
    usedsubs = []
    with open("romlist.csv", "r") as rl:
        for row in rl.readlines():
            data = row.replace('"', '')
            if not data.startswith("#") and data.count(",") >= 10:
                name, sub, des, alt, slot, emu, rec, unlock, st3, st2, st1, *_ = [x.strip() for x in data.split(",")]
                if (name and des and slot not in usedslots) or (slot == "99" and sub not in usedsubs):
                    des = des.replace("DK ","$ ").replace("DK", "$ ")
                    des = des.replace("1/2","{ ").replace("1/4","} ")
                    des = des.replace("NO","| ") if des[:2] == "NO" else des

                    if name == "dkongjr" and not os.path.exists(DKONGJR_ZIP):
                        continue
                    if name == "dkong3" and not os.path.exists(DKONG3_ZIP):
                        continue
                    if name == "ckongpt2" and not os.path.exists(CKONG_ZIP):
                        continue
                    if not emu.strip():
                        emu = "1"
                    if not rec.strip():
                        rec = "0"
                    if not unlock:
                        unlock = "0"
                    if not alt:
                        alt = des

                    if "-record" in get_emulator(int(emu)).lower():
                        # Score targets are not considered for recordings
                        st3, st2, st1 = ("",) * 3

                    icx, icy = -1, -1
                    if 0 < int(slot) <= len(SLOTS):
                        icx, icy = SLOTS[int(slot) - 1]
                    st1 = apply_skill(st1)
                    st2 = apply_skill(st2)
                    st3 = apply_skill(st3)

                    usedslots.append(slot)
                    usedsubs.append(sub)
                    romlist.append((name, sub, des, alt, icx, icy, int(emu), int(rec), int(unlock), st3, st2, st1))
    return romlist


def get_emulator(emu_number):
    return f'{(EMU_1, EMU_2, EMU_3, EMU_4, EMU_5, EMU_6, EMU_7, EMU_8)[emu_number - 1]}'


def get_inp_dir(emu):
    return os.path.join(os.path.dirname(get_emulator(emu).split(" ")[0]), "inp")


def get_inp_files(rec, name, sub, num):
    # Return the 5 most recent .inp recordings for the specified rom
    return sorted(glob(os.path.join(get_inp_dir(rec), f"{name}_{sub}_*.inp")), reverse=True)[:num]


def build_launch_command(info, basic_mode=False, launch_plugin=None, playback=False):
    # Receives subfolder (optional), name, emulator, unlock and target scores from info
    # If mame emulator supports a rompath (recommended) then the rom can be launched direct from the subfolder
    # otherwise the file will be copied over the main rom to avoid a CRC check fail.  See ALLOW_ROM_OVERWRITE option.
    subfolder, name, emu, rec, unlock, score3, score2, score1 = info
    if playback:  # playback using the original emulator/settings
        emu = rec
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

        # Does the rom have a dedicated plugin?
        for plugin_folder, plugin in PLUGINS:
            if plugin_folder == subfolder:
                launch_command += f" -plugin {plugin}"

                if "dkwolf" not in launch_directory.lower():
                    # Not using standard emulator so check the plugin path exists and copy if necessary
                    plugin_target = os.path.join(launch_directory, "plugins", plugin_folder)
                    if not os.path.exists(plugin_target):
                        plugin_source = os.path.join(ROOT_DIR, "dkwolf", "plugins", plugin_folder)
                        copytree(plugin_source, plugin_target)
                    break

    else:
        launch_command = launch_command.replace("<ROM_DIR>", ROM_DIR)

    # Are we using an optional launch plugin?
    if launch_plugin and "-plugin" not in launch_command:
        # Are there any parameters for the plugin?
        if ":" in launch_plugin:
            launch_plugin, parameter, *_ = launch_plugin.split(":")
            os.environ[launch_plugin.upper() + "_PARAMETER"] = parameter
        else:
            os.environ[launch_plugin.upper() + "_PARAMETER"] = ""
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
        os.environ["DATA_ALLOW_SKIP_INTRO"] = str(ALLOW_SKIP_INTRO)

    return launch_command, launch_directory, competing, inp_file


def get_bonus_timer(duration):
    return TIMER_START + 100 - (duration * 50)


def calculate_bonus(duration):
    # return bonus_display, colour, warning status, end of countdown
    bonus_timer = get_bonus_timer(duration)
    bonus_display = " 000" if bonus_timer <= 100 else str(int(bonus_timer)).rjust(4)[:2] + "00"
    return bonus_display, (CYAN, MAGENTA)[bonus_timer < 1000], bonus_timer < 1000, bonus_timer <= -200
