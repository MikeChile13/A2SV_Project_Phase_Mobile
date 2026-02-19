import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;
// import 'screens/books_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const ProviderScope(child: VibleApp()));
}

class VibleApp extends StatelessWidget {
  const VibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veritas bible',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: _getDefaultFontFamily(),
        appBarTheme: const AppBarTheme(
          color: Color(0xFF191919),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF0F0F0F),
          margin: const EdgeInsets.all(6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: const VibleSplashScreen(),
    );
  }

  String _getDefaultFontFamily() {
    try {
      if (Platform.isLinux) return 'Ubuntu';
      if (Platform.isMacOS) return '.AppleSystemUIFont';
      if (Platform.isWindows) return 'Segoe UI';
      return 'Roboto';
    } catch (_) {
      // On web or other platforms, use Roboto (default)
      return 'Roboto';
    }
  }
}
