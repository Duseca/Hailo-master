import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hailo/core/constants/collections.dart';
import 'package:hailo/core/constants/colors.dart';
import 'package:hailo/core/constants/images.dart';
import 'package:intl/intl.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import '../../core/common.dart';
import '../../core/utils/common.dart';
import '../../my_widgets/dialogs/errorDialog.dart';


class SchedulesTab extends StatefulWidget {
  final String uid;
  const SchedulesTab({Key? key, required this.uid}) : super(key: key);

  @override
  State<SchedulesTab> createState() => _SchedulesTabState();
}

class _SchedulesTabState extends State<SchedulesTab> {
  //method to check if the user has payment method added or not
  Future<bool> checkIfPaymentAdded({required String userId}) async {
    try {
      var doc = await usersCollection.doc(userId).get();
      bool isPaymentAdded = doc.get('isPaymentAdded');
      return isPaymentAdded;
    } on FirebaseException catch (e) {
      print(e);
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("My Schedules"),
        actions: [
          IconButton(
            onPressed: () async {
              //checking if the user has added payment method or not
              bool isPaymentAdded =
                  await checkIfPaymentAdded(userId: widget.uid);

              if (isPaymentAdded) {
                Get.toNamed('/longterm', parameters: {'uid': widget.uid});
              } else {
                errorDialog(
                    title: "Add Payment Method",
                    msg:
                        "You have not added any payment method yet, please add a payment method to create a long term schedule.");
              }
            },
            icon: const Icon(Icons.add_circle, size: 30),
            color: kPrimaryColor,
          )
        ],
      ),
      body: PaginateFirestore(
        onEmpty: Padding(
          padding: const EdgeInsets.symmetric(vertical: 208.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                  backgroundColor: kPrimaryColor.withOpacity(0.1),
                  radius: 70,
                  child: Image.asset(
                    "assets/noschedule.png",
                  )),
              SizedBox(
                height: 10,
              ),
              Text(
                'No Schedules Yet',
                style: fontBody(fontSize: 16),
              ),
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        //item builder type is compulsory.
        itemsPerPage: 10,
        itemBuilder: (context, documentSnapshots, index) {
          DocumentSnapshot task = documentSnapshots[index];
          List<dynamic> service = task['caregiverService'];
          List<dynamic> dates = task['days'];
          if (!widget.uid!.contains(task["uid"])) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 9.0),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.toNamed('/jobpage',
                        parameters: {'tid': task.id, 'uid': widget.uid});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: Color(0xffF2F2F2), width: 1)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //Icons Stacking
                          Container(
                            height: 50,
                            width: Get.width,
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom:
                                        BorderSide(color: Color(0xffF2F2F2)))),
                            child: Stack(children: [
                              Center(
                                child: service.length == 1
                                    ? Text(
                                        '${service[0]['name']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    : Text(
                                        '${service[0]['name']} and +${service.length - 1}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                              ),

                              // Category Icons Stacked
                              Positioned(
                                  height: 30,
                                  width: 30,
                                  left: 60,
                                  top: 9,
                                  child: service.length >= 3
                                      ? Container(
                                          decoration: BoxDecoration(
                                              color: kPrimaryColor,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: kWhiteColor,
                                                  width: 3)),
                                          child: Center(
                                            child: Image.asset(
                                              "${service[2]['icon']}",
                                              height: 18,
                                              width: 18,
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
                                                  color: kWhiteColor,
                                                  width: 3)),
                                        )),
                              Positioned(
                                  height: 30,
                                  width: 30,
                                  left: 39,
                                  top: 9,
                                  child: service.length >= 2
                                      ? Container(
                                          decoration: BoxDecoration(
                                              color: kPrimaryColor,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: kWhiteColor,
                                                  width: 3)),
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
                                                  color: kWhiteColor,
                                                  width: 3)),
                                        )),
                              Positioned(
                                  height: 30,
                                  width: 30,
                                  left: 16,
                                  top: 9,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: kPrimaryColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: kWhiteColor, width: 3)),
                                    child: Center(
                                      child: Image.asset(
                                        "${service[0]['icon']}",
                                        height: 15,
                                        width: 16,
                                        color: kWhiteColor,
                                      ),
                                    ),
                                  )),
                              // Category Icons Stacked
                            ]),
                          ),

                          // Caretaker Image and name

                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 8),
                            child: StreamBuilder<DocumentSnapshot>(
                                stream: jobsCollection.doc(task.id).snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData)
                                    return customProgressIndicator();
                                  DocumentSnapshot udata = snapshot.data!;
                                  if (snapshot.hasData &&
                                      !snapshot.data!.exists) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const CircleAvatar(
                                          radius: 14,
                                          backgroundColor: Color(0xffC4C4C4),
                                          child: Icon(
                                            Icons.question_mark,
                                            color: kWhiteColor,
                                            size: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Text(
                                          "Open Position",
                                          style: fontBody(
                                              fontSize: 16,
                                              fontColor: Color(0xffC4C4C4)),
                                        )
                                      ],
                                    );
                                  }
                                  String cID = udata['cid'];
                                  return StreamBuilder<DocumentSnapshot>(
                                      //stream: careTakersCollection.doc(udata.id).snapshots(),
                                      stream: careTakersCollection
                                          .doc(cID)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData)
                                          return customProgressIndicator();
                                        DocumentSnapshot data = snapshot.data!;

                                        return Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              child:
                                                  data["profilePicture"].isEmpty
                                                      ? Image.asset(
                                                          "assets/placeholderProfile.png",
                                                          fit: BoxFit.cover,
                                                          width: 30,
                                                          height: 30,
                                                        )
                                                      : CachedNetworkImage(
                                                          imageUrl: data[
                                                              "profilePicture"],
                                                          fit: BoxFit.cover,
                                                          width: 30,
                                                          height: 30,
                                                        ),
                                            ),
                                            const SizedBox(
                                              width: 17,
                                            ),
                                            Text(
                                              data["firstName"],
                                              style: fontBody(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )
                                          ],
                                        );
                                      });
                                }),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 40.0),
                            child: ListTile(
                              title: Text(
                                "${DateFormat("MMM dd, yyyy").format(task['startDate'].toDate())} to\n${DateFormat("MMM dd, yyyy").format(task['endDate'].toDate())}",
                                style: fontBody(
                                    fontColor: const Color(0xffC4C4C4),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                              ),
                              trailing: SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: task['jobStatus'] == "Pending"
                                      ? GestureDetector(
                                          onTap: () async {
                                            await longtermCollection
                                                .doc(task.id)
                                                .delete();
                                          },
                                          child: Container(
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: kSecondaryColor)),
                                            child: Center(
                                              child: Image.asset(
                                                Hdelete,
                                                height: 22,
                                                width: 22,
                                              ),
                                            ),
                                          ),
                                        )
                                      : SizedBox() /*StreamBuilder<DocumentSnapshot>(
                                    stream: jobsCollection.doc(task.id).snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return customProgressIndicator();
                                      }
                                      DocumentSnapshot tdata = snapshot.data!;
                                      String cID = tdata['cid'];
                                      print(cID);
                                      return StreamBuilder<DocumentSnapshot>(
                                          stream: careTakersCollection.doc(cID).snapshots(),
                                          builder: (context, snapshot) {

                                            DocumentSnapshot rdata = snapshot.data!;
                                            if (!snapshot.hasData) return customProgressIndicator();
                                            return GestureDetector(
                                              onTap: () async {
                                                try {
                                                  await careTakersCollection.doc(cID).collection("appliedJobs").doc(task.id).delete();
                                                } on Exception catch (e) {
                                                  // TODO
                                                }
                                                await jobsCollection.doc(task.id).delete();
                                                await longtermCollection.doc(task.id).collection("applicants").doc(cID).delete();
                                                await longtermCollection.doc(task.id).delete();
                                                customToast("task deleted");
                                              },
                                              child: Container(
                                                height: 40,
                                                width: 40,
                                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: kSecondaryColor)),
                                                child: Center(
                                                  child: Image.asset(
                                                    Hdelete,
                                                    height: 22,
                                                    width: 22,
                                                  ),
                                                ),
                                              )
                                            );
                                          });
                                    }),*/
                                  ),
                            ),
                          )
                        ]),
                  ),
                ),
              ],
            ),
          );
        },
        // orderBy is compulsory to enable pagination
        query: FirebaseFirestore.instance
            .collection('longTerm')
            .where("isCompleted", isEqualTo: false)
            .orderBy('price'),

        //Change types accordingly
        itemBuilderType: PaginateBuilderType.listView,
        // to fetch real-time data
        isLive: true,
      ),
    );
  }
}
