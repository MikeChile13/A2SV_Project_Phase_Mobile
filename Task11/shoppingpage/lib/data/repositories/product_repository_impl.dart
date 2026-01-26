import '../../domain/entities/product_entity.dart';
import '../../domain/failures/product_failure.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';
import '../models/product_model.dart';

/// ProductRepositoryImpl is the concrete implementation of ProductRepository
/// It follows the Repository Pattern and implements Clean Architecture principles
///
/// This repository acts as a mediator between:
/// - Domain Layer (business logic) via the ProductRepository interface
/// - Data Layer (remote and local data sources)
///
/// By depending on abstractions (RemoteDataSource and LocalDataSource),
/// it achieves loose coupling and supports easy testing and source switching
class ProductRepositoryImpl extends ProductRepository {
  /// Remote data source dependency (contracts)
  /// Handles API calls and network operations
  final RemoteDataSource remoteDataSource;

  /// Local data source dependency (contracts)
  /// Handles local storage and caching operations
  final LocalDataSource localDataSource;

  /// Constructor with injected dependencies
  /// This demonstrates Dependency Injection and Inversion of Control
  /// Both dependencies are abstractions, not concrete implementations
  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<(ProductEntity?, ProductFailure?)> insertProduct(
    ProductEntity product,
  ) async {
    try {
      // Convert domain entity to data model
      final productModel = ProductModel.fromEntity(product);

      // Try to create product on remote source first
      final remoteProduct = await remoteDataSource.createProduct(productModel);

      // If successful, also cache locally for offline access
      await localDataSource.cacheProduct(remoteProduct);

      return (remoteProduct.toEntity(), null);
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
      final productModel = ProductModel.fromEntity(product);

      // Try to update on remote source
      final remoteProduct = await remoteDataSource.updateProduct(productModel);

      // Also update local cache
      await localDataSource.updateProduct(remoteProduct);

      return (remoteProduct.toEntity(), null);
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
      // Try to delete from remote source
      await remoteDataSource.deleteProduct(productId);

      // Also delete from local cache
      await localDataSource.deleteProduct(productId);

      return (true, null);
    } catch (e) {
      return (
        false,
        ProductFailure(message: 'Error deleting product: ${e.toString()}'),
      );
    }
  }

  @override
  Future<(ProductEntity?, ProductFailure?)> getProduct(String productId) async {
    try {
      // Try to get from remote source first (fresh data)
      try {
        final remoteProduct = await remoteDataSource.getProduct(productId);
        // Cache the fetched product locally
        await localDataSource.cacheProduct(remoteProduct);
        return (remoteProduct.toEntity(), null);
      } catch (e) {
        // If remote fails, try local cache as fallback (offline support)
        try {
          final cachedProduct = await localDataSource.getProduct(productId);
          return (cachedProduct.toEntity(), null);
        } catch (_) {
          // Both remote and local failed
          rethrow;
        }
      }
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
      // Try to get from remote source first (fresh data)
      try {
        final remoteProducts = await remoteDataSource.getAllProducts();
        // Cache all fetched products locally for offline access
        await localDataSource.cacheProducts(remoteProducts);
        return (
          remoteProducts.map((m) => m.toEntity()).toList(),
          null,
        );
      } catch (e) {
        // If remote fails, try local cache as fallback (offline support)
        try {
          final cachedProducts = await localDataSource.getAllProducts();
          return (
            cachedProducts.map((m) => m.toEntity()).toList(),
            null,
          );
        } catch (_) {
          // Both remote and local failed
          rethrow;
        }
      }
    } catch (e) {
      return (
        null,
        ProductFailure(
          message: 'Error retrieving products: ${e.toString()}',
        ),
      );
    }
  }
}
