import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreenPage extends StatefulWidget {
  const ProfileScreenPage({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreenPage> {
  Map<String, dynamic>? userDetails;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchProfileDetails();
  }

  Future<void> fetchProfileDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    // Debug print
    print('User ID: $userId');

    if (userId != null) {
      try {
        final response = await http.post(
          Uri.parse('https://mobileapp.synnexcloudpos.com'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'profile_id': userId,
          },
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          List<dynamic> responseData = json.decode(response.body);

          if (responseData.isNotEmpty) {
            setState(() {
              userDetails = responseData[0];
              isLoading = false;
            });
          } else {
            setState(() {
              errorMessage = 'No profile details found';
              isLoading = false;
            });
          }
        } else {
          setState(() {
            errorMessage = 'Failed to load profile details';
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'Failed to load profile details';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        errorMessage = 'User ID not found';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color.fromARGB(255, 71, 4, 4),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : userDetails != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/img1.png',
                        width: 150,
                        height: 150,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'User Name: ${userDetails!['u_name']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'User Email: ${userDetails!['user_email']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Joined Date: ${userDetails!['created_date']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  )
                : Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                  ),
      ),
    );
  }
}
