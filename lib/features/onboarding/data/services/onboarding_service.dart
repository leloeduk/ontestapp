import 'package:shared_preferences/shared_preferences.dart';

/// Persiste l'état de l'onboarding via SharedPreferences.
class OnboardingService {
  static const String _key = 'onboarding_seen';

  Future<bool> isSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> setSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
