import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 8.0,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'LogIn',
                              style: GoogleFonts.archivo(
                                color: const Color.fromARGB(255, 71, 4, 4),
                                fontSize: 40,
                              ),
                            ),
                            const SizedBox(height: 40.0),
                            Theme(
                              data: Theme.of(context).copyWith(
                                inputDecorationTheme:
                                    const InputDecorationTheme(
                                  labelStyle: TextStyle(
                                      color: Color.fromARGB(255, 71, 4, 4)),
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
                                inputDecorationTheme: InputDecorationTheme(
                                  labelStyle: GoogleFonts.archivo(
                                    color: const Color.fromARGB(255, 71, 4, 4),
                                  ),
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
                            const SizedBox(height: 40.0),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .transparent, // Make the button background transparent
                                shadowColor: Colors.black.withOpacity(1),
                                fixedSize: const Size(220, 70),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Adjust this value to reduce the border radius
                                ),
                                elevation:
                                    0, // Set elevation to 0 to remove default shadow
                              ).copyWith(
                                backgroundColor:
                                    WidgetStateProperty.resolveWith<Color?>(
                                  (states) => Colors.transparent,
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  _login(context);
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF470404),
                                      Color(0xFFDAB3AC),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      8.0), // Match the border radius of the button
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Login',
                                  style: GoogleFonts.archivo(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40.0),
                Text(
                  'Powered by Synnex IT Solutions 2024',
                  style: GoogleFonts.archivo(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
