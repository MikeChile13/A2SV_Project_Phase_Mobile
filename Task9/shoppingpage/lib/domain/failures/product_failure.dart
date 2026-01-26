/// Failure represents an error state in the application
/// Following Clean Architecture principles
abstract class Failure {
  final String message;

  Failure({required this.message});
}

/// ProductFailure for product-related errors
class ProductFailure extends Failure {
  ProductFailure({required super.message});
}

/// ProductNotFoundFailure when a product doesn't exist
class ProductNotFoundFailure extends ProductFailure {
  ProductNotFoundFailure({
    required String productId,
  }) : super(message: 'Product with id $productId not found');
}

/// InvalidProductFailure for invalid product data
class InvalidProductFailure extends ProductFailure {
  InvalidProductFailure({
    required String reason,
  }) : super(message: 'Invalid product data: $reason');
}
