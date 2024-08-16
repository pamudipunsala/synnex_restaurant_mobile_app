import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restaurant_pos_mobile/view_models/login_view_model.dart';
import 'package:platform/platform.dart';

class LoginScreenPage extends StatefulWidget {
  const LoginScreenPage({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreenPage> {
  LoginScreen loginScreen = LoginScreen();
  final _formKey = GlobalKey<FormState>();
  final Platform platform = const LocalPlatform(); // Initialize the platform

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

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData is List && responseData.isNotEmpty) {
        final userId = responseData[0]['user_id'].toString();
        final comId = responseData[0]['com_id'].toString();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userId.toString());

        loginScreen.toDashboard(context, comId, userId);
      } else {
        _showErrorDialog(context, 'Unexpected response from the server.');
      }
    } else {
      _showErrorDialog(context, '\nInvalid username or password.');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    if (platform.isIOS) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Login Failed'),
            content: Text(message),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
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
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get the screen size and adjust layout accordingly
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

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
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 20.0 : size.width * 0.1,
              vertical: size.height * 0.05,
            ),
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
                              platform.isIOS ? 'Log In' : 'Log In',
                              style: GoogleFonts.archivo(
                                color: const Color.fromARGB(255, 71, 4, 4),
                                fontSize: isSmallScreen ? 30 : 40,
                              ),
                            ),
                            const SizedBox(height: 40.0),
                            Theme(
                              data: Theme.of(context).copyWith(
                                inputDecorationTheme:
                                    const InputDecorationTheme(
                                  labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 71, 4, 4),
                                  ),
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
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.black.withOpacity(1),
                                fixedSize: Size(
                                  isSmallScreen ? 180 : 220,
                                  isSmallScreen ? 50 : 70,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                elevation: 0,
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
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Login',
                                  style: GoogleFonts.archivo(
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    fontSize: isSmallScreen ? 18 : 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40.0),
                Text(
                  platform.isIOS
                      ? 'Powered by Synnex IT Solutions 2024 (iOS)'
                      : 'Powered by Synnex IT Solutions 2024 (Android)',
                  style: GoogleFonts.archivo(
                    color: Colors.black54,
                    fontSize: isSmallScreen ? 12 : 14,
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
