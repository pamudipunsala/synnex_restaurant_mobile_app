import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/view/edit_menu_screen.dart';
import 'package:restaurant_pos_mobile/view/edit_screen.dart';
import 'package:restaurant_pos_mobile/view/menu_screen.dart';

class OrderHistoryScreen {
  final TextEditingController orderHistoryController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  void toMenu(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: ((context) => const EditMenuScreenPage(
                  tableNo: 0,
                  userId: '',
                  comId: '',
                  waiterId: '',
                  orderNo: '',
                  orderId: 0,
                  totalPrice: 0,
                ))));
  }

  void toEditScreen(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: ((context) => const EditScreenPage(
                  orderDetails: [],
                  orderId: 0,
                  tabelNo: 0,
                  orderNo: '',
                  comId: 0,
                  waiterId: '',
                ))));
  }
}
