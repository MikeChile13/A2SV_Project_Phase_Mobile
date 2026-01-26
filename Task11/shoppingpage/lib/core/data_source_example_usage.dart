/// Example Usage of Data Source Contracts
/// This file demonstrates how to use the repository with data source contracts
/// in your Flutter application

import 'package:shoppingpage/core/service_locator.dart';
import 'package:shoppingpage/data/datasources/local_data_source_impl.dart';
import 'package:shoppingpage/data/datasources/remote_data_source_impl.dart';
import 'package:shoppingpage/data/models/product_model.dart';
import 'package:shoppingpage/domain/entities/product_entity.dart';
import 'package:shoppingpage/domain/repositories/product_repository.dart';

/// Example 1: Initialize Service Locator at App Startup
void initializeApp() {
  final serviceLocator = ServiceLocator();
  serviceLocator.setupDependencies();
  // Dependencies are now ready to be used throughout the app
}

/// Example 2: Get Repository Instance
void exampleGetRepository() {
  final serviceLocator = ServiceLocator();
  
  // Get the repository instance
  // Note: We access the abstract type, not the concrete implementation
  final ProductRepository repository = serviceLocator.productRepository;
  
  // The repository is now ready for use
  print('Repository instance obtained: $repository');
}

/// Example 3: Fetch All Products
Future<void> exampleGetAllProducts() async {
  final serviceLocator = ServiceLocator();
  final repository = serviceLocator.productRepository;
  
  // Call the repository method
  final (products, failure) = await repository.getAllProducts();
  
  if (failure != null) {
    // Handle error
    print('Error: ${failure.message}');
  } else if (products != null) {
    // Use products
    print('Fetched ${products.length} products');
    for (final product in products) {
      print('Product: ${product.name} - \$${product.price}');
    }
  }
}

/// Example 4: Get Single Product
Future<void> exampleGetProduct(String productId) async {
  final serviceLocator = ServiceLocator();
  final repository = serviceLocator.productRepository;
  
  final (product, failure) = await repository.getProduct(productId);
  
  if (failure != null) {
    print('Error: ${failure.message}');
  } else if (product != null) {
    print('Product: ${product.name}');
    print('Price: \$${product.price}');
    print('Description: ${product.description}');
  }
}

/// Example 5: Insert New Product
Future<void> exampleInsertProduct() async {
  final serviceLocator = ServiceLocator();
  final repository = serviceLocator.productRepository;
  
  // Create a product entity
  final newProduct = ProductEntity(
    id: 'prod_001',
    name: 'Laptop',
    description: 'High-performance laptop',
    price: 1299.99,
    imageUrl: 'https://example.com/laptop.jpg',
  );
  
  // Insert the product
  final (createdProduct, failure) = await repository.insertProduct(newProduct);
  
  if (failure != null) {
    print('Error: ${failure.message}');
  } else if (createdProduct != null) {
    print('Product created successfully: ${createdProduct.name}');
  }
}

/// Example 6: Update Existing Product
Future<void> exampleUpdateProduct(ProductEntity product) async {
  final serviceLocator = ServiceLocator();
  final repository = serviceLocator.productRepository;
  
  // Modify the product
  final updatedProduct = product.copyWith(
    price: 999.99, // New price
  );
  
  // Update the product
  final (result, failure) = await repository.updateProduct(updatedProduct);
  
  if (failure != null) {
    print('Error: ${failure.message}');
  } else if (result != null) {
    print('Product updated: ${result.name} - New price: \$${result.price}');
  }
}

/// Example 7: Delete Product
Future<void> exampleDeleteProduct(String productId) async {
  final serviceLocator = ServiceLocator();
  final repository = serviceLocator.productRepository;
  
  final (success, failure) = await repository.deleteProduct(productId);
  
  if (failure != null) {
    print('Error: ${failure.message}');
  } else if (success) {
    print('Product deleted successfully');
  }
}

