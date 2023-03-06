import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'constants/colors.dart';

TextStyle fontBody({
  Color fontColor = kBlackColor,
  required double fontSize,
  FontWeight fontWeight = FontWeight.normal,
}) =>
    TextStyle(fontSize: fontSize, color: fontColor, fontFamily: 'Poppins', fontWeight: fontWeight);

customToast(String msg) => Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.SNACKBAR,
    timeInSecForIosWeb: 3,
    backgroundColor: kPrimaryColor,
    textColor: kWhiteColor,
    fontSize: 16.0);

String timeDifference(DateTime dateTime) {
  DateTime now = DateTime.now();
  int seconds = now.difference(dateTime).inSeconds;
  if (seconds > 0 && seconds <= 60) return "${seconds}s";
  if (seconds > 60 && seconds <= 3600) return "${seconds ~/ 60}m";
  if (seconds > 3600 && seconds <= 86400) return "${seconds ~/ 3600}h";
  return "${seconds ~/ 86400}d";
}

String calculateAge(String dob) {
  DateTime now = DateTime.now();

  int days = now.difference(DateFormat("dd-MM-yyyy").parse(dob)).inDays;

  return "${days ~/ 365} years old";
}

getWeekDay(DateTime day) {
  return DateFormat("EEE").format(day);
}
