import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final splashScreenProvider = StateNotifierProvider<SplashScreenNotifier, bool>((ref) {
  return SplashScreenNotifier();
});

class SplashScreenNotifier extends StateNotifier<bool> {
  SplashScreenNotifier() : super(true) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final showSplash = prefs.getBool('show_splash_screen') ?? true;
    state = showSplash;
  }

  Future<void> toggleSplashScreen(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_splash_screen', value);
    state = value;
  }
}
