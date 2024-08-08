import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:restaurant_pos_mobile/models/order_history_model.dart';
import 'package:restaurant_pos_mobile/view/edit_screen.dart';
import 'package:restaurant_pos_mobile/view/view_order_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<HistoryItem> _originalHistoryItems = [];
  List<HistoryItem> _filteredHistoryItems = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchOrderHistory(); // Fetch order history and set state
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
        List<HistoryItem> historyItems = jsonResponse
            .map<HistoryItem>((order) => HistoryItem.fromJson(order))
            .toList();
        setState(() {
          _originalHistoryItems = historyItems;
          _filteredHistoryItems = historyItems;
        });
      } catch (e) {
        throw Exception('Failed to parse order history data: $e');
      }
    } else {
      throw Exception(
          'Failed to load order history, status code: ${response.statusCode}');
    }
  }

  void _filterHistoryItems(String query) {
    setState(() {
      _searchQuery = query;
      if (_searchQuery.isEmpty) {
        _filteredHistoryItems = _originalHistoryItems;
      } else {
        _filteredHistoryItems = _originalHistoryItems
            .where((item) =>
                item.orderId.contains(_searchQuery) ||
                item.date.contains(_searchQuery))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 71, 4, 4),
          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Order History',
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
                            child: ListTile(
                              title: Text(
                                'Order No: ${history.orderNo}\nDate: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(history.date))}\nTable No: ${history.tabelNo}\nTotal: ${history.total_payable}',
                              ),
                              subtitle: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: const Color.fromARGB(
                                          255, 71, 4, 4), // Text color
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 20.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            12.0), // Rounded corners
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewScreenPage(
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
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: const Color.fromARGB(
                                          255, 71, 4, 4), // Text color
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 20.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            12.0), // Rounded corners
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditScreenPage(
                                            orderId: history.orderId,
                                            orderNo: history.orderNo,
                                            tabelNo: history.tabelNo,
                                            orderDetails: [],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text('Edit'),
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

class _PendingList extends StatelessWidget {
  final List<HistoryItem> orderHistory;
  final ValueChanged<String> onSearch;

  _PendingList({Key? key, required this.orderHistory, required this.onSearch})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: onSearch,
            ),
          ),
          // const Text('4 Pendings      2 Ready'),
          Expanded(
            child: orderHistory.isEmpty
                ? const Center(child: Text('No pending orders found.'))
                : ListView.builder(
                    itemCount: orderHistory.length,
                    itemBuilder: (context, index) {
                      HistoryItem history = orderHistory[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            'Order No: ${history.orderNo}\nDate: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(history.date))}\nTable No: ${history.tabelNo}\nTotal: ${history.total_payable}',
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color.fromARGB(
                                      255, 71, 4, 4), // Text color
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        12.0), // Rounded corners
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewScreenPage(
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
                              const SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color.fromARGB(
                                      255, 71, 4, 4), // Text color
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        12.0), // Rounded corners
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditScreenPage(
                                        orderId: history.orderId,
                                        orderNo: history.orderNo,
                                        tabelNo: history.tabelNo,
                                        orderDetails: [], // Pass any additional order details if needed
                                      ),
                                    ),
                                  );
                                },
                                child: Text('Edit'),
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
    );
  }
}

class _ReadyList extends StatelessWidget {
  final List<HistoryItem> orderHistory;
  final ValueChanged<String> onSearch;

  _ReadyList({Key? key, required this.orderHistory, required this.onSearch})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: onSearch,
            ),
          ),
          const Text('4 Pendings      2 Ready'),
          Expanded(
            child: orderHistory.isEmpty
                ? const Center(child: Text('No ready orders found.'))
                : ListView.builder(
                    itemCount: orderHistory.length,
                    itemBuilder: (context, index) {
                      HistoryItem history = orderHistory[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            'Order No: ${history.orderId}\nDate: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(history.date))}\nTable No: ${history.tabelNo}\nTotal: ${history.total_payable}',
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color.fromARGB(
                                      255, 71, 4, 4), // Text color
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 24.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        12.0), // Rounded corners
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditScreenPage(
                                        orderId: history.orderId,
                                        orderDetails: [],
                                        tabelNo: '',
                                        orderNo: history.orderId,
                                      ),
                                    ),
                                  );
                                },
                                child: Text('Edit'),
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
    );
  }
}
