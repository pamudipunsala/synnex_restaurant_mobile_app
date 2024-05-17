import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/view/login_screen.dart';
import 'package:restaurant_pos_mobile/view/menu_screen.dart';
import 'package:restaurant_pos_mobile/view/order_history.dart';
import 'package:restaurant_pos_mobile/view/profile_screen.dart';
import 'package:restaurant_pos_mobile/view/table_screen.dart';

class DashboardScreen {
  void toMenu(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: ((context) => const MenuScreenPage())));
  }

  void toOrderHistory(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: ((context) => const OrderHistoryPage())));
  }

  void toProfile(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: ((context) => const ProfileScreenPage())));
  }
  void toTables(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: ((context) => const TableScreenPage())));
  }

  void isLogout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreenPage()),
      (route) => false,
    );
  }
}
