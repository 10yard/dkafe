# 1) Install DKAFE to /home/pi/dkafe_bin folder
sudo unzip /boot/dkafe_bin_rpi4.zip -d /home/pi

# 2) Copy dkong roms (if provided in /boot partition)
sudo cp -f /boot/dkong.zip /home/pi/dkafe_bin/roms
sudo cp -f /boot/dkongjr.zip /home/pi/dkafe_bin/roms

# 3) Grant all permissions
cd /home/pi
sudo chown -R pi:pi dkafe_bin
sudo chmod -R 755 dkafe_bin

# 4) Update system/config files
sudo sh -c "echo '@/home/pi/dkafe_bin/rpi_start.sh' >> /etc/xdg/lxsession/LXDE-pi/autostart"
sudo sh -c "echo 'xserver-command=X -nocursor' >> /usr/share/lightdm/lightdm.conf.d/01_debian.conf"

# 5) Set default screen resolution and reboot
xrandr -s 640x480 --output HDMI-1 --scale 1x1
sudo reboot