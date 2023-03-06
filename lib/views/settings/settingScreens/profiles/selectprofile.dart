import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hailo/views//settings/settingScreens/profiles/editprofiles.dart';

import '../../../../../core/common.dart';
import '../../../../../core/constants/colors.dart';

class SelectProfile extends StatelessWidget {
  const SelectProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar :  AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: kPrimaryColor,
          ),
          onPressed: Get.back,
        ),
        title: Text(
          'Select Profiles',
          style: fontBody(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 22.0,right:22.0),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 150,),
              ProfileContainer(profiletype: "Dad",),
              SizedBox(height: 20,),
              ProfileContainer(profiletype: "Mom",),
              SizedBox(height: 20,),
              ProfileContainer(profiletype: "Myself",),

              SizedBox(height: 90,),
              GestureDetector(
                onTap: () => Get.to(() => EditProfiles() ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(0xFF49DDC4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text("Create a New Profile",style: TextStyle(fontSize: 18,fontFamily: "Poppins",color: Colors.white),),
                  ),

                ),
              )

            ],
          ),
      ),
      );
  }
}

class ProfileContainer extends StatefulWidget {
   ProfileContainer({Key? key, required this.profiletype}) : super(key: key);

  String profiletype;

  @override
  State<ProfileContainer> createState() => _ProfileContainerState();
}

class _ProfileContainerState extends State<ProfileContainer> {



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.80,
        height: 60,
        decoration: BoxDecoration(
          color: Color(0xFFFF7991),
          borderRadius: BorderRadius.circular(8),

        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(Icons.account_circle_outlined,color: Colors.white,),
              SizedBox(width: 30,),
              Text(widget.profiletype,style: TextStyle(fontFamily: "Poppins",fontSize: 20,color: Colors.white),)
            ],
          ),
        ),
      ),
    );
  }
}
