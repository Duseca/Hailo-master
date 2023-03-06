import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Settings;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hailo/controller/root_controller.dart';
import 'package:hailo/core/constants/collections.dart';
import 'package:hailo/core/utils/common.dart';
import 'package:hailo/views/notification.dart';
import 'package:hailo/views/tabs/schedules_tab.dart';
import 'package:intl/intl.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import '../job_page_tabs/applicants.dart';
import '../root.dart';
import '../settings/settings.dart';
import '../../core/common.dart';
import '../../core/constants/colors.dart';

class HomeTab extends StatefulWidget {
  HomeTab({
    Key? key,
    required this.uid,
  }) : super(key: key);

  final String uid;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String? uid = Get.parameters["uid"];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: usersCollection.doc(widget.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return customProgressIndicator();
          DocumentSnapshot udata = snapshot.data!;
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: kPrimaryColor,
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: udata["profilePicture"].isEmpty
                        ? Image.asset(
                            "assets/placeholderProfile.png",
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                          )
                        : CachedNetworkImage(
                            imageUrl: udata["profilePicture"],
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                          ),
                  ),
                ],
              ),
              titleTextStyle: fontBody(fontSize: 18, fontColor: kWhiteColor),
              title: Text("Welcome ${udata["firstName"]}"),
              actions: [
                IconButton(onPressed: () => Get.to(() =>  NotificationPage(uid: widget.uid)), color: kWhiteColor, icon: const Icon(Icons.notifications)),
                IconButton(onPressed: () => Get.to(() => SettingSt(uid: widget.uid)), color: kWhiteColor, icon: const Icon(Icons.settings)),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(children: [
                    Image.asset("assets/shape1.png"),
                    Padding(
                      padding: const EdgeInsets.only(top: kToolbarHeight + 65, left: 24, right: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // No.of task
                          Container(
                            height: 170,
                            width: context.width / 2 - 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: [
                                  BoxShadow(
                                    color: kLightGreyColor.withOpacity(0.4),
                                    blurRadius: 10,
                                  )
                                ],
                                color: kWhiteColor),
                            child: StreamBuilder<QuerySnapshot>(
                                stream:
                                    longtermCollection.where("uid", isEqualTo: widget.uid).where("endDate", isGreaterThanOrEqualTo: DateTime.now()).snapshots(),
                                builder: (context, snapshot) {
                                  int count = 0;
                                  if (!snapshot.hasData) {
                                    count = 0;
                                  }
                                  if (snapshot.hasData) {
                                    count = snapshot.data!.docs.length;
                                  }
                                  return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/clipboard_icon.png',
                                          height: 20,
                                          width: 14,
                                        ),
                                        const SizedBox(
                                          width: 11,
                                        ),
                                        Text(
                                          'Schedule',
                                          style: fontBody(fontSize: 14, fontWeight: FontWeight.w600, fontColor: kPrimaryColor),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        IconButton(
                                          onPressed: () => Get.to(() => SchedulesTab(
                                                uid: widget.uid,
                                              )),
                                          icon: const Icon(
                                            Icons.arrow_forward_ios,
                                            color: kPrimaryColor,
                                            size: 10,
                                          ),
                                        )
                                      ],
                                    ),
                                    Text(
                                      'You have',
                                      style: fontBody(fontSize: 18, fontWeight: FontWeight.w500, fontColor: kLightGreyColor),
                                    ),
                                    Text(
                                      "$count",
                                      style: fontBody(fontSize: 45, fontWeight: FontWeight.w600, fontColor: kBlackColor),
                                    ),
                                    Text(
                                      'tasks',
                                      style: fontBody(fontSize: 18, fontWeight: FontWeight.w500, fontColor: kLightGreyColor),
                                    ),
                                  ]);
                                }),
                          ),

                          // No.of Applicants in applied status
                          Container(
                            height: 170,
                            width: context.width / 2 - 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9),
                              color: kWhiteColor,
                              boxShadow: [
                                BoxShadow(
                                  color: kLightGreyColor.withOpacity(0.4),
                                  blurRadius: 10,
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: StreamBuilder<QuerySnapshot>(
                                  stream: jobsCollection.where("status", isEqualTo: "applied").snapshots(),
                                  builder: (context, snapshot) {
                                    int count = 0;

                                    if (!snapshot.hasData) {
                                      count = 0;
                                    }
                                    if (snapshot.hasData) {
                                      count = snapshot.data!.docs.length;
                                    }
                                    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/user_love_icon.png',
                                            height: 20,
                                            width: 14,
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            'Applicants',
                                            style: fontBody(fontSize: 14, fontWeight: FontWeight.w600, fontColor: kPrimaryColor),
                                          ),
                                          const SizedBox(
                                            width: 1,
                                          ),
                                         /* IconButton(
                                            onPressed: () => {
                                            },
                                            icon: const Icon(
                                              Icons.arrow_forward_ios,
                                              color: kPrimaryColor,
                                              size: 10,
                                            ),
                                          )*/
                                        ],
                                      ),
                                      Text(
                                        'You have',
                                        style: fontBody(fontSize: 18, fontWeight: FontWeight.w500, fontColor: kLightGreyColor),
                                      ),
                                      Text(
                                        "$count",
                                        style: fontBody(fontSize: 45, fontWeight: FontWeight.w600, fontColor: kBlackColor),
                                      ),
                                      Text(
                                        'new applicant',
                                        style: fontBody(fontSize: 18, fontWeight: FontWeight.w500, fontColor: kLightGreyColor),
                                      ),
                                    ]);
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(
                    height: 28,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GestureDetector(
                      onTap: () => Get.find<RootController>().currentTab.value = 1,
                      child: Stack(
                        children: [
                          Container(
                            height: 92,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: kSecondaryColor,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Create Instant Task',
                                    style: fontBody(fontSize: 18, fontWeight: FontWeight.w500, fontColor: kWhiteColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.to(() => Root());
                              print(uid);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 203),
                              child: Image.asset(
                                'assets/create_task.png',
                                height: 92.41,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Active Schedule',
                      style: fontBody(fontSize: 18, fontWeight: FontWeight.w600, fontColor: kBlackColor),
                    ),
                  ),
                  PaginateFirestore(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.vertical,
                    physics: NeverScrollableScrollPhysics(),
                    onEmpty: SizedBox(height: 50),
                    separator: const SizedBox(height: 10),
                    shrinkWrap: true,
                    itemsPerPage: 10,
                    itemBuilder: (context, documentSnapshots, index) {
                      DocumentSnapshot task = documentSnapshots[index];
                      List<dynamic> service = task['caregiverService'];
                      List<dynamic> dates = task['days'];

                      return StreamBuilder(
                        stream: jobsCollection.where("taskId",isEqualTo:task.id).where("isStarted",isEqualTo:true).snapshots(),
                        builder: (context, snapshot) {
                          return GestureDetector(
                            onTap: () {
                              Get.toNamed('/jobpage', parameters: {'tid': task.id, 'uid': widget.uid});
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                //Icons Stacking
                                SizedBox(
                                  height: 50,
                                  width: Get.width,
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
                                                decoration:
                                                    BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle, border: Border.all(color: kWhiteColor, width: 3)),
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
                                                    color: Colors.transparent, shape: BoxShape.circle, border: Border.all(color: kWhiteColor, width: 3)),
                                              )),
                                    Positioned(
                                        height: 30,
                                        width: 30,
                                        left: 39,
                                        top: 9,
                                        child: service.length >= 2
                                            ? Container(
                                                decoration:
                                                    BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle, border: Border.all(color: kWhiteColor, width: 3)),
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
                                                    color: Colors.transparent, shape: BoxShape.circle, border: Border.all(color: kWhiteColor, width: 3)),
                                              )),
                                    Positioned(
                                        height: 30,
                                        width: 30,
                                        left: 16,
                                        top: 9,
                                        child: Container(
                                          decoration: BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle, border: Border.all(color: kWhiteColor, width: 3)),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 8),
                                  child: StreamBuilder<DocumentSnapshot>(
                                      stream: jobsCollection.doc(task.id).snapshots(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) return customProgressIndicator();
                                        DocumentSnapshot udata = snapshot.data!;
                                        if (snapshot.hasData && !snapshot.data!.exists) {
                                          return Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
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
                                                style: fontBody(fontSize: 16, fontColor: Color(0xffC4C4C4)),
                                              )
                                            ],
                                          );
                                        }
                                        String cID = udata['cid'];
                                        return StreamBuilder<DocumentSnapshot>(
                                            //stream: careTakersCollection.doc(udata.id).snapshots(),
                                            stream: careTakersCollection.doc(cID).snapshots(),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) return customProgressIndicator();
                                              DocumentSnapshot data = snapshot.data!;

                                              return Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(100),
                                                    child: data["profilePicture"].isEmpty
                                                        ? Image.asset(
                                                            "assets/placeholderProfile.png",
                                                            fit: BoxFit.cover,
                                                            width: 30,
                                                            height: 30,
                                                          )
                                                        : CachedNetworkImage(
                                                            imageUrl: data["profilePicture"],
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
                                  padding: const EdgeInsets.only(left: 80.0),
                                  child: Text(
                                    "${DateFormat("MMM dd, yyyy").format(task['startDate'].toDate())} to\n${DateFormat("MMM dd, yyyy").format(task['endDate'].toDate())}",
                                    style: fontBody(fontColor: const Color(0xffC4C4C4), fontSize: 14, fontWeight: FontWeight.w400),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Divider(thickness: 1, height: 2),
                              ],
                            ),
                          );
                        }
                      );
                    },
                    query: longtermCollection.where("uid", isEqualTo: widget.uid).where("jobStatus", isEqualTo: "hired").orderBy('price'),
                    itemBuilderType: PaginateBuilderType.listView,
                    isLive: true,
                    includeMetadataChanges: true,
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Upcoming Schedule',
                      style: fontBody(fontSize: 18, fontWeight: FontWeight.w600, fontColor: kBlackColor),
                    ),
                  ),
                  const SizedBox(height: 18),
                  PaginateFirestore(
                    onEmpty: const SizedBox(height: 50),
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.vertical,
                    includeMetadataChanges: true,
                    shrinkWrap: true,
                    itemsPerPage: 10,
                    itemBuilder: (context, documentSnapshots, index) {
                      DocumentSnapshot task = documentSnapshots[index];
                      List<dynamic> service = task['caregiverService'];
                      List<dynamic> dates = task['days'];
                      if (!widget.uid.contains(task["uid"])) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 9.0),
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed('/jobpage', parameters: {'tid': task.id, 'uid': widget.uid});
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              //Icons Stacking
                              Container(
                                height: 50,
                                width: Get.width,
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
                                              decoration:
                                                  BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle, border: Border.all(color: kWhiteColor, width: 3)),
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
                                                  color: Colors.transparent, shape: BoxShape.circle, border: Border.all(color: kWhiteColor, width: 3)),
                                            )),
                                  Positioned(
                                      height: 30,
                                      width: 30,
                                      left: 39,
                                      top: 9,
                                      child: service.length >= 2
                                          ? Container(
                                              decoration:
                                                  BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle, border: Border.all(color: kWhiteColor, width: 3)),
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
                                                  color: Colors.transparent, shape: BoxShape.circle, border: Border.all(color: kWhiteColor, width: 3)),
                                            )),
                                  Positioned(
                                      height: 30,
                                      width: 30,
                                      left: 16,
                                      top: 9,
                                      child: Container(
                                        decoration:
                                            BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle, border: Border.all(color: kWhiteColor, width: 3)),
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
                                padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 8),
                                child: StreamBuilder<DocumentSnapshot>(
                                    stream: jobsCollection.doc(task.id).snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) return customProgressIndicator();
                                      DocumentSnapshot udata = snapshot.data!;
                                      if (snapshot.hasData && !snapshot.data!.exists) {
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
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
                                              style: fontBody(fontSize: 16, fontColor: Color(0xffC4C4C4)),
                                            )
                                          ],
                                        );
                                      }
                                      String cID = udata['cid'];
                                      return StreamBuilder<DocumentSnapshot>(
                                          //stream: careTakersCollection.doc(udata.id).snapshots(),
                                          stream: careTakersCollection.doc(cID).snapshots(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) return customProgressIndicator();
                                            DocumentSnapshot data = snapshot.data!;

                                            return Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(100),
                                                  child: data["profilePicture"].isEmpty
                                                      ? Image.asset(
                                                          "assets/placeholderProfile.png",
                                                          fit: BoxFit.cover,
                                                          width: 30,
                                                          height: 30,
                                                        )
                                                      : CachedNetworkImage(
                                                          imageUrl: data["profilePicture"],
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
                                padding: const EdgeInsets.only(left: 80.0),
                                child: ListTile(
                                  title: Text(
                                    "${DateFormat("MMM dd, yyyy").format(task['startDate'].toDate())} to\n${DateFormat("MMM dd, yyyy").format(task['endDate'].toDate())}",
                                    style: fontBody(fontColor: const Color(0xffC4C4C4), fontSize: 14, fontWeight: FontWeight.w400),
                                  ),
                                  /*  trailing: GestureDetector(
                                      onTap: () async {
                                        await longtermCollection.doc(task.id).delete();
                                        await jobsCollection.doc(task.id).delete();
                                        customToast("task deleted");
                                      },
                                      child: Container(
                                        height: 33,
                                        width: 33,
                                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: kSecondaryColor)),
                                        child: Center(
                                          child: Image.asset(
                                            Hdelete,
                                            height: 12,
                                            width: 12,
                                          ),
                                        ),
                                      ),
                                    ),*/
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    query: longtermCollection.where("uid", isEqualTo: widget.uid).where("jobStatus", isEqualTo: "Pending").orderBy('price'),
                    itemBuilderType: PaginateBuilderType.listView,
                    isLive: true,
                  ),
                  // Stack(
                  //   children: [
                  //     Container(
                  //       margin: const EdgeInsets.only(left: 50),
                  //       alignment: Alignment.topLeft,
                  //       width: 4,
                  //       color: kLightGreyColor,
                  //     ),
                  //
                  //   ],
                  // )
                ],
              ),
            ),
          );
        });
  }
}
