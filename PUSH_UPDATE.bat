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

if not exist BUILD mkdir BUILD

if exist web2\NUL (
  echo.
  echo [1/4] Compress web2 -^> BUILD\web2.zip
  powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Test-Path 'BUILD\web2.zip') { Remove-Item 'BUILD\web2.zip' -Force }; Compress-Archive -Path 'web2\*' -DestinationPath 'BUILD\web2.zip' -CompressionLevel Optimal"
  if errorlevel 1 (echo ERROR: compress web2 failed & pause & exit /b 1)
) else (
  echo [1/4] No web2 folder - skip archive
)

echo.
echo [2/4] Rebuild manifest + upload release asset + commit + push
python PUSH_UPDATE.py
if errorlevel 1 (echo ERROR: PUSH_UPDATE.py failed & pause & exit /b 1)

echo.
echo [3/4] Verify git status
git status -sb

echo.
echo [4/4] DONE
echo Repo: https://github.com/thttd94/XXTE-Tool-Update
echo.
pause
