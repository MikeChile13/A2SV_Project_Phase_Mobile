import 'package:flutter_test/flutter_test.dart';
import 'package:shoppingpage/features/product/data/models/product_model.dart';

void main() {
  group('ProductModel', () {
    const testId = '1';
    const testName = 'Test Product';
    const testDescription = 'A test product description';
    const testPrice = 29.99;
    const testImageUrl = 'https://example.com/image.jpg';

    final testProductModel = ProductModel(
      id: testId,
      name: testName,
      description: testDescription,
      price: testPrice,
      imageUrl: testImageUrl,
    );

    group('Constructor', () {
      test('should create a ProductModel with all fields', () {
        expect(testProductModel.id, equals(testId));
        expect(testProductModel.name, equals(testName));
        expect(testProductModel.description, equals(testDescription));
        expect(testProductModel.price, equals(testPrice));
        expect(testProductModel.imageUrl, equals(testImageUrl));
      });
    });

    group('toJson', () {
      test('should convert ProductModel to valid JSON', () {
        final result = testProductModel.toJson();

        expect(result, equals({
          'id': testId,
          'name': testName,
          'description': testDescription,
          'price': testPrice,
          'imageUrl': testImageUrl,
        }));
      });

      test('should produce JSON with correct types', () {
        final json = testProductModel.toJson();

        expect(json['id'], isA<String>());
        expect(json['name'], isA<String>());
        expect(json['description'], isA<String>());
        expect(json['price'], isA<double>());
        expect(json['imageUrl'], isA<String>());
      });
    });

    group('fromJson', () {
      test('should create ProductModel from valid JSON', () {
        final jsonMap = {
          'id': testId,
          'name': testName,
          'description': testDescription,
          'price': testPrice,
          'imageUrl': testImageUrl,
        };

        final result = ProductModel.fromJson(jsonMap);

        expect(result.id, equals(testId));
        expect(result.name, equals(testName));
        expect(result.description, equals(testDescription));
        expect(result.price, equals(testPrice));
        expect(result.imageUrl, equals(testImageUrl));
      });

      test('should handle missing fields with defaults', () {
        final jsonMap = {
          'id': testId,
          'name': testName,
        };

        final result = ProductModel.fromJson(jsonMap);

        expect(result.id, equals(testId));
        expect(result.name, equals(testName));
        expect(result.description, equals(''));
        expect(result.price, equals(0.0));
        expect(result.imageUrl, equals(''));
      });

      test('should convert numeric price to double', () {
        final jsonMap = {
          'id': testId,
          'name': testName,
          'description': testDescription,
          'price': 29,
          'imageUrl': testImageUrl,
        };

        final result = ProductModel.fromJson(jsonMap);

        expect(result.price, equals(29.0));
        expect(result.price, isA<double>());
      });

      test('should handle null values gracefully', () {
        final jsonMap = {
          'id': null,
          'name': null,
          'description': null,
          'price': null,
          'imageUrl': null,
        };

        final result = ProductModel.fromJson(jsonMap);

        expect(result.id, equals(''));
        expect(result.name, equals(''));
        expect(result.description, equals(''));
        expect(result.price, equals(0.0));
        expect(result.imageUrl, equals(''));
      });

      test('should handle empty JSON map', () {
        final result = ProductModel.fromJson({});

        expect(result.id, equals(''));
        expect(result.name, equals(''));
        expect(result.description, equals(''));
        expect(result.price, equals(0.0));
        expect(result.imageUrl, equals(''));
      });
    });

    group('copyWith', () {
      test('should return same object when no parameters provided', () {
        final result = testProductModel.copyWith();

        expect(result.id, equals(testProductModel.id));
        expect(result.name, equals(testProductModel.name));
        expect(result.description, equals(testProductModel.description));
        expect(result.price, equals(testProductModel.price));
        expect(result.imageUrl, equals(testProductModel.imageUrl));
      });

      test('should replace specific fields', () {
        const newName = 'Updated Product';
        const newPrice = 39.99;

        final result = testProductModel.copyWith(
          name: newName,
          price: newPrice,
        );

        expect(result.id, equals(testProductModel.id));
        expect(result.name, equals(newName));
        expect(result.description, equals(testProductModel.description));
        expect(result.price, equals(newPrice));
        expect(result.imageUrl, equals(testProductModel.imageUrl));
      });

      test('should replace all fields', () {
        const newId = '2';
        const newName = 'New Product';
        const newDescription = 'New description';
        const newPrice = 49.99;
        const newImageUrl = 'https://example.com/new-image.jpg';

        final result = testProductModel.copyWith(
          id: newId,
          name: newName,
          description: newDescription,
          price: newPrice,
          imageUrl: newImageUrl,
        );

        expect(result.id, equals(newId));
        expect(result.name, equals(newName));
        expect(result.description, equals(newDescription));
        expect(result.price, equals(newPrice));
        expect(result.imageUrl, equals(newImageUrl));
      });
    });

    group('equality', () {
      test('should be equal to itself', () {
        expect(testProductModel, equals(testProductModel));
      });

      test('should be equal to another ProductModel with same values', () {
        final other = ProductModel(
          id: testId,
          name: testName,
          description: testDescription,
          price: testPrice,
          imageUrl: testImageUrl,
        );

        expect(testProductModel, equals(other));
      });

      test('should not be equal when any field differs', () {
        final other = ProductModel(
          id: '2',
          name: testName,
          description: testDescription,
          price: testPrice,
          imageUrl: testImageUrl,
        );

        expect(testProductModel, isNot(equals(other)));
      });

      test('should have same hashCode for equal objects', () {
        final other = ProductModel(
          id: testId,
          name: testName,
          description: testDescription,
          price: testPrice,
          imageUrl: testImageUrl,
        );

        expect(testProductModel.hashCode, equals(other.hashCode));
      });
    });

    group('toString', () {
      test('should return string representation', () {
        final result = testProductModel.toString();

        expect(result, contains('ProductModel'));
        expect(result, contains(testId));
        expect(result, contains(testName));
        expect(result, contains(testDescription));
        expect(result, contains('$testPrice'));
        expect(result, contains(testImageUrl));
      });
    });

    group('JSON round-trip', () {
      test('should maintain data integrity through toJson and fromJson', () {
        final json = testProductModel.toJson();
        final reconstructed = ProductModel.fromJson(json);

        expect(reconstructed, equals(testProductModel));
      });

      test('should handle multiple round-trips', () {
        var current = testProductModel;

        for (int i = 0; i < 3; i++) {
          final json = current.toJson();
          current = ProductModel.fromJson(json);
        }

        expect(current, equals(testProductModel));
      });
    });
  });
}
