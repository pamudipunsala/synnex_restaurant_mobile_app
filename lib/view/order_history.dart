import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/view_models/order_history_view_model.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistoryPage>
    with SingleTickerProviderStateMixin {
  OrderHistoryScreen orderhistory = OrderHistoryScreen();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order History'),
          backgroundColor: const Color.fromARGB(255, 71, 4, 4),
          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          bottom: TabBar(
            controller: _tabController,
            labelColor: const Color.fromARGB(
                255, 255, 255, 255), // Active tab text color
            unselectedLabelColor: const Color.fromARGB(255, 255, 255, 255)
                .withOpacity(0.6), 
            indicatorColor:
                const Color.fromARGB(255, 255, 255, 255), 
            tabs: const [
              Tab(text: 'Pendings'),
              Tab(text: 'Ready'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Pending List

            _PendingList(), // Remove const here
            // Ready List
            _ReadyList(), // Remove const here
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class _PendingList extends StatelessWidget {
  _PendingList({Key? key}) : super(key: key);
  OrderHistoryScreen orderhistory = OrderHistoryScreen();

  @override
  Widget build(BuildContext context) {
    return Column(
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
          child: ListView.builder(
            itemCount: 4,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: const Text(
                    'Fried Rice\nVariation - Chicken\nQuantity - 2\nAdd Ones - cheese Source\nTotal Price - Rs. 1600',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          orderhistory.toEditScreen(context);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // Delete logic
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ReadyList extends StatelessWidget {
  const _ReadyList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
          child: ListView.builder(
            itemCount: 4,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: const Text(
                    'String Hoppers\nVariation - red  - 2\nAdd Ones - fish curry\nTotal Price - Rs. 400.00',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Edit logic
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // Delete logic
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
