import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restaurant_pos_mobile/view_models/splash_view_model.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreenPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  SplashServices splashScreen = SplashServices();

  @override
  void initState() {
    super.initState();
    splashScreen.isLogin(context);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(240, 225, 218, 255),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              // rgb(240, 225, 218)
              Color(0xFFDAB3AC),
              Color(0xFFF0E1DA), // rgb(218, 179, 172)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Image.asset(
              'assets/CinnamonLogo.png', // Path to your image logo
              width: 400, // Adjust the width as needed
              height: 400, // Adjust the height as needed
              // You can add more animations here if needed
            ),
          ),
        ),
      ),
    );
  }
}
