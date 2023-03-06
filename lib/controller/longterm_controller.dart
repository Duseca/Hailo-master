import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hailo/core/constants/collections.dart';
import 'package:hailo/core/utils/common.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../core/common.dart';
import '../core/constants/colors.dart';
import '../core/constants/functions.dart';

class LongTermController extends GetxController {
  final PageController pageController = PageController();
  RxList<Map> careServices = <Map>[].obs;
  Completer<GoogleMapController> googleMapController = Completer();
  final formKeyRequirements = GlobalKey<FormState>();
  final box = GetStorage();
  RxInt currentPage = 0.obs;
  RxInt selectedIndex = 3.obs;
  String _type = "";
  RxDouble priceRange = 30.0.obs;
  String rangeValue = '';
  String time = "9:00am";
  String status = "Pending";
  RxString userType = "".obs;

  String todayWeekday = DateFormat("EEE").format(DateTime.now());

  Map<String, dynamic>? paymentIntent;

  var data = Get.parameters["uid"];

  var availability = <DateTime>[].obs;
  RxMap daysTask = {}.obs;

  final TextEditingController genderController = TextEditingController(),
      languageController = TextEditingController(),
      jobdescController = TextEditingController(),
      searchLocationController = TextEditingController(),
      descController = TextEditingController(),
      monthController = TextEditingController();

  List<String> pageHeading = [
    "Caregiver Services",
    "Select Profile",
    "Requirements",
    "Schedule",
    "Schedule",
    "Schedule",
    "Location",
    "Price & Description",
  ];

  //dates list for days Wise Payments
  List paymentsDatesList = [];

  //dates wise payments map
  Map datesWisePayments = {};

  List<String> weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  RxList selectedDays = [].obs;
  var weekAvail = <DateTime>[].obs;

  void addWeekday(DateTime date) {
    weekAvail.insert(0, date);
  }

  void deleteWeekday(DateTime date) {
    weekAvail.remove(date);
  }

  RxMap wdays = {}.obs;

  bool added = false;

  List<String> selectedItems = [
    'Recurring',
    'One Time',
  ];
  RxMap pastUserLocation = {}.obs;
  GeoPoint searchLocationPoint = GeoPoint(0, 0);
  GeoPoint currectLocation = GeoPoint(0, 0);

// Calendar Functions
  void addAvailability(DateTime date) {
    availability.insert(0, date);
  }

  void deleteAvailability(DateTime date) {
    availability.remove(date);
  }

