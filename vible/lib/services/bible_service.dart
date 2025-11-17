import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/bible_book.dart';

class BibleService {
  static List<BibleBook>? _cache;

  /// Loads bible JSON from assets and parses it into BibleBook objects.
  static Future<List<BibleBook>> loadFromAssets() async {
    if (_cache != null) return _cache!;

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
