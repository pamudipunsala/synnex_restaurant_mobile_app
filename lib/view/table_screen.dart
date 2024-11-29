import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:restaurant_pos_mobile/view/menu_screen.dart';
import 'package:restaurant_pos_mobile/view_models/table_view_model.dart';

class TableScreenPage extends StatefulWidget {
  final String comId;
  final String userId;
  const TableScreenPage({super.key, required this.comId, required this.userId});

  @override
  _TableScreenState createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreenPage>
    with WidgetsBindingObserver {
  List<dynamic> tables = [];
  List<dynamic> filteredTables = [];
  TableScreen tableScreen = TableScreen();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchTables();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    fetchTables();
  }

  Future<void> fetchTables() async {
    final response = await http.post(
      Uri.parse('https://mobileapp.synnexcloudpos.com'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'table_id': '1',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        tables = json.decode(response.body);
        filteredTables = List.from(tables);
      });
    } else {
      throw Exception('Failed to load tables');
    }
  }

  void searchTables(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTables = List.from(tables);
      } else {
        filteredTables = tables
            .where((table) => table['tabel_no']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 71, 4, 4),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Text(
          'Tables',
          style: GoogleFonts.bacasimeAntique(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading:
            Platform.isIOS ? const CupertinoNavigationBarBackButton() : null,
      ),
      body: Container(
        color: Color.fromARGB(255, 235, 226, 225),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Platform.isIOS
                  ? CupertinoSearchTextField(
                      onChanged: searchTables,
                      placeholder: 'Search...',
                      prefixIcon: const Icon(CupertinoIcons.search,
                          color: Color.fromARGB(255, 71, 4, 4)),
                    )
                  : TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        hintStyle:
                            TextStyle(color: Color.fromARGB(255, 71, 4, 4)),
                        fillColor: Color.fromARGB(255, 255, 255, 255),
                      ),
                      style:
                          const TextStyle(color: Color.fromARGB(255, 71, 4, 4)),
                      onChanged: searchTables,
                    ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: filteredTables.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 500 ? 3 : 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio:
                      MediaQuery.of(context).size.width > 800 ? 1 : 1.2,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final table = filteredTables[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuScreenPage(
                            tableNo: table['tabel_no'] is String
                                ? int.parse(table['tabel_no'])
                                : table['tabel_no'],
                            comId: widget.comId,
                            userId: widget.userId,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 250, 236, 234),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color.fromARGB(
                              255, 202, 158, 150), // Border color
                          width: 5, // Border width (adjust as needed)
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Table No: ${table['tabel_no']}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 20,
                                color: Color.fromARGB(255, 71, 4, 4)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
