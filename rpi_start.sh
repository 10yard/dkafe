# Refer to rpi_notes.txt
#
# Set screen resolution and launch DKAFE
xrandr -s 640x480 --output HDMI-1 --scale 1x0.8
cd /home/pi/dkafe
python3 launch.py