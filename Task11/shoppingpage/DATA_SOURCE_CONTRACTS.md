# Data Source Contracts Implementation Guide

## Overview

This document describes the implementation of data source contracts in the Ecommerce Flutter application. Data source contracts are essential interfaces that define standardized methods for data access operations, promoting clean architecture principles and enabling flexible, testable code.

## Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                   Presentation Layer                     │
│          (UI - Screens, Widgets, Pages)                 │
└────────────────┬────────────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────────────┐
│                    Domain Layer                          │
│  - Entities (ProductEntity)                             │
│  - Repository Interfaces (ProductRepository)             │
│  - Use Cases                                             │
│  - Failures (Exceptions)                                │
└────────────────┬────────────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────────────┐
│                    Data Layer                            │
│  - Repository Implementations                           │
│  - Data Source Contracts (RemoteDataSource,             │
│    LocalDataSource)                                      │
│  - Data Source Implementations                          │
│  - Models (DTOs)                                         │
│  - Network & Database Operations                        │
└─────────────────────────────────────────────────────────┘
```

## Key Components

### 1. Domain Layer - Repository Contract

**File**: `lib/domain/repositories/product_repository.dart`

```dart
abstract class ProductRepository {
  Future<(ProductEntity?, ProductFailure?)> insertProduct(ProductEntity product);
  Future<(ProductEntity?, ProductFailure?)> updateProduct(ProductEntity product);
  Future<(bool, ProductFailure?)> deleteProduct(String productId);
  Future<(ProductEntity?, ProductFailure?)> getProduct(String productId);
  Future<(List<ProductEntity>?, ProductFailure?)> getAllProducts();
}
```

**Purpose**: Defines the contract that all repository implementations must follow. This is part of the Domain Layer and should be independent of any implementation details.

**Benefits**:
- Clear interface for business logic
- Easy to test with mock implementations
- Defines what operations are available

### 2. Data Layer - Data Source Contracts

#### Remote Data Source Contract

**File**: `lib/data/datasources/remote_data_source.dart`

```dart
abstract class RemoteDataSource {
  Future<ProductModel> getProduct(String productId);
  Future<List<ProductModel>> getAllProducts();
  Future<ProductModel> createProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<bool> deleteProduct(String productId);
  Future<List<ProductModel>> searchProducts(String query);
}
```

**Purpose**: Defines the contract for all remote data operations (API calls, network requests).

**Key Responsibilities**:
- Fetch data from remote servers
- Handle network operations
- Manage API communication
- Return exceptions on failures

**Implementation**: `RemoteDataSourceImpl` provides an in-memory simulation of remote operations.

---

#### Local Data Source Contract

**File**: `lib/data/datasources/local_data_source.dart`

```dart
abstract class LocalDataSource {
  Future<ProductModel> getProduct(String productId);
  Future<List<ProductModel>> getAllProducts();
  Future<void> cacheProduct(ProductModel product);
  Future<void> cacheProducts(List<ProductModel> products);
  Future<void> createProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String productId);
  Future<void> clearAllProducts();
  Future<bool> productExists(String productId);
}
```

**Purpose**: Defines the contract for all local storage operations (database, cache, persistent storage).

**Key Responsibilities**:
- Store data locally for offline access
- Cache remote data
- Manage local persistence
- Return exceptions on failures

**Implementation**: `LocalDataSourceImpl` provides an in-memory simulation of local storage.

---

### 3. Data Models (DTOs)

**File**: `lib/data/models/product_model.dart`

```dart
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  
  // Conversion methods
  ProductEntity toEntity() { ... }
  factory ProductModel.fromEntity(ProductEntity entity) { ... }
  Map<String, dynamic> toJson() { ... }
  factory ProductModel.fromJson(Map<String, dynamic> json) { ... }
}
```

**Purpose**: Represents data as stored in the data layer. Acts as a Data Transfer Object (DTO).

**Responsibilities**:
- Encapsulate data structure for transmission and storage
- Provide serialization/deserialization (JSON conversions)
- Convert between domain entities and data models
- Isolate domain logic from data representation

---

### 4. Repository Implementation

**File**: `lib/data/repositories/product_repository_impl.dart`

```dart
class ProductRepositoryImpl extends ProductRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  
  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  
  // Implementation details using data sources
}
```

**Purpose**: Concrete implementation of the repository interface that uses data source contracts.

**Key Characteristics**:
- Depends on abstractions (RemoteDataSource, LocalDataSource) not concrete implementations
- Acts as a mediator between domain and data layers
- Implements caching strategy
- Provides offline support by falling back to local cache
- Maintains clean separation of concerns

---

### 5. Dependency Injection Setup

**File**: `lib/core/service_locator.dart`

```dart
class ServiceLocator {
  void setupDependencies() {
    _localDataSource = LocalDataSourceImpl();
    _remoteDataSource = RemoteDataSourceImpl();
    
    _productRepository = ProductRepositoryImpl(
      localDataSource: _localDataSource,
      remoteDataSource: _remoteDataSource,
    );
  }
}
```

**Purpose**: Centralized management of all dependencies in the application.

**Benefits**:
- Single point of dependency configuration
- Easy to swap implementations for testing
- Clear dependency graph
- Supports the Service Locator pattern

---

## Design Patterns Used

### 1. Repository Pattern
- Provides a clean interface between business logic and data access
- Encapsulates data source complexity
- Supports multiple data source strategies

### 2. Strategy Pattern
- Different data source implementations (Remote vs Local)
- Easy to switch between strategies
- Runtime selection of data sources

### 3. Data Transfer Object (DTO) Pattern
- `ProductModel` transfers data between layers
- Isolates domain from data representation
- Facilitates serialization/deserialization

### 4. Service Locator Pattern
- Centralized dependency management
- Easy access to services throughout the app
- Simplifies testing with mock implementations

### 5. Dependency Injection
- Data sources injected into repository
- Loose coupling between components
- Improved testability

---

## SOLID Principles Applied

### Single Responsibility Principle (SRP)
- `RemoteDataSource`: Only handles remote operations
- `LocalDataSource`: Only handles local storage
- `ProductRepository`: Only orchestrates data operations

### Open/Closed Principle (OCP)
- Can add new data source implementations without modifying existing code
- Repository works with any implementation of the contracts

### Liskov Substitution Principle (LSP)
- Any implementation of `RemoteDataSource` can be used interchangeably
- Any implementation of `LocalDataSource` can be used interchangeably
- `ProductRepositoryImpl` works with any repository interface

### Interface Segregation Principle (ISP)
- `RemoteDataSource` has specific remote operations
- `LocalDataSource` has specific local operations
- Clients use only the methods they need

### Dependency Inversion Principle (DIP)
- Repository depends on abstractions (datasource contracts)
- Not on concrete implementations
- High-level modules depend on abstractions
- Low-level modules depend on abstractions

---

## Data Flow Example: Get All Products

```
User UI
   ↓
