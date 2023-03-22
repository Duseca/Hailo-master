import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hailo/my_widgets/dialogs/errorDialog.dart';
import 'package:hailo/views/tabs/testtokenscreen.dart';
import 'package:http/http.dart' as http;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_maps_widget/google_maps_widget.dart'
    hide GoogleMapController;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hailo/views/settings/settingScreens/profiles/createprofile.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hailo/core/constants/collections.dart';
import 'package:hailo/core/constants/colors.dart';
import 'package:hailo/core/utils/common.dart';
import 'package:multiselect/multiselect.dart';
import 'package:readmore/readmore.dart';

import '../../core/common.dart';
import '../../core/constants/constants.dart';
import '../instant_task/task_created.dart';
import '../settings/settingScreens/payment.dart';

class CreateTaskTab extends StatefulWidget {
  CreateTaskTab({
    Key? key,
    required this.uid,
  }) : super(key: key);
  String uid;

  @override
  State<CreateTaskTab> createState() => _CreateTaskTabState();
}

class _CreateTaskTabState extends State<CreateTaskTab> {
  String? uid = Get.parameters["uid"];

  //--------- Variables-------------

  final box = GetStorage();
  var user;
  var setDefaultUserType = true;

  String? selectedUser = "";
  Map<String, dynamic>? paymentIntent;
  List<String> selectedValue = [];
  String selectedTask = "";
  final List<String> reqitems = [
    'State Licensed',
  ];
  List allTextField = [];
  List<String> tempArray = [];
  List tasks = [
    {
      "name": "Grocery Shopping",
      "icon": "assets/cart_icon.png",
      "destination": "Grocery Shop Location"
    },
    {
      "name": "Drive",
      "icon": "assets/car_icon.png",
      "destination": "Destination"
    },
    {
      "name": "Bathing",
      "icon": "assets/bath_icon.png",
      "destination": "Home Location"
    },
    //{"name": "Mobility", "icon": "assets/mobility_icon.png", "destination": "Destination"},
    {
      "name": "Grooming",
      "icon": "assets/grooming_icon.png",
      "destination": "Home Location"
    },
    {
      "name": "Meal Prep",
      "icon": "assets/meal_icon.png",
      "destination": "Home Location"
    },
    {
      "name": "Medicine Reminders",
      "icon": "assets/medicine_icon.png",
      "destination": "Home Location"
    },
    {
      "name": "Light Housekeeping",
      "icon": "assets/housekeeping_icon.png",
      "destination": "Home Location"
    },
    {
      "name": "Exercise",
      "icon": "assets/exercise_icon.png",
      "destination": "Pickup/Dropoff Location"
    },
  ];

  var date = DateTime.now().toString();
  String nowTime = DateFormat("jms").format(DateTime.now());

  Completer<GoogleMapController> googleMapController = Completer();
  GeoPoint searchLocationPoint = const GeoPoint(0, 0);
  GeoPoint pickupPoint = const GeoPoint(0, 0);
  GeoPoint stopOnePoint = const GeoPoint(0, 0);
  GeoPoint stopTwoPoint = const GeoPoint(0, 0);
  GeoPoint location = const GeoPoint(0.0, 0.0);
  GeoPoint lastposition = const GeoPoint(0.0, 0.0);
  final mapsWidgetController = GlobalKey<GoogleMapsWidgetState>();
  Map pastUserLocation = {};
  String? destinationName = "";
  String currentAddress = '';
  List<LatLng> polylineCoordinates = [];
  List eachUserCards = [];

  bool isActive = false;
  bool taskCreated = false;

  late final TextEditingController _time = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _now = TextEditingController();
  final TextEditingController _destination = TextEditingController();
  final TextEditingController searchLocationController =
      TextEditingController();
  final TextEditingController userType = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController pickUpController = TextEditingController();
  final TextEditingController stopOneController = TextEditingController();
  var userStripeId;
  var selectedCard = {}.obs;
  List displayTextField = [];

  addTextField() {
    print("Add");

    setState(() {
      if (allTextField.length == displayTextField.length) {
        print('same');
        return;
      } else {
        displayTextField.add(allTextField[displayTextField.length]);
        print(displayTextField);
      }
    });
  }

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

  removeTextField() {
    print("remove");

    setState(() {
      if (displayTextField.isNotEmpty) {
        displayTextField.removeLast();
      }
    });
  }

  void checkInstantTask() async {
    DocumentSnapshot check = await FirebaseFirestore.instance
        .collection("instantTask")
        .doc(widget.uid)
        .get();

    if (check.exists) {
      customToast("You have already created a task");
      return;
    }
  }

