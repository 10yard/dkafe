vDKWolf is a custom build of WolfMAME (v0.196) built for DKAFE which supports only Donkey Kong drivers.  
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
    Fix bug with mame source to allow building on Raspberry Pi4 without X11

A useful reference to compiling MAME can be found at:
  http://forum.arcadecontrols.com/index.php?topic=149545.0

To build with dkong only driver the SOURCES flag was used in the makefile along with REGENIE i.e.
  SOURCES=src/mame/drivers/dkong.cpp
  REGENIE=1

Other optimisations/flags were
  OPTIMIZE=3
  SYMBOLS=0 
  STRIP_SYMBOLS=1 
  PTR64=1 
  TOOLS=0 

Build time was less than 10 minutes!

For making a lightweight build to support multiple drivers e.g. for a 60-in-1 type setup:
  SOURCES=src/mame/drivers/dkong.cpp,src/mame/drivers/pacman.cpp,src/mame/drivers/galaga.cpp etc..

*****************
** Raspberry Pi**
*****************
Useful reference when compiling for Raspberry Pi:
  https://nowhereman999.wordpress.com/2016/02/29/compile-mame-0-171-on-a-raspberry-pi-2/
  also NO_OPENGL=1 with the make

Raspberry Pi Model 4B:
  Burn retropie to SDcard,  can use the version that comes with rpi imager
  copy dkafe.zip to boot partition
  copy mame_211b.zip to boot partition
  update config.txt and cmdline.txt on boot partition

  start it up then:
  cd
  unzip dkafe.zip

  cd
  sudo apt install -y mame
  (installs to /usr/games/mame and .mame under home)

  cd RetroPieSetup
  sudo ./retropie_setup.sh 
	- autostart > boot to text console (auto login)
	- splashscreen > disable splashscreen on boot
	- bashwelcometweak > remove bash welcome tweak
  reboot

  sudo apt install libsdl2-ttf-2.0-0 libsdl2-mixer-2.0-0 libsdl2-image-2.0-0  (install other SDL2 stuff,  not the main SDL2 though)

  cd
  cd dkafe
  sudo apt-get install python3-pip
  pip3 install -r requirements.txt

  sudo nano /opt/retropie/configs/all/autostart.sh (replace content with below)
  # DKAFE startup script
  aconnect -x  (to close any apps using the sound)
  cd
  cd dkafe
  python3 launch.py

Launching DKWolf with these arguments:
  -video accel -view "Pixel Aspect (7:8)"
