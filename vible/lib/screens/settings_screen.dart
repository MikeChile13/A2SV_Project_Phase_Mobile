import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/highlight_provider.dart';
import '../providers/splash_screen_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(highlightColorProvider);
    final showSplash = ref.watch(splashScreenProvider);
    final options = [
      {'name': 'Yellow', 'color': Colors.amberAccent},
      {'name': 'Orange', 'color': Colors.orangeAccent},
      {'name': 'Green', 'color': Colors.lightGreenAccent},
      {'name': 'Cyan', 'color': Colors.cyanAccent},
      {'name': 'Purple', 'color': Colors.purpleAccent},
      {'name': 'Red', 'color': Colors.redAccent},
      {'name': 'Deep Orange', 'color': Colors.deepOrangeAccent},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search Highlight Color',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((opt) {
                final color = opt['color'] as Color;
                final name = opt['name'] as String;
                return ChoiceChip(
                  avatar: CircleAvatar(backgroundColor: color, radius: 10),
                  label: Text(name),
                  selected: current == color,
                  selectedColor: color.withValues(alpha: 0.2),
                  onSelected: (_) => ref.read(highlightColorProvider.notifier).state = color,
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            const Text(
              'Display Options',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Show Splash Screen'),
              subtitle: const Text('Display the splash screen on app launch'),
              value: showSplash,
              onChanged: (value) {
                ref.read(splashScreenProvider.notifier).toggleSplashScreen(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
