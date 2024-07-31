import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:restaurant_pos_mobile/models/order_history_model.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<HistoryItem>> _orderHistory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _orderHistory = Future.value([]); // Initialize with an empty list
    fetchOrderHistory().then((history) {
      setState(() {
        _orderHistory = Future.value(history);
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<HistoryItem>> fetchOrderHistory() async {
    final response = await http.post(
      Uri.parse('https://mobileapp.synnexcloudpos.com'),
      body: {'history_id': '1'},
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse
            .map<HistoryItem>((order) => HistoryItem.fromJson(order))
            .toList();
      } catch (e) {
        throw Exception('Failed to parse order history data: $e');
      }
    } else {
      throw Exception(
          'Failed to load order history, status code: ${response.statusCode}');
    }
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
          bottom: TabBar(
            controller: _tabController,
            labelColor: const Color.fromARGB(255, 255, 255, 255),
            unselectedLabelColor:
                const Color.fromARGB(255, 255, 255, 255).withOpacity(0.6),
            indicatorColor: const Color.fromARGB(255, 255, 255, 255),
            tabs: const [
              Tab(text: 'Pendings'),
              Tab(text: 'Ready'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _PendingList(orderHistory: _orderHistory),
            _ReadyList(orderHistory: _orderHistory),
          ],
        ),
      ),
    );
  }
}

class _PendingList extends StatelessWidget {
  final Future<List<HistoryItem>> orderHistory;

  _PendingList({Key? key, required this.orderHistory}) : super(key: key);

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
              onChanged: (value) {
                // Implement search logic
              },
            ),
          ),
          const Text('4 Pendings      2 Ready'),
          Expanded(
            child: FutureBuilder<List<HistoryItem>>(
              future: orderHistory,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No pending orders found.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      HistoryItem history = snapshot.data![index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            'Order No: ${history.orderId}\nItem: ${history.item}\nQuantity: ${history.quantity}\nPrice: ${history.price}\nTotal: ${history.total}\nNote: ${history.note}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // Implement edit logic
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  // Implement delete logic
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadyList extends StatelessWidget {
  final Future<List<HistoryItem>> orderHistory;

  _ReadyList({Key? key, required this.orderHistory}) : super(key: key);

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
              onChanged: (value) {
                // Implement search logic
              },
            ),
          ),
          const Text('4 Pendings      2 Ready'),
          Expanded(
            child: FutureBuilder<List<HistoryItem>>(
              future: orderHistory,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No ready orders found.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      HistoryItem history = snapshot.data![index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            'Order No: ${history.orderId}\nItem: ${history.item}\nQuantity: ${history.quantity}\nPrice: ${history.price}\nTotal: ${history.total}\nNote: ${history.note}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // Implement edit logic
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  // Implement delete logic
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
