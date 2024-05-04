import 'package:chatapp/screen/chat_screen.dart';
import 'package:chatapp/screen/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final firebase = FirebaseAuth.instance;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  String _email = "";
  String _pass = "";
  String _passerorr = '';
  String _emailerorr = '';
  IconData icon = Icons.visibility;
  bool isPasswordVisible = false;
  bool _isAuthication = false;

  final _formKey = GlobalKey<FormState>();
  void _submit() async {
    setState(() {
      _isAuthication = true;
    });
    final _isValid = _formKey.currentState!.validate();
    if (!_isValid) {
      return;
    }
    _formKey.currentState!.save();
    try {
      final userCredentail = await firebase.signInWithEmailAndPassword(
        email: _email,
        password: _pass,
      );
      if (userCredentail != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext ctx) => const ChatScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == "invalid-email") {
        setState(() {
          _emailerorr = "Invalid Email format";
        });
      } else if (error.code == "wrong-password") {
        setState(() {
          _passerorr = "Wrong password";
        });
      } 
    } finally {
      setState(() {
        _isAuthication = false;
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Login',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                TextFormField(
                  decoration: InputDecoration(
                    errorText: _emailerorr.isNotEmpty ? _emailerorr : null,
                    label: const Text("Email"),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  onSaved: (value) {
                    _email = value!;
                  },
                  validator: (value) {
                    if (value!.isEmpty || !(value.contains("@"))) {
                      return 'Please enter a vailed Email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  obscureText: isPasswordVisible,
                  decoration: InputDecoration(
                    errorText: _passerorr.isNotEmpty ? _passerorr : null,
                    label: const Text("Password"),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(icon),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                          icon = isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off;
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
                const SizedBox(height: 26),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    elevation: 4,
                    backgroundColor: Colors.black,
                  ),
                  child: _isAuthication
                      ? const CircularProgressIndicator()
                      : const Text(
                          "Login",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have a account",
                      style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0), fontSize: 16),
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (BuildContext ctx) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Create one?",
                        style: TextStyle(color: Colors.lightBlue, fontSize: 16),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
