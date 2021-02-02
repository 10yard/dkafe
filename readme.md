# **DKAFE** #

Donkey Kong Arcade Front End

A Donkey Kong themed arcade game launcher made for arcade cabinets with incentives to play and unlock arcade games.  


![DKAFE frontend](https://github.com/10yard/dkafe/blob/master/artwork/snaps/frontend.png)


This project includes:
 - An interactive frontend launcher that comes preconfigured to work with classic Donkey Kong roms and hacks.
 - A custom lightweight version of WolfMAME built specifically for Donkey Kong.
 - Scripts to interface MAME with the frontend allowing for data to pass seamlessly.
 - A rom patcher that will automatically generate 27 hacks using the included Donkey Kong patch files.
 - 3 Donkey Kong hacks made specifically by me for use with DKAFE:
   - **DK Who and the Daleks** - Jumpman has regenerated as the next Dr Who and can use the Tardis to teleport through spacetime.
   - **DK Lava Panic** - Jumpman must keep his cool and move quickly to avoid the rising Lava.
   - **DK Last Man Standing** - You wil lose penalty points instead of lives so don't make mistakes unless you have earned enough points to survive.

This project does not include:
 - Roms


## Plot

Donkey Kong has captured Pauline and carried her to the top of an abandoned construction site. The shock of shaking up the building during his ascent has uncovered many hidden arcade machines from the 1980's era and they are scattered around the site. 

Yes, the plot is thin and I can't explain why Donkey Kong has decided to throw coins instead of barrels. Anyway, the coins must be collected by Jumpman and he must play games well to win coins and unlock arcade machines as he works his way up the building to rescue Pauline.  

Pauline will love it when you beat all of the machines.


## Automatically generated roms

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

By John Kowalski (Sock Master), http://users.axess.com/twilight/sock/
 - Donkey Kong Spooky Remix (dkongspooky)
 - Donkey Kong Christmas Remix (dkongxmas)
 - Donkey Kong Springs Trainer (dkongst2)
 - Donkey Kong Trainer (dkongtrn)
 - Donkey Kong Pace (dkongpace)
 - Donkey Kong Rainbow (dkongrainbow)

By Jeff Kulczycki, http://www.jeffsromhack.com/products/d2k.htm
 - Donkey Kong 2 Jumpman Returns (dkongdk2)
 - Donkey Kong Foundry (dkongf)
 - Donkey Kong Barrel Control Colouring (dkongbcc)

By Mike Mika and Clay Cowgill, http://www.multigame.com/dkp_arcade.html
 - Donkey Kong Pauline Edition (dkongpe)

By Don Hodges, http://www.donhodges.com/how_high_can_you_get.htm
 - Donkey Kong Kill Screen Fix (dkongksfix)

By Jon Wilson (me)
 - DK Who and the Daleks (dkongwho)
 - Donkey Kong Lava Panic (dkonglava)
 - DK Last Man Standing (dkonglastman)

By unknown others
 - Donkey Kong Wild Barrel Hack (dkongwbh)
 - Donkey Kong 2 Marios (dkong2m)
 - Donkey Kong Hard (dkonghrd)


![DKAFE hacks](https://github.com/10yard/dkafe/blob/master/artwork/snaps/dkwho_gameplay.png)


## DK WolfMAME

DKAFE comes bundled with my custom lightweight build of WolfMAME (v0.196) which supports only Donkey Kong drivers. 
This version has functionality disabled for save/load states, cheats, rewind, throttling etc. to make competition more challenging.
It is possible to set up other emulators and roms if you do not wish to use the default Donkey Kong focussed front end.

Recordings are saved to \inp subfolder of DKWOLF and can be replayed outside of DKAFE using the playback.bat passing romname and inp file name e.g.
```
playback dkong dkong_01022021-084510 
```

## Display Resolution

The frontend is rendered at 224x256 pixels (as per the original Donkey Kong arcade machine) and then scaled to fit the monitors actual resolution.
The scaling works perfectly with a 7/8 aspect vertically rotated screen.
For my system,  I was able to create a custom 7/8 aspect resoluton of 448x512 pixels with the Intel Graphics Driver.


## How to set up?

The application requires romlist.csv and settings.txt to be present in the installation folder along with other resources.
 
The settings.txt contains the emulator, rom path, controls and other configuration.

The romlist.csv contains information about the roms, which slot they should appear in and how they can be unlocked and launched in the frontend.  You must provide your own roms.

Mamedev maintains a list of free roms at:

https://www.mamedev.org/roms/

The frontend can be configured with multiple arcade emulators to allow a combination of standard arcade roms,  hacked and homebrew roms and to support Wolfmame recordings.

The default set up simply requires that you provide "dkong.zip" and "dkongjr.zip" rom and place them into the DKAFE roms subfolder.  The frontend can automatically generate roms for a whole bunch of Donkey Kong variants using patches which are included with the software.  See "Automatically generated roms" section above. 


### Frontend Settings

Default settings can be changed in the settings.txt file.

```
FULLSCREEN = 1
```
1 for fullscreen mode or 0 for windowed mode.

```
FREE_PLAY = 0
```
1 for free play.  If 0 then Jumpman must collect sufficient coins to play a game.

```
UNLOCK_MODE = 1
```
1 for unlock mode were Jumpman must score points to unlock games.  If 0 then all games are unlocked by default.

```
CONFIRM_EXIT = 1
```
1 to display confirmation screen when attempting to exit.  0 to exit without question.

```
ENABLE_HAMMERS=1
```
1 to enable teleport between hammers in the fronted to make it quicker to move up/down the platforms.

```
INACTIVE_TIME = 20
```
Period of inactivity in seconds before showing screensaver/game instructions.

```
PLAY_COST = 100
```
How much it costs to play an arcade machine.

```
LIFE_COST = 150
```
How many coins Jumpman drops when time runs out.

```
TIMER_START = 5000
```
Number to start the countdown timer from.


### Emulator Settings

Default settings can be changed in the settings.txt file.

```
EMU_1 = <ROOT>\dkwolf\dkwolf196 <OPTIONS> -rompath <ROM_DIR>
EMU_2 = <ROOT>\dkwolf\dkwolf196 -record <NAME>_<DATETIME>.inp <OPTIONS> -rompath <ROM_DIR>
EMU_3 = (optional)
EMU_4 = (optional)
EMU_5 = (optional)
EMU_6 = (optional)
EMU_7 = (optional)
EMU_8 = (optional)
```
EMU_1 to EMU_8 are used to define the emulators.  EMU_1 and EMU_2 come preconfigured.  By default EMU_1 is used for DKAFE gameplay and EMU_2 is used for DKAFE .inp recording.  It is recommended not to change EMU_1 and EMU_2.

```
ROM_DIR = <ROOT>\roms
```
The rom directory is set to the dkafe roms folder by default.

```
OPTIONS = -video gdi
```
Additional arguments to pass to DKMAME.  DKAFE will automatically pass other things in like -rompath and -record when necessary so this need not be changed.

```
AUTOSTRETCH = 1
```
1 to automatically fit DKMAME to the resolution of monitor.  It will detect if monitor is 3:4 or 7:8 or similar aspect.

```
CREDITS=1
```
1 to automatically insert a coin after launching a game.

```
AUTOSTART=1
```
1 to automatically start the game - if coins are inserted.

```
SHOW_AWARD_PROGRESS = 1
```
1 to show award progress when playing game (replaces highscore at top of screen)

```
SHOW_AWARD_TARGETS = 1
```
1 to show award targets for 1st, 2nd and 3rd prize when playing game (appears during the DK intro/climb scene)


### Control Settings


![DKAFE controls](https://github.com/10yard/dkafe/blob/master/artwork/snaps/controls.png)


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

Joystick controls can be configured by setting the USE_JOYSTICK option.
The up, down, left, right controls are defined automatically from the joystick axis movement.
Buttons can be customised in the settings.txt file as per the following example.  
Button numbers 0-19 relate to the first joystick and 20-39 relate to the second joystick.

```
USE_JOYSTICK = 1
BUTTON_JUMP = 0
BUTTON_ACTION = 1
BUTTON_P1 = 9
BUTTON_P2 = 29
BUTTON_EXIT = 6
BUTTON_COIN = 7
```


## How to use romlist.csv

A default romlist.csv is provided for use with the automatically generated roms (above).

The file can be configured to launch roms from the default rom directory (by leaving subfolder blank) or from a specified subfolder.  
The subfolder is useful when you have multiple roms with the same name e.g. there are lots of hacked versions of dkong.zip.  If the emulator supports -rompath then dkafe will launch the rom directly otherwise the rom will be copied over to the main rompath to workaround CRC checks.  If not providing -rompath then I recommend the original rom to be placed into /original subfolder to prevent it being overwritten.

The special subfolder name "shell" can be used when you want to launch a batch file or shell script.  Create a file named <romname>.bat on Windows or <romname>.sh elsewhere inside the shell subfolder of dkafe.

All roms in the list should be given a slot position (between 1 and 46) of where the icon should appear and a basic descriptive name.

Multiple emulators can be configured in settings.txt and the launch emulator can be set in the emu column. If blank the default 0 will be used.

All roms should be provided with a similarly named image as a .png file in the /artwork/icons folder or subfolder.  Recommended icon size is 12px wide x 22px High.  You can use the default_machine.png as a template.

Hopefully that all makes sense.  Refer to the example romlist.csv


## Emulator recommendation

### For Windows

For the default frontend you should stick with the bundled DKWolf emulator which is compiled from WolfMAME v0.196 and comes ready to go.
Otherwise my recommendations are:

1. Mame64 v0.196 minimum from https://www.mamedev.org/ . Rom hacks and lua interface hacks were tested against versions from v0.196 to v0.226

2. Wolfmame (for competition/recording) from https://github.com/mahlemiut/wolfmame/releases/

3. HB Mame (Dedicated to hacks and homebrew) from https://www.progettosnaps.net/hbmame/

### For Raspberry Pi

I get along best with advance mame:
  - https://github.com/amadvance/advancemame/releases/download/v3.9/advancemame_3.9-1_armhf.deb

on top of dietpi lightweight OS:
  - https://dietpi.com/
  

## Building/Compiling


### How to build DKAFE?

Requires Python3 (from v3.7) with installed packages from requirements.txt

Pyinstaller can be used to build the application binary on Windows.
  - pyinstaller launch.py --onefile --clean --console --icon artwork\dkafe.ico

See build.bat for an example build script making use of venv (virtual environment for Python)


### How to compile DKMame?

Refer to compile_notes.txt in the dkmame folder.


## Motivations?

The application was developed for my own DIY Donkey Kong arcade cabinet as a replacement for a 60-in-1 board and as an exercise in learning game development and Donkey Kong hacking.  

I wanted to bring together all of the amazing Donkey Kong roms and hacks into one place with an incentive to play them along with tools to aid my own progression (trainers) and .inp recording capability for score submissions.


## Thanks to

The Donkey Kong rom hacking resource
https://github.com/furrykef/dkdasm 

Paul Goes for an excellent set of Donkey Kong hacking reference material
https://donkeykonghacks.net/

The Donkey Kong Forum
https://donkeykongforum.com/

The pygame community
https://www.pygame.org/

Fantastic Donkey Kong hacks from Sockmaster (John Kowalski), Paul Goes, Jeff Kulczycki, Mike Mika/Clay Cowgill and Don Hodges.

The MAMEdev team
https://docs.mamedev.org/

WolfMAME by Mahlemiut
https://github.com/mahlemiut/wolfmame


## Feedback

Please send feedback to jon123wilson@hotmail.com

Jon