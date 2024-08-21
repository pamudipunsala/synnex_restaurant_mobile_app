import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/view/comment_screen.dart';
import 'package:restaurant_pos_mobile/view/dashboard_screen.dart';
import 'package:restaurant_pos_mobile/view/order_history.dart';

class CartScreen {
  final TextEditingController searchController = TextEditingController();
  CommentScreenPage menuScreen = CommentScreenPage();

  void toNote(BuildContext context) {
    menuScreen.toNote(context);
  }

  void toMenu(BuildContext context) {
    Navigator.of(context).pop();
  }

  void toDashboard(BuildContext context, String comId, String userId) {
    Navigator.push(context,
        MaterialPageRoute(builder: ((context) => DashboardPage(comId: comId, userId: userId))));
  }

  void toOrderHistory(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: ((context) => const OrderHistoryPage())));
  }
}
