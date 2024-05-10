import 'dart:async';

import 'package:flutter/material.dart';
import 'package:restaurant_pos_mobile/view/login_screen.dart';

class SplashServices {
  void isLogin(BuildContext context) {
    Timer(
        const Duration(seconds: 3),
        () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreenPage(),
              ),
            ));
  }
}
