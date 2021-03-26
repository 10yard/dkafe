#
#  D  K  A  F  E  -  Donkey Kong Arcade Frontend by Jon Wilson
#
# ----------------------------------------------------------------------------------------------
#  Assisted install script for Raspberry Pi4
#
#  You will need to copy the DKAFE binary release (e.g. dkafe_rpi4_binary_v0.1b.zip) and this
#  install script to the /boot partition.
#
#  Run this script to start the assisted install of DKAFE.
#  i.e. /boot/dkafe_install.sh
# ----------------------------------------------------------------------------------------------

# 1) Install DKAFE to /home/pi/dkafe_bin folder
sudo unzip /boot/dkafe_rpi4_binary*.zip -d /home/pi

# 2) Copy dkong roms (if found in /boot partition)
sudo cp -f /boot/dkong.zip /home/pi/dkafe_bin/roms
sudo cp -f /boot/dkongjr.zip /home/pi/dkafe_bin/roms

# 3) Grant all permissions
cd /home/pi
sudo chown -R pi:pi dkafe_bin
sudo chmod -R 777 dkafe_bin

# 4) Run Python scipt for optional setup
sudo python3 /home/pi/dkafe_bin/rpi4/dkafe_install.py