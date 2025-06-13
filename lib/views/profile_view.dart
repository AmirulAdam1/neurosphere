import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neurosphere/views/edit_profile_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      try {
        print("Fetching data for user: \${user!.uid}");

        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get()
            .timeout(const Duration(seconds: 5));

        if (doc.exists) {
          print("Document found for user: \${user!.uid}");
          setState(() {
            userData = doc.data();
            _isLoading = false;
          });
        } else {
          print("No document found for user: \${user!.uid}");
          setState(() => _isLoading = false);
        }
      } catch (e) {
        print("Error fetching user data: \$e");
        setState(() => _isLoading = false);
      }
    } else {
      print("No authenticated user.");
      setState(() => _isLoading = false);
    }
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileView()),
    ).then((_) => _loadUserData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditProfile,
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
              ? const Center(child: Text('No user data found.'))
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Icon(Icons.account_circle, size: 100, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      Text('Full Name: ${userData!['name']}', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      Text('Age: ${userData!['age']}', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      Text('Phone: ${userData!['phone']}', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      Text('Email: ${userData!['email']}', style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
    );
  }
}
