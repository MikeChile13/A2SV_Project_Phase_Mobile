import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final highlightColorProvider = StateProvider<Color>((ref) => Colors.amberAccent);



class HighlightNotifier extends StateNotifier<Map<String, Map<int, int>>> {
  HighlightNotifier() : super({}) {
    _loadHighlights();
  }

  Future<void> _loadHighlights() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('highlights');
    if (jsonString != null) {
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      state = jsonMap.map((key, value) => MapEntry(
            key,
            (value as Map).map((k, v) => MapEntry(int.parse(k), v as int)),
          ));
    }
  }

  Future<void> _saveHighlights() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('highlights', json.encode(state));
  }

  void toggleHighlight(String chapterKey, int verseIndex, int colorArgb) {
    final chapterHighlights = Map<int, int>.from(state[chapterKey] ?? {});
    if (chapterHighlights[verseIndex] == colorArgb) {
      chapterHighlights.remove(verseIndex);
    } else {
      chapterHighlights[verseIndex] = colorArgb;
    }

    if (chapterHighlights.isEmpty) {
      state = {...state}..remove(chapterKey);
    } else {
      state = {...state, chapterKey: chapterHighlights};
    }

    _saveHighlights();
  }

  int? getHighlight(String chapterKey, int verseIndex) {
    return state[chapterKey]?[verseIndex];
  }
}

final highlightProvider = StateNotifierProvider<HighlightNotifier, Map<String, Map<int, int>>>(
  (ref) => HighlightNotifier(),
);

// Helper to generate chapter key: "bookIndex-chapterIndex"
String chapterKey(int bookIndex, int chapterIndex) => '$bookIndex-$chapterIndex';