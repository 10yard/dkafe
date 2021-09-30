ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
 888    88o  888  o88        888       888          888
 888    888  888888         8  88      888ooo8      888ooo8
 888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
                                        by Jon Wilson (10yard)

Raspberry Pi 4 Install Steps
----------------------------

1. Format a new SD Card,  minimum 4GB size
2. Write the Raspberry Pi OS Desktop image (that's the default one ) using Raspberry Pi Image tool.
3. Extract contents of this zip file to the boot partition of the SD card.
4. Copy dkong.zip to the boot partition of the SD card.  Roms are not provided.
5. Verify that your /boot partition contains the following before continuing:
     ▪ dkafe_bin
     ▪ dkafe_install.sh
     ▪ dkong.zip
6. Boot up your Raspberry Pi and complete the "Welcome to Raspberry Pi" setup.  You can skip options.
7. Run the DKAFE install script in a terminal by typing the following:
     /boot/dkafe_install.sh
8. The assisted setup will ask the following questions.  Y is recommended for all.
     ▪ Rotate the display?
     ▪ Launch DKAFE on boot?
     ▪ Hide startup messages?
     ▪ Hide the Pi taskbar?
     ▪ Hide the Pi desktop?
     ▪ Hide the Pi mouse cursor?
     ▪ Use headphone jack for audio?
     ▪ Force 640x480 mode on boot?
     ▪ Map GPIO to keyboard input controls?
     ▪ Disable non-essential Services?
     ▪ Disable networking services (WiFi, SSH)?
     ▪ Reboot now?
