import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/models/cart_model.dart';
import 'package:restaurant_pos_mobile/view_models/cart_view_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartScreenPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final String userId;
  final int tableNo;
  final String comId;

  const CartScreenPage({
    Key? key,
    required this.cartItems,
    required this.tableNo,
    required this.comId,
    required this.userId,
  }) : super(key: key);

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
  double totalPrice = 0.0;
  int? oId;

  @override
  void initState() {
    super.initState();
    fetchTables();
    loadNote();
    calculateTotalPrice();

    if (widget.cartItems.isNotEmpty && widget.cartItems.last.comId.isNotEmpty) {
      generateOrderNo(widget.comId);
    } else {
      // Handle the case where comId is missing
      // You might want to show an error message or handle it differently based on your requirements
      print("Error: comId is missing.");
    }
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

  Future<void> generateOrderNo(String? comId) async {
    print('Generating order number...'); // Debugging print statement

    final response = await http.post(
      Uri.parse('https://mobileapp.synnexcloudpos.com'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'com_id': comId,
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
    final comId = widget.cartItems.isNotEmpty
        ? widget.cartItems.last.comId
        : widget.comId;
    final currentDate = DateTime.now();
    final formattedDateTime =
        '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')} ${currentDate.hour.toString().padLeft(2, '0')}:${currentDate.minute.toString().padLeft(2, '0')}:${currentDate.second.toString().padLeft(2, '0')}';
    final allNotes = widget.cartItems.map((item) => item.note).join(', ');

    final orderData = {
      'o_no': orderNo,
      'tabel_no': widget.tableNo.toString(),
      'com_id': comId,
      'total_payable': totalPrice + (totalPrice * 0.05),
      'created_date': formattedDateTime,
      'total_discount': 0.00,
      'total_before_discount': totalPrice,
      'service_charge': totalPrice * 0.05,
      'total_paid': 0.00,
      'payment_method': 0,
      'delivery': 0,
      'waiter': widget.userId.toString(),
      'added_by': widget.userId.toString(),
      'status': 0,
      'order_note': allNotes,
      'o_type': 1,
      'customer': '1',
      'cancel_reason': 'vdvcd',
      'canceled_by': 0,
      'items': widget.cartItems
          .map((item) => {
                'item_id': item.productId,
                'item': item.name.toString(),
                'quantity': item.quantity,
                'price': item.price,
                'note': item.note.toString(),
                'total_before_discount': item.price * item.quantity,
                'discout': item.price * 0.05,
                'total': item.price * item.quantity,
                'kot_type': item.kotType,
                'o_id': 126,
                'com_id': item.comId,
              })
          .toList(),
    };

    print('Order data being sent: $orderData'); // Debugging print statement

    try {
      final response = await http.post(
        Uri.parse('https://mobileapp.synnexcloudpos.com'),
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

  // void showAddNoteDialog() {
  //   noteController.text = noteText;
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Note'),
  //         content: TextField(
  //           controller: noteController,
  //           decoration: const InputDecoration(
  //             hintText: 'Enter your note here',
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close the dialog
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('Save'),
  //             onPressed: () {
  //               setState(() {
  //                 noteText = noteController.text; // Save the note text
  //               });
  //               saveNote(); // Save the note text to shared preferences
  //               Navigator.of(context).pop(); // Close the dialog
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void calculateTotalPrice() {
    double total = 0.0;
    for (var item in widget.cartItems) {
      total += item.price * item.quantity;
    }
    setState(() {
      totalPrice = total;
    });
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
          Text(
            'Order no : $orderNo',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
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
                            '${item.name}\nTable No - ${item.tableNo} \nVariation - ${item.variation}\nQuantity - ${item.quantity}\nAdd Ones - ${item.addOns}\nNote - ${item.note}\nTotal Price - Rs. ${item.price * item.quantity}',
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
                                      calculateTotalPrice();
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
                                    calculateTotalPrice();
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
          Text('Total Price =  Rs. $totalPrice',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          // ElevatedButton(
          //   onPressed: showAddNoteDialog,
          //   child: Text('Add Note'),
          // ),
          ElevatedButton(
            onPressed: () {
              cart.toMenu(context);
            },
            child: Text('Add More'),
          ),
          ElevatedButton(
            onPressed: submitOrder,
            child: Text('Place Order'),
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
