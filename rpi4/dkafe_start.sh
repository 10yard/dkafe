# Run this script to start DKAFE
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