import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bookmark_provider.dart';
import 'chapter_reader_screen.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  void _showEditNoteDialog(BuildContext context, WidgetRef ref, Bookmark bookmark) {
    final noteController = TextEditingController(text: bookmark.note ?? '');
    final bookmarkNotifier = ref.read(bookmarkProvider.notifier);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Note'),
        content: TextField(
          controller: noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Edit note...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              bookmarkNotifier.updateBookmarkNote(
                bookIndex: bookmark.bookIndex,
                chapterIndex: bookmark.chapterIndex,
                verseIndex: bookmark.verseIndex,
                note: noteController.text,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note updated'), duration: Duration(seconds: 1)),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.verseText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (b.note != null && b.note!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4, right: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: Colors.grey[400]!,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Text(
                              b.note!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('${b.bookName} ${b.chapterIndex + 1}:${b.verseIndex + 1}'),
                        content: SingleChildScrollView(
                          child: Text(b.verseText),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ref.read(bookmarkProvider.notifier).toggleBookmark(
                                    bookIndex: b.bookIndex,
                                    chapterIndex: b.chapterIndex,
                                    verseIndex: b.verseIndex,
                                    bookName: b.bookName,
                                    verseText: b.verseText,
                                  );
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _showEditNoteDialog(context, ref, b);
                            },
                            child: Text(b.note != null && b.note!.isNotEmpty ? 'Edit Note' : 'Add Note'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
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
                            child: const Text('Go to Verse'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}