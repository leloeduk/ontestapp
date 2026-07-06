import 'package:shared_preferences/shared_preferences.dart';

/// Persiste l'état de l'onboarding et l'acceptation des conditions via SharedPreferences.
class OnboardingService {
  static const String _keySeen = 'onboarding_seen';
  static const String _keyTerms = 'terms_accepted';

  Future<bool> isSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySeen) ?? false;
  }

  Future<void> setSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySeen, true);
  }

  Future<bool> isTermsAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTerms) ?? false;
  }

  Future<void> acceptTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTerms, true);
  }
}
