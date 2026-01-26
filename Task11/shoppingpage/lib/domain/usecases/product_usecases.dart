import '../entities/product_entity.dart';
import '../failures/product_failure.dart';
import '../repositories/product_repository.dart';

/// Base Use Case class
abstract class UseCase<Type, Params> {
  Future<(Type?, ProductFailure?)> call(Params params);
}

/// Params class for operations that don't require parameters
class NoParams {
  const NoParams();
}

/// Insert Product Use Case
/// Adds a new product to the repository
class InsertProductUseCase extends UseCase<ProductEntity, ProductEntity> {
  final ProductRepository repository;

  InsertProductUseCase(this.repository);

  @override
  Future<(ProductEntity?, ProductFailure?)> call(ProductEntity product) async {
    // Validate product before inserting
    if (product.name.isEmpty) {
      return (
        null,
        InvalidProductFailure(reason: 'Product name cannot be empty'),
      );
    }

    if (product.price < 0) {
      return (
        null,
        InvalidProductFailure(reason: 'Product price cannot be negative'),
      );
    }

    return repository.insertProduct(product);
  }
}

/// Update Product Use Case
/// Updates an existing product in the repository
class UpdateProductUseCase extends UseCase<ProductEntity, ProductEntity> {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  @override
  Future<(ProductEntity?, ProductFailure?)> call(ProductEntity product) async {
    // Validate product before updating
    if (product.id.isEmpty) {
      return (
        null,
        InvalidProductFailure(reason: 'Product ID cannot be empty'),
      );
    }

    if (product.name.isEmpty) {
      return (
        null,
        InvalidProductFailure(reason: 'Product name cannot be empty'),
      );
    }

    if (product.price < 0) {
      return (
        null,
        InvalidProductFailure(reason: 'Product price cannot be negative'),
      );
    }

    // Check if product exists
    final (existingProduct, failure) = await repository.getProduct(product.id);
    if (existingProduct == null && failure != null) {
      return (null, failure);
    }

    return repository.updateProduct(product);
  }
}

/// Delete Product Use Case
/// Removes a product from the repository
class DeleteProductUseCase extends UseCase<bool, String> {
  final ProductRepository repository;

  DeleteProductUseCase(this.repository);

  @override
  Future<(bool, ProductFailure?)> call(String productId) async {
    if (productId.isEmpty) {
      return (false, InvalidProductFailure(reason: 'Product ID cannot be empty'));
    }

    return repository.deleteProduct(productId);
  }
}

/// Get Product Use Case
/// Retrieves a specific product from the repository
class GetProductUseCase extends UseCase<ProductEntity, String> {
  final ProductRepository repository;

  GetProductUseCase(this.repository);

  @override
  Future<(ProductEntity?, ProductFailure?)> call(String productId) async {
    if (productId.isEmpty) {
      return (null, InvalidProductFailure(reason: 'Product ID cannot be empty'));
    }

    return repository.getProduct(productId);
  }
}

/// Get All Products Use Case
/// Retrieves all products from the repository
class GetAllProductsUseCase
    extends UseCase<List<ProductEntity>, NoParams> {
  final ProductRepository repository;

  GetAllProductsUseCase(this.repository);

  @override
  Future<(List<ProductEntity>?, ProductFailure?)> call(
    NoParams params,
  ) async {
    return repository.getAllProducts();
  }
}
