import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:hailo/views/settings/settingScreens/profiles/pillbox.dart';

import '../../../../controller/health_controller.dart';
import '../../../../core/common.dart';
import '../../../../core/constants/collections.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/common.dart';

class HealthCondition extends GetView<HealthController> {
  HealthCondition({Key? key}) : super(key: key);
  @override
  final HealthController controller = Get.put(HealthController());
  String? uid = Get.parameters["uid"];
  var userType = Get.arguments;

  TextEditingController _searchcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Conditions"),
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xffE7E7E7), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /* TextFormField(
              controller: _searchcontroller,
              decoration: InputDecoration(
                labelText: 'Search',
              ),
              ),*/
                StreamBuilder<QuerySnapshot>(
                    stream:
                        healthConditionsCollection.orderBy("dname").snapshots(),
                    builder: (context, lsnapshot) {
                      if (!lsnapshot.hasData) return customProgressIndicator();
                      List<DocumentSnapshot> healthConditions =
                          lsnapshot.data!.docs;
                      return ListView.separated(
                        padding: const EdgeInsets.all(6),
                        itemCount: healthConditions.length,
                        shrinkWrap: true,
                        controller: ScrollController(),
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) => Obx(
                          () => controller.hConditions
                                  .contains(healthConditions[index]["dname"])
                              ? ListTile(
                                  onTap: () {
                                    controller.hConditions.remove(
                                        healthConditions[index]["dname"]);
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  tileColor: kPrimaryColor.withOpacity(0.10),
                                  leading: const Icon(Icons.check_box_rounded,
                                      color: kPrimaryColor),
                                  title: Text(
                                    healthConditions[index]["dname"],
                                    style: fontBody(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        fontColor: kPrimaryColor),
                                  ),
                                )
                              : ListTile(
                                  onTap: () {
                                    controller.hConditions
                                        .add(healthConditions[index]["dname"]);
                                  },
                                  leading: const Icon(
                                      Icons.check_box_outline_blank_rounded,
                                      color: Color(0xffC4C4C4)),
                                  title: Text(
                                    healthConditions[index]["dname"],
                                    style: fontBody(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        fontColor: const Color(0xffC4C4C4)),
                                  ),
                                ),
                        ),
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(height: 10),
                      );
                    }),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 13),
                ),
                onPressed: () {
                  Get.off(() => PillBox(), arguments: [
                    userType[0],
                    userType[1],
                    userType[2],
                    userType[3],
                    controller.hConditions
                  ]);
                },
                child: const Text(
                  "Next",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontFamily: "Poppins"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
