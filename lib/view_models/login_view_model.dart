import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/view/dashboard_screen.dart';

class LoginScreen {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void toDashboard(BuildContext context, String comId, String userId) {
    Navigator.push(context,
        MaterialPageRoute(builder: ((context) => DashboardPage(comId: comId, userId: userId))));
  }
}
