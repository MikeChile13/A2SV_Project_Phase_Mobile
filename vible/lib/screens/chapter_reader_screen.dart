import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bible_providers.dart';

class ChapterReaderScreen extends ConsumerWidget {
  final int bookIndex;
  final int chapterIndex;
  final String bookTitle;

  const ChapterReaderScreen({
    required this.bookIndex,
    required this.chapterIndex,
    required this.bookTitle,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bibleAsync = ref.watch(bibleProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('$bookTitle — Chapter ${chapterIndex + 1}'),
      ),
      body: bibleAsync.when(
        data: (books) {
          final verses = books[bookIndex].chapters[chapterIndex];
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: verses.length,
            itemBuilder: (context, i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 18, color: Colors.white70, height: 1.4),
                    children: [
                      TextSpan(
                        text: '${i + 1}. ',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      TextSpan(text: verses[i]),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
