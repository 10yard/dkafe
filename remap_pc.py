"""
ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
 888    88o  888  o88        888       888          888
 888    888  888888         8  88      888ooo8      888ooo8
 888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
                                        by Jon Wilson (10yard)

Remap Controls for PC and DOS systems
which can't be otherwise configured
-----------------------------------
"""
from subprocess import call, DEVNULL, STDOUT, CREATE_NO_WINDOW
import keyboard
import sys

def kill_pc_external(pid=None, program=None):
    """force kill an external program"""
    if pid:
        call(f"taskkill /f /PID {pid}", stdout=DEVNULL, stderr=STDOUT, creationflags=CREATE_NO_WINDOW)
    elif program:
        call(f"taskkill /f /IM {program}", stdout=DEVNULL, stderr=STDOUT, creationflags=CREATE_NO_WINDOW)
    # Ensure remappings are ended
    keyboard.unhook_all()
    call(f"taskkill /f /IM remap_pc.exe")

def remap(name, mappings):
    """asynchronous: temporary keyboard remapping and force quit option"""
    for m in mappings.split("|"):
        try:
            src, dst = m.split(">")
        except ValueError:
            continue
        if dst.startswith("forcequit"):
            # Force quit necessary for some PC games.  "forcequit:PROGRAMNAME" or "forcequit" to kill the default.
            if ":" in dst:
                _program = dst.split(":")[1]
            else:
                _program = f"{name}.*"
            keyboard.add_hotkey(src, lambda: kill_pc_external(program=_program))
        elif src.startswith("delayspace"):
            keyboard.call_later(fn=keyboard.send,args=" ", delay=float(dst))
        elif src.startswith("delayenter"):
            keyboard.call_later(fn=keyboard.send, args="\n", delay=float(dst))
        else:
            keyboard.remap_key(src, dst)
    while True:
        keyboard.wait()

if __name__ == "__main__":
    if len(sys.argv) >= 3:
        remap(sys.argv[1], sys.argv[2])