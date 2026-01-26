import '../../domain/entities/product_entity.dart';
import '../../domain/failures/product_failure.dart';
import '../../domain/repositories/product_repository.dart';

/// In-memory implementation of ProductRepository
/// Uses a Map to store products for demonstration and testing
/// In a real application, this would interact with a database or remote API
class ProductRepositoryImpl extends ProductRepository {
  /// In-memory storage for products
  final Map<String, ProductEntity> _products = {};

  @override
  Future<(ProductEntity?, ProductFailure?)> insertProduct(
    ProductEntity product,
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 100));

      // Check if product already exists
      if (_products.containsKey(product.id)) {
        return (
          null,
          ProductFailure(
            message: 'Product with id ${product.id} already exists',
          ),
        );
      }

      // Add product to storage
      _products[product.id] = product;
      return (product, null);
    } catch (e) {
      return (
        null,
        ProductFailure(message: 'Error inserting product: ${e.toString()}'),
      );
    }
  }

  @override
  Future<(ProductEntity?, ProductFailure?)> updateProduct(
    ProductEntity product,
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 100));

      // Check if product exists
      if (!_products.containsKey(product.id)) {
        return (
          null,
          ProductNotFoundFailure(productId: product.id),
        );
      }

      // Update product
      _products[product.id] = product;
      return (product, null);
    } catch (e) {
      return (
        null,
        ProductFailure(message: 'Error updating product: ${e.toString()}'),
      );
    }
  }

  @override
  Future<(bool, ProductFailure?)> deleteProduct(String productId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 100));

      // Check if product exists
      if (!_products.containsKey(productId)) {
        return (
          false,
          ProductNotFoundFailure(productId: productId),
        );
      }

      // Delete product
      _products.remove(productId);
      return (true, null);
    } catch (e) {
      return (
        false,
        ProductFailure(message: 'Error deleting product: ${e.toString()}'),
      );
    }
  }

  @override
  Future<(ProductEntity?, ProductFailure?)> getProduct(
    String productId,
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 100));

      // Get product from storage
      final product = _products[productId];
      if (product == null) {
        return (
          null,
          ProductNotFoundFailure(productId: productId),
        );
      }

      return (product, null);
    } catch (e) {
      return (
        null,
        ProductFailure(
          message: 'Error retrieving product: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<(List<ProductEntity>?, ProductFailure?)> getAllProducts() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 100));

      // Return all products
      final products = _products.values.toList();
      return (products, null);
    } catch (e) {
      return (
        null,
        ProductFailure(
          message: 'Error retrieving products: ${e.toString()}',
        ),
      );
    }
  }

  /// Clear all products (useful for testing)
  void clearAllProducts() {
    _products.clear();
  }

  /// Get the number of products (useful for testing)
  int getProductCount() {
    return _products.length;
  }
}
