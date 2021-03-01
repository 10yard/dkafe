# **DKAFE** #

## Donkey Kong Arcade Front End

A Donkey Kong focussed arcade game launcher made for arcade cabinets with incentives to play and unlock arcade games. 


![DKAFE frontend](https://github.com/10yard/dkafe/blob/master/artwork/about/frontend.png)

You control Jumpman on the familiar girders stage and have him select which game to launch.

The default frontend setup brings together all the excellent Donkey Kong hacks that have been developed by the community along with some new hacks made specifically for this frontend. 

The frontend reward system will encourage you to play machines by awarding coins when you play well.  Hopefully encouraging you to unlock them and get good at them!

Your score targets are made visible during gameplay, and you are informed when you have earned a prize - so you know to expect a payout of coins.  Coins are awarded after beating target scores for 3rd, 2nd and 1st prize.

Awarded coins will drop from the top of the screen (after returning to the frontend) and Jumpman must do his best to collect them before they disappear off the bottom.


![DKAFE awards](https://github.com/10yard/dkafe/blob/master/artwork/about/awards.png) 


Pauline will provide game information, score targets and unlock requirements as you walk towards an arcade machine.  

You begin with just 100 coins, so you must collect coins which are thrown by Donkey Kong.  You'll be charged 100 coins to launch a game.  Be aware of the countdown timer too,  if the timer runs out you'll lose 150 coins!

If you're not up for the challenge then it is possible to adjust things and have all machines unlocked and set to free play.  Pauline will love it when you beat all the machines though.

The frontend can be easily configured to launch other emulators and roms.

> There will be folks who want to have 50,000 games on their arcade machines.  This frontend is not for them,  it was made for simplicity and to showcase a small selection of games and encourage them to be played.  


### This project includes:
 - An interactive frontend launcher that comes preconfigured to work with classic Donkey Kong roms and hacks.
 - A custom lightweight version of WolfMAME built specifically for Donkey Kong.
 - A rom patcher that will automatically generate hacked roms from the many included patch files.
 - LUA scripts to seamlessly interface MAME with the frontend.
 - 3 Donkey Kong hacks made by me for use with the DKAFE frontend:
   1. **DK Who and the Daleks** 
Jumpman has regenerated as the next Dr Who and has a Tardis for teleporting through spacetime.  Daleks and Weeping Angels will stand in your way of saving Rose Tyler.
   2. **DK Lava Panic**
Jumpman must keep his cool and move quickly up the platforms to avoid the rising Lava.  Try not to panic!
   3. **DK Last Man Standing** 
You will lose penalty points instead of lives so don't make mistakes unless you have earned enough points to survive.  You decide when to stop playing!


### This project does not include:
 - Roms or information on how to obtain them.


## Automatically generated roms

DKAFE comes with a default frontend built from various patches of the original **dkong.zip** (US Set 1) arcade rom.  The original rom is required for the patching to work,  it is not provided with the software.
All patch files are included in the **\patch folder.  Credit is given to the original authors below.


![DKAFE game info](https://github.com/10yard/dkafe/blob/master/artwork/about/gameinfo.png)


Not all the hacks feature in the default frontend setup.  I have purposely left out some crumbier ones e.g. dkong2m, dkongnad.


#### By Jon Wilson (me)
 - DK Who and the Daleks (dkongwho)
 - Donkey Kong Lava Panic (dkonglava)
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
 - Donkey Kong Kill Screen Fix (dkongksfix)

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

DKAFE comes with my custom lightweight build of WolfMAME which supports only Donkey Kong drivers. 
This version has functionality disabled for save/load states, cheats, rewind, throttling etc. to make competition more challenging.
It is possible to set up other emulators and roms if you do not wish to use the default Donkey Kong focussed front end.

Gameplay recordings are saved to DKAFE's **dkwolf\inp** folder and can be replayed outside DKAFE using the **playback.bat** passing arguments for romname and filename e.g.
```
playback dkong dkong_01022021-084510 
```


## Display Resolution

The frontend is rendered at 224x256 pixels (as per the original Donkey Kong arcade machine) and then scaled to fit the monitors actual resolution.
The scaling works perfectly with a 7:8 aspect vertically rotated screen.

For my system,  I was able to create a custom 7:8 aspect resoluton of 448x512 pixels with the Intel Graphics Driver.

I use the command line option **-view "Pixel Aspect (7:8)"** to override MAME's default 4:3 aspect.


## How to set up?

The application requires settings.txt and romlist.csv to be present in the installation folder along with other resources.  Defaults are provided.
 
The settings.txt contains the emulator, rom path, controls and other configuration.

The romlist.csv contains information about the roms, which slot they should appear in and how they can be unlocked and launched in the frontend.

The frontend can be configured with multiple arcade emulators to allow a combination of standard arcade roms,  hacked and homebrew roms and to support Wolfmame recordings.

The default set up simply requires that you place **dkong.zip** (and optionally **dkongjr.zip**) into DKAFE's **\roms** folder.  The frontend will automatically generate a bunch of Donkey Kong roms using patch files which are included with the software.  Refer to the "Automatically generated roms" section above. 


### Frontend Settings

Default settings can be changed in the settings.txt file.

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

`ENABLE_HAMMERS=1`    
1 to enable teleport between hammers in the fronted.  Makes it quicker to move up and down platforms.

`INACTIVE_TIME = 20`    
Period of inactivity in seconds before showing attract mode/game instructions.

`PLAY_COST = 100`    
How much it costs to play an arcade machine.

`LIFE_COST = 150`    
How many coins Jumpman drops when time runs out.

`TIMER_START = 5000`    
Number to start the countdown timer from.


### Emulator Settings

Default settings can be changed in the settings.txt file.

```
EMU_1 = <ROOT>\dkwolf\dkwolf <OPTIONS>
EMU_2 = <ROOT>\dkwolf\dkwolf <OPTIONS> -record <NAME>_<DATETIME>.inp 
EMU_3 = (optional)
EMU_4 = (optional)
EMU_5 = (optional)
EMU_6 = (optional)
EMU_7 = (optional)
EMU_8 = (optional)
```
`EMU_1` and `EMU_2` come preconfigured.    
`EMU_3` to `EMU_8` can be used to add more of your own emulators.  By default `EMU_1` is used for DKAFE gameplay and `EMU_2` is used for "inp" recordings.

`ROM_DIR = <ROOT>\roms`    
The rom directory is set to the DKAFE roms folder by default.

`OPTIONS = -rompath <ROM_DIR> -video gdi -view "Pixel Aspect (7:8)"`    
General arguments can be stored into <OPTIONS> rather than repeating for each emulator.

The special tags `<ROOT>`, `<ROM_DIR>`, `<OPTIONS>`, `<NAME>` and `<DATETIME>` used above are replaced with their actual values at runtime.

`ALLOW_ROM_OVERWRITE = 0`
Allow roms in ROM_DIR to be overwritten.  Set to 1 when using an emulator that doesn't support a rompath argument e.g. AdvanceMAME.


### DK Interface Settings

These settings relate to Donkey Kong and DK Junior Roms and hacks.

`CREDITS = 1`    
1 to automatically insert a coin after launching a game.

`AUTOSTART = 1`    
1 to automatically start the game - if coins are inserted.

`SHOW_AWARD_PROGRESS = 1`    
1 to show award progress when playing game (replaces highscore at top of screen)

`SHOW_AWARD_TARGETS = 1`    
1 to show award targets for 1st, 2nd and 3rd prize when playing game (appears during the DK intro/climb scene)

`SHOW_HUD = 1`    
1, 2 or 3 to enable the HUD to be displayed in the top right corner.  Use P2 Start to toggle the data.
1=Targets, 2=Awards, 3=No data, 0 to disable the HUD.


### Control Settings


![DKAFE controls](https://github.com/10yard/dkafe/blob/master/artwork/about/controls.png)


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
CONTROL_SNAP = F12
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

A default romlist.csv is provided for use with the automatically generated roms (see above).

The file can be configured to launch roms from the default rom directory (by leaving subfolder blank) or from a specified subfolder.  
The subfolder is useful when you have multiple roms with the same name e.g. there are lots of hacked versions of dkong.zip.  If the emulator supports a rompath argument then DKAFE will launch the rom directly from its subfolder.
If the emulator does not support a rompath (e.g. Advmame) then the rom will be copied over to the main rompath. See ALLOW_ROM_OVERWRITE option.  With this approach I recommend the original rom be placed into its own subfolder (e.g. **/original**) to prevent it from being overwritten.

All roms in the list should be given an emulator number (as defined in settings.txt), a slot position (between 1 and 46) and a basic descriptive name.  Set the slot position to 0 or 99 if you want the rom to only appear in the menu. 

The special subfolder name **shell** can be used when you want to launch a batch file or shell script.  Create a .bat or .sh file inside the **shell** subfolder of DKAFE.  The emulator number can be left blank.

An accompanying icon in .png format should be placed into the **artwork\icons** folder or subfolder with the same name as the rom.  Recommended icon size is 12px wide x 22px High.  You can use the default_machine.png as a template.

Hopefully that all makes sense.  Refer to the example romlist.csv


![DKAFE slots](https://github.com/10yard/dkafe/blob/master/artwork/about/slots.png)


## Emulator recommendation

### For Windows

For the default frontend you should stick with the bundled DKWolf emulator which comes ready to go. 
Otherwise, my recommendations are:

1. Mame64 v0.196 minimum from https://www.mamedev.org/ . Rom hacks and lua interface hacks were tested against versions from v0.196 to v0.226

2. Wolfmame (for competition/recording) from https://github.com/mahlemiut/wolfmame/releases/

3. HB Mame (Dedicated to hacks and homebrew) from https://www.progettosnaps.net/hbmame/


### For Raspberry Pi

Support is work in progress.

For best performance: 
 - Raspberry Pi 4 hardware (tested with 4gb version) running "RaspberryPi OS Lite"
 - Set the display resolution to 640x480 in raspi-config and rotate screen if preferred.
 - Set the framebuffer_width and framebuffer_height to 448x512 in the **/boot/config.txt** file
 - Set `OPTIONS = -rompath <ROM_DIR> -video accel -view "Pixel Aspect (7:8)"` in DKAFE's **settings.txt** file.
  

### How to build DKAFE?

Requires Python3 (v3.7 upwards) with installed packages from requirements.txt

Pyinstaller can be used to build the application binary on Windows.
```
pyinstaller launch.py --onefile --clean --console --icon artwork\dkafe.ico
```

See build.bat for an example build script making use of venv (virtual environment for Python)


### How to compile DKWolf?

Refer to readme.txt in the **DKWolf** folder.


## Motivations?

The frontend was developed for my own DIY Donkey Kong arcade cabinet as a replacement for a 60-in-1 board and as an exercise in learning game development and Donkey Kong hacking.

I wanted to bring together all the amazing Donkey Kong roms and hacks into one place with an incentive to play them along with tools to aid my own progression (trainers) and .inp recording capability for score submissions.

I frequently play the original Donkey Kong on MAME and aim to beat my high score of 199,200.  I need to master those springs!


## What's next?

 - Get this all running well on a Raspberry Pi 4.
 - Extend the default frontend setup to include support for NES Donkey Kong hacks.
 - Add Crazy Kong and Donkey Kong 3 interface support to the default frontend.
 - Provide 60-in-1 as a pre-configured frontend option - without the roms.
 - Allow some options to be easily changed via the frontend e.g. freeplay (on/off), unlock mode (on/off), autostart (on/off).
 
 
## Thanks to

The Donkey Kong rom hacking resource
https://github.com/furrykef/dkdasm 

Paul Goes for an excellent set of Donkey Kong hacking reference material
https://donkeykonghacks.net/

Fantastic Donkey Kong hacks from Sockmaster (John Kowalski), Paul Goes, Jeff Kulczycki, Mike Mika/Clay Cowgill, Don Hodges, Tim Appleton and Vic20 George.

The Donkey Kong Forum
https://donkeykongforum.com/

The pygame community
https://www.pygame.org/

The MAMEdev team
https://docs.mamedev.org/

WolfMAME by Mahlemiut
https://github.com/mahlemiut/wolfmame


## Feedback

Please send feedback to jon123wilson@hotmail.com

Jon