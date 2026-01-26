import 'package:flutter_test/flutter_test.dart';
import 'package:shoppingpage/data/datasources/local_data_source.dart';
import 'package:shoppingpage/data/datasources/local_data_source_impl.dart';
import 'package:shoppingpage/data/datasources/remote_data_source.dart';
import 'package:shoppingpage/data/models/product_model.dart';
import 'package:shoppingpage/data/repositories/product_repository_impl.dart';
import 'package:shoppingpage/domain/entities/product_entity.dart';
import 'package:shoppingpage/domain/repositories/product_repository.dart';

// ============= Mock Implementations =============

/// Mock RemoteDataSource for testing
/// Allows simulating network failures and custom responses
class MockRemoteDataSource implements RemoteDataSource {
  // Flag to simulate network errors
  bool shouldThrowException = false;
  
  // Storage for test data
  final Map<String, ProductModel> _testData = {};
  
  // Track method calls (useful for verifying interactions)
  int getProductCallCount = 0;
  int getAllProductsCallCount = 0;
  int createProductCallCount = 0;
  int updateProductCallCount = 0;
  int deleteProductCallCount = 0;
  
  @override
  Future<ProductModel> getProduct(String productId) async {
    getProductCallCount++;
    
    if (shouldThrowException) {
      throw Exception('Mock network error');
    }
    
    final product = _testData[productId];
    if (product == null) {
      throw Exception('Product not found: $productId');
    }
    return product;
  }
  
  @override
  Future<List<ProductModel>> getAllProducts() async {
    getAllProductsCallCount++;
    
    if (shouldThrowException) {
      throw Exception('Mock network error');
    }
    
    return _testData.values.toList();
  }
  
  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    createProductCallCount++;
    
    if (shouldThrowException) {
      throw Exception('Mock network error');
    }
    
    _testData[product.id] = product;
    return product;
  }
  
  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    updateProductCallCount++;
    
    if (shouldThrowException) {
      throw Exception('Mock network error');
    }
    
    if (!_testData.containsKey(product.id)) {
      throw Exception('Product not found: ${product.id}');
    }
    
    _testData[product.id] = product;
    return product;
  }
  
  @override
  Future<bool> deleteProduct(String productId) async {
    deleteProductCallCount++;
    
    if (shouldThrowException) {
      throw Exception('Mock network error');
    }
    
    if (!_testData.containsKey(productId)) {
      throw Exception('Product not found: $productId');
    }
    
    _testData.remove(productId);
    return true;
  }
  
  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    if (shouldThrowException) {
      throw Exception('Mock network error');
    }
    
    return _testData.values
        .where((p) => p.name.contains(query) || p.description.contains(query))
        .toList();
  }
  
  /// Add test data
  void addTestData(ProductModel product) {
    _testData[product.id] = product;
  }
  
  /// Clear all test data
  void clearTestData() {
    _testData.clear();
    getProductCallCount = 0;
    getAllProductsCallCount = 0;
    createProductCallCount = 0;
    updateProductCallCount = 0;
    deleteProductCallCount = 0;
  }
}

/// Mock LocalDataSource for testing
class MockLocalDataSource implements LocalDataSource {
  // Storage for cached data
  final Map<String, ProductModel> _cache = {};
  
  // Track method calls
  int getProductCallCount = 0;
  int getAllProductsCallCount = 0;
  int cacheProductCallCount = 0;
  int createProductCallCount = 0;
  int deleteProductCallCount = 0;
  
  bool shouldThrowException = false;
  
  @override
  Future<ProductModel> getProduct(String productId) async {
    getProductCallCount++;
    
    if (shouldThrowException) {
      throw Exception('Mock local error');
    }
    
    final product = _cache[productId];
    if (product == null) {
      throw Exception('Product not found in cache: $productId');
    }
    return product;
  }
  
  @override
  Future<List<ProductModel>> getAllProducts() async {
    getAllProductsCallCount++;
    
    if (shouldThrowException) {
      throw Exception('Mock local error');
    }
    
    return _cache.values.toList();
  }
  
