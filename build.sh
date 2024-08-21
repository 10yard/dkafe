#
#  DKAFE by Jon Wilson (10yard)
#
# ----------------------------------------------------------------------------------------------
#  Build and package the Raspberry Pi binary release
# ----------------------------------------------------------------------------------------------
#  Refer to rpi4_notes for info on settng up pyinstaller
#  Dependenices will be needed:
#    sudo apt-get install python3-pip zip
#    pip3 install -r requirements.txt
# ----------------------------------------------------------------------------------------------

# remove existing build folders
sudo rm -r -f /home/pi/dkafe_bin
sudo rm -r -f /boot/dkafe_bin

# set full permission on sources
cd /home/pi
sudo chown -R pi:pi dkafe
sudo chmod -R 777 dkafe

cd /home/pi/dkafe
sudo rm -r -f dist
sudo rm -r -f build

# build the application binary
sudo pyinstaller launch.py --onefile --clean --noconsole --exclude-module rotate-screen

# copy program resources
sudo cp -r artwork dist
sudo cp -r fonts dist
sudo cp -r shell dist
sudo cp -r sounds dist
sudo cp -r interface dist
sudo cp -r patch dist
sudo cp -r rpi4 dist
sudo cp -r playlist dist
sudo cp romlist.csv dist
sudo cp readme.md dist
sudo cp VERSION dist
sudo cp COPYING dist

# copy rpi4 specific settings
sudo cp rpi4/settings.txt dist
sudo cp rpi4/dkafe_start.sh dist
sudo cp rpi4/w_enter.sh dist
sudo cp rpi4/w_exit.sh dist

# create empty roms folder
sudo mkdir dist/roms
sudo cp roms/---* dist/roms

# create minimal dkwolf folder
sudo mkdir dist/dkwolf
sudo cp dkwolf/dkwolfrpi dist/dkwolf
sudo cp -r dkwolf/*.txt dist/dkwolf
sudo cp -r dkwolf/plugins dist/dkwolf
sudo cp -r dkwolf/changes dist/dkwolf
sudo cp -r dkwolf/hash dist/dkwolf

# remove unwanted plugin files for this system
sudo rm -r dist/dkwolf/plugins/galakong/bin
sudo rm -r dist/dkwolf/plugins/dkchorus/bin
sudo rm -r dist/dkwolf/plugins/allenkong/binxp

# Grant all permissions on dist
sudo chown -R pi:pi dist
sudo chmod -R 777 dist

# Export the system architecture to file
sudo echo pi &> dist/ARCH

# Launch the installer on first boot
sudo cp rpi4/firstboot.desktop /etc/xdg/autostart

## Move binaries to boot partition
sudo cp -r dist /boot/dkafe_bin

# Clean up
sudo rm -r dist
sudo rm -r build

# Remove log files
sudo rm -r /var/log/*

echo
echo ---- Build Finished ----

# Report free space on disk
echo Free space on disk: 
df -BM /tmp | tail -1 | awk '{print $4}'
echo

# Clear the terminal cache
history -c && history -w