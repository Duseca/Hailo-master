import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hailo/core/constants/colors.dart';
import 'package:hailo/core/utils/common.dart';

import '../../controller/job_page_controller.dart';
import '../../core/constants/collections.dart';
import 'applicants.dart';
import 'info.dart';

class JobPage extends GetView<JobPageController> {
  JobPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: StreamBuilder<DocumentSnapshot>(
          stream: longtermCollection.doc(controller.tid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return customProgressIndicator();

            DocumentSnapshot data = snapshot.data!;
            List<dynamic> service = data['caregiverService'];
            return Scaffold(
              appBar: AppBar(

                backgroundColor: Colors.transparent,
                centerTitle: true,
                title: Center(
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          const SizedBox(height: 30, width: 70),
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
                        ],
                      ),
                      const SizedBox(
                        width: 5,
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
                  ),
                ),
                leading: Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: kPrimaryColor,
                    ),
                    onPressed: Get.back,
                  ),
                ),
                bottom: const TabBar(
                  tabs: [
                    Tab(text: 'Info'),
                    Tab(text: 'Applicants'),
                  ],
                  indicatorColor: kPrimaryColor,
                  labelColor: kBlackColor,
                  unselectedLabelColor: Color(0xffC4C4C4),
                  labelStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  unselectedLabelStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  padding: EdgeInsets.symmetric(horizontal: 32),
                ),
              ),
              body: TabBarView(
                children: [
                  Info(
                    tid: controller.tid!,
                    uid: controller.uid!,
                  ),
                  Applicants(tid: controller.tid!, uid: controller.uid!),
                ],
              ),
            );
          }),
    );
  }
}
