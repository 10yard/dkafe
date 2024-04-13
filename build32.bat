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

echo **** export the system architecture to file
echo win32 > dist\ARCH


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

echo **** adjust controller defaults for some consoles
xcopy dkwolf\cfg\nes.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\coleco.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\a7800.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\a800xl.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\fds.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\gameboy.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\gbcolor.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\intv.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\hbf900a.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\ti99_4a.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\coco3.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\apple2e.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\bbcb.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\c64.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\c64p.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\pet4032.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\dragon32.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\snes.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\adam.cfg dist\dkwolf\cfg\ /S /i /Y
xcopy dkwolf\cfg\spectrum_*.cfg dist\dkwolf\cfg\ /Y
xcopy dkwolf\cfg\oric1_*.cfg dist\dkwolf\cfg\ /Y
xcopy dkwolf\cfg\gnw_*.cfg dist\dkwolf\cfg\ /Y
xcopy dkwolf\cfg\vic20_*.cfg dist\dkwolf\cfg\ /Y

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

:abort
echo End