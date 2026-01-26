import '../models/product_model.dart';
import 'remote_data_source.dart';

/// Remote Data Source Implementation
/// This is a concrete implementation of RemoteDataSource
/// In a real application, this would make actual HTTP requests
/// For this demonstration, it simulates API responses
class RemoteDataSourceImpl implements RemoteDataSource {
  /// In-memory storage for demonstration purposes
  /// In production, this would be replaced with actual HTTP client calls
  final Map<String, ProductModel> _remoteStorage = {};

  /// Flag to simulate network errors
  /// Useful for testing error handling
  bool shouldThrowException = false;

  @override
  Future<ProductModel> getProduct(String productId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    if (shouldThrowException) {
      throw Exception('Network error: Failed to fetch product');
    }

    final product = _remoteStorage[productId];
    if (product == null) {
      throw Exception('Product not found on remote server: $productId');
    }

    return product;
  }

  @override
  Future<List<ProductModel>> getAllProducts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    if (shouldThrowException) {
      throw Exception('Network error: Failed to fetch products');
    }

    return _remoteStorage.values.toList();
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    if (shouldThrowException) {
      throw Exception('Network error: Failed to create product');
    }

    if (_remoteStorage.containsKey(product.id)) {
      throw Exception('Product with ID ${product.id} already exists');
    }

    _remoteStorage[product.id] = product;
    return product;
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    if (shouldThrowException) {
      throw Exception('Network error: Failed to update product');
    }

    if (!_remoteStorage.containsKey(product.id)) {
      throw Exception('Product with ID ${product.id} not found on server');
    }

    _remoteStorage[product.id] = product;
    return product;
  }

  @override
  Future<bool> deleteProduct(String productId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    if (shouldThrowException) {
      throw Exception('Network error: Failed to delete product');
    }

    if (!_remoteStorage.containsKey(productId)) {
      throw Exception('Product with ID $productId not found on server');
    }

    _remoteStorage.remove(productId);
    return true;
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    if (shouldThrowException) {
      throw Exception('Network error: Failed to search products');
    }

    final results = _remoteStorage.values
        .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.description.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return results;
  }

  /// Helper method to populate test data
  /// In production, this is not needed as data comes from remote API
  void addTestProduct(ProductModel product) {
    _remoteStorage[product.id] = product;
  }

  /// Helper method to clear test data
  void clearTestData() {
    _remoteStorage.clear();
  }
}
