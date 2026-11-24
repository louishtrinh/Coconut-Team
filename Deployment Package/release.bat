@echo off
setlocal

rem ============================================================
rem  release.bat - publishes this project to a shared folder  (Windows)
rem
rem  Double-click it. It asks where to release; Enter reuses the
rem  last location, saved in release.cfg next to this file.
rem  Copies only what the PCs need: src\ python\ Launch.bat deploy.bat
rem  Every PC picks up the new code the next time it launches.
rem ============================================================

set "HERE=%~dp0"
set "CFG=%HERE%release.cfg"
set "DEPLOY=%HERE%Deployment Package\deploy.bat"
set "LAST="

if not exist "%HERE%src\main.py" echo No src\main.py next to this file - nothing to release. & goto done
if not exist "%DEPLOY%" echo Missing "%DEPLOY%" - copy the Deployment Package back into this project. & goto done

if exist "%CFG%" set /p LAST=<"%CFG%"
if defined LAST set "LAST=%LAST:"=%"

:ask
set "DEST="
if defined LAST set /p "DEST=Release to [%LAST%] (Enter = same): "
if not defined LAST set /p "DEST=Release to (shared folder, e.g. \\server\share\MyApp): "
if not defined DEST set "DEST=%LAST%"
if not defined DEST goto ask
set "DEST=%DEST:"=%"
if "%DEST:~-1%"=="\" set "DEST=%DEST:~0,-1%"
if /i "%DEST%\"=="%HERE%" echo That is this project folder - pick the shared folder. & goto ask
if not exist "%DEST%\" mkdir "%DEST%" 2>nul
if not exist "%DEST%\" echo Cannot reach or create "%DEST%" & goto ask
>"%CFG%" echo("%DEST%"

echo.
echo Releasing to "%DEST%"
rem /MIR only inside DEST\src and DEST\python, so a mistyped location
rem can never delete anything else there. /R:2 /W:2 = don't hang on a locked file.
robocopy "%HERE%src" "%DEST%\src" /MIR /XD __pycache__ /XF *.pyc .gitkeep /R:2 /W:2 /NJH /NJS /NFL /NDL /NP >nul
if errorlevel 8 echo   [FAIL] could not copy src\ & goto done
echo   [ok]   src\

if not exist "%HERE%python\python.exe" echo   [skip] no python\ here - deploy.bat will need internet at each PC & goto files
robocopy "%HERE%python" "%DEST%\python" /MIR /R:2 /W:2 /NJH /NJS /NFL /NDL /NP >nul
if errorlevel 8 echo   [FAIL] could not copy python\ & goto done
echo   [ok]   python\

:files
copy /y "%HERE%Launch.bat" "%DEST%\Launch.bat" >nul || (echo   [FAIL] could not copy Launch.bat & goto done)
copy /y "%DEPLOY%" "%DEST%\deploy.bat" >nul || (echo   [FAIL] could not copy deploy.bat & goto done)
echo   [ok]   Launch.bat, deploy.bat

echo.
echo Released. PCs already deployed get it at their next launch.
echo New PC: open "%DEST%" and double-click deploy.bat.

:done
echo.
pause
endlocal
