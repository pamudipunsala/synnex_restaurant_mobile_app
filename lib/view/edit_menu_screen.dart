import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:restaurant_pos_mobile/constants.dart';
import 'package:restaurant_pos_mobile/models/cart_model.dart';
import 'package:restaurant_pos_mobile/view/cart_screen.dart';
import 'package:restaurant_pos_mobile/view/edit_cart_screen.dart';
import 'package:restaurant_pos_mobile/view_models/menu_view_model.dart';

class EditMenuScreenPage extends StatefulWidget {
  final String userId;
  final String waiterId;
  final int tableNo;
  final String comId;
  final String orderNo;
  final int orderId;
  final double totalPrice;

  const EditMenuScreenPage(
      {super.key,
      required this.userId,
      required this.tableNo,
      required this.comId,
      required this.waiterId,
      required this.orderNo,
      required this.orderId,
      required this.totalPrice});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<EditMenuScreenPage> {
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
        Uri.parse(apiDomain),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'menu_id': '1',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> allProducts = json.decode(response.body);
        setState(() {
          products = allProducts
              .where((product) => product['com_id'] == widget.comId)
              .toList();
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
        Uri.parse(apiDomain),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'category_id': '1',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        setState(() {
          categories = decodedResponse
              .where(
                  (category) => category['com_id'].toString() == widget.comId)
              .toList();
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
        Uri.parse(apiDomain),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'Variation_id': '296',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> allVariations = json.decode(response.body);
        List<dynamic> variationsWithGroupValue = allVariations
            .where((variation) =>
                int.parse(variation['parent_id'] ?? '0') == parentId)
            .map((variation) => {
                  ...variation,
                  'groupValue': variation['p_id'] ?? '0',
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
    double selectedRadioPrice = 0.00;
    double checkboxPrice = 200.00;
    double totalPrice = 0.00;
    int tableNo = widget.tableNo;
    String userId = widget.userId;
    String note = '';
    bool isVariationSelected = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<dynamic>>(
          future: fetchVariations(parentId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildPlatformSpecificAlertDialog(
                content: const Center(child: CircularProgressIndicator()),
                actions: [],
              );
            } else if (snapshot.hasError) {
              return _buildPlatformSpecificAlertDialog(
                content: Text('Error: ${snapshot.error}'),
                actions: [],
              );
            } else {
              var variations = snapshot.data!;

              return StatefulBuilder(
                builder: (context, setState) {
                  void updateTotalPrice() {
                    setState(() {
                      totalPrice = selectedRadioPrice +
                          (isChecked ? checkboxPrice : 0.00);
                    });
                  }

                  return _buildPlatformSpecificAlertDialog(
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          const Text(
                            'Select the Variant',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 71, 4, 4),
                              fontSize: 16,
                            ),
                          ),
                          Material(
                            color: Color.fromARGB(255, 250, 236, 234),
                            child: Column(
                              children: [
                                for (var variation in variations)
                                  RadioListTile(
                                    title: Text(
                                        '${variation['name'] ?? 'Unknown'}  Rs.${double.parse(variation['regular_price'] ?? '0.00').toStringAsFixed(2)}'),
                                    value: int.tryParse(
                                            variation['p_id'].toString()) ??
                                        0,
                                    groupValue: selectedRadioInDialog,
                                    onChanged: (val) {
                                      setState(() {
                                        selectedRadioInDialog = val as int;
                                        selectedRadioPrice = double.parse(
                                            variation['regular_price'] ??
                                                '0.00');
                                        updateTotalPrice();
                                        isVariationSelected = true;
                                      });
                                    },
                                  ),
                                // const Text(
                                //   'Add Ones',
                                //   style: TextStyle(
                                //       fontWeight: FontWeight.bold,
                                //       fontSize: 16,
                                //       color: Color.fromARGB(255, 71, 4, 4)),
                                // ),
                                // CheckboxListTile(
                                //   controlAffinity:
                                //       ListTileControlAffinity.leading,
                                //   title: const Text('Add Ones 1  Rs.200.00'),
                                //   value: isChecked,
                                //   onChanged: (bool? value) {
                                //     setState(() {
                                //       isChecked = value!;
                                //       updateTotalPrice();
                                //     });
                                //   },
                                // ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Total: Rs.${totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 71, 4, 4),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Material(
                            color: Colors.white,
                            child: TextField(
                              controller: menu.noteController,
                              decoration: const InputDecoration(
                                labelText: 'Add a note',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      _buildPlatformSpecificDialogButton(
                        label: 'Cancel',
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      _buildPlatformSpecificDialogButton(
                        label: 'OK',
                        onPressed: isVariationSelected
                            ? () {
                                setState(() {
                                  final selectedProduct = products.firstWhere(
                                    (product) => product['p_id'] == parentId,
                                    orElse: () => {
                                      'name': 'Unknown',
                                      'com_id': '',
                                      'p_id': 0
                                    },
                                  );

                                  final existingItemIndex =
                                      cartItems.indexWhere(
                                    (item) =>
                                        item.name == selectedProduct['name'] &&
                                        item.variation ==
                                            variations.firstWhere(
                                              (variation) =>
                                                  variation['p_id'] != null &&
                                                  int.tryParse(variation['p_id']
                                                              ?.toString() ??
                                                          '') ==
                                                      selectedRadioInDialog,
                                              orElse: () => {'name': 'Unknown'},
                                            )['name'],
                                  );

                                  if (existingItemIndex != -1) {
                                    cartItems[existingItemIndex] = CartItem(
                                      name: cartItems[existingItemIndex].name,
                                      variation: cartItems[existingItemIndex]
                                          .variation,
                                      quantity: cartItems[existingItemIndex]
                                              .quantity +
                                          1,
                                      addOns: isChecked ? 'Add Ones 1' : '',
                                      price: totalPrice,
                                      note: menu.noteController.text,
                                      tableNo: tableNo,
                                      finalNote: note,
                                      comId: selectedProduct['com_id'],
                                      productId: selectedProduct['p_id'],
                                      kotType: products
                                              .firstWhere(
                                                (product) =>
                                                    product['p_id'] != null &&
                                                    product['p_id']
                                                            .toString() ==
                                                        parentId.toString(),
                                                orElse: () => {'kot_type': 0},
                                              )['kot_type']
                                              ?.toString() ??
                                          '0',
                                      productName: null,
                                      userId: userId,
                                      oId: 1,
                                      vat: '',
                                    );
                                  } else {
                                    cartItems.add(CartItem(
                                      name: selectedProduct['name'],
                                      variation: variations.firstWhere(
                                        (variation) =>
                                            variation['p_id'] != null &&
                                            int.tryParse(variation['p_id']
                                                    .toString()) ==
                                                selectedRadioInDialog,
                                        orElse: () => {'name': 'Unknown'},
                                      )['name'],
                                      quantity: 1,
                                      addOns: isChecked ? 'Add Ones 1' : '',
                                      price: totalPrice,
                                      note: menu.noteController.text,
                                      tableNo: tableNo,
                                      finalNote: note,
                                      comId: selectedProduct['com_id'],
                                      productId: selectedProduct['p_id'],
                                      kotType: products
                                          .firstWhere(
                                            (product) =>
                                                product['p_id'] != null &&
                                                product['p_id'].toString() ==
                                                    parentId.toString(),
                                            orElse: () => {'kot_type': 0},
                                          )['kot_type']
                                          .toString(),
                                      productName: null,
                                      userId: userId,
                                      oId: 1,
                                      vat: '',
                                    ));
                                  }
                                });
                                Navigator.of(context).pop();
                              }
                            : null,
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

  Widget _buildPlatformSpecificAlertDialog({
    required Widget content,
    required List<Widget> actions,
  }) {
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        content: content,
        actions: actions,
      );
    } else {
      return AlertDialog(
        content: content,
        actions: actions,
      );
    }
  }

  Widget _buildPlatformSpecificDialogButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor:
                  isHovered ? Color(0xFFDAB3AC) : Colors.transparent,
              foregroundColor: Colors.black, // Change text color if needed
            ),
            onPressed: onPressed,
            child: Text(label),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildPlatformSpecificAppBar(),
      body: Container(
        color: Color.fromARGB(255, 235, 226, 225),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search, size: screenWidth * 0.06),
                    border: OutlineInputBorder(),
                    hintStyle: TextStyle(
                      color: const Color.fromARGB(255, 71, 4, 4),
                      fontSize: screenWidth * 0.04,
                    ),
                    fillColor: Color.fromARGB(255, 255, 255, 255),
                  ),
                  style: TextStyle(
                    color: const Color.fromARGB(255, 71, 4, 4),
                    fontSize: screenWidth * 0.04,
                  ),
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
                    child: Text('Select a Category'),
                  ),
                  ...categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['pc_id']
                          .toString(), // Ensure 'pc_id' is not null
                      child: Text(category['name']?.toString() ??
                          'Unnamed Category'), // Handle null values
                    );
                  }).toList()
                ],
                style: TextStyle(
                    color: const Color.fromARGB(255, 71, 4, 4),
                    fontSize: screenWidth * 0.04),
              ),
              SizedBox(height: screenHeight * 0.02),
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
                    final imageUrl = '$apiDomain/${product['image_path']}';

                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        showVariationsDialog(context, product['p_id']);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(10.0),
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 250, 236, 234),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color.fromARGB(255, 202, 158, 150),
                            width: 5.0,
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
                            Image.network(
                              imageUrl,
                              height: screenHeight * 0.07,
                              width: screenWidth * 0.2,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                    ),
                                  );
                                }
                              },
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                return Image.asset(
                                  'assets/NO-IMAGE.jpg',
                                  height: screenHeight * 0.07,
                                  width: screenWidth * 0.2,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              '${product['name']}\nRs.${double.parse(product['regular_price'] ?? '0.00').toStringAsFixed(2)}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: screenHeight * 0.01,
                                color: const Color.fromARGB(255, 71, 4, 4),
                              ),
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
              builder: (context) => EditCartScreenPage(
                  cartItems: cartItems,
                  tableNo: widget.tableNo,
                  comId: widget.comId,
                  userId: widget.userId,
                  waiterId: widget.waiterId,
                  orderNo: widget.orderNo,
                  orderId: widget.orderId,
                  totalPrice: widget.totalPrice),
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 71, 4, 4),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }

  PreferredSizeWidget _buildPlatformSpecificAppBar() {
    if (Platform.isIOS) {
      return CupertinoNavigationBar(
        middle: Text(
          'Menu',
          style: GoogleFonts.bacasimeAntique(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 71, 4, 4),
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );
    } else {
      return AppBar(
        backgroundColor: const Color.fromARGB(255, 71, 4, 4),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Text(
          'Menu',
          style: GoogleFonts.bacasimeAntique(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20, // Adjust the size based on screenWidth if needed
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );
    }
  }

  Widget _buildPlatformSpecificSearchField() {
    if (Platform.isIOS) {
      return CupertinoTextField(
        placeholder: 'Search...',
        prefix: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(CupertinoIcons.search, size: 20),
        ),
        onChanged: searchProducts,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color.fromARGB(255, 71, 4, 4)),
          borderRadius: BorderRadius.circular(5),
        ),
        style: const TextStyle(
          color: Color.fromARGB(255, 71, 4, 4),
          fontSize: 16,
        ),
      );
    } else {
      return TextField(
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: const Icon(Icons.search, size: 20),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromARGB(255, 71, 4, 4)),
            borderRadius: BorderRadius.circular(5),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: searchProducts,
      );
    }
  }
}
