import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../core/common.dart';
import '../core/constants/collections.dart';
import '../core/constants/colors.dart';
import 'package:get/get.dart';
import '../views/model.dart';

class ChatsController extends GetxController {
  String? uid = Get.parameters["uid"],
      fid = Get.parameters["fid"],
      chatID = Get.parameters["chatID"];
  RxBool isTyping = false.obs;

  final TextEditingController messageController = TextEditingController();
  final lastChats = <Chat>[].obs;

  RxString showTimeID = "".obs;

  @override
  void onInit() {
    print(fid);
    lastChats.bindStream(fetchLastChats());
    super.onInit();
  }

  Stream<List<Chat>> fetchLastChats() {
    Stream<QuerySnapshot> stream = chatsCollection
        .doc(chatID)
        .collection("chats")
        .orderBy("sentOn", descending: true)
        .limit(20)
        .snapshots();
    var res = stream.map(
            (qShot) => qShot.docs.map((doc) => Chat.fromDocument(doc)).toList());
    return res;
  }

  sendMessage() async {
    if(messageController.text.isEmpty) return;
    await chatsCollection.doc(chatID).collection("chats").add({
      "message": messageController.text.trim(),
      "type": "text",
      "sentBy": uid!,
      "sentOn": DateTime.now(),
    });
    messageController.clear();
  }

  senderView(Chat chat) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints:
          BoxConstraints(minWidth: 50, maxWidth: Get.width / 1.5),
          child: GestureDetector(
            onTap: () {
              if (showTimeID.value == chat.chatID) {
                showTimeID.value = "";
                return;
              }
              showTimeID.value = chat.chatID;
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20)),
              ),
              child: Text(
                chat.message,
                style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ),
      ),
      Obx(
            () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInCirc,
          switchOutCurve: Curves.easeOutExpo,
          child: showTimeID.value == chat.chatID
              ? Text(
            DateFormat("hh:mm a").format(chat.sentOn.toDate()),
            style: fontBody(
                fontColor: const Color(0xff9FB5C6),
                fontSize: 10,
                fontWeight: FontWeight.w400),
          )
              : const SizedBox.shrink(),
        ),
      ),
    ],
  );

  receiverView(Chat chat) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints:
          BoxConstraints(minWidth: 0, maxWidth: Get.width / 1.5),
          child: GestureDetector(
            onTap: () {
              if (showTimeID.value == chat.chatID) {
                showTimeID.value = "";
                return;
              }
              showTimeID.value = chat.chatID;
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: kLightGreyColor),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
              ),
              child: Text(
                chat.message,
                style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ),
      ),
      Obx(
            () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInCirc,
          switchOutCurve: Curves.easeOutExpo,
          child: showTimeID.value == chat.chatID
              ? Text(
            DateFormat("hh:mm a").format(chat.sentOn.toDate()),
            style: fontBody(
                fontColor: const Color(0xff9FB5C6),
                fontSize: 10,
                fontWeight: FontWeight.w400),
          )
              : const SizedBox.shrink(),
        ),
      ),
    ],
  );

  @override
  void onReady() async {
    await usersCollection
        .doc(uid!)
        .collection("messages")
        .doc(fid!)
        .update({
      "unreadCount": 0,
    });
    super.onReady();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
