# **DKAFE** #

Donkey Kong Arcade Front End

A Python based arcade game launcher

Instructions
============
Donkey Kong has captured Pauline and carried her to the top of an abandoned construction site. The shock of shaking up the building during his ascent to the top has revealed many hidden old arcade machines from the 1980's era and they are scattered around the platforms.

Yes, the plot is a bit thin and I can't explain why Donkey Kong has decided to throw coins instead of barrels. Anyway, the coins must be collected by Jumpman and he must play games well, to win coins, so he can unlock and play all of the arcade machines.

Controls
========
The default controls are as follows.

```
Left/Right - Move Jumpman along the platforms.

Up/Down    - Move Jumpman up and down ladders. Up also faces Jumpman towards an arcade machine he wants to play.

P1 Start   - Play the arcade machine that Jumpman is facing. Jump also jumps :)
or Jump

P2 Start   - Calls up the quick access game list.
or Action

Coin       - Display useful game information above the arcade machines.

Esc        - Exit
```

Controls can be customised in the settings.txt file using the "common name" to identify the key.  [Refer to this table.](http://thepythongamebook.com/en:glossary:p:pygame:keycodes)

The default controls are set as follows.

```
CONTROL_LEFT = left
CONTROL_RIGHT = right
CONTROL_UP = up
CONTROL_DOWN = down
CONTROL_JUMP = left ctrl
CONTROL_ACTION = left alt
CONTROL_START = 1
CONTROL_MENU = 2
CONTROL_INFO = 5
CONTROL_EXIT = escape
```

How to set up?
==============
Requires Python3 (recommended v3.7) with installed packages from requirements.txt

The application requires romlist.txt and settings.txt to be present in the installation folder along with dependant folders/resources.
 
The settings.txt contains the emulator, rom path, controls and other configuration.

The romlist.txt contains the roms and information about where they appear in the frontend and how they are unlocked and launched.  You must set up your own roms.

The frontend can be configured with multiple arcade emulators to allow a combination of standard arcade roms,  hacked and homebrew roms and to support Wolfmame recordings.

The launch emulator is specified in the settings.txt and the romlist.txt.  Refer to example files.  You must configure your own based on your available roms.

Mamedev maintains a list of free roms at:

https://www.mamedev.org/roms/

How to build?
=============
Pyinstaller is required to build the application on Windows
  - pyinstaller launch.py --onefile --clean --console --icon artwork\dkafe.ico

See build.bat for an example build script making use of a venv (virtual environment for Python)

Emulator recommendation
=======================
For Windows
-----------
1. No nag Mame64 v0226 build here:
   - https://insertmorecoins.es/mame-mameui-0-226-32-64-bits-no-nag-including-mess/

2. Wolfmame v0226 (for competition/recording) here:
   - https://github.com/mahlemiut/wolfmame/releases/tag/wolf226

3. HB Mame v0226 (Dedicated to hacks and homebrew) here: 
   - http://www.progettosnaps.net/download?tipo=arcade_bin&file=/arcade/packs/ARCADE64_226_28102020.7z


For Raspberry Pi
----------------
I get along best with advance mame:
  - https://github.com/amadvance/advancemame/releases/download/v3.9/advancemame_3.9-1_armhf.deb

on top of dietpi lightweight OS:
  - https://dietpi.com/

How to use romlist.txt
======================
The file can be configured to launch roms from the default rom directory (by leaving subfolder blank) or from a specified subfolder.  

The subfolder is useful when you have multiple roms with the same name e.g. there are lots of hacked versions of dkong.zip.  If the emulator supports -rompath then dkafe will launch the rom directly otherwise the rom will be copied over to the main rompath to workaround CRC checks.  If not providing -rompath then I recommend the original rom to be placed into /original subfolder to prevent it being overwritten.

The special subfolder name "shell" can be used when you want to launch a batch file or shell script.  Create a file named <romname>.bat on Windows or <romname>.sh elsewhere inside the shell subfolder of dkafe.

Multiple emulators can be configured in settings.txt and the launch emulator can be set in the emu column. If blank the default 0 will be used.

All roms in the list should be given a slot position (between 1 and 46) of where the icon should appear and a basic descriptive name.

All roms should also have a similarly named image as a .png file in the /artwork/icons folder or subfolder.  You can use the default_machine.png as a template.

Hopefully that all makes sense.  Refer to the example romlist.csv


Motivations?
============
This application was made for my own DIY Donkey Kong arcade machine as a replacement for a 60-in-1 board.  The front end is rendered at 224x256 pixels and is graphically in keeping with the era.
I aim to Install to Raspberry Pi with Jamma connectivity.

Thanks to:

The community at Donkey Kong Forum
https://donkeykongforum.com/

The Donkey Kong rom hacking resource helped me understand how default scores are read and moved around RAM in the Donkey Kong and Donkey Kong Junior roms.
https://github.com/furrykef/dkdasm 

An excellent set of Donkey Kong rom hacks and hacking reference material from Paul Goes.
https://donkeykonghacks.net/

Jon