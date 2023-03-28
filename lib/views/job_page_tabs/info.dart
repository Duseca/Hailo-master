import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hailo/my_widgets/dialogs/confirm_task_completed_dialog.dart';
import 'package:hailo/views/root.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/marked_date.dart';
import 'package:flutter_calendar_carousel/classes/multiple_marked_dates.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:get/get.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:hailo/core/common.dart';
import 'package:hailo/core/constants/collections.dart';
import 'package:hailo/core/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../../controller/confirm_day_task_controller/confirm_day_task_controller.dart';
import '../../controller/job_page_controller.dart';
import '../../core/constants/functions.dart';
import '../../core/utils/common.dart';
import '../../models/confirm_task_model.dart';

class Info extends StatefulWidget {
  final String tid, uid;
  const Info({
    super.key,
    required this.tid,
    required this.uid,
  });

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  Completer<GoogleMapController> googleMapController = Completer();
  Map<String, dynamic>? paymentIntent;

  DateTime startSchedule = DateTime.now();
  DateTime pauseSchedule = DateTime.now();
  // DateTime Duration = pauseSchedule.difference(startSchedule) as DateTime;

  double rating = 0.0;
  int ratingCount = 0;

  Widget buildRating() => RatingBar.builder(
        minRating: 1,
        itemBuilder: (context, index) => const Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (rating) {
          setState(() {
            this.rating = rating;
          });
        },
      );

  void showRating(String cid) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Center(child: Text("Rate your Caregiver!")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/care.png",
                width: 50,
                height: 50,
                color: kPrimaryColor,
              ),
              SizedBox(
                height: 20,
              ),
              buildRating(),
              SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () async {
                  print("rating");
                  print(rating);

                  await careTakersCollection.doc(cid).update({
                    "rating": FieldValue.increment(rating),
                    "ratingCount": FieldValue.increment(1),
                  });
                  Get.back();
                },
                child: Text("Okay"),
                style: TextButton.styleFrom(
                  foregroundColor: kWhiteColor,
                  elevation: 0,
                  backgroundColor: kPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      );

  @override
  void initState() {
    // TODO: implement initState
    getJobDates();
    super.initState();
  }

  List jobdates = [];

