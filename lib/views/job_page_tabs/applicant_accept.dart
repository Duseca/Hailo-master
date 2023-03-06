import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hailo/core/common.dart';
import '../../core/constants/collections.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/common.dart';

class ApplicantAccept extends StatelessWidget {
  final String tid, cid;
  const ApplicantAccept({Key? key, required this.tid, required this.cid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Center(
          child: StreamBuilder<DocumentSnapshot>(
            stream: longtermCollection.doc(tid).snapshots(),
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
                                decoration: BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle, border: Border.all(color: kWhiteColor, width: 3)),
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
                                decoration: BoxDecoration(color: Colors.transparent, shape: BoxShape.circle, border: Border.all(color: kWhiteColor, width: 3)),
                              ),
                      ),
                      Positioned(
                        height: 30,
                        width: 30,
                        left: 23,
                        child: service.length >= 2
                            ? Container(
                                decoration: BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle, border: Border.all(color: kWhiteColor, width: 3)),
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
                                decoration: BoxDecoration(color: Colors.transparent, shape: BoxShape.circle, border: Border.all(color: kWhiteColor, width: 3)),
                              ),
                      ),
                      Positioned(
                          height: 30,
                          width: 30,
                          left: 2,
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
      body: StreamBuilder<DocumentSnapshot>(
          stream: careTakersCollection.doc(cid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return customProgressIndicator();
            DocumentSnapshot data = snapshot.data!;
            return Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Container(
                    height: 55,
                    width: 55,
                    margin: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(color: Colors.red.shade300, shape: BoxShape.circle),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    'Applicant Accepted !',
                    style: TextStyle(fontFamily: "Poppins", fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: 1),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Card(
                      elevation: 4,
                      shadowColor: Colors.black,
                      child: Container(
                        width: 200,
                        height: 300,
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                            Container(
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
                                        fit: BoxFit.cover,
                                        width: 50,
                                        height: 50,
                                      ),
                              ),
                            ),
                            Text(
                              data['firstName'] + " " + data['lastName'],
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              calculateAge(data['dob']),
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: kLightGreyColor),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  data["ratingCount"] > 0 ? (data['rating'] / data["ratingCount"]).toStringAsFixed(0) : "0.0",
                                  style: const TextStyle(color: Colors.amber, fontSize: 16),
                                ),
                              ],
                            ),
                          ]),
                        ),
                      )),
                  SizedBox(
                    height: 40,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      height: 52,
                      width: 332,
                      decoration: BoxDecoration(color: kPrimaryColor, borderRadius: BorderRadius.circular(9), border: Border.all(color: kPrimaryColor)),
                      child: const Center(
                        child: Text(
                          'Done',
                          style: TextStyle(fontSize: 20, color: kWhiteColor, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
