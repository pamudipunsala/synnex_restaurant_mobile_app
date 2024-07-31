import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: const Color.fromARGB(240, 225, 218, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 71, 4, 4),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: GoogleFonts.archivo(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              // rgb(240, 225, 218)
              Color(0xFFDAB3AC),
              Color(0xFFF0E1DA), // rgb(218, 179, 172)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : userDetails != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Profile Details',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 71, 4, 4),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          elevation: 5,
                          margin: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/img1.png',
                                  width: 150,
                                  height: 150,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'User Name: ${userDetails!['u_name']}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Email: ${userDetails!['user_email']}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Joined Date: ${userDetails!['created_date']}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 80),
                        Text(
                          'Powered by Synnex IT Solutions 2024',
                          style: GoogleFonts.archivo(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ), // Additional space after the card item
                      ],
                    )
                  : Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                    ),
        ),
      ),
    );
  }
}
