import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../core/common.dart';
import '../core/utils/progress_dialog_utils.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController(), passwordController = TextEditingController();

  emailLogin() async {
    if (!formKey.currentState!.validate()) return;
    ProgressDialogUtils.showProgressDialog();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text).then((value) {
        String uid = value.user!.uid;
        customToast("Welcome");
        Get.offAllNamed("/root", parameters: {"uid": uid});
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
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
