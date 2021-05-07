# **DKAFE** #

## Donkey Kong Arcade Front End

A multi-platform arcade game launcher based on Donkey Kong made for arcade cabinets with incentives to play and unlock arcade games.  


![DKAFE frontend](https://github.com/10yard/dkafe/blob/master/artwork/about/frontend.png)

The frontend system mimics Donkey Kong gameplay.  You control Jumpman on the familiar girders stage and have him select which arcade game to launch.

The default setup showcases all the excellent Donkey Kong hacks that have been developed by the community along with some new hacks that were made specifically for this frontend. 

The built-in reward system will payout coins when you play well.  Earning coins will allow you to unlock and play more machines.

Coins are awarded after beating target scores (for 3rd, 2nd and 1st prize).  Coins will drop from the top of the screen (after returning to the frontend) and Jumpman must do his best to collect them before they disappear off the bottom.


![DKAFE awards](https://github.com/10yard/dkafe/blob/master/artwork/about/awards.png) 


Pauline helps out providing game information, score targets and unlock requirements as you walk towards an arcade machine.  

You begin with 500 coins, and you must collect coins which are thrown by Donkey Kong.  You'll be charged 100 coins to launch a game.  Be aware of the countdown timer too,  if the timer runs out you'll lose 150 coins!

If you're not up for the challenge then it is possible to adjust things and have all machines unlocked and set to free play.  Pauline will love it when you beat all the machines though.

The frontend can be configured to launch other emulators and roms.

> There will be folks who want to have 10,000 games on their arcade machines.  This frontend is not for them.  It was made for simplicity and to showcase a small selection of games and encourage them to be played.  


### This project includes:
 - An interactive frontend launcher that comes preconfigured to work with classic Donkey Kong roms and hacks.
 - A custom lightweight version of WolfMAME built specifically for Donkey Kong.
 - A rom patcher that will automatically generate hacked roms from the many included patch files.
 - LUA scripts to seamlessly interface MAME with the frontend.
 - 3 Donkey Kong hacks made by me for use with the DKAFE frontend:
   1. **DK Lava Panic**
Jumpman must keep his cool and move quickly up platforms to avoid rising Lava.  Try not to panic!
   2. **DK Who and the Daleks** 
Jumpman has regenerated as the next Dr Who.  Help him rescue his assistant from the clutches of Donkey Kong.  The Daleks have destroyed her rocket ship and you're her only hope for escape.  Use the Tardis to teleport Jumpman through dimensions in spacetime.
   3. **DK Last Man Standing** 
You will lose penalty points instead of lives so don't make mistakes unless you have earned enough points to survive.  You decide when to stop playing!


### This project does not include:
 - Roms or information on how to obtain them.


## Automatically generated roms

DKAFE comes with a default frontend built from various patches of the original **dkong.zip** (US Set 1) arcade rom.  The original rom is required for the patching to work.
All patch files are included in the **/patch folder**.


![DKAFE game info](https://github.com/10yard/dkafe/blob/master/artwork/about/patches.png)


Credit is given to the original authors below.


#### By Jon Wilson (me)
 - Donkey Kong Lava Panic! (dkonglava)
 - DK Who and the Daleks (dkongwho)
 - DK Last Man Standing (dkonglastman)

#### By Paul Goes - https://donkeykonghacks.net/
 - Donkey Kong Crazy Barrels Edition (dkongcb)
 - Donkey Kong Championship Edition (dkongce)
 - Donkey Kong Randomized Edition (dkongrnd)
 - Donkey Kong Freerun Edition (dkongfr)
 - Donkey Kong Into The Dark (dkongitd)
 - Donkey Kong Skip Start (dkongl05)
 - Donkey Kong Reverse (dkongrev)
 - Donkey Kong On The Run (dkongotr)
 - Donkey Kong Twisted Jungle (dkongtj)

#### By John Kowalski (Sock Master) - http://users.axess.com/twilight/sock/
 - Donkey Kong Spooky Remix (dkongspooky)
 - Donkey Kong Christmas Remix (dkongxmas)
 - Donkey Kong Springs Trainer (dkongst2)
 - Donkey Kong Trainer (dkongtrn)
 - Donkey Kong Pace (dkongpace)
 - Donkey Kong Rainbow (dkongrainbow)

#### By Jeff Kulczycki - http://www.jeffsromhack.com/products/d2k.htm
 - Donkey Kong 2 Jumpman Returns (dkongdk2)
 - Donkey Kong Foundry (dkongf)
 - Donkey Kong Barrel Control Colouring (dkongbcc)

#### By Mike Mika and Clay Cowgill - http://www.multigame.com/dkp_arcade.html
 - Donkey Kong Pauline Edition (dkongpe)

#### By Don Hodges - http://www.donhodges.com/how_high_can_you_get.htm
 - Donkey Kong Killscreen Fix (dkongksfix)

#### By Tim Appleton - https://www.oocities.org/wigglebeat
 - Donkey Kong Pac-Man (dkongpac)

#### By Vic Twenty George
 - Donkey Kong Atari 2600 Graphics (dkong2600)

#### By unknown others
 - Donkey Kong Wild Barrel Hack (dkongwbh)
 - Donkey Kong Hard (dkonghrd)
 - Donkey Kong 2 Marios (dkong2m)
 - Donkey Kong Naked (dkongnad)


![DKAFE hacks](https://github.com/10yard/dkafe/blob/master/artwork/about/dkwho_gameplay.png)


## DKWolf

DKAFE comes with my custom lightweight build of WolfMAME named DKWolf,  it supports only Donkey Kong drivers.

This build has functionality disabled for save/load states, cheats, rewind, throttling etc. to make competition more challenging.

Gameplay recordings are saved to DKAFE's **/dkwolf/inp** folder.

It is possible to set up other emulators and roms if you do not wish to use the default Donkey Kong focussed front end.


## How to install

Steps to install the default frontend are as follows.  Also refer to **How to set up**.

### Windows

1. Download the latest DKAFE binary release for Windows and extract content to a folder. It is recommended to download the 64bit version unless you have an old machine.

2. Run "launch.exe".


### Raspberry Pi

1. Write the Raspberry Pi OS Desktop image (that's the default one ) using Raspberry Pi Image tool to an SD Card.

2. Extract contents of the latest Raspberry Pi Binary Release Zip to the boot partition of the SD card.

3. Copy dkong.zip and dkongjr.zip (optional) to the boot partition of the SD card.  Roms are not provided.

4. Verify that your /boot partition contains these files before continuing:
```  
     dkafe_bin
     dkafe_install.sh
     dkong.zip
```
	 
5. Boot your Raspberry Pi and complete the "Welcome to Raspberry Pi" setup.  You can skip options.

6. Run the install script in a terminal.
     /boot/dkafe_install.sh

7. The assisted setup will ask the following questions.
```	 
	 Rotate the display?
	 Launch DKAFE on boot?                    (Recommend Y)
	 Hide startup messages?                   (Recommend Y)
	 Hide the Pi taskbar?                     (Recommend Y)
	 Hide the Pi desktop?                     (Recommend Y)
	 Hide the Pi mouse cursor?                (Recommend Y)
	 Use headphone jack for audio?            (Recommend Y)
	 Force 640x480 mode on boot?              (Recommend Y)
	 Map GPIO to keyboard input controls?     (Recommend Y)
	 Disable non-essential Services?          (Recommend Y)
	 Disable networking services (WiFi, SSH)?
	 Reboot now?                              (Recommend Y)
```

## How to set up?

The default set up simply requires that you place **dkong.zip** (and optionally **dkongjr.zip**) into DKAFE's **/roms** folder.  
The frontend will automatically generate a bunch of Donkey Kong roms using patch files which are included with the software.

The application requires settings.txt and romlist.csv to be present in the installation folder.  Defaults are provided.
 
The settings.txt contains the emulator, rom path, controls and other configuration.  See **Frontend Settings** section below.

The romlist.csv contains information about the roms, which slot they should appear in and how they can be unlocked and launched in the frontend.  See **How to use romlist.csv** below.

The frontend can be configured with multiple arcade emulators to allow a combination of standard arcade roms,  hacked and homebrew roms and to support Wolfmame recordings.


## Display Resolution

The frontend is rendered at 224x256 pixels (as per the original Donkey Kong arcade machine) and then scaled to fit the monitors actual resolution.
The scaling works perfectly with a 7:8 aspect vertically rotated screen.

The command line argument `-view "Pixel Aspect (7:8)"` can be used to override MAME's default 4:3 aspect.

For my Windows system,  I was able to create a custom 7:8 aspect resoluton of 448x512 pixels with the Intel Graphics Driver.

For Raspberry Pi,  you should use 640x480 resolution and adjust the x/y display scale using xrandr.  The Pi install script will set this up for you.  Refer to **rpi4/rpi4_notes**.



### Frontend Settings

Default settings can be changed in the settings.txt file.  Some settings can also be changed in the frontend settings menu (available at the bottom of the game list or by pressing TAB).

`FULLSCREEN = 1`  
1 for fullscreen mode or 0 for windowed mode.

`FREE_PLAY = 0`    
1 for free play.  If 0 then Jumpman must collect sufficient coins to play a game.

`UNLOCK_MODE = 1`    
1 for unlock mode were Jumpman must score points to unlock games.  If 0 then all games are unlocked by default.

`CONFIRM_EXIT = 1`    
1 to display confirmation screen when attempting to exit.  0 to exit without question.

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


### Emulator Settings

Default settings can be changed in the settings.txt file.

```
EMU_1 = <ROOT>/dkwolf/dkwolf <OPTIONS>
EMU_2 = <ROOT>/dkwolf/dkwolf <OPTIONS> -record <NAME>_<DATETIME>.inp 
EMU_3 = (optional)
EMU_4 = (optional)
EMU_5 = (optional)
EMU_6 = (optional)
EMU_7 = (optional)
EMU_8 = (optional)
```
`EMU_1` and `EMU_2` come preconfigured.    
`EMU_3` to `EMU_8` can be used to add more of your own emulators.  By default `EMU_1` is used for DKAFE gameplay and `EMU_2` is used for "inp" recordings.

`ROM_DIR = <ROOT>/roms`    
The rom directory is set to the DKAFE roms folder by default.

`OPTIONS = -rompath <ROM_DIR> -view "Pixel Aspect (7:8)"`    
General arguments can be stored into <OPTIONS> rather than repeating for each emulator.

The special tags `<ROOT>`, `<ROM_DIR>`, `<OPTIONS>`, `<NAME>` and `<DATETIME>` used above are replaced with their actual values at runtime.

`ALLOW_ROM_OVERWRITE = 0`
Allow roms in ROM_DIR to be overwritten.  Set to 1 when using an emulator that doesn't support a rompath argument e.g. AdvanceMAME.

`EMU_EXIT_RPI`
Raspberry Pi specific command to issue after exiting emulator e.g. using `wmctrl` to return focus to the frontend.

`EMU_ENTER_RPI`
Raspberry Pi specific command to issue before starting an emulator


### DK Interface Settings

These settings relate to Donkey Kong and DK Junior Roms and hacks.

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

#### Joystick Controls

Joystick controls can be configured by setting the USE_JOYSTICK option.
The up, down, left, right controls are defined automatically from the first joysticks axis movement.
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


## How to use romlist.csv

A default romlist.csv is provided for use with the automatically generated roms (see above).

The file can be configured to launch roms from the default rom directory (by leaving subfolder blank) or from a specified subfolder.  
The subfolder is useful when you have multiple roms with the same name e.g. there are lots of hacked versions of dkong.zip.  If the emulator supports a rompath argument then DKAFE will launch the rom directly from its subfolder.
If the emulator does not support a rompath (e.g. Advmame) then the rom will be copied over to the main rompath. See ALLOW_ROM_OVERWRITE option.  With this approach I recommend the original rom be placed into its own subfolder (e.g. **/roms/original**) to prevent it from being overwritten.

All roms in the list should be given an emulator number (as defined in settings.txt), a slot position (between 1 and 46) and a basic descriptive name.  Set the slot position to 0 or 99 if you want the rom to only appear in the menu. 

The special subfolder name **shell** can be used when you want to launch a batch file or shell script.  Create a .bat or .sh file inside the **/shell** subfolder.  The emulator number can be left blank.

An accompanying icon in .png format should be placed into the **artwork/icons** folder or subfolder with the same name as the rom.  Recommended icon size is 12px wide x 22px High.  You can use the default_machine.png as a template.

Hopefully that all makes sense.  Refer to the example romlist.csv


![DKAFE slots](https://github.com/10yard/dkafe/blob/master/artwork/about/slots.png)


## Emulator recommendation

For the default frontend you should stick with the bundled DKWolf emulator which comes ready to go. 

Otherwise, my recommendations are:

### For Windows

1. Mame v0.196 from https://www.mamedev.org/ . Rom hacks and lua interface hacks are tested against this version.

2. Wolfmame (for competition/recording) from https://github.com/mahlemiut/wolfmame/releases/

3. HB Mame (Dedicated to hacks and homebrew) from https://www.progettosnaps.net/hbmame/


### For Raspberry Pi (Model 4)

1. Mame v0.196 from https://www.mamedev.org/ . Rom hacks and lua interface hacks are tested against this version.  Mamedev binaries are not generally available for Raspberry Pi so you will have to compile your own.  See readme.txt in **\dkwolf** folder

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

The frontend was developed for my own DIY Donkey Kong arcade cabinet as a replacement for a 60-in-1 board and as an exercise in learning game development and Donkey Kong hacking.

I wanted to bring together all the amazing Donkey Kong roms and hacks into one place with an incentive to play them along with tools to aid my own progression (trainers) and .inp recording capability for score submissions.

I frequently play the original Donkey Kong and aim to improve on my high score of 255,120.  I need to master those springs!


## What's next?

 - Unlock achievements for one-off objectives in the game such as completing stages for the first time (barrels, rivets, elevators, pies) or reaching levels for the first time.
 - Maybe add Crazy Kong and Donkey Kong 3 with interface support to the default frontend.
 - Maybe extend the default frontend setup to include support for NES Donkey Kong hacks.
 - Create an alternative frontend made for vertical arcade games (like 60-in-1 board) with DK, Pacman, Ms Pacman, Galaga, Burger Time, Frogger etc.  No roms will be provided.


## I need help with
 
 - Creating .png icons for popular arcade machine.  See the **dkafe/artwork/icon** folder.
 - Testing and tweaking the unlock mode.
 
 
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