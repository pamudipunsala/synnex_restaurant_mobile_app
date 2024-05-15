import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreenPage extends StatefulWidget {
  const ProfileScreenPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreenPage> {
  List roles = [];

  @override
  void initState() {
    super.initState();
    fetchRoles();
  }

  Future<void> fetchRoles() async {
    final response = await http.get(Uri.parse('http://localhost/mobile_apps/fetch_profile_data.php'));

    if (response.statusCode == 200) {
      setState(() {
        roles = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load roles');
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img1.png', 
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            roles.isEmpty
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: roles.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('Role ID: ${roles[index]['role_id']}'),
                          subtitle: Text('Role Name: ${roles[index]['role_name']}'),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
