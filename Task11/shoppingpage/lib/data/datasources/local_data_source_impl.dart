import '../models/product_model.dart';
import 'local_data_source.dart';

/// Local Data Source Implementation
/// This is a concrete implementation of LocalDataSource
/// In a real application, this would use SQLite, Hive, or other local storage solutions
/// For this demonstration, it uses an in-memory map to simulate local storage
class LocalDataSourceImpl implements LocalDataSource {
  /// In-memory storage for local caching
  /// In production, this would be replaced with actual database operations
  final Map<String, ProductModel> _localCache = {};

  @override
  Future<ProductModel> getProduct(String productId) async {
    // Simulate database query delay
    await Future.delayed(const Duration(milliseconds: 50));

    final product = _localCache[productId];
    if (product == null) {
      throw Exception('Product not found in local cache: $productId');
    }

    return product;
  }

  @override
  Future<List<ProductModel>> getAllProducts() async {
    // Simulate database query delay
    await Future.delayed(const Duration(milliseconds: 100));

    return _localCache.values.toList();
  }

  @override
  Future<void> cacheProduct(ProductModel product) async {
    // Simulate database write delay
    await Future.delayed(const Duration(milliseconds: 50));

    _localCache[product.id] = product;
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    // Simulate database write delay
    await Future.delayed(const Duration(milliseconds: 100));

    // Clear existing cache and add new products
    _localCache.clear();
    for (final product in products) {
      _localCache[product.id] = product;
    }
  }

  @override
  Future<void> createProduct(ProductModel product) async {
    // Simulate database write delay
    await Future.delayed(const Duration(milliseconds: 50));

    if (_localCache.containsKey(product.id)) {
      throw Exception('Product with ID ${product.id} already exists locally');
    }

    _localCache[product.id] = product;
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    // Simulate database write delay
    await Future.delayed(const Duration(milliseconds: 50));

    if (!_localCache.containsKey(product.id)) {
      throw Exception('Product with ID ${product.id} not found locally');
    }

    _localCache[product.id] = product;
  }

  @override
  Future<void> deleteProduct(String productId) async {
    // Simulate database write delay
    await Future.delayed(const Duration(milliseconds: 50));

    if (!_localCache.containsKey(productId)) {
      throw Exception('Product with ID $productId not found locally');
    }

    _localCache.remove(productId);
  }

  @override
  Future<void> clearAllProducts() async {
    // Simulate database operation delay
    await Future.delayed(const Duration(milliseconds: 50));

    _localCache.clear();
  }

  @override
  Future<bool> productExists(String productId) async {
    // Simulate database query delay
    await Future.delayed(const Duration(milliseconds: 30));

    return _localCache.containsKey(productId);
  }

  /// Helper method to get cache size (useful for testing and monitoring)
  int getCacheSize() {
    return _localCache.length;
  }
}
