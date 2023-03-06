import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:remixicon/remixicon.dart';
import '../controller/chat_controller.dart';
import '../core/common.dart';
import '../core/constants/collections.dart';
import '../core/constants/colors.dart';
import 'package:hailo/views/model.dart';

class Chats extends GetView<ChatsController> {
  const Chats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.only(left: 20),
            decoration: const ShapeDecoration(shape: CircleBorder(), color: Colors.white10),
            child: const Icon(Icons.arrow_back_ios_new, color: kPrimaryColor),
          ),
        ),
        title: StreamBuilder<DocumentSnapshot>(
            stream: careTakersCollection.doc(controller.fid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              DocumentSnapshot udoc = snapshot.data!;

              return ListTile(
                onTap: () => Get.back(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                leading: Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: udoc["profilePicture"],
                      errorWidget: (c, s, d) => Image.asset('assets/placeholderProfile.png'),
                      placeholder: (c, s) => Image.asset('assets/placeholderProfile.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(
                  udoc["firstName"],
                  style: fontBody(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                // subtitle: Text(
                //   udoc["activeNow"]
                //       ? "Online"
                //       : "Active ${time_ago.format(udoc["lastActive"].toDate())}",
                //   style: fontBody(
                //       fontSize: 12,
                //       fontWeight: FontWeight.w400,
                //       fontColor: const Color(0xff9FB5C6)),
                // ),
              );
            }),
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
                    Chat chat = controller.lastChats[index];
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
            padding: const EdgeInsets.symmetric(horizontal: 25),
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
                      hintText: "Say something nice...",
                      hintStyle: fontBody(fontSize: 15, fontWeight: FontWeight.w400),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
                      enabledBorder:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: kPrimaryColor, width: 2)),
                    ),
                  ),
                ),
                Obx(
                  () => controller.isTyping.value
                      ? const SizedBox.shrink()
                      : IconButton(
                          onPressed: () => {},
                          icon: const Icon(Remix.attachment_2),
                        ),
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

/*Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        elevation: 1,
        leadingWidth: 110,
        leading: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 15,
              ),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(Icons.arrow_back_ios,color: Colors.tealAccent,)
                ),
              ),
            const CircleAvatar(backgroundImage:AssetImage('assets/avatar.png')),
            ]
        ),
        title: const Text("Samuel Jackson"),
        actions: const [
          Icon(Icons.more_vert),
        ],

      ),
      body: Stack(
        children: [
          ListView.builder(
            shrinkWrap: true,
            padding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              */ /*var data = controller.getDummyMsg[index];*/ /*
              return ChatBubble(
                msg: "Hi! How are you?",
                time: "12:00 pm",
                isSeen: true,
                senderType: 'receiver',
                name: 'Samuel Jackson',
              );
            },
          ),

         // -----Below 'Write Message' Box---
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              width: double.infinity,
              decoration:  BoxDecoration(
                color: Colors.white,
                boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                  offset: const Offset(7.0,0.8)
              ),
            ],
          ),
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0,left: 8.0),
                child: Row(
                  children: <Widget>[
                    const SizedBox(width: 15,),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                            hintText: "Write message...",
                            hintStyle: TextStyle(color: Colors.black54),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)
                            ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15,),

                    FloatingActionButton(
                      onPressed: (){},
                      backgroundColor: Colors.tealAccent.shade400,
                      elevation: 0,
                      child: const Icon(Icons.send,color: Colors.white,size: 30),
                    ),
                  ],

                ),
              ),
            ),
          )
        ],
      ),
    );*/

/*class ChatBubble extends StatelessWidget {
  ChatBubble({Key? key, required this.name, required this.time, required this.msg,required this.isSeen, required this.senderType}) : super(key: key);
  String time,senderType,msg,name;
  bool? isSeen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child:
      Align(
        alignment:
        senderType == 'receiver' ? Alignment.topLeft : Alignment.topRight,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ),

          decoration: BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: kBlackColor.withOpacity(0.08),
                offset: const Offset(0, 1),
                blurRadius: 4,
              ),
            ],
          ),
          margin: const EdgeInsets.only(bottom: 30),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10.0,
            children: [
              Text(msg),
              Text(time),
            ],
          ),
        ),
      ),

    );
  }
}*/
