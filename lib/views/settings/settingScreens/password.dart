import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/form_validators.dart';

class Password extends StatefulWidget {
  const Password({Key? key}) : super(key: key);

  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future resetpassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            elevation: 10,
            icon:Icon( Icons.check_circle_rounded,size: 35,),
            iconColor: Colors.greenAccent,
            content: Text("Password reset link sent! Check your email.",style: TextStyle(fontFamily: "Poppins",fontSize: 15),),
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            //backgroundColor: Colors.red.shade100,
            elevation: 10,
            icon:Icon( Icons.warning,size: 35,),
            iconColor: Colors.red,
            content: Text(e.message.toString(),style: TextStyle(fontFamily: "Poppins",fontSize: 15),),
          );
        },
      );
    }
  }

  @override
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
          'Password Settings',
          style: fontBody(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const SizedBox(
                height: 39,
              ),
              Text("Enter your email address for the reset link :",style: TextStyle(fontFamily: "Poppins",fontSize: 20,fontWeight: FontWeight.w300),),
              const SizedBox(
                height: 39,
              ),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: fontBody(fontSize: 16, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff000000), width: 2)),
                ),
                validator: emailValidator,
              ),
              const SizedBox(
                height: 338,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                ),
                  onPressed: () async {
                    await resetpassword();
                  },
                  child: Text("Save",style: TextStyle(fontFamily: "Poppins",fontSize: 20),)),
              const SizedBox(
                height: 360,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
