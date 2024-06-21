import 'package:chat/Theme/Colors.dart';
import 'package:chat/models/ChatroomModel.dart';
import 'package:chat/models/FirebaseHelper.dart';
import 'package:chat/models/MessageModel.dart';
import 'package:chat/models/UserModel.dart';
import 'package:chat/pages/chatroom_page.dart';
import 'package:chat/pages/login_page.dart';
import 'package:chat/pages/profile_page.dart';
import 'package:chat/pages/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return CompleteProfile(
                          userModel: widget.userModel,
                          firebaseUser: widget.firebaseUser);
                    },
                  ));
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      NetworkImage(widget.userModel.profilepic.toString()),
                ),
              ),
            )
          ],
          title: Center(
            child: Text(
              "CHATIFY",
              style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                  decoration: BoxDecoration(color: Colors.black),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(
                                widget.userModel.profilepic.toString(),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.userModel.fullname.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 22),
                                ),
                                Text(widget.userModel.email.toString(),
                                    style: TextStyle(color: Colors.white))
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  )),
              ListTile(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return LoginPage();
                    },
                  ));
                },
                leading: Icon(
                  Icons.logout_outlined,
                  color: Colors.white,
                ),
                title: Text(
                  "Logout",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: primaryColor,
        ),
        body: SafeArea(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chatrooms")
                .where("users", arrayContains: widget.userModel.uid)
                .orderBy("createdon")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatRoomSnapshot =
                      snapshot.data as QuerySnapshot;

                  return ListView.builder(
                    itemCount: chatRoomSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                          chatRoomSnapshot.docs[index].data()
                              as Map<String, dynamic>);

                      Map<String, dynamic> participants =
                          chatRoomModel.participants!;

                      List<String> participantKeys = participants.keys.toList();
                      participantKeys.remove(widget.userModel.uid);

                      return FutureBuilder(
                        future:
                            FirebaseHelper.getUserModelById(participantKeys[0]),
                        builder: (context, userData) {
                          if (userData.connectionState ==
                              ConnectionState.done) {
                            if (userData.data != null) {
                              UserModel targetUser = userData.data as UserModel;

                              return ListTile(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return Chatroom(
                                          targetUsr: targetUser,
                                          chatroom: chatRoomModel,
                                          userModel: widget.userModel,
                                          firebaseUser: widget.firebaseUser);
                                    },
                                  ));
                                },
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      targetUser.profilepic.toString()),
                                ),
                                title: Text(
                                  targetUser.fullname.toString(),
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: (chatRoomModel.lastMessage
                                            .toString() !=
                                        "")
                                    ? Text(
                                        chatRoomModel.lastMessage.toString(),
                                        style: TextStyle(color: Colors.white),
                                      )
                                    : Text(
                                        "Say hi to your friend",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                trailing: Text(
                                  chatRoomModel.createdon.toString(),
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              );
                            } else {
                              return Container();
                            }
                          } else {
                            return Container();
                          }
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return Center(
                    child: Text("No Chats"),
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return SearchPage(
                  userModel: widget.userModel,
                  firebaseUser: widget.firebaseUser,
                );
              },
            ));
          },
          backgroundColor: secondaryColor,
          child: Icon(
            Icons.search,
            color: primaryColor,
          ),
        ));
  }
}
