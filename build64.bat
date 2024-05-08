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

echo **** define systems to be included in the add-on pack
set systems=a2600,a5200,a7800,a800xl,adam,apple2e,bbcb,c64,c64p,coco3,coleco,cpc6128,crvision,dos,dragon32,fds,gameboy,gbcolor,genesis,gnw,hbf900a,intv,lcd,mz700,nes,oric1,pc,pet4032,plus4,snes,spectrum,ti99_4a,vic20,zx81

echo **** adjust controller defaults for some consoles
for %%s in (%systems%) do xcopy dkwolf\cfg\%%s*.cfg dist\dkwolf\cfg\ /Y

echo **** remove unwanted plugin files for this system
del dist\dkwolf\plugins\galakong\bin\wavplayxp.exe
rmdir dist\dkwolf\plugins\allenkong\binxp /s /Q

echo **** build the exe in virtual environment ****
venv64\Scripts\pyinstaller launch.py --onefile --clean --noconsole --icon artwork\dkafe.ico
venv64\Scripts\pyinstaller remap_pc.py --onefile --clean --noconsole

echo **** clean up
rmdir build /s /Q
del *.spec

echo **** Code sign program executables with Open Source Developer Certificate
"C:\Program Files (x86)\Windows Kits\10\bin\x86\signtool" sign /tr http://timestamp.digicert.com /n "Open Source Developer" dist\launch.exe dist\remap_pc.exe dist\dkwolf\dkwolf.exe

echo **** package into a release ZIP getting the version from version.txt
set /p version=<VERSION
set zip_path="C:\Program Files\7-Zip\7z"
del releases\dkafe_win64_binary_%version%.zip
%zip_path% a releases\dkafe_win64_binary_%version%.zip .\dist\*

echo ----------------------------------------------------------------------------------------------
echo  Package the Console Add-On Pack
echo ----------------------------------------------------------------------------------------------
for %%s in (%systems%) do xcopy roms\%%s dist\console_addon\roms\%%s /S /i /Y

copy romlist_addon.csv dist\console_addon\ /Y
xcopy dkwolf\artwork dist\console_addon\dkwolf\artwork /S /i /Y

echo **** Include arcade in the addon pack to allow complete frontend setup from the single zip
copy roms\dkong.zip dist\console_addon\roms\ /Y
copy roms\dkongjr.zip dist\console_addon\roms\ /Y
copy roms\dkong3.zip dist\console_addon\roms\ /Y

echo **** Bonus roms includes with the addon pack
copy roms\logger.zip dist\console_addon\roms\ /Y
copy roms\congo.zip dist\console_addon\roms\ /Y

del releases\add-ons\dkafe_console_addon_pack_v1.zip
%zip_path% a releases\add-ons\dkafe_console_addon_pack_v1.zip .\dist\console_addon\*
