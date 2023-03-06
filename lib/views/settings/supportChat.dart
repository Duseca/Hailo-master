import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

import '../../controller/supportChat_controller.dart';
import '../../core/common.dart';
import '../../core/constants/colors.dart';
import '../supportmodel.dart';

class supportChat extends GetView<supportChatController> {
   supportChat({Key? key,}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: kWhiteColor,
          ),
        ),
        title: Text("Hailo Support", style: fontBody(fontColor: kWhiteColor, fontSize: 20, fontWeight: FontWeight.w500)),
        centerTitle: true,
        
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
                  () => LazyLoadScrollView(
                onEndOfPage: () {},
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  reverse: true,
                  itemBuilder: (context, index) {
                    SupportChat chat = controller.lastChats[index];
                    return chat.sentBy == controller.uid! ? controller.senderView(chat) : controller.receiverView(chat);
                  },
                  separatorBuilder: (c, s) => const SizedBox(height: 15),
                  itemCount: controller.lastChats.length,
                ),
              ),
            ),
          ),
          Container(
            height: kBottomNavigationBarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            width: context.width,

            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.messageController,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        controller.isTyping.value = false;
                      } else {
                        controller.isTyping.value = true;
                      }
                    },
                    style: fontBody(fontSize: 15, fontWeight: FontWeight.w400),
                    decoration: InputDecoration(
                      hintText: "How can we help you ?",
                      hintStyle: fontBody(fontColor: kBlackColor.withOpacity(0.3),fontSize: 15, fontWeight: FontWeight.w400),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
                      enabledBorder:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: kPrimaryColor, width: 2)),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                InkWell(
                  onTap: () => controller.sendMessage(),
                  child: Container(
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: kPrimaryColor), child: Image.asset("assets/send1.png", width: 40)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
  }

