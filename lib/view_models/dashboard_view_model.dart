import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/view/login_screen.dart';
import 'package:restaurant_pos_mobile/view/menu_screen.dart';
import 'package:restaurant_pos_mobile/view/order_history.dart';
import 'package:restaurant_pos_mobile/view/profile_screen.dart';
import 'package:restaurant_pos_mobile/view/table_screen.dart';

class DashboardScreen {
  void toMenu(
      BuildContext context, String comId, String userId, String waiterId) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: ((context) => MenuScreenPage(
                  tableNo: 0,
                  userId: userId,
                  comId: comId,
                  waiterId: waiterId,
                  orderNo: '',
                ))));
  }

  void toOrderHistory(BuildContext context, String comId) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: ((context) => OrderHistoryPage(
                  comId: comId,
                ))));
  }

  void toProfile(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: ((context) => const ProfileScreenPage())));
  }

  void toTables(
      BuildContext context, String comId, String userId, String waiterId) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: ((context) => TableScreenPage(
                  comId: comId,
                  userId: userId,
                  waiterId: waiterId,
                ))));
  }

  void isLogout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreenPage()),
      (route) => false,
    );
  }
}
