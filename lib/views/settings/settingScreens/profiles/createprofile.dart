import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hailo/views//settings/settingScreens/profiles/profiledetails.dart';

import '../../../../../core/constants/colors.dart';

class CreateProfile extends StatefulWidget {
  CreateProfile({Key? key}) : super(key: key);

  @override
  State<CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  String userType = '';
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: kPrimaryColor,
          ),
          onPressed: Get.back,
        ),
        title: Center(
            child: Text(
          "Create a New Profile",
          style: TextStyle(fontFamily: "Poppins", fontSize: 24, letterSpacing: 1),
        )),
      ),
      body: Center(
        child: Wrap(
          children: List.generate(2, (index) {
            return InkWell(
              onTap: () {

                setState(() {
                  selectedIndex = index;
                  if(selectedIndex==0)
                    userType ='Myself';
                  if(selectedIndex==1)
                    userType ='Friends';
                });
                Get.off(() =>ProfileDetails(),arguments: [userType]);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: index == 0
                      ? BoxDecoration(
                          color: Colors.teal.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(9),
                        )
                      : BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(9),
                        ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      index == 0
                          ? Image.asset(
                              'assets/user_love_icon.png',
                              width: 50,
                              height: 50,
                            )
                          : Image.asset(
                              'assets/care.png',
                              color: Colors.redAccent,
                              width: 50,
                              height: 50,
                            ),
                      SizedBox(
                        height: 20,
                      ),
                      index == 0
                          ? Text(
                              "Myself",
                              style: TextStyle(fontSize: 20, color: Colors.teal.shade300, fontFamily: "Poppins", fontWeight: FontWeight.w500),
                            )
                          : Text(
                              "Friends\n or Family",
                              style: TextStyle(fontSize: 20, color: Colors.redAccent, fontFamily: "Poppins", fontWeight: FontWeight.w500),
                            )
                    ],
                  ),
                ),
              ),
            );
          }

              ),
        ),
      ),
    );
  }
}
