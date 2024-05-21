import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/view_models/cart_view_model.dart';
import 'package:http/http.dart' as http;

class CartScreenPage extends StatefulWidget {
  const CartScreenPage({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreenPage> {
  List<dynamic> tables = [];
  List<dynamic> filteredTables = [];
  CartScreen cart = CartScreen();
  String selectedOption = 'Table Status';

  @override
  void initState() {
    super.initState();
    fetchTables();
  }

  Future<void> fetchTables() async {
    final response = await http
        .get(Uri.parse('http://localhost/mobile_apps/fetch_table_data.php'));

    if (response.statusCode == 200) {
      setState(() {
        tables = json.decode(response.body);
        filteredTables = List.from(tables);
      });
    } else {
      throw Exception('Failed to load tables');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: const Color.fromARGB(255, 71, 4, 4),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Column(
        children: [
          const Text('Table no : 01'),
          const Text('Order no : 0001'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedOption,
              onChanged: (String? newValue) {
                setState(() {
                  selectedOption = newValue!;
                });
              },
              items: <String>[
                'Table Status',
                'Table 1',
                'Table 2',
                'Table 3',
                'Table 4'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return const Card(
                  child: ListTile(
                    title: Text(
                      'Fried Rice\nVariation - Chicken\nQuantity - 2\nAdd Ones - cheese Source\nTotal Price - Rs. 1600',
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              cart.toNote(context);
            },
            child: const Text('Add Note'),
          ),
          ElevatedButton(
            onPressed: () {
              cart.toMenu(context);
            },
            child: const Text('Add More'),
          ),
          ElevatedButton(
            onPressed: () {
              cart.toOrderHistory(context);
            },
            child: const Text('Place Order'),
          ),
        ],
      ),
    );
  }
}
