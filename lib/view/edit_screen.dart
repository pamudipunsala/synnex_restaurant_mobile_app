import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        backgroundColor: const Color.fromARGB(255, 71, 4, 4),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Edit Order',
              style: GoogleFonts.archivo(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              // rgb(240, 225, 218)
              Color(0xFFDAB3AC),
              Color(0xFFF0E1DA), // rgb(218, 179, 172)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
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
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    const Color.fromARGB(255, 71, 4, 4), // Text color
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0), // Rounded corners
                ),
                elevation: 8, // Shadow effect
                textStyle: GoogleFonts.archivo(
                  textStyle: const TextStyle(
                    fontSize: 18, // Adjust font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onPressed: () {
                cart.toOrderHistory(context);
              },
              child: const Text('Edit'),
            ),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}
