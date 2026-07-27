/// Constantes globales de l'application.
class AppConstants {
  AppConstants._();

  // Collections Firestore
  static const String usersCollection = 'users';
  static const String testsCollection = 'tests';
  static const String reviewsCollection = 'reviews';

  static const String groupUrl = 'https://groups.google.com/g/ontestapp';

  // WhatsApp
  static const String whatsappGroupUrl =
      'https://chat.whatsapp.com/CbmQbQZtMco3MhL2hmvpop';

  // Version / mise à jour
  static const String versionCollection = 'app_config';
  static const String versionDocument = 'version';
  static const String latestVersionField = 'latestVersion';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.leloeduk.ontestapp';

  // Espacements réutilisables
  static const double spacing = 16.0;
  static const double radius = 16.0;
}
