echo
echo  DKAFE by Jon Wilson (10yard)
echo
echo ----------------------------------------------------------------------------------------------
echo  Build and package the Windows x64 binary release (and add-ons)
echo ----------------------------------------------------------------------------------------------

echo **** remove existing build folders ****
rmdir build /s /Q
rmdir dist /s /Q

echo **** copy program resources ****
xcopy artwork dist\artwork /S /i /Y
xcopy fonts dist\fonts /S /i /Y
xcopy shell dist\shell /S /i /Y
xcopy sounds dist\sounds /S /i /Y
xcopy interface dist\interface /S /i /Y
xcopy patch dist\patch /S /i /Y
xcopy playlist dist\playlist /S /i /Y
copy romlist.csv dist\ /Y
copy settings.txt dist\ /Y
copy readme.md dist\ /Y
copy VERSION dist\ /Y
copy COPYING dist\ /Y

echo **** export the system architecture to file
echo win64 > dist\ARCH

echo **** clear the snaps folder
del dist\artwork\snap\*.png /Q

echo **** create empty roms folder
xcopy roms\---* dist\roms /S /i /Y

echo **** create minimal dkwolf folder
xcopy dkwolf\dkwolf.exe dist\dkwolf\ /Y
xcopy dkwolf\*.txt dist\dkwolf\ /Y
xcopy dkwolf\*.md dist\dkwolf\ /Y
xcopy dkwolf\plugins dist\dkwolf\plugins /S /i /Y
xcopy dkwolf\changes dist\dkwolf\changes /S /i /Y
rmdir dist\dkwolf\inp /s /Q

echo **** adjust controller defaults for some consoles
xcopy dkwolf\cfg\nes.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\coleco.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\a7800.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\a800xl.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\fds.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\gameboy.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\gbcolor.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\intv.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\ti99_4a.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\coco3.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\apple2e.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\bbcb.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\pet4032.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\snes.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\dragon32.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\adam.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\c64_*.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\c64p_*.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\hbf900a_*.cfg dist\dkwolf\cfg\ /Y
xcopy dkwolf\cfg\spectrum_*.cfg dist\dkwolf\cfg\ /Y
xcopy dkwolf\cfg\oric1_*.cfg dist\dkwolf\cfg\ /Y
xcopy dkwolf\cfg\gnw_*.cfg dist\dkwolf\cfg\ /Y
xcopy dkwolf\cfg\vic20_*.cfg dist\dkwolf\cfg\ /Y

echo **** remove unwanted plugin files for this system
del dist\dkwolf\plugins\galakong\bin\wavplayxp.exe
rmdir dist\dkwolf\plugins\allenkong\binxp /s /Q

echo **** build the exe in virtual environment ****
venv\Scripts\pyinstaller launch.py --onefile --clean --console --icon artwork\dkafe.ico

echo **** clean up
rmdir build /s /Q
del *.spec

echo **** package into a release ZIP getting the version from version.txt
set /p version=<VERSION
set zip_path="C:\Program Files\7-Zip\7z"
del releases\dkafe_win64_binary_%version%.zip
%zip_path% a releases\dkafe_win64_binary_%version%.zip .\dist\*

echo ----------------------------------------------------------------------------------------------
echo  Package the Console Add-On Pack
echo ----------------------------------------------------------------------------------------------
xcopy roms\a2600 dist\console_addon\roms\a2600 /S /i /Y
xcopy roms\a5200 dist\console_addon\roms\a5200 /S /i /Y
xcopy roms\a7800 dist\console_addon\roms\a7800 /S /i /Y
xcopy roms\a800xl dist\console_addon\roms\a800xl /S /i /Y
xcopy roms\coleco dist\console_addon\roms\coleco /S /i /Y
xcopy roms\fds dist\console_addon\roms\fds /S /i /Y
xcopy roms\gameboy dist\console_addon\roms\gameboy /S /i /Y
xcopy roms\gbcolor dist\console_addon\roms\gbcolor /S /i /Y
xcopy roms\nes dist\console_addon\roms\nes /S /i /Y
xcopy roms\intv dist\console_addon\roms\intv /S /i /Y
xcopy roms\hbf900a dist\console_addon\roms\hbf900a /S /i /Y
xcopy roms\ti99_4a dist\console_addon\roms\ti99_4a /S /i /Y
xcopy roms\coco3 dist\console_addon\roms\coco3 /S /i /Y
xcopy roms\cpc6128 dist\console_addon\roms\cpc6128 /S /i /Y
xcopy roms\apple2e dist\console_addon\roms\apple2e /S /i /Y
xcopy roms\bbcb dist\console_addon\roms\bbcb /S /i /Y
xcopy roms\c64 dist\console_addon\roms\c64 /S /i /Y
xcopy roms\c64p dist\console_addon\roms\c64p /S /i /Y
xcopy roms\pet4032 dist\console_addon\roms\pet4032 /S /i /Y
xcopy roms\spectrum dist\console_addon\roms\spectrum /S /i /Y
xcopy roms\snes dist\console_addon\roms\snes /S /i /Y
xcopy roms\oric1 dist\console_addon\roms\oric1 /S /i /Y
xcopy roms\dragon32 dist\console_addon\roms\dragon32 /S /i /Y
xcopy roms\adam dist\console_addon\roms\adam /S /i /Y
xcopy roms\pc dist\console_addon\roms\pc /S /i /Y
xcopy roms\dos dist\console_addon\roms\dos /S /i /Y
xcopy roms\gnw dist\console_addon\roms\gnw /S /i /Y
xcopy roms\lcd dist\console_addon\roms\lcd /S /i /Y
xcopy roms\vic20 dist\console_addon\roms\vic20 /S /i /Y
copy romlist_addon.csv dist\console_addon\ /Y
xcopy dkwolf\artwork dist\console_addon\dkwolf\artwork /S /i /Y

echo **** Include arcade in the addon pack to allow complete frontend setup from the single zip
copy roms\dkong.zip dist\console_addon\roms\ /Y
copy roms\dkongjr.zip dist\console_addon\roms\ /Y
copy roms\dkong3.zip dist\console_addon\roms\ /Y

echo **** Bonus roms includes with the addon pack
copy roms\logger.zip dist\console_addon\roms\ /Y
copy roms\congo.zip dist\console_addon\roms\ /Y

del releases\add-ons\dkafe_console_addon_windows_%version%.zip
%zip_path% a releases\add-ons\dkafe_console_addon_pack_v1.zip .\dist\console_addon\*
