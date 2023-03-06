import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hailo/controller/root_controller.dart';
import 'package:hailo/core/constants/colors.dart';

const List tabColor = [kPrimaryColor, kSecondaryColor, kPrimaryColor, kPrimaryColor];

class Root extends GetView<RootController> {
  const Root({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => controller.bodyWidgets[controller.currentTab.value]
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          elevation: 0,
          backgroundColor: kWhiteColor,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: false,
          showSelectedLabels: false,
          currentIndex: controller.currentTab.value,
          onTap: (v) => controller.changeTab(v),
          items: [
            BottomNavigationBarItem(icon: _buildIcon("assets/home.png",0), label: ""),
            BottomNavigationBarItem(icon: _buildIcon("assets/clock.png", 1), label: ""),
            BottomNavigationBarItem(icon: _buildIcon("assets/care.png", 2), label: ""),
            BottomNavigationBarItem(icon: _buildIcon("assets/chat.png", 3), label: ""),
          ],
        ),
      ),
    );
  }

  _buildIcon(String image, int index) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: index == controller.currentTab.value ? tabColor[index].withOpacity(0.2) : kWhiteColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Image.asset(image, color: index == controller.currentTab.value ? tabColor[index] : kBlackColor, width: 25),
    );
  }
}
