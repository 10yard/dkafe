# Refer to rpi_notes.txt
#
# Set screen resolution and launch DKAFE
xrandr -s 640x480 --output HDMI-1 --scale 1x0.8
cd /home/pi/dkafe

# Run the binary or via Python interpreter
./launch
#python3 launch.py
