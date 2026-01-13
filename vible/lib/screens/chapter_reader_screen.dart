import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../providers/bible_providers.dart';
import '../providers/highlight_provider.dart';
import '../providers/bookmark_provider.dart'; // ← NEW

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
                    final backgroundColor = Color.lerp(baseColor, flashOverlay, isFlashing ? 1.0 : 0.0)!;

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
                            }
                          },
                          onLongPress: () async {
                            final selection = await showModalBottomSheet<String>(
                              context: context,
                              builder: (ctx) {
                                return SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: Icon(
                                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                          color: Colors.amber,
                                        ),
                                        title: Text(isBookmarked ? 'Remove Bookmark' : 'Add Bookmark'),
                                        onTap: () => Navigator.of(ctx).pop('bookmark'),
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.note_add),
                                        title: const Text('Add Note'),
                                        onTap: () => Navigator.of(ctx).pop('note'),
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.share),
                                        title: const Text('Share Verse'),
                                        onTap: () => Navigator.of(ctx).pop('share'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );

                            if (selection == null) return;

                            final reference = '${widget.bookTitle} ${widget.chapterIndex + 1}:${i + 1}';
                            final fullVerse = '$reference\n\n"$verseText"';

                            switch (selection) {
                              case 'bookmark':
                                bookmarkNotifier.toggleBookmark(
                                  bookIndex: widget.bookIndex,
                                  chapterIndex: widget.chapterIndex,
                                  verseIndex: i,
                                  bookName: widget.bookTitle,
                                  verseText: verseText,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isBookmarked ? 'Bookmark removed' : 'Bookmark added',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                                break;

                              case 'note':
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Notes feature coming soon!')),
                                );
                                break;

                              case 'share':
                                // Placeholder — replace with share_plus later
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Share:\n\n$fullVerse\n\n— Veritas Bible'),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                                break;
                            }
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