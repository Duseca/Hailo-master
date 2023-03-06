import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/common.dart';
import '../core/constants/colors.dart';
import '../core/utils/form_validators.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  linkPathao() async {
    if (emailController.text.isEmpty) {
      customToast("Please enter your registered email");
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
      customToast("Reset link sent to ${emailController.text}");
      Get.back();
    } on FirebaseAuthException catch (e) {
      customToast(e.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          color: kPrimaryColor,
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text("Reset Password"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(25),
        children: [
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
            decoration: InputDecoration(
              labelText: "Email",
              labelStyle: fontBody(fontSize: 16, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
              prefixIcon: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/email_icon.png", width: 20),
                ],
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff000000), width: 2)),
            ),
            validator: emailValidator,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => linkPathao(),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text("Send reset Link", style: fontBody(fontSize: 18, fontColor: kWhiteColor, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
