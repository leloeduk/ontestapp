# OnTestApp - Guide de Développement

## 🎯 Vue d'ensemble

OnTestApp est une application Flutter production-ready qui permet aux utilisateurs de :
- Tester des applications mobiles
- Donner des avis et des notes
- Accumuler des points
- Suivre leurs statistiques

## 📁 Structure des fichiers créés

### Services Firebase (`lib/core/services/`)
- `auth_service.dart` - Authentification Firebase
- `user_service.dart` - Gestion des données utilisateur
- `test_service.dart` - Gestion des applications à tester
- `review_service.dart` - Gestion des avis

### Repositories (`lib/repositories/`)
- `auth_repository.dart` - Abstraction authentification
- `user_repository.dart` - Abstraction données utilisateur
- `test_repository.dart` - Abstraction applications
- `review_repository.dart` - Abstraction avis

### Providers (`lib/providers/`)
- `auth_provider.dart` - État authentification
- `test_provider.dart` - État des tests
- `review_provider.dart` - État des avis
- `onboarding_provider.dart` - État onboarding

### Écrans (`lib/screens/`)
- **splash/** - Écran de démarrage
- **auth/** - Connexion et inscription
- **onboarding/** - Présentation de l'app
- **group/** - Rejoindre le groupe
- **home/** - Écran principal avec navigation
- **test/** - Détail, progression, avis, confirmation
- **profile/** - Profil utilisateur

### Widgets (`lib/widgets/`)
- `app_button.dart` - Bouton réutilisable
- `app_text_field.dart` - Champ texte personnalisé
- `test_card.dart` - Carte d'application
- `app_widgets.dart` - LoadingOverlay, ErrorMessage, EmptyMessage

### Core (`lib/core/`)
- **constants/** - Constantes et thème Material 3
- **router/** - Configuration GoRouter
- **services/** - Services Firebase
- **theme/** - Design system

### Models (`lib/models/`)
- `user_model.dart` - Modèle utilisateur
- `test_model.dart` - Modèle application
- `review_model.dart` - Modèle avis

## 🚀 Démarrage rapide

### 1. Installation
```bash
# Cloner le projet
git clone <url-repo>
cd ontestapp

# Installer les dépendances
flutter pub get

# Configurer Firebase
flutterfire configure
```

### 2. Configuration Firebase
```bash
# Générer les fichiers Firebase
flutterfire configure --project=votre-project-id
```

### 3. Lancer l'application
```bash
flutter run
```

## 🔧 Configuration

### Firebase Setup
1. Créer un projet Firebase
2. Activer Firebase Auth (Email/Password + Google Sign-In)
3. Créer une base Firestore
4. Ajouter les règles de sécurité

### Collections Firestore

**users** - Documents
```
uid (Primary Key)
├── name: string
├── email: string
├── photoUrl: string?
├── points: number (default: 0)
├── testsDone: number (default: 0)
├── joinedGroup: boolean (default: false)
└── createdAt: timestamp
```

**tests** - Documents
```
auto-id
├── title: string
├── description: string
├── iconUrl: string
├── playStoreUrl: string
├── points: number
├── steps: array[string]
└── createdAt: timestamp
```

**reviews** - Documents
```
auto-id
├── userId: string (reference to users)
├── testId: string (reference to tests)
├── rating: number (1-5)
├── comment: string
└── createdAt: timestamp
```

## 📱 Flux d'utilisation

### Premier lancement
1. **Splash** (2 secondes)
2. **Login** (Connexion/Inscription)
3. **Join Group** (Si non rejoint)
4. **Onboarding** (3 pages d'introduction)
5. **Home** (Accueil avec tests disponibles)

### Tester une application
1. Cliquer sur une carte d'application
2. Lire les détails et étapes
3. Cliquer "Tester maintenant"
4. Ouvrir l'application (Play Store)
5. Revenir et donner son avis (notation + commentaire)
6. Confirmation avec points gagnés

## 🎨 Personnalisation

### Couleurs
Modifier `lib/core/theme/app_theme.dart` :
```dart
static const Color primary = Color(0xFF7C3AED);
static const Color secondary = Color(0xFF06B6D4);
```

### Textes
Utiliser les TextStyle du thème :
```dart
Theme.of(context).textTheme.headlineMedium
```

### Animations
```dart
import 'package:flutter_animate/flutter_animate.dart';

Text('Hello')
  .animate()
  .fadeIn(duration: Duration(milliseconds: 500))
```

## 🔐 Sécurité

### Auth
- Password minimum 6 caractères
- Google Sign-In avec validation
- Session gérée par Firebase

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own document
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
    
    // Tests readable by all, writable by admin
    match /tests/{document=**} {
      allow read: if request.auth != null;
      allow write: if false; // Admin only
    }
    
    // Reviews readable by all authenticated, writable by owner
    match /reviews/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == resource.data.userId;
    }
  }
}
```

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```dart
testWidgets('LoginScreen test', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  expect(find.byType(LoginScreen), findsOneWidget);
});
```

## 📦 Build

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🐛 Debugging

### Hot Reload
```bash
flutter run
# Taper 'r' pour hot reload
```

### Debug Console
```dart
print('Debug message');
debugPrint('Flutter debug message');
```

### DevTools
```bash
flutter pub global activate devtools
devtools
```

## 📊 Performance

- ✅ Lazy loading des images avec `cached_network_image`
- ✅ Streams pour les données real-time
- ✅ Provider pour minimiser les rebuilds
- ✅ Images optimisées
- ✅ Pagination possible pour les listes

## 🚢 Déploiement

### PlayStore
1. Créer un compte Google Play Developer
2. Builder l'app bundle
3. Uploader sur Play Console
4. Remplir les infos et soumettre

### AppStore
1. Créer un compte Apple Developer
2. Builder avec `flutter build ios --release`
3. Utiliser Xcode pour l'upload
4. Remplir TestFlight et AppStore Connect

## 📝 Checklist avant production

- [ ] Google Play URL correcte
- [ ] Firebase configuré
- [ ] Textes et traductions finalisés
- [ ] Images optimisées
- [ ] Icône d'application
- [ ] Splash screen
- [ ] Privacy policy
- [ ] Terms of service
- [ ] Tests unitaires
- [ ] Performance optimisée

## 🤝 Contribution

Les contributions sont bienvenues ! Suivez la structure établie et maintenez la cohérence du code.

## 📧 Support

Pour toute question ou problème, contactez : contact@ontestapp.com

---

**Happy coding! 🚀**