ProductRepository.getAllProducts()
   ↓
Try Remote First (RemoteDataSource.getAllProducts)
   ├─ Success: Cache locally and return
   └─ Failure: Try Local Cache
      └─ Return cached data or propagate error
```

## Testing Benefits

With data source contracts in place, testing becomes significantly easier:

### Unit Testing
```dart
// Mock RemoteDataSource for testing
class MockRemoteDataSource implements RemoteDataSource {
  @override
  Future<List<ProductModel>> getAllProducts() async {
    return [/* test data */];
  }
}

// Test repository with mock
final repository = ProductRepositoryImpl(
  remoteDataSource: MockRemoteDataSource(),
  localDataSource: MockLocalDataSource(),
);
```

### Integration Testing
- Switch to real implementations
- Test actual API calls and database operations
- Verify data transformation

---

## File Structure

```
lib/
├── domain/
│   ├── entities/
│   │   └── product_entity.dart
│   ├── repositories/
│   │   └── product_repository.dart (Contract)
│   ├── failures/
│   │   └── product_failure.dart
│   └── usecases/
│       └── product_usecases.dart
├── data/
│   ├── datasources/
│   │   ├── remote_data_source.dart (Contract)
│   │   ├── remote_data_source_impl.dart
│   │   ├── local_data_source.dart (Contract)
│   │   └── local_data_source_impl.dart
│   ├── models/
│   │   └── product_model.dart
│   └── repositories/
│       └── product_repository_impl.dart
├── core/
│   └── service_locator.dart
└── ...
```

---

## Key Takeaways

1. **Contracts Define Behavior**: Abstract classes/interfaces define what operations are available
2. **Separation of Concerns**: Each layer has clear responsibilities
3. **Flexibility**: Easy to switch between implementations
4. **Testability**: Mock implementations can be created for testing
5. **Maintainability**: Changes to one implementation don't affect others
6. **SOLID Principles**: Code follows best practices for maintainable architecture
7. **Offline Support**: Local caching enables offline functionality
8. **Error Handling**: Clear failure types for different error scenarios

---

## Future Enhancements

1. **Real Network Calls**: Replace `RemoteDataSourceImpl` with actual HTTP client
2. **Database Integration**: Replace `LocalDataSourceImpl` with SQLite/Hive
3. **Error Recovery**: Implement retry logic with exponential backoff
4. **Pagination**: Add pagination to `getAllProducts()` method
5. **Filtering**: Add filter capabilities to data source methods
6. **Synchronization**: Auto-sync when network becomes available
7. **State Management**: Integrate with BLoC or Riverpod for state management

---
