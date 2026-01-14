import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bible_providers.dart';
import 'bookmarks_screen.dart';
import 'chapters_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class BooksScreen extends ConsumerStatefulWidget {
  const BooksScreen({super.key});

  @override
  ConsumerState<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends ConsumerState<BooksScreen> {
  bool _showOldTestament = true;

  // Old Testament has 39 books (Genesis to Malachi)
  static const int oldTestamentCount = 39;

  @override
  Widget build(BuildContext context) {
    final bibleAsync = ref.watch(bibleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Veritas Bible'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.bookmark),
          tooltip: 'Bookmarks',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BookmarksScreen()),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: bibleAsync.when(
        data: (books) {
            final displayBooks = _showOldTestament
              ? books.sublist(0, oldTestamentCount)
              : books.sublist(oldTestamentCount);

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(
                            value: true,
                            label: Text('Old Testament'),
                            icon: Icon(Icons.menu_book),
                          ),
                          ButtonSegment<bool>(
                            value: false,
                            label: Text('New Testament'),
                            icon: Icon(Icons.auto_stories),
                          ),
                        ],
                        selected: {_showOldTestament},
                        onSelectionChanged: (Set<bool> newSelection) {
                          setState(() {
                            _showOldTestament = newSelection.first;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filled(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SearchScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.search),
                      tooltip: 'Search',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: displayBooks.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
                  itemBuilder: (context, i) {
                    final book = displayBooks[i];
                    final bookIndex = i + (_showOldTestament ? 0 : oldTestamentCount);
                    final title = book.name ?? book.abbrev;
                    return ListTile(
                      title: Text(title, style: const TextStyle(fontSize: 18)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChaptersScreen(bookIndex: bookIndex, bookTitle: title),
                        ),
                      ),
                    );
                  },
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

  // No local abbrev-to-title mapping — use JSON `name` or `abbrev` fallback.
}
