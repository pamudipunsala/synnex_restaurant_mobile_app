import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/view_models/dashboard_view_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardScreen dashboard = DashboardScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color.fromARGB(255, 19, 139, 4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Image.asset('assets/img1.png'),
              iconSize: 20,
              onPressed: () {},
            ),
            const Text('Edvana Anne'),
            Title(
                color: const Color.fromARGB(255, 19, 139, 4),
                child: const Text('Restaurant POS Mobile')),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                //logic
                dashboard.toMenu(context);
              },
              child: const Text('Menu'),
            ),
            ElevatedButton(
              onPressed: () {
                //logic
                dashboard.toOrderHistory(context);
              },
              child: const Text('Order History'),
            ),
            ElevatedButton(
              onPressed: () {
                //logic
                dashboard.toProfile(context);
              },
              child: const Text('Profile'),
            ),
            ElevatedButton(
              onPressed: () {
                //logic
                dashboard.isLogout(context);
              },
              child: const Text('Logout'),
            ),
            ElevatedButton(
              onPressed: () {
                //logic
                dashboard.toMenu(context);
              },
              child: const Text('Add Sales'),
            )
          ],
        ),
      ),
    );
  }
}
