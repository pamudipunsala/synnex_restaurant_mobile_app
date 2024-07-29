import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restaurant_pos_mobile/view_models/dashboard_view_model.dart';

class DashboardPage extends StatefulWidget {
  final String comId;
  final String userId;

  const DashboardPage({super.key, required this.comId, required this.userId});

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
        backgroundColor: const Color.fromARGB(255, 71, 4, 4),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/img8.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: Colors.black
                    .withOpacity(0), // This is a transparent color layer.
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: const Alignment(0.8, 0.6),
                child: Image.asset(
                  'assets/img1.png',
                  width: 50,
                  height: 50,
                ),
              ),
              Title(
                color: const Color.fromARGB(255, 71, 4, 4),
                child: Text(
                  'Edvana Anne',
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
                  backgroundColor: const Color.fromARGB(255, 71, 4, 4),
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  side: const BorderSide(color: Color.fromARGB(255, 71, 4, 4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Square corners
                  ),
                  fixedSize: const Size(200, 50),
                ),
                onPressed: () {
                  dashboard.toMenu(context, widget.comId, widget.userId);
                },
                child: const Text('Menu'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 71, 4, 4),
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  side: const BorderSide(color: Color.fromARGB(255, 71, 4, 4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Square corners
                  ),
                  fixedSize: const Size(200, 50),
                ),
                onPressed: () {
                  dashboard.toOrderHistory(context, widget.comId);
                },
                child: const Text('Order History'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 71, 4, 4),
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  side: const BorderSide(color: Color.fromARGB(255, 71, 4, 4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Square corners
                  ),
                  fixedSize: const Size(200, 50),
                ),
                onPressed: () {
                  dashboard.toProfile(context);
                },
                child: const Text('Profile'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 71, 4, 4),
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  side: const BorderSide(color: Color.fromARGB(255, 71, 4, 4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Square corners
                  ),
                  fixedSize: const Size(200, 50),
                ),
                onPressed: () {
                  dashboard.isLogout(context);
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 71, 4, 4),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        onPressed: () {
          dashboard.toTables(context, widget.comId, widget.userId);
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
