# **DKAFE** #

Donkey Kong Arcade Front End

An interactive arcade game launcher with objectives and incentives to play and unlock arcade games.

![DKAFE frontend](https://github.com/10yard/dkafe/blob/master/artwork/snaps/frontend.png){:height="448px" width="512px"}

Instructions
============
Donkey Kong has captured Pauline and carried her to the top of an abandoned construction site. The shock of shaking up the building during his ascent has uncovered many hidden arcade machines from the 1980's era and they are scattered around the area. 

Yes, the plot is thin and I can't explain why Donkey Kong has decided to throw coins instead of barrels. Anyway, the coins must be collected by Jumpman and he must play games well, winning coins and working up  the building unlocking all of the arcade machines along the way.  

Pauline will love it when you beat all of the machines.


Controls
========
The default keyboard controls are as follows.

```
Left/Right - Move Jumpman along the platforms.

Up/Down    - Move Jumpman up and down ladders. Up also faces Jumpman towards an arcade machine he wants to play.

P1 Start   - Play the arcade machine that Jumpman is facing. Jump also jumps :)
or Jump

P2 Start   - Calls up the quick access game list.

Action     - Display useful game information above the arcade machines.

Coin       - Show slot numbers.

Esc        - Exit
```

Keyboard controls can be customised in the settings.txt file using the "common name" to identify the key.  [Refer to this table.](http://thepythongamebook.com/en:glossary:p:pygame:keycodes)
The default controls are aligned with MAME keys as follows.

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

Joystick controls can also be configured.
The up, down, left, right controls are defined automatically from the joystick axis movement.
Buttons can be customised in the settings.txt file as per the following example along with the USE_JOYSTICK option.  
Button assignment numbers 0-19 relate to the first joystick device and 20-39 relate to a second joystick device.

```
USE_JOYSTICK = 1
BUTTON_JUMP = 0
BUTTON_ACTION = 1
BUTTON_P1 = 9
BUTTON_P2 = 29
BUTTON_EXIT = 6
BUTTON_COIN = 7
```


How to set up?
==============
The application requires romlist.csv and settings.txt to be present in the installation folder along with other resources.
 
The settings.txt contains the emulator, rom path, controls and other configuration.

The romlist.csv contains information about the roms, which slot they should appear in and how they can be unlocked and launched in the frontend.  You must provide your own roms.

Mamedev maintains a list of free roms at:

https://www.mamedev.org/roms/

The frontend can be configured with multiple arcade emulators to allow a combination of standard arcade roms,  hacked and homebrew roms and to support Wolfmame recordings.

The default set up simply requires that you provide "dkong.zip" and "dkongjr.zip" rom and place them into the DKAFE roms subfolder.  The frontend can automatically generate roms for a whole bunch of Donkey Kong variants using patches which are included with the software.  See "Automatically generated roms" section below. 


Resolution
==========
The frontend is rendered at 224x256 pixels (as per the original Donkey Kong arcade machine) and then scaled to fit the monitors actual resolution.
The scaling works perfectly with a 7/8 aspect vertically rotated screen.
For my system,  I was able to create a custom 7/8 aspect resoluton of 448x512 pixels with the Intel Graphics Driver.


Automatically generated roms
============================
DKAFE builds a default frontend using various patches of the original "dkong.zip" (US Set 1) arcade rom. 

The patches are included with the software in the patch folder.
The orginal Donkey Kong rom is not provided with the software and must be obtained and placed into the dkafe/roms folder as dkong.zip.  It is recommended but not essential for you to also place dkongjr.zip into the dkafe/roms folder.  
DKAFE can apply patches and generate the following hacked Donkey Kong roms automatically for you.  The hacked versions will be organised into subfolders.  The folder name is given in brackets.

By Paul Goes, https://donkeykonghacks.net/
 - Donkey Kong Crazy Barrels Edition (dkongcb)
 - Donkey Kong Championship Edition (dkongce)
 - Donkey Kong Randomized Edition (dkongrnd)
 - Donkey Kong Freerun Edition (dkongfr)
 - Donkey Kong Into The Dark (dkongitd)
 - Donkey Kong Skip Start (dkongl05)
 - Donkey Kong On The Run (dkongotr)
 - Donkey Kong Reverse (dkongrev)

By John Kowalski (Sock Master) 
 - Donkey Kong Spooky Remix (dkongspooky)
 - Donkey Kong Christmas Remix (dkongxmas)
 - Donkey Kong Springs Trainer (dkongst2)
 - Donkey Kong Trainer (dkongtrn)
 - Donkey Kong Rainbow (dkongrainbow)

By Jeff Kulczycki, http://www.jeffsromhack.com/products/d2k.htm
 - Donkey Kong 2 Jumpman Returns (dkongdk2)
 - Donkey Kong Foundry (dkongf)
 - Donkey Kong Barrel Control Colouring (dkongbcc)

By Mike Mika
 - Donkey Kong Pauline Edition (dkongpe)

By Don Hodges, http://www.donhodges.com/how_high_can_you_get.htm
 - Donkey Kong Kill Screen Fix (dkongksfix)

By Jon Wilson (me)
 - DK Who and the Daleks
 - Donkey Kong Lava Panic
 - DK Last Man Standing

By unknown others
 - Donkey Kong Wild Barrel Hack (dkongwbh)
 - Donkey Kong 2 Marios (dkong2m)
 - Donkey Kong Hard (dkonghrd)
 - Donkey Kong Pace (dkongpace)


How to use romlist.csv
======================
A default romlist.csv is provided for use with the automatically generated roms (above).

The file can be configured to launch roms from the default rom directory (by leaving subfolder blank) or from a specified subfolder.  

The subfolder is useful when you have multiple roms with the same name e.g. there are lots of hacked versions of dkong.zip.  If the emulator supports -rompath then dkafe will launch the rom directly otherwise the rom will be copied over to the main rompath to workaround CRC checks.  If not providing -rompath then I recommend the original rom to be placed into /original subfolder to prevent it being overwritten.

The special subfolder name "shell" can be used when you want to launch a batch file or shell script.  Create a file named <romname>.bat on Windows or <romname>.sh elsewhere inside the shell subfolder of dkafe.

All roms in the list should be given a slot position (between 1 and 46) of where the icon should appear and a basic descriptive name.

Multiple emulators can be configured in settings.txt and the launch emulator can be set in the emu column. If blank the default 0 will be used.

All roms should be provided with a similarly named image as a .png file in the /artwork/icons folder or subfolder.  You can use the default_machine.png as a template.

Hopefully that all makes sense.  Refer to the example romlist.csv


Emulator recommendation
=======================
For Windows
-----------
1. Mame64 v0197 from https://www.mamedev.org/

2. Wolfmame v0165 (for competition/recording) from https://github.com/mahlemiut/wolfmame/releases/

3. HB Mame (Dedicated to hacks and homebrew) from https://www.progettosnaps.net/hbmame/

For Raspberry Pi
----------------
I get along best with advance mame:
  - https://github.com/amadvance/advancemame/releases/download/v3.9/advancemame_3.9-1_armhf.deb

on top of dietpi lightweight OS:
  - https://dietpi.com/
  

How to build?
=============
Requires Python3 (from v3.7) with installed packages from requirements.txt

Pyinstaller can be used to build the application binary on Windows.
  - pyinstaller launch.py --onefile --clean --console --icon artwork\dkafe.ico

See build.bat for an example build script making use of venv (virtual environment for Python)


Motivations?
============
The application was developed for my own DIY Donkey Kong arcade machine as a replacement for a 60-in-1 board.  I was looking to create something graphically in keeping with the era (rendering graphics at 224x256) feel relevant to the early 80's.  Bringing together all of the Donkey Kong roms and rom hacks into one place with an incentive to play them and tools to aid my progression (trainers) and .inp recording capability for score submissions.  I want it to startup quickly and be capable of running on multiple platforms (Windows, Mac, Rasp Pi, Android).


Thanks to
=========

The MAMEdev team
https://docs.mamedev.org/

The community at Donkey Kong Forum
https://donkeykongforum.com/

The Donkey Kong rom hacking resource
https://github.com/furrykef/dkdasm 

Paul Goes for an excellent set of Donkey Kong hacking reference material
https://donkeykonghacks.net/

Fantastic Donkey Kong hacks from Sockmaster (John Kowalski), Paul Goes, Jeff Kulczycki, Mike Mika and Don Hodges.

WolfMAME by Mahlemiut
https://github.com/mahlemiut/wolfmame

Python and pygame
https://www.python.org/ and https://www.pygame.org/


Feedback
========

Please send feedback to jon123wilson@hotmail.com

Jon