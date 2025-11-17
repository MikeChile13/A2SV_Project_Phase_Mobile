class BibleBook {
  final String? name;
  final String abbrev;
  final List<List<String>> chapters;

  BibleBook({
    this.name,
    required this.abbrev,
    required this.chapters,
  });

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    // Some JSON variants include a 'name' key; if not, it's null.
    final rawChapters = json['chapters'] as List<dynamic>;
    final chapters = rawChapters.map<List<String>>((ch) {
      return List<String>.from(ch as List<dynamic>);
    }).toList();

    return BibleBook(
      name: json['name'] as String?,
      abbrev: json['abbrev'] as String,
      chapters: chapters,
    );
  }
}
