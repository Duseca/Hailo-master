import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hailo/controller/login_controller.dart';
import 'package:hailo/core/constants/colors.dart';
import 'package:hailo/core/utils/form_validators.dart';
import 'package:hailo/views/reset_password.dart';

import '../core/common.dart';

class Login extends GetView<LoginController> {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: context.mediaQueryViewInsets.bottom == 0
          ? null
          : FloatingActionButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
              },
              backgroundColor: kWhiteColor,
              child: const Icon(
                Icons.keyboard_hide_rounded,
                color: kPrimaryColor,
              ),
            ),
      body: Stack(
        children: [
          Positioned(
            right: 0,
            top: kToolbarHeight - 20,
            child: Image.asset("assets/login_image.png", width: context.width / 2.5),
          ),
          ListView(
            padding: const EdgeInsets.all(32),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: context.width / 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 25),
                        child: Text(
                          "Hailo",
                          style: fontBody(fontSize: 24, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        "Already have an account?",
                        style: fontBody(fontSize: 24, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 70),
              Form(
                key: controller.formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: controller.emailController,
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
                        enabledBorder:
                            OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                        focusedBorder:
                            OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff000000), width: 2)),
                      ),
                      validator: emailValidator,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: controller.passwordController,
                      obscureText: true,
                      style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: fontBody(fontSize: 16, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                        prefixIcon: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/password_icon.png", width: 20),
                          ],
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        enabledBorder:
                            OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                        focusedBorder:
                            OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff000000), width: 2)),
                      ),
                      validator: passwordValidator,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => controller.emailLogin(),
                      style: ElevatedButton.styleFrom(
                        primary: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text("Login", style: fontBody(fontSize: 18, fontColor: kWhiteColor, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 50),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(style: fontBody(fontSize: 16), children: [
                    const TextSpan(text: "Forget Password? ", style: TextStyle(color: Color(0xffD8D8D8))),
                    TextSpan(
                      text: "Reset",
                      recognizer: TapGestureRecognizer()..onTap = () => Get.to(()=>ResetPassword()),
                      style: const TextStyle(color: Color(0xff49DDC4), decoration: TextDecoration.underline),
                    ),
                  ]),
                ),
              ),
              Row(
                children: [
                  const Expanded(
                    child: Divider(
                      color: const Color(0xffC4C4C4),
                      thickness: 3,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text("OR", style: fontBody(fontSize: 18, fontColor: const Color(0xffC4C4C4))),
                  ),
                  const Expanded(
                    child: Divider(
                      color: Color(0xffC4C4C4),
                      thickness: 3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () => Get.toNamed("/signup"),
                style: ElevatedButton.styleFrom(
                  primary: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text("Signup", style: fontBody(fontSize: 18, fontColor: kWhiteColor, fontWeight: FontWeight.w500)),
              ),
            /*  Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 50),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(style: fontBody(fontSize: 16), children: [
                    const TextSpan(text: "Don't have an account? ", style: TextStyle(color: Color(0xffD8D8D8))),
                    TextSpan(
                      text: "Sign Up",
                      recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed("/signup"),
                      style: const TextStyle(color: Color(0xff49DDC4), decoration: TextDecoration.underline),
                    ),
                  ]),
                ),
              ),*/
              /* ListTile(
                onTap: () => customToast("Coming soon"),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: const Color(0xffFF7991))),
                leading: Image.asset("assets/google.png", width: 20),
                title: Text("Login with Google", textAlign: TextAlign.center, style: fontBody(fontSize: 18, fontColor: const Color(0xffFF7991))),
              )*/
            ],
          ),
        ],
      ),
    );
  }
}
