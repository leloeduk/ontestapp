# Workflow Git — OnTestApp

## Branches

```
main                  ←版本 stable (production)
  └── develop         ← Intégration (review avant merge main)
        ├── feature/* ← Nouvelle fonctionnalité
        ├── fix/*     ← Correction de bug
        ├── chore/*   → Tâches techniques (tests, doc, config)
        └── refactor/*← Refactoring
```

## Cycle de travail

### 1. Démarrer une feature

```bash
git checkout develop
git pull origin develop
git checkout -b feature/ma-nouveaute
```

### 2. Coder et commit

```bash
git add <fichiers>
git commit -m "feat(scope): description courte"
```
Types de commit : `feat`, `fix`, `chore`, `refactor`, `docs`, `test`

### 3. Pousser la feature

```bash
git push origin feature/ma-nouveaute
```

### 4. Merge dans develop

```bash
git checkout develop
git pull origin develop
git merge feature/ma-nouveaute --no-ff -m "feat: merge ma-nouveaute into develop"
git push origin develop
```

Le `--no-ff` force un commit de merge visible dans l'historique.

### 5. Release dans main (quand develop est stable)

```bash
# D'abord vérifier :
flutter clean && flutter pub get
flutter analyze
flutter test

# Puis merger :
git checkout main
git merge develop --no-ff -m "feat: release vX.Y — description"
git push origin main
git push origin develop
```

## Règles

- **Jamais** de commit direct sur `main`. Toujours passer par develop + merge.
- **Jamais** de commit direct sur `develop` non plus — toujours via une feature branch.
- Les branches feature sont supprimées après merge (sur GitHub ou avec `git branch -d`).
- Toujours lancer `flutter analyze && flutter test` avant un merge dans `main`.
- Si `main` est bloqué pour une urgence : créer un `hotfix/...` depuis `main`, merger directement.
