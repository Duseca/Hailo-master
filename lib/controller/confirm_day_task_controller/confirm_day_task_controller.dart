import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hailo/models/confirm_task_model.dart';
import 'package:intl/intl.dart';

import '../../core/constants/collections.dart';

class ConfirmTaskController extends GetxController {
  //date list index (inital selected value)
  RxInt datesListIndex = 0.obs;

  //selected date
  // Timestamp? selectedDate;

  RxString selectedDate = "".obs;

  //day task date selector
  void dayTaskDateSelector(
      {required int selectedIndex, required Timestamp date}) {
    datesListIndex.value = selectedIndex;
    // selectedDate = date;

    selectedDate.value = DateFormat("dd-MM-yyyy").format(date.toDate());
  }

  //getting datesWisePayments map and price of the task
  Future<ConfirmTaskModel> getTaskDetails({required String taskId}) async {
    DocumentSnapshot taskData = await longtermCollection.doc(taskId).get();

    int pricePerHour = taskData.get('price');
    RxMap datesWisePayments = {}.obs;
    datesWisePayments.value = taskData.get('datesWisePayments');

    List daysList = taskData.get('days');

    List caregiverServices = taskData.get('caregiverService');

    //initializing task details in ConfirmTaskModel
    ConfirmTaskModel confirmTaskModel = ConfirmTaskModel(
        pricePerHour: pricePerHour.toString(),
        datesWisePaymentsMap: datesWisePayments,
        daysList: daysList,
        caregiverServices: caregiverServices);

    return confirmTaskModel;
  }

  //method to check if the map key's value is an array or a map
  bool isMap({required Map map, required String key}) {
    dynamic value = map[key];
    if (value is List) {
      return false;
    } else if (value is Map) {
      return true;
    }
    return false;
  }

  //method to check if all the payments for the selected task are done
  bool isPaymentDone({required Map datesWisePaymentsMap}) {
    //finding length of datesWisePaymentsMap
    int mapLength = datesWisePaymentsMap.length;
    //initializing a count variable (to check if all the payments are done)
    int count = 0;

    //iterating through each key of the map (to get its all the values at the keys)
    datesWisePaymentsMap.forEach((key, value) {
      //checking if the value at key exists (in the datesWisePaymentsMap)
      if (isMap(map: datesWisePaymentsMap, key: key)) {
        //checking if the payment request map at the key is paid or not
        if (datesWisePaymentsMap[key]['isPaid'] == true) {
          count++;
          log("Payment at $key isPaid: true");
        }
      }
    });

    //matching length of map with the count variable to check if all the payments are done or not
    if (mapLength == count) {
      log("All the payments are done");
      return true;
    } else {
      log("count is: $count");
      log("All the payments are not done");
      return false;
    }
  }

  String careGiverId = "";
  String totalPayment = "";

  //method to initialize payment data (to pay the caregiver)
  void initializePaymentData(
      {required String cId, required String totPayment}) {
    careGiverId = "";
    totalPayment = "";
    careGiverId = cId;
    totalPayment = totPayment;

    log("Care giver id is: $careGiverId");
    log("Total payment is: $totalPayment");
  }
}