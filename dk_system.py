import os
from platform import platform
os.environ['PYGAME_HIDE_SUPPORT_PROMPT'] = "hide"


def is_windows():
    # Is this a Windows OS?
    return "windows" in platform().lower()



