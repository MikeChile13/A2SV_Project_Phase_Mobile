import 'package:flutter/material.dart';

class ChapterTile extends StatelessWidget {
  final int index;
  final VoidCallback onTap;

  const ChapterTile({
    required this.index,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Card(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$index.',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('Chapter', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
