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
        'user_password': password,
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData is List && responseData.isNotEmpty) {
        final userId = responseData[0]['user_id'].toString();
        final comId = responseData[0]['com_id'].toString();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userId.toString());

        print('Stored userId: $userId');
        print('Stored comId: $comId');

        loginScreen.toDashboard(context, comId, userId);
      } else {
        _showErrorDialog(context, 'Unexpected response from the server.');
      }
    } else {
      _showErrorDialog(context, 'Invalid username or password.');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content: Text(message),
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
