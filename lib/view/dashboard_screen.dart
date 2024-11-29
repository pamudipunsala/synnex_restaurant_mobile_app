import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
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
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(240, 225, 218, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 71, 4, 4),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Text(
          'Dashboard',
          style: GoogleFonts.bacasimeAntique(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img9.png'), // Background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Blur effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          // Foreground content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isAnimationFinished)
                  AnimatedTextKit(
                    animatedTexts: [
                      FadeAnimatedText(
                        'Restaurant POS Mobile',
                        textAlign: TextAlign.center,
                        textStyle: GoogleFonts.babylonica(
                          textStyle: TextStyle(
                            color: const Color.fromARGB(255, 71, 4, 4),
                            fontSize: screenWidth * 0.1,
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
                    'Restaurant POS Mobile',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.babylonica(
                      textStyle: TextStyle(
                        color: const Color.fromARGB(255, 71, 4, 4),
                        fontSize: screenWidth * 0.1, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                SizedBox(height: screenHeight * 0.07), 
                _build3DButton('Menu', screenWidth, screenHeight, () {
                  dashboard.toMenu(context, widget.comId, widget.userId);
                }),
                SizedBox(height: screenHeight * 0.02),
                _build3DButton('Order History', screenWidth, screenHeight, () {
                  dashboard.toOrderHistory(context, widget.comId);
                }),
                SizedBox(height: screenHeight * 0.02),
                _build3DButton('Profile', screenWidth, screenHeight, () {
                  dashboard.toProfile(context);
                }),
                SizedBox(height: screenHeight * 0.02),
                _build3DButton('Logout', screenWidth, screenHeight, () {
                  dashboard.isLogout(context);
                }),
                SizedBox(height: screenHeight * 0.1),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Platform.isAndroid
          ? Container(
              width: screenWidth * 0.15, // Responsive width
              height: screenWidth * 0.15, // Responsive height
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF470404),
                    Color.fromRGBO(218, 179, 172, 1),
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
                child: const Icon(Icons.add, size: 32), // Consistent icon size
              ),
            )
          : CupertinoButton(
              color: const Color.fromARGB(255, 71, 4, 4),
              onPressed: () {
                dashboard.toTables(context, widget.comId, widget.userId);
              },
              child: Icon(CupertinoIcons.add, size: 32),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }

  // Function to build 3D button
  Widget _build3DButton(String text, double screenWidth, double screenHeight,
      VoidCallback onPressed) {
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
              borderRadius: BorderRadius.circular(10),
            ),
            fixedSize: Size(screenWidth * 0.6,
                screenHeight * 0.1), // Responsive button size
          ).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (states) => Colors.transparent,
            ),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.045, // Responsive font size
            ),
          ),
        ),
      ),
    );
  }
}
