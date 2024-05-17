import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:restaurant_pos_mobile/view/cart_screen.dart';

class MenuScreen {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  Future<List<dynamic>> fetchVariations(int parentId) async {
    final response = await http.get(Uri.parse('http://localhost/mobile_apps/fetch_variations_data.php'));

    if (response.statusCode == 200) {
      List<dynamic> allVariations = json.decode(response.body);
      // Filter variations based on parentId
      return allVariations.where((variation) => int.parse(variation['parent_id']) == parentId).toList();
    } else {
      throw Exception('Failed to load variations');
    }
  }

  void showVariationsDialog(BuildContext context, int parentId) {
    int? selectedRadio;
    bool isChecked = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<dynamic>>(
          future: fetchVariations(parentId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                content: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                content: Text('Error: ${snapshot.error}'),
              );
            } else {
              var variations = snapshot.data!;
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Title(
                            color: const Color.fromARGB(255, 71, 4, 4),
                            child: const Text(
                              'Select the Variant',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          for (var variation in variations)
                            RadioListTile<int>(
                              title: Text('${variation['name']}  Rs.${variation['regular_price']}'),
                              value: int.parse(variation['p_id']),
                              groupValue: selectedRadio,
                              onChanged: (value) {
                                setState(() {
                                  selectedRadio = value;
                                });
                              },
                            ),
                          Title(
                            color: Colors.black,
                            child: const Text(
                              'Add Ones',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text('Add Ones 1  Rs.200.00'),
                            value: isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                isChecked = value!;
                              });
                            },
                          ),
                          const Text('Total: 1800.00'),
                          const SizedBox(height: 20),
                          TextField(
                            controller: noteController,
                            decoration: const InputDecoration(
                              labelText: 'Add a note',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CartScreenPage()),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
        );
      },
    );
  }
}
