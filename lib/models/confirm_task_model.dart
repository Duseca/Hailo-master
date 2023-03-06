import 'package:get/get.dart';

class ConfirmTaskModel {
  String? pricePerHour;
  RxMap? datesWisePaymentsMap;
  List? daysList;
  List? caregiverServices;

  ConfirmTaskModel(
      {required this.pricePerHour,
      required this.datesWisePaymentsMap,
      required this.daysList,
      required this.caregiverServices});
}
