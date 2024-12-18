import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Import Cupertino widgets
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:restaurant_pos_mobile/constants.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

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
          Uri.parse(apiDomain),
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
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Scale text and element sizes based on screen width
    final double fontSize = screenWidth * 0.05;
    final double imageWidth = screenWidth * 0.4;
    final double imageHeight = screenHeight * 0.2;
    final double cardMargin = screenWidth * 0.05;
    final double cardPadding = screenWidth * 0.05;
    final double contentSpacing = screenHeight * 0.02;

    return Scaffold(
      backgroundColor: const Color.fromARGB(240, 225, 218, 255),
      appBar: Platform.isIOS
          ? PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: CupertinoNavigationBar(
                middle: Text(
                  'Profile',
                  style: GoogleFonts.bacasimeAntique(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                backgroundColor: const Color.fromARGB(255, 71, 4, 4),
              ),
            )
          : AppBar(
              backgroundColor: const Color.fromARGB(255, 71, 4, 4),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
                    style: GoogleFonts.bacasimeAntique(
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      body: Container(
        color: const Color.fromARGB(255, 235, 226, 225),
        child: Center(
          child: isLoading
              ? (Platform.isIOS
                  ? const CupertinoActivityIndicator()
                  : const CircularProgressIndicator())
              : userDetails != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Profile Details',
                          style: GoogleFonts.bacasimeAntique(
                            textStyle: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 71, 4, 4),
                            ),
                          ),
                        ),
                        SizedBox(height: contentSpacing),
                        Card(
                          color: Color.fromARGB(255, 250, 236, 234),
                          elevation: 5,
                          margin: EdgeInsets.all(cardMargin),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            side: const BorderSide(
                              color: Color.fromARGB(255, 202, 158, 150),
                              width: 5.0,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(cardPadding),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/img1.png',
                                  width: imageWidth,
                                  height: imageHeight,
                                ),
                                SizedBox(height: contentSpacing),
                                Text(
                                  'User Name: ${userDetails!['u_name']}',
                                  style: TextStyle(fontSize: fontSize * 0.7),
                                ),
                                SizedBox(height: contentSpacing),
                                Text(
                                  'Email: ${userDetails!['user_email']}',
                                  style: TextStyle(fontSize: fontSize * 0.7),
                                ),
                                SizedBox(height: contentSpacing),
                                Text(
                                  'Joined Date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(userDetails!['created_date']))}',
                                  style: TextStyle(fontSize: fontSize * 0.7),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: contentSpacing * 2),
                        Text(
                          'Powered by Synnex IT Solutions 2024',
                          style: GoogleFonts.archivo(
                            color: Colors.black54,
                            fontSize: fontSize * 0.5,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: fontSize),
                    ),
        ),
      ),
    );
  }
}
