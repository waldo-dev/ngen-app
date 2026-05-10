import 'package:app/src/util/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:app/l10n/app_localizations.dart';
import 'package:translator/translator.dart';

class ChatWidget extends StatefulWidget {
  final String tourId;
  final String managerId;

  ChatWidget(this.tourId, this.managerId);

  @override
  State<ChatWidget> createState() => ChatWidgetState();
}

class ChatWidgetState extends State<ChatWidget> {
  FirebaseAuth auth = FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getChat() {
    CollectionReference chats = FirebaseFirestore.instance.collection('chats');
    return chats
        .doc(widget.managerId)
        .collection('chat')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final _user = types.User(id: auth.currentUser!.uid);

    void _handleSendPressed(types.PartialText message) async {
      final translator = GoogleTranslator();
      var translation = await translator.translate(message.text, from: AppLocalizations.of(context)!.localeName, to: 'es');
      print(translation);
      CollectionReference chats = FirebaseFirestore.instance.collection('chats');
      await chats
          .doc(widget.managerId)
          .collection('chat')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .add({"createdAt": DateTime.now(), "senderId": auth.currentUser!.uid, "translatedMessage": translation.text, "message": message.text});
      await chats
          .doc(widget.managerId)
          .collection('chat')
          .doc(auth.currentUser!.uid)
          .set({'locale': AppLocalizations.of(context)!.localeName, 'name': "Anonymous"}, SetOptions(merge: true));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: getChat(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<types.Message> messages = snapshot.data!.docs.map((e) {
            var textMessage = types.TextMessage(
              author: types.User(id: e.get('senderId')),
              createdAt: e.get('createdAt').millisecondsSinceEpoch,
              id: e.id,
              text: e.get('senderId') == auth.currentUser!.uid ? e.get('message') : e.get('translatedMessage'),
            );
            return textMessage;
          }).toList();
          return Scaffold(
            appBar: AppBar(
              elevation: 1,
              title: Text(
                AppLocalizations.of(context)!.chatTitle,
                style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.font_black,
            ),
            body: Chat(
              theme: DefaultChatTheme(primaryColor: AppColors.primary, inputBackgroundColor: AppColors.font_black),
              messages: messages,
              onSendPressed: _handleSendPressed,
              user: _user,
            ),
          );
        });
  }
}

