import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hailo/core/constants/collections.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import '../../core/common.dart';
import '../../core/constants/colors.dart';
import '../model.dart';

class MessagesTab extends StatefulWidget {
   const MessagesTab({Key? key,required this.uid}) : super(key: key);

   final String uid;

  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: const Text(
          "Messages",
          style: TextStyle(fontSize: 20),
        ),

      ),
      body:PaginateFirestore(
        onEmpty: Text('No Messages Yet',),
        padding: EdgeInsets.symmetric(horizontal: 13),
        //item builder type is compulsory.
        itemBuilder: (context, documentSnapshots, index) {
          MessageModel message =
          MessageModel.fromDocument(documentSnapshots[index]);
          return StreamBuilder<DocumentSnapshot>(
              stream: careTakersCollection.doc(message.fid).snapshots(),
              builder: (context, usnapshot) {
                if (!usnapshot.hasData) return const SizedBox.shrink();
                DocumentSnapshot userDate = usnapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ListTile(
                    onTap: () => Get.toNamed("/chat", parameters: {
                      "uid": widget.uid,
                      "fid": message.fid,
                      "chatID": message.chatID
                    }),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side:
                        const BorderSide(color: kWhiteColor, width: 1)),
                    tileColor: message.unreadCount > 0
                        ? kPrimaryColor
                        : Colors.transparent,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: CachedNetworkImage(
                        imageUrl: userDate["profilePicture"],
                        errorWidget: (c, s, a) => Image.asset('assets/placeholderProfile.png'),
                        placeholder: (c, s) =>  Image.asset('assets/placeholderProfile.png'),
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                      ),
                    ),
                    title: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      children: [
                        Text(
                          userDate["firstName"],
                          style:
                          fontBody(fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        if (message.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const ShapeDecoration(
                                shape: CircleBorder(), color: kWhiteColor),
                            child: Text(
                              message.unreadCount.toString(),
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xff5B4ACF)),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      "${message.lastMessageBy == widget.uid ? 'You: ' : ''}${message.lastMessage}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: message.unreadCount > 0
                              ? kWhiteColor
                              : const Color(0xff9FB5C6)),
                    ),
                    trailing: Text(timeDifference(message.lastMessageOn.toDate()),
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Colors.white)),
                  ),
                );
              });
        },
        // orderBy is compulsory to enable pagination
        query: usersCollection
            .doc(widget.uid)
            .collection('messages')
            .orderBy('lastMessageOn',descending: true),
        //Change types accordingly
        itemBuilderType: PaginateBuilderType.listView,
        // to fetch real-time data
        isLive: true,
        includeMetadataChanges: true,
      ),
    );


      /*PaginateFirestore(
        //item builder type is compulsory.
        itemBuilder: (context, documentSnapshots, index) {
          final data = documentSnapshots[index].data() as Map?;
          return Container(
            padding: const EdgeInsets.all(2),
            child: ListTile(
              tileColor: Colors.grey.shade50,
              onTap: () => Get.to(() => const Chat()),
              minVerticalPadding: 18,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              leading: Image.asset(Avatar),
              title: Row(
                children: [
                  Text(
                    "name",
                  ),
                  SizedBox(
                    width: 12,
                  ),

                  Container(
                    width: 20,
                    height: 20,
                    color: Colors.teal.withOpacity(0.20),
                    child: const Center(
                        child: Text(
                          "2",
                          style: TextStyle(color: Colors.teal),
                        )),
                  )
                ],
              ),
              subtitle:  Row(
                children: [
                  Icon(
                    Icons.check,
                    color: Colors.teal,
                  ),

                  Text("Something",
                      style: const TextStyle(
                        color: Colors.teal,
                      )),
                ],
              ),

              trailing: Text("10.30",style: TextStyle(color: Colors.grey),),
              *//*contentPadding: const EdgeInsets.all(8.0),*//*
            ),
          );
        },
        // orderBy is compulsory to enable pagination
        query: usersCollection.doc(widget.uid).collection('messages').orderBy('lastMessageOn',descending: true),
        //Change types accordingly
        itemBuilderType: PaginateBuilderType.listView,
        // to fetch real-time data
        isLive: true,
      ),*/


  }
}


