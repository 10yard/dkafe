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
mkdir dist\roms
type NUL > "dist\roms\---Place dkong.zip file into this folder---"

echo **** create minimal dkwolf folder
xcopy dkwolf\dkwolf32.exe dist\dkwolf\dkwolf.exe* /Y
xcopy dkwolf\*.txt dist\dkwolf\ /Y
xcopy dkwolf\*.md dist\dkwolf\ /Y
xcopy dkwolf\plugins dist\dkwolf\plugins /S /i /Y
xcopy dkwolf\changes dist\dkwolf\changes /S /i /Y
xcopy dkwolf\hash dist\dkwolf\hash /S /i /Y
rmdir dist\dkwolf\inp /s /Q

echo **** define systems to be included in the add-on pack
set systems=a2600,a5200,a7800,a800xl,adam,apfimag,apple2e,bbcb,c64,c64p,cgenie,coco3,coleco,cpc6128,crvision,dos,dragon32,fds,gameboy,gbcolor,genesis,gnw,hbf900a,jupace,intv,laser310,lcd,mo5,mz700,nes,oric1,orica,pc,pcw10,pet4032,plus4,sg1000,smskr,snes,spectrum,spec128,ti99_4a,vic20,vic20_se,x1,zx81

echo **** adjust controller defaults for some consoles
for %%s in (%systems%) do xcopy dkwolf\cfg\%%s*.cfg dist\dkwolf\cfg\ /Y

echo **** remove unwanted plugin files for this system
del dist\dkwolf\plugins\galakong\bin\wavplayxp.exe
rmdir dist\dkwolf\plugins\allenkong\binxp /s /Q

echo **** build the exe in virtual environment ****
set PYTHONOPTIMIZE=1
venv32\Scripts\pyinstaller launch.py --onefile --clean --noconsole --icon artwork\dkafe.ico --name launch32 --hidden-import charset_normalizer.md__mypyc

echo **** clean up
rmdir build /s /Q
del *.spec

echo 
echo --------------------------------------------------------------
echo -   Sign executables on host machine with build_sign32.bat   -
echo -     (or skip this step by pressing a key)                       -  
echo --------------------------------------------------------------
timeout 300

echo **** package into a release ZIP getting the version from version.txt
del releases\dkafe_win32_binary_%version%.zip
%zip_path% a releases\dkafe_win32_binary_%version%.zip .\dist\*

:abort
echo End