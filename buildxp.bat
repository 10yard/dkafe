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
pyinstaller launch.py --onedir --clean --console --icon artwork\dkafe.ico --name launchxp

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
xcopy playlist dist\launchxp\playlist /S /i /Y
copy settings.txt dist\launchxp\ /Y
copy readme.md dist\launchxp\ /Y
copy VERSION dist\launchxp\ /Y
copy COPYING dist\launchxp\ /Y

echo *** remove the not supported ckong and bigkong from the default romlist.csv when copying
type romlist.csv | findstr /v ckong | findstr /v bigkong > dist\launchxp\romlist.csv

echo **** create empty roms folder
xcopy roms\---* dist\launchxp\roms /S /i /Y

echo **** create minimal dkwolf folder
xcopy dkwolf\dkwolfxp.exe dist\launchxp\dkwolf\dkwolf.exe* /Y
xcopy dkwolf\*.txt dist\launchxp\dkwolf\ /Y
xcopy dkwolf\*.md dist\launchxp\dkwolf\ /Y
xcopy dkwolf\plugins dist\launchxp\dkwolf\plugins /S /i /Y
xcopy dkwolf\changes dist\launchxp\dkwolf\changes /S /i /Y
copy dkwolf\plugins\galakong\bin\wavplayxp.exe dist\launchxp\dkwolf\plugins\galakong\bin\wavplay.exe /Y
rmdir dist\dkwolf\inp /s /Q

echo *** pull in plugin dependencies from Wolfmame 196 overwriting DKAFE default
xcopy C:\wolfmame_0196\plugins dist\launchxp\dkwolf\plugins /S /i /Y

echo **** clean up
rmdir build /s /Q
del /q *.spec

echo **** package into a release ZIP getting the version from version.txt
del /q releases\dkafe_winxp_binary_%version%.zip
%zip_path% a releases\dkafe_winxp_binary_%version%.zip .\dist\launchxp\*

:abort
echo End