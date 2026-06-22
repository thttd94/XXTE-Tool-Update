@echo off
setlocal EnableExtensions
cd /d "%~dp0"

echo ==================================================
echo  XXTE Tool Update - PUSH_UPDATE
echo  Folder: %CD%
echo ==================================================

where git >nul 2>nul || (echo ERROR: git not found & pause & exit /b 1)
where gh >nul 2>nul || (echo ERROR: GitHub CLI gh not found & pause & exit /b 1)
where python >nul 2>nul || (echo ERROR: python not found & pause & exit /b 1)

if not exist update_manifest.json (
  echo ERROR: missing update_manifest.json
  pause
  exit /b 1
)

set "TEMP_UPDATE_DIR=%TEMP%\XXTE_Tool_Update_Push"
set "TEMP_WEB2_ZIP=%TEMP_UPDATE_DIR%\web2.zip"
if not exist "%TEMP_UPDATE_DIR%" mkdir "%TEMP_UPDATE_DIR%"

if exist _internal\web2\NUL (
  echo.
  echo [1/4] Compress _internal\web2 -^> TEMP web2.zip
  powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Test-Path '%TEMP_WEB2_ZIP%') { Remove-Item '%TEMP_WEB2_ZIP%' -Force }; Compress-Archive -Path '_internal\web2\*' -DestinationPath '%TEMP_WEB2_ZIP%' -CompressionLevel Optimal"
  if errorlevel 1 (echo ERROR: compress _internal\web2 failed & pause & exit /b 1)
) else (
  echo [1/4] No _internal\web2 folder - skip archive
  set "TEMP_WEB2_ZIP="
)

echo.
echo [2/4] Rebuild manifest + upload release asset + commit + push
if defined TEMP_WEB2_ZIP (
  python PUSH_UPDATE.py "%TEMP_WEB2_ZIP%"
) else (
  python PUSH_UPDATE.py
)
if errorlevel 1 (echo ERROR: PUSH_UPDATE.py failed & pause & exit /b 1)

echo.
echo [3/4] Verify git status
git status -sb

echo.
echo [4/4] DONE
echo BUILD folder is ignored and untouched by PUSH_UPDATE.
echo Repo: https://github.com/thttd94/XXTE-Tool-Update
echo.
pause
