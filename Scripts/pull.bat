@echo off
REM Le script vit dans Scripts\, on remonte a la racine du projet.
cd /d "%~dp0.."
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
RIPPER.uproject
pause