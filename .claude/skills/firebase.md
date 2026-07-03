# Firebase

Utiliser uniquement :

- Firebase Authentication
- Cloud Firestore
- Firebase Storage

Les accès Firebase passent toujours par :

Services

↓

Repositories

↓

Bloc

↓

UI

Ne jamais appeler Firebase directement dans une page.

Créer un service par fonctionnalité.

Exemple :

AuthService

DocumentService

UserService

Les erreurs Firebase doivent être gérées avec try/catch.
