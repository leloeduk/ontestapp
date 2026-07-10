En analysant les 12 écrans, OnTestApp est une application qui met en relation des utilisateurs avec des applications mobiles à tester. En échange de leurs tests et de leurs avis, les utilisateurs gagnent des points qu'ils peuvent ensuite convertir en récompenses.

Le parcours utilisateur est simple et suit un processus bien défini.

1. Découverte de l'application

L'utilisateur ouvre l'application et voit un écran de démarrage (Splash Screen), puis un onboarding qui explique le concept :

Découvrir de nouvelles applications.
Les tester pendant un certain temps.
Donner un avis honnête.
Gagner des points.

L'objectif est de faire comprendre en quelques secondes que l'application récompense les testeurs.

2. Création d'un compte

L'utilisateur crée ensuite son compte avec :

Nom
Email
Mot de passe

ou se connecte directement avec Google.

Cette étape permet d'identifier chaque testeur et de suivre ses participations.

3. Rejoindre la communauté des testeurs

Avant de pouvoir accéder aux tests, l'utilisateur doit rejoindre un groupe Google.

Cette étape est importante car les applications proposées semblent être distribuées en phase de test fermé (Closed Testing), un mode de diffusion utilisé avant une publication officielle sur le Play Store. Cela permet aux développeurs de faire tester leurs applications par une communauté privée avant leur lancement.

Une fois le groupe rejoint, l'utilisateur confirme son inscription.

4. Accueil

L'écran principal présente :

le nombre de points accumulés,
les applications disponibles,
les récompenses en points pour chaque test.

Chaque application affiche notamment :

son nom,
sa catégorie,
le nombre de points à gagner,
un bouton Tester.

L'utilisateur choisit simplement celle qu'il souhaite essayer.

5. Consultation d'une application

Avant de lancer le test, une fiche descriptive présente :

une description de l'application,
les fonctionnalités à explorer,
les consignes à respecter.

L'utilisateur sait ainsi exactement ce qu'il devra tester.

6. Installation

Après avoir accepté le test, l'application redirige automatiquement vers le Google Play Store afin d'installer la version de test.

L'écran rappelle également qu'il faudra revenir dans OnTestApp une fois le test terminé pour laisser un avis et récupérer les points.

7. Évaluation sur Google Play

Une fois le test effectué, l'utilisateur revient dans OnTestApp.

L'application l'invite à :

1. Ouvrir directement Google Play pour laisser une note et un commentaire sur l'application
2. Prendre une capture d'écran de l'application installée (preuve d'installation)
3. Prendre une capture d'écran de son avis publié sur Google Play (preuve du commentaire)

Les deux captures d'écran sont uploadées sur Firebase Storage.

L'objectif est de garantir que l'utilisateur a bien installé et testé l'application, et qu'il a laissé un avis public sur le Play Store.

8. Validation manuelle

Après l'envoi des captures, l'application confirme la soumission.

Les points **ne sont pas crédités automatiquement**. Un administrateur vérifie manuellement les deux captures d'écran depuis la page `/admin/validation` :

- Capture 1 : vérifier que l'application est bien installée
- Capture 2 : vérifier que l'avis a bien été publié sur Google Play

Une fois validé, les points sont crédités sur le compte de l'utilisateur.

9. Profil

Le profil récapitule toute son activité :

total des points gagnés,
nombre de tests effectués,
statut de chaque soumission (Validé / En attente),
historique des récompenses.

Cela encourage les utilisateurs à rester actifs et à participer régulièrement.

En résumé

Le fonctionnement complet de OnTestApp est le suivant :

Inscription
│
▼
Rejoindre la communauté
│
▼
Choisir une application
│
▼
Installer depuis le Play Store
│
▼
Tester l'application
│
▼
Laisser un avis sur Google Play
│
▼
Prendre 2 captures d'écran (installation + avis)
│
▼
Upload des captures sur Firebase Storage
│
▼
Validation manuelle par l'admin
│
▼
Réception des points
│
▼
Recommencer avec une nouvelle application
Le concept de l'application

OnTestApp est une plateforme de tests d'applications mobiles récompensée. Elle crée un écosystème où :

Les développeurs obtiennent de vrais utilisateurs qui installent, utilisent et évaluent leurs applications avant leur lancement.
Les testeurs découvrent de nouvelles applications, contribuent à leur amélioration et gagnent des points en échange de leurs retours.

L'application agit donc comme un intermédiaire entre les créateurs d'applications et une communauté de testeurs, en transformant le processus de test en une expérience ludique grâce à un système de récompenses.

---

## Déploiement / Mise en production

### Firebase

1. Créer un projet Firebase (console.firebase.google.com)
2. Activer **Authentication** (Email/Mot de passe + Google)
3. Activer **Cloud Firestore** (règle : `allow read, write: if request.auth != null`)
4. Activer **Firebase Storage** (règle : `allow read, write: if request.auth != null`)
5. Télécharger `google-services.json` (Android) et `GoogleService-Info.plist` (iOS) → placer dans les dossiers respectifs

### Firebase CLI

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=nom-du-projet
```

### Build Android (APK / App Bundle)

```bash
# APK
flutter build apk --release

# App Bundle (recommandé Play Store)
flutter build appbundle --release
```

Le fichier généré se trouve dans `build/app/outputs/`.

### Build iOS (Archive)

```bash
flutter build ios --release
```

Puis ouvrir `ios/Runner.xcworkspace` dans Xcode, sélectionner `Product > Archive` et soumettre via le Organizer.

### Google Play Console

1. Créer un compte développeur Google Play (25 $ unique)
2. Préparer la fiche Play Store (icône, captures d'écran, description)
3. Lancer un **Closed Testing** (test fermé) avec un groupe Google
4. Promouvoir en **Open Testing** puis publication officielle

---

## Publicité (AdMob) — À implémenter

Pour intégrer des publicités et monétiser :

1. Créer un compte **AdMob** (https://admob.google.com)
2. Ajouter votre application dans AdMob
3. Créer des unités publicitaires (Banner, Interstitial, Rewarded)
4. Ajouter la dépendance dans `pubspec.yaml` :
   ```yaml
   google_mobile_ads: ^5.0.0
   ```
5. Configurer les IDs de test dans le code
6. Remplacer les IDs de test par les IDs réels avant la publication

**Recommandation pour ce MVP :** Commencer par une **bannière en bas de l'écran d'accueil** et une **interstitielle après la soumission d'un test**.

& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v -keystore android/app/upload-keystore.jks -alias upload


_____________________________________________________________________________________________________________________________


import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _requestPermission();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: android,
    );

    await _local.initialize(settings);

    FirebaseMessaging.onMessage.listen(_showNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("Notification ouverte");
    });

    final token = await getToken();
    print("FCM TOKEN : $token");
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> _showNotification(RemoteMessage message) async {
    await _local.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'appointment_channel',
          'Appointment Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}

Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  await Firebase.initializeApp();
}


______________________________________________________   main _________________________________________________________________

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler);

  await NotificationService.instance.initialize();

  runApp(const MyApp());
}

