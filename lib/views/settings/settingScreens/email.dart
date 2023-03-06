import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../core/common.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/form_validators.dart';

class Email extends StatefulWidget {
  const Email({Key? key}) : super(key: key);


  @override
  State<Email> createState() => _EmailState();
}

class _EmailState extends State<Email> {

  bool _value = false;
  User? user = FirebaseAuth.instance.currentUser;
TextEditingController emailController=TextEditingController();
    TextEditingController passwordController=TextEditingController();

    @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }


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
          'Email Settings',
          style: fontBody(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 57),
          child: Column(
            children: [
              const SizedBox(
                height: 39,
              ),

              Padding(
                padding: const EdgeInsets.all(4),
                child: RichText(
                    text: TextSpan(
                        text: 'Your current email is:\n',
                        style: fontBody(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            fontColor: const Color(0xffB7B7B7)),
                        children: [
                          TextSpan(
                              text:  user?.email,
                              style: fontBody(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  fontColor: kPrimaryColor))
                        ])),
              ),
              const SizedBox(
                height: 39,
              ),

              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.name,
                style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  labelText: "New Email",
                  labelStyle: fontBody(fontSize: 16, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff000000), width: 2)),
                ),
                validator: nameValidator,
              ),
              const SizedBox(height: 22),
              //L name
              TextFormField(
                controller: passwordController,
                keyboardType: TextInputType.name,
                style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  labelText: "Password",

                  labelStyle: fontBody(fontSize: 16, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff000000), width: 2)),
                ),
                obscureText: true,
                validator: nameValidator,
              ),

              const SizedBox(
                height: 200,
              ),
              GestureDetector(
                onTap: ()async{
                    try {
                      await FirebaseAuth.instance.signInWithEmailAndPassword(email: user!.email!, password: passwordController.text).then((value)async {
                      try {
                        await FirebaseAuth.instance.currentUser!.updateEmail(emailController.text);
                      } on FirebaseAuthException catch (e) {
                        switch (e.code) {
                          case "email-already-in-use":
                            customToast("Account not found");
                            break;

                        }
                      }

                      });
                    } on FirebaseAuthException catch (e) {
                      switch (e.code) {
                        case "user-not-found":
                          customToast("Account not found");
                          break;
                        case "wrong-password":
                          customToast("Wrong password");
                          break;
                        case "invalid-email":
                          customToast("Invalid email format");
                          break;
                      }
                    }
                    Get.back();
                  },

                child: Container(
                  height: 50,
                  width: 194,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), color: kPrimaryColor),
                  child: Center(
                      child: Text(
                        'Save',
                        style: fontBody(fontSize: 18, fontWeight: FontWeight.w500, fontColor: kWhiteColor),
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

