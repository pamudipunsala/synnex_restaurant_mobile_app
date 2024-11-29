import 'dart:convert';
import 'dart:io'; // Import for platform-specific checks
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Import for iOS-specific widgets
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:restaurant_pos_mobile/models/order_history_model.dart';
import 'package:restaurant_pos_mobile/view/edit_screen.dart';
import 'package:restaurant_pos_mobile/view/view_order_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatefulWidget {
  final String comId;
  const OrderHistoryPage({Key? key, required this.comId}) : super(key: key);

  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistoryPage>
    with SingleTickerProviderStateMixin {
  List<dynamic> products = [];
  late TabController _tabController;
  List<HistoryItem> _originalHistoryItems = [];
  List<HistoryItem> _filteredHistoryItems = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchOrderHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrderHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    final response = await http.post(
      Uri.parse('https://mobileapp.synnexcloudpos.com'),
      body: {'history_id': userId},
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        List<dynamic> jsonResponse = json.decode(response.body);
        print('Parsed JSON: $jsonResponse');
        List<HistoryItem> historyItems = jsonResponse
            .map<HistoryItem>((order) => HistoryItem.fromJson(order))
            .toList();

        setState(() {
          _originalHistoryItems = historyItems
              .where((item) => item.comId.toString() == widget.comId)
              .toList();
          _filteredHistoryItems = _originalHistoryItems;
        });
      } catch (e) {
        print('Error parsing JSON: $e');
        throw Exception('Failed to parse order history data: $e');
      }
    } else {
      throw Exception(
          'Failed to load order history, status code: ${response.statusCode}');
    }
  }

  void _filterHistoryItems(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredHistoryItems = _originalHistoryItems;
      } else {
        _filteredHistoryItems = _originalHistoryItems.where((item) {
          return item.orderNo.toLowerCase().contains(_searchQuery) ||
              item.date.toLowerCase().contains(_searchQuery) ||
              item.tabelNo.toString().contains(_searchQuery) ||
              item.totalPayable.toString().contains(_searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 71, 4, 4),
          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: Text(
            'Order History',
            style: GoogleFonts.bacasimeAntique(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        body: Container(
          color: Color.fromARGB(255, 235, 226, 225),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                  vertical: MediaQuery.of(context).size.height * 0.02,
                ),
                child: isIOS
                    ? CupertinoSearchTextField(
                        onChanged: _filterHistoryItems,
                      )
                    : TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: _filterHistoryItems,
                      ),
              ),
              Expanded(
                child: _filteredHistoryItems.isEmpty
                    ? const Center(child: Text('No orders found.'))
                    : ListView.builder(
                        itemCount: _filteredHistoryItems.length,
                        itemBuilder: (context, index) {
                          HistoryItem history = _filteredHistoryItems[index];
                          return Card(
                            color: Color.fromARGB(255, 250, 236, 234),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              side: const BorderSide(
                                color: Color.fromARGB(255, 202, 158, 150),
                                width: 5.0,
                              ),
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.05,
                              vertical:
                                  MediaQuery.of(context).size.height * 0.01,
                            ),
                            child: ListTile(
                              title: Text(
                                'Order No: ${history.orderNo}\nDate: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(history.date))}\nTable No: ${history.tabelNo}\nTotal: ${history.totalPayable.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04,
                                ),
                              ),
                              subtitle: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  isIOS
                                      ? CupertinoButton(
                                          color: const Color.fromARGB(
                                              255, 71, 4, 4),
                                          padding: EdgeInsets.symmetric(
                                            vertical: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.015,
                                            horizontal: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05,
                                          ),
                                          child: const Text('View'),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewScreenPage(
                                                  orderId: history.orderId,
                                                  tabelNo: history.tabelNo,
                                                  orderDetails: [],
                                                  orderNo: history.orderNo,
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 71, 4, 4),
                                            padding: EdgeInsets.symmetric(
                                              vertical: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.015,
                                              horizontal: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.05,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            textStyle: GoogleFonts.archivo(
                                              textStyle: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.045,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewScreenPage(
                                                  orderId: history.orderId,
                                                  tabelNo: history.tabelNo,
                                                  orderDetails: [],
                                                  orderNo: history.orderNo,
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text('View'),
                                        ),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.02),
                                  isIOS
                                      ? CupertinoButton(
                                          color: const Color.fromARGB(
                                              255, 71, 4, 4),
                                          padding: EdgeInsets.symmetric(
                                            vertical: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.015,
                                            horizontal: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05,
                                          ),
                                          child: const Text('Edit'),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditScreenPage(
                                                  orderId: history.orderId,
                                                  orderNo: history.orderNo,
                                                  tabelNo: history.tabelNo,
                                                  orderDetails: [],
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 71, 4, 4),
                                            padding: EdgeInsets.symmetric(
                                              vertical: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.015,
                                              horizontal: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.05,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            textStyle: GoogleFonts.archivo(
                                              textStyle: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.045,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditScreenPage(
                                                  orderId: history.orderId,
                                                  orderNo: history.orderNo,
                                                  tabelNo: history.tabelNo,
                                                  orderDetails: [],
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text('Edit'),
                                        ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
