echo
echo  DKAFE by Jon Wilson (10yard)
echo
echo -----------------------------------------------------------------------------------------------
echo  Build and package the Windows XP binary release
echo  NOTES: 
echo    Built using a backport of Python37 for XP
echo    No virtual environment is used
echo    No support for --onefile on XP so files are bundled by pyinstaller with --onedir
echo    Python base library files are not bundled by default so this script looks for them in
echo      C:\python_base_library
echo -----------------------------------------------------------------------------------------------
echo

@echo off
set /p _check=Build should be done on XP.  Do you wish to proceed? [Y/N]: 
if %_check% NEQ Y GOTO abort
echo Start Build

echo **** Set up environment ****
set /p version=<VERSION
set zip_path="C:\Program Files\7-Zip\7z"

echo **** remove existing build folders ****
rmdir build /s /Q
rmdir dist /s /Q

echo **** build the exe ****
pyinstaller launch.py --onedir --clean --console --icon artwork\dkafe.ico --name launchxp --exclude-module rotate-screen

echo **** copy python dependencies ****
echo **** these are files from the base_library.zip ****
xcopy C:\python_base_library dist\launchxp  /E /H /C /I /Y
del /q dist\launchxp\base_library.zip

echo **** copy program resources ****
xcopy artwork dist\launchxp\artwork /S /i /Y
xcopy fonts dist\launchxp\fonts /S /i /Y
xcopy shell dist\launchxp\shell /S /i /Y
xcopy sounds dist\launchxp\sounds /S /i /Y
xcopy interface dist\launchxp\interface /S /i /Y
xcopy patch dist\launchxp\patch /S /i /Y
xcopy xp\playlist dist\launchxp\playlist /S /i /Y
copy romlist.csv dist\launchxp\ /Y
copy settings.txt dist\launchxp\ /Y
copy readme.md dist\launchxp\ /Y
copy VERSION dist\launchxp\ /Y
copy COPYING dist\launchxp\ /Y

echo **** export the system architecture to file
echo winxp > dist\launchxp\ARCH

echo **** create empty roms folder
mkdir dist\roms
type NUL > "dist\roms\---Place dkong.zip file into this folder---"

echo **** create minimal dkwolf folder
xcopy dkwolf\dkwolfxp.exe dist\launchxp\dkwolf\dkwolf.exe* /Y
xcopy dkwolf\*.txt dist\launchxp\dkwolf\ /Y
xcopy dkwolf\*.md dist\launchxp\dkwolf\ /Y
xcopy dkwolf\plugins dist\launchxp\dkwolf\plugins /S /i /Y
xcopy dkwolf\changes dist\launchxp\dkwolf\changes /S /i /Y
rmdir dist\launchxp\dkwolf\inp /s /Q

echo **** define systems to be included in the add-on pack
set systems=a2600,a5200,a7800,a800xl,adam,apple2e,bbcb,c64,c64p,coco3,coleco,cpc6128,crvision,dos,dragon32,fds,gameboy,gbcolor,genesis,gnw,hbf900a,intv,lcd,mo5,mz700,nes,oric1,orica,pc,pcw10,pet4032,plus4,sg1000,smskr,snes,spectrum,spec128,ti99_4a,vic20,vic20_se,x1,zx81

echo **** adjust controller defaults for some consoles
for %%s in (%systems%) do xcopy dkwolf\cfg\%%s*.cfg dist\dkwolf\cfg\ /Y

echo **** Use an alternative wav/mp3 player on XP
copy dkwolf\plugins\galakong\bin\wavplayxp.exe dist\launchxp\dkwolf\plugins\galakong\bin\wavplay.exe /Y
copy dkwolf\plugins\allenkong\binxp\mp3play*.exe dist\launchxp\dkwolf\plugins\allenkong\bin /Y
rmdir dist\launchxp\dkwolf\plugins\allenkong\binxp /s /Q

echo **** clean up
rmdir build /s /Q
del /q *.spec

echo **** package into a release ZIP getting the version from version.txt
del /q releases\dkafe_winxp_binary_%version%.zip
%zip_path% a releases\dkafe_winxp_binary_%version%.zip .\dist\launchxp\*

:abort
echo End