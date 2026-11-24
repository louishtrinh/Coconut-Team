@echo off
setlocal

rem ============================================================
rem  deploy.bat - sets up this PC to run the program  (Windows)
rem
rem  Double-click it from the shared release folder, press Enter.
rem  The PC gets Python, Launch.bat and launch.cfg. The code stays
rem  on the share, so new releases need no redeploy.
rem ============================================================

set "SHARE=%~dp0"
set "SHARE=%SHARE:~0,-1%"
set "NAME="
for %%I in ("%SHARE%") do set "NAME=%%~nxI"
if not defined NAME set "NAME=Program"
set "PYVER=3.11.9"
set "PYURL=https://www.python.org/ftp/python/3.11.9/python-3.11.9-embed-amd64.zip"

if not exist "%SHARE%\src\main.py" echo No src\main.py here - run deploy.bat from the release folder. & goto done

:ask
set "DEST="
set /p "DEST=Install %NAME% on this PC to [C:\%NAME%] (Enter = same): "
if not defined DEST set "DEST=C:\%NAME%"
set "DEST=%DEST:"=%"
if "%DEST:~-1%"=="\" set "DEST=%DEST:~0,-1%"
if /i "%DEST%"=="%SHARE%" echo That is the release folder - pick a folder on this PC. & goto ask
if not exist "%DEST%\" mkdir "%DEST%" 2>nul
if not exist "%DEST%\" echo Cannot create "%DEST%" & goto ask

echo.
echo Installing to "%DEST%"

rem ---- Python: download it, or copy it from the share if offline ----
if exist "%DEST%\python\python.exe" echo   [skip] Python already installed & goto files
mkdir "%DEST%\python" 2>nul
echo   ....   downloading Python %PYVER%
rem Paths reach PowerShell through the environment, never inside the code string.
set "PYDIR=%DEST%\python"
powershell -NoProfile -Command "$ProgressPreference='SilentlyContinue'; $z=Join-Path $env:PYDIR 'python-embed.zip'; try { Invoke-WebRequest -Uri $env:PYURL -OutFile $z -UseBasicParsing; Expand-Archive -Path $z -DestinationPath $env:PYDIR -Force } catch { } finally { Remove-Item $z -ErrorAction SilentlyContinue }" 2>nul
if exist "%PYDIR%\python.exe" echo   [ok]   Python %PYVER% downloaded & goto files

echo   ....   no download - copying Python from the release folder
if not exist "%SHARE%\python\python.exe" echo   [FAIL] no Python in the release folder either - Launch.bat will try the Python on PATH. & goto files
robocopy "%SHARE%\python" "%PYDIR%" /E /R:2 /W:2 /NJH /NJS /NFL /NDL /NP >nul
if exist "%PYDIR%\python.exe" (echo   [ok]   Python copied from the release folder) else (echo   [FAIL] could not copy Python - Launch.bat will try the Python on PATH.)

:files
copy /y "%SHARE%\Launch.bat" "%DEST%\Launch.bat" >nul || (echo   [FAIL] could not copy Launch.bat & goto done)
rem Launch.bat finds no src\ next to itself, so it reads this: the code on the share.
>"%DEST%\launch.cfg" echo("%SHARE%\src\main.py"
echo   [ok]   Launch.bat, linked to "%SHARE%"

echo.
echo Done. To start the program: double-click Launch.bat in "%DEST%"

:done
echo.
pause
endlocal