  pickupLocation() async {
    if (pickUpController.text.isEmpty) {
      return;
    }

    List<Location> locations = [];
    try {
      locations = await locationFromAddress(pickUpController.text);
      customToast('Location selected');
      var first = locations.first;
      double lat = first.latitude;
      double long = first.longitude;

      pickupPoint = GeoPoint(lat, long);

      log("This is pickup point: $pickupPoint");

      final GoogleMapController mapController =
          await googleMapController.future;

      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target:
                  LatLng(locations.first.latitude, locations.first.longitude),
              zoom: 15),
        ),
      );
    } catch (e) {
      print('LOCATIONS ARE $e');
      errorDialog(title: 'Error', msg: e.toString());
    }
  }

  stopOneLocation() async {
    if (stopOneController.text.isEmpty) {
      return;
    }

    List<Location> locations = [];
    try {
      locations = await locationFromAddress(stopOneController.text);
      customToast('Location selected');
      var first = locations.first;
      double lat = first.latitude;
      double long = first.longitude;

      stopOnePoint = GeoPoint(lat, long);

      final GoogleMapController mapController =
          await googleMapController.future;

      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target:
                  LatLng(locations.first.latitude, locations.first.longitude),
              zoom: 15),
        ),
      );
    } catch (e) {
      print('LOCATIONS ARE $e');
      errorDialog(title: 'Error', msg: e.toString());
    }
  }

  updateLocation() async {
    if (searchLocationController.text.isEmpty) {
      return;
    }

    List<Location> locations = [];
    try {
      locations = await locationFromAddress(searchLocationController.text);
      customToast('Location selected');
      var first = locations.first;
      double lat = first.latitude;
      double long = first.longitude;

      searchLocationPoint = GeoPoint(lat, long);

      final GoogleMapController mapController =
          await googleMapController.future;

      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target:
                  LatLng(locations.first.latitude, locations.first.longitude),
              zoom: 15),
        ),
      );
    } catch (e) {
      print('LOCATIONS ARE $e');
      errorDialog(title: 'Error', msg: e.toString());
    }
  }

  //------Determining current position--------------
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
      if (permission == LocationPermission.deniedForever) {
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
    setState(() {
      location = GeoPoint(data.latitude, data.longitude);
    });
  }

  getLastPosition() async {
    GeoPoint lastposition =
        (await Geolocator.getLastKnownPosition()) as GeoPoint;
    return lastposition;
  }

  Future<String> getAddress(GeoPoint lastposition) async {
    List<Placemark> p = await placemarkFromCoordinates(
        lastposition.latitude, lastposition.longitude);
    Placemark place = p[0];
    print(place);
    currentAddress = '${place.name},${place.locality},${place.country}';
    return currentAddress;
  }

  double rating = 0.0;
  int ratingCount = 0;

  Widget buildRating() => RatingBar.builder(
        minRating: 1,
        itemBuilder: (context, index) => const Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (rating) {
          setState(() {
            this.rating = rating;
          });
        },
      );

  void showRating(String cid) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Center(child: Text("Rate your Caregiver!")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/care.png",
                width: 50,
                height: 50,
                color: kPrimaryColor,
              ),
              const SizedBox(
                height: 20,
              ),
              buildRating(),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () async {
                  print("rating");
                  print(rating);

                  await careTakersCollection.doc(cid).update({
                    "rating": FieldValue.increment(rating),
                    "ratingCount": FieldValue.increment(1),
                  });
                  Get.back();
                },
                child: Text("Okay"),
                style: TextButton.styleFrom(
                  foregroundColor: kWhiteColor,
                  elevation: 0,
                  backgroundColor: kPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      );

  // DropDown List for Requirements
  Widget drop() {
    return Container(
        decoration: BoxDecoration(
          color: kPrimaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: DropDownMultiSelect(
          decoration: InputDecoration(
            border: InputBorder.none,
            label: const Text("Requirements"),
            labelStyle: const TextStyle(
                fontSize: 15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: kPrimaryColor),
            filled: true,
            fillColor: kPrimaryColor.withOpacity(0.2),
            focusColor: kPrimaryColor.withOpacity(0.2),
          ),
          options: reqitems,
          selectedValues: selectedValue,
          isDense: true,

          // whenEmpty: 'Requirement',
          onChanged: (List<String> x) {
            setState(() {
              selectedValue = x;
            });
          },
        ));
  }

  //Dropdown for usertype(mom,dad,friend etc)
  Widget userDropDown() {
    return Center(
      child: StreamBuilder<QuerySnapshot>(
          stream: usersCollection.doc(uid).collection("userType").snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return customProgressIndicator();

            if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
              return SizedBox(
                width: Get.width,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => CreateProfile());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: Text(
                    "Create Profile",
                    style: TextStyle(fontSize: 16, fontFamily: "Poppins"),
                  ),
                ),
              );
            }
            if (setDefaultUserType) {
              user = snapshot.data?.docs[0].get('relationType');
              debugPrint('setDefault usertype: $user');
            }
            return ListTile(
              title: Container(
                decoration: BoxDecoration(
                  color: kSecondaryColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0, right: 8),
                      child: Icon(
                        Icons.person_pin,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          dropdownColor: kSecondaryColor,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_sharp,
                            color: Colors.white,
                          ),
                          isExpanded: true,
                          value: user,
                          items: snapshot.data!.docs.map((value) {
                            return DropdownMenuItem(
                              value: value.get('relationType'),
                              child: Text(
                                '${value.get('relationType')}',
                                style: fontBody(
                                    fontSize: 20, fontColor: kWhiteColor),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            debugPrint('selected onchange: $value');
                            setState(() {
                              user = value;
                              setDefaultUserType = false;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  @override
  void initState() {
    pastUserLocation = box.read("userLocation") ?? {};
    _determinePosition();

    getUserCards(userId: widget.uid);
    allTextField = [
      {
        "keyforbackend": "first_stop",
        "value": stopOneController,
        "text_field": TextFormField(
          controller: stopOneController,
          decoration: InputDecoration(
            labelText: "Add a Stop",
            labelStyle:
                fontBody(fontSize: 14, fontColor: const Color(0xffB7B7B7)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xffE7E7E7), width: 1)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xffE7E7E7), width: 1)),
            suffixIcon: TextButton(
              onPressed: () {
                stopOneLocation();
              },
              child: Text(
                "Locate",
                style: fontBody(fontSize: 12, fontColor: kPrimaryColor),
              ),
            ),
          ),
        )
      },
    ];

    super.initState();
  }

  @override
  void dispose() {
    googleMapController.future.then((GoogleMapController controller) {
      controller.dispose();
    });
    //very good
    _price.dispose();
    _destination.dispose();
    _time.dispose();
    searchLocationController.dispose();
    userType.dispose();
    _now.dispose();
    descController.dispose();
    pickUpController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Wrap(
            spacing: 10,
            alignment: WrapAlignment.center,
            children: [
              Image.asset("assets/clock.png", color: kWhiteColor, height: 18),
              Text("Create a Instant Task",
                  style: fontBody(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontColor: kWhiteColor)),
            ],
          ),
        ),
        body: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 150),
              child: StreamBuilder<DocumentSnapshot>(
                  stream: instantTaskCollection.doc(widget.uid).snapshots(),
                  builder: (context, snapshots) {
                    if (!snapshots.hasData) return customProgressIndicator();

                    if (snapshots.hasData && !snapshots.data!.exists) {
                      return SizedBox(
                        width: Get.width,
                        height: Get.height,
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            GoogleMap(
                              mapType: MapType.normal,
                              myLocationButtonEnabled: true,
                              myLocationEnabled: true,
                              initialCameraPosition: CameraPosition(
                                target: pastUserLocation.isEmpty
                                    ? const LatLng(
                                        37.42796133580664, -122.085749655962)
                                    : LatLng(pastUserLocation["latitude"],
                                        pastUserLocation["longitude"]),
                                zoom: 14.4746,
                              ),
                              onMapCreated: (GoogleMapController controller) {
                                googleMapController.complete(controller);
                              },
                              onCameraMove: (position) {
                                setState(() {
                                  lastposition = GeoPoint(
                                      position.target.latitude,
                                      position.target.longitude);
                                });
                              },
                            ),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: ShapeDecoration(
                                shape: const CircleBorder(),
                                color: kWhiteColor.withOpacity(0.6),
                                shadows: [
                                  BoxShadow(
                                      color: const Color(0xff111111)
                                          .withOpacity(0.06),
                                      blurRadius: 24,
                                      offset: const Offset(0, 20)),
                                ],
                              ),
                              child: const Icon(Icons.my_location,
                                  color: kSecondaryColor),
                            ),
                          ],
                        ),
                      );
                    }

                    DocumentSnapshot udata = snapshots.data!;
                    double slat = udata['location'].latitude;
                    double slong = udata['location'].longitude;

                    double dlat = udata['dlocation'].latitude;
                    double dlong = udata['dlocation'].longitude;

                    /*   double stoponeLat = udata['stopOneLocation'].latitude;
                    double stoponeLong = udata['stopOneLocation'].longitude;
*/
                    return udata['isActive'] == 'Yes'
                        ? StreamBuilder<DocumentSnapshot>(
                            stream: jobsInstantCollection
                                .doc(widget.uid)
                                .snapshots(),
                            builder: (context, jsnapshot) {
                              if (!jsnapshot.hasData) {
                                return const SizedBox();
                              }

                              print(jsnapshot.data!['position'].latitude);

                              return GoogleMapsWidget(
                                sourceMarkerIconInfo: const MarkerIconInfo(
                                  assetPath: "assets/location-pin.png",
                                ),
                                destinationMarkerIconInfo: const MarkerIconInfo(
                                  assetPath: "assets/pointer.png",
                                ),
                                driverMarkerIconInfo: MarkerIconInfo(
                                  assetPath: "assets/jeep.png",
                                  onTapMarker: (currentLocation) {
                                    print(
                                        "Driver is currently at $currentLocation");
                                  },
                                  assetMarkerSize: const Size.square(125),
                                  rotation: 90,
                                ),
                                updatePolylinesOnDriverLocUpdate: true,
                                apiKey:
                                    "AIzaSyBEzGuILNmdsdu9J0TKoVaW3YmIHFSB6kA",
                                key: mapsWidgetController,
                                sourceLatLng: LatLng(dlat, dlong),
                                destinationLatLng: LatLng(slat, slong),
                                driverCoordinatesStream: Stream.periodic(
                                    const Duration(seconds: 2), (i) {
                                  return LatLng(
                                    jsnapshot.data!['position'].latitude,
                                    jsnapshot.data!['position'].longitude,
                                  );
                                }),
                              );
                            })
                        : SizedBox(
                            width: Get.width,
                            height: Get.height,
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                GoogleMap(
                                  mapType: MapType.normal,
                                  myLocationButtonEnabled: true,
                                  myLocationEnabled: true,
                                  initialCameraPosition: CameraPosition(
                                    target: pastUserLocation.isEmpty
                                        ? const LatLng(37.42796133580664,
                                            -122.085749655962)
                                        : LatLng(pastUserLocation["latitude"],
                                            pastUserLocation["longitude"]),
                                    zoom: 14.4746,
                                  ),
                                  onMapCreated:
                                      (GoogleMapController controller) {
                                    googleMapController.complete(controller);
                                  },
                                  onCameraMove: (position) {
                                    setState(() {
                                      lastposition = GeoPoint(
                                          position.target.latitude,
                                          position.target.longitude);
                                    });
                                  },
                                ),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: ShapeDecoration(
                                    shape: const CircleBorder(),
                                    color: kWhiteColor.withOpacity(0.6),
                                    shadows: [
                                      BoxShadow(
                                          color: const Color(0xff111111)
                                              .withOpacity(0.06),
                                          blurRadius: 24,
                                          offset: const Offset(0, 20)),
                                    ],
                                  ),
                                  child: const Icon(Icons.my_location,
                                      color: kSecondaryColor),
                                ),
                              ],
                            ),
                          );
                  }),
            ),
            Image.asset("assets/shape2.png"),
            StreamBuilder<DocumentSnapshot>(
                stream: instantTaskCollection.doc(widget.uid).snapshots(),
                builder: (context, snapshots) {
                  if (!snapshots.hasData) return customProgressIndicator();

                  if (snapshots.hasData && !snapshots.data!.exists) {
                    return Container(
                        margin: const EdgeInsets.only(top: kToolbarHeight + 60),
                        width: Get.width,
                        height: Get.height / 6,
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(left: 15),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                //print("Selected : " + tasks[index]["name"]);
                                if (selectedTask != tasks[index]["name"]) {
                                  setState(() {
                                    selectedTask = tasks[index]["name"];
                                    destinationName =
                                        tasks[index]["destination"];
                                  });
                                  print(destinationName);
                                  print(selectedTask);
                                }
                                openCreateSheet(tasks[index], selectedTask);
                              },
                              child: Container(
                                height: 100,
                                width: 100,
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: selectedTask == tasks[index]["name"]
                                      ? kPrimaryColor
                                      : kWhiteColor,
                                  boxShadow: [
                                    BoxShadow(
                                        color: const Color(0xff111111)
                                            .withOpacity(0.06),
                                        blurRadius: 24,
                                        offset: const Offset(0, 20)),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      tasks[index]["icon"],
                                      height: 35,
                                      color:
                                          selectedTask == tasks[index]["name"]
                                              ? kWhiteColor
                                              : kPrimaryColor,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      tasks[index]["name"],
                                      textAlign: TextAlign.center,
                                      style: fontBody(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          fontColor: selectedTask ==
                                                  tasks[index]["name"]
                                              ? kWhiteColor
                                              : kPrimaryColor),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, i) =>
                              const SizedBox(width: 10),
                          itemCount: tasks.length,
                        ));
                  }

                  DocumentSnapshot data = snapshots.data!;
                  return Container(
                    margin: const EdgeInsets.only(top: kToolbarHeight + 60),
                    width: Get.width,
                    height: data["taskName"] == 'Light Housekeeping'
                        ? Get.height / 2
                        : Get.height / 3,
                    child: data['isActive'] == 'Yes'
                        ? Padding(
                            padding: const EdgeInsets.only(
                                left: 38.0, right: 38.0, top: 38.0),
                            child: Container(
                                height: Get.height,
                                width: 165,
                                //margin: const EdgeInsets.only(right: 14),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(9),
                                    color: kWhiteColor),
                                child: StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('jobsInstant')
                                        .doc(widget.uid)
                                        .snapshots(),
                                    builder: (context, snapshots) {
                                      if (!snapshots.hasData)
                                        return customProgressIndicator();

                                      DocumentSnapshot jobinst =
                                          snapshots.data!;
                                      String cID = jobinst['cid'];
                                      return StreamBuilder<DocumentSnapshot>(
                                          stream: careTakersCollection
                                              .doc(cID)
                                              .snapshots(),
                                          builder: (context, snapshots) {
                                            if (!snapshots.hasData)
                                              return customProgressIndicator();
                                            DocumentSnapshot udata =
                                                snapshots.data!;

                                            return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        height: 10,
                                                        width: 30,
                                                        decoration:
                                                            const BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color:
                                                                    kPrimaryColor),
                                                        child: Center(
                                                          child: Image.asset(
                                                            data["taskIcon"],
                                                            height: 20,
                                                            width: 20,
                                                            color: kWhiteColor,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 15),
                                                      Expanded(
                                                        child:
                                                            SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Text(
                                                            data["taskName"],
                                                            style: fontBody(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontColor:
                                                                    kBlackColor),
                                                          ),
                                                        ),
                                                      ),
                                                      Center(
                                                        child: Text(
                                                          "\$" +
                                                              " " +
                                                              "${data['price']}",
                                                          style: fontBody(
                                                              fontSize: 16,
                                                              fontColor:
                                                                  kPrimaryColor),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  data["taskName"] ==
                                                          'Light Housekeeping'
                                                      ? ReadMoreText(
                                                          data['comment'],
                                                          textAlign:
                                                              TextAlign.justify,
                                                          trimLines: 1,
                                                          style: TextStyle(
                                                              color: kBlackColor
                                                                  .withOpacity(
                                                                      0.5)),
                                                          colorClickableText:
                                                              kSecondaryColor,
                                                          trimMode:
                                                              TrimMode.Line,
                                                          trimCollapsedText:
                                                              ' more',
                                                          trimExpandedText:
                                                              ' less',
                                                        )
                                                      : SizedBox(),
                                                  data['isActive'] == 'Yes'
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .stretch,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            100),
                                                                    child: udata["profilePicture"]
                                                                            .isEmpty
                                                                        ? Image
                                                                            .asset(
                                                                            "assets/placeholderProfile.png",
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            width:
                                                                                30,
                                                                            height:
                                                                                30,
                                                                          )
                                                                        : CachedNetworkImage(
                                                                            imageUrl:
                                                                                udata["profilePicture"],
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            width:
                                                                                30,
                                                                            height:
                                                                                30,
                                                                          ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 15,
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        udata['firstName'] +
                                                                            " " +
                                                                            udata['lastName'],
                                                                        style: fontBody(
                                                                            fontSize:
                                                                                16),
                                                                      ),
                                                                      RichText(
                                                                        text: TextSpan(
                                                                            text:
                                                                                "Status:",
                                                                            style:
                                                                                fontBody(fontSize: 12),
                                                                            children: const [
                                                                              TextSpan(
                                                                                text: " In Progress",
                                                                                style: TextStyle(color: Colors.green),
                                                                              ),
                                                                            ]),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                              if (data[
                                                                      'isActive'] ==
                                                                  'Yes')
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top:
                                                                          10.0),
                                                                  child: ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                                                                      onPressed: () async {
                                                                        var doc = await jobsInstantCollection
                                                                            .doc(widget.uid)
                                                                            .get();

                                                                        /* await FirebaseFirestore.instance.collection("withdrawal").doc(data["withdrawalID"]).update({
                                                                      "caretakerUid": doc['cid'],
                                                                    });*/
                                                                        await careTakersCollection
                                                                            .doc(doc[
                                                                                'cid'])
                                                                            .update({
                                                                          "instantID":
                                                                              ""
                                                                        });

                                                                        await FirebaseFirestore
                                                                            .instance
                                                                            .collection("instantTask")
                                                                            .doc(widget.uid)
                                                                            .delete();
                                                                        showRating(
                                                                            doc['cid']);

                                                                        await FirebaseFirestore
                                                                            .instance
                                                                            .collection("withdrawal")
                                                                            .add({
                                                                          "caretakerUid":
                                                                              doc['cid'],
                                                                          "userUid":
                                                                              widget.uid,
                                                                          "day":
                                                                              DateFormat('dd-MM-yyyy').format(DateTime.now()),
                                                                          "month":
                                                                              DateFormat('MMM-yyyy').format(DateTime.now()),
                                                                          "time":
                                                                              DateTime.now(),
                                                                          "price":
                                                                              data['price'],
                                                                          "isPending":
                                                                              true,
                                                                        });

                                                                        await FirebaseFirestore
                                                                            .instance
                                                                            .collection("transactionPending")
                                                                            .doc(widget.uid)
                                                                            .delete();

                                                                        setState(
                                                                            () {
                                                                          taskCreated =
                                                                              false;
                                                                        });
                                                                      },
                                                                      child: const Text("Task Completed")),
                                                                ),
                                                            ],
                                                          ),
                                                        )
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .stretch,
                                                            children: [
                                                              const SizedBox(
                                                                  height: 10),
                                                              Row(
                                                                children: [
                                                                  const CircleAvatar(
                                                                    radius: 15,
                                                                    backgroundColor:
                                                                        Color(
                                                                            0xffC4C4C4),
                                                                    child: Icon(
                                                                      Icons
                                                                          .question_mark,
                                                                      color:
                                                                          kWhiteColor,
                                                                      size: 20,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          15),
                                                                  Text(
                                                                    "Open Position",
                                                                    style: fontBody(
                                                                        fontSize:
                                                                            16,
                                                                        fontColor:
                                                                            const Color(0xffC4C4C4)),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                  height: 5),
                                                              ElevatedButton(
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                          backgroundColor:
                                                                              kSecondaryColor),
                                                                  onPressed:
                                                                      () async {
                                                                    setState(
                                                                        () {
                                                                      taskCreated =
                                                                          false;
                                                                    });
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'instantTask')
                                                                        .doc(widget
                                                                            .uid)
                                                                        .delete();
                                                                  },
                                                                  child: Text(
                                                                      "Cancel")),
                                                            ],
                                                          ),
                                                        ),
                                                ]);
                                          });
                                    })),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(
                                left: 38.0, right: 38.0, top: 38.0),
                            child: Container(
                                height: Get.height,
                                width: 165,
                                //margin: const EdgeInsets.only(right: 14),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(9),
                                    color: kWhiteColor),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 30,
                                            width: 30,
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: kPrimaryColor),
                                            child: Center(
                                              child: Image.asset(
                                                data["taskIcon"],
                                                height: 20,
                                                width: 20,
                                                color: kWhiteColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Text(
                                                data["taskName"],
                                                style: fontBody(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    fontColor: kBlackColor),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Text(
                                              "\$" + " " + "${data['price']}",
                                              style: fontBody(
                                                  fontSize: 16,
                                                  fontColor: kPrimaryColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                const CircleAvatar(
                                                  radius: 15,
                                                  backgroundColor:
                                                      Color(0xffC4C4C4),
                                                  child: Icon(
                                                    Icons.question_mark,
                                                    color: kWhiteColor,
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 15),
                                                Text(
                                                  "Open Position",
                                                  style: fontBody(
                                                      fontSize: 16,
                                                      fontColor: const Color(
                                                          0xffC4C4C4)),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        kSecondaryColor),
                                                onPressed: () async {
                                                  setState(() {
                                                    taskCreated = false;
                                                  });
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('instantTask')
                                                      .doc(widget.uid)
                                                      .delete();
                                                },
                                                child: Text("Cancel")),
                                          ],
                                        ),
                                      ),
                                    ])),
                          ),
                  );
                })
            //
          ],
        ));
  }

  openCreateSheet(Map task, String selectedTask) {
    Get.bottomSheet(
      StatefulBuilder(builder: (context, internalState) {
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Image.asset(
                  "assets/custom_down_arrow.png",
                  width: 44,
                ),
              ),
            ),

            //destination
            if (selectedTask == ('Grocery Shopping'))
              Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextFormField(
                        controller:
                            pickUpController, //add destination controller which will be added manually by user
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "Pickup Location",
                          labelStyle: fontBody(
                              fontSize: 14, fontColor: const Color(0xffB7B7B7)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xffE7E7E7), width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xffE7E7E7), width: 1)),
                          suffixIcon: TextButton(
                            onPressed: () {
                              pickupLocation();
                            },
                            child: Text(
                              "Locate",
                              style: fontBody(
                                  fontSize: 12, fontColor: kPrimaryColor),
                            ),
                          ),
                        ),
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextFormField(
                        controller:
                            searchLocationController, //add destination controller which will be added manually by user
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: destinationName,
                          labelStyle: fontBody(
                              fontSize: 14, fontColor: const Color(0xffB7B7B7)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xffE7E7E7), width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xffE7E7E7), width: 1)),
                          suffixIcon: TextButton(
                            onPressed: () {
                              updateLocation();
                            },
                            child: Text(
                              "Locate",
                              style: fontBody(
                                  fontSize: 12, fontColor: kPrimaryColor),
                            ),
                          ),
                        ),
                      )),
                ],
              )
            else if (selectedTask == ('Drive'))
              Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextFormField(
                        controller:
                            pickUpController, //add destination controller which will be added manually by user
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "Pickup Location",
                          labelStyle: fontBody(
                              fontSize: 14, fontColor: const Color(0xffB7B7B7)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xffE7E7E7), width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xffE7E7E7), width: 1)),
                          suffixIcon: TextButton(
                            onPressed: () {
                              pickupLocation();
                            },
                            child: Text(
                              "Locate",
                              style: fontBody(
                                  fontSize: 12, fontColor: kPrimaryColor),
                            ),
                          ),
                        ),
                      )),

                  ...displayTextField
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(children: [
                            const Padding(
                              padding: EdgeInsets.only(
                                top: 20,
                                right: 20,
                              ),
                              child: Icon(
                                Icons.add,
                                color: kPrimaryColor,
                              ),
                            ),
                            Expanded(child: e['text_field'])
                          ]),
                        ),
                      )
                      .toList(),
                  SizedBox(
                    height: 20,
                  ),

                  // Add Stop Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          child: Text(
                            "Add Stop",
                            style:
                                fontBody(fontSize: 16, fontColor: kWhiteColor),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          onPressed: () {
                            addTextField();

                            internalState(() {});
                          },
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          onPressed: () {
                            removeTextField();
                            internalState(() {});
                          },
                          child: Text(
                            "Remove Stop",
                            style:
                                fontBody(fontSize: 16, fontColor: kWhiteColor),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 10,
                  ),
                ],
              )
            else
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextFormField(
                    controller:
                        searchLocationController, //add destination controller which will be added manually by user
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: destinationName,
                      labelStyle: fontBody(
                          fontSize: 14, fontColor: const Color(0xffB7B7B7)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xffE7E7E7), width: 1)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xffE7E7E7), width: 1)),
                      suffixIcon: TextButton(
                        onPressed: () {
                          updateLocation();
                        },
                        child: Text(
                          "Locate",
                          style:
                              fontBody(fontSize: 12, fontColor: kPrimaryColor),
                        ),
                      ),
                    ),
                  )),

            // Requirement dropdownlist
            drop(),
