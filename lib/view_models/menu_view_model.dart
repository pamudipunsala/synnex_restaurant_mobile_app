import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/view/cart_screen.dart';

class MenuScreen {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  void showVariationsDialog(BuildContext context) {
    int? selectedRadio = 0;
    bool isChecked = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Title(
                    color: Color.fromARGB(255, 71, 4, 4),
                    child: const Text(
                      'Select the Variant',
                      style: TextStyle(fontWeight: FontWeight.bold,),
                    )),
                RadioListTile(
                  title: const Text(
                      'Variation 1  Rs.800.00'), // Text for the radio button
                  value: 1, // Unique value for this radio button
                  groupValue: selectedRadio, // The currently selected value
                  onChanged: (value) {
                    selectedRadio = value; // Update the selected value
                    // Logic
                  },
                ),
                RadioListTile(
                  title: const Text(
                      'Variation 2 Rs.600.00'), // Text for the radio button
                  value: 1, // Unique value for this radio button
                  groupValue: selectedRadio, // The currently selected value
                  onChanged: (value) {
                    selectedRadio = value; // Update the selected value
                    // Handle radio button selection logic here
                  },
                ),
                RadioListTile(
                  title: const Text(
                      'Variation 3 Rs.400.00'), // Text for the radio button
                  value: 1, // Unique value for this radio button
                  groupValue: selectedRadio, // The currently selected value
                  onChanged: (value) {
                    selectedRadio = value; // Update the selected value
                    // Handle radio button selection logic here
                  },
                ),
                Title(
                  color: Colors.black,
                  child: const Text(
                    'Add Ones',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Checkbox(
                  checkColor: Colors.white,
                  value: isChecked,
                  onChanged: (bool? value) {
                    selectedRadio = value as int?;
                  },
                ),
                const Text('Add Ones 1  Rs.200.00'),
                Checkbox(
                  checkColor: Colors.white,
                  value: isChecked,
                  onChanged: (bool? value) {
                    selectedRadio = value as int?;
                  },
                ),
                const Text('Add Ones 2  Rs.200.00'),
                Checkbox(
                  checkColor: Colors.white,
                  value: isChecked,
                  onChanged: (bool? value) {
                    selectedRadio = value as int?;
                  },
                ),
                const Text('Add Ones 3  Rs.200.00'),
                const Text('Total : 1800.00'),
                const SizedBox(
                    height:
                        20), // Add spacing between the checkboxes and note field
                TextField(
                  controller: noteController, // Assign the note controller
                  decoration: const InputDecoration(
                    labelText: 'Add a note', // Label for the text field
                    border:
                        OutlineInputBorder(), // Border style for the text field
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
                    MaterialPageRoute(
                        builder: ((context) => const CartScreenPage())));
              },
            ),
          ],
        );
      },
    );
  }
}
