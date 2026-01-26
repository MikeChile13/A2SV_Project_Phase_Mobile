import '../models/product_model.dart';

/// LocalDataSource defines the contract for local data operations
/// This abstract class ensures that any local storage implementation
/// (SQLite, Hive, shared preferences, etc.) handles data consistently
/// following the Dependency Inversion Principle
abstract class LocalDataSource {
  /// Fetch a product by ID from local storage
  /// Returns the ProductModel if found
  /// Throws an exception if the product doesn't exist or operation fails
  Future<ProductModel> getProduct(String productId);

  /// Fetch all products from local storage
  /// Returns a list of ProductModel
  /// Throws an exception if the operation fails
  Future<List<ProductModel>> getAllProducts();

  /// Cache a single product to local storage
  /// Used to store products fetched from remote source locally
  /// Throws an exception if the operation fails
  Future<void> cacheProduct(ProductModel product);

  /// Cache a list of products to local storage
  /// Used to store multiple products fetched from remote source
  /// Overwrites existing data
  /// Throws an exception if the operation fails
  Future<void> cacheProducts(List<ProductModel> products);

  /// Create a new product in local storage
  /// Throws an exception if the operation fails
  Future<void> createProduct(ProductModel product);

  /// Update an existing product in local storage
  /// Throws an exception if the product doesn't exist or operation fails
  Future<void> updateProduct(ProductModel product);

  /// Delete a product from local storage by ID
  /// Throws an exception if the product doesn't exist or operation fails
  Future<void> deleteProduct(String productId);

  /// Clear all products from local storage
  /// Useful for logout or cache refresh operations
  /// Throws an exception if the operation fails
  Future<void> clearAllProducts();

  /// Check if a product exists in local storage
  /// Returns true if the product exists, false otherwise
  /// Throws an exception if the operation fails
  Future<bool> productExists(String productId);
}
