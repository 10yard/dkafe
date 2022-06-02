# **DKAFE** #

## Donkey Kong Arcade Frontend

An arcade game launcher based on Donkey Kong with incentives to play and unlock arcade games.  It comes bundled with features and ready to go.  You just need to provide your own dkong.zip.  


![DKAFE frontend](https://github.com/10yard/dkafe/blob/master/artwork/about/frontend.png)



## Get DKAFE for your system

The latest releases are available to download from below.  Refer to the **How to Install** section.

| Download Link                                                                                                        | Version | Operating System                          |
| -------------------------------------------------------------------------------------------------------------------- | ------- | ------------------------------------------|
| [dkafe_win64_binary_v0.32.zip](https://github.com/10yard/dkafe/releases/download/v0.32/dkafe_win64_binary_v0.32.zip) | 0.32    | Windows 64 bit (x64) systems: 10, 11      |
| [dkafe_win32_binary_v0.32.zip](https://github.com/10yard/dkafe/releases/download/v0.32/dkafe_win32_binary_v0.32.zip) | 0.32    | Windows 32 bit (x86) systems: Vista, 7, 8 |
| [dkafe_rpi4_image_v0.32.gz](https://github.com/10yard/dkafe/releases/download/v0.32/dkafe_rpi4_image_v0.32.gz)       | 0.32    | Raspberry Pi 4 and 400 only               |
| [dkafe_winxp_binary_v0.31.zip](https://github.com/10yard/dkafe/releases/download/v0.31/dkafe_winxp_binary_v0.31.zip) | 0.31    | Windows XP only                           |


## About DKAFE

The DKAFE frontend system mimics Donkey Kong gameplay.  You control Jumpman on the familiar girders stage and have him select which arcade game to launch.  Simply walk up to a machine,  push "Up" to face towards it, then push "Jump" to play.  

The default setup showcases all the excellent Donkey Kong hacks that have been developed by the community along with some new hacks that were made specifically by me for this frontend. 

The built-in reward system will payout coins when you play well.  Earning coins will allow you to unlock and play more machines.

Coins are awarded after beating target scores (for 3rd, 2nd and 1st prize).  Coins will drop from the top of the screen (after returning to the frontend) and Jumpman must do his best to collect them before they disappear off the bottom.


![DKAFE awards](https://github.com/10yard/dkafe/blob/master/artwork/about/awards.png) 


Pauline helps out providing game information, score targets and unlock requirements as you walk towards an arcade machine.  

You begin with 500 coins, and you must collect coins which are thrown by Donkey Kong.  You'll be charged 100 coins to launch a game.  Be aware of the countdown timer too,  if the timer runs out you'll lose 150 coins!

If you're not up for the challenge then it is possible to adjust things and have all machines unlocked and set to free play.  Pauline will love it when you beat all the machines though.

The frontend can be configured to launch other emulators and roms.


### The frontend includes:
 - An interactive launcher that comes preconfigured to work with classic Donkey Kong roms and hacks.
 - A rom patcher that automatically generates hacked roms from the many included patch files.
 - Several Donkey Kong hacks made by me specifically for use with this frontend.
 - A custom lightweight version of WolfMAME built specifically for Donkey Kong.
 - MAME plugins and scripts interface MAME with the frontend and add cool features such as a coaching mode.

### The frontend does not include:
 - Roms or information on how to obtain them.


## Automatically generated roms

DKAFE comes with a default frontend built from various patches of the original **dkong.zip** (US Set 1) arcade rom.  The original rom is required for the patching to work.
All patch files are included in the **/patch folder**.


![DKAFE game info](https://github.com/10yard/dkafe/blob/master/artwork/about/patches.png)


Credit is given to the original authors below.


### By Jon Wilson (me)
 - Vector Kong
 - GalaKong
 - Galakong Junior
 - Lava Panic!
 - DK Who and the Daleks
 - Donkey Kong Pies Only
 - Donkey Kong Rivets Only
 - Donkey Kong Springs Only
 - Donkey Kong Barrels Only
 - Donkey Kong Coach
 - Donkey Kong Chorus
 - Konkey Dong
 
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

### By John Kowalski (Sock Master) - http://users.axess.com/twilight/sock/
 - Donkey Kong Spooky Remix
 - Donkey Kong Christmas Remix
 - Donkey Kong Springs Trainer
 - Donkey Kong Trainer
 - Donkey Kong Pace
 - Donkey Kong Rainbow

### By Jeff Kulczycki - http://www.jeffsromhack.com/products/d2k.htm
 - Donkey Kong 2 Jumpman Returns
 - Donkey Kong Foundry
 - Donkey Kong Barrel Control Colouring

### By Mike Mika and Clay Cowgill - http://www.multigame.com/dkp_arcade.html
 - Donkey Kong Pauline Edition

### By Don Hodges - http://www.donhodges.com/how_high_can_you_get.htm
 - Donkey Kong Killscreen Fix

### By Tim Appleton - https://www.oocities.org/wigglebeat
 - Donkey Kong Pac-Man

### By Vic Twenty George
 - Donkey Kong Atari 2600 Graphics

### By others
 - Donkey Kong Wild Barrel Hack
 - Donkey Kong 2 Marios
 - Donkey Kong Naked
 - Donkey Kong Hard
 - Donkey Kong Japan


![DKAFE hacks](https://github.com/10yard/dkafe/blob/master/artwork/about/dkwho_gameplay.png)


![DKAFE hacks](https://github.com/10yard/dkafe/blob/master/artwork/about/galakong_gameplay.png)


## Feature Plugins

These plugins add extra features to some roms.

### DKCoach

The coaching plugin can help you master the springs and barrels stages.

[![DKCoach](https://github.com/10yard/dkafe/blob/master/artwork/about/coach.png)](https://www.youtube.com/watch?v=ax-xDwVr7No)

<sup>Click image to watch gameplay video</sup>

### DKChorus

The chorus plugin replaces the default samples and music with acapella sounds.

[![DKChorus](https://github.com/10yard/dkafe/blob/master/artwork/about/launchmenu.png)](https://www.youtube.com/watch?v=nYCNioYWcO4)

<sup>Click image to watch gameplay video</sup>


## DKWolf Emulator

DKAFE comes with my custom lightweight build of WolfMAME named DKWolf,  it supports only Donkey Kong drivers (including DK Junior and DK 3).

It is possible to set up other emulators and roms if you do not wish to use the default Donkey Kong focussed frontend.


## How to install

Steps to install the default frontend are as follows.  Also refer to **How to set up**.


### Windows

1. Download the latest DKAFE binary release for your version of Windows and extract contents to a folder.
2. Run "launch.exe".


### Raspberry Pi 4/400

1. Download the latest SD card image and burn to an SD card (minimum 4GB size).
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
	 Force 640x480 mode on boot?              (Recommend Y)
	 Map GPIO to keyboard input controls?     (Recommend Y)
	 Disable non-essential Services?          (Recommend Y)
	 Disable networking services (WiFi, SSH)? (Recommend Y)
	 Reboot now?                              (Recommend Y)	 
```


## How to set up?

The default set up simply requires that you place **dkong.zip** into DKAFE's **/roms** folder.  You may also place dkongjr.zip into the dkafe/roms folder too but that is not essential.  
The frontend will automatically generate a bunch of Donkey Kong roms using patch files which are included with the software.

The application requires settings.txt and romlist.csv to be present in the installation folder.  Defaults are provided.
 
The settings.txt contains the emulator, rom path, controls and other configuration.  See **Frontend Settings** section below.

The romlist.csv contains information about the roms, which slot they should appear in and how they can be unlocked and launched in the frontend.  See **How to use romlist.csv** below.


### Display Resolution

The frontend is rendered at 224x256 pixels (as per the original Donkey Kong arcade machine) and then scaled to fit the monitors actual resolution.

The OPTION `-view "Screen 0 Pixel Aspect (7:8)"` is used by default to override MAME's default 4:3 aspect.  

If rotating your monitor then you may want to add the OPTION `-nokeepaspect` to fill the screen.


### Frontend Settings

Default settings can be changed in the settings.txt file.  Some settings can be changed in the frontend settings menu (available at the bottom of the game list or by pressing TAB).

`FULLSCREEN = 1`  
1 for fullscreen mode or 0 for windowed mode.

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

`SPEED_ADJUST = 0`
Increase the frontend speed.  0 is normal.  If frontend is running slow then try incrementing by 1 until desired speed is achieved.

`SKILL_LEVEL = 1`
How difficult are the target scores. 1 (Beginner) to 10 (Expert).

`ENABLE_MENU=1`    
1 to enable the game list when P2 Start button is pressed to quickly launch an available game via the menu.

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
General arguments can be stored into <OPTIONS> rather than repeating for each emulator.

The special tags `<ROOT>`, `<ROM_DIR>`, `<OPTIONS>` and `<RECORD_ID>` used above are replaced with their actual values at runtime.

`ALLOW_ROM_OVERWRITE = 0`
Allow roms in ROM_DIR to be overwritten.  Set to 1 when using an emulator that doesn't support a rompath argument e.g. AdvanceMAME.

`EMU_ENTER`
Optional system command to issue before launching emulator

`EMU_EXIT`
Optional system command to issue after exiting emulator


### DK Interface Settings

These settings relate to Donkey Kong hacks.

`CREDITS = 1`    
1 to automatically insert a coin after launching a game.

`AUTOSTART = 1`    
1 to automatically start the game - if coins are inserted.

`ALLOW_SKIP_INTRO = 1`
Allow the DK climb scene to be quickly skipped in game by pressing Jump button

`ALLOW_COIN_TO_END_GAME = 1`
1 to allow push of coin during gameplay to trigger end of game, sacrificing all remaining lives, so a score can be registered.

`SHOW_AWARD_PROGRESS = 1`    
1 to show award progress when playing game (replaces highscore at top of screen)

`SHOW_AWARD_TARGETS = 1`    
1 to show award targets for 1st, 2nd and 3rd prize when playing game (appears during the DK intro/climb scene)

`SHOW_HUD = 1`    
1, 2 or 3 to enable the HUD to be displayed in the top right corner.  Use P2 Start to toggle the data.
1=Targets, 2=Awards, 3=No data, 0 to disable the HUD.


### Control Settings


![DKAFE controls](https://github.com/10yard/dkafe/blob/master/artwork/about/controls.png)


#### Keyboard Controls

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
CONTROL_SETTINGS = tab
CONTROL_SNAP = F12
```

IMPORTANT NOTE: The controls configured in the frontend do not apply to the emulator.  If your controls are not default then you will also have to configure your controls in the emulator menu (tab). 


#### Joystick Controls

Joystick controls are disabled by default.  Set """USE_JOYSTICK = 1""" to enable joystick controls.
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

GPIO input is supported on Raspberry Pi and it is my recommended option for interfacing with arcade controls.  The DKAFE install script can set this up automatically.

GPIO inputs can be mapped to keyboard inputs in the /boot/config.txt file. The chosen defaults avoid using GPIO pins that may be used with other Raspberry Pi peripherals:

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


### How to use romlist.csv

A default romlist.csv is provided for use with the automatically generated roms (see above).

The file can be configured to launch roms from the default rom directory (by leaving subfolder blank) or from a specified subfolder.  
The subfolder is useful when you have multiple roms with the same name e.g. there are lots of hacked versions of dkong.zip.  If the emulator supports a rompath argument then DKAFE will launch the rom directly from its subfolder.
If the emulator does not support a rompath (e.g. Advmame) then the rom will be copied over to the main rompath. See ALLOW_ROM_OVERWRITE option.  With this approach I recommend the original rom be placed into its own subfolder (e.g. **/roms/original**) to prevent it from being overwritten.

All roms in the list should be given an emulator number (e.g. 1 for DKWolf, as defined in settings.txt), a slot position (between 1 and 46) and a basic descriptive name.  Set the slot position to 0 or 99 if you want the rom to only appear in the menu. 

As well as an emulator number,  the roms can be given a recording emulator number (e.g. 2 for DK Wolf recordings).  This provides emulator details for when the rom is launched in recording mode.  Set to zero to disable recording.

The special subfolder name **shell** can be used when you want to launch a batch file or shell script.  Create a .bat or .sh file inside the **/shell** subfolder.  The emulator number can be left blank.

An accompanying icon in .png format should be placed into the **artwork/icons** folder or subfolder with the same name as the rom.  Recommended icon size is 12px wide x 22px High.


![DKAFE slots](https://github.com/10yard/dkafe/blob/master/artwork/about/slots.png)


## Emulator recommendation

For the default frontend you should stick with the bundled DKWolf emulator which comes ready to go. 

Otherwise, my recommendations are:

### For Windows

1. Mame v0.196 to v0.236 from https://www.mamedev.org/ . Rom hacks and lua interface hacks are tested against these versions.
2. Wolfmame (for competition/recording) from https://github.com/mahlemiut/wolfmame/releases/
3. HB Mame (Dedicated to hacks and homebrew) from https://www.progettosnaps.net/hbmame/


### For Raspberry Pi (Model 4)

1. Mame v0.196 to v0.236 from https://www.mamedev.org/ . LUA interface and plugins are tested against these versions.  Mamedev binaries are not generally available for Raspberry Pi so you will have to compile your own.  See readme.txt in **\dkwolf** folder
2. Advance Mame from https://www.advancemame.it/download
  

### How to build DKAFE binary?

Requires Python3 (v3.7 upwards) with installed packages from requirements.txt

Pyinstaller can be used to build the application binary.
```
pyinstaller launch.py --onefile --clean --console --icon artwork/dkafe.ico
```

See build.bat for an example Windows build script making use of venv (virtual environment for Python).

See build.sh and rpi4/rpi_notes.txt for building a Raspberry Pi binary.


### How to compile DKWolf?

Refer to readme.txt in the **/DKWolf** folder.



![DKAFE slots](https://github.com/10yard/dkafe/blob/master/artwork/about/arcade.jpg)


## Motivations?

The frontend was developed for my own DIY Donkey Kong arcade cabinet as a replacement for a 60-in-1 board and as an exercise in learning game development and Donkey Kong rom hacking.

I wanted to bring together all the amazing Donkey Kong roms and hacks into one place with an incentive to play them along with tools to aid my own progression (trainers) and .inp recording capability for score submissions.

I frequently play the original Donkey Kong and aim to improve on my high score of 309,500.


## What's next?

 - Add a test screen for the player controls and a welcome screen to set the initial frontend settings.
 - Complete work on the coaching plugin.  Helpers for Rivets and Pies stages to be added.  Barrels needs more work too.
 - Unlock achievements for one-off objectives in the game such as completing stages for the first time (barrels, rivets, elevators, pies) or reaching levels for the first time.
 - Maybe add Crazy Kong and Donkey Kong 3 with interface support to the default frontend.
 - Create an alternative frontend made for vertical arcade games (like 60-in-1 board) with DK, Pacman, Ms Pacman, Galaga, Burger Time, Frogger etc.  No roms will be provided.
 
## Thanks to

The Donkey Kong rom hacking resource
https://github.com/furrykef/dkdasm 

Paul Goes for an excellent set of Donkey Kong hacking reference material
https://donkeykonghacks.net/

Fantastic Donkey Kong hacks from Sockmaster (John Kowalski), Paul Goes, Jeff Kulczycki, Mike Mika/Clay Cowgill, Don Hodges, Tim Appleton and Vic20 George.

The pygame community
https://www.pygame.org/

The MAMEdev team
https://docs.mamedev.org/

WolfMAME by Mahlemiut
https://github.com/mahlemiut/wolfmame


## License

DKAFE is a free, open source, cross-platform front-end for emulators.
It is licensed under GNU GPLv3. 


## Feedback

Please send feedback to jon123wilson@hotmail.com

Jon

![DKAFE slots](https://github.com/10yard/dkafe/blob/master/artwork/about/trophy.png)
