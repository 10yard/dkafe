      ___   ___                    .--.
     (   ) (   )                  /    \
   .-.| |   | |   ___     .---.   | .`. ;    .--.
  /   \ |   | |  (   )   / .-, \  | |(___)  /    \
 |  .-. |   | |  ' /    (__) ; |  | |_     |  .-. ;
 | |  | |   | |,' /       .'`  | (   __)   |  | | |
 | |  | |   | .  '.      / .'| |  | |      |  |/  |
 | |  | |   | | `. \    | /  | |  | |      |  ' _.'
 | '  | |   | |   \ \   ; |  ; |  | |      |  .'.-.
 ' `-'  /   | |    \ .  ' `-'  |  | |      '  `-' /  Donkey Kong Arcade
  `.__,'   (___ ) (___) `.__.'_. (___)      `.__.'   by Jon Wilson

-----------------------------------------------------------------------------------
 Raspberry Pi 4 Install.  This readme file is bundled with the binary release ZIP.
-----------------------------------------------------------------------------------

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
