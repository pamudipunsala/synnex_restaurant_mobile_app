import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/models/menu_model.dart';
import 'package:restaurant_pos_mobile/view_models/menu_view_model.dart';

class MenuScreenPage extends StatefulWidget {
  const MenuScreenPage({Key? key}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreenPage> {
  MenuScreen menu = MenuScreen();

  List<MenuButtonModel> menuButtons = [
    MenuButtonModel(
      label: 'Fried Rice\nRs.800.00',
      imagePath: 'assets/img2.jpeg',
    ),
    MenuButtonModel(
      label: 'String Hoppers\nRs.400.00',
      imagePath: 'assets/img3.jpeg',
    ),
  ];

  String _selectedOption = 'Category';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: const Color.fromARGB(255, 19, 139, 4),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: menu.searchController,
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Logic
              },
            ),
          ),
          DropdownButton<String>(
            value: _selectedOption,
            items: const [
              DropdownMenuItem(
                child: Text('Category'),
                value: 'Category',
              ),
              DropdownMenuItem(
                child: Text('Breakfast'),
                value: 'Breakfast',
              ),
              DropdownMenuItem(
                child: Text('Lunch'),
                value: 'Lunch',
              ),
              DropdownMenuItem(
                child: Text('Dinner'),
                value: 'Dinner',
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedOption = value!;
              });
            },
          ),
          GridView.builder(
            shrinkWrap: true,
            itemCount: menuButtons.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (BuildContext context, int index) {
              final imagePath = menuButtons[index].imagePath;
              return GestureDetector(
                onTap: () {
                  // Logic
                  menu.showVariationsDialog(context);
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
                        imagePath,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        menuButtons[index].label,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
