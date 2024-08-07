import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:restaurant_pos_mobile/models/cart_model.dart';
import 'package:restaurant_pos_mobile/view/cart_screen.dart';
import 'package:restaurant_pos_mobile/view_models/menu_view_model.dart';

class MenuScreenPage extends StatefulWidget {
  final String userId;
  final int tableNo;
  final String comId;
  const MenuScreenPage(
      {super.key,
      required this.userId,
      required this.tableNo,
      required this.comId});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreenPage> {
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  List<dynamic> categories = [];
  MenuScreen menu = MenuScreen();
  String _selectedOption = 'Category';
  late int selectedRadioValue = -2;
  List<CartItem> cartItems = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCategories();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.post(
        Uri.parse('https://mobileapp.synnexcloudpos.com'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
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

  Future<void> fetchCategories() async {
    try {
      final response = await http.post(
        Uri.parse('https://mobileapp.synnexcloudpos.com'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'category_id': '1',
          'com_id': widget.comId,
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          categories = json.decode(response.body);
        });
        print('Categories fetched successfully: $categories');
      } else {
        print('Failed to load categories, status code: ${response.statusCode}');
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
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
      final response = await http.post(
        Uri.parse('https://mobileapp.synnexcloudpos.com'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'Variation_id': '1',
        },
      );

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
    String userId = widget.userId;
    String note = '';

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
                            final selectedProduct = products.firstWhere(
                                (product) =>
                                    int.parse(product['p_id']) == parentId,
                                orElse: () => {
                                      'name': 'Unknown',
                                      'com_id': '',
                                      'p_id': 0
                                    });

                            cartItems.add(CartItem(
                              name: selectedProduct['name'],
                              variation: variations.firstWhere(
                                  (variation) =>
                                      int.parse(variation['p_id']) ==
                                      selectedRadioInDialog,
                                  orElse: () => {'name': 'Unknown'})['name'],
                              quantity: 1,
                              addOns: isChecked ? 'Add Ones 1' : '',
                              price: totalPrice,
                              note: menu.noteController.text,
                              tableNo: tableNo,
                              finalNote: note,
                              comId: selectedProduct['com_id'], // Pass com_id
                              productId: int.parse(selectedProduct['p_id']),
                              kotType: products.firstWhere(
                                  (product) =>
                                      int.parse(product['p_id']) == parentId,
                                  orElse: () => {'kot_type': 0})['kot_type'],
                              productName: null,
                              userId: userId, oId: 1, vat: '',
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
      backgroundColor: const Color.fromARGB(240, 225, 218, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 71, 4, 4),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Menu',
              style: GoogleFonts.archivo(
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFDAB3AC),
              Color(0xFFF0E1DA),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
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
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedOption = newValue!;
                    if (_selectedOption == 'Category') {
                      filteredProducts = List.from(products);
                    } else {
                      filteredProducts = products
                          .where((product) =>
                              product['category'] == _selectedOption)
                          .toList();
                    }
                  });
                },
                items: [
                  const DropdownMenuItem<String>(
                    value: 'Category',
                    child: Text('Category'),
                  ),
                  ...categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['name'].toString(),
                      child: Text(category['name'].toString()),
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: GridView.builder(
                  itemCount: filteredProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.35,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final product = filteredProducts[index];
                    final imageUrl = '${product['image_path']}';

                    return GestureDetector(
                      onTap: () {
                        showVariationsDialog(
                            context, int.parse(product['p_id']));
                      },
                      child: Container(
                        margin: const EdgeInsets.all(10.0),
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
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
                            Image.asset(
                              imageUrl,
                              height: 70,
                              width: 70,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${product['name']}\nRs.${product['regular_price']}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 10,
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartScreenPage(
                cartItems: cartItems,
                tableNo: widget.tableNo,
                comId: widget.comId, // Pass comId
                userId: widget.userId,
              ),
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 71, 4, 4),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}
