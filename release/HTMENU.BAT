echo off
rem
rem HTMENU.BAT
rem Patrick Premartin 30/12/1991.
rem
olf_pres %1 %2 %3 %4 %5 %6 %7 %8 %9
:debut
echo                     Hyper Text Maker (› Patrick Premartin 1991).
echo ÿ
echo A - Page editor.
echo B - Linker.
echo C - Install.
echo ÿ
echo ESC - Exit.
echo Your choice ?
choix
if errorlevel 27 if not errorlevel 28 goto fin
if not errorlevel 65 goto debut
if errorlevel 68 goto debut
if errorlevel 67 goto C
if errorlevel 66 goto B
if errorlevel 65 goto A
goto debut
:A
htedit %1 %2 %3 %4 %5 %6 %7 %8 %9
goto debut
:B
htlink %1 %2 %3 %4 %5 %6 %7 %8 %9
goto debut
:C
htinstal %1 %2 %3 %4 %5 %6 %7 %8 %9
goto debut
:fin
echo on
