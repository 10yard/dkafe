ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
 888    88o  888  o88        888       888          888
 888    888  888888         8  88      888ooo8      888ooo8
 888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
                                        by Jon Wilson (10yard)

Raspberry Pi 4 Install Steps
----------------------------

1. Download the latest raspberry Pi image from the releases page and burn to an SD card (mimimum 4GB size)
2. Copy dkong.zip to the /boot partition of the SD card.
3. Boot your Raspberry Pi with card inserted.
4. The DKAFE install script ask the following questions. 
	 Rotate the display?
	 Launch DKAFE on boot?                    (Recommend Y)
	 Hide startup messages?                   (Recommend Y)
	 Hide the Pi taskbar?                     (Recommend Y)
	 Hide the Pi desktop?                     (Recommend Y)
	 Hide the Pi mouse cursor?                (Recommend Y)
	 Use headphone jack for audio?
	 Optimise framebuffer           (Recommend Y for HDMI and VGA)
	 Force 640x480 mode on boot?    (Recommend Y for HDMI and VGA)
	 Map GPIO to keyboard input controls?     (Recommend Y)
	 Disable non-essential Services?          (Recommend Y)
	 Disable networking services (WiFi, SSH)?
	 Reboot now?	 


	 
Notes
-----
If rotating your monitor then you may want to add the OPTION `-nokeepaspect` to your settings.txt file to fill the screen.