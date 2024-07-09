import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/models/cart_model.dart';
import 'package:restaurant_pos_mobile/view_models/cart_view_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartScreenPage extends StatefulWidget {
  final List<CartItem> cartItems;

  const CartScreenPage(
      {Key? key, required this.cartItems, required int tableNo})
      : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreenPage> {
  List<dynamic> tables = [];
  List<dynamic> filteredTables = [];
  CartScreen cart = CartScreen();
  String selectedOption = 'Table Status';
  String orderNo = '';
  String tableNo = '';
  final TextEditingController noteController = TextEditingController();
  String noteText = '';

  @override
  void initState() {
    super.initState();
    fetchTables();
    loadNote();

    String? comId =
        widget.cartItems.isNotEmpty && widget.cartItems.last.comId.isNotEmpty
            ? widget.cartItems.last.comId
            : '1'; // Default value as '1'
    generateOrderNo(comId); // Pass comId to generateOrderNo
  }

  Future<void> fetchTables() async {
    final response = await http.post(
      Uri.parse('https://mobileapp.synnexcloudpos.com'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'table_id': '1',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        tables = json.decode(response.body);
        filteredTables = List.from(tables);
      });
    } else {
      throw Exception('Failed to load tables');
    }
  }

// Future<void> fetchTables() async {
//   final response = await http.post(
//     Uri.parse('https://mobileapp.synnexcloudpos.com'),
//     headers: {'Content-Type': 'application/json'},
//     body: jsonEncode({'request_type': 'fetch_tables'}), // Example payload
//   );

//   if (response.statusCode == 200) {
//     setState(() {
//       tables = json.decode(response.body);
//       filteredTables = List.from(tables);
//     });
//   } else {
//     throw Exception('Failed to load tables');
//   }
// }

  Future<void> generateOrderNo(String? comId) async {
    print('Generating order number...'); // Debugging print statement

    final response = await http.post(
      Uri.parse('https://mobileapp.synnexcloudpos.com'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'com_id': '1',
      },
    );

    print(
        'HTTP response status: ${response.statusCode}'); // Debugging print statement
    print('HTTP response body: ${response.body}'); // Debugging print statement

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw Exception('Empty response body');
      }

      final List<dynamic> data = json.decode(response.body);
      final comId = data.isNotEmpty ? data[0]['com_id'] : null;
      print('Received com_id: $comId'); // Debugging print statement

      if (comId != null && comId.isNotEmpty) {
        final orderResponse = await http.post(
          Uri.parse('https://mobileapp.synnexcloudpos.com'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'com_id': comId,
          },
        );

        print(
            'Order response status: ${orderResponse.statusCode}'); // Debugging print statement
        print(
            'Order response body: ${orderResponse.body}'); // Debugging print statement

        if (orderResponse.statusCode == 200) {
          if (orderResponse.body.isEmpty) {
            throw Exception('Empty order response body');
          }

          final orderData = json.decode(orderResponse.body);
          final latestOrderNo =
              orderData.isNotEmpty ? orderData[0]['o_no'] : null;
          print(
              'Latest order number fetched: $latestOrderNo'); // Debugging print statement

          if (latestOrderNo != null) {
            final nextOrderNo =
                (int.parse(latestOrderNo) + 1).toString().padLeft(3, '0');
            setState(() {
              orderNo = nextOrderNo;
            });
            print(
                'Next order number generated: $orderNo'); // Debugging print statement
          } else {
            setState(() {
              orderNo = '001';
            });
            print(
                'Starting order number from 001'); // Debugging print statement
          }
        } else {
          print(
              'Failed to fetch order number: ${orderResponse.statusCode}'); // Debugging print statement
          throw Exception('Failed to fetch order number');
        }
      } else {
        print('Received empty or invalid com_id'); // Debugging print statement
        throw Exception('Empty or invalid com_id received');
      }
    } else {
      print(
          'Failed to fetch com_id: ${response.statusCode}'); // Debugging print statement
      throw Exception('Failed to fetch com_id');
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
    final comId = widget.cartItems.isNotEmpty
        ? widget.cartItems.last.comId
        : '1'; // Ensure com_id is provided

    final orderData = {
      'o_no': orderNo,
      'table_no': widget.cartItems.isNotEmpty ? widget.cartItems[0].tableNo : 0,
      'com_id': comId,
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
      'note': noteText,
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
            noteText = '';
          });
          saveNote();
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
                            '${item.name}\nTable No - ${item.tableNo} \nVariation - ${item.variation}\nQuantity - ${item.quantity}\nAdd Ones - ${item.addOns}\nTotal Price - Rs. ${item.price * item.quantity}',
                          ),
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
          if (widget.cartItems.isNotEmpty && noteText.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.grey[200],
              child: Text(
                'Note: $noteText',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ElevatedButton(
            onPressed: showAddNoteDialog,
            child: Text('Add Note'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: submitOrder,
        child: Icon(Icons.check),
        backgroundColor: const Color.fromARGB(255, 71, 4, 4),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
    );
  }
}
