# Shopping Page - E-commerce Flutter Application

A Flutter e-commerce application implementing Clean Architecture principles for robust, scalable, and maintainable code.

## Project Overview

This application demonstrates best practices in Flutter development using Clean Architecture pattern. It features:
- Well-organized project structure with clear separation of concerns
- Data models with JSON serialization/deserialization
- Domain entities for business logic
- Repository pattern for data access
- Comprehensive unit testing

## Architecture

This project follows the **Clean Architecture** pattern, which promotes:
- **Separation of Concerns**: Each layer has distinct responsibilities
- **Testability**: Loose coupling between layers enables easy testing
- **Reusability**: Components can be used across different parts of the application
- **Maintainability**: Clear structure makes it easier to understand and modify code

### Folder Structure

```
lib/
├── core/                          # Shared core components
│   ├── error/                     # Error handling and exceptions
│   ├── utils/                     # Utility functions and helpers
│   └── constants/                 # Application constants
│
├── features/                      # Feature modules
│   └── product/                   # Product feature module
│       ├── data/                  # Data layer
│       │   ├── models/            # Data models (with JSON serialization)
│       │   │   └── product_model.dart
│       │   ├── datasources/       # Remote and local data sources
│       │   └── repositories/      # Repository implementations
│       │
│       ├── domain/                # Domain layer (business logic)
│       │   ├── entities/          # Core business objects
│       │   ├── repositories/      # Abstract repository interfaces
│       │   └── usecases/          # Business use cases
│       │
│       └── presentation/          # UI layer
│           ├── pages/             # Full page widgets
│           ├── widgets/           # Reusable widgets
│           └── bloc/              # State management
│
└── test/                          # Unit and widget tests
    └── product_model_test.dart    # Model tests
```

### Architecture Layers

#### 1. **Data Layer** (`features/product/data/`)
- **Responsibility**: Handles data operations including API calls, database operations, and data transformations
- **Components**:
  - **Models**: Convert between API/database format and domain entities
  - **Data Sources**: Abstract interfaces for remote (API) and local (database) data
  - **Repositories**: Implement repository interfaces to fetch and process data

#### 2. **Domain Layer** (`features/product/domain/`)
- **Responsibility**: Contains pure business logic independent of frameworks
- **Components**:
  - **Entities**: Core business objects (e.g., `ProductEntity`)
  - **Repositories**: Abstract interfaces defining data access contracts
  - **Use Cases**: Encapsulate specific business logic operations

#### 3. **Presentation Layer** (`features/product/presentation/`)
- **Responsibility**: Manages UI and user interactions
- **Components**:
  - **Pages**: Full-screen widgets
  - **Widgets**: Reusable UI components
  - **BLoC**: State management and business logic coordination

#### 4. **Core Layer** (`lib/core/`)
- **Responsibility**: Contains shared utilities and constants used across features
- **Components**:
  - Error handling classes
  - Utility functions
  - Application constants

## Data Flow

### Request Flow
```
UI (Presentation) 
  ↓
BLoC/Provider 
  ↓
Use Case 
  ↓
Repository (Abstract)
  ↓
Data Layer Repository
  ↓
Data Source (Remote/Local)
  ↓
API / Database
```

### Response Flow
```
API / Database
  ↓
Data Source
  ↓
Model → Entity Conversion
  ↓
Repository
  ↓
Use Case
  ↓
BLoC/Provider
  ↓
UI Update (Presentation)
```

## Models and JSON Serialization

### ProductModel
Located in `lib/features/product/data/models/product_model.dart`

The `ProductModel` class handles conversion between JSON format (from API/storage) and Dart objects.

**Key Features**:
- `toJson()`: Converts ProductModel to JSON map (for API requests or storage)
- `fromJson()`: Factory constructor creates ProductModel from JSON (from API responses or storage)
- `copyWith()`: Creates a copy with selective field updates
- Equality operator: Enables model comparison
- Hash code: For use in collections

**Example Usage**:
```dart
// Creating from JSON (API response)
final json = {
  'id': '1',
  'name': 'Laptop',
  'description': 'High-performance laptop',
  'price': 999.99,
  'imageUrl': 'https://example.com/laptop.jpg'
};
final product = ProductModel.fromJson(json);

// Converting to JSON (sending to API)
final jsonData = product.toJson();

// Creating a copy with updates
final updatedProduct = product.copyWith(price: 899.99);
```

## Testing

The project includes comprehensive unit tests for the `ProductModel`.

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/product_model_test.dart

# Run tests with coverage
flutter test --coverage
```

### Test Coverage

The `product_model_test.dart` file includes:
- Constructor tests
- JSON serialization tests (`toJson`)
- JSON deserialization tests (`fromJson`)
- Edge cases (null values, missing fields, type conversion)
- Copy method tests
- Equality and hash code tests
- String representation tests
- Round-trip serialization integrity tests

## Getting Started

### Prerequisites
- Flutter SDK: ^3.10.3
- Dart SDK: Latest stable version

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

### Running Tests

```bash
flutter test
```

## Dependencies

- `flutter_test`: Testing framework
- `intl`: Internationalization support
- `image_picker`: Image selection functionality
- `cupertino_icons`: iOS-style icons

## Best Practices Implemented

✅ **Separation of Concerns**: Each layer has distinct responsibilities
✅ **Dependency Inversion**: Upper layers depend on abstractions, not concrete implementations
✅ **Single Responsibility Principle**: Each class has one reason to change
✅ **DRY (Don't Repeat Yourself)**: Common logic extracted to shared components
✅ **Testability**: Loose coupling enables comprehensive unit testing
✅ **Type Safety**: Proper use of Dart types and null safety
✅ **Documentation**: Clear comments and structured code

## Future Enhancements

- [ ] Implement remote data source with API calls
- [ ] Add local database storage (SQLite/Hive)
- [ ] Implement proper error handling with custom exceptions
- [ ] Add BLoC/Provider for state management
- [ ] Implement navigation between screens
- [ ] Add authentication and authorization
- [ ] Implement filtering and search functionality
- [ ] Add payment integration

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Clean Architecture Guide](https://resocoder.com/flutter-clean-architecture)
- [Dart Null Safety](https://dart.dev/null-safety)
- [Testing in Flutter](https://docs.flutter.dev/testing)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For help and support, please refer to:
- [Flutter Community](https://flutter.dev/community)
- [Stack Overflow - Flutter Tag](https://stackoverflow.com/questions/tagged/flutter)
- Official Flutter documentation
