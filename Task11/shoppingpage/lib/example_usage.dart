import 'package:shoppingpage/data/repositories/product_repository_impl.dart';
import 'package:shoppingpage/domain/entities/product_entity.dart';
import 'package:shoppingpage/domain/usecases/product_usecases.dart';

/// Example/Demo file showing how to use the Product CRUD operations
/// This demonstrates the Clean Architecture pattern in action

Future<void> main() async {
  print('=== eCommerce Product CRUD Operations Demo ===\n');

  // Initialize repository and use cases
  final repository = ProductRepositoryImpl();
  final insertProductUseCase = InsertProductUseCase(repository);
  final updateProductUseCase = UpdateProductUseCase(repository);
  final deleteProductUseCase = DeleteProductUseCase(repository);
  final getProductUseCase = GetProductUseCase(repository);
  final getAllProductsUseCase = GetAllProductsUseCase(repository);

  // Example 1: Insert Products
  print('--- Example 1: Insert Products ---');
  final laptop = ProductEntity(
    id: 'prod_001',
    name: 'Gaming Laptop',
    description: 'High-performance laptop for gaming and development',
    price: 1299.99,
    imageUrl: 'https://example.com/laptop.jpg',
  );

  final phone = ProductEntity(
    id: 'prod_002',
    name: 'Smartphone',
    description: 'Latest smartphone with excellent camera',
    price: 799.99,
    imageUrl: 'https://example.com/phone.jpg',
  );

  final (insertedLaptop, insertLaptopError) =
      await insertProductUseCase(laptop);
  if (insertLaptopError != null) {
    print('❌ Error inserting laptop: ${insertLaptopError.message}');
  } else {
    print('✅ Successfully inserted: ${insertedLaptop!.name}');
  }

  final (insertedPhone, insertPhoneError) = await insertProductUseCase(phone);
  if (insertPhoneError != null) {
    print('❌ Error inserting phone: ${insertPhoneError.message}');
  } else {
    print('✅ Successfully inserted: ${insertedPhone!.name}');
  }
  print('');

  // Example 2: Get All Products
  print('--- Example 2: Get All Products ---');
  final (allProducts, getAllError) =
      await getAllProductsUseCase(const NoParams());
  if (getAllError != null) {
    print('❌ Error retrieving products: ${getAllError.message}');
  } else {
    print('✅ Retrieved ${allProducts!.length} products:');
    for (var product in allProducts) {
      print('   • ${product.name}: \$${product.price}');
    }
  }
  print('');

  // Example 3: Get Specific Product
  print('--- Example 3: Get Specific Product ---');
  final (retrievedLaptop, getError) = await getProductUseCase('prod_001');
  if (getError != null) {
    print('❌ Error retrieving product: ${getError.message}');
  } else {
    print('✅ Retrieved product:');
    print('   Name: ${retrievedLaptop!.name}');
    print('   Description: ${retrievedLaptop.description}');
    print('   Price: \$${retrievedLaptop.price}');
  }
  print('');

  // Example 4: Update Product
  print('--- Example 4: Update Product ---');
  final updatedLaptop = laptop.copyWith(
    price: 1199.99,
    description: 'Premium gaming laptop - now with 20% discount!',
  );

  final (updated, updateError) = await updateProductUseCase(updatedLaptop);
  if (updateError != null) {
    print('❌ Error updating product: ${updateError.message}');
  } else {
    print('✅ Successfully updated: ${updated!.name}');
    print('   New price: \$${updated.price}');
    print('   New description: ${updated.description}');
  }
  print('');

  // Example 5: Get All Products After Update
  print('--- Example 5: Get All Products After Update ---');
  final (updatedProducts, getAllError2) =
      await getAllProductsUseCase(const NoParams());
  if (getAllError2 != null) {
    print('❌ Error retrieving products: ${getAllError2.message}');
  } else {
    print('✅ Updated product list:');
    for (var product in updatedProducts!) {
      print('   • ${product.name}: \$${product.price}');
    }
  }
  print('');

  // Example 6: Error Handling - Invalid Product
  print('--- Example 6: Error Handling - Invalid Product ---');
  final invalidProduct = ProductEntity(
    id: 'prod_003',
    name: '',
    description: 'Product with empty name',
    price: 100.0,
    imageUrl: 'https://example.com/invalid.jpg',
  );

  final (_, insertError) = await insertProductUseCase(invalidProduct);
  if (insertError != null) {
    print('❌ Validation error (Expected): ${insertError.message}');
  }
  print('');

  // Example 7: Error Handling - Negative Price
  print('--- Example 7: Error Handling - Negative Price ---');
  final negativeProduct = ProductEntity(
    id: 'prod_004',
    name: 'Invalid Product',
    description: 'Product with negative price',
    price: -50.0,
    imageUrl: 'https://example.com/negative.jpg',
  );

  final (_, priceError) = await insertProductUseCase(negativeProduct);
  if (priceError != null) {
    print('❌ Validation error (Expected): ${priceError.message}');
  }
  print('');

  // Example 8: Delete Product
  print('--- Example 8: Delete Product ---');
  final (deleteSuccess, deleteError) = await deleteProductUseCase('prod_001');
  if (deleteError != null) {
    print('❌ Error deleting product: ${deleteError.message}');
  } else if (deleteSuccess) {
    print('✅ Successfully deleted product with ID: prod_001');
  }
  print('');

  // Example 9: Get All Products After Deletion
  print('--- Example 9: Get All Products After Deletion ---');
  final (finalProducts, getAllError3) =
      await getAllProductsUseCase(const NoParams());
  if (getAllError3 != null) {
    print('❌ Error retrieving products: ${getAllError3.message}');
  } else {
    print('✅ Remaining products (${finalProducts!.length}):');
    for (var product in finalProducts) {
      print('   • ${product.name}: \$${product.price}');
    }
  }
  print('');

  // Example 10: Error Handling - Non-existent Product
  print('--- Example 10: Error Handling - Non-existent Product ---');
  final (_, notFoundError) = await getProductUseCase('prod_nonexistent');
  if (notFoundError != null) {
    print('❌ Error (Expected): ${notFoundError.message}');
  }
  print('');

  print('=== Demo Complete ===');
}
