import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class EditScreenPage extends StatefulWidget {
  final String orderId;
  final String tabelNo;
  final String orderNo;

  const EditScreenPage({
    Key? key,
    required this.orderId,
    required this.tabelNo,
    required this.orderNo,
    required List orderDetails,
  }) : super(key: key);

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreenPage> {
  List orderItems = [];
  List filteredOrderItems = [];
  Map<int, int> quantities = {};
  Map<int, TextEditingController> noteControllers = {};

  @override
  void initState() {
    super.initState();
    _fetchOrderItems();
  }

  Future<void> _fetchOrderItems() async {
    final response = await http.post(
      Uri.parse('https://mobileapp.synnexcloudpos.com/OrderEdit.php'),
      body: {'o_id': widget.orderId},
    );

    if (response.statusCode == 200) {
      try {
        if (response.headers['content-type']?.contains('application/json') ==
            true) {
          var decodedBody = json.decode(response.body);
          if (decodedBody is List) {
            setState(() {
              orderItems = decodedBody;
              filteredOrderItems = orderItems; // Initialize with all items
              quantities = {
                for (var item in orderItems) item['item_id']: item['quantity']
              };
              noteControllers = {
                for (var item in orderItems)
                  item['item_id']: TextEditingController(text: item['note'])
              };
            });
          } else {
            print('Expected a list but got: $decodedBody');
          }
        } else {
          throw Exception('Unexpected HTML response');
        }
      } catch (e) {
        print('Error decoding JSON: $e');
      }
    } else {
      throw Exception('Failed to load order items');
    }
  }

  void _filterItems(String query) {
    setState(() {
      filteredOrderItems = orderItems.where((item) {
        return item['item']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item['price']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item['note']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item['quantity']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase());
      }).toList();
    });
  }

  void incrementQuantity(int itemId) {
    setState(() {
      quantities[itemId] = (quantities[itemId] ?? 0) + 1;
    });
  }

  void decrementQuantity(int itemId) {
    setState(() {
      if (quantities[itemId] != null && quantities[itemId]! > 1) {
        quantities[itemId] = quantities[itemId]! - 1;
      }
    });
  }

  Future<void> _submitChanges() async {
    final updatedItems = filteredOrderItems.map((item) {
      final itemId = item['item_id'];
      final quantity = quantities[itemId] ?? item['quantity'];
      final price = (item['price'] as num).toDouble();
      final totalPrice = price * quantity;

      return {
        'item_id': itemId,
        'quantity': quantity,
        'item': item['item'],
        'price': price,
        'note': noteControllers[itemId]?.text ?? item['note'],
        'total_before_discount': item['total_before_discount'],
        'discout': item['discout'],
        'total': totalPrice,
        'kot_type': item['kot_type'],
        'o_id': item['o_id'],
        'com_id': item['com_id'],
      };
    }).toList();

    final response = await http.post(
      Uri.parse('https://mobileapp.synnexcloudpos.com/editorder.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedItems),
    );
    Navigator.pop(context);
    if (response.statusCode == 200) {
      print('Response: ${response.body}');
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    for (var controller in noteControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text(
                'Edit Order',
                style: GoogleFonts.archivo(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              backgroundColor: const Color.fromARGB(255, 71, 4, 4),
            ),
            child: _buildBody(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 71, 4, 4),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              title: Text(
                'Edit Order',
                style: GoogleFonts.archivo(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            body: _buildBody(),
          );
  }

  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFDAB3AC),
            Color(0xFFF0E1DA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Platform.isIOS
                ? CupertinoSearchTextField(
                    onChanged: _filterItems,
                  )
                : TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _filterItems,
                  ),
          ),
          Text(
            'Table no : ${widget.tabelNo}',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.normal,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            'Order no : ${widget.orderNo}',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.normal,
              decoration: TextDecoration.none,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredOrderItems.length,
              itemBuilder: (context, index) {
                var item = filteredOrderItems[index];
                int itemId = item['item_id'];
                int quantity = quantities[itemId] ?? item['quantity'];
                double price = (item['price'] as num).toDouble();
                double totalPrice = price * quantity;

                return Card(
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Item: ${item['item']}'),
                        Platform.isIOS
                            ? CupertinoTextField(
                                controller: noteControllers[itemId],
                                placeholder: 'Note',
                              )
                            : TextField(
                                controller: noteControllers[itemId],
                                decoration: const InputDecoration(
                                  labelText: 'Note',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                        Text('Quantity: $quantity'),
                        Text('Price: ${price.toStringAsFixed(2)}'),
                        Text('Total: ${totalPrice.toStringAsFixed(2)}'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => decrementQuantity(itemId),
                            ),
                            Text('$quantity'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => incrementQuantity(itemId),
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Platform.isIOS
                ? CupertinoButton(
                    color: const Color.fromARGB(255, 71, 4, 4),
                    onPressed: _submitChanges,
                    child: Text(
                      'Save Changes',
                      style: GoogleFonts.archivo(
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 71, 4, 4),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 8,
                      textStyle: GoogleFonts.archivo(
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onPressed: _submitChanges,
                    child: const Text('Save Changes'),
                  ),
          ),
        ],
      ),
    );
  }
}
