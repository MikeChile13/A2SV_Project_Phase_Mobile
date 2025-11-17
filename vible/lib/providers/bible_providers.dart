import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bible_book.dart';
import '../services/bible_service.dart';

// A FutureProvider that loads the list of books once and caches via Riverpod.
final bibleProvider = FutureProvider<List<BibleBook>>((ref) async {
  return BibleService.loadFromAssets();
});
