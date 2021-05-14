#
#  D  K  A  F  E  -  Donkey Kong Arcade Frontend by Jon Wilson
#
# ----------------------------------------------------------------------------------------------
#  Assisted install script for Raspberry Pi4
#
#  You will need to extract all contents of the DKAFE binary release zip file
#  to the /boot partition and then run this script.
#
#  i.e. /boot/dkafe_install.sh
# ----------------------------------------------------------------------------------------------

# 1) Install DKAFE to /home/pi/dkafe_bin folder
sudo cp -r /boot/dkafe_bin /home/pi

# 2) Copy dkong roms (if found in /boot partition)
sudo cp -f /boot/dkong.zip /home/pi/dkafe_bin/roms
sudo cp -f /boot/dkongjr.zip /home/pi/dkafe_bin/roms

# 3) Grant all permissions
cd /home/pi
sudo chown -R pi:pi dkafe_bin
sudo chmod -R 777 dkafe_bin

# 4) Run Python scipt for optional setup
sudo python3 /home/pi/dkafe_bin/rpi4/dkafe_install.py