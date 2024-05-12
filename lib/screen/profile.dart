import 'package:chatapp/screen/edit_profile.dart';
import 'package:chatapp/screen/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _imageUrl;
  String? _name;
  String _currentLanguage = 'en';

  Future<void> _getAvatarImage() async {
    try {
      final fireStorageImage = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (fireStorageImage.exists) {
        final data = fireStorageImage.data();
        if (data != null) {
          _imageUrl = data['image'] as String? ?? '';
          _name = data['name'] as String? ?? '';
        }
      }
    } on FirebaseException catch (error) {
      print(error);
    }
  }

  /*void _showAppearanceDialog() {
    showModalBottomSheet<void>(
        useSafeArea: true,
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ), // Rounded top corner
        builder: (context) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight - 20;
              final width = constraints.maxWidth;
              return SizedBox(
                height: height,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Form(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Appearance"),
                          const SizedBox(height: 20.0),
                          Row(
                            children: [
                              const Text("Theme:"),
                              const Spacer(),
                              Switch(
                                value:
                                    _isLightTheme, // Replace with your theme selection logic
                                onChanged: (value) =>
                                    setState(() => _isLightTheme = value),
                              ),
                              const Text('Light'),
                            ],
                          ),
                          Row(
                            children: [
                              const Text("Language:"),
                              const Spacer(),
                              Switch(
                                value:
                                    _isEnglish, // Replace with your language selection logic
                                onChanged: (value) =>
                                    setState(() => _isEnglish = value),
                              ),
                              const Text('English'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (ctx) => const LoginScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.login_outlined, color: Colors.red))
        ],
      ),
      body: FutureBuilder<void>(
        future: _getAvatarImage(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(
              child: Column(
                children: [
                  const SizedBox(height: 25),
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        _imageUrl != null ? NetworkImage(_imageUrl!) : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _name ?? 'name',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: ((context) => const EditProfileScreen())));
                    },
                    icon: const Icon(
                      Icons.edit_note_outlined,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Edit Profile",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                    ),
                    child: const Text(
                      "State",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const ListTile(
                    title: Text(
                      "At school",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                    ),
                    child: const Text(
                      "Language",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[ 
                          const Text("Language",style: TextStyle(fontSize: 16),),
                          DropdownButton<String>(
                          value: _currentLanguage,
                          items: const [
                            DropdownMenuItem(
                              value: 'en',
                              child: Text('English (US)'),
                            ),
                            DropdownMenuItem(
                              value: 'es',
                              child: Text('Spanish (ES)'),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _currentLanguage = value!),
                        ),
                        ],
                      ),
                    ),
                  
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
