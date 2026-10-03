# RIPPER

Projet Unreal Engine **5.8**, Blueprint only (pas de code C++, donc rien à compiler).

Les assets sont versionnés avec **Git LFS** et protégés par des **verrous**. Lis la section « Premier clone » avant toute chose : sans git-lfs, le projet est inouvrable.

---

## Prérequis

| | Version | Obligatoire |
|---|---|---|
| Unreal Engine | 5.8 | oui |
| Git | récent | oui |
| **Git LFS** | 3.x | **oui — sans lui rien ne fonctionne** |

Installation de git-lfs :

- **macOS** : `brew install git-lfs`
- **Windows** : [git-lfs.com](https://git-lfs.com) (ou cocher Git LFS dans l'installeur de Git for Windows)

Vérifie avec `git lfs version` avant de cloner.

---

## Premier clone

```bash
git clone https://github.com/Killians06/RIPPER.git
cd RIPPER
```

Puis **lance le script de configuration une seule fois** :

- **macOS** : double-clic sur `setup.command` (ou `./setup.command`)
- **Windows** : double-clic sur `setup.bat`

Il s'occupe de quatre choses indispensables :

1. installe les hooks LFS (ils sont propres à chaque clone, le dépôt ne peut pas les transmettre) ;
2. désactive la mise en lecture seule des assets — **sans ça Unreal ne peut rien sauvegarder** ;
3. télécharge les assets LFS et les rend inscriptibles ;
4. installe les raccourcis de déplacement **ZQSD** dans le viewport de l'éditeur.

> Pourquoi un script plutôt qu'un réglage versionné ? Parce que git-lfs refuse la clé `lfs.setlockablereadonly` dans `.lfsconfig` (« unsafe key »). Elle doit être posée poste par poste, il n'existe aucun moyen de la livrer par le dépôt.

Ouvre ensuite `RIPPER.uproject`.

---

## Au quotidien

**Ferme toujours Unreal Editor avant de récupérer les modifications.** Les scripts `pull.command` (macOS) et `pull.bat` (Windows) le vérifient, font le `git pull` et relancent le projet.

### Les verrous : la règle à ne pas oublier

Un `.uasset` ou un `.umap` est un fichier binaire : **Git ne sait pas fusionner deux modifications concurrentes**. Si deux personnes touchent la même map, l'une des deux perd son travail.

D'où les verrous. Avant d'attaquer la map ou un Blueprint partagé :

```bash
git lfs lock Content/Map/Base_Map.umap
```

Le serveur refusera alors le push de quiconque d'autre sur ce fichier. En terminant :

```bash
git lfs unlock Content/Map/Base_Map.umap
```

Pour voir qui détient quoi :

```bash
git lfs locks
```

Le verrou n'est **pas automatique** : rien ne te le rappellera. À deux ou trois, un message « je prends la map » dans la conversation d'équipe complète utilement la commande.

---

## Organisation du dépôt

| Chemin | Rôle |
|---|---|
| `Content/Blueprints/` | `BP_FPS_Character`, `GM_Gamemode` |
| `Content/Map/` | `Base_Map` (World Partition) |
| `Content/__ExternalActors__/`, `__ExternalObjects__/` | acteurs de la map, un fichier par acteur — **ne jamais y toucher à la main** |
| `Config/` | réglages du projet (versionnés) |
| `Params/Keyboard_Shortcuts.ini` | raccourcis viewport ZQSD, installés par le script de setup |

Non versionnés (générés par Unreal) : `Binaries/`, `Intermediate/`, `Saved/`, `DerivedDataCache/`, `Content/Developers/`.

### Entrées clavier : deux choses distinctes

- `Config/DefaultInput.ini` → les entrées **du jeu** (ZQSD pour le personnage). Versionné, à ne pas supprimer.
- `Params/Keyboard_Shortcuts.ini` → les raccourcis **de l'éditeur**, pour se déplacer dans le viewport en ZQSD. Installé par le script de setup dans la config utilisateur d'Unreal, hors du projet.

---

## ⚠️ Deux avertissements

**Ne renomme jamais `.gitattributes`.** Le fichier s'était appelé `.gittattributes` (deux `t`) pendant un temps : Git l'ignorait en silence, donc LFS et les verrous étaient inactifs sans que personne le voie, et les assets partaient en binaires bruts dans l'historique.

**L'historique a été réécrit le 3 octobre 2026** pour basculer les assets vers LFS et purger 166 Mo de contenu de template mort (le dépôt est passé de 112 Mo à 31 Mo au clone). Si tu possèdes un clone antérieur à cette date, **re-clone-le** : un `git pull` échouera sur des historiques sans ancêtre commun.

---

## Dépannage

| Symptôme | Cause | Remède |
|---|---|---|
| Les assets sont des fichiers texte de ~130 octets | git-lfs absent au moment du clone | installer git-lfs, puis `git lfs pull` |
| Unreal refuse de sauvegarder, assets en lecture seule | script de setup non lancé | relancer `setup.command` / `setup.bat` |
| `git pull` : « refusing to merge unrelated histories » | clone antérieur au 3 octobre 2026 | re-cloner le dépôt |
| Push refusé sur un asset précis | quelqu'un détient le verrou | `git lfs locks` pour voir qui |
| Des fichiers `… 2.uasset` apparaissent | doublons créés par macOS lors d'une copie | les supprimer, **ne jamais les committer** (ce sont des acteurs fantômes pour World Partition) |
| Le projet s'ouvre sur une map vide | — | vérifier que `Base_Map` est bien la map par défaut dans `Config/DefaultEngine.ini` |
