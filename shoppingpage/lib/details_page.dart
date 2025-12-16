import 'package:flutter/material.dart';
import 'models/product.dart';

class DetailsPage extends StatelessWidget {
  final Product product;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const DetailsPage({super.key, required this.product, this.onDelete, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Delete product?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
                  ],
                ),
              );
              if (confirm == true) onDelete?.call();
            },
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.memory(
              product.imageBytes,
              width: double.infinity,
              height: 260,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product.category, style: TextStyle(color: Colors.grey[600])),
                      Text('Kwacha ${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(product.description, style: const TextStyle(fontSize: 14, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
