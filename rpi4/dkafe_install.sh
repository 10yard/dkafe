#  ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
#   888    88o  888  o88        888       888          888
#   888    888  888888         8  88      888ooo8      888ooo8
#   888    888  888  88o      8oooo88     888          888
#  o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
#                                          by Jon Wilson (10yard)
#
#  Assisted install script for Raspberry Pi4
# ----------------------------------------------------------------------------

echo "ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo"
echo " 888    88o  888  o88        888       888          888"
echo " 888    888  888888         8  88      888ooo8      888ooo8"
echo " 888    888  888  88o      8oooo88     888          888"
echo "o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888"
echo "INSTALL OPTIONS                         by Jon Wilson (10yard)"
echo ""

read -p "Press any key to proceed with install"
echo
echo "Preparing files,  please wait..."

# 1) Install DKAFE to /home/pi/dkafe_bin folder
sudo cp -r /boot/dkafe_bin /home/pi

# 2) Copy dkong roms (if found in /boot partition)
sudo cp -f /boot/dkong.zip /home/pi/dkafe_bin/roms 2>/dev/null
sudo cp -f /boot/dkongjr.zip /home/pi/dkafe_bin/roms 2>/dev/null

# 3) Grant all permissions
cd /home/pi
sudo chown -R pi:pi dkafe_bin
sudo chmod -R 777 dkafe_bin

# 4) Remove the first boot script
sudo rm /etc/xdg/autostart/firstboot.desktop 2>/dev/null

# 5) Run Python script for optional setup
sudo python3 /home/pi/dkafe_bin/rpi4/dkafe_install.py
