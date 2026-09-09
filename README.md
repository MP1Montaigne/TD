# Retranscription des TD de MP*

Le projet produit deux sorties :

- `pdf/TD-01.pdf` : la séance 01 seule ;
- `pdf/Recueil-TD.pdf` : le recueil annuel, qui inclut actuellement la séance 01.

## Compilation

Dans PowerShell, depuis le dossier du projet :

```powershell
.\build.ps1
```

Pour ne compiler qu'une sortie :

```powershell
.\build.ps1 td01
.\build.ps1 recueil
```

## Ajouter une séance

1. Placer les photos dans `photos/02`, `photos/03`, etc.
2. Créer `td/td02-content.tex` sur le modèle de `td/td01-content.tex`.
3. Créer le petit document autonome `td/td02.tex`.
4. Ajouter dans `recueil.tex` un `\chapter{...}` suivi de `\input{td/td02-content}`.
5. Relancer `.\build.ps1` : les fichiers `tdNN.tex` sont découverts automatiquement.

Le préambule commun (`latex/preamble.tex`) garantit une présentation homogène dans les PDF
individuels et dans le recueil annuel.

## Règle de transcription

- Reproduire fidèlement le texte, les notations, les indications et l'ordre visibles sur les photos.
- Ne pas reformuler une question et ne pas ajouter de titre éditorial aux exercices.
- Conserver dans la solution les sous-parties `a)`, `b)`, `c)` ou `1)`, `2)`, `3)` de la copie.
- Corriger uniquement une coquille ou une erreur mathématique manifeste.
- En cas de lecture incertaine, laisser un commentaire LaTeX `% À vérifier sur la photo` au lieu
  d'inventer ou de supprimer le passage.