  // Selecting gender in requirement page
  void selectGender() => Get.defaultDialog(
        title: "Select Gender",
        titleStyle: fontBody(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontColor: kPrimaryColor),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () {
                genderController.text = "Male";
                Get.back();
              },
              title: Text("Male", style: fontBody(fontSize: 15)),
            ),
            ListTile(
              onTap: () {
                genderController.text = "Female";
                Get.back();
              },
              title: Text("Female", style: fontBody(fontSize: 15)),
            ),
          ],
        ),
        backgroundColor: kWhiteColor,
      );

  // Selecting language in requirement page
  void selectLanguage() => Get.defaultDialog(
        title: "Select Language",
        titleStyle: fontBody(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontColor: kPrimaryColor),
        content: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection("languages").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return customProgressIndicator();

              List<DocumentSnapshot> data = snapshot.data!.docs;
              return SizedBox(
                height: Get.height / 3,
                width: Get.width / 3,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      onTap: () {
                        languageController.text = data[index]['name'];
                        print(data[index]['name']);
                        Get.back();
                      },
                      title: Text(data[index]['name'],
                          style: fontBody(fontSize: 15)),
                    );
                  },
                ),
              );
            }),
        backgroundColor: kWhiteColor,
      );

  //Selecting schedule type in schedule page
  void selectType(int index) {
    _type = selectedItems[index];
    selectedIndex.value = index;
  }

  void pRange(double value) {
    priceRange.value = value;
    print(value);
  }

  //Current location of the user

  getCurrentPosition() async {
    var currentLoc = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    //var currentLoc1 = await Geolocator.l
    var long = currentLoc.longitude;
    var lat = currentLoc.latitude;
    currectLocation = GeoPoint(lat, long);
    return currectLocation;
  }

  // Updating and determining location
  updateLocation() async {
    if (searchLocationController.text.isEmpty) {
      return;
    }

    List<Location> locations =
        await locationFromAddress(searchLocationController.text);
    var first = locations.first;
    double lat = first.latitude;
    double long = first.longitude;

    searchLocationPoint = GeoPoint(lat, long);

    final GoogleMapController mapController = await googleMapController.future;

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(locations.first.latitude, locations.first.longitude),
            zoom: 15),
      ),
    );
  }

  void _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.openLocationSettings();
        customToast("Location permissions are denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      customToast(
          "Location permissions are permanently denied, we cannot request permissions");
      return;
    }
    Position data = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final GoogleMapController mapController = await googleMapController.future;

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(data.latitude, data.longitude), zoom: 15),
      ),
    );
    box.write("userLocation",
        {"latitude": data.latitude, "longitude": data.longitude});
    double clat = data.latitude;
    double clong = data.longitude;

    searchLocationPoint = GeoPoint(data.latitude, data.longitude);
  }

  //Button functionality
  onNext() async {
    switch (currentPage.value) {
      //services
      case 0:
        if (careServices.isEmpty) {
          customToast("Please select a service");
          return;
        }
        currentPage.value++;
        pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
        break;
      // select profile
      case 1:
        if (userType.isEmpty) {
          customToast("Select a profile to continue");
          return;
        }
        currentPage.value++;
        pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
        break;
      // requirements
      case 2:
        if (!formKeyRequirements.currentState!.validate()) {
          return;
        }
        currentPage.value++;
        pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
        break;
      // type
      case 3:
        if (_type.isEmpty) {
          customToast("Select at schedule type");
          return;
        }
        currentPage.value++;
        pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
        break;

      // calender
      case 4:
        if (availability.isEmpty && selectedDays.isEmpty) {
          customToast("Select at least one day");
          return;
        }

        if (_type == "Recurring" && monthController.text.isEmpty) {
          customToast("Enter recurring months");
          return;
        }

        if (selectedItems[selectedIndex.value] == "Recurring") {
          for (String day in selectedDays) {
            wdays[day] = [];
          }
        } else {
          availability.toSet().toList().sort();

          for (DateTime dateTime in availability) {
            daysTask[DateFormat("dd-MM-yyyy").format(dateTime)] = [];
          }
        }

        currentPage.value++;
        pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
        break;

      // drag drop
      case 5:
        if (daysTask.isEmpty && _type != "Recurring") {
          customToast("Please add task");
          return;
        }
        if (wdays.isEmpty && _type == "Recurring") {
          customToast("Please add task");
          return;
        }
        currentPage.value++;
        pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
        break;

      // location
      case 6:
        currentPage.value++;
        print('SEARCH LOCATION LONG:${searchLocationPoint.longitude}');
        print('Current LOCATION LONG:${currectLocation.longitude}');

        pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
        break;

      //Price
      case 7:
        customToast("Please wait...");

        if (_type == "Recurring") {
          List dates = [];
          DateTime flag = DateTime.now();
          for (String wd in selectedDays) {
            while (true) {
              if (wd == DateFormat("EEE").format(flag)) {
                dates.add(flag);
                break;
              }
              flag = flag.add(const Duration(days: 1));
            }
            flag = DateTime.now();
          }
          dates.sort(); // sorting the first date of each weekday

          int totalWeeks = 4 * int.parse(monthController.text);
          print("total weeks $totalWeeks");
          int c = 1; // week count
          int i = 0; // day increment by 7

          for (DateTime date in dates) {
            while (c <= totalWeeks) {
              availability.add(date.add(Duration(days: i)));

              daysTask[DateFormat("dd-MM-yyyy")
                      .format(date.add(Duration(days: i)))] =
                  wdays[DateFormat("EEE").format(date)];

              i += 7;
              c++;
            }
            c = 1;
            i = 0;
          }
          availability.toSet().toList().sort();
        }

        paymentsDatesList = [];

        //assigning task days list for dates wise payments
        paymentsDatesList = availability;

        datesWisePayments = {};

        //adding dates in  wisePayments for payments according to days tasks
        for (int i = 0; i < paymentsDatesList.length; i++) {
          datesWisePayments.addAll(
              {DateFormat("dd-MM-yyyy").format(paymentsDatesList[i]): []});
        }

        // makePayment(
        //   amount: priceRange.value,
        // );

        log("datesWisePayments: $datesWisePayments");

        // log("This is task model: $taskModelMap");

        //my changes start
        await longtermCollection.add({
          "caregiverService": careServices,
          "startDate": availability.first,
          "endDate": availability.last,
          "uid": data.toString(),
          "gender": genderController.text.trim(),
          "language": languageController.text.trim(),
          "days": availability,
          "scheduleType": _type,
          "destination": searchLocationPoint,
          "location": currectLocation,
          "price": priceRange.value.round(),
          "jobDesc": descController.text.trim(),
          "scheduleTasks": daysTask,
          "jobStatus": status,
          "userType": userType.value,
          "isCompleted": false,
          "datesWisePayments": datesWisePayments
        }).then((value) async {
          await FirebaseFirestore.instance
              .collection("transactionPending")
              .doc(value.id)
              .set({
            "userUid": data,
            "day": DateFormat('dd-MM-yyyy').format(DateTime.now()),
            "month": DateFormat('MMM-yyyy').format(DateTime.now()),
            "time": DateTime.now(),
            "price": priceRange.value,
            "isPending": true,
          });
        });

        customToast("Task created successfully");
        Get.offAllNamed("/root", parameters: {"uid": data!});
        //my changes end
        var doc = await usersCollection.doc(data).get();
        await sendNotificationCareTaker.call({
          "title": "Posted a new job",
          "description":
              "${doc["firstName"]} posted a job for ${careServices[0]["name"]}",
        });

        break;
    }
  }
