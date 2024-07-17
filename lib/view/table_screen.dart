import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:restaurant_pos_mobile/view/menu_screen.dart';
import 'package:restaurant_pos_mobile/view_models/table_view_model.dart';

class TableScreenPage extends StatefulWidget {
  final String comId;
  final String userId;
  const TableScreenPage({super.key, required this.comId, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _TableScreenState createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreenPage> {
  List<dynamic> tables = [];
  List<dynamic> filteredTables = [];
  TableScreen tableScreen = TableScreen();

  @override
  void initState() {
    super.initState();
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
        title: const Text('Tables'),
        backgroundColor: const Color.fromARGB(255, 71, 4, 4),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  hintStyle: TextStyle(color: Color.fromARGB(255, 71, 4, 4)),
                  fillColor: Color.fromARGB(255, 255, 255, 255),
                ),
                style: const TextStyle(color: Color.fromARGB(255, 71, 4, 4)),
                onChanged: searchTables,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: GridView.builder(
                itemCount: filteredTables.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.5,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final table = filteredTables[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuScreenPage(
                            tableNo: int.parse(table['tabel_no']),
                            // userId: int.parse(table['user_id']),
                            comId: widget.comId,
                            userId: widget.userId,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
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
