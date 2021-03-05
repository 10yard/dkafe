# 1) Install DKAFE to /home/pi/dkafe_bin folder
sudo unzip /boot/dkafe_bin_install.zip -d /home/pi

# 2) Copy dkong roms if provided in /boot partition
sudo cp /boot/dkong.zip /home/pi/dkafe_bin/roms
sudo cp /boot/dkongjr.zip /home/pi/dkafe_bin/roms

# 3) Update and install dependencies
sudo apt-get update
sudo apt-get install xrandr

# 4) Update system/config files
sudo sh -c "echo '@/home/pi/dkafe_bin/rpi_start.sh' >> /etc/xdg/lxsession/LXDE-pi/autostart"
sudo sh -c "echo 'xserver-command=X -nocursor' >> /usr/share/lightdm/lightdm.conf.d/01_debian.conf"

# 5) Set default screen resolution and reboot
xrandr -s 640x480 --output HDMI-1
sudo reboot