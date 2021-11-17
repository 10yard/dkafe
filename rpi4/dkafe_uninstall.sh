#  ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
#   888    88o  888  o88        888       888          888
#   888    888  888888         8  88      888ooo8      888ooo8
#   888    888  888  88o      8oooo88     888          888
#  o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
#                                          by Jon Wilson (10yard)
#
#  Run this script to uninstall DKAFE and undo changes made to the default configuration
#  i.e. /home/pi/dkafe_bin/dkafe_uninstall.sh
#
#
sudo cp /etc/xdg/lxsession/LXDE-pi/autostart_DKAFEBACKUP /etc/xdg/lxsession/LXDE-pi/autostart
sudo cp /etc/xdg/lxsession/LXDE-pi/autostart_DKAFEBACKUP2 /etc/xdg/lxsession/LXDE-pi/autostart
sudo cp /etc/xdg/pcmanfm/LXDE-pi/desktop-items-0-DKAFEBACKUP.conf /etc/xdg/pcmanfm/LXDE-pi/desktop-items-0.conf
sudo cp /usr/share/lightdm/lightdm.conf.d/01_debian_DKAFEBACKUP.conf /usr/share/lightdm/lightdm.conf.d/01_debian.conf
sudo cp /boot/cmdline_DKAFEBACKUP.txt /boot/cmdline.txt
sudo cp /boot/config_DKAFEBACKUP.txt /boot/config.txt

sudo rm /etc/xdg/lxsession/LXDE-pi/autostart_DKAFEBACKUP
sudo rm /etc/xdg/lxsession/LXDE-pi/autostart_DKAFEBACKUP2
sudo rm /etc/xdg/pcmanfm/LXDE-pi/desktop-items-0-DKAFEBACKUP.conf
sudo rm /usr/share/lightdm/lightdm.conf.d/01_debian_DKAFEBACKUP.conf
sudo rm /boot/cmdline_DKAFEBACKUP.txt
sudo rm /boot/config_DKAFEBACKUP.txt

sudo systemctl enable dphys-swapfile.service --quiet
sudo systemctl enable keyboard-setup.service --quiet
sudo systemctl enable apt-daily.service --quiet
sudo systemctl enable hciuart.service --quiet
sudo systemctl enable avahi-daemon.service --quiet
sudo systemctl enable triggerhappy.service --quiet
sudo systemctl enable systemd-timesyncd.service --quiet
sudo systemctl enable gldriver-test.service --quiet
sudo systemctl enable systemd-rfkill.service --quiet
sudo systemctl enable dhcpcd.service --quiet
sudo systemctl enable networking.service --quiet
sudo systemctl enable ssh.service --quiet
sudo systemctl enable wpa_supplicant.service --quiet

xrandr --output HDMI-1 --rotate left
sudo rm -r /home/pi/dkafe_bin
