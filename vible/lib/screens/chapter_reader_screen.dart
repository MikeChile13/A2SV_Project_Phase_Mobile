import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/bible_providers.dart';
import '../providers/highlight_provider.dart';
import '../providers/bookmark_provider.dart';

class ChapterReaderScreen extends ConsumerStatefulWidget {
  final int bookIndex;
  final int chapterIndex;
  final String bookTitle;
  final int? initialVerseIndex;

  const ChapterReaderScreen({
    required this.bookIndex,
    required this.chapterIndex,
    required this.bookTitle,
    this.initialVerseIndex,
    super.key,
  });

  @override
  ConsumerState<ChapterReaderScreen> createState() => _ChapterReaderScreenState();
}

class _ChapterReaderScreenState extends ConsumerState<ChapterReaderScreen> {
  bool _highlightMode = false;
  Color? _activeHighlightColor;
  int? _flashVerseIndex;
  bool _shareMode = false;
  Set<int> _selectedVerses = {};

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  static const List<Color> _palette = [
    Color(0xFFFFF176),
    Color(0xFFA5D6A7),
    Color(0xFF90CAF9),
    Color(0xFFF8BBD0),
    Color(0xFFFFCC80),
  ];

  String get _chapterKey => '${widget.bookIndex}-${widget.chapterIndex}';

