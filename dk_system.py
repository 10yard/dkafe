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
import sys
from datetime import datetime
from glob import glob
from shutil import copy, move, copytree
from time import sleep, time
from dk_config import *
from dk_interface import lua_interface


def debounce():
    sleep(0.05)

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
    for filename in glob(os.path.join(PATCH_DIR, "gametext", "*.txt")):
        with open(filename) as f_in:
            try:
                texts.append([os.path.basename(filename).split(".")[0], f_in.readlines()])
            except UnicodeDecodeError:
                pass
    return texts


def read_romlist(specific_romlist_file=None):
    # read romlists and return info about available roms (and shell scripts)
    count_dk, count_other = 0, 0
    romlists = {}
    usedslots, usedsubs, usedunique = [], [], []
    romlist_files = ROMLIST_FILES if not specific_romlist_file else [specific_romlist_file, '']
    for i, csv in enumerate(reversed(romlist_files)):
        romlists[i] = []
        if os.path.exists(csv):
            with open(csv) as rl:
                for row in rl.readlines():
                    data = row.replace('"', '')
                    if data.strip() and not data.startswith("#") and not data.startswith(",,") and data.count(",") >= 10:
                        # read romlist data and tweak the descriptions
                        name, sub, des, alt, slot, emu, rec, unlock, st3, st2, st1, *_ = [x.strip() for x in data.split(",")]

                        slot = slot.split(".")[0] # decimal places are used only for sorting
                        if not slot:
                            slot = "9999"
                        _shell = sub == "shell"
                        if _shell or sub not in usedsubs:
                            if not _shell and not os.path.exists(os.path.join(ROM_DIR, sub, name + ".zip")) and not os.path.exists(os.path.join(ROM_DIR, sub, "dkong.zip")):
                                # Skip over roms when files are not found
                                continue
                            if ARCH != "win64" and name.split("_")[0] in WIN64_ONLY_SYSTEMS:
                                # Skip over incompatible roms
                                continue
                            if ARCH != "win64" and name in STATEKEEP_MEDIA_EXCEPTIONS:
                                # Skip over roms that use a .statekeep file when not running Win64
                                continue
                            if name in OPTIONAL_NAMES and not os.path.exists(os.path.join(ROM_DIR, name + ".zip")):
                                # Skip over specific hacks when an optional rom is not found e.g. Galakong JR
                                continue

                            if not alt:
                                alt = des
                            des = des.replace("DK ", "$ ").replace("DK", "$ ")
                            des = des.replace("CK ", "# ").replace("CK", "# ")
                            des = des.replace("BK ", "^ ").replace("BK", "^ ")
                            des = des.replace("ZK ", "² ").replace("ZK", "² ")
                            des = des.replace("JR ", "³ ").replace("JR", "³ ")
                            des = des.replace("1/2", "{ ").replace("1/4", "} ")

                            alt = alt.replace("00", "№")  # Single character 00

                            # Assume defaults when not provided
                            if not emu:
                                emu = "1" if not _shell else "0"
                            if not rec:
                                rec = "0"
                            if not unlock:
                                unlock = "0"

                            # Get the score targets
                            if "-record" in get_emulator(int(emu)).lower():
                                # Score targets are not considered for recordings
                                st3, st2, st1 = ("",) * 3
                            st1 = apply_skill(st1)
                            st2 = apply_skill(st2)
                            st3 = apply_skill(st3)

                            # Get slot location
                            icx, icy = -1, -1
                            if 0 < int(slot) <= len(SLOTS):
                                icx, icy = SLOTS[int(slot) - 1]

                            if (name and des) or name == "empty":
                                if slot in usedslots:
                                    slot = "9999"
                                    icx, icy = -1, -1
                                elif sub:
                                    usedsubs.append(sub)
                                if name != "empty":
                                    # is this an add-on rom
                                    add = sub == "shell" and name.split("_")[0].replace("-", "_") in RECOGNISED_SYSTEMS
                                    if name + "|" + sub not in usedunique:
                                        romlists[i].append((name, sub, des, alt, slot, icx, icy, int(emu), int(rec), int(unlock), st3, st2, st1, add))
                                        usedunique.append(name + "|" + sub)
                                        if int(emu) < 3:
                                            count_dk += 1
                                        else:
                                            count_other += 1
                                usedslots.append(slot)
    return romlists[1] + romlists[0], count_dk - count_other


