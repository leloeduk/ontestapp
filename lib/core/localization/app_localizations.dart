import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'locale_cubit.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  bool get _isEn => locale.languageCode == 'en';

  static AppLocalizations of(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    return AppLocalizations(locale);
  }

  /// À utiliser uniquement dans des callbacks (hors build).
  static AppLocalizations read(BuildContext context) {
    final locale = context.read<LocaleCubit>().state;
    return AppLocalizations(locale);
  }

  // --- App ---
  String get appTitle => _isEn ? 'OnTestApp' : 'OnTestApp';

  // --- Auth ---
  String get welcome => _isEn ? 'Welcome!' : 'Bienvenue !';
  String get signInSubtitle =>
      _isEn ? 'Sign in to continue testing apps.' : 'Connecte-toi pour continuer à tester des apps.';
  String get email => _isEn ? 'Email' : 'Email';
  String get password => _isEn ? 'Password' : 'Mot de passe';
  String get acceptTerms => _isEn ? 'I accept the terms of use' : "J'accepte les conditions d'utilisation";
  String get readTerms =>
      _isEn ? 'Read the terms of use before registering your account' : "Lire les conditions d'utilisation avant d'inscrire votre compte dans l'application";
  String get readTermsShort => _isEn ? 'Read the terms of use' : "Lire les conditions d'utilisation";
  String get signIn => _isEn ? 'Sign in' : 'Se connecter';
  String get or => _isEn ? 'or' : 'ou';
  String get continueWithGoogle => _isEn ? 'Continue with Google' : 'Continuer avec Google';
  String get noAccount => _isEn ? "Don't have an account?" : "Pas encore de compte ?";
  String get signUp => _isEn ? 'Sign up' : "S'inscrire";
  String get createAccount => _isEn ? 'Create an account' : 'Créer un compte';
  String get signUpSubtitle =>
      _isEn ? 'Join the community and earn points.' : 'Rejoins la communauté et gagne des points.';
  String get name => _isEn ? 'Name' : 'Nom';
  String get alreadyAccount => _isEn ? 'Already have an account?' : 'Déjà un compte ?';

  // --- Terms acceptance message ---
  String get signInTermsMsg =>
      _isEn ? 'By signing in, you accept our terms of use' : 'En vous connectant, vous acceptez nos conditions d\'utilisation';
  String get signUpTermsMsg =>
      _isEn ? 'By signing up, you accept our terms of use' : 'En vous inscrivant, vous acceptez nos conditions d\'utilisation';

  // --- Errors ---
  String get invalidEmail => _isEn ? 'Invalid email' : 'Email invalide';
  String get emailRequired => _isEn ? 'Email required' : 'Email requis';
  String get wrongCredentials => _isEn ? 'Invalid email or password' : 'Email ou mot de passe incorrect';
  String get emailInUse => _isEn ? 'This email is already in use' : 'Cet email est déjà utilisé';
  String get weakPassword => _isEn ? 'Password too weak' : 'Mot de passe trop faible';
  String get noInternet => _isEn ? 'No internet connection' : 'Pas de connexion internet';
  String get authError => _isEn ? 'Authentication error' : "Erreur d'authentification";
  String get unknownError => _isEn ? 'An error occurred' : 'Une erreur est survenue';
  String get googleSignInFailed => _isEn ? 'Google sign-in failed' : 'Connexion Google impossible';
  String get passwordRequired => _isEn ? 'Password required' : 'Mot de passe requis';
  String get minChars => _isEn ? 'Minimum 6 characters' : 'Minimum 6 caractères';
  String fieldRequired(String field) =>
      _isEn ? '$field is required' : '$field est requis';
  String get nameField => _isEn ? 'Name' : 'Le nom';

  // --- Connectivity ---
  String get connectToInternet => _isEn ? 'Connect to the internet' : 'Connectez-vous à internet';
  String get offline => _isEn ? 'Offline' : 'Hors ligne';
  String get offlineDataSync => _isEn ? '— data will be synced' : '— les données seront synchronisées';
  String get acceptTermsRequired => _isEn ? 'Please accept the terms of use' : 'Veuillez accepter les conditions d\'utilisation';

  // --- Drawer ---
  String get home => _isEn ? 'Home' : 'Accueil';
  String get earnPoints => _isEn ? 'Earn points' : 'Gagner des points';
  String get myHistory => _isEn ? 'My history' : 'Mon historique';
  String get adminValidation => _isEn ? 'Admin validation' : 'Validation admin';
  String get about => _isEn ? 'About' : 'À propos';
  String get feedback => _isEn ? 'Feedback' : 'Suggestion';
  String get signOut => _isEn ? 'Sign out' : 'Se déconnecter';
  String get language => _isEn ? 'Language' : 'Langue';
  String get french => _isEn ? 'French' : 'Français';
  String get english => _isEn ? 'English' : 'Anglais';

  // --- Home ---
  String get myTests => _isEn ? 'My tests' : 'Mes tests';
  String get history => _isEn ? 'History' : 'Historique';
  String get profile => _isEn ? 'Profile' : 'Profil';
  String get appsToTest => _isEn ? 'Apps to test' : 'Applications à tester';
  String get noApps => _isEn ? 'No apps at the moment' : 'Aucune application pour le moment';
  String get cantLoadTests => _isEn ? 'Could not load tests' : 'Impossible de charger les tests';
  String get earnPointsCard => _isEn ? 'Earn points' : 'Gagne des points';
  String get watchAndEarn => _isEn ? 'Watch a video and earn 5 points' : 'Regarde une vidéo et gagne 5 points';
  String get seeMore => _isEn ? 'See more' : 'Voir plus';

  // --- My Tests ---
  String get testsSubmitted => _isEn ? 'Tests submitted' : 'Tests soumis';
  String get reviewsGiven => _isEn ? 'Reviews given' : 'Avis donnés';
  String get addTest => _isEn ? 'Add a test' : 'Ajouter un test';
  String get noTestsSubmitted => _isEn ? 'No tests submitted' : 'Aucun test soumis';
  String get deleteTest => _isEn ? 'Delete this test?' : 'Supprimer ce test ?';
  String get deleteIrreversible => _isEn ? 'This action is irreversible.' : 'Cette action est irréversible.';
  String get cancel => _isEn ? 'Cancel' : 'Annuler';
  String get delete => _isEn ? 'Delete' : 'Supprimer';
  String get pointsRequired => _isEn ? '50 points required to add a test' : '50 points requis pour ajouter un test';
  String get freePlanLimit => _isEn ? 'Free plan limit reached (2 tests max)' : 'Limite du plan gratuit atteinte (2 tests max)';

  // --- History ---
  String get noHistory => _isEn ? 'No history' : 'Aucun historique';
  String get validated => _isEn ? 'Validated' : 'Validé';
  String get pendingValidation => _isEn ? 'Pending validation' : 'En attente de validation';

  // --- Onboarding ---
  String get testApps => _isEn ? 'Test apps' : 'Teste des applications';
  String get testAppsDesc =>
      _isEn ? 'Discover new apps and try them for free.' : 'Découvre de nouvelles applications et essaie-les gratuitement.';
  String get shareOpinion => _isEn ? 'Share your opinion' : 'Donne ton avis';
  String get shareOpinionDesc =>
      _isEn ? 'Rate apps and share your experience with the community.' : 'Note les applications et partage ton expérience avec la communauté.';
  String get earnPointsOnboard => _isEn ? 'Earn points' : 'Gagne des points';
  String get earnPointsDesc =>
      _isEn ? 'Each completed test earns you points. Have fun!' : 'Chaque test complété te rapporte des points. Amuse-toi !';
  String get skip => _isEn ? 'Skip' : 'Passer';
  String get start => _isEn ? 'Start' : 'Commencer';
  String get next => _isEn ? 'Next' : 'Suivant';

  // --- Terms ---
  String get termsOfUse => _isEn ? 'Terms of Use' : "Conditions d'utilisation";
  String get welcomeOnTestApp => _isEn ? 'Welcome to OnTestApp' : 'Bienvenue sur OnTestApp';
  String get agreeTerms =>
      _isEn ? 'By using this app, you agree to the following terms:' : 'En utilisant cette application, tu acceptes les conditions suivantes :';
  String get testerGroup => _isEn ? 'Tester Group' : 'Groupe de testeurs';
  String get testerGroupDesc => _isEn
      ? 'You must join the Google Group ontestapps@googlegroups.com to participate. This group coordinates testing between developers and testers.'
      : 'Tu dois rejoindre le Google Group ontestapps@googlegroups.com pour participer. Ce groupe permet de coordonner les tests entre développeurs et testeurs.';
  String get appTesting => _isEn ? 'App Testing' : "Tests d'applications";
  String get appTestingDesc => _isEn
      ? 'You can submit your own apps for testing, and test those of other members. Each test earns points.'
      : "Tu peux soumettre tes propres applications pour qu'elles soient testées, et tester celles des autres membres. Chaque test rapporte des points.";
  String get privacy => _isEn ? 'Privacy' : 'Confidentialité';
  String get privacyDesc => _isEn
      ? 'Screenshots and information shared during tests are visible to the administration team only for validation purposes.'
      : "Les captures d'écran et informations partagées lors des tests sont visibles par l'équipe d'administration uniquement dans le cadre de la validation.";
  String get pointsAndRewards => _isEn ? 'Points & Rewards' : 'Points et récompenses';
  String get pointsAndRewardsDesc => _isEn
      ? 'Points are credited after your tests are validated by an administrator. They are not redeemable for cash and may be adjusted in case of abuse.'
      : 'Les points sont crédités après validation de tes tests par un administrateur. Ils ne sont pas monnayables et peuvent être ajustés en cas d\'abus.';

  // --- Profile ---
  String get points => _isEn ? 'Points' : 'Points';
  String get testsDone => _isEn ? 'Tests done' : 'Tests réalisés';
  String get validatedLabel => _isEn ? 'Validated' : 'Validés';
  String get pending => _isEn ? 'Pending' : 'En attente';
  String get totalEarned => _isEn ? 'Total earned' : 'Total gagné';
  String get plan => _isEn ? 'Plan' : 'Plan';
  String get free => _isEn ? 'Free' : 'Gratuit';
  String get viewFullHistory => _isEn ? 'View full history' : 'Voir mon historique complet';
  String get changePlan => _isEn ? 'Change plan' : 'Changer de plan';
  String get changePlanNotAvailable =>
      _isEn ? 'Not available yet. Coming soon.' : "Pas disponible pour l'instant. Bientôt disponible.";
  String get ok => _isEn ? 'OK' : 'OK';
  String get editProfile => _isEn ? 'Edit profile' : 'Modifier le profil';
  String get changePhoto => _isEn ? 'Change photo' : 'Changer la photo';
  String get addPhoto => _isEn ? 'Add a photo' : 'Ajouter une photo';
  String get save => _isEn ? 'Save' : 'Enregistrer';
  String get confirmSignOut => _isEn ? 'Sign out' : 'Se déconnecter';
  String get confirmSignOutMsg => _isEn ? 'Do you really want to sign out?' : 'Veux-tu vraiment te déconnecter ?';
  String get disconnect => _isEn ? 'Sign out' : 'Déconnexion';
  // Fixed:
  String get disconnectLabel => _isEn ? 'Sign out' : 'Déconnexion';

  String get lastSubmissions => _isEn ? 'Last submissions' : 'Dernières soumissions';

  // --- About ---
  String get aboutTitle => _isEn ? 'About' : 'À propos';
  String get forDevelopers => _isEn ? 'For developers' : 'Pour les développeurs';
  String get aboutDesc => _isEn
      ? 'OnTestApp allows developers to submit their Android apps for testing by a community of qualified testers.'
      : "OnTestApp permet aux développeurs de soumettre leurs applications Android pour qu'elles soient testées par une communauté de testeurs qualifiés.";
  String get howItWorks => _isEn ? 'How it works?' : 'Comment ça marche ?';
  String get howDevs => _isEn ? 'Developers add their apps' : 'Les développeurs ajoutent leurs apps';
  String get howTesters => _isEn ? 'Testers install and test them' : 'Les testeurs les installent et les testent';
  String get howReview => _isEn ? 'Testers give their feedback' : 'Les testeurs donnent leur avis';
  String get howFeedback => _isEn ? 'Developers get concrete feedback' : 'Les développeurs reçoivent des retours concrets';
  String get contact => _isEn ? 'Contact' : 'Contact';

  // --- Drawer ---
  String get joinWhatsApp =>
      _isEn ? 'Join WhatsApp group' : 'Rejoindre le groupe WhatsApp';

  // --- Update ---
  String get updateAvailable => _isEn ? 'Update available' : 'Mise à jour disponible';
  String get newVersionMessage => _isEn
      ? 'A new version is available on the Play Store. Update to get the latest features!'
      : 'Une nouvelle version est disponible sur le Play Store. Mets à jour pour profiter des dernières fonctionnalités !';
  String get updateNow => _isEn ? 'Update now' : 'Mettre à jour';
  String get later => _isEn ? 'Later' : 'Plus tard';

  // --- Earn ---
  String get earnTitle => _isEn ? 'Earn points' : 'Gagner des points';
  String get earn5PerVideo => _isEn ? 'Earn 5 points per video' : 'Gagne 5 points par vidéo';
  String get earnDescription => _isEn
      ? 'Watch a short ad video and earn 5 points.\nYou can watch as many videos as you want!'
      : 'Regarde une courte vidéo publicitaire et gagne 5 points.\nTu peux regarder autant de vidéos que tu veux !';
  String get earnGoOnline => _isEn ? 'Connect to the internet to watch videos and earn points.' : 'Connecte-toi à internet pour regarder des vidéos et gagner des points.';
  String get reward => _isEn ? 'Reward' : 'Récompense';
  String get rewardPerVideo => _isEn ? '5 points per video watched' : '5 points par vidéo regardée';
  String get offlineUnavailable => _isEn ? 'Unavailable offline' : 'Indisponible hors ligne';
  String get watchVideo => _isEn ? 'Watch a video' : 'Regarder une vidéo';
  String get pointsAddedAfter => _isEn ? 'Points are added immediately after the video ends.' : 'Les points sont ajoutés immédiatement après la fin de la vidéo.';
  String get noVideoAvailable => _isEn ? 'No video available at the moment' : 'Aucune vidéo disponible pour le moment';
  String get videoError => _isEn ? 'Error playing the video' : 'Erreur lors de la lecture de la vidéo';
  String get pointsEarned => _isEn ? '+5 points! Keep it up!' : '+5 points ! Continue comme ça !';

  // --- Rewards ---
  String get myHistoryTitle => _isEn ? 'My history' : 'Mon historique';
  String get totalEarnedHeader => _isEn ? 'Total earned' : 'Total gagné';
  String get noTestsYet => _isEn ? 'No tests yet' : 'Aucun test pour le moment';

  // --- Join Group ---
  String get joinGroup => _isEn ? 'Join the group' : 'Rejoindre le groupe';
  String get developer => _isEn ? 'Developer' : 'Développeur';
  String get googleGroup => _isEn ? 'Google Group' : 'Google Group';
  String get playConsole => _isEn ? 'Play Console' : 'Play Console';
  String get areYouDev => _isEn ? 'Are you a developer?' : 'Es-tu développeur ?';
  String get devDescription => _isEn
      ? 'Developers must configure their Google Play testing track.'
      : 'Les développeurs doivent configurer leur piste de test Google Play.';
  String get no => _isEn ? 'No' : 'Non';
  String get yes => _isEn ? 'Yes' : 'Oui';
  String get joinTesterGroup => _isEn ? 'Join the tester group' : 'Rejoins le groupe des testeurs';
  String get joinDescription => _isEn
      ? 'You must join the Google Group to test and have your apps tested.'
      : 'Tu dois rejoindre le Google Group pour pouvoir tester et faire tester tes applications.';
  String get joinGroupBtn => _isEn ? 'Join the group' : 'Rejoindre le groupe';
  String get nextBtn => _isEn ? 'Next' : 'Suivant';
  String get configurePlayConsole => _isEn ? 'Configure Google Play Console' : 'Configure Google Play Console';
  String get configurePlayDesc => _isEn
      ? 'Before validating, configure your testing track in Google Play Console:'
      : 'Avant de valider, configure ta piste de test dans Google Play Console :';
  String get steps => _isEn ? 'Steps:' : 'Étapes :';
  String get step1 => _isEn ? '1. Go to Google Play Console > Testing tracks' : '1. Va dans Google Play Console > Pistes de test';
  String get step2 => _isEn ? '2. Create a Closed Testing track' : '2. Crée une piste Closed Testing';
  String get step3 => _isEn ? '3. Add ontestapp@googlegroups.com as testers' : "3. Ajoute ontestapp@googlegroups.com comme testeurs";
  String get step4 => _isEn ? '4. Publish the track' : '4. Publie la piste';
  String get configConfirm => _isEn
      ? 'I have configured the testing track\nwith the group in Play Console'
      : "J'ai configuré la piste de test\navec le groupe dans Play Console";
  String get done => _isEn ? 'Done!' : 'Terminé !';
  String get validate => _isEn ? 'Validate' : 'Valider';
  String get checkAbove => _isEn ? 'Check the box above to validate' : 'Coche la case ci-dessus pour valider';
  String get welcomeTeam => _isEn
      ? 'Welcome to the team!\nYour apps can now be tested by the community.'
      : "Bienvenue dans l'équipe !\nTes apps pourront être testées par la communauté.";
  String get back => _isEn ? 'Back' : 'Retour';
  String get couldNotOpenLink => _isEn ? "Could not open the link" : "Impossible d'ouvrir le lien";
  String get errorOccurred => _isEn ? 'An error occurred' : 'Une erreur est survenue';

  // --- Retry ---
  String get retry => _isEn ? 'Retry' : 'Réessayer';

  // --- Missing test ---
  String get backToHome => _isEn ? 'Back to home' : "Retour à l'accueil";

  // --- Add/Edit Test ---
  String get addApplication => _isEn ? 'Add an application' : 'Ajouter une application';
  String get selectImage => _isEn ? 'Select an image' : 'Sélectionner une image';
  String get title => _isEn ? 'Title' : 'Titre';
  String get required => _isEn ? 'Required' : 'Requis';
  String get description => _isEn ? 'Description' : 'Description';
  String get playStoreUrl => _isEn ? 'Play Store URL' : 'URL Play Store';
  String get validPlayStoreUrl => _isEn ? 'Valid Play Store URL: https://play.google.com/store/apps/' : 'URL Play Store valide : https://play.google.com/store/apps/';
  String get category => _isEn ? 'Category' : 'Catégorie';
  String get pointsInfo => _isEn ? '10 points earned per completed test • 50 points deducted on add' : "10 points gagnés par test terminé • 50 points déduits à l'ajout";
  String get addMinus50 => _isEn ? 'Add (-50 points)' : 'Ajouter (-50 points)';
  String get appAddedSuccess => _isEn ? 'Application added successfully' : 'Application ajoutée avec succès';
  String get cantSelectImage => _isEn ? "Could not select the image" : "Impossible de sélectionner l'image";
  String get selectImagePrompt => _isEn ? 'Please select an image' : 'Veuillez sélectionner une image';
  String get editApp => _isEn ? 'Edit application' : "Modifier l'application";
  String get editSave => _isEn ? 'Save' : 'Enregistrer';
  String get appEdited => _isEn ? 'Application edited' : 'Application modifiée';

  // --- Categories ---
  String get catEntertainment => _isEn ? 'Entertainment' : 'Divertissement';
  String get catGames => _isEn ? 'Games' : 'Jeux';
  String get catSocial => _isEn ? 'Social Media' : 'Réseaux sociaux';
  String get catUtilities => _isEn ? 'Utilities' : 'Utilitaires';
  String get catEducation => _isEn ? 'Education' : 'Éducation';
  String get catProductivity => _isEn ? 'Productivity' : 'Productivité';
  String get catMusic => _isEn ? 'Music' : 'Musique';
  String get catPhotography => _isEn ? 'Photography' : 'Photographie';
  String get catShopping => _isEn ? 'Shopping' : 'Shopping';
  String get catTravel => _isEn ? 'Travel' : 'Voyage';
  String get catSports => _isEn ? 'Sports' : 'Sport';
  String get catVideoGames => _isEn ? 'Video Games' : 'Videogames';
  String get catOther => _isEn ? 'Other' : 'Autre';

  /// Canonical (French) category values stored in Firestore.
  static const canonicalCategories = [
    'Divertissement',
    'Jeux',
    'Réseaux sociaux',
    'Utilitaires',
    'Éducation',
    'Productivité',
    'Musique',
    'Photographie',
    'Shopping',
    'Voyage',
    'Sport',
    'Videogames',
    'Autre',
  ];

  List<String> get localizedCategories => [
        catEntertainment,
        catGames,
        catSocial,
        catUtilities,
        catEducation,
        catProductivity,
        catMusic,
        catPhotography,
        catShopping,
        catTravel,
        catSports,
        catVideoGames,
        catOther,
      ];

  /// Returns the localized display name for a canonical category value.
  String categoryDisplay(String canonical) {
    final index = canonicalCategories.indexOf(canonical);
    if (index < 0) return canonical;
    return localizedCategories[index];
  }

  // --- Test Detail ---
  String get detail => _isEn ? 'Detail' : 'Détail';
  String get deleteConfirmTitle => _isEn ? 'Delete' : 'Supprimer';
  String get deleteConfirmMsg => _isEn ? 'Do you really want to delete this app?' : 'Veux-tu vraiment supprimer cette application ?';
  String get edit => _isEn ? 'Edit' : 'Modifier';
  String get appDeleted => _isEn ? 'Application deleted' : 'Application supprimée';
  String get descriptionLabel => _isEn ? 'Description' : 'Description';
  String get stepsToFollow => _isEn ? 'Steps to follow' : 'Étapes à suivre';
  String get whatToDo => _isEn ? 'What you need to do' : 'Ce que vous devez faire';
  String get watchVideoForPoints => _isEn ? 'Watch a video to earn 5 points' : 'Suivre une vidéo pour gagner 5 points';
  String get downloadAndInstall => _isEn ? "Download and install the app" : "Télécharger et installer l'application";
  String get giveReview => _isEn ? "Review the app" : "Donner mon avis sur l'application";
  String get screenshotInstalled => _isEn ? "Screenshot of the installed app" : "Une capture d'écran de l'app installée";
  String get screenshotReview => _isEn ? "Screenshot of your review" : "Une capture d'écran de mon avis";
  String get bothScreenshotsValidated => _isEn ? 'Both screenshots validated = 10 points' : 'Les deux captures validées = 10 points';
  String get testNow => _isEn ? 'Test now' : 'Tester maintenant';
  String get pointsLabel => _isEn ? 'points' : 'points';

  // --- Test In Progress ---
  String get testInProgress => _isEn ? 'Test in progress' : 'Test en cours';
  String get openPlayStore => _isEn ? 'Open Play Store' : 'Ouvrir le Play Store';
  String get installAndTest => _isEn ? 'Install and test' : 'Installer et tester';
  String get giveYourReview => _isEn ? "Give your review" : "Donner ton avis";
  String get previous => _isEn ? 'Previous' : 'Précédent';
  String get nextStep => _isEn ? 'Next' : 'Suivant';
  String get openPlayStoreDesc => _isEn ? "Open the app on the Play Store to access the official and secure page." : "Ouvre l'application sur le Play Store pour accéder à la page officielle et sécurisée.";
  String get installDesc => _isEn ? "Install the app from the Play Store and use it for a few moments to check its functionality." : "Installe l'application depuis le Play Store et utilise-la quelques instants pour vérifier son bon fonctionnement.";
  String get testAllFeatures => _isEn ? 'Test all features to give a complete review.' : 'Teste toutes les fonctionnalités pour donner un avis complet.';
  String get reviewReminder => _isEn ? "Come back here and review the app. Your feedback helps improve the app." : "Reviens ici et donne ton avis sur l'application. Ton retour aide à améliorer l'application.";
  String get iTestedGiveReview => _isEn ? "I've tested — Give my review" : "J'ai testé — Donner mon avis";
  String get cantOpenPlayStore => _isEn ? "Could not open the Play Store" : "Impossible d'ouvrir le Play Store";

  // --- Review ---
  String get giveReviewTitle => _isEn ? 'Give my review' : 'Donner mon avis';
  String get completeStepsForPoints => _isEn ? 'Complete the steps to earn your points' : 'Termine les étapes pour gagner tes points';
  String get leavePlayStoreReview => _isEn ? 'Leave a Google Play review' : "Laisser un avis Google Play";
  String get screenshot1Install => _isEn ? 'Screenshot 1 — Installation' : "Capture d'écran 1 — Installation";
  String get screenshot2Review => _isEn ? 'Screenshot 2 — Review' : "Capture d'écran 2 — Avis";
  String get reviewWillBeCredited => _isEn ? "Points will be credited after manual verification of your screenshots." : "Les points seront crédités après vérification manuelle de tes captures.";
  String get sendForValidation => _isEn ? 'Send for validation' : 'Envoyer pour validation';
  String get openPlayStoreToReview => _isEn ? "Open the Play Store, rate the app and leave a comment." : "Ouvre le Play Store, note l'application et laisse un commentaire.";
  String get openGooglePlay => _isEn ? 'Open Google Play' : 'Ouvrir Google Play';
  String get takeScreenshotInstalled => _isEn ? "Take a screenshot of the installed app." : "Prends une capture d'écran de l'application installée.";
  String get modify => _isEn ? 'Modify' : 'Modifier';
  String get select => _isEn ? 'Select' : 'Sélectionner';
  String get captureScreenshotReview => _isEn ? "Screenshot your review (rating + comment) on Google Play." : "Capture ton avis (note + commentaire) sur Google Play.";
  String get selectBothScreenshots => _isEn ? 'Please select both screenshots' : "Veuillez sélectionner les 2 captures d'écran";

  // --- Confirmation ---
  String get submissionSent => _isEn ? 'Submission sent!' : 'Soumission envoyée !';
  String get screenshotsBeingVerified => _isEn ? "Your screenshots are being verified.\nPoints will be credited once validated." : "Tes captures d'écran sont en cours de vérification.\nLes points seront crédités une fois validées.";
  String get backToHomeBtn => _isEn ? "Back to home" : "Retour à l'accueil";
  String get plus2Points => _isEn ? '+2 points for watching the video!' : '+2 points pour avoir regardé la vidéo !';

  // --- Admin Validation ---
  String get adminValidationTitle => _isEn ? 'Admin validation' : 'Validation admin';
  String get validateSubmission => _isEn ? 'Validate this submission?' : 'Valider cette soumission ?';
  String get pointsWillBeCredited => _isEn ? "Points will be credited to the user." : "Les points seront crédités à l'utilisateur.";
  String get noPendingSubmissions => _isEn ? 'No pending submissions' : 'Aucune soumission en attente';
  String get capture1 => _isEn ? 'Screenshot 1' : 'Capture 1';
  String get capture2 => _isEn ? 'Screenshot 2' : 'Capture 2';
  String get noCapture => _isEn ? 'No screenshot' : 'Aucune capture';
  String get viewOnPlayStore => _isEn ? 'View on Play Store' : 'Voir sur le Play Store';
  String get deleteTestConfirm => _isEn ? 'Delete this test?' : 'Supprimer ce test ?';
  String get deleteTestMsg => _isEn ? "The test and its images will be deleted. The user keeps their already credited points." : "Le test et ses images seront supprimés. L'utilisateur garde ses points déjà crédités.";
  String get userLabel => _isEn ? 'User' : 'Utilisateur';
  String get testCount => _isEn ? 'test' : 'test';
  String get testCountPlural => _isEn ? 'tests' : 'tests';
  String get errorLabel => _isEn ? 'Error' : 'Erreur';
}
