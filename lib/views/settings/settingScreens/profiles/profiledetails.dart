import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hailo/views/settings/settingScreens/profiles/healthcondition.dart';
import 'package:intl/intl.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';

import 'package:hailo/core/constants/colors.dart';
import 'package:hailo/core/common.dart';

class ProfileDetails extends StatefulWidget {
  ProfileDetails({Key? key}) : super(key: key);

  @override
  State<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  var userType = Get.arguments;
  String? relationshipValue;
  String? uid = Get.parameters["uid"];

  final TextEditingController _fname = TextEditingController();
  final TextEditingController _lname = TextEditingController();
  final TextEditingController _dob = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  void selectDate() => Get.bottomSheet(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 270,
            child: ScrollDatePicker(
              minimumDate: DateTime(1950),
              maximumDate: DateTime(2100),
              selectedDate: _selectedDate,
              locale: const Locale('en'),
              onDateTimeChanged: (DateTime value) {
                _selectedDate = value;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: () {
                _dob.text = DateFormat("dd-MM-yyyy").format(_selectedDate);
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                primary: kPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text("Set date", style: fontBody(fontSize: 18, fontColor: kWhiteColor, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      backgroundColor: kWhiteColor);

  @override
  void dispose() {
    _fname.dispose();
    _lname.dispose();
    _dob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Profile Details"),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 48.0),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(
                padding: EdgeInsets.only(left: 55.0),
                child: Text(
                  "Relationship to Profile",
                  style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 55.0, right: 55.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 1, style: BorderStyle.solid), borderRadius: BorderRadius.circular(8)),
                  child: '${userType[0]}' == 'Myself'
                      ? DropdownButton(
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_outlined,
                            color: Colors.teal,
                          ),
                          hint: Text("Select Relationship"),
                          value: relationshipValue,
                          items: const [
                            DropdownMenuItem(
                              child: Text("Myself"),
                              value: "Myself",
                            )
                          ],
                          onChanged: (value) {
                            setState(() {
                              relationshipValue = value.toString();
                            });
                          },
                        )
                      : DropdownButton(
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_outlined,
                            color: Colors.teal,
                          ),
                          hint: Text("Select Relationship"),
                          value: relationshipValue,
                          items: [
                            DropdownMenuItem(
                              child: Text("Mom"),
                              value: "Mom",
                            ),
                            DropdownMenuItem(child: Text("Dad"), value: "Dad"),
                            DropdownMenuItem(child: Text("Brother"), value: "Brother"),
                            DropdownMenuItem(child: Text("Sister"), value: "Sister"),
                            DropdownMenuItem(child: Text("Cousin"), value: "Cousin"),
                            DropdownMenuItem(child: Text("Friend"), value: "Friend"),
                          ],
                          onChanged: (value) {
                            setState(() {
                              relationshipValue = value.toString();
                            });
                          },
                        ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 55.0),
                    child: Text(
                      "Details of that person",
                      style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 55.0, right: 55.0),
                    child: TextField(
                      controller: _fname,
                      cursorColor: Colors.black,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: "First Name",
                        hintText: "First Name",
                        labelStyle: fontBody(fontSize: 16, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        enabledBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                        focusedBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff000000), width: 2)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, left: 55.0, right: 55.0),
                    child: TextField(
                      controller: _lname,
                      cursorColor: Colors.black,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: "Last Name",
                        labelStyle: fontBody(fontSize: 16, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        enabledBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                        focusedBorder:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff000000), width: 2)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, left: 55.0, right: 55.0),
                    child: TextFormField(
                      controller: _dob,
                      keyboardType: TextInputType.text,
                      readOnly: true,
                      onTap: () => selectDate(),
                      style: fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                      decoration: InputDecoration(
                        labelText: "Date of Birth",
                        labelStyle: fontBody(fontSize: 16, fontWeight: FontWeight.w400, fontColor: const Color(0xffB7B7B7)),
                        suffixIcon: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/calender_icon.png", width: 20),
                          ],
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        enabledBorder:
                            OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                        focusedBorder:
                            OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff000000), width: 2)),
                      ),
                      //validator: dobValidator,
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 98.0, horizontal: 50.0),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 13),
                          ),
                          onPressed: () {
                            Get.off(() => HealthCondition(), arguments: [relationshipValue, _fname.text, _lname.text, _dob.text]);
                          },
                          child: const Text(
                            "Create",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, fontFamily: "Poppins"),
                          ),
                        ),
                      ))
                ],
              ),
            ]),
          ),
        ));
  }
}