def get_romkeys(romlist):
    keys = []
    for rom in romlist:
        keys.append(rom[1] + rom[0])


def get_emulator(emu_number):
    return f'{(EMU_1, EMU_2, EMU_3, EMU_4, EMU_5, EMU_6, EMU_7, EMU_8)[emu_number - 1]}'


def get_inp_dir(emu):
    emu_param = get_emulator(emu).split(" ")[0]
    if "dkwolf" in get_emulator(emu).lower() and "dkwolf" not in emu_param.lower():
        return os.path.join(ROOT_DIR, "dkwolf", "inp")
    else:
        return os.path.join(os.path.dirname(emu_param), "inp")


def get_inp_files(rec, name, sub, num):
    # Return the 5 most recent .inp recordings for the specified rom
    return sorted(glob(os.path.join(get_inp_dir(rec), f"{name}_{sub}_*.inp")), reverse=True)[:num]


def add_plugin(command, plugin):
    return f"{command},{plugin}" if "-plugin " in command else f"{command} -plugin {plugin}"


def build_launch_command(info, basic_mode=False, high_score_save=False, refocus=False, fullscreen=True, launch_plugin=None, playback=False):
    # Receives subfolder (optional), name, emulator, unlock and target scores from info
    # If mame emulator supports a rompath (recommended) then the rom can be launched direct from the subfolder
    # otherwise the file will be copied over the main rom to avoid a CRC check fail.  See ALLOW_ROM_OVERWRITE option.
    subfolder, name, alt, emu, rec, unlock, score3, score2, score1 = info
    if playback:  # playback using the original emulator/settings
        emu = rec
    emu_args = get_emulator(emu)
    inp_file = f"{name}_{subfolder}_{get_datetime()}_0m.inp"
    emu_args = emu_args.replace("<RECORD_ID>", inp_file)
    emu_param = os.path.normpath(emu_args.split(" ")[0])
    launch_directory = os.path.normpath(os.path.dirname(emu_param))
    launch_command = f'{emu_args} {name}'
    competing = False
    parameter_plugin = None

    if "dkwolf" in emu_args.lower() and "dkwolf" not in emu_param.lower():
        # Assume dkwolf defaults when there is an issue with the target path
        launch_directory = os.path.normpath(os.path.join(ROOT_DIR, "dkwolf"))
        if "-record" in emu_args:
            launch_command = f'"{os.path.join(launch_directory, "dkwolf")}" {OPTIONS} -record {inp_file} {name}'
        else:
            launch_command = f'"{os.path.join(launch_directory, "dkwolf")}" {OPTIONS} {name}'

    if subfolder:
        if subfolder == "shell":
            _system = name.split("_")[0].replace("-", "_")
            # Launch a batch file or shell script from the shell subfolder
            # environmental variables can be used in the shell
            os.environ["DKAFE_SHELL_VIDEO"] = f'-video {get_system(return_video=True)} {["-window", ""][fullscreen]}'
            os.environ["DKAFE_SHELL_ROOT"] = ROOT_DIR
            os.environ["DKAFE_SHELL_ROMS"] = ROM_DIR
            os.environ["DKAFE_SHELL_SYSTEM"] = _system
            os.environ["DKAFE_SHELL_NAME"] = name
            os.environ["DKAFE_SHELL_NAME_2"] = name.split("_")[1] if "_" in name else name
            os.environ["DKAFE_SHELL_MEDIA"] = GAME_MEDIA.get(name) or SYSTEM_MEDIA.get(_system) or "-cart"
            if name in STATEKEEP_MEDIA_EXCEPTIONS:
                # .statekeep is for exceptions, when the generation of .state is not possible using shell.lua
                # e.g. gbcolor will not listen to simulated keyboard inputs so a state file is created independently
                if ARCH == "win64":
                    os.environ["DKAFE_SHELL_STATE"] = os.path.normpath(os.path.join(ROM_DIR, _system, name + ".statekeep"))
            else:
                os.environ["DKAFE_SHELL_STATE"] = os.path.normpath(os.path.join(ROM_DIR, _system, name + ".state"))
            if is_pi():
                os.environ["DKAFE_SHELL_BOOT"] = f'-script {os.path.join(ROOT_DIR, "interface", "shell.lua")}'
            else:
                os.environ["DKAFE_SHELL_BOOT"] = f'-script "{os.path.join(ROOT_DIR, "interface", "shell.lua")}"'
            os.environ["DKAFE_SHELL_ROR"] = ""
            os.environ["DKAFE_SHELL_ARCH"] = ARCH
            if "_ror" in name:
                os.environ["DKAFE_SHELL_ROR"] = "-ror"
                os.environ["DKAFE_SHELL_BOOT"] = ""
            os.environ["DKAFE_SHELL_PLUGIN"] = ""
            if launch_plugin:
                os.environ["DKAFE_SHELL_PLUGIN"] = f"-plugin {launch_plugin}"

            # If there is a specific config file then copy it over system default prior to running
            cfg_file = os.path.join(ROOT_DIR, "dkwolf", "cfg", name + ".cfg")
            if os.path.exists(cfg_file):
                cfg_system = os.path.join(ROOT_DIR, "dkwolf", "cfg", _system + ".cfg")
                copy(cfg_file, cfg_system)

            launch_command = os.path.join(ROOT_DIR, "shell", name + (".bat", ".sh")[is_pi()])
            if not os.path.exists(launch_command):
                if _system in RECOGNISED_SYSTEMS:
                    _system_shellfile = os.path.join(ROOT_DIR, "shell", _system + (".bat", ".sh")[is_pi()])
                    if os.path.exists(_system_shellfile):
                        # There is a system specific shell file
                        launch_command = _system_shellfile
                    else:
                        launch_command = os.path.join(ROOT_DIR, "shell", "default_console" + (".bat", ".sh")[is_pi()])
                else:
                    # use default shell when a specific file is not found
                    launch_command = os.path.join(ROOT_DIR, "shell", "default" + (".bat", ".sh")[is_pi()])
        else:
            if "<ROM_DIR>" in launch_command:
                # Launch a rom and provide rom path
                launch_command = launch_command.replace("<ROM_DIR>", os.path.normpath(os.path.join(ROM_DIR, subfolder)))
            elif int(ALLOW_ROM_OVERWRITE):
                # Copy rom to fixed rom path before launch. For emulators without a rompath argument e.g. Advmame.
                rom_source = os.path.join(ROM_DIR, subfolder, name + ".zip")
                rom_target = os.path.join(ROM_DIR, name + ".zip")
                if os.path.exists(rom_source):
                    copy(rom_source, rom_target)

            # Does the rom have a dedicated plugin?
            for plugin_folder, plugin in PLUGINS:
                if plugin_folder == subfolder:
                    if ":" in plugin:
                        # Plugin is launched with parameters and can compete (unlike a menu launch plugin).
                        parameter_plugin = plugin
                        break
                    else:
                        # Regular plugin
                        launch_command += f" -plugin {plugin}"

                        if "dkwolf" not in launch_command.lower():
                            # Not using standard emulator so check the plugin path exists and copy if necessary
                            plugin_target = os.path.join(launch_directory, "plugins", plugin)
                            if not os.path.exists(plugin_target):
                                plugin_source = os.path.join(ROOT_DIR, "dkwolf", "plugins", plugin)
                                if os.path.exists(plugin_source):
                                    copytree(plugin_source, plugin_target)
                            break

    else:
        launch_command = launch_command.replace("<ROM_DIR>", os.path.normpath(ROM_DIR))

    if subfolder == "shell":
        if not basic_mode:
            os.environ["DATA_ANNOUNCE_AWARD"] = str(ANNOUNCE_AWARD_INGAME)
            script = lua_interface("shell", name, subfolder, score3, score2, score1, basic_mode)
            competing = True
    else:
        # Reset the optional parameters for all available plugins
        for filename in os.listdir(os.path.join(ROOT_DIR, "dkwolf", "plugins")):
            if os.path.isdir(os.path.join(ROOT_DIR, "dkwolf", "plugins", filename)):
                os.environ[f"{filename.upper()}_PARAMETER"] = ""

        os.environ["ALLENKONG_PARAMETER"] = ""  # TO DO: Reset based on plugin name

        # Are we using an optional launch plugin or parameter plugin?
        if parameter_plugin:
            # Parameter plugins are not subject to competing and highscore restrictions
            launch_plugin = parameter_plugin
        if launch_plugin:
            # Are there any parameters for the plugin?
            if ":" in launch_plugin:
                launch_plugin, parameter, *_ = launch_plugin.split(":")
                os.environ[launch_plugin.upper() + "_PARAMETER"] = parameter
            else:
                os.environ[launch_plugin.upper() + "_PARAMETER"] = ""
            launch_command = add_plugin(launch_command, launch_plugin)
        if parameter_plugin:
            # Clear launch plugin so the following restrictions are not applied
            launch_plugin = None

        # Are we using the hiscore plugin - and no launch plugin (such as stage practice or level 5 start) ?
        if high_score_save and not launch_plugin and subfolder not in HISCORE_UNFRIENDLY:
            os.environ["DKAFE_SUBFOLDER"] = subfolder + "_" if subfolder else ""
            launch_command = add_plugin(launch_command, "hiscore")

        # Are we using the refocus plugin
        if refocus:
            launch_command = add_plugin(launch_command, "refocus")

        # Should we use the skipstartupframes plugin
        if "dkwolf" in launch_command and "_addon" in launch_command and ("roms/other" in launch_command or "roms\\other" in launch_command):
            launch_command = add_plugin(launch_command, "skipstartupframes")

        if not fullscreen:
            launch_command += " -window"

        launch_command += " -skip_gameinfo -nonvram_save"


        if not basic_mode and not launch_plugin and "-record" not in launch_command:
            script = lua_interface(get_emulator(emu), name, subfolder, score3, score2, score1, basic_mode)
            if script:
                # An interface script is available
                competing = True
                launch_command += f' -noconsole -autoboot_script "{os.path.join(ROOT_DIR, "interface", script)}"'

        os.environ["DATA_AUTOSTART"] = "0"
        if competing or launch_plugin:
            # Update options
            os.environ["DATA_CREDITS"] = str(CREDITS + int(CREDITS and subfolder in ADDITIONAL_CREDIT))
            if competing:
                os.environ["DATA_AUTOSTART"] = str(AUTOSTART) if CREDITS > 0 and subfolder not in AUTOSTART_UNFRIENDLY else "0"
            os.environ["DATA_ALLOW_SKIP_INTRO"] = str(ALLOW_SKIP_INTRO) if subfolder not in SKIPINTRO_UNFRIENDLY else "0"
            os.environ["DATA_ANNOUNCE_AWARD"] = str(ANNOUNCE_AWARD_INGAME)

    if sys.gettrace():
        print(launch_command)  # debug launch arguments
    return launch_command, launch_directory, competing, inp_file


def get_bonus_timer(duration):
    return TIMER_START + 100 - (duration * 50)


def calculate_bonus(duration):
    # return bonus_display, colour, warning status, end of countdown
    bonus_timer = get_bonus_timer(duration)
    bonus_display = " 000" if bonus_timer <= 100 else str(int(bonus_timer)).rjust(4)[:2] + "00"
    return bonus_display, (0, 1)[bonus_timer < 1000], bonus_timer < 1000, bonus_timer <= -200
