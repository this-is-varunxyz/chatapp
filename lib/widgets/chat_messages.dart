import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('chat').orderBy('createdAt',descending: true).snapshots(),
      builder: (ctx, chatSnapShot) {
        if (chatSnapShot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!chatSnapShot.hasData || chatSnapShot.data!.docs.isEmpty) {
          return const Center(child: Text("No messages found"));
        }
        if (chatSnapShot.hasError) {
          return Center(child: Text("Somethin' went wrong"));
        }
        final loadedMessage = chatSnapShot.data!.docs;
        return ListView.builder(
          reverse: true,
          itemCount: loadedMessage.length,
          itemBuilder: (ctx, index) {
           return Text(loadedMessage[index].data()['text']);
          },
        );
      },
    );
  }
}
