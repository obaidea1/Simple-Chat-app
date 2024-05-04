import 'package:chatapp/widget/chat_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatefulWidget {
  const ChatMessage({super.key});

  @override
  State<ChatMessage> createState() {
    return _ChatMessageState();
  }
}

class _ChatMessageState extends State<ChatMessage> {
  @override
  Widget build(BuildContext context) {

    final authentucatedUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("chat")
          .orderBy(
            'messagedate',
            descending: true,
          )
          .snapshots(),
      builder: (ctx, snapshots) {
        if (snapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshots.hasData || snapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text("There's no message yet"),
          );
        }
        final loadedMessage = snapshots.data!.docs;
        return ListView.builder(
          reverse: true,
          itemCount: loadedMessage.length,
          itemBuilder: (context, index) {
            final chatmessage = loadedMessage[index].data();
            final nextChatMessage = index + 1 < loadedMessage.length
                ? loadedMessage[index + 1].data()
                : null;
            final userId = chatmessage['userid'];
            final nextUserId = nextChatMessage != null
                ? nextChatMessage["userid"]
                : null;
            final nextUserIsSame = userId == nextUserId;
            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatmessage["message"],
                isMe: authentucatedUser!.uid == userId,
              );
            } else {
              return MessageBubble.first(
                userImage: chatmessage["userImage"],
                username: chatmessage["name"],
                message: chatmessage["message"],
                isMe: authentucatedUser!.uid == userId,
              );
            }
          },
        );
      },
    );
  }
}
