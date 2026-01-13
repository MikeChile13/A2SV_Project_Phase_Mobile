import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bookmark_provider.dart';
import 'chapter_reader_screen.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarkProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        centerTitle: true,
      ),
      body: bookmarks.isEmpty
          ? const Center(
              child: Text(
                'No bookmarks yet.\nLong-press a verse to add one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final b = bookmarks[index];
                return ListTile(
                  leading: const Icon(Icons.bookmark, color: Colors.amber),
                  title: Text('${b.bookName} ${b.chapterIndex + 1}:${b.verseIndex + 1}'),
                  subtitle: Text(
                    b.verseText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      ref.read(bookmarkProvider.notifier).toggleBookmark(
                            bookIndex: b.bookIndex,
                            chapterIndex: b.chapterIndex,
                            verseIndex: b.verseIndex,
                            bookName: b.bookName,
                            verseText: b.verseText,
                          );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChapterReaderScreen(
                          bookIndex: b.bookIndex,
                          chapterIndex: b.chapterIndex,
                          bookTitle: b.bookName,
                          initialVerseIndex: b.verseIndex,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}