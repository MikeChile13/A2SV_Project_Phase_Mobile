import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bible_providers.dart';

enum Testament { old, new_, all }

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  Testament _selectedTestament = Testament.all;
  String? _selectedBook;
  final TextEditingController _searchController = TextEditingController();

  static const int oldTestamentCount = 39;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                    // TODO: Implement search functionality
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Search the Word',
                        style: TextStyle(color: Colors.white38, fontSize: 16),
                      ),
                    ),
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
