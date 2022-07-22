```
ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
 888    88o  888  o88        888       888          888
 888    888  888888         8  88      888ooo8      888ooo8
 888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
                                        by Jon Wilson (10yard)
```

## Notes on setting up Raspberry Pi4


### Assisted setup

1. Download the latest raspberry Pi image from the releases page 
2. Write image to an SD card (mimimum 4GB size) using Raspberry Pi Imager
2. Copy dkong.zip to the /boot partition of the SD card.
3. Boot your Raspberry Pi with card inserted.
4. The DKAFE install script will ask the following questions. 
	 Rotate the display?
	 Launch DKAFE on boot?                    (Recommend Y)
	 Hide startup messages?                   (Recommend Y)
	 Hide the Pi taskbar?                     (Recommend Y)
	 Hide the Pi desktop?                     (Recommend Y)
	 Hide the Pi mouse cursor?                (Recommend Y)
	 Use headphone jack for audio?            (Recommend Y)
	 Force 640x480 mode on boot?              (Recommend Y)
	 Map GPIO to keyboard input controls?     (Recommend Y)
	 Disable non-essential Services?          (Recommend Y)
	 Disable networking services (WiFi, SSH)?
	 Reboot now?                              (Recommend Y)	 


### Manual setup

Source files should be extracted to /home/pi/dkafe
The binary distribution should be extracted to /home/pi or you can use the automated setup above.


### Resolution and frontend display scale

The resolution and display scale are set in dkafe_start.sh file.

e.g. for 7:8 aspect ratio with a rotated display use the following:
	xrandr --output HDMI-1 --scale 1x0.8 --rotate left
	
NOTE: If rotating your monitor then you may want to add the OPTION `-nokeepaspect` to your settings.txt file to fill the screen.


### Scan line generators

If using with a VGA scan line generator then you should force 640x480 during boot and disable overscan i.e.

```
disable_overscan=1
hdmi_group=2
hdmi_mode=4
```


### CRT Displays


#### HDMI TO RGB Scart (with VGA2SCART)

This connects Pi using HDMI/VGA adapter to a VGA2SCART adapter (RGB scart https://www.retroupgrades.co.uk/product/vga2scart/)
I was able to make it work well in 1 video mode: 576i at 50hz

```
hdmi_group=1
hdmi_mode=26
disable_overscan=0
```

If there is interference then increase then set ```config_hdml_boost=5``` and increase or reduce value to resolve.

The KMS graphics driver overlay should be commented out i.e.

```
# dtoverlay=vc4-kms-v3d
# max_framebuffers=2
```


#### HDMI to Composite SCART

Use DKAFE default settings but ensure 288p resolution (for PAL) or 240p resolution (for NTSC).
Don't bother with framebuffer height/width config settings.

Optionally, update ```dkafe_start.sh``` and change the scale to fit your CRT display perfectly e.g. --scale 0.7x1  (to stretch the X) 

Optionally use overscan config to fine tune the display positioning e.g.

```
disable_overscan=0
overscan_left=-8
overscan_right=-8
overscan_top=-8
overscan_bottom=-8
```


#### Composite TV Output

The Pi4 supports composite AV output for direct connection to a CRT TV.
You will need a "3.5mm to 3x RCA composite A/V cable" such as this one - https://thepihut.com/products/av-composite-cable-3-5mm-to-3-x-rca-3m
The composite is disabled by default (it reduces performance a little) so you need to enable it.
Add extra config lines to the /boot/config.txt

```
sdtv_mode=2
sdtv_aspect=1
enable_tvout=1
```

The above is for PAL.  For NTSC you should set ```sdtv mode=0```.  Refer to options at https://www.raspberrypi.com/documentation/computers/config_txt.html#composite-video-mode

The KMS graphics driver overlay should be commented out i.e.

```
# dtoverlay=vc4-kms-v3d
# max_framebuffers=2
```

To stretch the graphics to full screen I recommend changing the framebuffer size (in factors of 224x256) e.g.


```
framebuffer_width=448
framebuffer_height=512
```

Optionally,  align picture to fit the screen by enabling overscan e.g.

```
disable_overscan=0
overscan_left=40
overscan_right=8
```


#### GPIO input

GPIO pins can be mapped to keyboard input in the /boot/config.txt file
This makes it easy to wire up arcade controls.

Default assignments for DKAFE controls are as follows:

```
dtoverlay=gpio-key,gpio=17,keycode=105,label="KEY_LEFT"
dtoverlay=gpio-key,gpio=27,keycode=106,label="KEY_RIGHT"
dtoverlay=gpio-key,gpio=22,keycode=103,label="KEY_UP"
dtoverlay=gpio-key,gpio=23,keycode=108,label="KEY_DOWN"
dtoverlay=gpio-key,gpio=24,keycode=29,label="KEY_LEFTCTRL"
dtoverlay=gpio-key,gpio=25,keycode=56,label="KEY_LEFTALT"
dtoverlay=gpio-key,gpio=5,keycode=2,label="KEY_1"
dtoverlay=gpio-key,gpio=6,keycode=3,label="KEY_2"
dtoverlay=gpio-key,gpio=16,keycode=6,label="KEY_5"
dtoverlay=gpio-key,gpio=26,keycode=1,label="KEY_ESC"
```

Refer to pinout guide at https://pinout.xyz/

### SSH

Connect to Raspberry Pi4 remotely via IP (over port 22) using these credentials:

```
User: pi
Password: dkafe
```


### Build DKAFE (from latest sources)

Install dependencies.

```
cd
sudo pip3 uninstall pygame
sudo pip3 install -r requirements.txt
sudo apt install zip libsdl2-ttf-2.0-0 libsdl2-mixer-2.0-0 libsdl2-image-2.0.0
pip install pyinstaller
```

Build the frontend.

```
pyinstaller launch.py --onefile --clean --noconsole --icon artwork/dkafe.ico
```
	
Copy executables to the ```dkafe``` folder which contains all other resources required to run.

```
sudo cp /home/pi/dkafe/dist/launch /home/pi/dkafe
```

Launch DKAFE.

```
cd /home/pi/dkafe	
./launch
```
