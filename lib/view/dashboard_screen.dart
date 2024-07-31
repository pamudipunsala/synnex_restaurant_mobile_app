import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restaurant_pos_mobile/view_models/dashboard_view_model.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class DashboardPage extends StatefulWidget {
  final String comId;
  final String userId;

  const DashboardPage({super.key, required this.comId, required this.userId});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardScreen dashboard = DashboardScreen();
  bool _isAnimationFinished = false;

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
              'Dashboard',
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
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: Image.asset(
        //       'assets/img1.png',
        //       width: 50,
        //       height: 50,
        //     ),
        //   ),
        // ],
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isAnimationFinished)
                AnimatedTextKit(
                  animatedTexts: [
                    FadeAnimatedText(
                      'Restaurant Pos Mobile',
                      textAlign: TextAlign.center,
                      textStyle: GoogleFonts.archivo(
                        textStyle: const TextStyle(
                          color: Color.fromARGB(255, 71, 4, 4),
                          fontSize: 30, // Adjust the font size as needed
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      duration: const Duration(milliseconds: 4000),
                    ),
                  ],
                  isRepeatingAnimation: false,
                  onFinished: () {
                    setState(() {
                      _isAnimationFinished = true;
                    });
                  },
                )
              else
                Text(
                  'Restaurant Pos Mobile',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.archivo(
                    textStyle: const TextStyle(
                      color: Color.fromARGB(255, 71, 4, 4),
                      fontSize: 30, // Adjust the font size as needed
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 60.0),
              _build3DButton('Menu', () {
                dashboard.toMenu(context, widget.comId, widget.userId);
              }),
              const SizedBox(height: 16),
              _build3DButton('Order History', () {
                dashboard.toOrderHistory(context, widget.comId);
              }),
              const SizedBox(height: 16),
              _build3DButton('Profile', () {
                dashboard.toProfile(context);
              }),
              const SizedBox(height: 16),
              _build3DButton('Logout', () {
                dashboard.isLogout(context);
              }),
              const SizedBox(height: 80.0),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        width: 70, // Adjust the width as needed
        height: 70,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF470404),
              Color(0xFFDAB3AC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          onPressed: () {
            dashboard.toTables(context, widget.comId, widget.userId);
          },
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }

  // Function to build 3D button
  Widget _build3DButton(String text, VoidCallback onPressed) {
    return Material(
      elevation: 8, // Shadow depth
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF470404),
              Color(0xFFDAB3AC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.black.withOpacity(1),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Square corners
            ),
            fixedSize: const Size(220, 80),
          ).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (states) => Colors.transparent,
            ),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ),
    );
  }
}
