echo **** remove existing build folders ****
rmdir build /s /Q

echo **** copy program resources ****
xcopy artwork dist\artwork /S /i /Y
xcopy fonts dist\fonts /S /i /Y
xcopy shell dist\shell /S /i /Y
xcopy sounds dist\sounds /S /i /Y
xcopy interface dist\interface /S /i /Y
xcopy patch dist\patch /S /i /Y
copy romlist.csv dist\ /Y
copy settings.txt dist\ /Y
copy readme.md dist\ /Y

echo **** create empty roms folder
xcopy roms\---* dist\roms /S /i /Y


echo **** build the exe in virtual environment ****
venv\Scripts\pyinstaller launch.py --onefile --clean --console --icon artwork\dkafe.ico

echo **** clean up
rmdir build /s /Q
del *.spec