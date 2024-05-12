import 'package:chatapp/widget/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _aboutmeController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  String? _name;
  String? _imageUrl;
  String? _email;
  String? _aboutme;
  int _aboutMeLength = 0;

  Future<void> _updateAboutMe() async {
    _aboutme = _aboutmeController.text;
    print(_aboutme);
    final user = FirebaseAuth.instance.currentUser;
    final usersCollection = FirebaseFirestore.instance.collection('users');
    await usersCollection.doc(user!.uid).update({
      'about_me': _aboutme,
    }).then((_) => print('About Me updated successfully'));
  }
  Future<void> _updateName() async {
    _name = _nameController.text;
    print(_aboutme);
    final user = FirebaseAuth.instance.currentUser;
    final usersCollection = FirebaseFirestore.instance.collection('users');
    await usersCollection.doc(user!.uid).update({
      'name': _name,
    }).then((_) => print('name updated successfully'));
  }
  /*Future<void> _updateImage() async {
    if (_imageUrl != null) {
        final storageRef =
            FirebaseStorage.instance.ref().child('user_image').child(
                  '${userCredential.user!.uid}.jpg',
                ).g;
        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();}
    _imageUrl = _nameController.text;
    print(_aboutme);
    final user = FirebaseAuth.instance.currentUser;
    final usersCollection = FirebaseFirestore.instance.collection('users');
    await usersCollection.doc(user!.uid).update({
      'name': _name,
    }).then((_) => print('name updated successfully'));
  }*/

  Future<void> _getAvatarImage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        final snapshot = await userDoc.get();

        if (snapshot.exists) {
          final data = snapshot.data();
          if (data != null) {
            _imageUrl = data['image'] as String;
            _name = data['name'] as String;
            _email = data['email'] as String;
            _aboutme = data['about_me'] as String;
            _aboutMeLength = _aboutme!.length;
            _aboutmeController.text = _aboutme!;
            _nameController.text = _name!;
          }
        } else {
          print('No user document found');
        }
      } else {
        print('Error: No user signed in');
      }
    } on FirebaseException catch (error) {
      print(error);
    }
  }

  void _showAboutMeDialog() {
    final keybordView = MediaQuery.of(context).viewInsets.bottom;

    showModalBottomSheet<void>(
        useSafeArea: true,
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        builder: (context) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight - 20;
              final width = constraints.maxWidth;
              return SizedBox(
                height: height,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, keybordView + 20),
                    child: Form(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _updateAboutMe();
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text(
                                  "Save",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            minLines: 1,
                            maxLines: 363,
                            keyboardType: TextInputType.multiline,
                            buildCounter: (context,
                                {required currentLength,
                                required isFocused,
                                required maxLength}) {
                              maxLength = 140;
                              bool isRight = currentLength < maxLength;
                              return Text(
                                '${maxLength - currentLength}',
                                style: TextStyle(
                                  color: isFocused
                                      ? isRight
                                          ? const Color.fromARGB(255, 2, 2, 2)
                                          : Colors.red
                                      : const Color.fromARGB(
                                          255, 255, 255, 255),
                                ),
                              );
                            },
                            maxLength: 140,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your About Me';
                              } else if (value.length > 140) {
                                return 'Maximum 140 characters allowed';
                              }
                              return null;
                            },
                            controller: _aboutmeController,
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(246, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(246, 255, 255, 255),
        title: const Text("Edit Profile"),
      ),
      body: FutureBuilder(
        future: _getAvatarImage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error:${snapshot.error}"),
            );
          } else {
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      alignment: Alignment.topLeft,
                      margin: const EdgeInsetsDirectional.only(
                          start: 30, end: 30, top: 30, bottom: 20),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              
                               CircleAvatar(
                                  radius: 40.0,
                                  backgroundImage: _imageUrl != null
                                      ? NetworkImage(_imageUrl!)
                                      : null,
                                ),
                              
                              TextButton(
                                onPressed: () {
                                  ImagePick(imagePath: (imagePath) {
                                    _imageUrl = imagePath!.path; 

                                  });
                                },
                                child: const Text(
                                  "Edit",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: TextFormField(
                              controller: _nameController,
                              buildCounter: (context,
                                  {required currentLength,
                                  required isFocused,
                                  required maxLength}) {
                                maxLength = 15;
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end ,
                                  children: [
                                    Text(
                                      '${maxLength - currentLength}',
                                      style: TextStyle(
                                        color: isFocused
                                            ? const Color.fromARGB(255, 2, 2, 2)
                                            : const Color.fromARGB(
                                                255, 255, 255, 255),
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: _updateName,
                                        icon: Icon(
                                          Icons.done,
                                          color: isFocused ? Colors.black : Colors.white,
                                        ))
                                  ],
                                );
                              },
                              validator: (value) {
                                // Optional validation logic
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                if (_name!.length > 15) {
                                  return "please enter a name less than 15 character";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 40),
                      child: const Text(
                        "Email",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      margin: const EdgeInsetsDirectional.only(
                          start: 30, end: 30, bottom: 20),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: Colors.white,
                      ),
                      child: Text(
                        _email ?? "email@gmail.com",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 40),
                      child: const Text(
                        "About",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      margin: const EdgeInsetsDirectional.only(
                          start: 30, end: 30, bottom: 20),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: Colors.white,
                      ),
                      child: ListTile(
                        onTap: _showAboutMeDialog,
                        title: Text(_aboutme!),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          fill: BorderSide.strokeAlignCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
