import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

import 'package:restaurant_pos_mobile/constants.dart';

class ViewScreenPage extends StatefulWidget {
  final int orderId;
  final String orderNo;
  final int tabelNo;

  const ViewScreenPage({
    Key? key,
    required this.orderId,
    required this.orderNo,
    required this.tabelNo,
    required List orderDetails,
  }) : super(key: key);

  @override
  _ViewScreenState createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreenPage> {
  List orderItems = [];
  List filteredItems = [];
  Map<int, int> quantities = {};
  final String url = '$apiDomain$orderEditEndpoint';

  @override
  void initState() {
    super.initState();
    _fetchOrderItems();
  }

  Future<void> _fetchOrderItems() async {
    final response = await http.post(
      Uri.parse(url),
      body: {'o_id': widget.orderId.toString()},
    );

    if (response.statusCode == 200) {
      try {
        if (response.headers['content-type']?.contains('application/json') ==
            true) {
          var decodedBody = json.decode(response.body);
          if (decodedBody is List) {
            setState(() {
              orderItems = decodedBody;
              filteredItems = orderItems;
              quantities = {
                for (var item in orderItems) item['item_id']: item['quantity']
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
      filteredItems = orderItems.where((item) {
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
              'View Order',
              style: GoogleFonts.bacasimeAntique(
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
        color: Color.fromARGB(255, 235, 226, 225),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Platform.isIOS
                  ? CupertinoSearchTextField(
                      placeholder: 'Search...',
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
            Text('Table no : ${widget.tabelNo}'),
            Text('Order no : ${widget.orderNo}'),
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  var item = filteredItems[index];
                  int itemId = item['item_id'];
                  int quantity = quantities[itemId] ?? item['quantity'];
                  double price = (item['price'] as num).toDouble();
                  double totalPrice = price * quantity;

                  return Card(
                    color: Color.fromARGB(255, 250, 236, 234),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 202, 158, 150),
                        width: 5.0,
                      ),
                    ),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Item: ${item['item']}\nNote: ${item['note']}\nQuantity: $quantity\nPrice: ${price.toStringAsFixed(2)}\nTotal: ${totalPrice.toStringAsFixed(2)}',
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
                Navigator.pop(context);
              },
              child: const Text('Back'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
