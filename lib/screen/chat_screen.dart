import 'package:chatapp/screen/login_screen.dart';
import 'package:chatapp/widget/chat_message.dart';
import 'package:chatapp/widget/new_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  String? _imageUrl; // Use a nullable type to handle potential image absence
  void setUpPushNotification() async {
        final fcm = FirebaseMessaging.instance;
        fcm.requestPermission();
        fcm.subscribeToTopic("chat");
  }
  @override
  void initState() {
    super.initState();
    getAvatarImage();
  }

  Future<void> getAvatarImage() async {
    try {
      final fireStoreImage = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (fireStoreImage.exists) {
        final data = fireStoreImage.data()!;
        _imageUrl = data['image'] as String?;
      }
    } on FirebaseException catch (error) {
      print( error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Group"),
        actions: [
          GestureDetector(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (BuildContext ctx) => const LoginScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 10,
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundImage:
                    _imageUrl != null ? NetworkImage(_imageUrl!) : null,
              ),
            ),
          )
          /*IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (BuildContext ctx) => const LoginScreen(),
                ),
              );
            },
            icon: const Icon(Icons.logout_sharp),
          ),*/
        ],
      ),
      body: const Column(
        children: [
          Expanded(
            child: ChatMessage(),
          ),
          NewMessage(),
        ],
      ),
    );
  }
}
