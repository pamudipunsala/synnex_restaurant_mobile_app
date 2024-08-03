import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ViewScreenPage extends StatefulWidget {
  final String orderId;
  final String tabelNo; // Add this line

  const ViewScreenPage({
    Key? key,
    required this.orderId,
    required this.tabelNo, // Add this line
    required List orderDetails,
  }) : super(key: key);

  @override
  _ViewScreenState createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreenPage> {
  List orderItems = [];
  Map<int, int> quantities = {};

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

    print('Response status: ${response.statusCode}');
    print('Response headers: ${response.headers}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        if (response.headers['content-type']?.contains('application/json') ==
            true) {
          var decodedBody = json.decode(response.body);
          if (decodedBody is List) {
            setState(() {
              orderItems = decodedBody;
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

  Future<void> _submitChanges() async {
    final updatedItems = orderItems.map((item) {
      final itemId = item['item_id'];
      final quantity = quantities[itemId] ?? item['quantity'];
      final price =
          (item['price'] as num).toDouble(); // Ensure price is a double
      final totalPrice = price * quantity;

      return {
        'item_id': itemId,
        'quantity': quantity,
        'item': item['item'],
        'price': price,
        'note': item['note'],
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

    if (response.statusCode == 200) {
      print('Response: ${response.body}');
    } else {
      print('Error: ${response.statusCode}');
    }
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
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // Logic for search functionality can be implemented here
                },
              ),
            ),
            Text('Table no : ${widget.tabelNo}'),
            Text('Order no : ${widget.orderId}'),
            Expanded(
              child: ListView.builder(
                itemCount: orderItems.length,
                itemBuilder: (context, index) {
                  var item = orderItems[index];
                  int itemId = item['item_id'];
                  int quantity = quantities[itemId] ?? item['quantity'];
                  double price = (item['price'] as num)
                      .toDouble(); // Ensure price is a double
                  double totalPrice = price * quantity;

                  return Card(
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
