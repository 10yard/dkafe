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
    increase check to 1000 roms before clones are validated.  This suppresses the warnings.

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
	
  Apply source changes (assuming the sources target):
    cp ~/dkafe_bin/dkwolf/changes/wolf241-build/language.cpp ~/wolfmame-wolf241/src/frontend/mame/language.cpp
	cp ~/dkafe_bin/dkwolf/changes/wolf241-build/ui.cpp ~/wolfmame-wolf241/src/frontend/mame/ui/ui.cpp
	cp ~/dkafe_bin/dkwolf/changes/wolf241-build/romload.cpp ~/wolfmame-wolf241/src/emu/romload.cpp
	cp ~/dkafe_bin/dkwolf/changes/wolf241-build/validity.cpp ~/wolfmame-wolf241/src/emu/validity.cpp
	cp ~/dkafe_bin/dkwolf/changes/wolf241-build/mame.cpp ~/wolfmame-wolf241/src/frontend/mame/mame.cpp
	
  Additional Pi4 flags are:
    NO_OPENGL=1
	NO_X11=1
	ARCHOPTS = -mcpu=cortex-a72 -mtune=cortex-a72 -mfpu=neon-vfpv4 -mfloat-abi=hard -funsafe-math-optimizations -fexpensive-optimizations -fprefetch-loop-arrays
	
  make LDFLAGS="-Wl,--copy-dt-needed-entries"