  getJobDates() async {
    QuerySnapshot jobDocs = await longtermCollection
        .where("uid", isEqualTo: widget.uid)
        .orderBy('price')
        .get();

    for (DocumentSnapshot jobData in jobDocs.docs) {
      DocumentSnapshot taskDoc = await longtermCollection.doc(widget.tid).get();

      for (Timestamp date in taskDoc["days"]) {
        jobdates.add(DateFormat("dd-MM-yyyy").format(date.toDate()));
      }
    }

    jobdates = jobdates.toSet().toList();
    setState(() {});
    //print(jobdates);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: longtermCollection.doc(widget.tid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return customProgressIndicator();

          DocumentSnapshot udata = snapshot.data!;
          List<dynamic> service = udata['caregiverService'];

          double lat = udata['destination'].latitude;
          double long = udata['destination'].longitude;
          return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              children: [
                Stack(alignment: AlignmentDirectional.topCenter, children: [
                  Container(
                    height: 30.h,
                    margin: const EdgeInsets.only(top: 24),
                    decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffE7E7E7)),
                        borderRadius: BorderRadius.circular(9)),
                    child: service.length < 4
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 35),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                  service.length,
                                  (index) => Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: kPrimaryColor,
                                            child: Image.asset(
                                              '${service[index]['icon']}',
                                              height: 30,
                                              width: 30,
                                              color: kWhiteColor,
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          Text(
                                            '${service[index]['name']}',
                                            style: fontBody(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                fontColor: kBlackColor),
                                          ),
                                          const SizedBox(height: 15),
                                          Text(
                                            'Start Time',
                                            style: fontBody(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                fontColor: kPrimaryColor),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            '${service[index]['startTime']}',
                                            style: fontBody(
                                                fontSize: 14,

                                                fontColor: kBlackColor),
                                          ),

                                          // Text(
                                          //   '${service[index]['name']}',
                                          //   style: fontBody(
                                          //       fontSize: 14,
                                          //       fontWeight: FontWeight.w500,
                                          //       fontColor: kBlackColor),
                                          // ),
                                          const SizedBox(height: 15),
                                          Text(
                                            'End Time',
                                            style: fontBody(
                                                fontSize: 14,

                                                fontColor: kPrimaryColor),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            '${service[index]['endTime']}',
                                            style: fontBody(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                fontColor: kBlackColor),
                                          ),
                                        ],
                                      )),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 35),
                            scrollDirection: Axis.horizontal,
                            itemCount: service.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (!snapshot.hasData) {
                                return customProgressIndicator();
                              }
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: kPrimaryColor,
                                    child: Image.asset(
                                      '${service[index]['icon']}',
                                      height: 30,
                                      width: 30,
                                      color: kWhiteColor,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    '${service[index]['name']}',
                                    style: fontBody(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontColor: kBlackColor),
                                  )
                                ],
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const SizedBox(
                                width: 35,
                              );
                            },
                          ),
                  ),
                  Positioned(
                      top: 16,
                      child: Container(
                        color: kWhiteColor,
                        child: const Text(
                          'Services',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xffB7B7B7)),
                        ),
                      ))
                ]),

                //Price
                Stack(
                  alignment: AlignmentDirectional.topCenter,
                  children: [
                    Container(
                      height: 60,
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 11),
                      decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xffE7E7E7)),
                          borderRadius: BorderRadius.circular(9)),
                      child: Center(
                          child: Text(
                        "\$ ${udata["price"]}",
                        // "\$ ${udata["price"]} per hour ",
                        textAlign: TextAlign.center,
                        style: fontBody(fontSize: 22, fontColor: kPrimaryColor),
                      )),
                    ),
                    Positioned(
                        top: 4,
                        child: Container(
                          color: kWhiteColor,
                          child: Text(
                            "Price",
                            style: fontBody(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontColor: Color(0xffB7B7B7)),
                          ),
                        ))
                  ],
                ),

                //Caregiver Position
                Stack(
                  alignment: AlignmentDirectional.topCenter,
                  children: [
                    Container(
                      height: 60,
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 11),
                      decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xffE7E7E7)),
                          borderRadius: BorderRadius.circular(9)),
                      child: StreamBuilder<DocumentSnapshot>(
                          stream: jobsCollection.doc(widget.tid).snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return customProgressIndicator();
                            DocumentSnapshot udata = snapshot.data!;

                            if (snapshot.hasData && !snapshot.data!.exists) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                        fontColor: const Color(0xffC4C4C4)),
                                  )
                                ],
                              );
                            }

                            String cID = udata['cid'];
                            String status = udata['status'];

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 15),
                                StreamBuilder<DocumentSnapshot>(
                                    stream: careTakersCollection
                                        .doc(cID)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData)
                                        return customProgressIndicator();
                                      DocumentSnapshot udata = snapshot.data!;
                                      return Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            child: udata["profilePicture"]
                                                    .isEmpty
                                                ? Image.asset(
                                                    "assets/placeholderProfile.png",
                                                    fit: BoxFit.cover,
                                                    width: 30,
                                                    height: 30,
                                                  )
                                                : CachedNetworkImage(
                                                    imageUrl:
                                                        udata["profilePicture"],
                                                    fit: BoxFit.cover,
                                                    width: 30,
                                                    height: 30,
                                                  ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            udata['firstName'] +
                                                " " +
                                                udata['lastName'],
                                            style: fontBody(
                                                fontSize: 16,
                                                fontColor: kBlackColor),
                                          ),
                                        ],
                                      );
                                    }),
                              ],
                            );
                          }),
                    ),
                    Positioned(
                        top: 4,
                        child: Container(
                          color: kWhiteColor,
                          child: const Text(
                            'Caregiver',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xffB7B7B7)),
                          ),
                        ))
                  ],
                ),

                //Job Description
                Stack(
                  children: [
                    Container(
                      height: 132,
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 11),
                      decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xffE7E7E7)),
                          borderRadius: BorderRadius.circular(9)),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          udata["jobDesc"],
                          style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xffB7B7B7)),
                        ),
                      ),
                    ),
                    Positioned(
                        left: 137,
                        top: 4,
                        child: Container(
                          color: kWhiteColor,
                          child: const Text(
                            'Description',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xffB7B7B7)),
                          ),
                        ))
                  ],
                ),

                //Map
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Container(
                      height: 132,
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 11),
                      decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xffE7E7E7)),
                          borderRadius: BorderRadius.circular(9)),
                      child: GoogleMap(
                        mapType: MapType.normal,
                        myLocationButtonEnabled: false,
                        initialCameraPosition:
                            CameraPosition(target: LatLng(lat, long), zoom: 15),
                        onMapCreated: (GoogleMapController gmController) {
                          googleMapController.complete(gmController);
                        },
                      ),
                    ),
                    Image.asset('assets/marker.png', width: 25),
                    Positioned(
                        left: 137,
                        top: 4,
                        child: Container(
                          color: kWhiteColor,
                          child: const Text(
                            'Location',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xffB7B7B7)),
                          ),
                        )),
                  ],
                ),

                //Calendar
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 11),
                  decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xffE7E7E7)),
                      borderRadius: BorderRadius.circular(9)),
                  child: CalendarCarousel<Event>(
                    customDayBuilder: (
                      bool isSelectable,
                      int index,
                      bool isSelectedDay,
                      bool isToday,
                      bool isPrevMonthDay,
                      TextStyle textStyle,
                      bool isNextMonthDay,
                      bool isThisMonthDay,
                      DateTime day,
                    ) {
                      if (udata['days'].contains(day)) {
                        return Container(
                          decoration: const BoxDecoration(
                              color: kPrimaryColor, shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: kBlackColor,
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.black54,
                            ),
                          ),
                        );
                      }
                    },
                    height: Get.height / 2,
                    iconColor: kPrimaryColor,
                    todayTextStyle: TextStyle(color: Colors.tealAccent),
                    multipleMarkedDates: MultipleMarkedDates(
                        markedDates: List.generate(
                      jobdates.length,
                      (index) => MarkedDate(
                          date: DateFormat("dd-MM-yyyy").parse(jobdates[index]),
                          color: kPrimaryColor),
                    )),
                    weekdayTextStyle: const TextStyle(color: kPrimaryColor),
                    headerTextStyle: const TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 24),
                    selectedDateTime: DateTime.now(),
                    selectedDayButtonColor: Colors.grey.withOpacity(0.4),
                    onDayLongPressed: (DateTime date) {},
                  ),
                ),
                const SizedBox(height: 80),

                StreamBuilder<DocumentSnapshot>(
                    stream: jobsCollection.doc(widget.tid).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return customProgressIndicator();
                      DocumentSnapshot udata = snapshot.data!;

                      return StreamBuilder(
                          stream:
                              longtermCollection.doc(widget.tid).snapshots(),
                          builder: (context, snapshot) {
                            DocumentSnapshot data = snapshot.data!;
                            String jobStatus = data['jobStatus'];

                            return jobStatus == 'Pending'
                                ? //cancel schedule button
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    child: GestureDetector(
                                      onTap: () async {
                                        log("This is id: ${widget.tid}");
                                        var doc = await longtermCollection
                                            .doc(widget.tid)
                                            .get();
                                        String jobStatus = doc.get('jobStatus');

                                        if (jobStatus == 'Pending') {
                                          await longtermCollection
                                              .doc(widget.tid)
                                              .delete();
                                          customToast(
                                              "Schedule has been cancelled");
                                          Get.offAllNamed("/root",
                                              parameters: {"uid": widget.uid});
                                        } else {
                                          customToast(
                                              "Schedule cannot be cancelled as it is started");
                                        }

                                        //TODO: this is the code to credit the caregiver when the schedule will be ended

                                        // var doc = await jobsCollection
                                        //     .doc(widget.tid)
                                        //     .get();

                                        // await jobsCollection
                                        //     .doc(widget.tid)
                                        //     .update({
                                        //   "isStarted": false,
                                        //   "status": "done",
                                        // }); to be done on map iteration on client app

                                        // /* await FirebaseFirestore.instance.collection("withdrawal").doc(widget.tid).update({
                                        //     "caretakerUid": doc["cid"],
                                        //   });*/// already done

                                        // await longtermCollection
                                        //     .doc(widget.tid)
                                        //     .update({
                                        //   "isCompleted": true,
                                        //   "jobStatus": "done",
                                        // }); to be done on map iteration on client app

                                        // await FirebaseFirestore.instance
                                        //     .collection("withdrawal")
                                        //     .add({
                                        //   "caretakerUid": doc["cid"],
                                        //   "userUid": widget.uid,
                                        //   "day": DateFormat('dd-MM-yyyy')
                                        //       .format(DateTime.now()),
                                        //   "month": DateFormat('MMM-yyyy')
                                        //       .format(DateTime.now()),
                                        //   "time": DateTime.now(),
                                        //   "price": data['price'],
                                        //   "isPending": true,
                                        // }); //already done

                                        // await FirebaseFirestore.instance
                                        //     .collection("transactionPending")
                                        //     .doc(widget.uid)
                                        //     .delete(); // to be done on map iteration on client app

                                        // Get.offAllNamed("/root",
                                        //     parameters: {"uid": widget.uid});

                                        // print(doc["cid"]);
                                        // print(widget.tid);
                                        // Get.offAllNamed("/root",
                                        //     parameters: {"uid": widget.uid});

                                        // showRating(doc["cid"]);
                                      },
                                      child: Container(
                                        height: 59,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(9),
                                            color: kPrimaryColor),
                                        child: const Center(
                                          child: Text(
                                            'Cancel Schedule',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: kWhiteColor,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                :
                                //Confirm Tasks Completed
                                GestureDetector(
                                    onTap: () async {
                                      log("This is task id: ${widget.tid}");

                                      //putting ConfirmTaskController
                                      Get.put<ConfirmTaskController>(
                                          ConfirmTaskController());

                                      //getting task details (for getting applied payments from caregiver)
                                      ConfirmTaskModel confirmTaskModel =
                                          await Get.find<
                                                  ConfirmTaskController>()
                                              .getTaskDetails(
                                                  taskId: widget.tid);

                                      dayTasksCompletedDialog(
                                          taskId: widget.tid,
                                          confirmTaskModel: confirmTaskModel,
                                          uid: widget.uid);

                                      // await jobsCollection
                                      //     .doc(widget.tid)
                                      //     .update({
                                      //   "isStarted": true,
                                      // });
                                      // customToast("Your schedule started!");
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Container(
                                        height: 59,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(9),
                                            color: kPrimaryColor),
                                        child: const Center(
                                          child: Text(
                                            'Confirm Tasks Completed',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: kWhiteColor,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                          });
                    }),
              ]);
        });
  }
}
