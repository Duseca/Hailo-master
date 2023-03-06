import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hailo/views/settings/settingScreens/password.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../controller/profile_controller.dart';
import '../../../../core/common.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/form_validators.dart';
import 'email.dart';

class ProfileSetting extends GetView<ProfileController> {
   ProfileSetting({super.key});




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: kPrimaryColor,
          ),
          onPressed: Get.back,
        ),
        title: Text(
          'Edit Account',
          style: fontBody(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 57),
        child: Form(
          key: controller.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            children: [
              const SizedBox(
                height: 39,
              ),

              Align(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    Obx(() => ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: controller.imagePath.value.isEmpty
                          ? CachedNetworkImage(
                        imageUrl: controller.profilePicture!,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                      )
                          : Image.file(File(controller.imagePath.value),  width: 120,
                          height: 120, fit: BoxFit.cover),
                    ),),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: controller.openImageSelect,
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: kPrimaryColor),
                            child: Icon(Icons.edit, color: kWhiteColor,size: 18,)
                          ),
                        ))
                  ],
                ),
              ),

              const SizedBox(
                height: 39,
              ),


              //---- First Name
              TextFormField(
                controller: controller.firstnameController,
                keyboardType: TextInputType.name,
                style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  labelText: "First Name",
                  labelStyle: fontBody(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontColor: const Color(0xffB7B7B7)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                      const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                      const BorderSide(color: Color(0xff000000), width: 2)),
                ),
                validator: nameValidator,
              ),
              const SizedBox(height: 22),

              //---- Last Name
              TextFormField(
                controller: controller.lastnameController,
                keyboardType: TextInputType.name,
                style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  labelText: "Last Name",
                  labelStyle: fontBody(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontColor: const Color(0xffB7B7B7)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                      const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                      const BorderSide(color: Color(0xff000000), width: 2)),
                ),
                validator: nameValidator,
              ),
              const SizedBox(
                height: 38,
              ),
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

              const SizedBox(height: 22),

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
              const SizedBox(height: 80),


              //--- Save Button
              GestureDetector(
                onTap: () => controller.save(),
                child: Container(
                  height: 50,
                  width: 194,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      color: kPrimaryColor),
                  child: Center(
                      child: Text(
                        'Save',
                        style: fontBody(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            fontColor: kWhiteColor),
                      )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

