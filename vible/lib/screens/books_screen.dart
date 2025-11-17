import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bible_providers.dart';
import 'chapters_screen.dart';

class BooksScreen extends ConsumerWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bibleAsync = ref.watch(bibleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vible'),
        centerTitle: true,
      ),
      body: bibleAsync.when(
        data: (books) {
          return ListView.separated(
            itemCount: books.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
            itemBuilder: (context, i) {
              final book = books[i];
              final title = book.name ?? _mapAbbrevToTitle(book.abbrev) ?? book.abbrev;
              return ListTile(
                title: Text(title, style: const TextStyle(fontSize: 18)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChaptersScreen(bookIndex: i, bookTitle: title),
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

  // If abbrev is like "gn" you may prefer mapping to "Genesis". Optional.
  String? _mapAbbrevToTitle(String abbrev) {
    // Minimal mapping; your JSON may already include 'name'
    const map = {
      'gn': 'Genesis',
      'ex': 'Exodus',
      'lv': 'Leviticus',
      'nm': 'Numbers',
      'dt': 'Deuteronomy',
      // extend as needed
    };
    return map[abbrev.toLowerCase()];
  }
}
