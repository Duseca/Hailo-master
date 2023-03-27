import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/multiple_marked_dates.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:hailo/controller/longterm_controller.dart';
import 'package:hailo/core/common.dart';
import 'package:hailo/core/constants/colors.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:hailo/core/utils/common.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../../core/constants/collections.dart';
import '../../core/utils/form_validators.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../settings/settingScreens/profiles/createprofile.dart';

class LongTerm extends GetView<LongTermController> {
  const LongTerm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: context.mediaQueryViewInsets.bottom == 0
          ? null
          : FloatingActionButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
              },
              backgroundColor: kWhiteColor,
              child: const Icon(
                Icons.keyboard_hide_rounded,
                color: kPrimaryColor,
              ),
            ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Get.back(),
          color: kPrimaryColor,
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Obx(() => Text(controller.pageHeading[controller.currentPage.value])),
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller.pageController,
        children: [
          // services
          StreamBuilder<QuerySnapshot>(
              stream: categoriesCollection.orderBy("name").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return customProgressIndicator();
                }
                List<DocumentSnapshot> caregiverServices = snapshot.data!.docs;
                return Padding(
                  padding: const EdgeInsets.all(35.0),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 20,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
                    children: List.generate(caregiverServices.length, (index) {
                      Map catg = caregiverServices[index].data() as Map;
                      return Obx(
                        () => GestureDetector(
                          onTap: () {
                            if (controller.careServices.contains(catg)) {
                              controller.careServices.remove(catg);
                            } else {
                              controller.careServices.add(catg);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                                color: controller.careServices.contains(catg) ? kPrimaryColor : kWhiteColor,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [BoxShadow(color: kBlackColor.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  caregiverServices[index]["icon"],
                                  width: 30,
                                  height: 35,
                                  color: controller.careServices.contains(catg) ? kWhiteColor.withOpacity(0.7) : kPrimaryColor,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  caregiverServices[index]["name"],
                                  textAlign: TextAlign.center,
                                  style: fontBody(
                                      fontSize: 11, fontColor: controller.careServices.contains(catg) ? kWhiteColor.withOpacity(0.7) : kPrimaryColor),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),

          // select profile
          Padding(
            padding: const EdgeInsets.only(left: 22.0, right: 22.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
              StreamBuilder<QuerySnapshot>(
                  stream: usersCollection.doc(controller.data!).collection("userType").snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return customProgressIndicator();
                    List<DocumentSnapshot> profiles = snapshot.data!.docs;
                    if (snapshot.hasData && profiles.isEmpty) {
                      return const SizedBox();
                    }

                    return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: profiles.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(color: kSecondaryColor, borderRadius: BorderRadius.circular(8.0)),
                              child: ListTile(
                                onTap: () {
                                  if (controller.userType.value == profiles[index]['relationType']) {
                                    controller.userType.value = "";
                                    return;
                                  }
                                  controller.userType.value = profiles[index]['relationType'];
                                },
                                leading: const Icon(Icons.person_pin, color: kWhiteColor),
                                title: Text(
                                  "${profiles[index]['relationType']}",
                                  style: fontBody(fontSize: 20, fontColor: kWhiteColor),
                                ),
                                trailing: Obx(
                                  () => controller.userType.value == profiles[index]['relationType']
                                      ? const Icon(Icons.check_box, color: kWhiteColor)
                                      : const Icon(Icons.check_box_outline_blank, color: kWhiteColor),
                                ),
                              ),
                            ),
                          );
                        });
                  }),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => Get.to(() => CreateProfile()),
                child: Column(
                  children: [
                    Container(
                      height: 52,
                      width: 332,
                      decoration:
                          BoxDecoration(color: kPrimaryColor, borderRadius: BorderRadius.circular(9), border: Border.all(color: kPrimaryColor)),
                      child: const Center(
                        child: Text(
                          ' Create New Profile',
                          style: TextStyle(fontSize: 20, color: kWhiteColor, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ]),
          ),

          // requirements
          Form(
            key: controller.formKeyRequirements,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Gender (Requirement Screen)
                  TextFormField(
                    controller: controller.genderController,
                    readOnly: true,
                    onTap: () => controller.selectGender(),
                    keyboardType: TextInputType.text,
                    style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                    decoration: InputDecoration(
                      labelText: "Gender",
                      labelStyle: fontBody(fontSize: 16, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                      suffixIcon: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/dropdown_icon.png", width: 20),
                        ],
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff000000), width: 2)),
                    ),
                    validator: genderValidator,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: controller.languageController,
                    readOnly: true,
                    onTap: () => controller.selectLanguage(),
                    keyboardType: TextInputType.text,
                    style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                    decoration: InputDecoration(
                      labelText: "Language",
                      labelStyle: fontBody(fontSize: 16, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                      suffixIcon: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/dropdown_icon.png", width: 20),
                        ],
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff000000), width: 2)),
                    ),
                    validator: genderValidator,
                  ),
                ],
              ),
            ),
          ),

          //Schedule Type

          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 28.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: Center(
                    child: Text(
                      "What type of schedule\n are you looking for?",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontFamily: "Poppins", color: Colors.grey.shade400),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.selectedItems.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 38.0, vertical: 10.0),
                      child: Obx(
                        () => ListTile(
                            selected: controller.selectedIndex.value == index ? true : false,
                            shape: RoundedRectangleBorder(
                              side: controller.selectedIndex.value == index
                                  ? const BorderSide(color: Color(0xFF49DDC4))
                                  : const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            selectedColor: const Color(0xFF49DDC4),
                            title: Text(
                              controller.selectedItems[index].toString(),
                              textScaleFactor: 1.2,
                              textAlign: TextAlign.center,
                              style:
                                  controller.selectedIndex.value == index ? const TextStyle(color: Color(0xFF49DDC4)) : TextStyle(color: Colors.grey),
                            ),
                            onTap: () {
                              controller.selectType(index);
                              print(controller.selectedItems[index]);
                            }),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          //Calendar

          Obx(
            () => controller.selectedItems[controller.selectedIndex.value] == "Recurring"
                ? ListView(
                    shrinkWrap: true,
                    //  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Recurring Months : ",
                            style: fontBody(fontSize: 17),
                          ),
                          SizedBox(
                            height: 30,
                            width: 70,
                            child: TextFormField(
                              controller: controller.monthController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: fontBody(fontSize: 18),
                            ),
                          ),
                          Text(
                            "months",
                            style: fontBody(fontSize: 17),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 150),
                        width: Get.width,
                        height: 80,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: kWhiteColor),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: controller.weekdays.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                //
                                if (controller.selectedDays.contains(controller.weekdays[index])) {
                                  controller.selectedDays.remove(controller.weekdays[index]);
                                } else {
                                  controller.selectedDays.add(controller.weekdays[index]);
                                }
                              },
                              child: Obx(
                                () => controller.selectedDays.contains(controller.weekdays[index])
                                    ? Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                            color: kPrimaryColor,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: kBlackColor.withOpacity(0.3))),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            controller.weekdays[index],
                                            style: const TextStyle(color: kWhiteColor),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                            color: kWhiteColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: kPrimaryColor)),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            controller.weekdays[index],
                                            style: const TextStyle(color: kBlackColor),
                                          ),
                                        ),
                                      ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const SizedBox(width: 10);
                          },
                        ),
                      ),
                    ],
                  )
                /* CalendarCarousel<Event>(
                    onDayPressed: (date, events) {
                      controller.addAvailability(date);
                    },
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
                      if (controller.availability.contains(day)) {
                        return Container(
                          decoration: const BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle),
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
                  weekFormat: true,


                    todayTextStyle: const TextStyle(color: Colors.tealAccent),
                    multipleMarkedDates: MultipleMarkedDates(markedDates: [ ]),
                    weekdayTextStyle: const TextStyle(color: kPrimaryColor),
                    headerTextStyle: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w500, fontSize: 24),
                    selectedDateTime: DateTime.now(),
                    minSelectedDate: DateTime.now(),

                    selectedDayButtonColor: Colors.grey.withOpacity(0.4),
                    onDayLongPressed: (DateTime date) {
                      controller.deleteAvailability(date);
                    },
                  )*/
                : CalendarCarousel<Event>(
                    onDayPressed: (date, events) {
                      controller.addAvailability(date);
                    },
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
                      if (controller.availability.contains(day)) {
                        return Container(
                          decoration: const BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle),
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
                    todayTextStyle: const TextStyle(color: Colors.tealAccent),
                    multipleMarkedDates: MultipleMarkedDates(markedDates: []),
                    weekdayTextStyle: const TextStyle(color: kPrimaryColor),
                    headerTextStyle: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w500, fontSize: 24),
                    selectedDateTime: DateTime.now(),
                    minSelectedDate: DateTime.now(),
                    selectedDayButtonColor: Colors.grey.withOpacity(0.4),
                    onDayLongPressed: (DateTime date) {
                      controller.deleteAvailability(date);
                    },
                  ),
          ),

          //drag drop
          /*controller.selectedItems[controller.selectedIndex.value] == "Recurring"
              ? Column(
            children: [
              const SizedBox(height: 40),
              Text(
                "Which days do you need care?",
                style: fontBody(fontSize: 15, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  height: 300,
                  decoration: const BoxDecoration(color: kWhiteColor, borderRadius: BorderRadius.vertical(bottom: Radius.circular(35))),
                  child: Obx(
                        () => ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.selectedDays.length,
                        itemBuilder: (context, index) {
                          DateTime day = controller.selectedDays[index] as DateTime;
                          return DragTarget<Map>(
                            builder: (BuildContext context, List accepted, List rejected) {
                              return Container(
                                width: 100,
                                height: 200,
                                color: kWhiteColor,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("${day.day}", style: fontBody(fontWeight: FontWeight.w500, fontSize: 12, fontColor: kBlackColor)),
                                    Expanded(
                                      child: Container(
                                        width: 50,
                                        margin: const EdgeInsets.only(top: 10, bottom: 20),
                                        padding: const EdgeInsets.all(8),
                                        decoration: ShapeDecoration(
                                          color: kPrimaryColor,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(getWeekDay(day).toUpperCase(),
                                                style: fontBody(fontWeight: FontWeight.w500, fontSize: 12, fontColor: kBlackColor)),
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: List.generate(
                                                    controller.daysTask[DateFormat("dd-MM-yyyy").format(day)].length,
                                                        (index) => Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                      child: Image.asset(controller.daysTask[DateFormat("dd-MM-yyyy").format(day)][index]["icon"],
                                                          width: 30, color: kWhiteColor),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onAccept: (Map draggedService) {
                              String date = DateFormat("dd-MM-yyyy").format(day);

                              draggedService["startTime"] = "9:00 AM";
                              draggedService["endTime"] = "12:00 PM";

                              List kochu = controller.daysTask[date];
                              if (kochu.isNotEmpty) {
                                kochu.add(draggedService);
                                controller.daysTask[date] = kochu;
                              } else {
                                controller.daysTask[date] = [draggedService];
                              }
                            },
                          );
                        }),
                  ),
                ),
              ),
              Text(
                "Drag and drop services to days",
                style: fontBody(fontSize: 15, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
              ),
              Container(
                  margin: const EdgeInsets.only(top: 25, bottom: 40),
                  height: 165,
                  decoration:
                  const BoxDecoration(color: Color(0xffFBFBFB), border: Border.symmetric(horizontal: BorderSide(color: Color(0xffBFBFBF), width: 1))),
                  child: Obx(
                        () => ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        Map service = controller.careServices[index];
                        return Center(
                          child: Draggable<Map>(
                            data: service,
                            feedback: Container(
                              padding: const EdgeInsets.all(10),
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                  color: kPrimaryColor,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: kPrimaryColor),
                                  boxShadow: [BoxShadow(color: kBlackColor.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    service["icon"],
                                    width: 30,
                                    height: 35,
                                    color: kWhiteColor.withOpacity(0.7),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    service["name"],
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    style: fontBody(fontSize: 11, fontColor: kWhiteColor.withOpacity(0.7)),
                                  )
                                ],
                              ),
                            ),
                            childWhenDragging: Container(
                              padding: const EdgeInsets.all(10),
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                  color: kWhiteColor,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: kPrimaryColor),
                                  boxShadow: [BoxShadow(color: kBlackColor.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    service["icon"],
                                    width: 30,
                                    height: 35,
                                    color: kPrimaryColor,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    service["name"],
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: fontBody(fontSize: 11, fontColor: kPrimaryColor),
                                  )
                                ],
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                  color: kWhiteColor,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: kPrimaryColor),
                                  boxShadow: [BoxShadow(color: kBlackColor.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    service["icon"],
                                    width: 30,
                                    height: 35,
                                    color: kPrimaryColor,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    service["name"],
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: fontBody(fontSize: 11, fontColor: kPrimaryColor),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const SizedBox(width: 20),
                      itemCount: controller.careServices.length,
                    ),
                  ))
            ],
          )
              :*/
          Obx(
            () => controller.selectedItems[controller.selectedIndex.value] == "Recurring"
                ?

            Column(
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        "Which days do you need care?",
                        style: fontBody(fontSize: 15, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                      ),
                      Expanded(
                        child: GetBuilder<LongTermController>(
                          builder: (context) {
                            return Container(
                              margin: const EdgeInsets.only(top: 20),
                              height: 300,
                              decoration: const BoxDecoration(color: kWhiteColor, borderRadius: BorderRadius.vertical(bottom: Radius.circular(35))),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: controller.selectedDays.length,
                                  itemBuilder: (context, index) {
                                    String day = controller.selectedDays[index];
                                    return DragTarget<Map>(
                                      builder: (BuildContext context, List accepted, List rejected) {
                                        return Container(
                                          width: 100,
                                          height: 200,
                                          color: kWhiteColor,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text("${day}", style: fontBody(fontWeight: FontWeight.w500, fontSize: 12, fontColor: kBlackColor)),
                                              Expanded(
                                                child: Container(
                                                  width: 50,
                                                  margin: const EdgeInsets.only(top: 10, bottom: 20),
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: ShapeDecoration(
                                                    color: kPrimaryColor,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Expanded(
                                                        child: SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: List.generate(
                                                              controller.wdays[day].length,
                                                              (index) => Padding(
                                                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                                child: Image.asset(controller.wdays[day][index]["icon"], width: 30, color: kWhiteColor),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      onAccept: (Map draggedService) async {

                                        // var a=controller.selectTime(draggedService: draggedService, context: context);
                                        var a= await Get.defaultDialog(
                                            title: 'Select time',
                                            content: Container(
                                              width: 100.w,
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Container(
                                                            height:80,
                                                            width: 60,
                                                            decoration: BoxDecoration(
                                                                border: Border.all(color: kPrimaryColor,width: 2),
                                                                borderRadius: BorderRadius.circular(10)
                                                            ),
                                                            child: Center(
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [
                                                                  Image.asset(draggedService['icon'],
                                                                    height: 30,
                                                                    width: 30,),
                                                                  SizedBox(height: 10,),
                                                                  Center(child: Text(draggedService['name'],style: TextStyle(fontSize: 10,color: kPrimaryColor),),)
                                                                ],
                                                              ),
                                                            )),

                                                        Container(
                                                          width: 10.w,
                                                          child: Divider(
                                                            height: 2,
                                                            color: kPrimaryColor,
                                                            thickness: 3,
                                                          ),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Column(
                                                              children: [
                                                                Text('Start Time',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),
                                                                SizedBox(width: 15,),
                                                                InkWell(
                                                                    onTap: () {
                                                                      Duration initialtimer = const Duration();
                                                                      DatePicker.showTime12hPicker(
                                                                        context,
                                                                        onConfirm: (selected) {
                                                                          draggedService["startTime"] =
                                                                              DateFormat("jms").format(selected);
                                                                          controller.startTime.value= draggedService["startTime"];
                                                                        },
// minTime: DateTime.now(),
// maxTime: DateTime(2030, 12, 31),
                                                                        onChanged: (date) {
                                                                          draggedService["startTime"] =
                                                                              DateFormat("jms").format(date);
                                                                          controller.startTime.value=draggedService["startTime"];
                                                                          print('change $date');
                                                                        },
                                                                        currentTime: DateTime.tryParse('10:00:00'),
                                                                      );
                                                                    },
                                                                    child:Obx(()=>controller.startTime.value!=''?
                                                                    Text(controller.startTime.value,style: TextStyle(fontWeight: FontWeight.bold),):Text(draggedService['startTime'])
                                                                    )
                                                                )
                                                              ],
                                                            ),
                                                            SizedBox(width: 10,),
                                                            Column(
                                                              children: [
                                                                Text('End Time',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),
                                                                SizedBox(width: 15,),
                                                                InkWell(
                                                                    onTap: () {
                                                                      Duration initialtimer = const Duration();
                                                                      DatePicker.showTime12hPicker(
                                                                        context,
                                                                        onConfirm: (selected) {
                                                                          draggedService["endTime"] =
                                                                              DateFormat("jms").format(selected);
                                                                          controller.endTime.value= draggedService["endTime"];
                                                                        },
// minTime: DateTime.now(),
// maxTime: DateTime(2030, 12, 31),
                                                                        onChanged: (date) {
                                                                          draggedService["endTime"] =
                                                                              DateFormat("jms").format(date);
                                                                          controller.endTime.value=draggedService["endTime"];
                                                                          print('change $date');
                                                                        },
                                                                        currentTime: DateTime.tryParse('12:00:00'),
                                                                      );
                                                                    },
                                                                    child:Obx(()=>controller.endTime.value!=''?
                                                                    Text(controller.endTime.value,style: TextStyle(fontWeight: FontWeight.bold),):Text(draggedService['startTime'],style: TextStyle(fontWeight: FontWeight.bold),)
                                                                    )
                                                                )
                                                              ],
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10,),
                                                  TextButton(onPressed: (){
                                                    Get.back();
                                                  }, child: Text('Done',style: TextStyle(color: kPrimaryColor,fontSize: 16),))

                                                ],
                                              ),
                                            ));
                                        // draggedService["startTime"] = "9:00 AM";
                                        // draggedService["endTime"] = "12:00 PM";

                                        print(draggedService);
                                        List kochu = controller.wdays[day];
                                        if (kochu.isNotEmpty) {
                                          kochu.add(draggedService);
                                          controller.wdays[day] = kochu;
                                        } else {
                                          controller.wdays[day] = [draggedService];
                                        }

                                        controller.callUpdate();
                                      },
                                    );
                                  }),
                            );
                          }
                        ),
                      ),
                      Text(
                        "Drag and drop services to days",
                        style: fontBody(fontSize: 15, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                      ),
                      Container(
                          margin: const EdgeInsets.only(top: 25, bottom: 40),
                          height: 165,
                          decoration: const BoxDecoration(
                              color: Color(0xffFBFBFB), border: Border.symmetric(horizontal: BorderSide(color: Color(0xffBFBFBF), width: 1))),
                          child: Obx(
                            () => ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                Map service = controller.careServices[index];
                                return Center(
                                  child: Draggable<Map>(
                                    data: service,
                                    feedback: Container(
                                      padding: const EdgeInsets.all(10),
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                          color: kPrimaryColor,
                                          borderRadius: BorderRadius.circular(8.0),
                                          border: Border.all(color: kPrimaryColor),
                                          boxShadow: [BoxShadow(color: kBlackColor.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            service["icon"],
                                            width: 30,
                                            height: 35,
                                            color: kWhiteColor.withOpacity(0.7),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            service["name"],
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            style: fontBody(fontSize: 11, fontColor: kWhiteColor.withOpacity(0.7)),
                                          )
                                        ],
                                      ),
                                    ),
                                    childWhenDragging: Container(
                                      padding: const EdgeInsets.all(10),
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                          color: kWhiteColor,
                                          borderRadius: BorderRadius.circular(8.0),
                                          border: Border.all(color: kPrimaryColor),
                                          boxShadow: [BoxShadow(color: kBlackColor.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            service["icon"],
                                            width: 30,
                                            height: 35,
                                            color: kPrimaryColor,
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            service["name"],
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                            style: fontBody(fontSize: 11, fontColor: kPrimaryColor),
                                          )
                                        ],
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                          color: kWhiteColor,
                                          borderRadius: BorderRadius.circular(8.0),
                                          border: Border.all(color: kPrimaryColor),
                                          boxShadow: [BoxShadow(color: kBlackColor.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            service["icon"],
                                            width: 30,
                                            height: 35,
                                            color: kPrimaryColor,
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            service["name"],
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                            style: fontBody(fontSize: 11, fontColor: kPrimaryColor),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) => const SizedBox(width: 20),
                              itemCount: controller.careServices.length,
                            ),
                          ))
                    ],
                  )
                : Column(   //SINGLE DAY
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        "Which days do you need care?",
                        style: fontBody(fontSize: 15, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                      ),
                      Expanded(
                        child: GetBuilder<LongTermController>(
                          // init: LongTermController(),
                          builder: (context) {
                            return Container(
                              margin: const EdgeInsets.only(top: 20),
                              height: 300,
                              decoration: const BoxDecoration(color: kWhiteColor, borderRadius: BorderRadius.vertical(bottom: Radius.circular(35))),
                              child: Obx(
                                () => ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: controller.availability.length,
                                    itemBuilder: (context, index) {
                                      DateTime day = controller.availability[index];
                                      return DragTarget<Map>(
                                        builder: (BuildContext context, List accepted, List rejected) {
                                          return Container(
                                            width: 100,
                                            height: 200,
                                            color: kWhiteColor,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text("${day.day}", style: fontBody(fontWeight: FontWeight.w500, fontSize: 12, fontColor: kBlackColor)),
                                                Expanded(
                                                  child: Container(
                                                    width: 50,
                                                    margin: const EdgeInsets.only(top: 10, bottom: 20),
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: ShapeDecoration(
                                                      color: kPrimaryColor,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(getWeekDay(day).toUpperCase(),
                                                            style: fontBody(fontWeight: FontWeight.w500, fontSize: 12, fontColor: kBlackColor)),
                                                        Expanded(
                                                          child: SingleChildScrollView(
                                                            child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: List.generate(
                                                                controller.daysTask[DateFormat("dd-MM-yyyy").format(day)].length,
                                                                (index) => Padding(
                                                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                                  child: Image.asset(
                                                                      controller.daysTask[DateFormat("dd-MM-yyyy").format(day)][index]["icon"],
                                                                      width: 30,
                                                                      color: kWhiteColor),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        onAccept: (Map draggedService) async {
                                          String date = DateFormat("dd-MM-yyyy").format(day);

                                          // var a=controller.selectTime(draggedService: draggedService, context: context);
                                          var a= await Get.defaultDialog(barrierDismissible: false,
                                              title: 'Select time',
                                              content: Container(
                                                width: 100.w,
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Container(
                                                              height:80,
                                                              width: 60,
                                                              decoration: BoxDecoration(
                                                                border: Border.all(color: kPrimaryColor,width: 2),
                                                                borderRadius: BorderRadius.circular(10)
                                                              ),
                                                              child: Center(
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                                Image.asset(draggedService['icon'],
                                                                  height: 30,
                                                                  width: 30,),
                                                                SizedBox(height: 10,),
                                                                Center(child: Text(draggedService['name'],style: TextStyle(fontSize: 10,color: kPrimaryColor),),)
                                                            ],
                                                          ),
                                                              )),

                                                          Container(
                                                            width: 10.w,
                                                            child: Divider(
                                                              height: 2,
                                                              color: kPrimaryColor,
                                                              thickness: 3,
                                                            ),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Column(
                                                                children: [
                                                                  Text('Start Time',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),
                                                                  SizedBox(width: 15,),
                                                                  InkWell(
                                                                      onTap: () {
                                                                        Duration initialtimer = const Duration();
                                                                        DatePicker.showTime12hPicker(
                                                                          context,
                                                                          onConfirm: (selected) {
                                                                            draggedService["startTime"] =
                                                                                DateFormat("jms").format(selected);
                                                                            controller.startTime.value= draggedService["startTime"];
                                                                          },
// minTime: DateTime.now(),
// maxTime: DateTime(2030, 12, 31),
                                                                          onChanged: (date) {
                                                                            draggedService["startTime"] =
                                                                                DateFormat("jms").format(date);
                                                                            controller.startTime.value=draggedService["startTime"];
                                                                            print('change $date');
                                                                          },
                                                                          currentTime: DateTime.tryParse('10:00:00'),
                                                                        );
                                                                      },
                                                                      child:Obx(()=>controller.startTime.value!=''?
                                                                      Text(controller.startTime.value,style: TextStyle(fontWeight: FontWeight.bold),):Text(draggedService['startTime'])
                                                                      )
                                                                  )
                                                                ],
                                                              ),
                                                              SizedBox(width: 10,),
                                                              Column(
                                                                children: [
                                                                  Text('End Time',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),
                                                                  SizedBox(width: 15,),
                                                                  InkWell(
                                                                      onTap: () {
                                                                        Duration initialtimer = const Duration();
                                                                        DatePicker.showTime12hPicker(
                                                                          context,
                                                                          onConfirm: (selected) {
                                                                            draggedService["endTime"] =
                                                                                DateFormat("jms").format(selected);
                                                                            controller.endTime.value= draggedService["endTime"];
                                                                          },
// minTime: DateTime.now(),
// maxTime: DateTime(2030, 12, 31),
                                                                          onChanged: (date) {
                                                                            draggedService["endTime"] =
                                                                                DateFormat("jms").format(date);
                                                                            controller.endTime.value=draggedService["endTime"];
                                                                            print('change $date');
                                                                          },
                                                                          currentTime: DateTime.tryParse('12:00:00'),
                                                                        );
                                                                      },
                                                                      child:Obx(()=>controller.endTime.value!=''?
                                                                      Text(controller.endTime.value,style: TextStyle(fontWeight: FontWeight.bold),):Text(draggedService['startTime'],style: TextStyle(fontWeight: FontWeight.bold),)
                                                                      )
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(height: 10,),
                                                    TextButton(onPressed: (){
                                                      if(draggedService["startTime"]==null){
                                                        controller.startTime.value='09:00 AM';
                                                        draggedService["startTime"]= controller.startTime.value;
                                                        print(controller.startTime.value);

                                                      }
                                                      if(draggedService["endTime"]==null){
                                                        controller.endTime.value='12:00 PM';
                                                        draggedService["endTime"]= controller.endTime.value;
                                                        print(controller.endTime.value);
                                                      }

                                                      Get.back();
                                                    }, child: Text('Done',style: TextStyle(color: kPrimaryColor,fontSize: 16),))

                                                  ],
                                                ),
                                              ));
                                          // draggedService["startTime"] = "9:00 AM";
                                          // draggedService["endTime"] = "12:00 PM";
                                          print(draggedService);

                                          List kochu = controller.daysTask[date];
                                          if (kochu.isNotEmpty) {
                                            kochu.add(draggedService);
                                            controller.daysTask[date] = kochu;
                                          } else {
                                            controller.daysTask[date] = [draggedService];
                                          }
                                          controller.callUpdate();
                                        },
                                      );
                                    }),
                              ),
                            );
                          }
                        ),
                      ),
                      Text(
                        "Drag and drop services to days",
                        style: fontBody(fontSize: 15, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                      ),
                      Container(
                          margin: const EdgeInsets.only(top: 25, bottom: 40),
                          height: 165,
                          decoration: const BoxDecoration(
                              color: Color(0xffFBFBFB), border: Border.symmetric(horizontal: BorderSide(color: Color(0xffBFBFBF), width: 1))),
                          child: Obx(
                            () => ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                Map service = controller.careServices[index];
                                return Center(
                                  child: Draggable<Map>(
                                    data: service,
                                    feedback: Container(
                                      padding: const EdgeInsets.all(10),
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                          color: kPrimaryColor,
                                          borderRadius: BorderRadius.circular(8.0),
                                          border: Border.all(color: kPrimaryColor),
                                          boxShadow: [BoxShadow(color: kBlackColor.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            service["icon"],
                                            width: 30,
                                            height: 35,
                                            color: kWhiteColor.withOpacity(0.7),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            service["name"],
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            style: fontBody(fontSize: 11, fontColor: kWhiteColor.withOpacity(0.7)),
                                          )
                                        ],
                                      ),
                                    ),
                                    childWhenDragging: Container(
                                      padding: const EdgeInsets.all(10),
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                          color: kWhiteColor,
                                          borderRadius: BorderRadius.circular(8.0),
                                          border: Border.all(color: kPrimaryColor),
                                          boxShadow: [BoxShadow(color: kBlackColor.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            service["icon"],
                                            width: 30,
                                            height: 35,
                                            color: kPrimaryColor,
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            service["name"],
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                            style: fontBody(fontSize: 11, fontColor: kPrimaryColor),
                                          )
                                        ],
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                          color: kWhiteColor,
                                          borderRadius: BorderRadius.circular(8.0),
                                          border: Border.all(color: kPrimaryColor),
                                          boxShadow: [BoxShadow(color: kBlackColor.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            service["icon"],
                                            width: 30,
                                            height: 35,
                                            color: kPrimaryColor,
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            service["name"],
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                            style: fontBody(fontSize: 11, fontColor: kPrimaryColor),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) => const SizedBox(width: 20),
                              itemCount: controller.careServices.length,
                            ),
                          ))
                    ],
                  ),
          ),

          //location
          Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Obx(
                      () => GoogleMap(
                        mapType: MapType.normal,
                        markers: {},
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
                        initialCameraPosition: CameraPosition(
                          target: controller.pastUserLocation.isEmpty
                              ? const LatLng(37.42796133580664, -122.085749655962)
                              : LatLng(controller.pastUserLocation["latitude"], controller.pastUserLocation["longitude"]),
                          zoom: 14.4746,
                        ),
                        onMapCreated: (GoogleMapController gmcomtroller) {
                          controller.googleMapController.complete(gmcomtroller);
                        },
                        onCameraMove: (position) {

                          controller.searchLocationPoint = GeoPoint(position.target.latitude, position.target.longitude);
                          print(controller.searchLocationPoint.longitude);
                          },

                      ),
                    ),
                    Image.asset('assets/marker.png', width: 25),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  textInputAction: TextInputAction.done,
                  controller: controller.searchLocationController,
                  decoration: InputDecoration(
                    hintText: "Enter Address",
                    hintStyle: fontBody(fontColor: Colors.grey, fontSize: 16),
                    suffixIcon: TextButton(
                      onPressed: () {
                        controller.updateLocation();
                        controller.getCurrentPosition();
                        print(controller.currectLocation);
                        print(controller.searchLocationPoint.longitude);
                      },
                      child: Text(
                        "Locate",
                        style: fontBody(fontSize: 12, fontColor: kPrimaryColor),
                      ),
                    ),

                    //Icon(Icons.map_outlined,color: Color(0xFF49DDC4)),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),

          //price
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(18.0),
                child: Text(
                  "Rate",
                  // "Hourly Rate",
                  style: TextStyle(fontFamily: "Poppins", fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "\$15",
                    style: TextStyle(fontFamily: "Poppins", fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF49DDC4)),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.30,
                  ),
                  const Text(
                    "\$45",
                    style: TextStyle(fontFamily: "Poppins", fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF49DDC4)),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.30,
                  ),
                  const Text(
                    "\$75",
                    style: TextStyle(fontFamily: "Poppins", fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF49DDC4)),
                  ),
                ],
              ),
              Obx(() {
                return Slider(
                  min: 15.0,
                  max: 75.0,
                  activeColor: Color(0xFF49DDC4),
                  inactiveColor: Colors.grey[300],
                  value: controller.priceRange.value,
                  divisions: 10,
                  label: '${controller.priceRange.round()}',
                  onChanged: (value) {
                    controller.pRange(value);
                    // controller.update();
                  },
                );
              }),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                  child: TextField(
                    controller: controller.descController,
                    maxLength: 500,
                    maxLines: 10,
                    decoration: InputDecoration(
                        counterText: '${controller.descController.text.length.toString()}/500',
                        counterStyle: const TextStyle(color: Colors.grey),
                        hintText: "Enter job description here",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(6),
                        )),
                    onChanged: (jvalue) {
                      controller.rangeValue = jvalue;
                      print(jvalue);
                    },
                  )),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: kWhiteColor,
        child: Obx(() => Container(
              height: kBottomNavigationBarHeight,
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    controller.onNext();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: Text(controller.currentPage.value > 6 ? "Create Schedule" : "Next",
                      style: fontBody(fontSize: 18, fontColor: kWhiteColor, fontWeight: FontWeight.w500)),
                  label: const Icon(Icons.arrow_forward),
                ),
              ),
            )),
      ),
    );
  }
}
