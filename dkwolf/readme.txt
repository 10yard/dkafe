ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
 888    88o  888  o88        888       888          888
 888    888  888888         8  88      888ooo8      888ooo8
 888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
                                        by Jon Wilson (10yard)

Notes on DKWolf
---------------

DKWolf is a custom lightweight build of WolfMAME which supports only Donkey Kong drivers.

The code changes for WolfMAME 0.196, 0.236 and 0.241 are included in the "changes" folder.

  frontend/mame/ui/ui.cpp
    removed startup up messages
    disabled load states and save states
    disabled throttling, frameskip, overclocking, rewind/fastforward, cheats, stepping when paused

  emu/romload.cpp
    removed "WARNING: the machine might not run correctly."
    removed "WRONG CHECKSUMS" message as we are expecting this with our DK hacks.
    removed ROM loading messages

  emu/validity.cpp
    Increase check to 1000 roms before clones are validated.  This suppresses the warnings.

  emu/video.h
    Increase the max frameskip so we can more quickly skip the dk intro scene when user presses jump button.
	We can also start some console roms quicker that load from disk. 

  emu/machine.cpp
	Disable save state messages.  States are used by DKAFE only for quick loading of shell/console roms.

  frontend/mame/mame.cpp
    removed "Initializing..." message

  frontend/mame/language.cpp
    Remove translation error messages

  mame/drivers/galaxian.cpp, mame/includes/galaxian.h and mame/mame.lst
	To add support for bigkonggx to v0.241
	

A useful reference to compiling MAME can be found at:
  http://forum.arcadecontrols.com/index.php?topic=149545.0

MAME build tools are available at https://github.com/mamedev/buildtools/releases

To build with only DK drivers (including DK conversions) the SOURCES flag was used in the makefile along with REGENIE i.e.
  SOURCES=src/mame/drivers/dkong.cpp,src/mame/drivers/cclimber.cpp,src/mame/drivers/galaxian.cpp
  REGENIE=1
  NOWERROR=1

Other optimisations/flags are:
  OPTIMIZE=3
  SYMBOLS=0
  SYMLEVEL=1
  STRIP_SYMBOLS=1 
  TOOLS=0 
  DEBUG=0
  USE_QTDEBUG=0
    
Pi4 build specifics:
  Build requires a 8GB minimum SDcard and some dependencies to be installed:
    sudo apt update
    sudo apt-get install git build-essential python libsdl2-dev libsdl2-ttf-dev libfontconfig-dev qt5-default

  Grab sources for a specific release of WolfMAME prior to build:
    wget https://github.com/mahlemiut/wolfmame/archive/refs/tags/wolf241.zip
	unzip wolf241.zip
	
  Apply source changes (assuming working directory is sources target):
    cp language.cpp ~/wolfmame-wolf241/src/frontend/mame/language.cpp
	cp ui.cpp ~/wolfmame-wolf241/src/frontend/mame/ui/ui.cpp
	cp romload.cpp ~/wolfmame-wolf241/src/emu/romload.cpp
	cp validity.cpp ~/wolfmame-wolf241/src/emu/validity.cpp
	cp mame.cpp ~/wolfmame-wolf241/src/frontend/mame/mame.cpp
	cp galaxian.cpp ~/wolfmame-wolf241/src/mame/drivers/galaxian.cpp
	cp galaxian.h ~/wolfmame-wolf241/src/mame/includes/galaxian.h
	cp mame.lst ~/wolfmame-wolf241/src/mame/mame.lst
	cp machine.cpp ~/wolfmame-wolf241/src/emu/machine.cpp
	cp video.h ~/wolfmame-wolf241/src/emu/video.h
	
  Additional Pi4 flags are:
    NO_OPENGL=1
	NO_X11=1
	
  make -j4 LDFLAGS="-Wl,--copy-dt-needed-entries"
