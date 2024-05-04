import 'dart:io';

import 'package:chatapp/screen/chat_screen.dart';
import 'package:chatapp/screen/login_screen.dart';
import 'package:chatapp/widget/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() {
    return _SignupScreenState();
  }
}

class _SignupScreenState extends State<SignupScreen> {
  String _name = "";
  String _pass = "";
  String _email = "";
  String _emailError = ""; 
  String _passwordError = ""; 
  IconData icon = Icons.visibility;
  bool isVisible = false;
  bool _isSubmitting = false; 
  File? _selectedImage;

  final _formKey = GlobalKey<FormState>();

   void _submit() async {
    setState(() {
      _isSubmitting = true;
    });

    final _isValid = _formKey.currentState!.validate();
    if (!_isValid) {
      return;
    }

    _formKey.currentState!.save();

    try {
      final userCredential = await _firebase.createUserWithEmailAndPassword(
          email: _email, password: _pass);

      if (_selectedImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child('user_image').child(
          '${userCredential.user!.uid}.jpg',
        );
        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredential.user!.uid)
            .set({
          "image": imageUrl,
          "name": _name,
          "email": _email,
        });
      }

      if (userCredential != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => const ChatScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (error) {
      setState(() {
        _isSubmitting = false;
      });
      if(error.code == 'email-already-in-use'){
        _emailError = "email-already-in-use";
      }
      if(error.code == "weak-password"){
        _passwordError = "weak-password";
      }
    } catch (error) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Hello ',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 50,
                        fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Let's create your own account",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  const SizedBox(
                    height: 26,
                  ),
                  ImagePick(
                    imagePath: (pickedImage) {
                      _selectedImage = pickedImage;
                      print(_selectedImage!.path);
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      label: Text("Name"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                      ),
                      prefixIcon: Icon(Icons.person),
                    ),
                    onSaved: (value) {
                      _name = value!;
                      print(_name);
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter your name";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      errorText: _emailError.isEmpty ? null : _emailError,
                      label: const Text("Email"),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                      ),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    onSaved: (value) {
                      _email = value!;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter a email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    obscureText:   isVisible ,
                    decoration: InputDecoration(
                      errorText: _passwordError.isEmpty ? null : _passwordError,
                      label: const Text("Password"),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(icon),
                        onPressed: () {
                          setState(() {
                            isVisible = !isVisible;

                            if (isVisible) {
                              icon = Icons.visibility_off;
                            } else {
                              icon = Icons.visibility;
                            }
                          });
                        },
                      ),
                    ),
                    onSaved: (value) {
                      _pass = value!;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      elevation: 25,
                      backgroundColor: Colors.black,
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text(
                            "SignUp",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have a account",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (BuildContext ctx) =>
                                    const LoginScreen()),
                          );
                        },
                        child: const Text(
                          "Login?",
                          style:
                              TextStyle(color: Colors.lightBlue, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
