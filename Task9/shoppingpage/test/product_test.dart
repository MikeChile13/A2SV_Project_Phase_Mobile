import 'package:flutter_test/flutter_test.dart';
import 'package:shoppingpage/data/repositories/product_repository_impl.dart';
import 'package:shoppingpage/domain/entities/product_entity.dart';
import 'package:shoppingpage/domain/failures/product_failure.dart';
import 'package:shoppingpage/domain/usecases/product_usecases.dart';

void main() {
  late ProductRepositoryImpl repository;
  late InsertProductUseCase insertProductUseCase;
  late UpdateProductUseCase updateProductUseCase;
  late DeleteProductUseCase deleteProductUseCase;
  late GetProductUseCase getProductUseCase;
  late GetAllProductsUseCase getAllProductsUseCase;

  setUp(() {
    repository = ProductRepositoryImpl();
    insertProductUseCase = InsertProductUseCase(repository);
    updateProductUseCase = UpdateProductUseCase(repository);
    deleteProductUseCase = DeleteProductUseCase(repository);
    getProductUseCase = GetProductUseCase(repository);
    getAllProductsUseCase = GetAllProductsUseCase(repository);
  });

  group('ProductEntity', () {
    test('ProductEntity should be created with required properties', () {
      final product = ProductEntity(
        id: '1',
        name: 'Test Product',
        description: 'A test product',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      expect(product.id, '1');
      expect(product.name, 'Test Product');
      expect(product.description, 'A test product');
      expect(product.price, 99.99);
      expect(product.imageUrl, 'https://example.com/image.jpg');
    });

    test('copyWith should create a new ProductEntity with updated fields', () {
      final product = ProductEntity(
        id: '1',
        name: 'Original',
        description: 'Original description',
        price: 50.0,
        imageUrl: 'https://example.com/original.jpg',
      );

      final updatedProduct = product.copyWith(
        name: 'Updated',
        price: 75.0,
      );

      expect(updatedProduct.id, '1');
      expect(updatedProduct.name, 'Updated');
      expect(updatedProduct.price, 75.0);
      expect(updatedProduct.description, 'Original description');
    });

    test('two ProductEntities with same values should be equal', () {
      final product1 = ProductEntity(
        id: '1',
        name: 'Product',
        description: 'Description',
        price: 100.0,
        imageUrl: 'https://example.com/image.jpg',
      );

      final product2 = ProductEntity(
        id: '1',
        name: 'Product',
        description: 'Description',
        price: 100.0,
        imageUrl: 'https://example.com/image.jpg',
      );

      expect(product1, product2);
      expect(product1.hashCode, product2.hashCode);
    });
  });

  group('InsertProductUseCase', () {
    test('should insert a valid product successfully', () async {
      final product = ProductEntity(
        id: '1',
        name: 'New Product',
        description: 'Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      final (insertedProduct, failure) = await insertProductUseCase(product);

      expect(insertedProduct, product);
      expect(failure, null);
    });

    test('should fail when inserting product with empty name', () async {
      final product = ProductEntity(
        id: '1',
        name: '',
        description: 'Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      final (insertedProduct, failure) = await insertProductUseCase(product);

      expect(insertedProduct, null);
      expect(failure, isA<InvalidProductFailure>());
      expect(failure!.message, contains('name cannot be empty'));
    });

    test('should fail when inserting product with negative price', () async {
      final product = ProductEntity(
        id: '1',
        name: 'Product',
        description: 'Description',
        price: -10.0,
        imageUrl: 'https://example.com/image.jpg',
      );

      final (insertedProduct, failure) = await insertProductUseCase(product);

      expect(insertedProduct, null);
      expect(failure, isA<InvalidProductFailure>());
      expect(failure!.message, contains('price cannot be negative'));
    });

    test('should fail when inserting duplicate product', () async {
      final product = ProductEntity(
        id: '1',
        name: 'Product',
        description: 'Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      // Insert first product
      await insertProductUseCase(product);

      // Try to insert duplicate
      final (insertedProduct, failure) = await insertProductUseCase(product);

      expect(insertedProduct, null);
      expect(failure, isA<ProductFailure>());
      expect(failure!.message, contains('already exists'));
    });
  });

  group('GetProductUseCase', () {
    test('should retrieve an existing product successfully', () async {
      final product = ProductEntity(
        id: '1',
        name: 'Product',
        description: 'Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      // Insert product first
      await insertProductUseCase(product);

      // Retrieve product
      final (retrievedProduct, failure) = await getProductUseCase('1');

      expect(retrievedProduct, product);
      expect(failure, null);
    });

    test('should fail when retrieving non-existent product', () async {
      final (retrievedProduct, failure) = await getProductUseCase('nonexistent');

      expect(retrievedProduct, null);
      expect(failure, isA<ProductNotFoundFailure>());
    });

    test('should fail when product ID is empty', () async {
      final (retrievedProduct, failure) = await getProductUseCase('');

      expect(retrievedProduct, null);
      expect(failure, isA<InvalidProductFailure>());
      expect(failure!.message, contains('ID cannot be empty'));
    });
  });

  group('UpdateProductUseCase', () {
    test('should update an existing product successfully', () async {
      final originalProduct = ProductEntity(
        id: '1',
        name: 'Original',
        description: 'Original description',
        price: 50.0,
        imageUrl: 'https://example.com/original.jpg',
      );

      // Insert product first
      await insertProductUseCase(originalProduct);

      // Update product
      final updatedProduct = originalProduct.copyWith(
        name: 'Updated',
        price: 75.0,
      );

      final (result, failure) = await updateProductUseCase(updatedProduct);

      expect(result, updatedProduct);
      expect(failure, null);
    });

    test('should fail when updating non-existent product', () async {
      final product = ProductEntity(
        id: 'nonexistent',
        name: 'Product',
        description: 'Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      final (result, failure) = await updateProductUseCase(product);

      expect(result, null);
      expect(failure, isA<ProductNotFoundFailure>());
    });

    test('should fail when updating product with empty name', () async {
      final product = ProductEntity(
        id: '1',
        name: '',
        description: 'Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      final (result, failure) = await updateProductUseCase(product);

      expect(result, null);
      expect(failure, isA<InvalidProductFailure>());
      expect(failure!.message, contains('name cannot be empty'));
    });

    test('should fail when updating product with empty ID', () async {
      final product = ProductEntity(
        id: '',
        name: 'Product',
        description: 'Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      final (result, failure) = await updateProductUseCase(product);

      expect(result, null);
      expect(failure, isA<InvalidProductFailure>());
      expect(failure!.message, contains('ID cannot be empty'));
    });

    test('should fail when updating product with negative price', () async {
      final product = ProductEntity(
        id: '1',
        name: 'Product',
        description: 'Description',
        price: -10.0,
        imageUrl: 'https://example.com/image.jpg',
      );

      final (result, failure) = await updateProductUseCase(product);

      expect(result, null);
      expect(failure, isA<InvalidProductFailure>());
      expect(failure!.message, contains('price cannot be negative'));
    });
  });

  group('DeleteProductUseCase', () {
    test('should delete an existing product successfully', () async {
      final product = ProductEntity(
        id: '1',
        name: 'Product',
        description: 'Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      // Insert product first
      await insertProductUseCase(product);

      // Delete product
      final (success, failure) = await deleteProductUseCase('1');

      expect(success, true);
      expect(failure, null);

      // Verify product is deleted
      final (retrievedProduct, _) = await getProductUseCase('1');
      expect(retrievedProduct, null);
    });

    test('should fail when deleting non-existent product', () async {
      final (success, failure) = await deleteProductUseCase('nonexistent');

      expect(success, false);
      expect(failure, isA<ProductNotFoundFailure>());
    });

    test('should fail when product ID is empty', () async {
      final (success, failure) = await deleteProductUseCase('');

      expect(success, false);
      expect(failure, isA<InvalidProductFailure>());
      expect(failure!.message, contains('ID cannot be empty'));
    });
  });

  group('GetAllProductsUseCase', () {
    test('should return empty list when no products exist', () async {
      final (products, failure) = await getAllProductsUseCase(const NoParams());

      expect(products, isEmpty);
      expect(failure, null);
    });

    test('should return all inserted products', () async {
      final product1 = ProductEntity(
        id: '1',
        name: 'Product 1',
        description: 'Description 1',
        price: 50.0,
        imageUrl: 'https://example.com/1.jpg',
      );

      final product2 = ProductEntity(
        id: '2',
        name: 'Product 2',
        description: 'Description 2',
        price: 75.0,
        imageUrl: 'https://example.com/2.jpg',
      );

      // Insert products
      await insertProductUseCase(product1);
      await insertProductUseCase(product2);

      // Get all products
      final (products, failure) = await getAllProductsUseCase(const NoParams());

      expect(products, hasLength(2));
      expect(products, contains(product1));
      expect(products, contains(product2));
      expect(failure, null);
    });

    test('should reflect changes after insertion and deletion', () async {
      final product = ProductEntity(
        id: '1',
        name: 'Product',
        description: 'Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      // Initially empty
      var (products, _) = await getAllProductsUseCase(const NoParams());
      expect(products, isEmpty);

      // After insertion
      await insertProductUseCase(product);
      (products, _) = await getAllProductsUseCase(const NoParams());
      expect(products, hasLength(1));

      // After deletion
      await deleteProductUseCase('1');
      (products, _) = await getAllProductsUseCase(const NoParams());
      expect(products, isEmpty);
    });
  });

  group('ProductRepositoryImpl', () {
    test('should maintain product state across operations', () async {
      final product1 = ProductEntity(
        id: '1',
        name: 'Product 1',
        description: 'Description 1',
        price: 50.0,
        imageUrl: 'https://example.com/1.jpg',
      );

      final product2 = ProductEntity(
        id: '2',
        name: 'Product 2',
        description: 'Description 2',
        price: 75.0,
        imageUrl: 'https://example.com/2.jpg',
      );

      // Insert products
      await repository.insertProduct(product1);
      await repository.insertProduct(product2);

      // Verify all products exist
      var (allProducts, _) = await repository.getAllProducts();
      expect(allProducts, hasLength(2));

      // Update one product
      final updatedProduct1 = product1.copyWith(price: 60.0);
      await repository.updateProduct(updatedProduct1);

      // Delete one product
      await repository.deleteProduct('2');

      // Verify final state
      (allProducts, _) = await repository.getAllProducts();
      expect(allProducts, hasLength(1));
      expect(allProducts![0], updatedProduct1);
    });

    test('should clear all products correctly', () async {
      final product = ProductEntity(
        id: '1',
        name: 'Product',
        description: 'Description',
        price: 99.99,
        imageUrl: 'https://example.com/image.jpg',
      );

      await repository.insertProduct(product);
      expect(repository.getProductCount(), 1);

      repository.clearAllProducts();
      expect(repository.getProductCount(), 0);
    });
  });
}
