#
#  D  K  A  F  E  -  Donkey Kong Arcade Frontend by Jon Wilson
#
# ----------------------------------------------------------------------------------------------
#  Build and package the Windows x64 binary release
# ----------------------------------------------------------------------------------------------
#  Raspberry Pi Build Script
# ----------------------------------------------------------------------------------------------
#  Refer to rpi4_notes for info on settng up pyinstaller
#  Dependenices will be needed:
#    sudo apt-get install python3-pip zip
#    pip3 install -r requirements.txt
# ----------------------------------------------------------------------------------------------

# remove existing build folders
sudo rm -r -f /home/pi/dkafe_bin

# set full permission on sources
cd /home/pi
sudo chown -R pi:pi dkafe
sudo chmod -R 777 dkafe

cd /home/pi/dkafe
sudo rm -r -f dist
sudo rm -r -f build

# build the application binary
sudo pyinstaller launch.py --onefile --clean --noconsole

# copy program resources
sudo cp -r artwork dist
sudo cp -r fonts dist
sudo cp -r shell dist
sudo cp -r sounds dist
sudo cp -r interface dist
sudo cp -r patch dist
sudo cp -r rpi4 dist
sudo cp romlist.csv dist
sudo cp readme.md dist
sudo cp VERSION dist
sudo cp COPYING dist

# copy rpi4 specific settings
sudo cp rpi4/settings.txt dist
sudo cp rpi4/dkafe_start.sh dist

# create empty roms folder
sudo mkdir dist/roms
sudo cp roms/---* dist/roms

# create minimal dkwolf folder
sudo mkdir dist/dkwolf
sudo cp dkwolf/dkwolfrpi dist/dkwolf
sudo cp dkwolf/playback.bat dist/dkwolf
sudo cp -r dkwolf/*.txt dist/dkwolf
sudo cp -r dkwolf/*.md dist/dkwolf
sudo cp -r dkwolf/plugins dist/dkwolf
sudo cp -r dkwolf/changes dist/dkwolf

# Grant all permissions on dist
sudo chown -R pi:pi dist
sudo chmod -R 777 dist

# Move binaries to /home/pi
mv dist /home/pi/dkafe_bin

# Clean up
sudo rm -r build

# package it all up into a versioned ZIP for easy distribution
version=$(cat /home/pi/dkafe/VERSION)
cd /home/pi
zip -r /home/pi/dkafe_rpi4_binary_${version}.zip dkafe_bin
cd /home/pi/dkafe/rpi4
zip -r /home/pi/dkafe_rpi4_binary_${version}.zip dkafe_install.sh
zip -r /home/pi/dkafe_rpi4_binary_${version}.zip readme.txt
