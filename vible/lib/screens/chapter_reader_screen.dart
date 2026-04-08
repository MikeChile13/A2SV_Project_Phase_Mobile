import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _ChapterReaderScreenState extends ConsumerState<ChapterReaderScreen>
    with SingleTickerProviderStateMixin {
  bool _highlightMode = false;
  Color? _activeHighlightColor;
  int? _flashVerseIndex;
  bool _shareMode = false;
  bool _copyMode = false;
  final Set<int> _selectedVerses = {};

  // ── Search state ──────────────────────────────────────────────────────────
  bool _searchActive = false;
  String _searchQuery = '';
  int _searchResultCount = 0;
  int _currentSearchResultIndex = 0;
  /// verse index → list of (start, end) character ranges that match
  Map<int, List<(int, int)>> _searchMatches = {};
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late final AnimationController _searchAnimController;
  late final Animation<double> _searchWidthAnimation;
  // ─────────────────────────────────────────────────────────────────────────

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

  // Map of book names to their abbreviations
  static const Map<String, Map<String, String>> _bookAbbreviations = {
    'Genesis': {'full': 'Genesis', 'medium': 'Gen', 'short': 'Gn'},
    '1Chronicles': {'full': '1Chronicles', 'medium': '1Chr', 'short': '1Ch'},
    '1Corinthians': {'full': '1Corinthians', 'medium': '1Cor', 'short': '1Co'},
    '1John': {'full': '1John', 'medium': '1Jn', 'short': '1J'},
    '1Kings': {'full': '1Kings', 'medium': '1Ki', 'short': '1K'},
    '1Peter': {'full': '1Peter', 'medium': '1Pet', 'short': '1P'},
    '1Samuel': {'full': '1Samuel', 'medium': '1Sam', 'short': '1S'},
    '1Thessalonians': {'full': '1Thessalonians', 'medium': '1Ths', 'short': '1Th'},
    '1Timothy': {'full': '1Timothy', 'medium': '1Tim', 'short': '1T'},
    '2Chronicles': {'full': '2Chronicles', 'medium': '2Chr', 'short': '2Ch'},
    '2Corinthians': {'full': '2Corinthians', 'medium': '2Cor', 'short': '2Co'},
    '2John': {'full': '2John', 'medium': '2Jn', 'short': '2J'},
    '2Kings': {'full': '2Kings', 'medium': '2Ki', 'short': '2K'},
    '2Peter': {'full': '2Peter', 'medium': '2Pet', 'short': '2P'},
    '2Samuel': {'full': '2Samuel', 'medium': '2Sam', 'short': '2S'},
    '2Thessalonians': {'full': '2Thessalonians', 'medium': '2Ths', 'short': '2Th'},
    '2Timothy': {'full': '2Timothy', 'medium': '2Tim', 'short': '2T'},
    '3John': {'full': '3John', 'medium': '3Jn', 'short': '3J'},
    'Acts': {'full': 'Acts', 'medium': 'Acts', 'short': 'Ac'},
    'Amos': {'full': 'Amos', 'medium': 'Amos', 'short': 'Am'},
    'Colossians': {'full': 'Colossians', 'medium': 'Col', 'short': 'Co'},
    'Daniel': {'full': 'Daniel', 'medium': 'Dan', 'short': 'Da'},
    'Deuteronomy': {'full': 'Deuteronomy', 'medium': 'Deu', 'short': 'De'},
    'Ecclesiastes': {'full': 'Ecclesiastes', 'medium': 'Ecc', 'short': 'Ec'},
    'Ephesians': {'full': 'Ephesians', 'medium': 'Eph', 'short': 'Ep'},
    'Esther': {'full': 'Esther', 'medium': 'Est', 'short': 'Es'},
    'Exodus': {'full': 'Exodus', 'medium': 'Exo', 'short': 'Ex'},
    'Ezekiel': {'full': 'Ezekiel', 'medium': 'Eze', 'short': 'Ez'},
    'Ezra': {'full': 'Ezra', 'medium': 'Ezr', 'short': 'Ez'},
    'Galatians': {'full': 'Galatians', 'medium': 'Gal', 'short': 'Ga'},
    'Habakkuk': {'full': 'Habakkuk', 'medium': 'Hab', 'short': 'Hb'},
    'Haggai': {'full': 'Haggai', 'medium': 'Hag', 'short': 'Ha'},
    'Hebrews': {'full': 'Hebrews', 'medium': 'Heb', 'short': 'He'},
    'Hosea': {'full': 'Hosea', 'medium': 'Hos', 'short': 'Ho'},
    'Isaiah': {'full': 'Isaiah', 'medium': 'Isa', 'short': 'Is'},
    'James': {'full': 'James', 'medium': 'Jas', 'short': 'Ja'},
    'Jeremiah': {'full': 'Jeremiah', 'medium': 'Jer', 'short': 'Jr'},
    'Job': {'full': 'Job', 'medium': 'Job', 'short': 'Jo'},
    'Joel': {'full': 'Joel', 'medium': 'Joe', 'short': 'Jo'},
    'John': {'full': 'John', 'medium': 'Jhn', 'short': 'Jn'},
    'Jonah': {'full': 'Jonah', 'medium': 'Jon', 'short': 'Jo'},
    'Joshua': {'full': 'Joshua', 'medium': 'Jos', 'short': 'Js'},
    'Jude': {'full': 'Jude', 'medium': 'Jud', 'short': 'Ju'},
    'Judges': {'full': 'Judges', 'medium': 'Jdg', 'short': 'Jg'},
    'Lamentations': {'full': 'Lamentations', 'medium': 'Lam', 'short': 'La'},
    'Leviticus': {'full': 'Leviticus', 'medium': 'Lev', 'short': 'Le'},
    'Luke': {'full': 'Luke', 'medium': 'Luk', 'short': 'Lu'},
    'Malachi': {'full': 'Malachi', 'medium': 'Mal', 'short': 'Ma'},
    'Mark': {'full': 'Mark', 'medium': 'Mar', 'short': 'Mk'},
    'Matthew': {'full': 'Matthew', 'medium': 'Mat', 'short': 'Mt'},
    'Micah': {'full': 'Micah', 'medium': 'Mic', 'short': 'Mi'},
    'Nahum': {'full': 'Nahum', 'medium': 'Nah', 'short': 'Na'},
    'Nehemiah': {'full': 'Nehemiah', 'medium': 'Neh', 'short': 'Ne'},
    'Numbers': {'full': 'Numbers', 'medium': 'Num', 'short': 'Nu'},
    'Obadiah': {'full': 'Obadiah', 'medium': 'Oba', 'short': 'Ob'},
    'Philemon': {'full': 'Philemon', 'medium': 'Phm', 'short': 'Pm'},
    'Philippians': {'full': 'Philippians', 'medium': 'Phi', 'short': 'Ph'},
    'Proverbs': {'full': 'Proverbs', 'medium': 'Pro', 'short': 'Pr'},
    'Psalms': {'full': 'Psalms', 'medium': 'Psa', 'short': 'Ps'},
    'Revelation': {'full': 'Revelation', 'medium': 'Rev', 'short': 'Re'},
    'Romans': {'full': 'Romans', 'medium': 'Rom', 'short': 'Ro'},
    'Ruth': {'full': 'Ruth', 'medium': 'Rut', 'short': 'Ru'},
    'SongofSolomon': {'full': 'Song of Solomon', 'medium': 'Song', 'short': 'So'},
    'Titus': {'full': 'Titus', 'medium': 'Tit', 'short': 'Ti'},
    'Zechariah': {'full': 'Zechariah', 'medium': 'Zec', 'short': 'Zc'},
    'Zephaniah': {'full': 'Zephaniah', 'medium': 'Zep', 'short': 'Ze'},
  };

  String _getBookAbbreviation(String bookName, String lengthType) {
    return _bookAbbreviations[bookName]?[lengthType] ?? bookName;
  }

  @override
  void initState() {
    super.initState();

    _searchAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _searchWidthAnimation = CurvedAnimation(
      parent: _searchAnimController,
      curve: Curves.easeInOut,
    );

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

  @override
  void dispose() {
    _searchAnimController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ── Search helpers ────────────────────────────────────────────────────────

  void _openSearch() {
    setState(() => _searchActive = true);
    _searchAnimController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _searchFocusNode.requestFocus();
    });
  }

  void _closeSearch() {
    _searchFocusNode.unfocus();
    _searchAnimController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _searchActive = false;
          _searchQuery = '';
          _searchMatches = {};
          _searchResultCount = 0;
          _currentSearchResultIndex = 0;
          _searchController.clear();
        });
      }
    });
  }

  /// Rebuilds [_searchMatches] for [query] against [verses].
  void _runSearch(String query, List<String> verses) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchQuery = '';
        _searchMatches = {};
        _searchResultCount = 0;
        _currentSearchResultIndex = 0;
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    final Map<int, List<(int, int)>> matches = {};
    int totalCount = 0;

    for (int vi = 0; vi < verses.length; vi++) {
      final lowerVerse = verses[vi].toLowerCase();
      int start = 0;
      final List<(int, int)> verseMatches = [];

      while (true) {
        final idx = lowerVerse.indexOf(lowerQuery, start);
        if (idx == -1) break;
        verseMatches.add((idx, idx + lowerQuery.length));
        totalCount++;
        start = idx + lowerQuery.length;
      }

      if (verseMatches.isNotEmpty) {
        matches[vi] = verseMatches;
      }
    }

    setState(() {
      _searchQuery = query;
      _searchMatches = matches;
      _searchResultCount = totalCount;
      _currentSearchResultIndex = totalCount > 0 ? 1 : 0;
    });

    // Scroll to first match
    if (matches.isNotEmpty) {
      final firstVerseIndex = matches.keys.first;
      _itemScrollController.scrollTo(
        index: firstVerseIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
    }
  }

  /// Navigate between search results (direction: +1 or -1).
  void _navigateSearchResult(int direction, List<String> verses) {
    if (_searchResultCount == 0) return;

    int nextIndex = _currentSearchResultIndex + direction;
    if (nextIndex < 1) nextIndex = _searchResultCount;
    if (nextIndex > _searchResultCount) nextIndex = 1;

    setState(() => _currentSearchResultIndex = nextIndex);

    // Find the verse that contains the nth result
    int count = 0;
    for (final entry in _searchMatches.entries) {
      final verseMatchCount = entry.value.length;
      if (count + verseMatchCount >= nextIndex) {
        _itemScrollController.scrollTo(
          index: entry.key,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.3,
        );
        break;
      }
      count += verseMatchCount;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────

  void _enterHighlightMode(Color color) {
    setState(() {
      _highlightMode = true;
      _activeHighlightColor = color;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Highlight mode — tap verses to apply color')),
    );
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

  void _enterCopyMode() {
    setState(() {
      _copyMode = true;
      _selectedVerses.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copy mode — tap verses to select, then copy')),
    );
  }

  void _exitCopyMode() {
    setState(() {
      _copyMode = false;
      _selectedVerses.clear();
    });
  }

  void _toggleVerseSelection(int verseIndex) {
    if (!_shareMode && !_copyMode) return;

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
    final verseRangeTitle = _formatVerseRange(sortedIndices);
    final bookChapter = '${widget.bookTitle} Ch ${widget.chapterIndex + 1}:$verseRangeTitle';
    final verseLines = sortedIndices.map((i) {
      return '${i + 1}. "${verses[i]}"';
    }).join('\n\n');

    final shareText = '$bookChapter\n\n$verseLines\n\n— Veritas Bible';

    await Share.share(shareText);
  }

  String _formatVerseRange(List<int> verseIndices) {
    if (verseIndices.isEmpty) return '';
    if (verseIndices.length == 1) return '${verseIndices[0] + 1}';

    final ranges = <String>[];
    int rangeStart = verseIndices[0];
    int rangeEnd = verseIndices[0];

    for (int i = 1; i < verseIndices.length; i++) {
      if (verseIndices[i] == rangeEnd + 1) {
        rangeEnd = verseIndices[i];
      } else {
        if (rangeStart == rangeEnd) {
          ranges.add('${rangeStart + 1}');
        } else {
          ranges.add('${rangeStart + 1}-${rangeEnd + 1}');
        }
        rangeStart = verseIndices[i];
        rangeEnd = verseIndices[i];
      }
    }

    if (rangeStart == rangeEnd) {
      ranges.add('${rangeStart + 1}');
    } else {
      ranges.add('${rangeStart + 1}-${rangeEnd + 1}');
    }

    return ranges.join(',');
  }

  Future<void> _copySelectedVersesToClipboard(List<String> verses) async {
    if (_selectedVerses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select verses to copy')),
      );
      return;
    }

    final sortedIndices = _selectedVerses.toList()..sort();
    final verseRangeTitle = _formatVerseRange(sortedIndices);
    final bookChapter = '${widget.bookTitle} Ch ${widget.chapterIndex + 1}:$verseRangeTitle';
    final verseLines = sortedIndices.map((i) {
      return '${i + 1}. "${verses[i]}"';
    }).join('\n\n');

    final copyText = '$bookChapter\n\n$verseLines';

    await Clipboard.setData(ClipboardData(text: copyText));

    if (mounted) {
      if (_copyMode) {
        _exitCopyMode();
      } else if (_shareMode) {
        _exitShareMode();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verses copied to clipboard')),
      );
    }
  }

  void _toggleHighlight(int verseIndex) {
    if (!_highlightMode || _activeHighlightColor == null) return;

    ref.read(highlightProvider.notifier).toggleHighlight(
          _chapterKey,
          verseIndex,
          _activeHighlightColor!.toARGB32(),
        );
  }

  void _showVerseOptions(
    BuildContext context,
    WidgetRef ref,
    int verseIndex,
    String verseText,
    bool isBookmarked,
    List<String> verses,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              ),
              title: const Text('Bookmark'),
              onTap: () {
                Navigator.pop(ctx);
                _showBookmarkDialog(context, ref, verseIndex, verseText, isBookmarked);
              },
            ),
            ListTile(
              leading: const Icon(Icons.highlight_alt),
              title: const Text('Highlight Text'),
              onTap: () {
                Navigator.pop(ctx);
                _showHighlightColorPicker(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(ctx);
                _enterShareMode();
                _toggleVerseSelection(verseIndex);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Text'),
              onTap: () {
                Navigator.pop(ctx);
                _enterCopyMode();
                _toggleVerseSelection(verseIndex);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showHighlightColorPicker(BuildContext context) async {
    final selectedColor = await showModalBottomSheet<Color>(
      context: context,
      builder: (ctx) => _buildColorPalette(ctx),
    );

    if (selectedColor != null && mounted) {
      _enterHighlightMode(selectedColor);
    }
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

    final existingBookmark = bookmarks
        .where(
          (b) =>
              b.bookIndex == widget.bookIndex &&
              b.chapterIndex == widget.chapterIndex &&
              b.verseIndex == verseIndex,
        )
        .firstOrNull;

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
                const SnackBar(
                    content: Text('Bookmark added'), duration: Duration(seconds: 1)),
              );
            },
            child: const Text('Bookmark'),
          ),
        ],
      ),
    );
  }

  // ── Verse text builder with search highlighting ───────────────────────────

  /// Builds a [TextSpan] for [verseText] at [verseIndex], wrapping any
  /// search-query matches in a highlighted span using [searchHighlightColor].
  TextSpan _buildVerseTextSpan({
    required int verseIndex,
    required String verseText,
    required bool isBookmarked,
    required Color searchHighlightColor,
  }) {
    final baseStyle = const TextStyle(
      fontSize: 18,
      color: Colors.white70,
      height: 1.4,
    );

    final List<InlineSpan> children = [
      if (isBookmarked)
        const WidgetSpan(
          child: Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.bookmark, size: 18, color: Colors.amber),
          ),
        ),
      TextSpan(
        text: '${verseIndex + 1}. ',
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];

    final matches = _searchMatches[verseIndex];
    if (matches == null || matches.isEmpty || _searchQuery.isEmpty) {
      children.add(TextSpan(text: verseText));
    } else {
      int cursor = 0;
      for (final (start, end) in matches) {
        if (cursor < start) {
          children.add(TextSpan(text: verseText.substring(cursor, start)));
        }
        children.add(
          TextSpan(
            text: verseText.substring(start, end),
            style: TextStyle(
              backgroundColor: searchHighlightColor.withValues(alpha: 0.55),
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
        cursor = end;
      }
      if (cursor < verseText.length) {
        children.add(TextSpan(text: verseText.substring(cursor)));
      }
    }

    return TextSpan(style: baseStyle, children: children);
  }

  // ─────────────────────────────────────────────────────────────────────────

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
            title: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _searchActive
                  ? const SizedBox.shrink()
                  : _ResponsiveChapterTitle(
                      key: const ValueKey('chapter-title'),
                      bookTitle: widget.bookTitle,
                      chapterNumber: widget.chapterIndex + 1,
                      getAbbreviation: _getBookAbbreviation,
                    ),
            ),
            actions: [
              // ── Expandable search bar ──────────────────────────────────
              AnimatedBuilder(
                animation: _searchWidthAnimation,
                builder: (context, child) {
                  return SizeTransition(
                    sizeFactor: _searchWidthAnimation,
                    axis: Axis.horizontal,
                    axisAlignment: 1.0,
                    child: child,
                  );
                },
                child: _searchActive
                    ? _SearchBar(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        resultCount: _searchResultCount,
                        currentResult: _currentSearchResultIndex,
                        onChanged: (q) => _runSearch(q, verses),
                        onPrevious: () => _navigateSearchResult(-1, verses),
                        onNext: () => _navigateSearchResult(1, verses),
                        onClose: _closeSearch,
                      )
                    : const SizedBox.shrink(),
              ),
              if (!_searchActive)
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Search chapter',
                  onPressed: _openSearch,
                ),
              // ──────────────────────────────────────────────────────────
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

                    final baseColor = userHighlight?.withValues(alpha: 0.25) ?? Colors.transparent;

                    final isFlashing = _flashVerseIndex == i;
                    final flashOverlay = searchHighlightColor.withValues(alpha: isFlashing ? 0.5 : 0.0);

                    final isSelected = _selectedVerses.contains(i);
                    final selectionHighlight =
                        isSelected ? Colors.blue.withValues(alpha: 0.3) : Colors.transparent;

                    final hasSearchMatch =
                        _searchMatches.containsKey(i) && _searchQuery.isNotEmpty;

                    final backgroundColor = (_shareMode || _copyMode)
                        ? Color.lerp(baseColor, selectionHighlight, isSelected ? 1.0 : 0.0)!
                        : isFlashing
                            ? Color.lerp(baseColor, flashOverlay, 1.0)!
                            : hasSearchMatch
                                ? Color.lerp(
                                    baseColor,
                                    searchHighlightColor.withValues(alpha: 0.08),
                                    1.0,
                                  )!
                                : baseColor;

                    final isBookmarked = bookmarkNotifier.isBookmarked(
                      widget.bookIndex,
                      widget.chapterIndex,
                      i,
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            if (_highlightMode) {
                              _toggleHighlight(i);
                            } else if (_shareMode || _copyMode) {
                              _toggleVerseSelection(i);
                            }
                          },
                          onLongPress: () {
                            _showVerseOptions(
                              context,
                              ref,
                              i,
                              verseText,
                              isBookmarked,
                              verses,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: RichText(
                              text: _buildVerseTextSpan(
                                verseIndex: i,
                                verseText: verseText,
                                isBookmarked: isBookmarked,
                                searchHighlightColor: searchHighlightColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if ((_shareMode || _copyMode) && _selectedVerses.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF191919),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26, blurRadius: 8, offset: Offset(0, -2)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_selectedVerses.length} verse${_selectedVerses.length > 1 ? 's' : ''} selected',
                        style: const TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (_shareMode)
                            ElevatedButton.icon(
                              onPressed: () => _shareSelectedVerses(verses),
                              icon: const Icon(Icons.share),
                              label: const Text('Share'),
                            ),
                          if (_copyMode)
                            ElevatedButton.icon(
                              onPressed: () => _copySelectedVersesToClipboard(verses),
                              icon: const Icon(Icons.copy),
                              label: const Text('Copy'),
                            ),
                          if (_shareMode)
                            ElevatedButton.icon(
                              onPressed: () => _copySelectedVersesToClipboard(verses),
                              icon: const Icon(Icons.copy),
                              label: const Text('Copy'),
                            ),
                        ],
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

// ── Search bar widget ─────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int resultCount;
  final int currentResult;
  final ValueChanged<String> onChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onClose;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.resultCount,
    required this.currentResult,
    required this.onChanged,
    required this.onPrevious,
    required this.onNext,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 180,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onNext(),
            style: const TextStyle(color: Colors.white, fontSize: 15),
            cursorColor: Colors.white70,
            decoration: InputDecoration(
              hintText: 'Search verse…',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (resultCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            '$currentResult/$resultCount',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up, size: 20),
            tooltip: 'Previous result',
            onPressed: onPrevious,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            tooltip: 'Next result',
            onPressed: onNext,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ] else if (controller.text.isNotEmpty) ...[
          const SizedBox(width: 6),
          const Text(
            'No results',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
        IconButton(
          icon: const Icon(Icons.close, size: 20),
          tooltip: 'Close search',
          onPressed: onClose,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}

// ── Existing unchanged widgets ────────────────────────────────────────────────

class _ResponsiveChapterTitle extends StatelessWidget {
  final String bookTitle;
  final int chapterNumber;
  final String Function(String, String) getAbbreviation;

  const _ResponsiveChapterTitle({
    required this.bookTitle,
    required this.chapterNumber,
    required this.getAbbreviation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        String title;

        if (width > 200) {
          title = '$bookTitle - Chapter $chapterNumber';
        } else if (width > 140) {
          final mediumAbbrev = getAbbreviation(bookTitle, 'medium');
          title = '$mediumAbbrev - Ch $chapterNumber';
        } else if (width > 100) {
          final shortAbbrev = getAbbreviation(bookTitle, 'short');
          title = '$shortAbbrev - Ch $chapterNumber';
        } else {
          final shortAbbrev = getAbbreviation(bookTitle, 'short');
          title = '$shortAbbrev $chapterNumber';
        }

        return Text(
          title,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        );
      },
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