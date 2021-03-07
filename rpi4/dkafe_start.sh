# Run this script to start DKAFE
#
# Set screen resolution and launch DKAFE
xrandr -s 640x480 --output HDMI-1 --scale 1x0.8

# Run the binary from dkafe_bin folder
cd /home/pi/dkafe_bin
./launch

# or via Python interpreter from dkafe (sources) folder
#cd /home/pi/dkafe
#python3 launch.py
