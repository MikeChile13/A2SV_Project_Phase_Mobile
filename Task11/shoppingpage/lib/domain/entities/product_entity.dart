/// Product Entity
/// Represents a product in the eCommerce application.
/// This is a pure entity with no dependencies on external libraries.
class ProductEntity {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  /// Create a copy of ProductEntity with optional field replacements
  ProductEntity copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          price == other.price &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      price.hashCode ^
      imageUrl.hashCode;

  @override
  String toString() =>
      'ProductEntity(id: $id, name: $name, description: $description, price: $price, imageUrl: $imageUrl)';
}
