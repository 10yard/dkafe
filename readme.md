# **DKAFE** #

## Donkey Kong Arcade Frontend

An arcade game launcher based on Donkey Kong with incentives to play and unlock arcade games.  It comes bundled with features and ready to go.  You just need to provide your own dkong.zip.  


![DKAFE frontend](https://github.com/10yard/dkafe/blob/master/artwork/about/frontend.png)

A very short video review by GenXGrownUp - https://www.youtube.com/shorts/_RtjCKfJuoo

An article on the Set Side B gaming blog - https://setsideb.com/romhack-thursday-dkafe/


## Get DKAFE for your system

The latest releases are available to download from below.  Refer to the [How to Install](#how-to-install) and [Troubleshooting](#troubleshooting) sections.

| Download Link                                                                                                        | Version | Operating System                           |
| -------------------------------------------------------------------------------------------------------------------- | ------- | -------------------------------------------|
| [dkafe_win64_binary_v0.75.zip](https://github.com/10yard/dkafe/releases/download/v0.75/dkafe_win64_binary_v0.75.zip) | 0.75    | Windows 64 bit (x64) systems (Recommended) |
| [dkafe_win32_binary_v0.75.zip](https://github.com/10yard/dkafe/releases/download/v0.75/dkafe_win32_binary_v0.75.zip) | 0.75    | Windows 32 bit (x86) systems               |
| [dkafe_rpi4_image_v0.75.gz](https://github.com/10yard/dkafe/releases/download/v0.75/dkafe_rpi4_image_v0.75.gz)       | 0.75    | Raspberry Pi 4 and 400 only                |
| [dkafe_winxp_binary_v0.67.zip](https://github.com/10yard/dkafe/releases/download/v0.67/dkafe_winxp_binary_v0.67.zip) | 0.67    | Windows XP (No longer maintained)          |

* Windows binaries are digitally signed to ensure the origin of the files and their integrity.
* DKAFE sources can also run on other systems, for example, see the section on installing to [Ubuntu Linux](#ubuntu-linux)

## About DKAFE

The DKAFE frontend system mimics Donkey Kong gameplay.  You control Jumpman on several familiar stages and have him select which arcade game to launch.  Simply walk up to a machine,  push "Up" to face towards it, then push "Jump" to play.  

The default setup showcases all the excellent Donkey Kong hacks that have been developed by the community along with some new hacks that were made specifically by me for this frontend. 

The built-in reward system will payout coins when you play well.  Earning coins will allow you to unlock and play more machines.

Coins are awarded after beating target scores (for 3rd, 2nd and 1st prize).  Coins will drop from the top of the screen (after returning to the frontend) and Jumpman must do his best to collect them before they disappear off the bottom.


![DKAFE awards](https://github.com/10yard/dkafe/blob/master/artwork/about/awards.png) 


Pauline helps out by providing game information, score targets and unlock requirements as you walk towards an arcade machine.  

You begin with 500 coins, and you must collect coins which are thrown by Donkey Kong.  You'll be charged 100 coins to launch a game.  Be aware of the countdown timer too,  if the timer runs out you'll lose 150 coins!

If you're not up for the challenge then it is possible to adjust things and have all machines unlocked and set to free play.  Pauline will love it when you beat all the machines though.

The frontend can be configured to launch other emulators and roms.

Jumpman can traverse platforms using unbroken ladders and by utilising hammers (to teleport short distances).  Jumpman can drop through an oilcan to quickly warp between the stages.

![NEW Feature](https://github.com/10yard/dkafe/blob/master/artwork/about/new.png) 
The console add-on pack adds up to 5 extra stages and is packed out with hundreds of Donkey Kong ports, clones and hacks for a myriad of console and computer systems.  See [Console Add-on Pack](#console-add-on-pack) section below.

![Donkey Kong versions supported](https://github.com/10yard/dkafe/blob/master/artwork/about/versions_detected.png)


### The frontend includes:
 - An interactive launcher that comes preconfigured to work with classic Donkey Kong roms and hacks.
 - A rom patcher that automatically generates hacked roms from the many included patch files.
 - Several Donkey Kong hacks and plugins made by me specifically for use with this frontend.
 - A custom lightweight version of WolfMAME built specifically for Donkey Kong, and it's clones and bootlegs.
 - MAME plugins and scripts that interface with the frontend to add cool features such as score targets, stage practice and a coaching mode.
 - A built in music playlist that features 16 fantastic Donkey Kong remix tracks by default.
 - Extensive configuration options.
 - An optional console add-on pack featuring over 300 ports, clones and hacks for 60 classic gaming systems, and a bonus arcade stage.

### The frontend does not include:
 - Roms or information on how to obtain them.


![DKAFE trophy award](https://github.com/10yard/dkafe/blob/master/artwork/about/trophy2.png)


## Automatically generated roms

DKAFE comes with a default frontend built from various patches of the original **dkong.zip** (US Set 1) arcade rom.  The original rom is required for the patching to work.
All patch files are included in the **/patch folder**.


![DKAFE game info](https://github.com/10yard/dkafe/blob/master/artwork/about/patches.png)


Credit is given to the original authors below.


### By Jon Wilson (me)
 - VectorKong and Dizzy Kong
 - GalaKong, Extreme GalaKong and GalaKong Junior
 - DK Bros.
 - Allen Kong
 - DK Lava Panic!
 - DK Who and the Daleks
 - Donkey Kong Insanity
 - OctoMonkey
 - Half Kong
 - Quarter Kong
 - 2NUT Kong
 - NoLuck Kong
 - Konkey Dong
 - Donkey Kong Barrels, Pies, Springs, Rivets
 - Donkey Kong Killscreen
 - Donkey Kong Coach
 - Donkey Kong Chorus
 - Donkey Kong Continue
 - Donkey Kong Ends
 
### By Paul Goes - https://donkeykonghacks.net/
 - Donkey Kong Crazy Barrels Edition
 - Donkey Kong Championship Edition
 - Donkey Kong Randomized Edition
 - Donkey Kong Freerun Edition
 - Donkey Kong Into The Dark
 - Donkey Kong Skip Start
 - Donkey Kong Reverse
 - Donkey Kong On The Run
 - Donkey Kong Twisted Jungle
 - Donkey Kong Barrelpalooza
 - Donkey Kong 40th Anniversary Edition
 - Donkey Kong Duel
 - Donkey Kong Wizardry
 - Donkey Kong RNDMZR
 - Donkey Kong Springfinity
 - Donkey Kong Barrel Boss
 - Donkey Kong Heart Hunt
 - Donkey Kong Accelerate
 - Donkey Kong Pac-Man Crossover
 - Crazy Kong Pt2 DK Graphics

### By John Kowalski (Sock Master) - http://users.axess.com/twilight/sock/
 - Donkey Kong Spooky Remix
 - Donkey Kong Christmas Remix
 - Donkey Kong Remix Demo
 - Donkey Kong Springs Trainer
 - Donkey Kong Trainer
 - Donkey Kong Pace
 - Donkey Kong Rainbow
 - Doonkey Kong Junior Bugfix
 - Crazy Kong Part II 2023 Revision

### By Jeff Kulczycki - http://www.jeffsromhack.com/products/d2k.htm
 - Donkey Kong 2 Jumpman Returns
 - Donkey Kong Foundry
 - Donkey Kong Barrel Control Colouring

### By Mike Mika and Clay Cowgill - http://www.multigame.com/dkp_arcade.html
 - Donkey Kong Pauline Edition

### By Don Hodges - http://www.donhodges.com/how_high_can_you_get.htm
 - Donkey Kong Killscreen Fix
 
### By Kirai Shouen and 125scratch - https://www.romhacking.net/hacks/6689/
 - Kana Kong 

### By Tim Appleton - https://www.oocities.org/wigglebeat
 - Donkey Kong Pac-Man

### By Vic Twenty George
 - Donkey Kong Atari 2600 Graphics
 
### By ChrisP - https://donkeykongforum.net/index.php?topic=1215
 - Crazy Kong 117

### By Falcon
 - Crazy Kong
 - Crazy Kong Part II
 - Crazy Kong Part II (Alternative Levels)

### By others
 - Donkey Kong Wild Barrel Hack
 - Donkey Kong Hard
 - Donkey Kong 2 Marios
 - Donkey Kong Naked
 - Donkey Kong Japan

### Bootlegs
 - Big Kong
 - Donkey Kong on Galaxian Hardware
 - Crazy Kong on Scramble Hardware
 - Crazy Kong on Moon Cresta Hardware
 - Crazy Kong on Galaxian Hardware
 - Crazy Kong Spanish Bootleg
 - Big Kong on Galaxian Hardware



![DKAFE hacks](https://github.com/10yard/dkafe/blob/master/artwork/about/gameinfo.png)


![DKAFE hacks](https://github.com/10yard/dkafe/blob/master/artwork/about/dkwho_gameplay.png)



## DKWolf Emulator

DKAFE comes with my custom lightweight build of WolfMAME named DKWolf,  it supports only Donkey Kong drivers (including DK Junior, DK3, Crazy Kong and Big Kong).

It is possible to set up other emulators and roms if you do not wish to use the default Donkey Kong focussed frontend.


## Feature Plugins

These plugins add extra features to some roms.

### DK Coach

The coaching plugin can help you master the spring and barrel stages.


[![DK Coach](https://github.com/10yard/dkafe/blob/master/artwork/about/coach.png)](https://www.youtube.com/watch?v=8cUUOP9Pjis&t)

[Click here to watch a video review of DKCoach by GenXGrownup.](https://www.youtube.com/watch?v=8cUUOP9Pjis&t)


### DK Chorus

The chorus plugin replaces the default samples and music with acapella sounds.

[
![DK Chorus](https://github.com/10yard/dkafe/blob/master/artwork/about/launchmenu.png)](https://www.youtube.com/watch?v=nYCNioYWcO4)

[Click here to watch a gameplay video of DK Chorus.](https://www.youtube.com/watch?v=nYCNioYWcO4)


### DK Practice

The practice plugin allows you to practice playing a particular stage to refine your skills.    
Typically you will be able to select from Barrels, Pies, Springs and Rivets.  There is also an option to start the game from level 5.
 
 
![DK Practice](https://github.com/10yard/dkafe/blob/master/artwork/about/practice.png)


### DK Continue

The continue plugin gives you the opportunity to continue playing when your game would normally be over.

A continue option will appear with a 10 second countdown timer. Simply push the P1 Start button to continue your game and your score will be reset to zero.
A tally of the total number of continues made will appear at the top of the screen.


![DK Continue](https://github.com/10yard/dkafe/blob/master/artwork/about/continue.png)


## Console Add-on Pack

An optional add-on pack includes over 300 Donkey Kong ports and hacks for the following classic home consoles and computers.

 - Acorn Atom
 - Atari 2600
 - Amstrad CPC
 - Amstrad PCW
 - Apple ][
 - APF Imagination Machine
 - Arduino Arduboy
 - Atari 5200
 - Atari 7800
 - Atari 800XL
 - Atari ST
 - BBC Micro
 - Coleco Adam
 - Colecovision
 - Commodore 16/Plus4
 - Commodore 64
 - Commodore Amiga
 - Commodore Pet
 - Commodore VIC-20
 - Dragon 32
 - EACA Colour Genie EG2000
 - Epoch Cassette Vision
 - Exelvision EXL100
 - Famicom Disk System
 - Game and Watch
 - Intellivision
 - Jupiter Ace
 - LCD and Handheld
 - LowRes NX Fantasy Console
 - Microsoft Windows PC
 - MS-DOS
 - MSX
 - NEC PC-88
 - Nintendo DS
 - Nintendo Entertainment System
 - Nintendo Gameboy
 - Nintendo Gameboy Color
 - Pico-8 Fantasy Console
 - Pokitto DIY Handheld
 - Sega Genesis/Megadrive
 - Sega Master System
 - Sega SG-1000
 - Sharp MZ700
 - Sharp X1
 - Sinclair Spectrum 48K
 - Sinclair Spectrum 128K
 - Sinclair ZX80
 - Sinclair ZX81
 - Super Nintendo
 - Tandy Color Computer 3 (CoCo3) 
 - Tandy MC10
 - Tandy TRS-80
 - Tangerine Oric
 - Texas Instruments TI99/4
 - Thomson MO5
 - TIC-80 Fantasy Console
 - Uzebox - Atmega Game Console
 - VTech Creativision
 - Vtech Laser VZ
 - Watara Supervision
 

The Donkey Kong console games will appear on 4 extra stages (*Crazy Kong and Big Kong stages are exclusive to Windows x64 platform).  There is also a bonus arcade stage.
In unlock mode,  you must play for a given amount of time to win coins instead of reaching a target score  e.g. Play 2 minutes for 3rd prize,  4 minutes for 2nd prize and 8 minutes for first prize.

The default controls for these games have been configured to work with arcade controls.  Typically press "P1 Start" or "Jump" to start.

![DKAFE addon](https://github.com/10yard/dkafe/blob/master/artwork/about/console_addon.png)

![DKAFE game menu](https://github.com/10yard/dkafe/blob/master/artwork/about/gamemenu.png)



## How to install

Steps to install the default frontend are as follows.  Also refer to [How to set up](#how-to-set-up).


### Windows

1. Download the latest DKAFE binary release for your version of Windows and extract contents to a folder.
2. Run "launch.exe".


### Raspberry Pi 4/400

1. Download the latest SD card image 
2. Burn image to an SD card (minimum 4GB size) using Raspberry Pi Imager.
2. Copy dkong.zip to the /boot partition of the SD card.
3. Boot your Raspberry Pi with the SD card inserted.
4. The DKAFE install script will ask some questions. 
```	 
	 Rotate the display?
	 Launch DKAFE on boot?                    (Recommend Y)
	 Hide startup messages?                   (Recommend Y)
	 Hide the Pi taskbar?                     (Recommend Y)
	 Hide the Pi desktop?                     (Recommend Y)
	 Hide the Pi mouse cursor?                (Recommend Y)
	 Use headphone jack for audio?
	 Optimise framebuffer    (Recommend Y for HDMI and VGA)
	 Force 640x480 mode on boot?
	 Map GPIO to keyboard input controls?     (Recommend Y)
	 Disable non-essential Services?          (Recommend Y)
	 Disable networking services (WiFi, SSH)?
	 Reboot now?	 
```


### Ubuntu Linux

A full list of steps to get DKAFE running on Ubuntu 24.04 was provided by Christopher Kremer.
These steps includes compiling wolfmame v0.241 which is required for the best compatibility.

```
git clone https://github.com/10yard/dkafe.git --depth=1
mkdir ./dkafe/pipenv
python3 -m venv ./dkafe/pipenv
source ./dkafe/pipenv/bin/activate
pip install pygame pygame-menu==3.5.8 ips-util stopwatch.py
wget https://github.com/mahlemiut/wolfmame/archive/refs/tags/wolf241.tar.gz
tar -xvzf wolf241.tar.gz
cd ./wolfmame-wolf241
nano ./src/lib/netlist/plib/pstring.h and add #include <cstdint> to includes list
nano ./src/lib/netlist/plib/ptypes.h and add #include <cstdint> to includes list
make SUBTARGET=arcade CFLAGS="-Wno-dangling-pointer -Wno-use-after-free -Wno-uninitialized -Wno-address -Wno-deprecated-declarations"
cp mamearcade ../dkafe/dkwolf/dkwolf
nano ./dkafe/settings.txt and append -pluginspath ./plugins to OPTIONS
rm ./dkafe/romlist_addon.csv
python3 launch.py
```

## How to set up?

The default set up simply requires that you place **dkong.zip** into DKAFE's **/roms** folder.  Optionally, you may place **dkongjr.zip** and **dkong3.zip** into the dkafe/roms folder.  
The frontend will automatically generate a bunch of Donkey Kong roms using patch files which are included with the software.

The application requires settings.txt and romlist.csv to be present in the installation folder.  Defaults are provided.
 
The settings.txt contains the emulator, rom path, controls and other configuration.  See [Frontend Settings](#frontend-settings) section below.

The romlist.csv contains information about the roms, which game slot they should appear in and how they can be unlocked and launched in the frontend.  See [How to use romlist.csv](#how-to-use-romlist-csv) below.
There are 367 configurable game slots in total. 


![DKAFE slots](https://github.com/10yard/dkafe/blob/master/artwork/about/slots.png)


### Add-on Pack Installation

The optional console add-on pack can be downloaded automatically from within the DKAFE settings menu.

![DKAFE get addon](https://github.com/10yard/dkafe/blob/master/artwork/about/get_addon.png)

The system will detect the downloaded ZIP and automatically unpack and install the add-on pack for you.

Console add-on games have been optimised to launch instantly on Windows 64 bit machines.  For other platforms,  the first load will be slower while DKAFE performs an initial optimisation.  Subsequent loads will be instant.


![Console Wheel](https://github.com/10yard/dkafe/blob/master/artwork/about/console_wheel.jpg)


### Display Resolution

The frontend is rendered at 224x256 pixels (as per the original Donkey Kong arcade machine) and then scaled to fit the monitors actual resolution.

The OPTION `-view "Screen 0 Pixel Aspect (7:8)"` is used by default to override MAME's default 4:3 aspect.  

If rotating your monitor then you may want to add the OPTION `-nokeepaspect` to fill the screen.

For Raspberry Pi,  refer to [Raspberry Pi Notes](rpi4/rpi4_notes.md) for information on connecting to a CRT TV via RGB Scart or Composite AV.

![CRT goodness](https://github.com/10yard/dkafe/blob/master/artwork/about/crt_rgb.jpg)


### Frontend Settings

Default settings can be changed in the `settings.txt` file.  Some settings can be changed in the frontend settings menu (available at the bottom of the game list or by pressing TAB key).


![Frontend Settings](https://github.com/10yard/dkafe/blob/master/artwork/about/settings.png)


`FULLSCREEN = 1`  
1 for fullscreen mode or 0 for windowed mode.

`ROTATION = 0`  
Rotates the screen for the duration of your DKAFE session.  Set to 0, 90, 180 or 270.  For Windows systems only.  Pi4 rotation is handled via install script.

`FREE_PLAY = 0`    
1 for free play.  If 0 then Jumpman must collect sufficient coins to play a game.

`UNLOCK_MODE = 1`    
1 for unlock mode were Jumpman must score points to unlock games.  If 0 then all games are unlocked by default.

`CONFIRM_EXIT = 1`    
1 to display confirmation screen when attempting to exit.  0 to exit without question.

`BASIC_MODE = 0`
1 for basic mode to switch the frontend gameplay features off.  This is equivalent to FREE_PLAY = 1, UNLOCK_MODE = 0 and all interface settings set to 0.

`SHOW_SPLASHSCREEN = 1`
1 to show the DKAFE splash screen and animation on startup.  0 to skip the splash screen.

`SHOW_GAMETEXT = 1`
1 to show the game text descriptions when Jumpman faces an arcade machine.  0 to hide the game descriptions.

`SPEED_ADJUST = 0`
Increase the frontend speed.  0 is normal.  If frontend is running slow then try incrementing by 1 until desired speed is achieved.

`SKILL_LEVEL = 1`
How difficult are the target scores.  1 (Beginner) to 10 (Expert).

`START_STAGE = 0`
The stage to start the frontend on.  0 is barrels stage, 1 is rivets stage, 2 is pie factory stage, 3 is springs stage, 4 is crazy kong stage, 5 is big kong stage.

`HIGH_SCORE_SAVE = 1`
Save your high score tables for each game.

`ENABLE_PLAYLIST = 1`
1 to play music files from the **playlist** folder instead of the regular Donkey kong background music.

'PLAYLIST_VOLUME = 5'
Playlist music volume from 0 (minimum) to 10 (maximum).

`ENABLE_MENU=1`    
1 to enable the game list when P2 Start button is pressed to quickly launch an available game via the menu.

`ENABLE_ADDONS=1`    
1 to enable add-on packs.  0 to disable previously installed add-ons.

`ENABLE_SHUTDOWN=0`    
1 to enable system shutdown via the "confirm exit" menu.

`ENABLE_HAMMERS=1`    
1 to enable teleport between hammers in the fronted.  Makes it quicker to move up and down platforms.

`INACTIVE_TIME = 20`    
Period of inactivity in seconds before showing attract mode/game instructions.

`PLAY_COST = 100`    
How much it costs to play an arcade machine.

`LIFE_COST = 150`    
How many coins Jumpman drops when time runs out.

`SCORE_START = 500`
How many coins Jumpman starts out with.

`TIMER_START = 8000`    
Number to start the countdown timer from.

`INP_FAVOURITE = 10`    
Number of minutes gameplay required for a recording to be flagged as favourite.


### Emulator Settings

Default settings can be changed in the settings.txt file.

```
EMU_1 = <ROOT>/dkwolf/dkwolf <OPTIONS>
EMU_2 = <ROOT>/dkwolf/dkwolf <OPTIONS> -record <RECORD_ID> 
EMU_3 = (optional)
EMU_4 = (optional)
EMU_5 = (optional)
EMU_6 = (optional)
EMU_7 = (optional)
EMU_8 = (optional)
```
`EMU_1` and `EMU_2` come preconfigured. `EMU_1` is used for DKAFE gameplay and `EMU_2` is used for "inp" recordings.
`EMU_3` to `EMU_8` can be used to add more of your own emulators.

`ROM_DIR = <ROOT>/roms`    
The rom directory is set to the DKAFE roms folder by default.

`OPTIONS = -rompath <ROM_DIR> -view "Screen 0 Pixel Aspect (7:8)" -video opengl`    
General arguments can be stored into `<OPTIONS>` rather than repeating for each emulator.

The special tags `<ROOT>`, `<ROM_DIR>`, `<OPTIONS>` and `<RECORD_ID>` used above are replaced with their actual values at runtime.

`ALLOW_ROM_OVERWRITE = 0`
Allow roms in ROM_DIR to be overwritten.  Set to 1 when using an emulator that doesn't support a rompath argument e.g. AdvanceMAME.

`EMU_ENTER`
Optional system command to issue before launching emulator

`EMU_EXIT`
Optional system command to issue after exiting emulator

`REFOCUS_WINDOW = 0`
Attempt to refocus DKAFE window when exiting from LUA interface (Windows Only)


### DK Interface Settings

These settings relate to Donkey Kong hacks.

`CREDITS = 1`    
1 to automatically insert a coin after launching a game.

`AUTOSTART = 1`    
1 to automatically start the game - if coins are inserted.

`ALLOW_SKIP_INTRO = 1`
Allow the DK climb scene to be quickly skipped in game by pressing Jump button

`SHOW_AWARD_PROGRESS = 1`    
1 to show award progress when playing game (replaces highscore at top of screen)

`SHOW_AWARD_TARGETS = 1`    
1 to show award targets for 1st, 2nd and 3rd prize when playing game (appears during the DK intro/climb scene)

`SHOW_HUD = 1`    
1, 2 or 3 to enable the HUD to be displayed in the top right corner.  Press `P2 Start` to toggle the data.
1=Targets, 2=Awards, 3=No data, 0 to disable the HUD.

`ANNOUNCE_AWARD_INGAME = 1`    
1 to enable prize award announcements during gameplay.



### Control Settings


![DKAFE controls](https://github.com/10yard/dkafe/blob/master/artwork/about/controls.png)


#### Keyboard Controls

Keyboard controls can be customised in the `settings.txt` file using the "common name" to identify the key.  [Refer to this table.](https://elearn.ellak.gr/mod/page/view.php?id=2786)
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
CONTROL_SETTINGS = tab
CONTROL_SNAP = F12
CONTROL_SKIP = s
CONTROL_PLAYLIST = p
```

IMPORTANT NOTE: The controls configured in the frontend do not apply to the emulator.  If your controls are not default then you will also have to configure your controls in the emulator menu (tab). 


#### Joystick Controls

Joystick controls are enabled by default.  Set `USE_JOYSTICK = 0` to disable joystick controls.
The up, down, left, right controls are automatically mapped from the DPAD and first detected joystick axis.
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

#### GPIO Inputs

GPIO input is supported on Raspberry Pi4 and it is my recommended option for interfacing with arcade controls.  The DKAFE install script can set this up automatically.

GPIO inputs can be mapped to keyboard inputs in the `/boot/config.txt` file. The chosen defaults avoid using GPIO pins that may be used with other Raspberry Pi peripherals:

```
# GPIO to keyboard inputs
dtoverlay=gpio-key,gpio=17,keycode=105,label="KEY_LEFT"
dtoverlay=gpio-key,gpio=27,keycode=106,label="KEY_RIGHT"
dtoverlay=gpio-key,gpio=22,keycode=103,label="KEY_UP"
dtoverlay=gpio-key,gpio=23,keycode=108,label="KEY_DOWN"
dtoverlay=gpio-key,gpio=24,keycode=29,label="KEY_LEFTCTRL"
dtoverlay=gpio-key,gpio=25,keycode=56,label="KEY_LEFTALT"
dtoverlay=gpio-key,gpio=5,keycode=2,label="KEY_1"
dtoverlay=gpio-key,gpio=6,keycode=3,label="KEY_2"
dtoverlay=gpio-key,gpio=16,keycode=6,label="KEY_5"
dtoverlay=gpio-key,gpio=26,keycode=1,label="KEY_ESC"
```


### Music Playlist

You can override the default Donkey Kong background music by setting `ENABLE_PLAYLIST = 1` in the settings.txt file.
14 Donkey Kong music remixes are included by default for your enjoyment - see thank you section below for a list of the included tracks and their creators.  These files can be removed and replaced with your own favourite music tracks in **.mp3**, **.ogg** or **.wav** format. 

The "Music Playlist" can also be activated via the frontend settings menu (by pressing the TAB key) or it can be toggle on/off by pressing the CONTROL_PLAYLIST key (p).
When music is playing you can skip to the next track by pressing the CONTROL_SKIP key (s).


### How to use romlist CSV

A default `romlist.csv` is provided for use with the automatically generated roms (see above).

The file can be configured to launch roms from the default rom directory (by leaving subfolder blank) or from a specified subfolder.
The subfolder is useful when you have multiple roms with the same name e.g. there are lots of hacked versions of dkong.zip.  If the emulator supports a rompath argument then DKAFE will launch the rom directly from its subfolder.
If the emulator does not support a rompath (e.g. Advmame) then the rom will be copied over to the main rompath. See `ALLOW_ROM_OVERWRITE` option.  With this approach I recommend the original rom be placed into its own subfolder (e.g. `/roms/original`) to prevent it from being overwritten.

All roms in the list should be given an emulator number (e.g. 1 for DKWolf, as defined in `settings.txt`), a slot position (between 1 and 367) and a basic descriptive name.  Set the slot position to 0 or 999 if you want the rom to only appear in the menu. 

As well as an emulator number,  the roms can be given a recording emulator number (e.g. 2 for DK Wolf recordings).  This provides emulator details for when the rom is launched in recording mode.  Set to zero to disable recording.

If there are multiple entries for the same slot number then the first valid entry will be used.  This allows the optional roms *dkongjr* and *dkong3* to become active when they are provided.

The special subfolder name `shell` can be used when you want to launch a batch file or shell script.  Create a .bat or .sh file inside the `/shell` subfolder.  The emulator number can be left blank.

An accompanying icon in .png format should be placed into the `artwork/icons` folder or subfolder with the same name as the rom.  Recommended icon size is 12px wide x 22px High.



## Emulator recommendation

For the default frontend you should stick with the bundled DKWolf emulator which comes ready to go. 

Otherwise, my recommendations are:

### For Windows

1. Mame v0.196 to v0.241 from https://www.mamedev.org/ . Rom hacks and lua interface hacks are tested against these versions.
2. Wolfmame (for competition/recording) from https://github.com/mahlemiut/wolfmame/releases/
3. HB Mame (Dedicated to hacks and homebrew) from https://www.progettosnaps.net/hbmame/


### For Raspberry Pi (Model 4)

1. Mame v0.196 to v0.241 from https://www.mamedev.org/ . LUA interface and plugins are tested against these versions.  Mamedev binaries are not generally available for Raspberry Pi so you will have to compile your own.  See readme.txt in **\dkwolf** folder
2. Advance Mame from https://www.advancemame.it/download
  

### How to build DKAFE binary?

Requires Python3 (v3.7 upwards) with installed packages from `requirements.txt`

Pyinstaller can be used to build the application binary.
```
pyinstaller launch.py --onefile --clean --console --icon artwork/dkafe.ico
```

See build64.bat (and build32.bat) for Windows build script making use of a Python virtual environment (venv).

See build.sh and [Raspberry Pi Notes](rpi4/rpi4_notes.md) for building a Raspberry Pi binary.


### How to compile DKWolf?

Refer to [dkwolf/readme.txt](dkwolf/readme.txt).



![DKAFE arcade](https://github.com/10yard/dkafe/blob/master/artwork/about/arcade.jpg)


## Motivations?

The frontend was developed for my own DIY Donkey Kong arcade cabinet as a replacement for a 60-in-1 board and as an exercise in learning game development and Donkey Kong rom hacking.

I wanted to bring together all the amazing Donkey Kong roms and hacks into one place with an incentive to play them along with tools to aid my own progression (trainers) and .inp recording capability for score submissions.

I would love to get to the infamous killscreen on level 22.  My current PB is 513,900 points at level 15.


 
## Thanks to

The Donkey Kong rom hacking resource
https://github.com/furrykef/dkdasm 

Paul Goes excellent set of Donkey Kong hacking reference material
https://donkeykonghacks.net/

Fantastic Donkey Kong hacks from Sockmaster (John Kowalski), Paul Goes, Jeff Kulczycki, Mike Mika/Clay Cowgill, Don Hodges, ChrisP, Tim Appleton, Vic20 George, Kirai Shouen/125scratch

Feedback and feature ideas from Superjustinbros (Justin De Lucia)
https://superjustintheblog.blogspot.com/

The pygame community
https://www.pygame.org/

The MAMEdev team
https://docs.mamedev.org/

WolfMAME by Mahlemiut
https://github.com/mahlemiut/wolfmame

The VRC6 Project by LeviR.star's Music.  4 tracks are included in the default playlist folder
https://www.youtube.com/watch?v=Ufd9UC2wUpA

Donkey Kong Arcade Theme Remixes by Nintega Dario. 2 tracks are included in the default playlist folder
https://www.youtube.com/watch?v=VPT42lfFNMY

DonkeyKong Classic Remix Music by MyNameIsBanks
https://www.youtube.com/watch?v=MDw2goJSi4k

Donkey Kong Remix Music by SanHolo
https://www.youtube.com/watch?v=_kdgB5SRqHw

Donkey Kong Arcade by MotionRide Music
https://www.youtube.com/watch?v=gy0C2a5QEu8

Do the Donkey Kong (Instrumental) by Buckner & Garcia
https://www.youtube.com/watch?v=oK0yLlZ4zsk

Donkey Kong Arcade C64 Remix by Sascha Zeidler
https://www.c64.com/games/2464

Hammer Time Remix by Mitchel Gatzke
https://www.youtube.com/watch?v=crhTHJGgFag

Donkey Kong NES Medley by Chiptunema
https://www.youtube.com/watch?v=TnNTVwKzs0o

Donkey Kong Country Synthwave Remix by RetroKid
https://www.youtube.com/watch?v=_CnkT5VcVhI

![Thanks](https://github.com/10yard/dkafe/blob/master/artwork/about/thanks.png)


## License

DKAFE is a free, open source, cross-platform front-end for emulators.
It is licensed under GNU GPLv3. 


## Troubleshooting

#### I have a multiple monitor setup.  How do I make MAME appear on a specific monitor?
 - In the settings.txt file,  add the following to `OPTIONS` with `\\.\DISPLAY1` or `\\.\DISPLAY2` being your chosen monitor.

```
-numscreens 1 -screen0 \\.\DISPLAY1
```

your revised options should now look something like the following.

```
OPTIONS = -rompath "<ROM_DIR>" -view "Screen 0 Pixel Aspect (7:8)" -nofilter -video opengl -numscreens 1 -screen0 \\.\DISPLAY1
```


#### The system is running slow on an older machine

 - Reduce your screen resolution.  This will definitely improve performance in the frontend and emulation.

 - In the settings.txt file,  change emulator `OPTIONS` to use `-video gdi` instead of `-video opengl`

 - Disable the music playlist in the frontend settings.  The .mp3 decoding might be slowing the frontend down.

 - Increase the speed adjust value in the frontend settings.


#### A game fails to launch in MAME, and you get a black screen (on Windows)

 - In the settings.txt file,  change emulator `OPTIONS` to use `-video gdi` instead of `-video opengl`

 - Ensure the DKAFE folder is granted full access permissions.


## Feedback

Please send feedback to jon123wilson@hotmail.com


Jon

![DKAFE trophy](https://github.com/10yard/dkafe/blob/master/artwork/about/trophy.png)
