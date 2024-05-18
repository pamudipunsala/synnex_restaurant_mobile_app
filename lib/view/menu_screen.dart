import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:restaurant_pos_mobile/view_models/menu_view_model.dart';

class MenuScreenPage extends StatefulWidget {
  const MenuScreenPage({Key? key}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreenPage> {
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  MenuScreen menu = MenuScreen();
  String _selectedOption = 'Category';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('http://localhost/mobile_apps/fetch_menu_data.php'));

    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body);
        filteredProducts = List.from(products);
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  void searchProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredProducts = List.from(products);
      } else {
        filteredProducts = products.where((product) =>
            product['name'].toString().toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
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
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: GridView.builder(
                itemCount: filteredProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.5,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final product = filteredProducts[index];
                  final imageUrl = '${product['image_path']}';

                  return GestureDetector(
                    onTap: () {
                      menu.showVariationsDialog(context, int.parse(product['p_id']));
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
                          Image.asset(
                            imageUrl,
                            height: 80,
                            width: 80,
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
    );
  }
}