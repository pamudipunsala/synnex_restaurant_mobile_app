import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/view/menu_screen.dart';

class TableScreen{
  void toMenu(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (context) => const MenuScreenPage()));
  }
}