import 'package:chat/Theme/Colors.dart';
import 'package:chat/main.dart';
import 'package:chat/models/ChatroomModel.dart';
import 'package:chat/models/UserModel.dart';
import 'package:chat/pages/chatroom_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController search_controller = TextEditingController();

  Future<ChatRoomModel?> getchatroom(UserModel targetUser) async {
    ChatRoomModel? chatroom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();
    if (snapshot.docs.length > 0) {
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingchatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatroom = existingchatroom;
    } else {
      ChatRoomModel newchatroom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
        users: [widget.userModel.uid.toString(), targetUser.uid.toString()],
        createdon: DateTime.now(),
      );
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newchatroom.chatroomid)
          .set(newchatroom.toMap());

      chatroom = newchatroom;
    }

    return chatroom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text('Select Contact'),
        ),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 50),
          child: ListView(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 21, 36, 21),
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    controller: search_controller,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.grey.shade500),
                      labelText: 'Search here...',
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  setState(() {});
                },
                child: Container(
                  //width: 80,

                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(8)),
                  child: Center(
                    child: Text(
                      'Search',
                      style: TextStyle(
                          color: const Color.fromRGBO(255, 255, 255, 1)),
                    ),
                  ),
                ),
              ),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .where("email", isEqualTo: search_controller.text)
                      .where("email", isNotEqualTo: widget.userModel.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot dataSnapshot =
                            snapshot.data as QuerySnapshot;

                        if (dataSnapshot.docs.length > 0) {
                          Map<String, dynamic> userMap = dataSnapshot.docs[0]
                              .data() as Map<String, dynamic>;

                          UserModel searchedUser = UserModel.fromMap(userMap);

                          return ListTile(
                            onTap: () async {
                              ChatRoomModel? chatRoomModel =
                                  await getchatroom(searchedUser);
                              if (chatRoomModel != null) {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return Chatroom(
                                      targetUsr: searchedUser,
                                      userModel: widget.userModel,
                                      firebaseUser: widget.firebaseUser,
                                      chatroom: chatRoomModel,
                                    );
                                  },
                                ));
                              }
                            },
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(searchedUser.profilepic!),
                            ),
                            title: Text(
                              searchedUser.fullname!,
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(searchedUser.email!,
                                style: TextStyle(color: Colors.white)),
                            trailing: Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.white,
                            ),
                          );
                        } else {
                          return Text(
                            "No results found!",
                            style: TextStyle(color: Colors.white),
                          );
                        }
                      } else if (snapshot.hasError) {
                        return Text("An error occured!",
                            style: TextStyle(color: Colors.white));
                      } else {
                        return Text("No results found!",
                            style: TextStyle(color: Colors.white));
                      }
                    } else {
                      return CircularProgressIndicator();
                    }
                  }),
            ],
          ),
        ),
      )),
    );
  }
}
