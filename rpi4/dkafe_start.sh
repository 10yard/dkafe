#
#  D  K  A  F  E  -  Donkey Kong Arcade Frontend by Jon Wilson
#
# ----------------------------------------------------------------------------------------------
#  DKAFE Start Script
#
#  Run this script to start DKAFE.
#  i.e. /home/pi/dkafe_bin/dkafe_start.sh
#  ---------------------------------------------------------------------------------------------
#
# Set screen resolution and scale
xrandr --output HDMI-1 --auto
xrandr --output HDMI-1 --mode 640x480 --scale 1x1

# Disable screen blanking
sudo xset s off
sudo xset -dpms
sudo xset s noblank

# Run the binary from dkafe_bin folder
cd /home/pi/dkafe_bin
./launch