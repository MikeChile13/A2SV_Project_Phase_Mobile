import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/bible_book.dart';

class BibleService {
  static List<BibleBook>? _cache;

  /// Loads bible JSON from assets and parses it into BibleBook objects.
  static Future<List<BibleBook>> loadFromAssets() async {
    if (_cache != null) return _cache!;

    // Prefer the per-book files in `assets/Bible-kjv-master/` and use
    // `Books.json` as the ordered index. Fall back to the single-file
    // `assets/bible/en_kjv.json` if the master folder isn't available.
    try {
      final indexStr = await rootBundle.loadString('assets/Bible-kjv-master/Books.json');
      final List<dynamic> bookNames = jsonDecode(indexStr) as List<dynamic>;
      final List<BibleBook> books = [];

      for (final rawName in bookNames) {
        final name = rawName as String;
        // Build filename by stripping non-alphanumeric characters
        // e.g. "1 Samuel" -> "1Samuel.json", "Song of Solomon" -> "SongofSolomon.json"
        final fileName = name.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
        final path = 'assets/Bible-kjv-master/$fileName.json';

        try {
          final bookStr = await rootBundle.loadString(path);
          final Map<String, dynamic> data = jsonDecode(bookStr) as Map<String, dynamic>;

          final bookName = data['book'] as String? ?? name;

          final rawChapters = data['chapters'] as List<dynamic>? ?? <dynamic>[];
          final chapters = rawChapters.map<List<String>>((ch) {
            final verses = (ch['verses'] as List<dynamic>? ?? <dynamic>[]);
            return verses.map<String>((v) => v['text'] as String? ?? '').toList();
          }).toList();

          final abbrev = bookName.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toLowerCase();

          books.add(BibleBook(name: bookName, abbrev: abbrev, chapters: chapters));
        } catch (_) {
          // If a single book file fails to load, skip it and continue.
          continue;
        }
      }

      _cache = books;
      if (_cache != null && _cache!.isNotEmpty) return _cache!;
    } catch (_) {
      // Fall through to legacy single-file load below.
    }

    // Legacy fallback: single combined JSON file
    final jsonStr = await rootBundle.loadString('assets/bible/en_kjv.json');
    final data = jsonDecode(jsonStr) as List<dynamic>;
    _cache = data.map((e) => BibleBook.fromJson(e as Map<String, dynamic>)).toList();
    return _cache!;
  }

  /// Optionally: get a single book by index
  static Future<BibleBook> getBook(int index) async {
    final books = await loadFromAssets();
    return books[index];
  }

  /// Optionally: get a chapter's verses by book and chapter index
  static Future<List<String>> getChapter(int bookIndex, int chapterIndex) async {
    final book = await getBook(bookIndex);
    return book.chapters[chapterIndex];
  }
}
