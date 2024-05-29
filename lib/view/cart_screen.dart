import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/models/cart_model.dart';
import 'package:restaurant_pos_mobile/view_models/cart_view_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// In CartScreenPage
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
  String orderNo = '';
  final TextEditingController noteController = TextEditingController();
  String noteText = ''; // To store the note text

  @override
  void initState() {
    super.initState();
    fetchTables();
    generateOrderNo();
    loadNote();
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

  Future<void> generateOrderNo() async {
    final response = await http
        .get(Uri.parse('http://localhost/mobile_apps/fetch_order_no.php'));

    if (response.statusCode == 200) {
      final latestOrderNo = json.decode(response.body)['order_no'];
      final nextOrderNo =
          (int.parse(latestOrderNo) + 1).toString().padLeft(3, '0');
      setState(() {
        orderNo = nextOrderNo;
      });
    } else {
      throw Exception('Failed to generate order number');
    }
  }

  Future<void> loadNote() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      noteText = prefs.getString('noteText') ?? '';
    });
  }

  Future<void> saveNote() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('noteText', noteText);
  }

  Future<void> submitOrder() async {
    final url = Uri.parse('http://localhost/mobile_apps/submit_data.php');
    final orderData = {
      'o_no': orderNo,
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
      'note': noteText, // Include the note in the order data
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
            noteText =
                ''; // Clear the note text upon successful order submission
          });
          saveNote(); // Save the note text to shared preferences
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

  void showAddNoteDialog() {
    noteController.text = noteText;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Note'),
          content: TextField(
            controller: noteController,
            decoration: const InputDecoration(
              hintText: 'Enter your note here',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  noteText = noteController.text; // Save the note text
                });
                saveNote(); // Save the note text to shared preferences
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
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
          Text('Order no : $orderNo'),
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
                return Dismissible(
                  key: Key(
                      '${item.name}_${item.tableNo}'), // Ensure each item has a unique key
                  onDismissed: (direction) {
                    setState(() {
                      widget.cartItems.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${item.name} dismissed")),
                    );
                  },
                  background:
                      Container(color: Color.fromARGB(255, 170, 131, 128)),
                  child: Card(
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${item.name}\nTable No - ${item.tableNo} \nVariation - ${item.variation}\nQuantity - ${item.quantity}\nAdd Ones - ${item.addOns}\nTotal Price - Rs. ${item.price * item.quantity}'),
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
                  ),
                );
              },
            ),
          ),
          if (noteText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Note: $noteText',
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ),
          ElevatedButton(
            onPressed: showAddNoteDialog,
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
