import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:hailo/core/common.dart';
import 'package:hailo/core/constants/colors.dart';
import 'package:hailo/views/job_page_tabs/applicant_accept.dart';

import '../../core/constants/collections.dart';
import '../../core/utils/common.dart';

class Application extends StatefulWidget {
  final String uid, tid, cid;
  const Application(
      {super.key, required this.uid, required this.tid, required this.cid});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  openChat(String uid, String cid) async {
    DocumentSnapshot snapshot =
        await usersCollection.doc(uid).collection("messages").doc(cid).get();
    if (snapshot.exists) {
      Get.offNamed("/chat",
          parameters: {"uid": uid, "fid": cid, "chatID": snapshot['chatID']});
    } else {
      await chatsCollection.add({
        "chatStarted": true,
        "users": [uid, cid]
      }).then((value) async {
        DateTime now = DateTime.now();
        await usersCollection.doc(uid).collection("messages").doc(cid).set({
          "chatID": value.id,
          "lastMessage": "Start a new chat",
          "unreadCount": 0,
          "lastMessageBy": "",
          "lastMessageOn": now,
        });
        await careTakersCollection
            .doc(cid)
            .collection("messages")
            .doc(uid)
            .set({
          "chatID": value.id,
          "lastMessage": "Start a new chat",
          "unreadCount": 0,
          "lastMessageBy": "",
          "lastMessageOn": now,
        });
        Get.offNamed("/chat",
            parameters: {"uid": uid, "fid": cid, "chatID": value.id});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Center(
          child: StreamBuilder<DocumentSnapshot>(
            stream: longtermCollection.doc(widget.tid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return customProgressIndicator();
              DocumentSnapshot data = snapshot.data!;
              List<dynamic> service = data['caregiverService'];
              return Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 30,
                        width: 70,
                      ),
                      Positioned(
                        height: 30,
                        width: 30,
                        left: 44,
                        child: service.length >= 3
                            ? Container(
                                decoration: BoxDecoration(
                                    color: kPrimaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: kWhiteColor, width: 3)),
                                child: Center(
                                  child: Image.asset(
                                    "${service[2]['icon']}",
                                    height: 18,
                                    width: 18,
                                    color: kWhiteColor,
                                  ),
                                ))
                            : Container(
                                height: 15,
                                width: 15,
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: kWhiteColor, width: 3)),
                              ),
                      ),
                      Positioned(
                        height: 30,
                        width: 30,
                        left: 23,
                        child: service.length >= 2
                            ? Container(
                                decoration: BoxDecoration(
                                    color: kPrimaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: kWhiteColor, width: 3)),
                                child: Center(
                                  child: Image.asset(
                                    "${service[1]['icon']}",
                                    height: 15,
                                    width: 15,
                                    color: kWhiteColor,
                                  ),
                                ),
                              )
                            : Container(
                                height: 15,
                                width: 15,
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: kWhiteColor, width: 3)),
                              ),
                      ),
                      Positioned(
                          height: 30,
                          width: 30,
                          left: 2,
                          child: Container(
                            decoration: BoxDecoration(
                                color: kPrimaryColor,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: kWhiteColor, width: 3)),
                            child: Center(
                              child: Image.asset(
                                "${service[0]['icon']}",
                                height: 15,
                                width: 16,
                                color: kWhiteColor,
                              ),
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  service.length == 1
                      ? Text(
                          '${service[0]['name']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : Text(
                          '${service[0]['name']} and +${service.length - 1}',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ],
              );
            },
          ),

          /*  */
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: kPrimaryColor,
            ),
            onPressed: Get.back,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: StreamBuilder<DocumentSnapshot>(
            stream: careTakersCollection.doc(widget.cid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return customProgressIndicator();
              DocumentSnapshot data = snapshot.data!;
              return Column(children: [
                Container(height: 40),
                SizedBox(
                  height: 138,
                  width: 138,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: data["profilePicture"].isEmpty
                        ? Image.asset(
                            "assets/placeholderProfile.png",
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                          )
                        : CachedNetworkImage(
                            imageUrl: data["profilePicture"],
                            placeholder: (c, s) =>
                                const ColoredBox(color: kLightGreyColor),
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // C- Name
                Text(
                  data['firstName'] + " " + data['lastName'],
                  style: fontBody(
                      fontSize: 25,
                      fontWeight: FontWeight.w400,
                      fontColor: kBlackColor),
                ),
                const SizedBox(height: 6),

                // dob
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      calculateAge(data['dob']),
                      style: fontBody(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          fontColor: kLightGreyColor),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      data['gender'],
                      style: fontBody(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          fontColor: kLightGreyColor),
                    ),
                  ],
                ),
                Wrap(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 58.0),
                    child: Text(
                      data['languages'].join(', '),
                      style: fontBody(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          fontColor: kLightGreyColor),
                    ),
                  ),
                ]),

                Text(
                  "I drive a " +
                      data['carDetails']['brand'] +
                      " " +
                      data['carDetails']['model'] +
                      " " +
                      data['carDetails']['year'],
                  style: fontBody(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      fontColor: kLightGreyColor),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),

                // Ratings
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 22),
                    SizedBox(width: 4),
                    Text(
                      data["ratingCount"] > 0
                          ? (data['rating'] / data["ratingCount"])
                              .toStringAsFixed(0)
                          : "0.0",
                      style: const TextStyle(color: Colors.amber, fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),

                // Send Message
                ElevatedButton.icon(
                  icon: Image.asset(
                    'assets/chat.png',
                    height: 21,
                    width: 21,
                    color: kWhiteColor,
                  ),
                  label: const Text(
                    'Send Message',
                    style: TextStyle(
                        color: kWhiteColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9)),
                  ),
                  onPressed: () => openChat(widget.uid, widget.cid),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                ),

                // Accept Applicant
                ElevatedButton(
                  onPressed: () async {
                    DocumentSnapshot jobDoc =
                        await jobsCollection.doc(widget.tid).get();

                    if (jobDoc.exists) {
                      customToast("Already hired");
                      return;
                    }

                    await longtermCollection.doc(widget.tid).update({
                      "jobStatus": "hired",
                    });

                    await jobsCollection.doc(widget.tid).set({
                      "cid": widget.cid,
                      "isStarted": true,
                      "status": "hired",
                      "taskId": widget.tid,
                    }).then((value) async {
                      Get.off(() =>
                          ApplicantAccept(tid: widget.tid, cid: widget.cid));
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: kPrimaryColor,
                    foregroundColor: kWhiteColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Center(
                    child: Text(
                      'Accept Applicant',
                      style: TextStyle(
                          fontSize: 20,
                          color: kWhiteColor,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                )
              ]);
            }),
      ),
    );
  }
}
