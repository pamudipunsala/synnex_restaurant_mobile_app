import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/view_models/login_view_model.dart';

class LoginScreenPage extends StatefulWidget {
  const LoginScreenPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreenPage> {
  LoginScreen loginScreen = LoginScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Title(
                color: const Color.fromARGB(255, 19, 139, 4),
                child: const Text('LogIn')),
            TextField(
              controller: loginScreen.usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: loginScreen.passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                //logic
                loginScreen.toDashboard(context);
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
