import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/view/dashboard_screen.dart';

class LoginScreen {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void toDashboard(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: ((context) => const DashboardPage())));
  }
}
