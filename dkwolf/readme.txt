ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
 888    88o  888  o88        888       888          888
 888    888  888888         8  88      888ooo8      888ooo8
 888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
                                        by Jon Wilson (10yard)

Notes on DKWolf
---------------

DKWolf is a custom build of WolfMAME built for DKAFE which supports only Donkey Kong drivers.
It a lightweight emulator with reduced size and functionality removed for save and load states, cheats, throttling etc.

The code changes from WolfMAME 0.196 and 0.236 are included in the "changes" folder.

  frontend/mame/ui/ui.cpp
    removed startup up messages
    disabled load states and save states
    disabled throttling, frameskip, overclocking, rewind/fastforward, cheats, stepping when paused

  emu/romload.cpp
    removed "WARNING: the machine might not run correctly."
    removed "WRONG CHECKSUMS" message as we are expecting this with our DK hacks.
    removed ROM loading messages
    changed missing ROM error to show message "ROM file was not found.  Please check DKAFE configuration".

  emu/video.h
    Increase the max frameskip so we can more quickly skip the dk intro scene when user presses jump button.

  frontend/mame/mame.cpp
    removed "Initializing..." message

  frontend/mame/language.cpp (0.236 only)
    Remove translation error messages

  frontend/mame/luaengine.cpp (0.196 only)
    fixed issue with lua engine preventing the rightmost pixels from being drawn to screen

  osd/modules/render/drawbgfx.cpp (Rpi Only)
    Fix bug in mame source which was effecting RPI build

A useful reference to compiling MAME can be found at:
  http://forum.arcadecontrols.com/index.php?topic=149545.0

MAME build tools are available at https://github.com/mamedev/buildtools/releases

To build with only DK (and crazy kong) drivers the SOURCES flag was used in the makefile along with REGENIE i.e.
  SOURCES=src/mame/drivers/dkong.cpp,src/mame/drivers/cclimber.cpp
  REGENIE=1
  NOWERROR=1

Other optimisations/flags were
  OPTIMIZE=3
  SYMBOLS=0
  SYMLEVEL=1
  STRIP_SYMBOLS=1 
  TOOLS=0 
  
Pi4 build requires these dependencies to be installed:
sudo apt-get install git build-essential python libsdl2-dev libsdl2-ttf-dev libfontconfig-dev qt5-default
