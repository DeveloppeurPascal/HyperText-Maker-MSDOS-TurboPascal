@echo off
set code=mkht
mkmsg mkht.txt mkht.msg
txt2htd hypertxt
lha a c:\olf_soft\lzh\%code% htmenu.bat *.exe hypertxt.txt hypertxt.htd
lha a c:\olf_soft\lzh\%code% setup.cfg mkht.msg c:\prg\others\divers\setdflt.exe
set code=
echo on
