#  ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
#   888    88o  888  o88        888       888          888
#   888    888  888888         8  88      888ooo8      888ooo8
#   888    888  888  88o      8oooo88     888          888
#  o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
#                                          by Jon Wilson (10yard)
#
#  Assisted install script for Raspberry Pi4
#  -----------------------------------------
#
#  You will need to extract all contents of the DKAFE binary release zip file
#  to the /boot partition and then run this script.
#
#  i.e. /boot/dkafe_install.sh
# ----------------------------------------------------------------------------

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