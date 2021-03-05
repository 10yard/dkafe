# 1) Install DKAFE to /home/pi/dkafe folder
sudo cp /boot/dkafe_rpi4_install.zip /home/pi/
cd /home/pi
unzip dkafe_rpi4_install.zip
sudo rm dkafe_rpi4_install.zip

# 2) Copy roms if provided in /boot partition
sudo cp /boot/dkong.zip /home/pi/dkafe/roms
sudo cp /boot/dkongjr.zip /home/pi/dkafe/roms
sudo cp /boot/roms/*.zip /home/pi/dkafe/roms

# 3) Backup system files and update them
sudo cp -b /home/pi/dkafe/rpi4/config.txt /boot/config.txt
sudo cp -b /home/pi/dkafe/rpi4/cmdline.txt /boot/cmdline.txt

# 4) Backup autostart file and update - this also hides the taskbar
sudo cp -b /home/pi/dkafe/rpi4/autostart /etc/xdg/lxsession/LXDE-pi/autostart

# 5) Backup desktop config and update - this hides the mouse pointer
sudo cp -b /home/pi/dkafe/rpi4/01_debian.conf /usr/share/lightdm/lightdm.conf.d/01_debian.conf

# 6) Update and install general dependencies
sudo apt-get update
sudo apt-get install wmctrl xrandr

# 7) Install dependencies for binary

# 8) Install dependencies for python3 (optional)
cd /home/pi/dkafe
sudo apt-get install python3-pip
pip3 install -r requirements.txt

# 9) Set default screen resolution and reboot
xrandr -s 640x480 --output HDMI-1
sudo reboot