  @override
  Future<void> cacheProduct(ProductModel product) async {
    cacheProductCallCount++;
    
    if (shouldThrowException) {
      throw Exception('Mock local error');
    }
    
    _cache[product.id] = product;
  }
  
  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    _cache.clear();
    for (final product in products) {
      _cache[product.id] = product;
    }
  }
  
  @override
  Future<void> createProduct(ProductModel product) async {
    createProductCallCount++;
    
    if (shouldThrowException) {
      throw Exception('Mock local error');
    }
    
    _cache[product.id] = product;
  }
  
  @override
  Future<void> updateProduct(ProductModel product) async {
    if (!_cache.containsKey(product.id)) {
      throw Exception('Product not found in cache: ${product.id}');
    }
    _cache[product.id] = product;
  }
  
  @override
  Future<void> deleteProduct(String productId) async {
    if (!_cache.containsKey(productId)) {
      throw Exception('Product not found in cache: $productId');
    }
    _cache.remove(productId);
  }
  
  @override
  Future<void> clearAllProducts() async {
    _cache.clear();
  }
  
  @override
  Future<bool> productExists(String productId) async {
    return _cache.containsKey(productId);
  }
  
  /// Clear test data and reset counters
  void reset() {
    _cache.clear();
    getProductCallCount = 0;
    getAllProductsCallCount = 0;
    cacheProductCallCount = 0;
    createProductCallCount = 0;
    deleteProductCallCount = 0;
  }
}

// ============= Test Helper Data =============

/// Create test product model
ProductModel createTestProductModel({
  String id = 'test_001',
  String name = 'Test Product',
  String description = 'Test Description',
  double price = 99.99,
  String imageUrl = 'https://example.com/test.jpg',
}) {
  return ProductModel(
    id: id,
    name: name,
    description: description,
    price: price,
    imageUrl: imageUrl,
  );
}

/// Create test product entity
ProductEntity createTestProductEntity({
  String id = 'test_001',
  String name = 'Test Product',
  String description = 'Test Description',
  double price = 99.99,
  String imageUrl = 'https://example.com/test.jpg',
}) {
  return ProductEntity(
    id: id,
    name: name,
    description: description,
    price: price,
    imageUrl: imageUrl,
  );
}

// ============= Test Suites =============

