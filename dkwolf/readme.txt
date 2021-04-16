      ___   ___                    .--.
     (   ) (   )                  /    \
   .-.| |   | |   ___     .---.   | .`. ;    .--.
  /   \ |   | |  (   )   / .-, \  | |(___)  /    \
 |  .-. |   | |  ' /    (__) ; |  | |_     |  .-. ;
 | |  | |   | |,' /       .'`  | (   __)   |  | | |
 | |  | |   | .  '.      / .'| |  | |      |  |/  |
 | |  | |   | | `. \    | /  | |  | |      |  ' _.'
 | '  | |   | |   \ \   ; |  ; |  | |      |  .'.-.
 ' `-'  /   | |    \ .  ' `-'  |  | |      '  `-' /  Donkey Kong Arcade Frontend
  `.__,'   (___ ) (___) `.__.'_. (___)      `.__.'   by Jon Wilson

----------------------------------------------------------------------------------------------
 Notes on DKWolf
----------------------------------------------------------------------------------------------

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

  emu/config.cpp
    remove save of config files

  emu/video.h
    Increase the max frameskip so we can more quickly skip the dk intro scene when user presses jump button.

  osd/modules/render/drawbgfx.cpp
    Fix bug in mame source which was effecting RPI build

A useful reference to compiling MAME can be found at:
  http://forum.arcadecontrols.com/index.php?topic=149545.0

MAME build tools are available at https://github.com/mamedev/buildtools/releases

To build with dkong only driver the SOURCES flag was used in the makefile along with REGENIE i.e.
  SOURCES=src/mame/drivers/dkong.cpp
  REGENIE=1

Other optimisations/flags were
  OPTIMIZE=3
  SYMBOLS=0 
  STRIP_SYMBOLS=1 
  TOOLS=0 

Build time was less than 10 minutes!

For making a lightweight build to support multiple drivers:
  SOURCES=src/mame/drivers/dkong.cpp,src/mame/drivers/pacman.cpp,src/mame/drivers/galaga.cpp etc..

----------------------------------------------------------------------------------------------
 Raspberry Pi
----------------------------------------------------------------------------------------------
Compiling on Raspberry Pi 4:

Use Raspberry Pi Imager to write "Raspberry Pi Desktop" to an SD card and boot it up.
Recommand to change the desktop resolution to 640x480

sudo apt-get update
sudo apt-get install git build-essential python libsdl2-dev libsdl2-ttf-dev libfontconfig-dev qt5-default
sudo apt-get install python3-pip
sudo apt-get install wmctrl

# Get wolfmame source
wget https://github.com/mahlemiut/wolfmame/archive/wolf196.zip
unzip wolf196

# Copy files from the /dkwolf/changes folder overwriting the source files.  File paths provided in the above notes.

# Build
sudo nano makefile
make -j5

# Get DKAFE and install requirements
wget https://github.com/10yard/dkafe/??.zip
unzip dkafe
pip3 install -r requirements.txt
sudo pip3 install -r requirements.txt (sudo requirements are needed later for pyinstaller)

# Build pyinstaller
git clone https://github.com/pyinstaller/pyinstaller
	# Need to make a bootloader for Pi
	cd pyinstaller/bootloader
	python ./waf all --target-arch=32bit
	cp /home/pi/code/pyinstaller/build/release/run /home/pi/code/pyinstaller/bootloader
cd pyinstaller	
sudo python3 setup.py install

#build DKAFE
sudo pyinstaller launch.py --onefile --clean --noconsole --icon artwork/dkafe.ico

