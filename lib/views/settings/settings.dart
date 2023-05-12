import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hailo/core/common.dart';
import 'package:hailo/core/constants/colors.dart';
import 'package:hailo/views/settings/settingScreens/ListOfPaymentMethods.dart';
import 'package:hailo/views/settings/settingScreens/email.dart';
import 'package:hailo/views/settings/settingScreens/location.dart';
import 'package:hailo/views/settings/settingScreens/password.dart';
import 'package:hailo/views/settings/settingScreens/payment.dart';
import 'package:hailo/views/settings/settingScreens/profiles/editprofiles.dart';
import 'package:hailo/views/settings/settingScreens/profiles/selectprofile.dart';
import 'package:hailo/views/settings/supportChat.dart';
import 'package:sizer/sizer.dart';

import '../../../core/constants/collections.dart';
import '../../../core/utils/common.dart';
import '../../core/bindings.dart';
import '../login.dart';

class SettingSt extends StatefulWidget {
  final String uid;
  const SettingSt({Key? key, required this.uid}) : super(key: key);

  @override
  State<SettingSt> createState() => _SettingStState();
}

class _SettingStState extends State<SettingSt> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: StreamBuilder< DocumentSnapshot>(
          stream: usersCollection.doc(widget.uid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return customProgressIndicator();
            DocumentSnapshot udata = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: udata["profilePicture"].isEmpty
                          ? Image.asset(
                              "assets/placeholderProfile.png",
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                            )
                          : CachedNetworkImage(
                              imageUrl: udata["profilePicture"],
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                            ),
                    ),
                    title: Text(
                      "${udata["firstName"]}\n${udata["lastName"]}",
                      style: fontBody(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.logout),
                      color: kSecondaryColor,
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Get.offAllNamed("/login");
                      },
                    ),
                  ),
                  SizedBox(height: 20,),

                  //---- Profile, Password, Email........Profiles-------
                  ListTile(
                    onTap: () => Get.toNamed('/profile_settings',parameters:{"uid": udata.id, "profilePicture": udata["profilePicture"] }),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Color(0xffE5E5E5), width: 1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/profile.png',
                          height: 20,
                          width: 15,
                        ),
                      ],
                    ),
                    title: Text(
                      'Edit Account',
                      style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                    subtitle: Text(
                      'Change Name, Email and Password.',
                      style: fontBody(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          fontColor: const Color(0xffB7B7B7)),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: kPrimaryColor,
                      size: 13,
                    ),
                  ),
                  const SizedBox(
                    height: 7,
                  ),

                 /* //----Password---
                  ListTile(
                    onTap: () => Get.to(() => const Password() ),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Color(0xffE5E5E5), width: 1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/password_icon.png',
                          height: 20,
                          width: 15,
                        ),
                      ],
                    ),
                    title: Text(
                      'Password',
                      style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                    subtitle: Text(
                      'Change Password',
                      style: fontBody(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          fontColor: const Color(0xffB7B7B7)),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: kPrimaryColor,
                      size: 13,
                    ),
                  ),
                  const SizedBox(
                    height: 7,
                  ),

                  //----Email---
                  ListTile(
                    onTap: () => Get.to(() =>Email() ),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Color(0xffE5E5E5), width: 1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/email_icon.png',
                          height: 20,
                          width: 15,
                        ),
                      ],
                    ),
                    title: Text(
                      'Email',
                      style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                    subtitle: Text(
                      'Subscription option',
                      style: fontBody(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          fontColor: const Color(0xffB7B7B7)),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: kPrimaryColor,
                      size: 13,
                    ),
                  ),
                  const SizedBox(
                    height: 7,
                  ),*/

                  //--- Location

                  ListTile(
                    onTap: () => Get.to(() =>CardListScreen(userId: widget.uid,) ),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Color(0xffE5E5E5), width: 1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/payment_icon.png',
                          height: 20,
                          width: 15,
                        ),
                      ],
                    ),
                    title: Text(
                      'Payment',
                      style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                    subtitle: Text(
                      'See and edit payment metho..',
                      style: fontBody(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          fontColor: const Color(0xffB7B7B7)),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: kPrimaryColor,
                      size: 13,
                    ),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  ListTile(
                    onTap: () => Get.to(() =>EditProfiles() ),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Color(0xffE5E5E5), width: 1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/profileheart_icon.png',
                          height: 20,
                          width: 15,
                          color: kPrimaryColor,
                        ),
                      ],
                    ),
                    title: Text(
                      'Profiles',
                      style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                    subtitle: Text(
                      'Edit or create new profile',
                      style: fontBody(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          fontColor: const Color(0xffB7B7B7)),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: kPrimaryColor,
                      size: 13,
                    ),
                  ),
                  SizedBox(height: 10,),

                  //Support
                  ListTile(
                    onTap: () async {
                      await chatSupportCollection.doc(widget.uid).set({
                        "chatStarted": true,
                        "lastMessageAt" :DateTime.now()
                      });
                      Get.toNamed("/supportChat", parameters: {"uid": widget.uid,});
                    },
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Color(0xffE5E5E5), width: 1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/chat.png',
                          height: 16,
                          width: 12.8,
                          color: kPrimaryColor,
                        ),
                      ],
                    ),
                    title: Text(
                      'Support',
                      style:
                      fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                    subtitle: Text(
                      '24 hours Chat support',
                      style: fontBody(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          fontColor: const Color(0xffB7B7B7)),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: kPrimaryColor,
                      size: 13,
                    ),
                  ),
                  SizedBox(height: 23.h,),
                  InkWell(
                    onTap: (){
                      Get.defaultDialog(title: 'Are you sure?',middleText: 'This will delete all the data that your account contains including any payments and orders.',

                        confirm: ElevatedButton(onPressed: () async {
                          Get.back();
                          await usersCollection.doc(widget.uid).delete();
                          await FirebaseAuth.instance.currentUser!.delete();
                          Get.offAll(()=>Login(),binding: LoginBinding());

                          customToast('Deleted');
                        }, child: Text('Done'),style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red),),),
                        cancel: TextButton(onPressed: (){
                          Get.back();
                        }, child: Text('Cancel',style: fontBody(fontColor: kPrimaryColor,fontSize: 14),)),
                      );
                    },
                    child: Center(
                      child: Container(
                        height: 6.h,
                        width: 70.w,
                        decoration: BoxDecoration(
                            color: Colors.red,

                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.delete,color: Colors.white,size: 24,),
                                Text('Delete Account',style: fontBody(fontColor: Colors.white,fontSize: 16
                                ),),
                                SizedBox(width: 10,)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )



                ],
              ),
            );
          }),
    );
  }
}

