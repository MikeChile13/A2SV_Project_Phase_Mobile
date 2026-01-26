import 'dart:typed_data';

class Product {
  final String name;
  final String category;
  final double price;
  final Uint8List imageBytes; // image data usable on all platforms
  final String description;

  Product({
    required this.name,
    required this.category,
    required this.price,
    required this.imageBytes,
    required this.description,
  });
}
