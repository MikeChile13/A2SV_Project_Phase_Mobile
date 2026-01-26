import 'package:shoppingpage/data/datasources/local_data_source.dart';
import 'package:shoppingpage/data/datasources/local_data_source_impl.dart';
import 'package:shoppingpage/data/datasources/remote_data_source.dart';
import 'package:shoppingpage/data/datasources/remote_data_source_impl.dart';
import 'package:shoppingpage/data/repositories/product_repository_impl.dart';
import 'package:shoppingpage/domain/repositories/product_repository.dart';

/// ServiceLocator provides a centralized place to initialize and access
/// all dependencies in the application following the Service Locator pattern
///
/// Benefits:
/// - Centralized dependency management
/// - Easy to switch implementations (e.g., mock implementations for testing)
/// - Clear dependency graph
/// - Separation of concerns
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  /// Concrete implementations of data sources
  late LocalDataSource _localDataSource;
  late RemoteDataSource _remoteDataSource;
  late ProductRepository _productRepository;

  ServiceLocator._internal();

  factory ServiceLocator() {
    return _instance;
  }

  /// Initialize all dependencies
  /// This should be called once at application startup
  void setupDependencies() {
    // Initialize data sources
    // These are the concrete implementations that implement the contracts
    _localDataSource = LocalDataSourceImpl();
    _remoteDataSource = RemoteDataSourceImpl();

    // Initialize repository with data source dependencies
    // The repository depends on abstractions, not concrete implementations
    // This allows for easy testing and implementation switching
    _productRepository = ProductRepositoryImpl(
      localDataSource: _localDataSource,
      remoteDataSource: _remoteDataSource,
    );
  }

  /// Get the ProductRepository instance
  /// The return type is the abstract class, not the implementation
  /// This follows the Dependency Inversion Principle
  ProductRepository get productRepository => _productRepository;

  /// Get the LocalDataSource instance
  /// Used internally by the repository, but can be accessed for testing
  LocalDataSource get localDataSource => _localDataSource;

  /// Get the RemoteDataSource instance
  /// Used internally by the repository, but can be accessed for testing
  RemoteDataSource get remoteDataSource => _remoteDataSource;

  /// Reset dependencies (useful for testing)
  void resetDependencies() {
    setupDependencies();
  }
}
