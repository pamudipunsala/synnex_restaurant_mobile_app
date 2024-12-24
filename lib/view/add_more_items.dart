import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/constants.dart';
import 'package:restaurant_pos_mobile/models/cart_model.dart';
import 'package:restaurant_pos_mobile/view_models/cart_view_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class AddMoreItemsScreen extends StatefulWidget {
  final int tableNo;
  final String orderNo;
  final double total;

  const AddMoreItemsScreen({
    Key? key,
    required this.orderNo,
    required this.tableNo,
    required this.total,
  }) : super(key: key);

  @override
  _AddMoreItemsScreenState createState() => _AddMoreItemsScreenState();
}

class _AddMoreItemsScreenState extends State<AddMoreItemsScreen> {
  List<dynamic> tables = [];
  List<dynamic> filteredTables = [];
  CartScreen cart = CartScreen();
  String selectedOption = 'Table Status';
  String orderNo = '';
  String tableNo = '';
  final TextEditingController noteController = TextEditingController();
  String noteText = '';
  double totalPrice = 0.0;
  int? oId;
  String? generatedComId;
  final String url = '$apiDomain$addOrderEndpoint';
  bool isSubmitting = false;
  bool isOrderNumberGenerated = true;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: Platform.isIOS
          ? AppBar(
              backgroundColor: const Color.fromARGB(255, 71, 4, 4),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Add More Items',
                    style: GoogleFonts.bacasimeAntique(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : AppBar(
              backgroundColor: const Color.fromARGB(255, 71, 4, 4),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Add More Items',
                    style: GoogleFonts.bacasimeAntique(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      body: Container(
        color: Color.fromARGB(255, 235, 226, 225),
      ),
    );
  }
}
