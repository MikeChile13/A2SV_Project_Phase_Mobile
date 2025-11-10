import 'dart:io';

class Product {
  String name;
  String description;
  double price;
  String imageUrl;
  bool isCompleted;

  Product({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isCompleted = false,
  });

  void markAsCompleted() {
    isCompleted = true;
  }

  void edit({
    String? name,
    String? description,
    double? price,
    String? imageUrl,
  }) {
    if (name != null) this.name = name;
    if (description != null) this.description = description;
    if (price != null) this.price = price;
    if (imageUrl != null) this.imageUrl = imageUrl;
  }

  @override
  String toString() {
    return '''
Product:
  Name: $name
  Description: $description
  Price: ZMW ${price.toStringAsFixed(2)}
  Image: $imageUrl
  Completed: ${isCompleted ? "Yes" : "No"}
''';
  }
}

class ProductManager {
  final List<Product> _products = [];

  void addProduct(Product product) {
    _products.add(product);
    print('Product "${product.name}" added successfully.');
  }

  void viewAllProducts() {
    if (_products.isEmpty) {
      print('No products found.');
      return;
    }
    print('All Products:');
    for (var product in _products) {
      print(product);
    }
  }

  void viewCompletedProducts() {
    final completed = _products.where((p) => p.isCompleted).toList();
    if (completed.isEmpty) {
      print('No completed products.');
      return;
    }
    print('Completed Products:');
    for (var product in completed) {
      print(product);
    }
  }

  void viewPendingProducts() {
    final pending = _products.where((p) => !p.isCompleted).toList();
    if (pending.isEmpty) {
      print('No pending products.');
      return;
    }
    print('Pending Products:');
    for (var product in pending) {
      print(product);
    }
  }

  void editProduct(String name) {
    final product = _products.firstWhere(
      (p) => p.name.toLowerCase() == name.toLowerCase(),
      orElse: () => Product(name: '', description: '', price: 0, imageUrl: ''),
    );

    if (product.name.isEmpty) {
      print('Product not found.');
      return;
    }

    stdout.write('Enter new name (leave blank to keep "${product.name}"): ');
    final newName = stdin.readLineSync();
    stdout.write('Enter new description (leave blank to keep current): ');
    final newDesc = stdin.readLineSync();
    stdout.write('Enter new price (leave blank to keep ${product.price}): ');
    final newPriceInput = stdin.readLineSync();
    stdout.write('Enter new image URL (leave blank to keep current): ');
    final newImage = stdin.readLineSync();

    double? newPrice = double.tryParse(newPriceInput ?? '');

    product.edit(
      name: newName!.isEmpty ? null : newName,
      description: newDesc!.isEmpty ? null : newDesc,
      price: newPrice ?? product.price,
      imageUrl: newImage!.isEmpty ? null : newImage,
    );

    print('Product "${product.name}" updated successfully.');
  }

  void deleteProduct(String name) {
    _products.removeWhere((p) => p.name.toLowerCase() == name.toLowerCase());
    print('Product "$name" deleted successfully.');
  }

  void markProductCompleted(String name) {
    final product = _products.firstWhere(
      (p) => p.name.toLowerCase() == name.toLowerCase(),
      orElse: () => Product(name: '', description: '', price: 0, imageUrl: ''),
    );

    if (product.name.isEmpty) {
      print('Product not found.');
      return;
    }

    product.markAsCompleted();
    print('Product "${product.name}" marked as completed.');
  }
}

void main() {
  final manager = ProductManager();

  while (true) {
    print('''
==== E-Commerce Manager ====
1. Add Product
2. View All Products
3. View Completed Products
4. View Pending Products
5. Edit Product
6. Delete Product
7. Mark Product as Completed
8. Exit
Select an option:
''');

    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        stdout.write('Enter product name: ');
        final name = stdin.readLineSync()!;
        stdout.write('Enter description: ');
        final desc = stdin.readLineSync()!;
        stdout.write('Enter price: ');
        final price = double.parse(stdin.readLineSync()!);
        stdout.write('Enter image URL: ');
        final image = stdin.readLineSync()!;
        manager.addProduct(Product(name: name, description: desc, price: price, imageUrl: image));
        break;

      case '2':
        manager.viewAllProducts();
        break;

      case '3':
        manager.viewCompletedProducts();
        break;

      case '4':
        manager.viewPendingProducts();
        break;

      case '5':
        stdout.write('Enter product name to edit: ');
        final name = stdin.readLineSync()!;
        manager.editProduct(name);
        break;

      case '6':
        stdout.write('Enter product name to delete: ');
        final name = stdin.readLineSync()!;
        manager.deleteProduct(name);
        break;

      case '7':
        stdout.write('Enter product name to mark as completed: ');
        final name = stdin.readLineSync()!;
        manager.markProductCompleted(name);
        break;

      case '8':
        print('Exiting...');
        return;

      default:
        print('Invalid choice, try again.');
    }
  }
}
