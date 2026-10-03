#!/bin/bash
# =============================================================
#  RIPPER — configuration d'un poste macOS (a lancer UNE fois
#  apres le clone). Double-cliquable depuis le Finder.
# =============================================================
cd "$(dirname "$0")" || exit 1

ok()   { printf '  \033[32mOK\033[0m   %s\n' "$1"; }
warn() { printf '  \033[33m!\033[0m    %s\n' "$1"; }
fail() { printf '  \033[31mECHEC\033[0m %s\n' "$1"; }

echo
echo "=== Configuration du poste pour RIPPER ==="
echo

# --- 1. git-lfs est indispensable --------------------------------------
if ! command -v git-lfs >/dev/null 2>&1; then
    fail "git-lfs n'est pas installe."
    echo
    echo "  Sans lui, les assets arrivent sous forme de fichiers texte de"
    echo "  130 octets et Unreal ne pourra pas ouvrir le projet."
    echo
    echo "  Installe-le puis relance ce script :"
    echo "      brew install git-lfs"
    echo
    read -r -p "Appuie sur Entree pour quitter..."
    exit 1
fi
ok "git-lfs present ($(git-lfs version | awk '{print $1}'))"

# --- 2. Hooks LFS (par clone, non transmis par le depot) --------------
git lfs install --local >/dev/null 2>&1 && ok "hooks LFS installes" \
    || fail "installation des hooks LFS"

# --- 3. Desactiver la lecture seule des fichiers 'lockable' -----------
# Sans ca, les 146 assets arrivent en lecture seule et Unreal ne peut
# plus sauvegarder. Ce reglage ne peut PAS etre versionne : git-lfs
# refuse la cle dans .lfsconfig, chaque poste doit donc l'appliquer.
git config lfs.setlockablereadonly false && ok "lecture seule desactivee" \
    || fail "configuration de la lecture seule"

# --- 4. Recuperer les assets et les rendre inscriptibles --------------
git lfs pull >/dev/null 2>&1 && ok "assets LFS recuperes" \
    || warn "git lfs pull a echoue (reseau ? identifiants ?)"

n=$(find Content -type f \( -name '*.uasset' -o -name '*.umap' \) \
     -exec chmod u+w {} + -print 2>/dev/null | wc -l | tr -d ' ')
ok "$n assets rendus inscriptibles"

# --- 5. Raccourcis de deplacement dans le viewport (ZQSD) -------------
UEVER=$(grep -o '"EngineAssociation"[^,]*' RIPPER.uproject \
        | grep -oE '[0-9]+\.[0-9]+' | head -1)
[ -z "$UEVER" ] && UEVER="5.8"
DEST="$HOME/Library/Application Support/Epic/UnrealEngine/$UEVER/Saved/Config/MacEditor"
SRC="Params/Keyboard_Shortcuts.ini"

if [ ! -f "$SRC" ]; then
    warn "$SRC introuvable, raccourcis non installes"
elif [ ! -d "$(dirname "$DEST")" ]; then
    warn "Unreal $UEVER ne semble pas installe, raccourcis non installes"
    echo "       (attendu : $DEST)"
else
    mkdir -p "$DEST"
    if [ -f "$DEST/EditorKeyBindings.ini" ]; then
        BAK="$DEST/EditorKeyBindings.ini.bak-$(date +%Y%m%d-%H%M%S)"
        cp "$DEST/EditorKeyBindings.ini" "$BAK"
        warn "raccourcis existants sauvegardes dans $(basename "$BAK")"
    fi
    cp "$SRC" "$DEST/EditorKeyBindings.ini" \
        && ok "raccourcis viewport ZQSD installes (Unreal $UEVER)" \
        || fail "copie des raccourcis"
fi

echo
echo "=== Termine ==="
echo
echo "  Ferme Unreal Editor s'il est ouvert, puis relance-le pour que"
echo "  les raccourcis soient pris en compte."
echo
echo "  Avant de travailler sur la map ou un Blueprint partage :"
echo "      git lfs lock Content/Map/Base_Map.umap"
echo "  Puis en terminant :"
echo "      git lfs unlock Content/Map/Base_Map.umap"
echo
read -r -p "Appuie sur Entree pour quitter..."
