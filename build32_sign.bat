echo
echo  DKAFE by Jon Wilson (10yard)
echo
echo ----------------------------------------------------------------------------------------------
echo  Sign Windows 32bit executables - when build is not performed on host machine.
echo ----------------------------------------------------------------------------------------------

echo **** Code sign program executables with Open Source Developer Certificate
"C:\Program Files (x86)\Windows Kits\10\bin\x86\signtool" sign /tr http://timestamp.apple.com/ts01 /n "Open Source Developer" dist\launch32.exe dist\dkwolf\dkwolf.exe
pause
