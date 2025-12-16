import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'models/product.dart';
// Allows digits and one optional decimal point with up to `decimalRange` places
// Example: 123.45
class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;
  DecimalTextInputFormatter({this.decimalRange = 2}) : assert(decimalRange >= 0);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;
    if (text.isEmpty) return newValue;
    // Allow leading '.' -> '0.'
    if (text == '.') return TextEditingValue(text: '0.', selection: TextSelection.collapsed(offset: 2));
    // Only digits and decimal point
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) return oldValue;
    if (text.contains('.')) {
      final parts = text.split('.');
      if (parts.length > 2) return oldValue; // more than one dot
      if (decimalRange >= 0 && parts[1].length > decimalRange) return oldValue; // too many decimals
    }
    return newValue;
  }
}

class AddProduct extends StatefulWidget {
  final Function(Product)? onAdd; // callback to send product back
  final Function(Product, int)? onUpdate; // update existing product at index
  final Product? product; // optional initial product for editing
  final int? index; // index when editing

  const AddProduct({super.key, this.onAdd, this.onUpdate, this.product, this.index});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  Uint8List? _imageBytes;

  final List<String> categories = ["Shoes", "Shirts", "Trousers", "Dresses"];

  final ImagePicker _picker = ImagePicker();

  

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _descriptionController.text = widget.product!.description;
      _selectedCategory = widget.product!.category;
      _imageBytes = widget.product!.imageBytes;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  void _saveProduct() {
    final hasImage = _imageBytes != null;
    if (_formKey.currentState!.validate() && _selectedCategory != null && hasImage) {
      final product = Product(
        name: _nameController.text.trim(),
        category: _selectedCategory!,
        price: double.parse(_priceController.text.trim()),
        imageBytes: _imageBytes!,
        description: _descriptionController.text.trim(),
      );
      if (widget.onUpdate != null && widget.index != null) {
        widget.onUpdate!(product, widget.index!);
      } else if (widget.onAdd != null) {
        widget.onAdd!(product);
      }
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select an image')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              // Image picker (clearer UI)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[850]
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade700),
                  ),
                  child: _imageBytes == null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.add_a_photo, size: 48, color: Colors.white70),
                              SizedBox(height: 8),
                              Text(
                                'Tap to add image',
                                style: TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.memory(_imageBytes!, height: 180, width: double.infinity, fit: BoxFit.cover),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.black45,
                                  child: const Icon(Icons.edit, size: 18, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Product Name"),
                validator: (value) => (value == null || value.isEmpty) ? "Enter product name" : null,
              ),

              const SizedBox(height: 20),

              // Description field
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (value) => (value == null || value.isEmpty) ? "Enter a description" : null,
              ),

              const SizedBox(height: 20),

              // Category dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Category"),
                items: categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                value: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) => value == null ? "Select a category" : null,
              ),

              const SizedBox(height: 20),

              // Price field
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                  DecimalTextInputFormatter(decimalRange: 2),
                ],
                decoration: const InputDecoration(labelText: "Price (Kwacha)"),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter price";
                  final n = num.tryParse(value);
                  if (n == null) return "Enter a valid number";
                  return null;
                },
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _saveProduct,
                child: Text(widget.product == null ? "Add Product" : "Save Changes"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
