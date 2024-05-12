import 'package:chatapp/screen/login_screen.dart';
import 'package:chatapp/screen/profile.dart';
import 'package:chatapp/widget/chat_message.dart';
import 'package:chatapp/widget/new_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
        await fcm.requestPermission();
        fcm.subscribeToTopic("chat");
  }
  @override
  void initState() {
    super.initState();
    _getAvatarImage();
    setUpPushNotification();
  }

  Future<void> _getAvatarImage() async {
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
        centerTitle: true,
        actions: [
          FutureBuilder(
            future: _getAvatarImage(),
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting){
                return const Center(child: CircularProgressIndicator(),);
              } else if(snapshot.hasError){
                return Center(child: Text("Error: ${snapshot.error}"),);
              } else {
                return GestureDetector(
              onTap: () async {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext ctx) => const ProfileScreen(),
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
            );
              }
            },
          ),
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
