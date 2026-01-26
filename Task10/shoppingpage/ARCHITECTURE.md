# Clean Architecture Implementation - Product CRUD Operations

## Overview

This document outlines the Clean Architecture implementation for CRUD (Create, Read, Update, Delete) operations in the eCommerce Mobile App. The implementation follows SOLID principles and Test-Driven Development (TDD) practices.

## Architecture Layers

### 1. Domain Layer (`lib/domain/`)
The innermost layer that contains business logic and is independent of any external framework.

#### Entities (`domain/entities/`)
- **ProductEntity**: Represents a product in the eCommerce system
  - Properties: `id`, `name`, `description`, `price`, `imageUrl`
  - Methods: `copyWith()` for immutable updates, `==` and `hashCode` for equality

#### Failures (`domain/failures/`)
- **Failure**: Base abstract class for all error cases
- **ProductFailure**: General product operation errors
- **ProductNotFoundFailure**: When a product doesn't exist
- **InvalidProductFailure**: When product data is invalid

#### Repositories (`domain/repositories/`)
- **ProductRepository**: Abstract interface defining the contract for product data operations
  - Methods:
    - `insertProduct()`: Add a new product
    - `updateProduct()`: Modify an existing product
    - `deleteProduct()`: Remove a product
    - `getProduct()`: Retrieve a specific product
    - `getAllProducts()`: Retrieve all products

#### Use Cases (`domain/usecases/`)
Use cases represent specific business operations. Each use case:
- Implements the `UseCase<Type, Params>` interface
- Uses the repository to access data
- Performs validation
- Returns a tuple of `(Result?, Failure?)`

**Use Cases Implemented:**
1. **InsertProductUseCase**: Validates and inserts a new product
   - Validates: name is not empty, price is non-negative
2. **UpdateProductUseCase**: Validates and updates an existing product
   - Validates: ID is not empty, name is not empty, price is non-negative
   - Checks: Product exists before updating
3. **DeleteProductUseCase**: Deletes a product by ID
   - Validates: Product ID is not empty
4. **GetProductUseCase**: Retrieves a specific product
   - Validates: Product ID is not empty
5. **GetAllProductsUseCase**: Retrieves all products

### 2. Data Layer (`lib/data/`)
Contains implementations of repositories and handles data operations.

#### ProductRepositoryImpl (`data/repositories/`)
In-memory implementation of the ProductRepository interface:
- Stores products in a `Map<String, ProductEntity>`
- Simulates network delays with `Future.delayed()`
- Implements all CRUD operations with error handling
- Provides testing utilities: `clearAllProducts()`, `getProductCount()`

## Error Handling

The application uses a Result tuple pattern `(Data?, Failure?)`:
- If operation succeeds: `(data, null)`
- If operation fails: `(null, failure)`

This approach eliminates the need for exceptions in normal control flow and makes error handling explicit.

## Example Usage

```dart
// Initialize
final repository = ProductRepositoryImpl();
final insertProductUseCase = InsertProductUseCase(repository);
final getProductUseCase = GetProductUseCase(repository);

// Create a product
final product = ProductEntity(
  id: '1',
  name: 'Laptop',
  description: 'High-performance laptop',
  price: 999.99,
  imageUrl: 'https://example.com/laptop.jpg',
);

// Insert product
final (insertedProduct, insertError) = await insertProductUseCase(product);
if (insertError != null) {
  print('Error: ${insertError.message}');
} else {
  print('Product inserted: ${insertedProduct!.name}');
}

// Retrieve product
final (retrievedProduct, getError) = await getProductUseCase('1');
if (getError != null) {
  print('Error: ${getError.message}');
} else {
  print('Product found: ${retrievedProduct!.name}');
}
```

## Testing

unit tests are provided in `test/product_test.dart`:

### Test Coverage
1. **ProductEntity Tests**
   - Creation and properties
   - copyWith() functionality
   - Equality and hashCode

2. **InsertProductUseCase Tests**
   - Successful insertion
   - Validation: empty name
   - Validation: negative price
   - Duplicate product handling

3. **GetProductUseCase Tests**
   - Successful retrieval
   - Non-existent product handling
   - Empty product ID validation

4. **UpdateProductUseCase Tests**
   - Successful update
   - Non-existent product handling
   - Validation: empty ID, empty name, negative price

5. **DeleteProductUseCase Tests**
   - Successful deletion
   - Non-existent product handling
   - Empty product ID validation

6. **GetAllProductsUseCase Tests**
   - Empty product list
   - Multiple products retrieval
   - State changes after operations

7. **ProductRepositoryImpl Tests**
   - State maintenance across operations
   - Clear and count utilities

### Running Tests
```bash
flutter test test/product_test.dart
```

## SOLID Principles Applied

1. **Single Responsibility Principle (SRP)**
   - Each use case handles one specific operation
   - Repository interface focuses on data access contracts

2. **Open/Closed Principle (OCP)**
   - New repository implementations can be added without modifying existing code
   - New use cases can be created without changing existing ones

3. **Liskov Substitution Principle (LSP)**
   - Any ProductRepository implementation can be swapped for another
   - All implementations follow the same contract

4. **Interface Segregation Principle (ISP)**
   - ProductRepository defines specific operations needed
   - Use cases only depend on the repository interface

5. **Dependency Inversion Principle (DIP)**
   - Use cases depend on the ProductRepository abstraction, not concrete implementations
   - High-level modules (use cases) don't depend on low-level modules (implementations)


