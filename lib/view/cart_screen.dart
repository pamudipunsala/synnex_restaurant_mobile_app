import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/models/cart_model.dart';
import 'package:restaurant_pos_mobile/view_models/cart_view_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

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
  String? generatedComId;

  @override
  void initState() {
    super.initState();
    fetchTables();
    loadNote();
    calculateTotalPrice();

    if (widget.cartItems.isNotEmpty && widget.cartItems.last.comId.isNotEmpty) {
      generateOrderNo(widget.comId);
    } else {
      print("Error: comId is missing.");
    }
  }

  Future<void> fetchTables() async {
    final response = await http.post(
      Uri.parse('https://mobileapp.synnexcloudpos.com'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'table_id': '1'},
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
    print('Generating order number...');

    if (comId == null || comId.isEmpty) {
      print('Error: comId is missing or empty');
      throw Exception('Empty or invalid com_id received');
    }

    final response = await http.post(
      Uri.parse('https://mobileapp.synnexcloudpos.com'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'com_id': comId},
    );

    print('HTTP response status: ${response.statusCode}');
    print('HTTP response body: ${response.body}');

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw Exception('Empty response body');
      }

      final List<dynamic> dataList = json.decode(response.body);
      if (dataList.isNotEmpty) {
        final Map<String, dynamic> data = dataList.first;
        final latestCode = data['code'];
        final gen = data['gen'];
        final orderPref = data['order_pref'];
        print('Latest code: $latestCode');
        print('gen value: $gen');
        print('Order prefix: $orderPref');

        if (latestCode != null) {
          // Increment the latest code to generate the next order number
          int nextCode = int.parse(latestCode);
          String nextOrderNo = orderPref +
              widget.userId +
              nextCode.toString().padLeft(int.parse(gen), '0');

          setState(() {
            orderNo = nextOrderNo;
            generatedComId = comId;
          });

          print('Next order number generated: $orderNo');
        } else {
          print('Received empty or invalid code');
          throw Exception('Empty or invalid code received');
        }
      } else {
        print('Received empty list');
        throw Exception('Empty list received');
      }
    } else {
      print('Failed to fetch com_id: ${response.statusCode}');
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
    final comId = generatedComId ?? widget.comId;
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
      'status': 1,
      'order_note': allNotes,
      'o_type': 1,
      'customer': '1',
      'cancel_reason': 'vdvcd',
      'canceled_by': 0,
    };

    print('Order data to send: $orderData');

    try {
      final response = await http.post(
        Uri.parse('https://mobileapp.synnexcloudpos.com'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(orderData),
      );

      print('Order response status: ${response.statusCode}');
      print('Order response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Server Response: $result');

        if (result['status'] == 'success') {
          final oId = result['o_id'];
          print('oId from server: $oId');

          List<Map<String, dynamic>> itemsData = widget.cartItems
              .map((items) => {
                    'item_id': items.productId,
                    'item': items.name,
                    'quantity': items.quantity.toString(),
                    'price': items.price,
                    'note': items.note,
                    'total_before_discount': items.price * items.quantity,
                    'discout': 0.00,
                    'total': items.price * items.quantity,
                    'kot_type': items.kotType,
                    'o_id': oId,
                    'com_id': comId, // Ensure comId is passed here
                  })
              .toList();

          print('Sending items data: $itemsData');
          final itemResponse = await http.post(
            Uri.parse('https://mobileapp.synnexcloudpos.com/addorder.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(itemsData),
          );

          print('Items response status: ${itemResponse.statusCode}');
          print('Items response body: ${itemResponse.body}');

          if (itemResponse.statusCode == 200) {
            print('Successfully inserted items');

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'])),
            );
            setState(() {
              widget.cartItems.clear();
              noteText = '';
            });
            saveNote();
            Navigator.pop(context);
          } else {
            print(
                'Failed to insert items: Status: ${itemResponse.statusCode} - Body: ${itemResponse.body}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to insert items.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit order')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting order')),
      );
    }
  }

  void calculateTotalPrice() {
    totalPrice = widget.cartItems
        .fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(240, 225, 218, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 71, 4, 4),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Shopping Cart',
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
                    key: Key('${item.name}_${item.tableNo}'),
                    onDismissed: (direction) {
                      setState(() {
                        widget.cartItems.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Item Deleted Successfully")),
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
                              '${item.name}\nTable No - ${item.tableNo} \nVariation - ${item.variation}\nQuantity - ${item.quantity}\nAdd Ons - ${item.addOns}\nNote - ${item.note}\nTotal Price - Rs. ${item.price.toStringAsFixed(2) * item.quantity}',
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
            Text('Total: Rs.${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color.fromARGB(255, 71, 4, 4), // Text color
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
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
                cart.toMenu(context);
              },
              child: Text('Add More'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color.fromARGB(255, 71, 4, 4), // Text color
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
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
              onPressed: widget.cartItems.isNotEmpty
                  ? () {
                      submitOrder();
                    }
                  : null,
              child: Text('Place Order'),
            ),
            SizedBox(height: 18),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: submitOrder,
        backgroundColor: const Color.fromARGB(255, 71, 4, 4),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        child: const Icon(Icons.check),
      ),
    );
  }
}
