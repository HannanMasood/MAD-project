import 'dart:io';
import 'package:chat/Theme/Colors.dart';
import 'package:chat/models/UIHelper.dart';
import 'package:chat/models/UserModel.dart';
import 'package:chat/pages/Home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfile(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  _CompleteProfileState createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  TextEditingController fullname_controller = TextEditingController();

  File? imageFile;
  TextEditingController fullNameController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      cropImage(pickedFile);
      print("successfully");
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 20);

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Upload Profile Picture"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  leading: Icon(Icons.photo_album),
                  title: Text("Select from Gallery"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                  leading: Icon(Icons.camera_alt),
                  title: Text("Take a photo"),
                ),
              ],
            ),
          );
        });
  }

  void checkvalues() {
    String fullname = fullname_controller.text.trim();

    if (fullname == "" || imageFile == null) {
      print('All fields are required');
    } else {
      uploadData();
    }
  }

  void uploadData() async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepicture")
        .child(widget.userModel!.uid.toString())
        .putFile(imageFile!);
    UIHelper.showLoadingDialog(context, "Loading..");
    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();
    String fullname = fullname_controller.text.trim();

    widget.userModel.fullname = fullname;
    widget.userModel.profilepic = imageUrl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      print('Data Uploaded');

      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return HomePage(
            userModel: widget.userModel,
            firebaseUser: widget.firebaseUser,
          );
        },
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: ListView(
              children: [
                SizedBox(
                  height: 20,
                ),
                CupertinoButton(
                  onPressed: () {
                    showPhotoOptions();
                  },
                  padding: EdgeInsets.all(0),
                  child: Stack(children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey.shade500,
                      radius: 60,
                      backgroundImage:
                          (imageFile != null) ? FileImage(imageFile!) : null,
                      child: (imageFile == null)
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    Positioned(
                      top: 80,
                      right: 5,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            color: secondaryColor),
                        child: Center(
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  ]),
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 21, 36, 21),
                      borderRadius: BorderRadius.circular(8)),
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      controller: fullname_controller,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        labelStyle: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    checkvalues();
                  },
                  child: Container(
                    //width: 80,

                    margin: EdgeInsets.symmetric(horizontal: 10),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Text(
                        'Submit',
                        style: TextStyle(
                            color: const Color.fromRGBO(255, 255, 255, 1)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
