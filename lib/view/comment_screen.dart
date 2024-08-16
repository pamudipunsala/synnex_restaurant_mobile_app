import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Import this for Cupertino widgets
import 'dart:io'; // Import this to use Platform-specific checks

class CommentScreenPage {
  final TextEditingController noteController = TextEditingController();

  void toNote(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Platform.isIOS
            ? CupertinoAlertDialog(
                title: const Text('Note'),
                content: CupertinoTextField(
                  controller: noteController,
                  placeholder: 'Enter your note here',
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                  CupertinoDialogAction(
                    child: const Text('Save'),
                    onPressed: () {
                      // Get the note text from the controller
                      String noteText = noteController.text;
                      // Use the note text as needed (e.g., save it, print it)
                      print('Note: $noteText');
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ],
              )
            : AlertDialog(
                title: const Text('Note'),
                content: TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your note here',
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                  TextButton(
                    child: const Text('Save'),
                    onPressed: () {
                      String noteText = noteController.text;
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