/// Example 8: Working with Data Sources Directly
/// This is useful when you need to interact with specific data sources
void exampleDirectDataSourceAccess() {
  final serviceLocator = ServiceLocator();
  
  // Access data sources directly (useful for advanced scenarios)
  final remoteDataSource = serviceLocator.remoteDataSource;
  final localDataSource = serviceLocator.localDataSource;
  
  print('Remote Data Source: $remoteDataSource');
  print('Local Data Source: $localDataSource');
}

/// Example 9: Testing with Mock Data Sources
/// This demonstrates how to test with mock implementations
class MockRemoteDataSource implements RemoteDataSourceImpl {
  @override
  Future<ProductModel> getProduct(String productId) async {
    return ProductModel(
      id: productId,
      name: 'Test Product',
      description: 'Test Description',
      price: 99.99,
      imageUrl: 'https://example.com/test.jpg',
    );
  }
  
  @override
  Future<List<ProductModel>> getAllProducts() async {
    return [
      ProductModel(
        id: 'test_1',
        name: 'Test Product 1',
        description: 'Test Description 1',
        price: 99.99,
        imageUrl: 'https://example.com/test1.jpg',
      ),
      ProductModel(
        id: 'test_2',
        name: 'Test Product 2',
        description: 'Test Description 2',
        price: 199.99,
        imageUrl: 'https://example.com/test2.jpg',
      ),
    ];
  }
  
  @override
  Future<ProductModel> createProduct(ProductModel product) async => product;
  
  @override
  Future<ProductModel> updateProduct(ProductModel product) async => product;
  
  @override
  Future<bool> deleteProduct(String productId) async => true;
  
  @override
  Future<List<ProductModel>> searchProducts(String query) async => [];
}

/// Example 10: Complete CRUD Operations Flow
Future<void> exampleCompleteFlow() async {
  final serviceLocator = ServiceLocator();
  final repository = serviceLocator.productRepository;
  
  print('=== Complete CRUD Operations Flow ===\n');
  
  // Create
  print('1. Creating a new product...');
  final newProduct = ProductEntity(
    id: 'laptop_001',
    name: 'MacBook Pro',
    description: 'Professional laptop for developers',
    price: 2499.99,
    imageUrl: 'https://example.com/macbook.jpg',
  );
  
  final (created, createError) = await repository.insertProduct(newProduct);
  if (createError != null) {
    print('   Error: ${createError.message}');
  } else {
    print('   ✓ Product created: ${created?.name}\n');
  }
  
  // Read
  print('2. Reading the created product...');
  final (retrieved, readError) = await repository.getProduct('laptop_001');
  if (readError != null) {
    print('   Error: ${readError.message}');
  } else {
    print('   ✓ Product retrieved: ${retrieved?.name}');
    print('   ✓ Price: \$${retrieved?.price}\n');
  }
  
  // Update
  print('3. Updating product price...');
  final updatedProduct = retrieved!.copyWith(price: 2299.99);
  final (updated, updateError) = await repository.updateProduct(updatedProduct);
  if (updateError != null) {
    print('   Error: ${updateError.message}');
  } else {
    print('   ✓ Product updated: ${updated?.name}');
    print('   ✓ New price: \$${updated?.price}\n');
  }
  
  // List all
  print('4. Fetching all products...');
  final (all, listError) = await repository.getAllProducts();
  if (listError != null) {
    print('   Error: ${listError.message}');
  } else {
    print('   ✓ Total products: ${all?.length}\n');
  }
  
  // Delete
  print('5. Deleting the product...');
  final (deleted, deleteError) = await repository.deleteProduct('laptop_001');
  if (deleteError != null) {
    print('   Error: ${deleteError.message}');
  } else if (deleted) {
    print('   ✓ Product deleted successfully\n');
  }
  
  print('=== Flow Completed ===');
}

// Usage in main.dart or app initialization:
// void main() {
//   initializeApp(); // Initialize all dependencies
//   runApp(const MyApp());
// }
