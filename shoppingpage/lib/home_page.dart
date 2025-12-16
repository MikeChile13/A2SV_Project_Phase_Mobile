import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/product.dart';
import 'add_product.dart';
import 'details_page.dart';
// import 'platform_image_io.dart';
// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     String today = DateFormat('EEE, MMM d').format(DateTime.now());

//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [

//               // ---- TOP ROW (profile + date + bell) ----
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Profile picture
//                   Container(
//                     width: 60,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                       child: const Icon(
//                         Icons.shopping_cart, // or shopping_cart, store, etc.
//                         size: 32,
//                         color: Colors.blueGrey,
//                       ),
//                   ),

//                   const SizedBox(width: 10),

//                   // Date + name
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         today,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       const Text(
//                         "Michael Chileshe",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),

//                   // Push bell to right
//                   const Spacer(),

//                   IconButton(
//                     onPressed: () {},
//                     icon: const Icon(Icons.notifications),
//                   ),
//                 ],
//               ),

//               // Add spacing below header
//               const SizedBox(height: 24),

//               // The rest of the body is empty (you can add later)\
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Available Products',
//                   style: TextStyle(
//                     fontSize: 30,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.search),
//                   onPressed: () {
//                     // Your search action here
//                   },
//                 ),
//               ],
//             )
//             ],
//           ),
//         ),
//       ),

//       // Floating action button
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.blue,
//         shape: const CircleBorder(),
//         onPressed: () => Navigator.pushNamed(context, '/add'),
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
// }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Product> _products = [];

  @override
  Widget build(BuildContext context) {
    String today = DateFormat('EEE, MMM d').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- TOP ROW (profile + date + bell) ----
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile picture
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.shopping_cart, // or shopping_cart, store, etc.
                      size: 32,
                      color: Colors.blueGrey,
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Date + name
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        today,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Michael Chileshe",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Push bell to right
                  const Spacer(),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Available Products header with search button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Products',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      //search action 
                    },
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Product list or empty placeholder
              Expanded(
                child: _products.isEmpty
                    ? const Center(child: Text("No products added yet."))
                    : ListView.builder(
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailsPage(
                                    product: product,
                                    onDelete: () {
                                      setState(() {
                                        _products.removeAt(index);
                                      });
                                      Navigator.pop(context);
                                    },
                                    onEdit: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddProduct(
                                            product: product,
                                            index: index,
                                            onUpdate: (updated, idx) {
                                              setState(() {
                                                _products[idx] = updated;
                                              });
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.memory(
                                    product.imageBytes,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.category,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Kwacha ${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
  backgroundColor: Colors.blue,
  shape: const CircleBorder(),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProduct(
          onAdd: (product) {
            setState(() {
              _products.add(product); // add product to list
            });
          },
        ),
      ),
    );
  },
  child: const Icon(Icons.add, color: Colors.white),
),

    );
  }
}
