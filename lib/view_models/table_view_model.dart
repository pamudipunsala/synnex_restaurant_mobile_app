import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/view/menu_screen.dart';

class TableScreen {
  void toMenu(BuildContext context, String comId) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MenuScreenPage(
                  tableNo: 0,
                  userId: '',
                  comId: comId,
                )));
  }
}
