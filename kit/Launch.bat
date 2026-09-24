@echo off
setlocal

rem ============================================================
rem  Launch.bat - runs the calculator  (Windows)
rem
rem  Double-click it. The first run asks where main.py lives and
rem  remembers the answer in launch.cfg next to this file.
rem  Delete launch.cfg to be asked again.
rem
rem  Python: the embedded copy in .\python\ if one is there,
rem  otherwise the Python launcher (py), otherwise python on PATH.
rem
rem  Paths are kept inside quotes wherever they are echoed or
rem  saved, so a folder like D:\R&D is read as text, not as two
rem  commands joined by &.
rem ============================================================

set "HERE=%~dp0"
set "CFG=%HERE%launch.cfg"
set "SCRIPT="

rem Rule 11: a program's entry point always lives at src\main.py next to this file.
if exist "%HERE%src\main.py" set "SCRIPT=%HERE%src\main.py" & goto run

if exist "%CFG%" set /p SCRIPT=<"%CFG%"
if defined SCRIPT set "SCRIPT=%SCRIPT:"=%"
if defined SCRIPT if not exist "%SCRIPT%" echo Saved location no longer exists: "%SCRIPT%" & set "SCRIPT="
if defined SCRIPT goto run

:ask
set "SCRIPT="
set /p "SCRIPT=Path to main.py, or its folder (Enter = this folder): "
if not defined SCRIPT set "SCRIPT=%HERE%"
set "SCRIPT=%SCRIPT:"=%"
if exist "%SCRIPT%\main.py" set "SCRIPT=%SCRIPT%\main.py"
if exist "%SCRIPT%\*" if exist "%SCRIPT%\src\main.py" set "SCRIPT=%SCRIPT%\src\main.py"
if not exist "%SCRIPT%" echo Not found: "%SCRIPT%" & goto ask
if exist "%SCRIPT%\*" echo No main.py in "%SCRIPT%" & goto ask
for %%I in ("%SCRIPT%") do if /i not "%%~xI"==".py" echo Not a Python script: "%SCRIPT%" & goto ask
>"%CFG%" echo("%SCRIPT%"
echo Saved to launch.cfg - delete it to choose a different location.
echo.

:run
set "PY="
set "PYARGS="
if exist "%HERE%python\python.exe" set "PY=%HERE%python\python.exe"
if not defined PY where py >nul 2>&1 && set "PY=py" && set "PYARGS=-3"
if not defined PY where python >nul 2>&1 && set "PY=python"
if not defined PY echo Python 3 not found. Install it, or put an embedded copy in "%HERE%python\" & goto done

rem The embeddable build's pythonXY._pth keeps the script's own folder off
rem sys.path, which would break "from calculator import ...". Put it back.
rem The path travels as an argument, never inside the code string.
"%PY%" %PYARGS% -c "import os,sys,runpy; p=os.path.abspath(sys.argv[1]); sys.path.insert(0,os.path.dirname(p)); sys.argv=[p]; runpy.run_path(p,run_name='__main__')" "%SCRIPT%"
if errorlevel 1 goto done
endlocal
exit /b 0

:done
echo.
pause
endlocal
