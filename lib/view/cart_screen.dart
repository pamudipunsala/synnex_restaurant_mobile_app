import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/models/cart_model.dart';
import 'package:restaurant_pos_mobile/view_models/cart_view_model.dart';
import 'package:http/http.dart' as http;

class CartScreenPage extends StatefulWidget {
  final List<CartItem> cartItems;

  const CartScreenPage({Key? key, required this.cartItems}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreenPage> {
  List<dynamic> tables = [];
  List<dynamic> filteredTables = [];
  CartScreen cart = CartScreen();
  String selectedOption = 'Table Status';
  String orderNumber = '001';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchTables();
    generateOrderNumber();
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

  Future<void> generateOrderNumber() async {
    final response = await http
        .get(Uri.parse('http://localhost/mobile_apps/fetch_order_no.php'));

    if (response.statusCode == 200) {
      final latestOrderNumber =
          json.decode(response.body)['latest_order_number'];
      if (latestOrderNumber != null) {
        final int latestNumber = int.parse(latestOrderNumber);
        final nextOrderNumber = (latestNumber + 1).toString().padLeft(4, '0');
        setState(() {
          orderNumber = nextOrderNumber;
        });
      }
    } else {
      throw Exception('Failed to fetch latest order number');
    }
  }

  Future<void> submitOrder() async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse('http://localhost/mobile_apps/submit_data.php');
    final orderData = {
      'o_no': orderNumber,
      'table_no': widget.cartItems.isNotEmpty ? widget.cartItems[0].tableNo : 0,
      'items': widget.cartItems
          .map((item) => {
                'item': item.name,
                'variation': item.variation,
                'add_ons': item.addOns,
                'quantity': item.quantity,
                'price': item.price,
                'table_no': item.tableNo,
              })
          .toList(),
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(orderData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
          setState(() {
            widget.cartItems.clear();
            generateOrderNumber();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
    print(orderData);
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
          Text('Order no : $orderNumber'),
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
                return Card(
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${item.name}\nTable No - ${item.tableNo} \nVariation - ${item.variation}\nQuantity - ${item.quantity}\nAdd Ones - ${item.addOns}\nTotal Price - Rs. ${item.price}\nNote - ${item.note}'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if (item.quantity > 1) {
                                    item.quantity--;
                                  }
                                });
                              },
                            ),
                            Text(item.quantity.toString()),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  item.quantity++;
                                });
                              },
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
              cart.toNote(context);
            },
            child: const Text('Add Note'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Add More'),
          ),
          ElevatedButton(
            onPressed: submitOrder,
            child: const Text('Place Order'),
          ),
        ],
      ),
    );
  }
}
