import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/vible_icon_animation.dart'; // ← import here
import '../providers/splash_screen_provider.dart';
import 'books_screen.dart';

class VibleSplashScreen extends ConsumerStatefulWidget {
  const VibleSplashScreen({super.key});

  @override
  ConsumerState<VibleSplashScreen> createState() => _VibleSplashScreenState();
}

class _VibleSplashScreenState extends ConsumerState<VibleSplashScreen> {
  @override
  Widget build(BuildContext context) {
    final showSplash = ref.watch(splashScreenProvider);
    
    // If splash screen is disabled, go directly to books screen
    if (!showSplash) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const BooksScreen()),
          );
        }
      });
    }
    
    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              VibleIconAnimation(
                size: 240,
                onCompleted: () {
                  if (!mounted) return;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const BooksScreen()),
                  );
                },
              ), // ← Use it here!
              const SizedBox(height: 32),
              // The 'King James Bible' text is already inside VibleIconAnimation
            ],
          ),
        ),
      ),
    );
  }
}