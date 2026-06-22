@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "SRC=%~dp0..\BUILD\XXTE Manager"
set "DST=%~dp0"

echo ==================================================
echo  Sync BUILD\XXTE Manager -^> push build
echo  SRC: %SRC%
echo  DST: %DST%
echo ==================================================

if not exist "%SRC%\XXTE Manager.exe" (
  echo ERROR: missing build output: %SRC%\XXTE Manager.exe
  pause
  exit /b 1
)

if exist "%DST%\_internal" rmdir /s /q "%DST%\_internal"
copy /y "%SRC%\XXTE Manager.exe" "%DST%\XXTE Manager.exe" >nul
xcopy "%SRC%\_internal" "%DST%\_internal" /E /I /Y >nul

rem Only exclude machine-specific configs.
del /f /q "%DST%\_internal\data\active_config.json" 2>nul
del /f /q "%DST%\_internal\data\xxtouch_router_config.json" 2>nul

echo DONE. Now run PUSH_UPDATE.bat if you want to publish.
pause
