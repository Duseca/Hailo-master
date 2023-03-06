import 'package:get/get.dart';

class CalendarController extends GetxController {
  var availability = <DateTime>[].obs;

  void addAvailability(DateTime date) {
    availability.insert(0, date);
    update();
  }

  Map weekdays = {
    "sun": [
      {
        "name": "Driving",
        "icon": "",
      }
    ],
    "mon": [],
    "tue": [],
    "wed": [],
  };


  void deleteAvailability(DateTime date) {
    availability.remove(date);
    update();
  }
}
