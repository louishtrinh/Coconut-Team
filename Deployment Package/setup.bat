@echo off
setlocal

rem ============================================================
rem  Coconut Team - per-project setup  (Windows)
rem
rem  Run from anywhere:   setup.bat "C:\path\to\new-project"
rem  Or double-click it and type the path when asked.
rem
rem  Does the things the plugin cannot do for you:
rem    - copies CLAUDE.md
rem    - creates the ownership lanes (docs\design, src, tests)
rem    - adds Prototype/ to .gitignore
rem    - writes .claude\settings.json so cloud sessions load the plugin
rem    - copies Launch.bat and installs embedded Python into python\
rem      (rule 11: setup.bat installs, Launch.bat runs)
rem ============================================================

set "RULES_VERSION=v0.1.0"
set "KIT=%~dp0"
set "MARKET=louishtrinh/Coconut-Team"
rem  Rule 11: Python 3.11.9 embeddable, the version Big Coconut's proven
rem  setup template uses. The program needs only the standard library.
set "PYVER=3.11.9"
set "PYURL=https://www.python.org/ftp/python/3.11.9/python-3.11.9-embed-amd64.zip"

if "%~1"=="" goto ask
set "TARGET=%~1"
goto have
:ask
set /p "TARGET=Path to the project to set up (Enter = the folder this package is in): "
:have
rem a drag-dropped path arrives in quotes; keep paths quoted only where used
if defined TARGET set "TARGET=%TARGET:"=%"

rem This file lives in the project's "Deployment Package" folder, so the
rem project is the folder one level up.
if "%TARGET%"=="" for %%I in ("%KIT%..") do set "TARGET=%%~fI"
if not exist "%TARGET%\" echo. & echo Not found: "%TARGET%" & goto done

echo.
echo Setting up: "%TARGET%"
echo.

rem ---- 1. CLAUDE.md -------------------------------------------------
if exist "%TARGET%\CLAUDE.md" (
  echo   [skip] CLAUDE.md already exists - not overwriting.
  echo          Compare it against "%KIT%CLAUDE.md" ^(rules %RULES_VERSION%^)
) else (
  copy /y "%KIT%CLAUDE.md" "%TARGET%\CLAUDE.md" >nul
  echo   [ok]   CLAUDE.md copied ^(rules %RULES_VERSION%^)
)

rem ---- 2. ownership lanes -------------------------------------------
call :makedir "%TARGET%\docs\design"
call :makedir "%TARGET%\src"
call :makedir "%TARGET%\tests"
call :makedir "%TARGET%\.claude\project"
call :makedir "%TARGET%\Prototype"

rem git will not track an empty folder, so leave a marker in each
call :keep "%TARGET%\docs\design"
call :keep "%TARGET%\src"
call :keep "%TARGET%\tests"

rem ---- 3. .gitignore -------------------------------------------------
if not exist "%TARGET%\.gitignore" type nul > "%TARGET%\.gitignore"
findstr /x /c:"Prototype/" "%TARGET%\.gitignore" >nul 2>&1
if errorlevel 1 (
  >>"%TARGET%\.gitignore" echo Prototype/
  echo   [ok]   .gitignore: added Prototype/
) else (
  echo   [skip] .gitignore: Prototype/ already listed
)
rem /python/ with the leading slash: only the embedded copy at the root,
rem never some other folder that happens to be called python
findstr /x /c:"/python/" "%TARGET%\.gitignore" >nul 2>&1
if errorlevel 1 (
  >>"%TARGET%\.gitignore" echo /python/
  echo   [ok]   .gitignore: added /python/
) else (
  echo   [skip] .gitignore: /python/ already listed
)

rem ---- 4. .claude\settings.json --------------------------------------
if exist "%TARGET%\.claude\settings.json" (
  call :snippet "%TARGET%\.claude\settings.coconut-snippet.json"
  echo   [skip] settings.json exists - wrote settings.coconut-snippet.json
  echo          Merge extraKnownMarketplaces and enabledPlugins by hand.
) else (
  call :snippet "%TARGET%\.claude\settings.json"
  echo   [ok]   .claude\settings.json written
)

rem ---- 5. Launch.bat -------------------------------------------------
if exist "%TARGET%\Launch.bat" (
  echo   [skip] Launch.bat already exists
) else (
  copy /y "%KIT%Launch.bat" "%TARGET%\Launch.bat" >nul
  echo   [ok]   Launch.bat copied
)

rem ---- 6. embedded Python --------------------------------------------
call :python "%TARGET%\python"

echo.
echo Done. Next:
echo.
echo   1^) cd /d "%TARGET%"
echo   2^) git add -A ^&^& git commit -m "Coconut Team setup" ^&^& git push
echo   3^) In Claude Code:  /plugin marketplace add %MARKET%
echo                       /plugin install coconut-team@coconut
echo                       /reload-plugins
echo   4^) Check with /agents - Bob, Daisuki-chan, Hiram, Amy should be listed.
echo.
goto done

rem ---- helpers -------------------------------------------------------
:makedir
if exist "%~1\" (
  echo   [skip] "%~nx1" already exists
) else (
  mkdir "%~1" 2>nul
  echo   [ok]   created "%~1"
)
exit /b

:keep
if not exist "%~1\.gitkeep" type nul > "%~1\.gitkeep"
exit /b

:snippet
> "%~1" echo {
>>"%~1" echo   "extraKnownMarketplaces": {
>>"%~1" echo     "coconut": {
>>"%~1" echo       "source": { "source": "github", "repo": "%MARKET%" }
>>"%~1" echo     }
>>"%~1" echo   },
>>"%~1" echo   "enabledPlugins": {
>>"%~1" echo     "coconut-team@coconut": true
>>"%~1" echo   }
>>"%~1" echo }
exit /b

:python
rem Big Coconut's setup template: download the embeddable zip, extract it
rem through a temp folder, delete the zip. On failure Launch.bat falls back
rem to the Python on PATH.
if exist "%~1\python.exe" (
  echo   [skip] python\ already has python.exe
  exit /b
)
set "PYDEST=%~1"
set "PYZIP=%~1\python-embed.zip"
echo   ....   downloading Python %PYVER%
mkdir "%PYDEST%" 2>nul
powershell -Command "Invoke-WebRequest -Uri '%PYURL%' -OutFile '%PYZIP%'"
if errorlevel 1 (
  echo   [FAIL] could not download Python - Launch.bat will use the Python on PATH instead.
  exit /b
)
echo   ....   extracting Python
powershell -Command "Expand-Archive -Path '%PYZIP%' -DestinationPath '%PYDEST%\temp' -Force; Move-Item '%PYDEST%\temp\*' '%PYDEST%\'; Remove-Item '%PYDEST%\temp' -Recurse -Force"
del "%PYZIP%" 2>nul
if not exist "%PYDEST%\python.exe" (
  echo   [FAIL] Python did not extract - Launch.bat will use the Python on PATH instead.
  exit /b
)
echo   [ok]   Python %PYVER% installed in python\
exit /b

:done
echo.
pause
endlocal
