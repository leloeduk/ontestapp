# OnTestApp - Application Flutter Complète

Une application mobile moderne et gamifiée permettant aux utilisateurs de tester des applications mobiles, donner leurs avis et gagner des points.

## 📋 Architectura

```
lib/
├── core/
│   ├── constants/          # Constantes et thème
│   │   └── app_constants.dart
│   │   └── app_theme.dart  # Material 3 Theme
│   ├── router/             # GoRouter configuration
│   │   └── app_router.dart
│   ├── services/           # Firebase Services
│   │   ├── auth_service.dart
│   │   ├── user_service.dart
│   │   ├── test_service.dart
│   │   └── review_service.dart
│   └── utils/              # Utilitaires
│
├── models/                 # Modèles de données
│   ├── user_model.dart
│   ├── test_model.dart
│   └── review_model.dart
│
├── repositories/           # Repository Pattern
│   ├── auth_repository.dart
│   ├── user_repository.dart
│   ├── test_repository.dart
│   └── review_repository.dart
│
├── providers/              # State Management (Provider)
│   ├── auth_provider.dart
│   ├── test_provider.dart
│   ├── review_provider.dart
│   └── onboarding_provider.dart
│
├── screens/                # Écrans de l'application
│   ├── splash/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── onboarding/
│   ├── group/
│   ├── home/
│   ├── test/
│   │   ├── test_detail_screen.dart
│   │   ├── test_in_progress_screen.dart
│   │   ├── review_screen.dart
│   │   └── confirmation_screen.dart
│   └── profile/
│
├── widgets/                # Widgets réutilisables
│   ├── app_button.dart
│   ├── app_text_field.dart
│   ├── test_card.dart
│   ├── app_widgets.dart    # LoadingOverlay, ErrorMessage, etc.
│
├── firebase_options.dart   # Configuration Firebase
└── main.dart              # Point d'entrée de l'application
```

## 🎯 Fonctionnalités

### 1. **Authentification**
- Inscription avec email/password
- Connexion avec email/password  
- Google Sign-In
- Validation des champs

### 2. **Onboarding**
- PageView avec animations fluides
- Sauvegarde avec SharedPreferences
- 3 pages d'introduction

### 3. **Rejoindre le groupe**
- Écran expliquant l'obligation
- Lien vers le groupe Google
- Confirmation avec bouton "J'ai déjà rejoint"

### 4. **Accueil**
- Salutation personnalisée
- Affichage des points et statistiques
- Liste des applications à tester
- Bottom navigation

### 5. **Détail du test**
- Image/logo de l'app
- Description complète
- Nombre de points gagnables
- Étapes à suivre numérotées
- Bouton "Tester maintenant"

### 6. **Test en cours**
- Bouton ouvrant le Play Store
- Vérification que l'app a été ouverte
- Rappel pour revenir donner son avis

### 7. **Avis utilisateur**
- Système de notation avec étoiles (1-5)
- Champ commentaire
- Sauvegarde en Firestore
- Support des avis existants (update)

### 8. **Confirmation**
- Animation de succès
- Affichage des points gagnés
- Navigation vers l'accueil

### 9. **Profil**
- Avatar utilisateur
- Statistiques (points, tests complétés)
- Informations personnelles
- Bouton se déconnecter

## 🏗️ Architecture

### Repository Pattern
Les **services** communiquent avec Firebase, les **repositories** abstraient les services pour les **providers**.

### State Management (Provider)
Chaque domain a son provider :
- `AuthProvider` - Gestion de l'authentification
- `TestProvider` - Gestion des applications à tester
- `ReviewProvider` - Gestion des avis
- `OnboardingProvider` - État de l'onboarding

### Navigation (GoRouter)
Routes protégées avec redirection automatique :
- Non authentifié → Login
- Authentifié → Onboarding (si non vu)
- Authentifié + Onboarding vu → Home
- Authentifié sans groupe → Join Group

## 🎨 Design System

### Couleurs
- **Primary**: Violet (#7C3AED)
- **Secondary**: Cyan (#06B6D4)
- **Tertiary**: Purple (#8B5CF6)
- **Error**: Red (#DC2626)

### Material 3
- Cards arrondies (16px)
- Ombres légères
- Spacing cohérent
- Animations fluides

## 🔐 Firebase Collections

### `users`
```json
{
  "uid": "string",
  "name": "string",
  "email": "string",
  "photoUrl": "string?",
  "points": 0,
  "testsDone": 0,
  "joinedGroup": false,
  "createdAt": "ISO8601"
}
```

### `tests`
```json
{
  "title": "string",
  "description": "string",
  "iconUrl": "string",
  "playStoreUrl": "string",
  "points": 10,
  "steps": ["step1", "step2"],
  "createdAt": "ISO8601"
}
```

### `reviews`
```json
{
  "userId": "string",
  "testId": "string",
  "rating": 4.5,
  "comment": "string",
  "createdAt": "ISO8601"
}
```

## 📦 Packages Utilisés

```yaml
provider: ^6.4.0              # State management
go_router: ^17.2.2            # Navigation
firebase_core: ^4.7.0         # Firebase
firebase_auth: ^6.4.0         # Authentification
cloud_firestore: ^6.3.0       # Base de données
firebase_storage: ^11.6.0     # Stockage
google_sign_in: ^6.2.1        # Google Sign-In
shared_preferences: ^2.2.3    # Préférences locales
flutter_animate: ^4.5.0       # Animations
flutter_rating_bar: ^4.0.1    # Système de notation
cached_network_image: ^3.3.1  # Images en cache
url_launcher: ^6.3.2          # Ouverture d'URLs
equatable: ^2.0.8             # Comparaison d'objets
intl: ^0.19.0                 # Localisation
```

## 🚀 Installation et Setup

### 1. Configuration Firebase
```bash
flutterfire configure
```

### 2. Installation des dépendances
```bash
flutter pub get
```

### 3. Générer les fichiers
```bash
flutter generate
```

### 4. Lancer l'app
```bash
flutter run
```

## 🔄 Flux d'authentification

```
Splash Screen
    ↓
Vérifier Auth State
    ↓
    ├─ Non authentifié → Login
    │     ↓
    │  Inscription ou Connexion
    │     ↓
    │  Onboarding
    │
    └─ Authentifié → Join Group?
          ↓
       ├─ Non rejoint → Join Group Screen
       │
       └─ Rejoint → Onboarding Vu?
             ↓
          ├─ Non → Onboarding
          │
          └─ Oui → Home Screen
```

## 💡 Bonnes Pratiques

- ✅ Null Safety complète
- ✅ Code réutilisable et maintenable
- ✅ Validation des champs
- ✅ Gestion des erreurs
- ✅ Animations fluides
- ✅ Responsive design
- ✅ Architecture scalable
- ✅ Séparation UI/Logique/Data

## 🐛 Troubleshooting

### Erreur Firebase
Vérifier que `google-services.json` et `GoogleService-Info.plist` sont configurés.

### Pas d'images
Vérifier les URLs des images dans Firestore.

### GoRouter ne fonctionne pas
S'assurer que les providers sont initialisés avant la création du router.

## 📱 Appareils supportés

- Android 5.0+
- iOS 11.0+
- Web (optionnel)

## 📄 License

MIT License - Libre d'utilisation

---

**Développé avec ❤️ en Flutter**
