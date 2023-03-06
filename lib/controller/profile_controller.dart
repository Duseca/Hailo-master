import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hailo/core/constants/colors.dart';
import 'package:image_picker/image_picker.dart';
import '../core/common.dart';
import '../core/constants/collections.dart';

class ProfileController extends GetxController {


  String? uid = Get.parameters["uid"];
  String? profilePicture = Get.parameters["profilePicture"];
  final formKey = GlobalKey<FormState>();
  final ImagePicker imagePicker = ImagePicker();
  var imageName = "".obs, imageSize = 0, imagePath = "".obs;

  String image="";


  final TextEditingController firstnameController = TextEditingController(),
      lastnameController = TextEditingController();


  getUser() async{
    var doc = await usersCollection.doc(uid).get();
    firstnameController.text = doc['firstName'];
    lastnameController.text = doc['lastName'];
    image = doc['profilePicture'];



  }
  void pickImage({bool gallery = false}) async {
    final XFile? image = await imagePicker.pickImage(source: gallery ? ImageSource.gallery : ImageSource.camera);
    if (image == null) return;
    imageSize = await image.length() ~/ 1000;
    if (imageSize > 5400) {
      customToast("Max file limit exceeds");
      return;
    }

      imageName.value = image.name;
      imagePath.value = image.path;
  }

  void openImageSelect() => Get.defaultDialog(
      title: "Select Profile Picture",
      titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kPrimaryColor),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            onTap: () {
              pickImage(gallery: true);
              Get.back();
            },
            title: const Text("Open Gallery", style: TextStyle(fontSize: 15)),
          ),
          ListTile(
            onTap: () {
              pickImage();
              Get.back();
            },
            title: const Text("Open Camera", style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
      backgroundColor: Colors.white);

  save() async {
    final String firstname = firstnameController.text;
    final String lastname = lastnameController.text;

    if (!formKey.currentState!.validate()) return;

    String? imageURL = image;

    if (imagePath.isNotEmpty) {
      final storageRef = FirebaseStorage.instance.ref();

      String ext = imagePath.split(".").last;
      int fileName = DateTime.now().millisecondsSinceEpoch;

      try {
        final postRef = storageRef.child("company/$uid/pp_$fileName.$ext");
        await postRef.putFile(File(imagePath.value));
        imageURL = await postRef.getDownloadURL();
      } on FirebaseException catch (e) {
        customToast(e.code);
      }
    }

    await usersCollection
        .doc(uid)
        .update({
      "firstName": firstname,
      "lastName": lastname,
      "profilePicture": imageURL,
        });

    customToast(" Profile updated successfully!",);


    Get.back();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    getUser();


    super.onInit();
  }



  @override
  void onClose() {
    firstnameController.dispose();
    lastnameController.dispose();
    super.onClose();
  }
}