  @override
  void initState() {
    super.initState();

    if (widget.initialVerseIndex != null) {
      _flashVerseIndex = widget.initialVerseIndex;

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) setState(() => _flashVerseIndex = null);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _itemScrollController.scrollTo(
          index: widget.initialVerseIndex!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          alignment: 0.3,
        );
      });
    }
  }

  void _enterHighlightMode(Color color) {
    setState(() {
      _highlightMode = true;
      _activeHighlightColor = color;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Highlight mode — tap verses to apply color')),
    );
  }

  void _exitHighlightMode() {
    setState(() {
      _highlightMode = false;
      _activeHighlightColor = null;
    });
  }

  void _enterShareMode() {
    setState(() {
      _shareMode = true;
      _selectedVerses.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share mode — tap verses to select, then share')),
    );
  }

  void _exitShareMode() {
    setState(() {
      _shareMode = false;
      _selectedVerses.clear();
    });
  }

  void _toggleVerseSelection(int verseIndex) {
    if (!_shareMode) return;

    setState(() {
      if (_selectedVerses.contains(verseIndex)) {
        _selectedVerses.remove(verseIndex);
      } else {
        _selectedVerses.add(verseIndex);
      }
    });
  }

  Future<void> _shareSelectedVerses(List<String> verses) async {
    if (_selectedVerses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select verses to share')),
      );
      return;
    }

    final sortedIndices = _selectedVerses.toList()..sort();
    final bookChapter = '${widget.bookTitle} ${widget.chapterIndex + 1}';
    final verseLines = sortedIndices.map((i) {
      return '${i + 1}. "${verses[i]}"';
    }).join('\n\n');

    final shareText = '$bookChapter\n\n$verseLines\n\n— Veritas Bible';

    await Share.share(shareText);
  }

  void _toggleHighlight(int verseIndex) {
    if (!_highlightMode || _activeHighlightColor == null) return;

    ref.read(highlightProvider.notifier).toggleHighlight(
          _chapterKey,
          verseIndex,
          _activeHighlightColor!.value,
        );
  }

  Widget _buildColorPalette(BuildContext ctx) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          children: _palette.map((c) {
            return GestureDetector(
              onTap: () => Navigator.of(ctx).pop(c),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showBookmarkDialog(
    BuildContext context,
    WidgetRef ref,
    int verseIndex,
    String verseText,
    bool isBookmarked,
  ) {
    final bookmarkNotifier = ref.read(bookmarkProvider.notifier);
    final bookmarks = ref.read(bookmarkProvider);
    
    final existingBookmark = bookmarks.where(
      (b) => b.bookIndex == widget.bookIndex &&
          b.chapterIndex == widget.chapterIndex &&
          b.verseIndex == verseIndex,
    ).firstOrNull;

    final noteController = TextEditingController(text: existingBookmark?.note ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Bookmark'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add a note (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              bookmarkNotifier.toggleBookmark(
                bookIndex: widget.bookIndex,
                chapterIndex: widget.chapterIndex,
                verseIndex: verseIndex,
                bookName: widget.bookTitle,
                verseText: verseText,
                note: noteController.text.isNotEmpty ? noteController.text : null,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bookmark added'), duration: Duration(seconds: 1)),
              );
            },
            child: const Text('Bookmark'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bibleAsync = ref.watch(bibleProvider);
    final highlightState = ref.watch(highlightProvider);
    final bookmarkNotifier = ref.read(bookmarkProvider.notifier);
    final searchHighlightColor = ref.watch(highlightColorProvider);

    return bibleAsync.when(
      data: (books) {
        final verses = books[widget.bookIndex].chapters[widget.chapterIndex];
        final totalChapters = books[widget.bookIndex].chapters.length;
        final hasPrevious = widget.chapterIndex > 0;
        final hasNext = widget.chapterIndex < totalChapters - 1;

        // Load user highlights
        final Map<int, Color> chapterHighlights = {};
        final raw = highlightState[_chapterKey];
        if (raw != null) {
          raw.forEach((i, argb) => chapterHighlights[i] = Color(argb));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('${widget.bookTitle} — Chapter ${widget.chapterIndex + 1}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.highlight),
                tooltip: 'Highlight verses',
                onPressed: () async {
                  final color = await showModalBottomSheet<Color>(
                    context: context,
                    builder: _buildColorPalette,
                  );
                  if (color != null) _enterHighlightMode(color);
                },
              ),
              if (_highlightMode)
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Exit highlight mode',
                  onPressed: _exitHighlightMode,
                ),
              IconButton(
                icon: Icon(_shareMode ? Icons.close : Icons.share),
                tooltip: _shareMode ? 'Exit share mode' : 'Share verses',
                onPressed: _shareMode ? _exitShareMode : _enterShareMode,
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ScrollablePositionedList.builder(
                  itemCount: verses.length,
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemBuilder: (context, i) {
                    final verseText = verses[i];
                    final userHighlight = chapterHighlights[i];

                    // Base background from user highlight
                    final baseColor = userHighlight?.withOpacity(0.25) ?? Colors.transparent;

                    // Flash from search
                    final isFlashing = _flashVerseIndex == i;
                    final flashOverlay = searchHighlightColor.withOpacity(isFlashing ? 0.5 : 0.0);
                    
                    // Share mode selection highlight
                    final isSelected = _selectedVerses.contains(i);
                    final shareHighlight = isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent;
                    
                    final backgroundColor = _shareMode
                        ? Color.lerp(baseColor, shareHighlight, isSelected ? 1.0 : 0.0)!
                        : Color.lerp(baseColor, flashOverlay, isFlashing ? 1.0 : 0.0)!;

                    // Check if this verse is bookmarked
                    final isBookmarked = bookmarkNotifier.isBookmarked(
                      widget.bookIndex,
                      widget.chapterIndex,
                      i,
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            if (_highlightMode) {
                              _toggleHighlight(i);
                            } else if (_shareMode) {
                              _toggleVerseSelection(i);
                            }
                          },
                          onLongPress: () {
                            _showBookmarkDialog(
                              context,
                              ref,
                              i,
                              verseText,
                              isBookmarked,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                  height: 1.4,
                                ),
                                children: [
                                  // Bookmark icon if bookmarked
                                  if (isBookmarked)
                                    const WidgetSpan(
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: Icon(Icons.bookmark, size: 18, color: Colors.amber),
                                      ),
                                    ),
                                  TextSpan(
                                    text: '${i + 1}. ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextSpan(text: verseText),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_shareMode && _selectedVerses.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF191919),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedVerses.length} verse${_selectedVerses.length > 1 ? 's' : ''} selected',
                        style: const TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _shareSelectedVerses(verses),
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                      ),
                    ],
                  ),
                )
              else
                _BottomNav(
                  hasPrevious: hasPrevious,
                  hasNext: hasNext,
                  bookIndex: widget.bookIndex,
                  chapterIndex: widget.chapterIndex,
                  bookTitle: widget.bookTitle,
                ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final bool hasPrevious;
  final bool hasNext;
  final int bookIndex;
  final int chapterIndex;
  final String bookTitle;

  const _BottomNav({
    required this.hasPrevious,
    required this.hasNext,
    required this.bookIndex,
    required this.chapterIndex,
    required this.bookTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF191919),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: hasPrevious
                ? () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChapterReaderScreen(
                          bookIndex: bookIndex,
                          chapterIndex: chapterIndex - 1,
                          bookTitle: bookTitle,
                        ),
                      ),
                    )
                : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
          ),
          ElevatedButton.icon(
            onPressed: hasNext
                ? () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChapterReaderScreen(
                          bookIndex: bookIndex,
                          chapterIndex: chapterIndex + 1,
                          bookTitle: bookTitle,
                        ),
                      ),
                    )
                : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
            iconAlignment: IconAlignment.end,
          ),
        ],
      ),
    );
  }
}