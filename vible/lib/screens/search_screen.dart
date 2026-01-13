import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bible_providers.dart';
import '../screens/chapter_reader_screen.dart';
import '../providers/highlight_provider.dart';

enum Testament { old, new_, all }

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class SearchResult {
  final String book;
  final int chapter;
  final int verseNumber;
  final String text;

  SearchResult({
    required this.book,
    required this.chapter,
    required this.verseNumber,
    required this.text,
  });
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  Testament _selectedTestament = Testament.all;
  String? _selectedBook;
  final TextEditingController _searchController = TextEditingController();

  List<SearchResult> _searchResults = [];
  static const int oldTestamentCount = 39;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> extractQuotedPhrases(String input) {
    // Match either "..." or '...'; ensure opening and closing quotes are the same
    final regex = RegExp(r'"([^"]+)"|' + r"'([^']+)'");
    return regex.allMatches(input).map((m) {
      return (m.group(1) ?? m.group(2))!.toLowerCase();
    }).toList();
  }



  List<String> extractUnquotedWords(String input) {
    // Remove quoted parts first
    // remove both double- and single-quoted phrases (matching pairs)
    final cleaned = input.replaceAll(RegExp(r'"([^"]+)"|' + r"'([^']+)'"), ' ');
    final words = cleaned
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w.toLowerCase())
        .toList();
    return words;
  }

  Widget _buildHighlightedText(String text) {
    final query = _searchController.text.trim();

    final phrases = extractQuotedPhrases(query);
    final words = extractUnquotedWords(query);

    final terms = <String>{};
    terms.addAll(phrases);
    terms.addAll(words);

    if (terms.isEmpty) {
      return Text(
        text,
        style: const TextStyle(color: Colors.white),
      );
    }

    final sortedTerms = terms.toList()..sort((a, b) => b.length.compareTo(a.length));
    final pattern = sortedTerms.map(RegExp.escape).join('|');
    final reg = RegExp(pattern, caseSensitive: false);

    final matches = reg.allMatches(text).toList();
    if (matches.isEmpty) {
      return Text(
        text,
        style: const TextStyle(color: Colors.white),
      );
    }

    final defaultColor = Colors.white;
    final children = <TextSpan>[];
    int last = 0;

    for (final m in matches) {
      if (m.start > last) {
        children.add(TextSpan(text: text.substring(last, m.start), style: TextStyle(color: defaultColor)));
      }

      final matchText = text.substring(m.start, m.end);
      final selectedColor = ref.watch(highlightColorProvider);
      children.add(TextSpan(text: matchText, style: TextStyle(color: selectedColor)));

      last = m.end;
    }

    if (last < text.length) {
      children.add(TextSpan(text: text.substring(last), style: TextStyle(color: defaultColor)));
    }

    return RichText(
      text: TextSpan(children: children, style: const TextStyle(fontSize: 14)),
    );
  }

  int findBookIndexByName(List<dynamic> books, String name) {
  return books.indexWhere(
    (b) => (b.name ?? b.abbrev).toString().toLowerCase() ==
           name.toLowerCase(),
  );
}

  List<SearchResult> performSearch(
    String query,
    List<dynamic> books,
    Testament testament,
    String? selectedBook,
  ) {
    final lowerQuery = query.toLowerCase();

    final phrases = extractQuotedPhrases(lowerQuery);
    final words = extractUnquotedWords(lowerQuery);

    final results = <SearchResult>[];

    // ---------------------------
    // 1. DETERMINE SEARCH RANGE
    // ---------------------------
    int start = 0;
    int end = books.length;

    const int oldTestamentCount = 39;

    switch (testament) {
      case Testament.old:
        start = 0;
        end = oldTestamentCount;
        break;

      case Testament.new_:
        start = oldTestamentCount;
        end = books.length;
        break;

      case Testament.all:
        start = 0;
        end = books.length;
        break;
    }

    // If a specific book is selected, override the range:
    int? bookOnlyIndex;
    if (selectedBook != null) {
      bookOnlyIndex = books.indexWhere(
        (b) => (b.name ?? b.abbrev) == selectedBook,
      );

      if (bookOnlyIndex != -1) {
        start = bookOnlyIndex;
        end = bookOnlyIndex + 1;
      }
    }

    // ---------------------------
    // 2. PERFORM SEARCH IN RANGE
    // ---------------------------
    for (int b = start; b < end; b++) {
      final book = books[b];
      final bookName = book.name ?? book.abbrev;

      for (int c = 0; c < book.chapters.length; c++) {
        final chapter = book.chapters[c];

        for (int v = 0; v < chapter.length; v++) {
          final verse = chapter[v].toString();
          final verseLower = verse.toLowerCase();

          bool matches = true;

          // 1. Check quoted phrases
          for (final p in phrases) {
            if (!verseLower.contains(p)) {
              matches = false;
              break;
            }
          }

          if (!matches) continue;

          // 2. Check word matches
          for (final w in words) {
            if (!verseLower.contains(w)) {
              matches = false;
              break;
            }
          }

          if (matches) {
            results.add(
              SearchResult(
                book: bookName,
                chapter: c + 1,
                verseNumber: v + 1,
                text: verse,
              ),
            );
          }
        }
      }
    }

    return results;
  }


  String _getTestamentLabel() {
    switch (_selectedTestament) {
      case Testament.old:
        return 'Old Testament';
      case Testament.new_:
        return 'New Testament';
      case Testament.all:
        return 'All';
    }
  }

  void _cycleTestament() {
    setState(() {
      switch (_selectedTestament) {
        case Testament.all:
          _selectedTestament = Testament.old;
          break;
        case Testament.old:
          _selectedTestament = Testament.new_;
          break;
        case Testament.new_:
          _selectedTestament = Testament.all;
          break;
      }
      _selectedBook = null;
    });
  }

  List<String> _getAvailableBooks(List<dynamic> books) {
    switch (_selectedTestament) {
      case Testament.old:
        return books
            .sublist(0, oldTestamentCount)
            .map((b) => (b.name ?? b.abbrev) as String)
            .toList();
      case Testament.new_:
        return books
            .sublist(oldTestamentCount)
            .map((b) => (b.name ?? b.abbrev) as String)
            .toList();
      case Testament.all:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final bibleAsync = ref.watch(bibleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        centerTitle: true,
      ),
      body: bibleAsync.when(
        data: (books) {
          final availableBooks = _getAvailableBooks(books);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 160,
                      child: ElevatedButton(
                        onPressed: _cycleTestament,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(_getTestamentLabel()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedBook,
                        decoration: InputDecoration(
                          labelText: 'Select Book',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _selectedTestament == Testament.all
                            ? null
                            : availableBooks.map((book) {
                                return DropdownMenuItem<String>(
                                  value: book,
                                  child: Text(book),
                                );
                              }).toList(),
                        onChanged: _selectedTestament == Testament.all
                            ? null
                            : (String? newValue) {
                                setState(() {
                                  _selectedBook = newValue;
                                });
                              },
                        hint: const Text('All books'),
                        disabledHint: const Text('All books'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a keyword or phrase...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),

                  onSubmitted: (value) {
                    if (value.trim().isEmpty) return;

                    final books = ref.read(bibleProvider).value!;

                    final results = performSearch(
                      value,
                      books,
                      _selectedTestament,
                      _selectedBook,
                    );

                    setState(() {
                      _searchResults = results;
                    });
                  },

                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _searchResults.isEmpty
                      ? const Center(
                          child: Text(
                            'Search the Word',
                            style: TextStyle(color: Colors.white38, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final r = _searchResults[index];
                            return ListTile(
                                title: Text(
                                  '${r.book} ${r.chapter}:${r.verseNumber}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: _buildHighlightedText(r.text),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                onTap: () {
                                  final books = ref.read(bibleProvider).value!;
                                  final bookIndex = findBookIndexByName(books, r.book);

                                  if (bookIndex == -1) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: Could not locate book "${r.book}".')),
                                    );
                                    return;
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChapterReaderScreen(
                                        bookIndex: bookIndex,
                                        chapterIndex: r.chapter - 1,
                                        bookTitle: r.book,
                                        initialVerseIndex: r.verseNumber - 1, // ← Triggers flash + scroll
                                      ),
                                    ),
                                  );
                                },
                              );
                          },
                        ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
