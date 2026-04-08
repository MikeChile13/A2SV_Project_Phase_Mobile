import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../models/bible_book.dart';
import '../providers/bible_providers.dart';

class StudyViewScreen extends ConsumerStatefulWidget {
  const StudyViewScreen({super.key});

  @override
  ConsumerState<StudyViewScreen> createState() => _StudyViewScreenState();
}

const int _oldTestamentCount = 39;

class _StudyViewScreenState extends ConsumerState<StudyViewScreen> {
  final List<ItemScrollController> _scrollControllers = [];
  Axis _direction = Axis.horizontal;

  @override
  void dispose() {
    _scrollControllers.clear();
    super.dispose();
  }

  void _syncScrollControllers(int count) {
    while (_scrollControllers.length < count) {
      _scrollControllers.add(ItemScrollController());
    }
    while (_scrollControllers.length > count) {
      _scrollControllers.removeLast();
    }
  }

  void _ensureInitialTab(List<BibleBook> books) {
    final tabs = ref.read(tabManagerProvider);
    if (tabs.isEmpty && books.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(tabManagerProvider.notifier).addTab(
              TabState(
                bookIndex: 0,
                chapterIndex: 0,
                bookTitle: books[0].name ?? books[0].abbrev,
              ),
            );
      });
    }
  }

  void _addPane(List<BibleBook> books) {
    final currentTabs = ref.read(tabManagerProvider);
    if (currentTabs.length >= 4 || books.isEmpty) return;

    final baseTab = currentTabs.isNotEmpty
        ? currentTabs.last
        : TabState(
            bookIndex: 0,
            chapterIndex: 0,
            bookTitle: books[0].name ?? books[0].abbrev,
          );

    final bookIndex = baseTab.bookIndex.clamp(0, books.length - 1);
    final book = books[bookIndex];
    final chapterIndex =
        baseTab.chapterIndex.clamp(0, book.chapters.length - 1);

    ref.read(tabManagerProvider.notifier).addTab(
          TabState(
            bookIndex: bookIndex,
            chapterIndex: chapterIndex,
            bookTitle: book.name ?? book.abbrev,
            showOldTestament: baseTab.showOldTestament,
          ),
        );
  }

  void _removePane(int index) {
    final manager = ref.read(tabManagerProvider.notifier);
    final currentTabs = ref.read(tabManagerProvider);
    if (currentTabs.length <= 1) return;
    manager.removeTab(index);
  }

  void _toggleDirection() {
    setState(() {
      _direction =
          _direction == Axis.horizontal ? Axis.vertical : Axis.horizontal;
    });
  }

  void _toggleTestament(List<BibleBook> books, int tabIndex) {
    final tabs = ref.read(tabManagerProvider);
    if (tabIndex >= 0 && tabIndex < tabs.length) {
      final currentTab = tabs[tabIndex];
      final newShowOldTestament = !currentTab.showOldTestament;
      final sectionStart = newShowOldTestament ? 0 : _oldTestamentCount;

      final newBook = books[sectionStart];
      ref.read(tabManagerProvider.notifier).updateTab(
        tabIndex,
        TabState(
          bookIndex: sectionStart,
          chapterIndex: 0,
          bookTitle: newBook.name ?? newBook.abbrev,
          showOldTestament: newShowOldTestament,
        ),
      );
    }
  }

  void _updateTab(
    int tabIndex,
    int bookIndex,
    int chapterIndex,
    String bookTitle,
  ) {
    final tabs = ref.read(tabManagerProvider);
    final currentTab = tabIndex >= 0 && tabIndex < tabs.length ? tabs[tabIndex] : null;

    ref.read(tabManagerProvider.notifier).updateTab(
          tabIndex,
          TabState(
            bookIndex: bookIndex,
            chapterIndex: chapterIndex,
            bookTitle: bookTitle,
            showOldTestament: currentTab?.showOldTestament ?? true,
          ),
        );

    _scrollControllers[tabIndex].scrollTo(
      index: 0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bibleAsync = ref.watch(bibleProvider);
    final studyTabs = ref.watch(tabManagerProvider);

    return bibleAsync.when(
      data: (books) {
        _ensureInitialTab(books);
        _syncScrollControllers(studyTabs.length);

        final canAdd = studyTabs.length < 4;
        final canRemove = studyTabs.length > 1;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Study View'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
                  IconButton(
                icon: const Icon(Icons.grid_view),
                tooltip: _direction == Axis.horizontal
                    ? "Split vertically"
                    : "Split horizontally",
                onPressed: _toggleDirection,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: canAdd ? () => _addPane(books) : null,
              ),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed:
                    canRemove ? () => _removePane(studyTabs.length - 1) : null,
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Flex(
              direction: _direction,
              children: List.generate(studyTabs.length, (index) {
                final tab = studyTabs[index];

                return Expanded(
                  child: _StudyPane(
                    books: books,
                    tab: tab,
                    tabIndex: index,
                    scrollController: _scrollControllers[index],
                    onTabChanged: _updateTab,
                    onRemovePane: _removePane,
                    canRemove: canRemove,
                    onToggleTestament: () => _toggleTestament(books, index),
                  ),
                );
              }),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}

class _StudyPane extends StatelessWidget {
  final List<BibleBook> books;
  final TabState tab;
  final int tabIndex;
  final ItemScrollController scrollController;
  final void Function(
    int tabIndex,
    int bookIndex,
    int chapterIndex,
    String bookTitle,
  ) onTabChanged;
  final void Function(int index) onRemovePane;
  final bool canRemove;
  final VoidCallback onToggleTestament;

  const _StudyPane({
    required this.books,
    required this.tab,
    required this.tabIndex,
    required this.scrollController,
    required this.onTabChanged,
    required this.onRemovePane,
    required this.canRemove,
    required this.onToggleTestament,
  });

  @override
  Widget build(BuildContext context) {
    final safeBookIndex = tab.bookIndex.clamp(0, books.length - 1);
    final showOldTestament = tab.showOldTestament;
    final sectionStart = showOldTestament ? 0 : _oldTestamentCount;
    final sectionEnd = showOldTestament ? _oldTestamentCount : books.length;
    final sectionBooks = books.sublist(sectionStart, sectionEnd);
    final selectedBookIndex = safeBookIndex.clamp(sectionStart, sectionEnd - 1);
    final book = books[selectedBookIndex];
    final chapters = book.chapters;
    final safeChapterIndex =
        tab.chapterIndex.clamp(0, chapters.length - 1);
    final verses = chapters[safeChapterIndex];
    final sectionBookSelection = selectedBookIndex - sectionStart;

    final hasPrevious = safeChapterIndex > 0;
    final hasNext = safeChapterIndex < chapters.length - 1;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // 🔥 COMPACT HEADER
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                // 📖 Lucide icon Testament toggle
                Tooltip(
                  message: showOldTestament ? 'Old Testament' : 'New Testament',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: onToggleTestament,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: showOldTestament
                            ? Colors.teal[700]   // OT
                            : Colors.amber[700], // NT
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        LucideIcons.bookOpen,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // 📚 Book dropdown
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: sectionBookSelection,
                        isExpanded: true,
                        dropdownColor: Colors.grey[900],
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Colors.white70),
                        items: List.generate(sectionBooks.length, (index) {
                          final title = sectionBooks[index].name ??
                              sectionBooks[index].abbrev;
                          return DropdownMenuItem(
                            value: index,
                            child: Text(title),
                          );
                        }),
                        onChanged: (newRelativeIndex) {
                          if (newRelativeIndex == null) return;

                          final newIndex = sectionStart + newRelativeIndex;
                          final newBook = books[newIndex];
                          final newChapterIndex = safeChapterIndex
                              .clamp(0, newBook.chapters.length - 1);

                          onTabChanged(
                            tabIndex,
                            newIndex,
                            newChapterIndex,
                            newBook.name ?? newBook.abbrev,
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // �🔢 Chapter dropdown
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: safeChapterIndex + 1,
                      dropdownColor: Colors.grey[900],
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14),
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Colors.white70),
                      items: List.generate(chapters.length, (index) {
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1}'),
                        );
                      }),
                      onChanged: (selectedNumber) {
                        if (selectedNumber == null) return;

                        onTabChanged(
                          tabIndex,
                          selectedBookIndex,
                          selectedNumber - 1,
                          book.name ?? book.abbrev,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 8),
                if (canRemove)
                  Tooltip(
                    message: 'Close pane',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onRemovePane(tabIndex),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 📖 VERSES
          Expanded(
            child: ScrollablePositionedList.builder(
              itemCount: verses.length,
              itemScrollController: scrollController,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    '${index + 1}. ${verses[index]}',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.white70,
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // ⬅️➡️ NAVIGATION
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: hasPrevious
                        ? () => onTabChanged(
                              tabIndex,
                              safeBookIndex,
                              safeChapterIndex - 1,
                              book.name ?? book.abbrev,
                            )
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: hasNext
                        ? () => onTabChanged(
                              tabIndex,
                              safeBookIndex,
                              safeChapterIndex + 1,
                              book.name ?? book.abbrev,
                            )
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                    iconAlignment: IconAlignment.end,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}