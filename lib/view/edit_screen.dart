import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/view_models/cart_view_model.dart';

class EditScreenPage extends StatefulWidget {
  const EditScreenPage({Key? key}) : super(key: key);

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreenPage> {
  CartScreen cart = CartScreen();
  int quantity = 0; // Default quantity

  void incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decrementQuantity() {
    setState(() {
      if (quantity > 0) {
        quantity--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Order'),
        backgroundColor: const Color.fromARGB(255, 71, 4, 4),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: cart.searchController,
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Logic
              },
            ),
          ),
          const Text('Table no : 01'),
          const Text('Order no : 0001'),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fried Rice\nVariation - Chicken\nAdd Ones - cheese Source\nTotal Price - Rs. 1600',
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: decrementQuantity,
                            ),
                            Text('$quantity'), // Display quantity
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: incrementQuantity,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              cart.toOrderHistory(context);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }
}
