import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hailo/core/common.dart';
import 'package:hailo/core/constants/colors.dart';
import '../controller/splash_controller.dart';

class Splash extends GetView<SplashController> {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Center(
        child: Image.asset("assets/hailoLOGO.png",)
      ),
    );
  }
}
