ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
 888    88o  888  o88        888       888          888
 888    888  888888         8  88      888ooo8      888ooo8
 888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
                                        by Jon Wilson (10yard)

Notes on DKWolf
---------------

DKWolf is a custom build of WolfMAME (v0.196) built for DKAFE which supports only Donkey Kong drivers.
It a lightweight emulator less than 15mb size.
This version has functionality removed for save and load states, cheats, throttling etc.

The code changes from released WolfMAME v0.196 are included in the "changes" folder.
The changes are:

  frontend/mame/ui/ui.cpp
    removed startup up messages
    disabled load states and save states
    disabled throttling, frameskip, overclocking, rewind/fastforward, cheats, stepping when paused

  frontend/mame/mame.cpp
    removed "Initializing..." message

  frontend/mame/luaengine.cpp
    fixed issue with lua engine preventing the rightmost pixels from being drawn to screen

  emu/romload.cpp
    removed "WARNING: the machine might not run correctly."
    removed "WRONG CHECKSUMS" message as we are expecting this with our DK hacks.
    removed ROM loading messages
    changed missing ROM error to show message "ROM file was not found.  Please check DKAFE configuration".

  emu/video.h
    Increase the max frameskip so we can more quickly skip the dk intro scene when user presses jump button.

  osd/modules/render/drawbgfx.cpp (** RPI4 ONLY)
    Fix bug in mame source which was effecting RPI build

A useful reference to compiling MAME can be found at:
  http://forum.arcadecontrols.com/index.php?topic=149545.0

MAME build tools are available at https://github.com/mamedev/buildtools/releases

To build with dkong only driver the SOURCES flag was used in the makefile along with REGENIE i.e.
  SOURCES=src/mame/drivers/dkong.cpp
  REGENIE=1
  NOWERROR=1

Other optimisations/flags were
  OPTIMIZE=3
  SYMBOLS=0
  SYMLEVEL=1
  STRIP_SYMBOLS=1 
  TOOLS=0 

Build time was less than 10 minutes!

For making a lightweight build to support multiple drivers:
  SOURCES=src/mame/drivers/dkong.cpp,src/mame/drivers/pacman.cpp,src/mame/drivers/galaga.cpp etc..


Raspberry Pi
------------
Compiling on Raspberry Pi 4:

Use Raspberry Pi Imager to write "Raspberry Pi Desktop" to an SD card and boot it up.
Recommand to change the desktop resolution to 640x480

sudo apt-get update
sudo apt-get install git build-essential python libsdl2-dev libsdl2-ttf-dev libfontconfig-dev qt5-default python3-pip

# Get wolfmame source
wget https://github.com/mahlemiut/wolfmame/archive/wolf196.zip
unzip wolf196

# Copy files from the /dkwolf/changes folder overwriting the source files.  File paths provided in the above notes.

# Adjust makefile (ap per above notes) and build
sudo nano makefile
make