var startTime='09:00 AM'.obs;
var endTime='12:00 PM'.obs;
  selectTime({required draggedService,required context}) {
    Get.defaultDialog(
        title: 'Select time',
        content: Column(
          children: [
            Row(
              children: [
                Image.asset(draggedService['icon']),
                Divider(
                  height: 2,
                  color: kPrimaryColor,
                  thickness: 2,
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        Text('Start Time'),
                        InkWell(
                          onTap: () {
                            Duration initialtimer = const Duration();
                            DatePicker.showTime12hPicker(
                              context,
                              onConfirm: (selected) {
                                draggedService["startTime"] =
                                    DateFormat("jms").format(selected);
                                update();
                              },
// minTime: DateTime.now(),
// maxTime: DateTime(2030, 12, 31),
                              onChanged: (date) {
                                draggedService["startTime"] =
                                    DateFormat("jms").format(date);
                                update();
                                print('change $date');
                              },
                              currentTime: DateTime.tryParse('10:00:00'),
                            );
                          },
                          child: GetBuilder<LongTermController>(
                              builder: (context) {
                            return Text(draggedService["startTime"]);
                          }),
                        )
                      ],
                    )
                  ],
                )
              ],
            )
          ],
        ));
  }

  @override
  void onInit() {
    pastUserLocation.value = box.read("userLocation") ?? {};
    _determinePosition();
    super.onInit();
  }

  @override
  void dispose() {
    genderController.dispose();
    pageController.dispose();
    languageController.dispose();
    jobdescController.dispose();
    searchLocationController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> makePayment({
    required double amount,
  }) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'USD');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  style: ThemeMode.light,
                  merchantDisplayName: 'Hailo Care'))
          .then((value) {});
      displayPaymentSheet(amount);
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  createPaymentIntent(double amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': (amount * 100).toInt().toString(),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer sk_test_51KpK8bCfPMYKQLpFrmP4uXuYDtoiB2yfa1YDAnRBEjO58kC4IjFTQjZyDBeP6a0I1NRq0DA1FNlHJX9UgyVJTMei00UBbRKV0A',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return jsonDecode(response.body);
    } catch (err) {
      print(err.toString());
    }
  }

  displayPaymentSheet(double amount) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        await longtermCollection.add({
          "caregiverService": careServices,
          "startDate": availability.first,
          "endDate": availability.last,
          "uid": data.toString(),
          "gender": genderController.text.trim(),
          "language": languageController.text.trim(),
          "days": availability,
          "scheduleType": _type,
          "destination": searchLocationPoint,
          "location": currectLocation,
          "price": priceRange.value.round(),
          "jobDesc": descController.text.trim(),
          "scheduleTasks": daysTask,
          "jobStatus": status,
          "userType": userType.value,
          "isCompleted": false,
        }).then((value) async {
          await FirebaseFirestore.instance
              .collection("transactionPending")
              .doc(value.id)
              .set({
            "userUid": data,
            "day": DateFormat('dd-MM-yyyy').format(DateTime.now()),
            "month": DateFormat('MMM-yyyy').format(DateTime.now()),
            "time": DateTime.now(),
            "price": amount,
            "isPending": true,
          });
        });

        customToast("Payment Successful");
        Get.offAllNamed("/root", parameters: {"uid": data!});

        paymentIntent = null;
      }).onError((error, stackTrace) {
        // customToast( "$error $stackTrace");

        customToast("No Payment Done");
      });
    } on StripeException catch (e) {
      customToast("${e.error}");
    } catch (e) {
      customToast('$e');
    }
  }
}
