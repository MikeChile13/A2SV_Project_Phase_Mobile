import 'package:flutter/material.dart';
import 'models/product.dart';

class SearchPage extends StatefulWidget {
  final List<Product> products;
  const SearchPage({super.key, required this.products});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  RangeValues _priceRange = const RangeValues(0, 10000);
  late List<Product> _filteredProducts;
  final List<String> _categories = ["Shoes", "Shirts", "Trousers", "Dresses"];
  String _selectedCategory = 'All'; // Default to 'All', no longer nullable

  @override
  void initState() {
    super.initState();
    _filteredProducts = List.from(widget.products);
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
  }

  // Build dropdown items once (outside Builder for simplicity)
  List<DropdownMenuItem<String>> get _categoryItems {
    return [
      const DropdownMenuItem(value: 'All', child: Text('All')),
      ..._categories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: theme.colorScheme.onBackground),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Search Product',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 12),

              // Search field
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search product',
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // === FILTERS in a scrollable area if needed ===
              // Wrap filters in Expanded or SingleChildScrollView if too tall
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category
                      Text('Category', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: _categoryItems,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                            _applyFilters();
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Price
                      Text('Price', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('0', style: theme.textTheme.bodySmall),
                          Text('10,000', style: theme.textTheme.bodySmall),
                        ],
                      ),
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 10000,
                        divisions: 100,
                        labels: RangeLabels(
                          _priceRange.start.round().toString(),
                          _priceRange.end.round().toString(),
                        ),
                        onChanged: (value) {
                          setState(() => _priceRange = value);
                          _applyFilters();
                        },
                        activeColor: theme.colorScheme.secondary,
                      ),

                      const SizedBox(height: 16),

                      // Apply Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _applyFilters,
                          child: const Text('APPLY', style: TextStyle(color: Colors.white)),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // === PRODUCT LIST ===
                      ..._filteredProducts.isEmpty
                          ? [Center(child: Text('No products found', style: theme.textTheme.bodyLarge))]
                          : _filteredProducts.map((p) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.brightness == Brightness.dark
                                            ? Colors.black.withOpacity(0.6)
                                            : Colors.grey.withOpacity(0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                        child: Image.memory(
                                          p.imageBytes,
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    p.name,
                                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    p.description,
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  'Kwacha ${p.price.toStringAsFixed(0)}',
                                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.star, size: 16, color: Colors.amber),
                                                    const SizedBox(width: 4),
                                                    Text('(4.0)', style: theme.textTheme.bodySmall),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    final min = _priceRange.start;
    final max = _priceRange.end;

    setState(() {
      _filteredProducts = widget.products.where((p) {
        final matchesQuery = query.isEmpty || p.name.toLowerCase().contains(query);
        final matchesPrice = p.price >= min && p.price <= max;
        final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
        return matchesQuery && matchesPrice && matchesCategory;
      }).toList();
    });
  }
}