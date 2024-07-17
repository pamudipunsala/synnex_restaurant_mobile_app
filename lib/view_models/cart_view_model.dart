import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/view/comment_screen.dart';
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

  void toOrderHistory(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: ((context) => const OrderHistoryPage())));
  }
}
