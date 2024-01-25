echo
echo  DKAFE by Jon Wilson (10yard)
echo
echo ----------------------------------------------------------------------------------------------
echo  Build and package the Windows x86 (32 bit) binary release
echo  NOTES:
echo    The build should be done on a 32bit machine.
echo ----------------------------------------------------------------------------------------------
echo

@echo off
set /p _check=Recommend build is done on 32bit machine.  Do you wish to proceed? [Y/N]: 
if %_check% NEQ Y GOTO abort
echo Start Build

echo **** set up environment
set /p version=<VERSION
set zip_path="C:\Program Files\7-Zip\7z"

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

echo **** clear the snaps folder
del dist\artwork\snap\*.png /Q

echo **** create empty roms folder
xcopy roms\---* dist\roms /S /i /Y

echo **** create minimal dkwolf folder
xcopy dkwolf\dkwolf32.exe dist\dkwolf\dkwolf.exe* /Y
xcopy dkwolf\*.txt dist\dkwolf\ /Y
xcopy dkwolf\*.md dist\dkwolf\ /Y
xcopy dkwolf\plugins dist\dkwolf\plugins /S /i /Y
xcopy dkwolf\changes dist\dkwolf\changes /S /i /Y
rmdir dist\dkwolf\inp /s /Q

echo **** remove unwanted plugin files for this system
del dist\dkwolf\plugins\galakong\bin\wavplayxp.exe
rmdir dist\dkwolf\plugins\allenkong\binxp /s /Q

echo **** build the exe in virtual environment ****
venv32\Scripts\pyinstaller launch.py --onefile --clean --console --icon artwork\dkafe.ico --name launch32

echo **** clean up
rmdir build /s /Q
del *.spec

echo **** package into a release ZIP getting the version from version.txt
del releases\dkafe_win32_binary_%version%.zip
%zip_path% a releases\dkafe_win32_binary_%version%.zip .\dist\*

echo ----------------------------------------------------------------------------------------------
echo  Package the Console Add-On Pack
echo ----------------------------------------------------------------------------------------------
xcopy roms\a2600 dist\console_addon\roms\a2600 /S /i /Y
xcopy roms\nes dist\console_addon\roms\nes /S /i /Y
copy romlist_addon.csv dist\console_addon\ /Y

del releases\add-ons\dkafe_console_addon_windows_%version%.zip
%zip_path% a releases\add-ons\dkafe_console_addon_windows_%version%.zip .\dist\console_addon\*

:abort
echo End