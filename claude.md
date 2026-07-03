# OnTestApp - MVP

## Objectif

Développer une application Flutter moderne permettant aux utilisateurs de tester des applications et de gagner des points.

Le projet est un MVP. Le code doit rester simple, lisible et facile à maintenir.

---

# Technologies

- Flutter
- Dart
- Flutter Bloc
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- GoRouter

---

# Architecture

Toujours utiliser une architecture Feature First.

Chaque fonctionnalité doit être indépendante.

Structure :

```
lib/

core/

features/

main.dart
```

Chaque feature contient :

```
feature/

data/

    models/

    repositories/

    services/

domain/

    entities/

    repositories/

presentation/

    bloc/

    pages/

    widgets/
```

---

# Règles

Le projet doit rester simple.

Éviter de créer des classes inutiles.

Toujours réutiliser le code existant.

Créer des widgets réutilisables.

Ne jamais mettre de logique métier dans les pages.

---

# Flutter Bloc

Chaque fonctionnalité possède :

- Bloc
- Event
- State

Le Bloc contient la logique.

Les pages affichent uniquement les données.

---

# Firebase

Utiliser uniquement :

- Firebase Authentication
- Cloud Firestore
- Firebase Storage

Les appels Firebase passent toujours par les services.

Les repositories utilisent les services.

Les blocs utilisent les repositories.

---

# Navigation

Utiliser uniquement GoRouter.

Toutes les routes sont dans :

```
core/router/app_router.dart
```

---

# Interface

Utiliser Material 3.

Respecter la maquette.

Créer des widgets simples.

Le design doit être responsive.

---

# Style de code

Utiliser :

- const
- final
- Equatable

Nommer correctement les variables.

Créer des petits fichiers.

---

# Avant de terminer une tâche

Toujours exécuter :

```bash
flutter analyze

flutter test
```

Corriger les erreurs avant de continuer.

---

# Ne jamais faire

Ne jamais :

- mettre Firebase directement dans une page
- mettre toute la logique dans un Widget
- modifier les fichiers générés
- ajouter une dépendance sans demander
- dupliquer du code
- ignorer flutter analyze

---

# Objectif

Créer un code simple, propre et compréhensible, comme le ferait un développeur Flutter junior appliquant les bonnes pratiques.
