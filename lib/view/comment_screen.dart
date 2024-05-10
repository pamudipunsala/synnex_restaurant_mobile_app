import 'package:flutter/material.dart';

class CommentScreenPage {
  final TextEditingController noteController = TextEditingController();

  void toNote(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Note'),
          content: TextField(
            controller: noteController,
            decoration: const InputDecoration(
              hintText: 'Enter your note here',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                // Get the note text from the controller
                String noteText = noteController.text;
                // Use the note text as needed (e.g., save it, print it)
                print('Note: $noteText');
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
