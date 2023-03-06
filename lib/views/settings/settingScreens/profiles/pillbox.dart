import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/common.dart';
import '../../../../core/constants/colors.dart';
import '../../../root.dart';

class PillBox extends StatefulWidget {
  PillBox({Key? key}) : super(key: key);

  @override
  State<PillBox> createState() => _PillBoxState();
}

class _PillBoxState extends State<PillBox> {
  _PillBoxState() {
    selectedValue = menuitems[0];
  }
  final List<String> menuitems = ['1', '2', '3', '4', '5'];

  String? uid = Get.parameters["uid"];
  var userType = Get.arguments;

  String? selectedValue;
  TextEditingController _pillController = TextEditingController();
  TextEditingController hourControler = TextEditingController();
  TextEditingController minuteController = TextEditingController();
  TextEditingController amController = TextEditingController();
  List pills = <Map>[];

  addpills() {
    pills.add({
      "pillName": _pillController.text,
      "pillNum": selectedValue,
      "pillTime": "${hourControler.text}:${minuteController.text} ${amController.text}"
    });

    _pillController.clear();
    hourControler.clear();
    amController.clear();
    minuteController.clear();
  }

  selectClock() => Get.defaultDialog(
        title: "AM/PM",
        titleStyle: fontBody(fontSize: 20, fontWeight: FontWeight.w500, fontColor: kPrimaryColor),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () {
                amController.text = "AM";
                Get.back();
              },
              title: Text("AM", style: fontBody(fontSize: 15)),
            ),
            ListTile(
              onTap: () {
                amController.text = "PM";
                Get.back();
              },
              title: Text("PM", style: fontBody(fontSize: 15)),
            ),
          ],
        ),
        backgroundColor: kWhiteColor,
      );
  @override
  void dispose() {
    // TODO: implement dispose
    _pillController.dispose();
    hourControler.dispose();
    minuteController.dispose();
    amController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Pill Box"),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: pills.length,
          itemBuilder: (context, index) {
            Map pill = pills[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: kLightGreyColor.withOpacity(0.5), blurRadius: 20),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(pill["pillName"], style: fontBody(fontSize: 25, fontWeight: FontWeight.w700)),
                    trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          pills.removeAt(index);
                        });
                      },
                      color: Colors.red,
                      icon: const Icon(Icons.close),
                    ),
                  ),
                  Text('${pill["pillNum"]} Pills', style: fontBody(fontSize: 15, fontWeight: FontWeight.w500)),
                  const Divider(color: kLightGreyColor),
                  Text(pill["pillTime"], style: fontBody(fontSize: 20, fontWeight: FontWeight.w400)),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: BottomAppBar(
          child: ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: Get.width / 2 - 20,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kLightGreyColor,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            child: Container(
                              height: Get.height / 4,
                              width: Get.width - 30,
                              color: Colors.white70,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _pillController,
                                            decoration: InputDecoration(
                                              labelText: "Pill Name",
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                            height: 55,
                                            width: 60,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.black38), //border of dropdown button
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: DropdownButtonHideUnderline(
                                                  child: DropdownButtonFormField(
                                                iconEnabledColor: Colors.teal,
                                                icon: Icon(Icons.keyboard_arrow_down_sharp),
                                                borderRadius: BorderRadius.circular(8),
                                                value: selectedValue,
                                                onSaved: (String? newValue) {
                                                  setState(() {
                                                    selectedValue = newValue!;
                                                    print(newValue);
                                                  });
                                                },
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    selectedValue = newValue as String;
                                                    print(newValue);
                                                  });
                                                },
                                                items: menuitems
                                                    .map((e) => DropdownMenuItem(
                                                          child: Text(e),
                                                          value: e,
                                                        ))
                                                    .toList(),
                                              )),
                                            ))
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          height: 50,
                                          width: 100,
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            controller: hourControler,
                                            decoration: InputDecoration(
                                              labelText: "Hour",
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 50,
                                          width: 100,
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            controller: minuteController,
                                            decoration: InputDecoration(
                                              labelText: "Minutes",
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 50,
                                          width: 70,
                                          child: TextFormField(
                                            textAlign: TextAlign.center,
                                            onTap: selectClock,
                                            controller: amController,
                                            decoration: InputDecoration(
                                              labelText: "AM/PM",
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimaryColor,
                                        //padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          addpills();
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        "OK",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 16, fontFamily: "Poppins"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  },
                  child: const Text(
                    "Add Pill",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontFamily: "Poppins", color: kBlackColor),
                  ),
                ),
              ),
              SizedBox(
                width: Get.width / 2 - 20,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  ),
                  onPressed: () async{
                    await FirebaseFirestore.instance.collection("users").doc(uid).collection("userType").doc(userType[0]).set({
                      "relationType": userType[0],
                      "firstName": userType[1],
                      "lastName": userType[2],
                      "dateofBirth": userType[3],
                      "healthConditions": userType[4],
                      "pills": pills,
                    });
                    customToast("User has been successfully added!");

                    Get.back();
                  },
                  child: const Text(
                    "Done",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontFamily: "Poppins"),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class ReusableContainer extends StatefulWidget {
  ReusableContainer({Key? key, required this.weekdays}) : super(key: key);
  String weekdays;

  @override
  State<ReusableContainer> createState() => _ReusableContainerState();
}

class _ReusableContainerState extends State<ReusableContainer> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4.0,
      ),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: 45,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: Center(
              child: Text(
            widget.weekdays,
            style: TextStyle(color: Colors.grey),
          )),
        ),
      ),
    );
  }
}
