import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/view_models/dashboard_view_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: const Alignment(0.8, 0.6),
              child: IconButton(
                icon: Icon(Icons.image, size: 5),
                onPressed: () {},
              ),
            ),
            const Text('Edvana Anne'),
            Title(
              color: const Color.fromARGB(255, 19, 139, 4),
              child: const Text('Restaurant POS Mobile'),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                dashboard.toMenu(context);
              },
              child: const Text('Menu'),
            ),
            ElevatedButton(
              onPressed: () {
                dashboard.toOrderHistory(context);
              },
              child: const Text('Order History'),
            ),
            ElevatedButton(
              onPressed: () {
                dashboard.toProfile(context);
              },
              child: const Text('Profile'),
            ),
            ElevatedButton(
              onPressed: () {
                dashboard.isLogout(context);
              },
              child: const Text('Logout'),
            ),
            Align(
              alignment: const Alignment(0.8, 0.6),
              child: ElevatedButton(
                onPressed: () {
                  dashboard.toMenu(context);
                },
                child: const Text('Add Sales'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
