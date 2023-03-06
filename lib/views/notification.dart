import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hailo/core/constants/colors.dart';
import 'package:hailo/main.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:remixicon/remixicon.dart';

import '../core/common.dart';
import '../core/constants/collections.dart';

class NotificationPage extends StatefulWidget {
  final String uid;
 const NotificationPage({Key? key, required this.uid}) : super(key: key);



  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notification"),
      ),
      body: PaginateFirestore(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, documentSnapshots, index) {
          DocumentSnapshot notify = documentSnapshots[index];

          return Padding(
              padding: const EdgeInsets.all(5.0),
              child: ListTile(
                minLeadingWidth: 0,
                tileColor: kPrimaryColor.withOpacity(0.1),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                leading: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircleAvatar(
                      backgroundColor: kPrimaryColor,
                      radius: 5,
                    ),
                  ],
                ),
                title: Text(notify["title"]),
                subtitle: Text(
              "${notify["description"]}\n ${timeDifference(notify["sentAt"].toDate())}",),
                trailing: IconButton(
                  icon: const Icon(
                    Remix.close_circle_line,
                    color: Colors.red,
                  ),
                  onPressed: () async {
                    print(notify.id);
                    await usersCollection.doc(widget.uid).collection("notifications").doc(notify.id).delete();
                  },
                ),
              ));
        },
        query: usersCollection.doc(widget.uid).collection("notifications").orderBy("sentAt", descending: true),
        isLive: true,
        itemBuilderType: PaginateBuilderType.listView,
      ),
    );
  }
}
