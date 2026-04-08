import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bible_book.dart';
import '../services/bible_service.dart';

// A FutureProvider that loads the list of books once and caches via Riverpod.
final bibleProvider = FutureProvider<List<BibleBook>>((ref) async {
  return BibleService.loadFromAssets();
});

// Tab management
class TabState {
  final int bookIndex;
  final int chapterIndex;
  final String bookTitle;
  final int? initialVerseIndex;
  final String? searchQuery;
  final bool showOldTestament;

  const TabState({
    required this.bookIndex,
    required this.chapterIndex,
    required this.bookTitle,
    this.initialVerseIndex,
    this.searchQuery,
    this.showOldTestament = true,
  });

  TabState copyWith({
    int? bookIndex,
    int? chapterIndex,
    String? bookTitle,
    int? initialVerseIndex,
    String? searchQuery,
    bool? showOldTestament,
  }) {
    return TabState(
      bookIndex: bookIndex ?? this.bookIndex,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      bookTitle: bookTitle ?? this.bookTitle,
      initialVerseIndex: initialVerseIndex ?? this.initialVerseIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      showOldTestament: showOldTestament ?? this.showOldTestament,
    );
  }
}

class TabManager extends StateNotifier<List<TabState>> {
  TabManager() : super([]); // Start with no tabs

  void addTab(TabState tabState) {
    if (state.length >= 4) return;
    state = [...state, tabState];
  }

  void removeTab(int index) {
    if (state.length > 1) {
      state = [...state]..removeAt(index);
    }
  }

  void updateTab(int index, TabState newState) {
    if (index >= 0 && index < state.length) {
      state = [...state]..[index] = newState;
    }
  }

  void navigateToChapter(int tabIndex, int bookIndex, int chapterIndex, String bookTitle) {
    if (tabIndex >= 0 && tabIndex < state.length) {
      final newState = TabState(
        bookIndex: bookIndex,
        chapterIndex: chapterIndex,
        bookTitle: bookTitle,
      );
      updateTab(tabIndex, newState);
    }
  }
}

final tabManagerProvider = StateNotifierProvider<TabManager, List<TabState>>((ref) {
  return TabManager();
});
