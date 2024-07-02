import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:restaurant_pos_mobile/models/cart_model.dart';
import 'package:restaurant_pos_mobile/view/cart_screen.dart';
import 'package:restaurant_pos_mobile/view_models/menu_view_model.dart';

class MenuScreenPage extends StatefulWidget {
  final String userId;
  final int tableNo;
  const MenuScreenPage({Key? key, required this.userId, required this.tableNo})
      : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreenPage> {
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  MenuScreen menu = MenuScreen();
  String _selectedOption = 'Category';
  late int selectedRadioValue = -2;
  List<CartItem> cartItems = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.post(
        Uri.parse('https://mobileapp.synnexcloudpos.com'),
        body: {
          'menu_id': '1',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body);
          filteredProducts = List.from(products);
        });
        print('Products fetched successfully: $products');
      } else {
        print('Failed to load products, status code: ${response.statusCode}');
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  void searchProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredProducts = List.from(products);
      } else {
        filteredProducts = products
            .where((product) => product['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<List<dynamic>> fetchVariations(int parentId) async {
    try {
      final response =
          await http.get(Uri.parse('https://mobileapp.synnexcloudpos.com'));

      if (response.statusCode == 200) {
        List<dynamic> allVariations = json.decode(response.body);
        List<dynamic> variationsWithGroupValue = allVariations
            .where((variation) =>
                int.parse(variation['parent_id'] ?? '0') == parentId)
            .map((variation) => {
                  ...variation,
                  'groupValue': int.parse(variation['p_id'] ?? '0'),
                })
            .toList();

        return variationsWithGroupValue;
      } else {
        throw Exception('Failed to load variations');
      }
    } catch (e) {
      print('Error fetching variations: $e');
      return [];
    }
  }

  void showVariationsDialog(BuildContext context, int parentId) {
    bool isChecked = false;
    int? selectedRadioInDialog = -1;
    double selectedRadioPrice = 0.0;
    double checkboxPrice = 200.0;
    double totalPrice = 0.0;
    int tableNo = widget.tableNo;

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
                  void updateTotalPrice() {
                    setState(() {
                      totalPrice = selectedRadioPrice +
                          (isChecked ? checkboxPrice : 0.0);
                    });
                  }

                  return AlertDialog(
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          const Text(
                            'Select the Variant',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 71, 4, 4)),
                          ),
                          for (var variation in variations)
                            RadioListTile(
                              title: Text(
                                  '${variation['name'] ?? 'Unknown'}  Rs.${variation['regular_price'] ?? '0.00'}'),
                              value: int.parse(variation['p_id'] ?? '0'),
                              groupValue: selectedRadioInDialog,
                              onChanged: (val) {
                                setState(() {
                                  selectedRadioInDialog = val;
                                  selectedRadioPrice = double.parse(
                                      variation['regular_price'] ?? '0.00');
                                  updateTotalPrice();
                                });
                              },
                            ),
                          const Text(
                            'Add Ones',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text('Add Ones 1  Rs.200.00'),
                            value: isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                isChecked = value!;
                                updateTotalPrice();
                              });
                            },
                          ),
                          Text('Total: Rs.$totalPrice'),
                          const SizedBox(height: 20),
                          TextField(
                            controller: menu.noteController,
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
                          setState(() {
                            cartItems.add(CartItem(
                              name: products.firstWhere(
                                  (product) =>
                                      int.parse(product['p_id']) == parentId,
                                  orElse: () => {
                                        'name': 'Unknown',
                                      })['name'],
                              variation: variations.firstWhere(
                                  (variation) =>
                                      int.parse(variation['p_id']) ==
                                      selectedRadioInDialog,
                                  orElse: () => {
                                        'name': 'Unknown',
                                      })['name'],
                              quantity: 1,
                              addOns: isChecked ? 'Add Ones 1' : '',
                              price: totalPrice,
                              note: menu.noteController.text,
                              tableNo: tableNo,
                              finalNote: '',
                              comId: '',
                            ));
                          });
                          Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Menu'),
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
                  onChanged: searchProducts,
                ),
              ),
              DropdownButton<String>(
                value: _selectedOption,
                items: const [
                  DropdownMenuItem(
                    value: 'Category',
                    child: Text('Category'),
                  ),
                  DropdownMenuItem(
                    value: 'Breakfast',
                    child: Text('Breakfast'),
                  ),
                  DropdownMenuItem(
                    value: 'Lunch',
                    child: Text('Lunch'),
                  ),
                  DropdownMenuItem(
                    value: 'Dinner',
                    child: Text('Dinner'),
                  ),
                ],
                style: const TextStyle(color: Color.fromARGB(255, 71, 4, 4)),
                onChanged: (value) {
                  setState(() {
                    _selectedOption = value!;
                  });
                },
              ),
              const SizedBox(height: 8),
              for (var product in filteredProducts)
                GestureDetector(
                  onTap: () =>
                      showVariationsDialog(context, int.parse(product['p_id'])),
                  child: Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      leading: Image.asset(
                        product['image'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(product['name'] ?? 'Unknown',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 71, 4, 4))),
                      subtitle: Text('Rs.${product['regular_price'] ?? '0.00'}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 71, 4, 4))),
                      trailing: const Icon(Icons.arrow_forward),
                    ),
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CartScreenPage(
                      cartItems: cartItems, tableNo: widget.tableNo)),
            );
          },
          backgroundColor: const Color.fromARGB(255, 71, 4, 4),
          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          child: const Icon(Icons.shopping_cart),
        ));
  }
}
