import '../entities/product_entity.dart';
import '../failures/product_failure.dart';

/// ProductRepository interface
/// Defines the contract for product data operations
/// Following the Dependency Inversion Principle
abstract class ProductRepository {
  /// Insert a new product
  /// Returns the created product or a ProductFailure
  Future<(ProductEntity?, ProductFailure?)> insertProduct(
    ProductEntity product,
  );

  /// Update an existing product
  /// Returns the updated product or a ProductFailure
  Future<(ProductEntity?, ProductFailure?)> updateProduct(
    ProductEntity product,
  );

  /// Delete a product by ID
  /// Returns true if deletion was successful, false otherwise with ProductFailure
  Future<(bool, ProductFailure?)> deleteProduct(String productId);

  /// Get a product by ID
  /// Returns the product or a ProductFailure
  Future<(ProductEntity?, ProductFailure?)> getProduct(String productId);

  /// Get all products
  /// Returns a list of products or a ProductFailure
  Future<(List<ProductEntity>?, ProductFailure?)> getAllProducts();
}
