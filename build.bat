echo **** remove existing build folders ****
rmdir build /s /Y
rmdir dist /s /Y

echo **** copy program resources ****
xcopy artwork dist\artwork /S /i /Y
xcopy fonts dist\fonts /S /i /Y
xcopy shell dist\shell /S /i /Y
xcopy sounds dist\sounds /S /i /Y
copy romlist.txt dist\ /Y
copy settings.txt dist\ /Y
copy readme.md dist\ /Y

echo **** build the exe in virtual environment ****
venv\Scripts\pyinstaller launch.py --onefile --clean --console --icon artwork\dkafe.ico

echo **** clean up
rmdir build /s /Y
del *.spec