import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bible_providers.dart';
import '../widgets/chapter_tile.dart';
import 'chapter_reader_screen.dart';

class ChaptersScreen extends ConsumerWidget {
  final int bookIndex;
  final String bookTitle;

  const ChaptersScreen({
    required this.bookIndex,
    required this.bookTitle,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bibleAsync = ref.watch(bibleProvider);

    return Scaffold(
      appBar: AppBar(title: Text(bookTitle)),
      body: bibleAsync.when(
        data: (books) {
          final chapters = books[bookIndex].chapters;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: GridView.builder(
              itemCount: chapters.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, // like your screenshot
                childAspectRatio: 1.0,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, i) {
                return ChapterTile(
                  index: i + 1,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChapterReaderScreen(
                          bookIndex: bookIndex,
                          chapterIndex: i,
                          bookTitle: bookTitle,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}