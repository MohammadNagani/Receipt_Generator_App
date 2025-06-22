//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:receipt_generator/layouts/editProfile.dart';
import 'package:receipt_generator/authenication/register.dart'; // Import the RegisterPage

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:receipt_generator/receipt/reciept_history.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = '';
  String userEmail = '';
  String profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      final data = await supabase
          .from('profiles')
          .select('first_name, last_name, profile_image, email')
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        setState(() {
          String firstName = data['first_name'] ?? '';
          String lastName = data['last_name'] ?? '';
          userName = '$firstName $lastName'.trim();
          userEmail = data['email'] ?? user.email ?? 'No Email';
          profileImageUrl = data['profile_image'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 10),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: profileImageUrl.isEmpty
                            ? null
                            : NetworkImage(profileImageUrl),
                        child: profileImageUrl.isEmpty
                            ? IconButton(
                                onPressed: profileImage,
                                icon: Icon(Icons.person, size: 30),
                              )
                            : null,
                      ),
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.add_a_photo),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: TextStyle(fontSize: 20)),
                    Text(userEmail, style: TextStyle(fontSize: 15)),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.blue,
                elevation: 3,
              ),
              onPressed: editProfile,
              child: Text(
                "Edit Profile",
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            buildProfileSettings(Icons.logout, "Log Out", _logout),
            Divider(),
            buildProfileSettings(Icons.receipt, "Receipt", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReceiptHistoryPage()),
              );
            }),
          ],
        ),
      ),
    );
  }

  void editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfile()),
    );
  }

  Widget buildProfileSettings(IconData icon, String text, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Icon(icon),
        Text(text),
        IconButton(onPressed: onTap, icon: Icon(Icons.arrow_right)),
      ],
    );
  }

  Future<void> _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RegisterPage()),
      );
    } catch (e) {
      print("Error signing out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: $e")),
      );
    }
  }

  Future<void> profileImage() async {}
}
