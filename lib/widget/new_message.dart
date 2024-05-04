import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NewMessage();
  }
}

class _NewMessage extends State<NewMessage> {
  TextEditingController _message = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _message.dispose();
  }

  void _sentMessage ()async {
    final enteredMessage = _message.text;
    if(enteredMessage.trim().isEmpty){
      return;
    }
    FocusScope.of(context).unfocus();
    _message.clear();
    final user = FirebaseAuth.instance.currentUser;

    final userData = await FirebaseFirestore.instance
    .collection("users")
    .doc(user!.uid)
    .get();
    FirebaseFirestore.instance.collection("chat").add({
      "message" : enteredMessage,
      "userid" : user.uid,
      "messagedate" : Timestamp.now(),
      "userImage" : userData.data()!['image'],
      "name" : userData.data()!['name'],
    });
    
    
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10,bottom: 10,right: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: TextField(
              autocorrect: true,
              textCapitalization: TextCapitalization.characters,
              controller: _message,
              decoration: const InputDecoration(
                hintText: "write your message",
              ),

            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            onPressed: _sentMessage,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
