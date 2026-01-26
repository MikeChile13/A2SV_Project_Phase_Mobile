import '../models/product_model.dart';

/// RemoteDataSource defines the contract for remote data operations
/// This abstract class ensures that any implementation handles API calls
/// in a consistent manner, following the Dependency Inversion Principle
abstract class RemoteDataSource {
  /// Fetch a product by ID from remote source
  /// Returns the ProductModel if successful
  /// Throws an exception if the operation fails
  Future<ProductModel> getProduct(String productId);

  /// Fetch all products from remote source
  /// Returns a list of ProductModel
  /// Throws an exception if the operation fails
  Future<List<ProductModel>> getAllProducts();

  /// Create a new product on the remote source
  /// Takes a ProductModel and returns the created product
  /// Throws an exception if the operation fails
  Future<ProductModel> createProduct(ProductModel product);

  /// Update an existing product on the remote source
  /// Takes a ProductModel with updated data
  /// Throws an exception if the operation fails
  Future<ProductModel> updateProduct(ProductModel product);

  /// Delete a product from the remote source
  /// Takes the product ID to delete
  /// Returns true if successful, false otherwise
  /// Throws an exception if the operation fails
  Future<bool> deleteProduct(String productId);

  /// Search products on the remote source by query
  /// Returns a list of matching ProductModel
  /// Throws an exception if the operation fails
  Future<List<ProductModel>> searchProducts(String query);
}