void main() {
  group('Data Source Contracts Tests', () {
    late MockRemoteDataSource mockRemoteDataSource;
    late MockLocalDataSource mockLocalDataSource;
    late ProductRepository repository;
    
    setUp(() {
      // Initialize mocks for each test
      mockRemoteDataSource = MockRemoteDataSource();
      mockLocalDataSource = MockLocalDataSource();
      
      // Create repository with mock data sources
      repository = ProductRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        localDataSource: mockLocalDataSource,
      );
    });
    
    tearDown(() {
      // Clean up after each test
      mockRemoteDataSource.clearTestData();
      mockLocalDataSource.reset();
    });
    
    // ============= GetAllProducts Tests =============
    
    group('getAllProducts', () {
      test('should return products from remote when available', () async {
        // Arrange
        final testProducts = [
          createTestProductModel(id: '1', name: 'Product 1'),
          createTestProductModel(id: '2', name: 'Product 2'),
        ];
        for (final product in testProducts) {
          mockRemoteDataSource.addTestData(product);
        }
        
        // Act
        final (result, error) = await repository.getAllProducts();
        
        // Assert
        expect(error, isNull);
        expect(result, isNotNull);
        expect(result?.length, equals(2));
        expect(result?[0].name, equals('Product 1'));
        expect(result?[1].name, equals('Product 2'));
      });
      
      test('should cache products from remote locally', () async {
        // Arrange
        final testProducts = [
          createTestProductModel(id: '1', name: 'Product 1'),
        ];
        for (final product in testProducts) {
          mockRemoteDataSource.addTestData(product);
        }
        
        // Act
        await repository.getAllProducts();
        
        // Assert - verify caching occurred
        expect(mockLocalDataSource.cacheProductCallCount, greaterThan(0));
      });
      
      test('should return cached products when remote fails', () async {
        // Arrange
        final cachedProduct = createTestProductModel(id: '1', name: 'Cached Product');
        await mockLocalDataSource.cacheProduct(
          ProductModel.fromEntity(cachedProduct.toEntity()),
        );
        
        // Simulate remote failure
        mockRemoteDataSource.shouldThrowException = true;
        
        // Act
        final (result, error) = await repository.getAllProducts();
        
        // Assert
        expect(error, isNull); // Should not error due to fallback
        expect(result, isNotNull);
        expect(result?.length, equals(1));
      });
      
      test('should return error when both remote and local fail', () async {
        // Arrange
        mockRemoteDataSource.shouldThrowException = true;
        mockLocalDataSource.shouldThrowException = true;
        
        // Act
        final (result, error) = await repository.getAllProducts();
        
        // Assert
        expect(result, isNull);
        expect(error, isNotNull);
      });
    });
    
    // ============= GetProduct Tests =============
    
    group('getProduct', () {
      test('should get product from remote', () async {
        // Arrange
        final testProduct = createTestProductModel(id: '123', name: 'Test Item');
        mockRemoteDataSource.addTestData(testProduct);
        
        // Act
        final (result, error) = await repository.getProduct('123');
        
        // Assert
        expect(error, isNull);
        expect(result, isNotNull);
        expect(result?.name, equals('Test Item'));
      });
      
      test('should fall back to local cache when remote fails', () async {
        // Arrange
        final cachedProduct = createTestProductModel(id: '123', name: 'Cached Item');
        await mockLocalDataSource.cacheProduct(
          ProductModel.fromEntity(cachedProduct.toEntity()),
        );
        mockRemoteDataSource.shouldThrowException = true;
        
        // Act
        final (result, error) = await repository.getProduct('123');
        
        // Assert
        expect(error, isNull);
        expect(result?.name, equals('Cached Item'));
      });
    });
    
    // ============= InsertProduct Tests =============
    
    group('insertProduct', () {
      test('should insert product via remote datasource', () async {
        // Arrange
        final testProduct = createTestProductEntity(id: '1', name: 'New Product');
        
        // Act
        final (result, error) = await repository.insertProduct(testProduct);
        
        // Assert
        expect(error, isNull);
        expect(result, isNotNull);
        expect(result?.name, equals('New Product'));
        expect(mockRemoteDataSource.createProductCallCount, equals(1));
      });
      
      test('should cache product after remote insert', () async {
        // Arrange
        final testProduct = createTestProductEntity(id: '1', name: 'New Product');
        
        // Act
        await repository.insertProduct(testProduct);
        
        // Assert
        expect(mockLocalDataSource.cacheProductCallCount, greaterThan(0));
      });
      
      test('should return error when remote insert fails', () async {
        // Arrange
        mockRemoteDataSource.shouldThrowException = true;
        final testProduct = createTestProductEntity(id: '1', name: 'New Product');
        
        // Act
        final (result, error) = await repository.insertProduct(testProduct);
        
        // Assert
        expect(result, isNull);
        expect(error, isNotNull);
      });
    });
    
    // ============= UpdateProduct Tests =============
    
    group('updateProduct', () {
      test('should update product via remote datasource', () async {
        // Arrange
        final originalProduct = createTestProductModel(id: '1', name: 'Original', price: 50.0);
        mockRemoteDataSource.addTestData(originalProduct);
        
        final updatedEntity = ProductEntity(
          id: '1',
          name: 'Updated',
          description: 'Original Description',
          price: 75.0,
          imageUrl: 'https://example.com/test.jpg',
        );
        
        // Act
        final (result, error) = await repository.updateProduct(updatedEntity);
        
        // Assert
        expect(error, isNull);
        expect(result?.name, equals('Updated'));
        expect(result?.price, equals(75.0));
      });
    });
    
    // ============= DeleteProduct Tests =============
    
    group('deleteProduct', () {
      test('should delete product via remote datasource', () async {
        // Arrange
        final testProduct = createTestProductModel(id: '1', name: 'To Delete');
        mockRemoteDataSource.addTestData(testProduct);
        
        // Act
        final (success, error) = await repository.deleteProduct('1');
        
        // Assert
        expect(error, isNull);
        expect(success, isTrue);
      });
      
      test('should return error when delete fails on both sources', () async {
        // Arrange
        mockRemoteDataSource.shouldThrowException = true;
        
        // Act
        final (success, error) = await repository.deleteProduct('999');
        
        // Assert
        expect(success, isFalse);
        expect(error, isNotNull);
      });
    });
    
    // ============= Contract Adherence Tests =============
    
    group('Contract Adherence', () {
      test('RemoteDataSource contract is implemented', () {
        // Verify that RemoteDataSource is properly implemented
        expect(mockRemoteDataSource, isA<RemoteDataSource>());
      });
      
      test('LocalDataSource contract is implemented', () {
        // Verify that LocalDataSource is properly implemented
        expect(mockLocalDataSource, isA<LocalDataSource>());
      });
      
      test('ProductRepository contract is implemented', () {
        // Verify that ProductRepository is properly implemented
        expect(repository, isA<ProductRepository>());
      });
    });
  });
}
