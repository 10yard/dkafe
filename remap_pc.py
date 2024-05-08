import keyboard
import sys

def kill_pc_external(pid=None, program=None):
    """force kill an external program"""
    from subprocess import call, DEVNULL, STDOUT
    if pid:
        call(f"taskkill /f /PID {pid}", stdout=DEVNULL, stderr=STDOUT)
    elif program:
        call(f"taskkill /f /IM {program}", stdout=DEVNULL, stderr=STDOUT)

def remap(name, mappings):
    """asynchronous: temporary keyboard remapping and force quit option"""
    for m in mappings.split(","):
        src, dst = m.split(">")
        if dst.startswith("forcequit"):
            # Force quit necessary for some PC games.  "forcequit:PROGRAMNAME" or "forcequit" to kill the default.
            if ":" in dst:
                _program = dst.split(":")[1]
            else:
                _program = f"{name}.*"
            keyboard.add_hotkey(src, lambda: kill_pc_external(program=_program))
        else:
            keyboard.remap_key(src, dst)
    while True:
        keyboard.wait()

if __name__ == "__main__":
    if len(sys.argv) >= 3:
        remap(sys.argv[1], sys.argv[2])