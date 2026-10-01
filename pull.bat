@echo off
tasklist /FI "IMAGENAME eq UnrealEditor.exe" | find /I "UnrealEditor.exe" >nul
if %errorlevel%==0 (
    echo.
    echo  Unreal Editor est ouvert, connard. Ferme-le avant de faire un pull.
    echo.
    pause
    exit /b 1
)
git pull
git status
pause