import 'dart:math';

import 'package:chat/Theme/Colors.dart';
import 'package:chat/main.dart';
import 'package:chat/models/ChatroomModel.dart';
import 'package:chat/models/MessageModel.dart';
import 'package:chat/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Chatroom extends StatefulWidget {
  final UserModel targetUsr;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const Chatroom(
      {super.key,
      required this.targetUsr,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<Chatroom> createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {
  TextEditingController message_controller = TextEditingController();

  void sendmessage() async {
    String msg = message_controller.text.trim();
    message_controller.clear();

    if (msg != null) {
      MessageModel newmessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        text: msg,
        seen: false,
        createdon: DateTime.now(),
      );

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newmessage.messageid)
          .set(newmessage.toMap());

      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());
      print("message sent");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade400,
              backgroundImage:
                  NetworkImage(widget.targetUsr.profilepic!.toString()),
            ),
            SizedBox(
              width: 10,
            ),
            Text(widget.targetUsr.fullname.toString()),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("chatrooms")
                  .doc(widget.chatroom.chatroomid)
                  .collection("messages")
                  .orderBy("createdon", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot datasnapshot = snapshot.data as QuerySnapshot;

                    return ListView.builder(
                        reverse: true,
                        itemCount: datasnapshot.docs.length,
                        itemBuilder: (context, index) {
                          MessageModel currentmessage = MessageModel.fromMap(
                              datasnapshot.docs[index].data()
                                  as Map<String, dynamic>);
                          return Padding(
                            padding: const EdgeInsets.all(2),
                            child: Row(
                              mainAxisAlignment: (currentmessage.sender ==
                                      widget.userModel.uid)
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 39, 159, 45),
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: EdgeInsets.all(12),
                                  margin: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    currentmessage.text.toString(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("An error occured!"),
                    );
                  } else {
                    return Center(
                      child: Text("Say hi to your friend"),
                    );
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          )),
          Container(
            padding: EdgeInsets.only(right: 25, left: 10, top: 20, bottom: 10),
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 21, 36, 21),
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        controller: message_controller,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.grey.shade500),
                          labelText: 'Message here...',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(40)),
                  child: IconButton(
                      onPressed: () {
                        sendmessage();
                      },
                      icon: Icon(
                        Icons.send,
                        color: primaryColor,
                        size: 30,
                      )),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
