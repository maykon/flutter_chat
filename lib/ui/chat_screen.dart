import 'dart:io';

import 'package:chat/ui/chat_message.dart';
import 'package:chat/ui/text_composer.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';

final googleSignIn = GoogleSignIn();
final auth = FirebaseAuth.instance;

Future<Null> _ensureLoggedIn() async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null) user = await googleSignIn.signInSilently();
  if (user == null) user = await googleSignIn.signIn();
  if (await auth.currentUser() == null) {
    GoogleSignInAuthentication credentials =
        await googleSignIn.currentUser.authentication;
    await auth.signInWithCredential(GoogleAuthProvider.getCredential(
        idToken: credentials.idToken, accessToken: credentials.accessToken));
  }
}

_handleSubmited(String text) async {
  await _ensureLoggedIn();
  _sendMessage(text: text);
}

void _sendMessage({String text, String imgUrl}) {
  Firestore.instance.collection("messages").add({
    "text": text,
    "imgUrl": imgUrl,
    "senderName": googleSignIn.currentUser.displayName,
    "senderPhotoUrl": googleSignIn.currentUser.photoUrl,
  });
}

void _onSendImage(File image) async {
  if (image == null) return;
  await _ensureLoggedIn();
  StorageUploadTask task = FirebaseStorage.instance
      .ref()
      .child(googleSignIn.currentUser.id.toString() +
          DateTime.now().millisecondsSinceEpoch.toString())
      .putFile(image);
  StorageTaskSnapshot taskSnapshot = await task.onComplete;
  String url = await taskSnapshot.ref.getDownloadURL();
  _sendMessage(imgUrl: url);
}

/*
StorageUploadTask task = FirebaseStorage.instance.ref().child(googleSignIn.currentUser.id.toString() +
    DateTime.now().millisecondsSinceEpoch.toString()).putFile(imgFile);
StorageTaskSnapshot taskSnapshot = await task.onComplete;
String url = await taskSnapshot.ref.getDownloadURL();
_sendMessage(imgUrl: url);
*/

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Chat"),
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                child: StreamBuilder(
              stream: Firestore.instance.collection("messages").snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    return ListView.builder(
                        reverse: true,
                        itemBuilder: (context, index) {
                          List list = snapshot.data.documents.reversed.toList();
                          return ChatMessage(data: list[index].data);
                        },
                        itemCount: snapshot.data.documents.length);
                }
              },
            )),
            Divider(
              height: 1.0,
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: TextComposer(
                onSubmited: _handleSubmited,
                onSendImage: _onSendImage,
              ),
            )
          ],
        ),
      ),
    );
  }
}
