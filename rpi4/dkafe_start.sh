#  ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
#   888    88o  888  o88        888       888          888
#   888    888  888888         8  88      888ooo8      888ooo8
#   888    888  888  88o      8oooo88     888          888
#  o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
#                                          by Jon Wilson (10yard)
#
#  Run this script to start DKAFE on Raspberry Pi4
#  i.e. /home/pi/dkafe_bin/dkafe_start.sh
#

# Stop the composition manager
killall xcompmgr

# Disable screen blanking
sudo xset s off
sudo xset -dpms
sudo xset s noblank

# Run the python script or binary from dkafe_bin folder
cd /home/pi/dkafe_bin
#./launch >nul 2>&1
python3 launch.py >nul 2>&1
