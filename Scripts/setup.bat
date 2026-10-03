@echo off
REM =============================================================
REM   RIPPER - configuration d'un poste Windows (a lancer UNE
REM   fois apres le clone). Double-cliquable depuis l'explorateur.
REM =============================================================
REM Le script vit dans Scripts\, on remonte a la racine du projet.
cd /d "%~dp0.."
setlocal enabledelayedexpansion

echo.
echo === Configuration du poste pour RIPPER ===
echo.

REM --- 1. git-lfs est indispensable -----------------------------------
where git-lfs >nul 2>&1
if errorlevel 1 (
    echo   ECHEC  git-lfs n'est pas installe.
    echo.
    echo   Sans lui, les assets arrivent sous forme de fichiers texte de
    echo   130 octets et Unreal ne pourra pas ouvrir le projet.
    echo.
    echo   Installe-le depuis https://git-lfs.com puis relance ce script.
    echo.
    pause
    exit /b 1
)
echo   OK     git-lfs present

REM --- 2. Hooks LFS (par clone, non transmis par le depot) ------------
git lfs install --local >nul 2>&1
if errorlevel 1 (echo   ECHEC  installation des hooks LFS) else (echo   OK     hooks LFS installes)

REM --- 3. Desactiver la lecture seule des fichiers 'lockable' ---------
REM Sans ca, les 146 assets arrivent en lecture seule et Unreal ne peut
REM plus sauvegarder. Ce reglage ne peut PAS etre versionne : git-lfs
REM refuse la cle dans .lfsconfig, chaque poste doit donc l'appliquer.
git config lfs.setlockablereadonly false
if errorlevel 1 (echo   ECHEC  configuration de la lecture seule) else (echo   OK     lecture seule desactivee)

REM --- 4. Recuperer les assets et les rendre inscriptibles ------------
git lfs pull >nul 2>&1
if errorlevel 1 (echo   !      git lfs pull a echoue ^(reseau ? identifiants ?^)) else (echo   OK     assets LFS recuperes)

attrib -R "Content\*.uasset" /S >nul 2>&1
attrib -R "Content\*.umap"   /S >nul 2>&1
echo   OK     assets rendus inscriptibles

REM --- 5. Raccourcis de deplacement dans le viewport (ZQSD) -----------
REM Version du moteur. Volontairement en dur : l'analyse du .uproject en
REM batch est fragile. Si vous passez le projet a une autre version
REM d'Unreal, mettez cette ligne a jour (et "EngineAssociation" dans
REM RIPPER.uproject).
set "UEVER=5.8"

set "DEST=%LOCALAPPDATA%\UnrealEngine\!UEVER!\Saved\Config\WindowsEditor"
set "SRC=Params\Keyboard_Shortcuts.ini"

if not exist "!SRC!" (
    echo   !      !SRC! introuvable, raccourcis non installes
) else (
    if not exist "%LOCALAPPDATA%\UnrealEngine\!UEVER!" (
        echo   !      Unreal !UEVER! ne semble pas installe, raccourcis non installes
        echo          ^(attendu : !DEST!^)
    ) else (
        if not exist "!DEST!" mkdir "!DEST!" >nul 2>&1
        if exist "!DEST!\EditorKeyBindings.ini" (
            for /f "tokens=1-3 delims=/ " %%a in ("%DATE%") do set "STAMP=%%c%%b%%a"
            copy /Y "!DEST!\EditorKeyBindings.ini" "!DEST!\EditorKeyBindings.ini.bak-!STAMP!" >nul
            echo   !      raccourcis existants sauvegardes en .bak-!STAMP!
        )
        copy /Y "!SRC!" "!DEST!\EditorKeyBindings.ini" >nul
        if errorlevel 1 (echo   ECHEC  copie des raccourcis) else (echo   OK     raccourcis viewport ZQSD installes ^(Unreal !UEVER!^))
    )
)

echo.
echo === Termine ===
echo.
echo   Ferme Unreal Editor s'il est ouvert, puis relance-le pour que
echo   les raccourcis soient pris en compte.
echo.
echo   Avant de travailler sur la map ou un Blueprint partage :
echo       git lfs lock Content/Map/Base_Map.umap
echo   Puis en terminant :
echo       git lfs unlock Content/Map/Base_Map.umap
echo.
pause
