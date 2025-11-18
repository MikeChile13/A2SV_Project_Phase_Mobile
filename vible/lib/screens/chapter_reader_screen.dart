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
          final totalChapters = books[bookIndex].chapters.length;
          final hasPrevious = chapterIndex > 0;
          final hasNext = chapterIndex < totalChapters - 1;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
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
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF191919),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: hasPrevious
                          ? () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => ChapterReaderScreen(
                                    bookIndex: bookIndex,
                                    chapterIndex: chapterIndex - 1,
                                    bookTitle: bookTitle,
                                  ),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: hasNext
                          ? () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => ChapterReaderScreen(
                                    bookIndex: bookIndex,
                                    chapterIndex: chapterIndex + 1,
                                    bookTitle: bookTitle,
                                  ),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                      iconAlignment: IconAlignment.end,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
