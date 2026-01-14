import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Each bookmark stores: bookIndex, chapterIndex, verseIndex, bookName, verseText, and optional note
class Bookmark {
  final int bookIndex;
  final int chapterIndex;
  final int verseIndex;
  final String bookName;
  final String verseText;
  final DateTime addedAt;
  final String? note;

  Bookmark({
    required this.bookIndex,
    required this.chapterIndex,
    required this.verseIndex,
    required this.bookName,
    required this.verseText,
    required this.addedAt,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'bookIndex': bookIndex,
        'chapterIndex': chapterIndex,
        'verseIndex': verseIndex,
        'bookName': bookName,
        'verseText': verseText,
        'addedAt': addedAt.millisecondsSinceEpoch,
        'note': note,
      };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        bookIndex: json['bookIndex'],
        chapterIndex: json['chapterIndex'],
        verseIndex: json['verseIndex'],
        bookName: json['bookName'],
        verseText: json['verseText'],
        addedAt: DateTime.fromMillisecondsSinceEpoch(json['addedAt']),
        note: json['note'],
      );
}

class BookmarkNotifier extends StateNotifier<List<Bookmark>> {
  BookmarkNotifier() : super([]) {
    _loadBookmarks();
  }

  static const String _prefsKey = 'bookmarks';

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      state = jsonList.map((json) => Bookmark.fromJson(json)).toList()
        ..sort((a, b) => b.addedAt.compareTo(a.addedAt)); // newest first
    }
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(state.map((b) => b.toJson()).toList());
    await prefs.setString(_prefsKey, jsonString);
  }

  void toggleBookmark({
    required int bookIndex,
    required int chapterIndex,
    required int verseIndex,
    required String bookName,
    required String verseText,
    String? note,
  }) {
    final key = '$bookIndex-$chapterIndex-$verseIndex';

    final existingIndex = state.indexWhere(
      (b) => '${b.bookIndex}-${b.chapterIndex}-${b.verseIndex}' == key,
    );

    if (existingIndex != -1) {
      // Remove bookmark
      state = [...state]..removeAt(existingIndex);
    } else {
      // Add new bookmark
      final newBookmark = Bookmark(
        bookIndex: bookIndex,
        chapterIndex: chapterIndex,
        verseIndex: verseIndex,
        bookName: bookName,
        verseText: verseText,
        addedAt: DateTime.now(),
        note: note,
      );
      state = [newBookmark, ...state];
    }

    _saveBookmarks();
  }

  void updateBookmarkNote({
    required int bookIndex,
    required int chapterIndex,
    required int verseIndex,
    required String note,
  }) {
    final key = '$bookIndex-$chapterIndex-$verseIndex';
    final existingIndex = state.indexWhere(
      (b) => '${b.bookIndex}-${b.chapterIndex}-${b.verseIndex}' == key,
    );

    if (existingIndex != -1) {
      final updated = state[existingIndex];
      state = [
        ...state.sublist(0, existingIndex),
        Bookmark(
          bookIndex: updated.bookIndex,
          chapterIndex: updated.chapterIndex,
          verseIndex: updated.verseIndex,
          bookName: updated.bookName,
          verseText: updated.verseText,
          addedAt: updated.addedAt,
          note: note.isEmpty ? null : note,
        ),
        ...state.sublist(existingIndex + 1),
      ];
      _saveBookmarks();
    }
  }

  bool isBookmarked(int bookIndex, int chapterIndex, int verseIndex) {
    final key = '$bookIndex-$chapterIndex-$verseIndex';
    return state.any((b) => '${b.bookIndex}-${b.chapterIndex}-${b.verseIndex}' == key);
  }
}

final bookmarkProvider = StateNotifierProvider<BookmarkNotifier, List<Bookmark>>(
  (ref) => BookmarkNotifier(),
);