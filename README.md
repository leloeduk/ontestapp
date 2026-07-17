# OnTestApp

**FR** — Une application Flutter qui permet aux utilisateurs de tester des applications mobiles et de gagner des points en échange de leurs avis.

**EN** — A Flutter app that lets users test mobile applications and earn points in exchange for their reviews.

---

## Fonctionnalités / Features

- Inscription & connexion (Email + Google) / Sign up & login (Email + Google)
- Onboarding interactif / Interactive onboarding
- Découverte des apps à tester / Discover apps to test
- Installation via Google Play / Install via Google Play
- Upload de captures d'écran (preuve d'installation + avis) / Screenshot uploads (proof of install + review)
- Validation manuelle par un admin / Manual admin validation
- Système de points et récompenses / Points & rewards system
- Profil utilisateur / User profile
- Bilingual FR/EN (localisation instantanée) / Bilingual FR/EN (instant language switch)
- Interface Material 3 responsive / Responsive Material 3 UI
- Détection de connexion / Connectivity detection

## Stack

- **Flutter** + **Dart**
- **Firebase Authentication**
- **Cloud Firestore**
- **Firebase Storage**
- **Flutter Bloc** (state management)
- **GoRouter** (navigation)
- **intl** (localisation FR/EN)

## Architecture

```
lib/
├── core/          # App router, theme, constants, localization
├── features/      # Feature-first architecture
│   ├── auth/
│   ├── home/
│   ├── earn/
│   ├── review/
│   ├── history/
│   ├── profile/
│   └── admin/
└── main.dart
```

Chaque feature suit le pattern **Bloc** :

```
feature/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── domain/
│   └── repositories/
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

## Démarrage / Getting Started

```bash
# Cloner / Clone
git clone https://github.com/ton-compte/ontestapp.git

# Dépendances / Dependencies
flutter pub get

# Générer Firebase / Configure Firebase
flutterfire configure --project=nom-du-projet

# Lancer / Run
flutter run

# Analyser / Analyze
flutter analyze

# Tester / Test
flutter test
```

## Firebase Setup

1. Créer un projet Firebase / Create a Firebase project
2. Activer Authentication (Email + Google)
3. Activer Cloud Firestore
4. Activer Firebase Storage
5. Télécharger `google-services.json` (Android) et `GoogleService-Info.plist` (iOS)

## Build

```bash
# APK
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Licence / License

MIT
