import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restaurant_pos_mobile/view_models/login_view_model.dart';

class LoginScreenPage extends StatefulWidget {
  const LoginScreenPage({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreenPage> {
  LoginScreen loginScreen = LoginScreen();
  final _formKey = GlobalKey<FormState>();

  Future<void> _login(BuildContext context) async {
    final username = loginScreen.usernameController.text;
    final password = loginScreen.passwordController.text;

    final response = await http.post(
      Uri.parse('https://mobileapp.synnexcloudpos.com'),
      body: {
        'u_name': username,
        'user_email': username,
        'user_password': password,
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      // Debug print statements to check the response
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('Parsed response data: $responseData');

      // Check if responseData is a list
      if (responseData is List) {
        print('Received a list instead of an object: $responseData');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Login Failed'),
              content: const Text('Unexpected response from the server.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      final userId = responseData['user_id'];
      if (userId != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userId.toString());

        // Debug print to confirm userId is stored
        print('Stored userId: $userId');

        // ignore: use_build_context_synchronously
        loginScreen.toDashboard(context);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Login Failed'),
              content: const Text('Invalid username or password.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      // Handle non-200 responses
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Failed'),
            content: const Text('Unexpected response from the server.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'LogIn',
                style: TextStyle(
                  color: Color.fromARGB(255, 71, 4, 4),
                  fontSize: 40,
                ),
              ),
              const SizedBox(height: 60.0),
              Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: const InputDecorationTheme(
                    labelStyle: TextStyle(color: Color.fromARGB(255, 71, 4, 4)),
                  ),
                ),
                child: TextFormField(
                  controller: loginScreen.usernameController,
                  decoration: const InputDecoration(
                    labelText: 'UserName or UserEmail',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Your Username';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20.0),
              Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: const InputDecorationTheme(
                    labelStyle: TextStyle(color: Color.fromARGB(255, 71, 4, 4)),
                  ),
                ),
                child: TextFormField(
                  controller: loginScreen.passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Your Password';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 80.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 71, 4, 4),
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  fixedSize: const Size(90, 50),
                ),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _login(context);
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
