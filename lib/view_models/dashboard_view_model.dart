import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/view/dashboard_screen.dart';
import 'package:restaurant_pos_mobile/view/menu_screen.dart';
import 'package:restaurant_pos_mobile/view/order_history.dart';
import 'package:restaurant_pos_mobile/view/profile_screen.dart';

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

  void isLogout(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: ((context) => const DashboardPage())));
  }
}
