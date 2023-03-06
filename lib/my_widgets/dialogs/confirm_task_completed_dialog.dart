import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hailo/my_widgets/date_container.dart';
import 'package:hailo/my_widgets/day_task_detail_widget.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../controller/confirm_day_task_controller/confirm_day_task_controller.dart';
import '../../core/common.dart';
import '../../core/constants/collections.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/constants.dart';
import '../../models/confirm_task_model.dart';
import '../../views/settings/settingScreens/payment.dart';

void dayTasksCompletedDialog(
    {required String taskId,
    required ConfirmTaskModel confirmTaskModel,
    required String uid}) {
  //finding ConfirmTaskController
  ConfirmTaskController confirmTaskController =
      Get.find<ConfirmTaskController>();
  var selectedCard = {}.obs;
  var userStripeId;
  List eachUserCards = [];
  //initializing initial selected date value
  // confirmTaskController.selectedDate = confirmTaskModel.daysList![0];
  confirmTaskController.selectedDate.value =
      DateFormat("dd-MM-yyyy").format(confirmTaskModel.daysList![0].toDate());

  // List caregiverServices = confirmTaskModel
  //         .datesWisePaymentsMap![confirmTaskController.selectedDate.value]
  //     ['caregiverServices'];

  // log("These are caregiver services: $caregiverServices");
  getUserCards({required userId}) async {
    eachUserCards = [];
    var user =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    userStripeId = user.get('customer_stripe_id');
    try {
      var url = Uri.parse(api + '/get-customer-cards/$userStripeId');
      var response = await http.get(url);
      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');
      var jsonDecoded = jsonDecode(response.body);
      eachUserCards = jsonDecoded['cards'];
      selectedCard.value = eachUserCards.last;
      print('JSON DECODE OF CARDS: ${jsonDecoded}');
      // eachUserCards= jsonDecoded['meditations'];
    } catch (e) {
      print("Error occured: ${e.toString()}");
    }
  }

  Get.dialog(
    AlertDialog(
      scrollable: true,
      content: Column(
        children: [
          SizedBox(
            height: 2.w,
          ),

          //dates
          SizedBox(
            height: 20.w,
            width: 100.w,
            child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: confirmTaskModel.daysList!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Obx(() {
                      return DateContainer(
                        date: confirmTaskModel.daysList![index].toDate(),
                        isActive:
                            confirmTaskController.datesListIndex.value == index
                                ? true
                                : false,
                        onSelect: () {
                          confirmTaskController.dayTaskDateSelector(
                              date: confirmTaskModel.daysList![index],
                              selectedIndex: index);

                          //getting total payment for the selected date (if there exists any)
                          String totPayment = confirmTaskController.isMap(
                                      map: confirmTaskModel
                                          .datesWisePaymentsMap!.value,
                                      key: confirmTaskController
                                          .selectedDate.value) ==
                                  true
                              ? confirmTaskModel.datesWisePaymentsMap![
                                      confirmTaskController.selectedDate]
                                  ['totalPayment']
                              : '0';

                          String cId = confirmTaskController.isMap(
                                      map: confirmTaskModel
                                          .datesWisePaymentsMap!.value,
                                      key: confirmTaskController
                                          .selectedDate.value) ==
                                  true
                              ? confirmTaskModel.datesWisePaymentsMap![
                                      confirmTaskController.selectedDate]
                                  ['careGiverId']
                              : '0';

                          //initializing total payment
                          confirmTaskController.initializePaymentData(
                              cId: cId, totPayment: totPayment);
                        },
                      );
                    }),
                  );
                }),
          ),

          SizedBox(
            height: 2.w,
          ),

          //services
          Container(
            height: 10.w,
            width: 100.w,
            alignment: Alignment.center,
            child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: confirmTaskModel.caregiverServices!.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                          color: kPrimaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: kWhiteColor, width: 3)),
                      child: Center(
                        child: Image.asset(
                          confirmTaskModel.caregiverServices![index]["icon"],
                          height: 15,
                          width: 16,
                          color: kWhiteColor,
                        ),
                      ),
                    ),
                  );
                }),
          ),

          //price
          DayTaskDetailWidget(
              title: "Price",
              subtitle: "\$${confirmTaskModel.pricePerHour} per hour"),

          SizedBox(
            height: 1.h,
          ),

          //work hours
          Obx(() {
            return DayTaskDetailWidget(
                title: "Work Hours",
                subtitle:
                    "${confirmTaskController.isMap(map: confirmTaskModel.datesWisePaymentsMap!.value, key: confirmTaskController.selectedDate.value) == true ? confirmTaskModel.datesWisePaymentsMap![confirmTaskController.selectedDate]['noOfHours'] : '0'}");
          }),

          SizedBox(
            height: 1.h,
          ),

          //total payment
          Obx(() {
            return DayTaskDetailWidget(
                title: "Total Payment",
                subtitle:
                    "\$${confirmTaskController.isMap(map: confirmTaskModel.datesWisePaymentsMap!.value, key: confirmTaskController.selectedDate.value) == true ? confirmTaskModel.datesWisePaymentsMap![confirmTaskController.selectedDate]['totalPayment'] : '0'}");
          }),

          SizedBox(
            height: 3.h,
          ),

          //payment heading
          const Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Payment",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          FutureBuilder(
              future: getUserCards(userId: uid),
              builder: (context, data) {
                if (data.connectionState == ConnectionState.done) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Container(
                      height: Get.height * 0.08,
                      width: Get.width * 0.8,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 1, color: kPrimaryColor)),
                      child: Obx(() => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                selectedCard['brand'] == 'Visa'
                                    ? Image.asset(
                                        'assets/visa.png',
                                        height: 40,
                                        width: 40,
                                      )
                                    : Image.asset(
                                        'assets/mastercard.png',
                                        height: 40,
                                        width: 40,
                                      ),
                                Text(
                                  '****  ****  ****  ${selectedCard['last4']}',
                                  style: TextStyle(
                                      color: Colors.black38,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ])),
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      color: kPrimaryColor,
                    ),
                  );
                }
              }),
          SizedBox(
            height: 5,
          ),
          TextButton(
              onPressed: () {
                Get.defaultDialog(
                  title: 'Select card',
                  content: Container(
                    height: Get.height * 0.5,
                    width: Get.width * 0.9,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                            height: Get.height * 0.42,
                            child: FutureBuilder(
                                future: getUserCards(userId: uid),
                                builder: (context, data) {
                                  if (data.connectionState ==
                                      ConnectionState.done) {
                                    return ListView.builder(
                                        itemCount: eachUserCards.length,
                                        itemBuilder: (context, index) {
                                          if (eachUserCards.length > 0) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              child: InkWell(
                                                onTap: () {
                                                  selectedCard.value =
                                                      eachUserCards[index];
                                                  Get.back();
                                                },
                                                child: Container(
                                                  height: Get.height * 0.08,
                                                  width: Get.width * 0.6,
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        eachUserCards[index]
                                                                    ['brand'] ==
                                                                'Visa'
                                                            ? Image.asset(
                                                                'assets/visa.png',
                                                                height: 40,
                                                                width: 40,
                                                              )
                                                            : Image.asset(
                                                                'assets/mastercard.png',
                                                                height: 40,
                                                                width: 40,
                                                              ),
                                                        Text(
                                                          '****  ****  ****  ${eachUserCards[index]['last4']}',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black38,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ]),
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Text(
                                                'No saved cards found !!!');
                                          }
                                        });
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: kPrimaryColor,
                                      ),
                                    );
                                  }
                                })),

                        InkWell(
                          onTap: () {
                            Get.to(() => PaymentSheetScreen(
                                  userId: uid,
                                  customerStripeID: userStripeId,
                                ));
                          },
                          child: Container(
                            height: 50,
                            width: 194,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9),
                                color: kPrimaryColor),
                            child: Center(
                                child: Text(
                              'Add card',
                              style: fontBody(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  fontColor: kWhiteColor),
                            )),
                          ),
                        )

                        // if (tokenData != null)
                        //   ResponseCard(
                        //     response: tokenData!.toJson().toPrettyString(),
                        //   )
                      ],
                    ),
                  ),
                );
              },
              child: Text(
                'Select other card',
                style: TextStyle(color: kPrimaryColor),
              )),
          //pay button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: GestureDetector(
              onTap: () async {
                //getting total payment for the selected date (if there exists any)
                String totPayment = confirmTaskController.isMap(
                            map: confirmTaskModel.datesWisePaymentsMap!.value,
                            key: confirmTaskController.selectedDate.value) ==
                        true
                    ? confirmTaskModel.datesWisePaymentsMap![
                        confirmTaskController.selectedDate]['totalPayment']
                    : '0';

                String cId = confirmTaskController.isMap(
                            map: confirmTaskModel.datesWisePaymentsMap!.value,
                            key: confirmTaskController.selectedDate.value) ==
                        true
                    ? confirmTaskModel.datesWisePaymentsMap![
                        confirmTaskController.selectedDate]['careGiverId']
                    : '0';

                //initializing total payment
                confirmTaskController.initializePaymentData(
                    cId: cId, totPayment: totPayment);

                log("selected date is: ${confirmTaskController.selectedDate}");

                if (confirmTaskController.totalPayment == '0') {
                  customToast("Nothing to pay");
                } else {
                  //showing please wait toast
                  customToast('Please wait');
                  // //getting already existing map of datesWisePayments
                  var taskData = await longtermCollection.doc(taskId).get();

                  Map datesWisePaymentsMap = taskData.get('datesWisePayments');

                  //appending new date wise payment request to old map
                  datesWisePaymentsMap[confirmTaskController.selectedDate]
                      ['isPaid'] = true;
                  if (confirmTaskController.isPaymentDone(
                      datesWisePaymentsMap: datesWisePaymentsMap)) {
                    await payToStripe(
                        customerId: userStripeId,
                        cardId: selectedCard['id'],
                        amount:
                            (double.parse(confirmTaskController.totalPayment) *
                                    100)
                                .toInt()
                                .toString());
                    if (paymentDone == true) {
                      log("All the payments are done");
                      //testing start
                      var doc = await jobsCollection.doc(taskId).get();

                      await jobsCollection.doc(taskId).update({
                        "isStarted": false,
                        "status": "done",
                      });

                      await longtermCollection.doc(taskId).update({
                        "isCompleted": true,
                        "jobStatus": "done",
                      });

                      Map<String, dynamic> withdrawalCreationMap = {
                        "caretakerUid": confirmTaskController.careGiverId,
                        "userUid": FirebaseAuth.instance.currentUser!.uid,
                        "day": DateFormat('dd-MM-yyyy').format(DateTime.now()),
                        "month": DateFormat('MMM-yyyy').format(DateTime.now()),
                        "time": DateTime.now(),
                        "price": int.parse(confirmTaskController.totalPayment),
                        "isPending": true,
                      };

                      await FirebaseFirestore.instance
                          .collection("transactionPending")
                          .doc(taskId)
                          .delete(); // to be done on map iteration on client app

                      await FirebaseFirestore.instance
                          .collection("withdrawal")
                          .add(withdrawalCreationMap);

                      //updating datesWisePayments map
                      await longtermCollection
                          .doc(taskId)
                          .update({'datesWisePayments': datesWisePaymentsMap});

                      // showRating(doc["cid"]);

                      //testing end}
                    }
                  } else {
                    await payToStripe(
                        customerId: userStripeId,
                        cardId: selectedCard['id'],
                        amount:
                            (double.parse(confirmTaskController.totalPayment) *
                                    100)
                                .toInt()
                                .toString());
                    log("All the payments are not done yet");
                    if (paymentDone == true) {
                      Map<String, dynamic> withdrawalCreationMap = {
                        "caretakerUid": confirmTaskController.careGiverId,
                        "userUid": FirebaseAuth.instance.currentUser!.uid,
                        "day": DateFormat('dd-MM-yyyy').format(DateTime.now()),
                        "month": DateFormat('MMM-yyyy').format(DateTime.now()),
                        "time": DateTime.now(),
                        "price": int.parse(confirmTaskController.totalPayment),
                        "isPending": true,
                      };

                      log("withdrawalCreationMap is: $withdrawalCreationMap");
                      await FirebaseFirestore.instance
                          .collection("withdrawal")
                          .add(withdrawalCreationMap);

                      //updating datesWisePayments map
                      await longtermCollection
                          .doc(taskId)
                          .update({'datesWisePayments': datesWisePaymentsMap});
                    }
                  }
                  log("Updated datesWisePayments map is: $datesWisePaymentsMap");
                }

                //disposing ConfirmTaskController
                Get.delete<ConfirmTaskController>();
                Get.back();
              },
              child: Container(
                height: 59,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    color: kPrimaryColor),
                child: const Center(
                  child: Text(
                    'Pay',
                    style: TextStyle(
                        fontSize: 18,
                        color: kWhiteColor,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      actions: [
        TextButton(
          child: const Text(
            "Close",
            style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            log("This is selected date: ${confirmTaskController.selectedDate}");
            //disposing ConfirmTaskController
            Get.delete<ConfirmTaskController>();
            Get.back();
          },
        ),
      ],
    ),
  );
}

var paymentDone = false;
payToStripe({required customerId, required cardId, required amount}) async {
  try {
    var url = Uri.parse('$api/create-charge');
    print(url);
    Map body = {
      "amount": amount,
      "currency": "usd",
      "customer": customerId,
      "source": cardId,
      "description": "description"
    };
    print(json.encode(body));
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: json.encode(body));
    if (response.statusCode == 200) {
      paymentDone = true;
      customToast('Payment done successfully');
    } else {
      paymentDone = false;
      customToast(
          'Payment not done due to some error, please check if your card is working');
    }
  } catch (e) {
    paymentDone = false;
    print("ERROR OCCURED : ${e.toString()}");
  }
}
