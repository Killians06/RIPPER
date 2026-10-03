#!/bin/bash
# Équivalent macOS de pull.bat — double-cliquable depuis le Finder.
# Le script vit dans Scripts/, on remonte a la racine du projet.
cd "$(dirname "$0")/.." || exit 1

if pgrep -x "UnrealEditor" > /dev/null; then
    echo
    echo "  Unreal Editor est ouvert. Ferme-le avant de faire un pull."
    echo
    read -r -p "Appuie sur Entrée pour quitter..."
    exit 1
fi

git pull
git status

open RIPPER.uproject

read -r -p "Appuie sur Entrée pour quitter..."
