import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('fr')) {
    _loadLocale();
  }

  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale') ?? 'fr';
    _loaded = true;
    emit(Locale(code));
  }

  Future<void> setLocale(Locale locale) async {
    _loaded = true;
    emit(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
  }

  void toggle() {
    final next = state.languageCode == 'fr' ? const Locale('en') : const Locale('fr');
    setLocale(next);
  }
}
