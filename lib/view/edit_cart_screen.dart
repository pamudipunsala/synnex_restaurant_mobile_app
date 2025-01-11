import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/constants.dart';
import 'package:restaurant_pos_mobile/models/cart_model.dart';
import 'package:restaurant_pos_mobile/view_models/cart_view_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class EditCartScreenPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final String userId;
  final String waiterId;
  final int tableNo;
  final String comId;
  final String orderNo;
  final int orderId;
  final double totalPrice;

  const EditCartScreenPage({
    Key? key,
    required this.cartItems,
    required this.tableNo,
    required this.comId,
    required this.userId,
    required this.waiterId,
    required this.orderNo,
    required this.orderId,
    required this.totalPrice,
  }) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<EditCartScreenPage> {
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
  final String url = '$apiDomain$addOrderEndpoint';
  final String url2 = '$apiDomain$editOrderEndpoint';
  bool isSubmitting = false;
  bool isOrderNumberGenerated = true;

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
      Uri.parse(apiDomain),
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
      Uri.parse(apiDomain),
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
          int nextCode =
              latestCode is int ? latestCode + 1 : int.parse(latestCode) + 1;
          String nextOrderNo = orderPref +
              widget.userId +
              nextCode
                  .toString()
                  .padLeft(gen is int ? gen : int.parse(gen), '0');

          setState(() {
            orderNo = nextOrderNo;
            generatedComId = comId;
            isOrderNumberGenerated = false;
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
    final userId = widget.userId;
    final waiterId = widget.waiterId;
    final int orderId = widget.orderId;
    final currentDate = DateTime.now();
    final formattedDateTime =
        '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')} ${currentDate.hour.toString().padLeft(2, '0')}:${currentDate.minute.toString().padLeft(2, '0')}:${currentDate.second.toString().padLeft(2, '0')}';
    final allNotes = widget.cartItems.map((item) => item.note).join(', ');

    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    final orderData = {
      'o_no': widget.orderNo,
      'tabel_no': widget.tableNo.toString(),
      'com_id': comId,
      'total_payable': totalPrice + (totalPrice * 0.05),
      'created_date': formattedDateTime,
      'total_before_discount': totalPrice,
      'service_charge': totalPrice * 0.05,
      'order_note': allNotes,
    };

    print('Order data to send: $orderData');

    try {
      // final endpoint = orderNo.isNotEmpty ? url2 : apiDomain;
      final response = await http.post(
        Uri.parse(url2),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(orderData),
      );

      print('Order response status: ${response.statusCode}');
      print('Order response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Server Response: $result');

        // Now send the items
        List<Map<String, dynamic>> itemsData = widget.cartItems.map((items) {
          return {
            'item_id': items.productId.toString(),
            'item': items.name,
            'quantity': items.quantity.toString(),
            'price': items.price.toString(),
            'note': items.note,
            'total_before_discount': (items.price * items.quantity).toString(),
            'discout': '0.00',
            'total': (items.price * items.quantity).toString(),
            'kot_type': items.kotType,
            'o_id': orderId,
            'com_id': comId.toString(),
          };
        }).toList();

        print('Sending items data: $itemsData');

        final itemResponse = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(itemsData),
        );

        if (itemResponse.statusCode == 200) {
          print('Successfully inserted items');
          cart.toDashboard(context, comId, userId, waiterId);
        } else {
          print('Failed to insert items: ${itemResponse.body}');
          throw Exception('Items submission failed');
        }
      } else {
        throw Exception('Order submission failed: ${response.body}');
      }
    } catch (error) {
      print('Error while submitting order: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  void calculateTotalPrice() {
    double initialTotal = widget.totalPrice;

    double cartItemsTotal = widget.cartItems.fold(0.0, (sum, item) {
      return sum + (item.price * item.quantity);
    });

    setState(() {
      totalPrice = initialTotal + cartItemsTotal;
    });

    print("Total price calculated: $totalPrice");
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: Platform.isIOS
          ? AppBar(
              backgroundColor: const Color.fromARGB(255, 71, 4, 4),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Shopping Cart',
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
            )
          : AppBar(
              backgroundColor: const Color.fromARGB(255, 71, 4, 4),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Shopping Cart',
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
            Text(
              'Order no : ${widget.orderNo.isNotEmpty ? widget.orderNo : orderNo.isNotEmpty ? orderNo : orderNo}',
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
                        const SnackBar(
                            content: Text("Item Deleted Successfully")),
                      );
                    },
                    background: Container(
                        color: const Color.fromARGB(255, 170, 131, 128)),
                    child: Card(
                      elevation: Platform.isIOS ? 4.0 : 2.0,
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
                              '${item.name}\nTable No - ${item.tableNo}\nVariation - ${item.variation}\nQuantity - ${item.quantity}\nNote - ${item.note}\nTotal Price - Rs. ${(item.price * item.quantity).toStringAsFixed(2)}',
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
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
                                  icon: const Icon(Icons.add),
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
                padding: const EdgeInsets.all(16.0),
                color: Colors.grey[200],
                child: Text(
                  'Note: $noteText',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            Text('Total: Rs.${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Platform.isIOS
                  ? Container(
                      width: screenWidth * 0.45,
                      height: screenHeight * 0.06,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                            255, 71, 4, 4), // Custom button color
                        borderRadius:
                            BorderRadius.circular(12.0), // Rounded corners
                      ),
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 24.0),
                        onPressed: () {
                          cart.toMenu(context);
                        },
                        child: const Text(
                          'Add More',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      width: screenWidth * 0.45,
                      height: screenHeight * 0.06,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              const Color.fromARGB(255, 71, 4, 4), // Text color
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 24.0),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12.0), // Rounded corners
                          ),
                          elevation: 8, // Shadow effect
                          textStyle: GoogleFonts.archivo(
                            textStyle: const TextStyle(
                              fontSize: 11, // Adjust font size
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onPressed: () {
                          cart.toMenu(context);
                        },
                        child: const Text('Add More'),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Platform.isIOS
                  ? Container(
                      width: screenWidth * 0.45,
                      height: screenHeight * 0.06,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ElevatedButton(
                        onPressed: widget.cartItems.isEmpty ||
                                isSubmitting ||
                                isOrderNumberGenerated
                            ? null
                            : () {
                                submitOrder();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              widget.cartItems.isEmpty || isSubmitting
                                  ? Colors.grey // Disabled button color
                                  : const Color.fromARGB(
                                      255, 71, 4, 4), // Enabled button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Place Order',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      width: screenWidth * 0.45,
                      height: screenHeight * 0.06,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color.fromARGB(255, 71, 4, 4),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 24.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 8,
                        ),
                        onPressed: widget.cartItems.isEmpty || isSubmitting
                            ? null
                            : () {
                                submitOrder();
                              },
                        child: const Text('Place Order'),
                      ),
                    ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
