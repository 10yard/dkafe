import os
from platform import platform
from datetime import datetime
os.environ['PYGAME_HIDE_SUPPORT_PROMPT'] = "1"
#os.environ['SDL_VIDEO_CENTERED'] = "1"
#os.environ['SDL_VIDEO_WINDOW_POS'] = "0,10"


def is_windows():
    # Is this a Windows OS?
    return "windows" in platform().lower()


def get_datetime():
    return datetime.now().strftime("%d%m%Y-%H%M%S")
