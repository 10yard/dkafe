# RPI build script
# Refer to rpi4_notes for info on settng up pyinstaller

# remove existing build folders
sudo rm -r dist
sudo rm -r build
sudo mkdir dist

# copy program resources
sudo cp -r artwork dist/artwork
sudo cp -r fonts dist/fonts
sudo cp -r shell dist/shell
sudo cp -r sounds dist/sounds
sudo cp -r interface dist/interface
sudo cp -r patch dist/patch
sudo cp romlist.csv dist/romlist.csv
sudo cp settings.txt dist/settings.txt
sudo cp readme.md dist/settings.txt

# create empty roms folder
sudo mkdir dist/roms
sudo cp roms/---* dist/roms

# create minimal dkmame folder
sudo cp dkwolf/dkwolfrpi dist/dkwolfrpi
sudo cp dkwolf/playback.bat dist/dkwolf/playback.bat
sudo cp -r dkwolf/*.txt dist/dkwolf
sudo cp -r dkwolf/*.md dist/dkwolf
sudo cp -r dkwolf/plugins dist/dkwolf/plugins
sudo cp -r dkwolf/changes dist/dkwolf/changes

# build the application binary
sudo pyinstaller launch.py --onefile --clean --noconsole
sudo cp launch /dist/launch

#clean up
sudo rm -r build