/*          ExpansionPanelList(
                elevation: 3,
                // Controlling the expansion behavior
                expansionCallback: (index, isExpanded) {
                  setState(() {
                    _items[index]['isExpanded'] = !isExpanded;
                  });
                },
                animationDuration: Duration(milliseconds: 600),
                children: _items
                    .map(
                      (item) => ExpansionPanel(
                    canTapOnHeader: true,
                    backgroundColor:
                    item['isExpanded'] == true ? Colors.cyan[100] : Colors.white,
                    headerBuilder: (_, isExpanded) => Container(
                        padding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        child: Text(
                          item['title'],
                          style: TextStyle(fontSize: 20),
                        )),
                    body: Container(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      child: Text(item['description']),
                    ),
                    isExpanded: item['isExpanded'],
                  ),
                )
                    .toList(),
              )*/

            //time
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: TextField(
                      readOnly: true,
                      controller: _time,
                      keyboardType: TextInputType.datetime,
                      onTap: () async {
                        Duration initialtimer = const Duration();
                        DatePicker.showTime12hPicker(
                          context,
                          onConfirm: (selected) {
                            _time.text = DateFormat("jms").format(selected);
                          },
                          // minTime: DateTime.now(),
                          // maxTime: DateTime(2030, 12, 31),
                          onChanged: (date) {
                            _time.text = DateFormat("jms").format(date);
                            print('change $date');
                          },
                          currentTime: DateTime.now(),
                        );

                        // TimeOfDay? time=  await getTime(context: context, title: "Select Your Time",);
                        // String timeNew=time!.format(context);
                        // print(timeNew);
                        // _time.text=timeNew;

                        // Get.bottomSheet(
                        //   Column(
                        //     mainAxisSize: MainAxisSize.min,
                        //     children: [
                        //
                        //       // CupertinoTimerPicker(
                        //       //   mode: CupertinoTimerPickerMode.hm,
                        //       //   backgroundColor: kWhiteColor,
                        //       //   minuteInterval: 1,
                        //       //   secondInterval: 1,
                        //       //   initialTimerDuration: initialtimer,
                        //       //   onTimerDurationChanged: (Duration changedtimer) {
                        //       //     setState(() {
                        //       //       initialtimer = changedtimer;
                        //       //       _time.text = changedtimer.toString().substring(0, 4);
                        //       //     });
                        //       //     print(initialtimer);
                        //       //   },
                        //       // ),
                        //       ButtonBar(
                        //         alignment: MainAxisAlignment.spaceEvenly,
                        //         children: [
                        //           SizedBox(
                        //             width: Get.width / 2 - 40,
                        //             child: TextButton(
                        //               onPressed: () {
                        //                 Get.back();
                        //               },
                        //               style: TextButton.styleFrom(
                        //                 backgroundColor: kPrimaryColor,
                        //                 foregroundColor: kWhiteColor,
                        //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        //               ),
                        //               child: Text(
                        //                 "Cancel",
                        //                 style: fontBody(fontSize: 19),
                        //               ),
                        //             ),
                        //           ),
                        //           SizedBox(
                        //             width: Get.width / 2 - 40,
                        //             child: TextButton(
                        //               onPressed: () {
                        //                 Get.back();
                        //               },
                        //               style: TextButton.styleFrom(
                        //                 backgroundColor: kPrimaryColor,
                        //                 foregroundColor: kWhiteColor,
                        //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        //               ),
                        //               child: Text(
                        //                 "Set",
                        //                 style: fontBody(fontSize: 19),
                        //               ),
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ],
                        //   ),
                        //   backgroundColor: kWhiteColor,
                        // );
                      },
                      decoration: InputDecoration(
                        hintText: '00:00',
                        hintStyle:
                            const TextStyle(color: Colors.grey, fontSize: 16),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 6.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xffE7E7E7), width: 1)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xffE7E7E7), width: 1)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 50,
                    width: 150,
                    child: OutlinedButton(
                      onPressed: () {
                        _time.text = DateFormat("jms").format(DateTime.now());
                        print(_time.text);
                      },
                      style: OutlinedButton.styleFrom(
                        //backgroundColor: (_nowPressed == true) ?  Colors.teal : Colors.white ,
                        side: const BorderSide(color: Colors.teal),
                      ),
                      child: const Text(
                        'Now',
                        style: TextStyle(
                            color: Colors.teal, fontFamily: "Poppins"),
                      ),
                    ),
                  )
                ],
              ),
            ),

            // Usertype drop down
            userDropDown(),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Container(
                height: Get.height * 0.08,
                width: Get.width * 0.6,
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
            ),
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
                                  future: getUserCards(userId: widget.uid),
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
                                                          eachUserCards[index][
                                                                      'brand'] ==
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
                                    userId: widget.uid,
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
            SizedBox(
              height: 10,
            ),
            //Comment section
            if (selectedTask == ('Light Housekeeping'))
              TextField(
                controller: descController,
                maxLength: 50,
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: "Cleaning Sq. feet  ",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Color(0xffE7E7E7), width: 1)),
                ),
                onChanged: (val) {
                  print("10");
                }, /*(jvalue) {
                  rangeValue = jvalue;
                  print(jvalue);
                },*/
              ),

            //Price
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _price,
                      keyboardType: TextInputType.number,
                      style:
                          fontBody(fontSize: 16, fontWeight: FontWeight.w400),
                      decoration: InputDecoration(
                        labelText: "Price",
                        labelStyle: fontBody(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            fontColor: const Color(0xffB7B7B7)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xffE7E7E7), width: 1)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xff000000), width: 2)),
                      ),
                      //validator: nameValidator,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      onPressed: () async {
                        setState(() {
                          taskCreated = true;
                          print(taskCreated);
                        });
                        // field name in camel case

                        DocumentSnapshot check = await FirebaseFirestore
                            .instance
                            .collection("instantTask")
                            .doc(widget.uid)
                            .get();

                        if (check.exists) {
                          customToast("You have already created a task");
                          return;
                        }

                        makePayment(
                            amount: double.parse(_price.text),
                            tId: widget.uid,
                            name: task["name"],
                            icon: task["icon"],
                            cardId: selectedCard['id'],
                            customerId: userStripeId);
                      },
                      child: const Text(
                        "Confirm",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontFamily: "Poppins"),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      }),
      elevation: 10,
      /* isScrollControlled: false,*/
      backgroundColor: Colors.white,
    );
  }

  Future<void> makePayment(
      {required double amount,
      required String tId,
      name,
      icon,
      required cardId,
      required customerId}) async {
    try {
      // paymentIntent = await createPaymentIntent(amount, 'USD');
      //
      // await Stripe.instance
      //     .initPaymentSheet(
      //         paymentSheetParameters: SetupPaymentSheetParameters(
      //             paymentIntentClientSecret: paymentIntent!['client_secret'],
      //             style: ThemeMode.light,
      //             merchantDisplayName: 'Hailo Care'))
      //     .then((value) {});

      displayPaymentSheet(amount, name, icon, tId, cardId, customerId);
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
          headers: {"Content-Type": "application/json"},
          body: json.encode(body));
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

  displayPaymentSheet(
      double amount, String name, icon, tId, cardId, customerId) async {
    try {
      // await Stripe.instance.presentPaymentSheet().then((value) async {
      await payToStripe(
              customerId: customerId,
              cardId: cardId,
              amount: (amount * 100).toInt().toString())
          .then((value) async {
        if (paymentDone == true) {
          await FirebaseFirestore.instance
              .collection("transactionPending")
              .doc(widget.uid)
              .set({
            "userUid": widget.uid,
            "day": DateFormat('dd-MM-yyyy').format(DateTime.now()),
            "month": DateFormat('MMM-yyyy').format(DateTime.now()),
            "time": DateTime.now(),
            "price": amount,
            "isPending": true,
          }).then((value) async {
            await FirebaseFirestore.instance
                .collection("instantTask")
                .doc(widget.uid)
                .set({
              "destination": name == "Drive"
                  ? stopOneController.text
                  : searchLocationController.text,
              "requirements": selectedValue,
              "relation": user,
              "price": amount,
              "time": _time.text,
              "date": date,
              "uid": widget.uid,
              "taskName": name,
              "taskIcon": icon,
              "location": name == "Grocery Shopping" || name == "Drive"
                  ? pickupPoint
                  : location,
              "plocation": pickUpController.text,
              "comment": descController.text,
              "dlocation": name == "Drive" ? stopOnePoint : lastposition,
              /*"stopOneName": stopOneController.text,
            "stopOneLocation": name == "Drive" ? stopOnePoint : 0,*/
              "isActive": "No",
              //"withdrawalID": value.id,
            });
          });

          Get.to(
              () => TaskCreated(
                    uid: widget.uid,
                  ),
              arguments: [
                amount,
                _time.text,
                date,
                name,
                icon,
                searchLocationController.text,
                stopOneController.text,
                pickUpController.text,
              ]);
          customToast("Payment Successful");
          paymentIntent = null;
        } else {
          customToast('Payment not done due to some error');
        }
      }).onError((error, stackTrace) {
        customToast("$error $stackTrace");
      });
    } on StripeException catch (e) {
      customToast("${e.error}");
    } catch (e) {
      customToast('$e');
    }
  }

  Future<TimeOfDay?> getTime({
    required BuildContext context,
    String? title,
    TimeOfDay? initialTime,
    String? cancelText,
    String? confirmText,
  }) async {
    TimeOfDay? time = await showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      cancelText: cancelText ?? "Cancel",
      confirmText: confirmText ?? "Save",
      helpText: title ?? "Select time",
      builder: (context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    return time;
  }
}
