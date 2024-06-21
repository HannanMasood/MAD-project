import 'package:chat/Theme/Colors.dart';
import 'package:chat/models/UIHelper.dart';
import 'package:chat/models/UserModel.dart';
import 'package:chat/pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController email_controller = TextEditingController();

  TextEditingController pass_controller = TextEditingController();

  TextEditingController cpass_controller = TextEditingController();

  void checkvalue() {
    String email = email_controller.text;

    String pass = email_controller.text;

    String cpass = email_controller.text;

    if (email == "" || pass == "" || cpass == "") {
      print("Invalid");
    } else if (pass != cpass) {
      print("Error in Confirm password field");
    } else {
      signup(email, pass);
    }
  }

  void signup(String email, String password) async {
    UserCredential? credential;
    UIHelper.showLoadingDialog(context, "Signing In..");
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      print(ex.code.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser =
          UserModel(uid: uid, fullname: "", email: email, profilepic: "");
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        print("New User Created");
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return CompleteProfile(
                userModel: newUser, firebaseUser: credential!.user!);
          },
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 80),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 100),
            child: Center(
              child: Column(
                children: [
                  Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                  SizedBox(
                    height: 80,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 21, 36, 21),
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        controller: email_controller,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.grey.shade500),
                          labelText: 'Email',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 21, 36, 21),
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        obscureText: true,
                        controller: pass_controller,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.grey.shade500),
                          labelText: 'Password',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 21, 36, 21),
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        controller: cpass_controller,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.grey.shade500),
                          labelText: 'Confirm Password',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  GestureDetector(
                    onTap: () {
                      checkvalue();
                    },
                    child: Container(
                      //width: 80,

                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: secondaryColor,
                          borderRadius: BorderRadius.circular(8)),
                      child: Center(
                        child: Text(
                          'Signup',
                          style: TextStyle(
                              color: const Color.fromRGBO(255, 255, 255, 1)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account ?",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'login',
                          style: TextStyle(
                              color: secondaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
