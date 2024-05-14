import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
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
        backgroundColor: const Color.fromARGB(255, 71, 4, 4),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: const Alignment(0.8, 0.6),
              child: IconButton(
                icon: const Icon(Icons.image, size: 5),
                onPressed: () {},
              ),
            ),
            Title(
              color: const Color.fromARGB(255, 71, 4, 4),
              child: Text(
                'Edvana Anne',
                textAlign: TextAlign.right,
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    color: Color.fromARGB(255, 71, 4, 4),
                    fontSize: 10, // Adjust the font size as needed
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Title(
              color: const Color.fromARGB(255, 71, 4, 4),
              child: Text(
                'Restaurant Pos Mobile',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    color: Color.fromARGB(255, 71, 4, 4),
                    fontSize: 30, // Adjust the font size as needed
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 173, 108, 71),
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                side: const BorderSide(color: Color.fromARGB(255, 71, 4, 4)),
                fixedSize: const Size(200, 50),
              ),
              onPressed: () {
                dashboard.toMenu(context);
              },
              child: const Text('Menu'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 173, 108, 71),
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                side: const BorderSide(color: Color.fromARGB(255, 71, 4, 4)),
                fixedSize: const Size(200, 50),
              ),
              onPressed: () {
                dashboard.toOrderHistory(context);
              },
              child: const Text('Order History'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 173, 108, 71),
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                side: const BorderSide(color: Color.fromARGB(255, 71, 4, 4)),
                fixedSize: const Size(200, 50),
              ),
              onPressed: () {
                dashboard.toProfile(context);
              },
              child: const Text('Profile'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 173, 108, 71),
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                side: const BorderSide(color: Color.fromARGB(255, 71, 4, 4)),
                fixedSize: const Size(200, 50),
              ),
              onPressed: () {
                dashboard.isLogout(context);
              },
              child: const Text('Logout'),
            ),
            const SizedBox(height: 120.0),
            Align(
              alignment: const Alignment(0.8, 0.6),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 71, 4, 4),
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  fixedSize: const Size(200, 80),
                ),
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
