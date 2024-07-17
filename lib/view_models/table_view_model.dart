import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/view/menu_screen.dart';

class TableScreen {
  void toMenu(BuildContext context, String comId, String userId) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MenuScreenPage(
                  tableNo: 0,
                  userId: userId,
                  comId: comId,
                )));
  }
}
