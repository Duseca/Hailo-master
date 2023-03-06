import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationController extends GetxController {
  var latitude = 51.509865.obs;
  var longitude = -0.118092.obs;
  late StreamSubscription<Position> streamSubscription;
  bool yes = false;
  Completer<GoogleMapController> googleMapController = Completer();

  @override
  void onInit() async {
    super.onInit();
    mylocation();
  }

  void mylocation() async {
    bool yourlocation;
    LocationPermission permission;

    yourlocation = await Geolocator.isLocationServiceEnabled();
    if (!yourlocation) {
      return Future.error('Location Service is disabled');
    }
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location Permission  Denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location Permanently Denied');
    }

    Position position = await Geolocator.getCurrentPosition();
  }

  Future<void> check() async {
    yes = !yes;
    if (yes) {
      showlocation();
    }
    update();
  }

  showlocation() async {
    Position position = await Geolocator.getCurrentPosition();
    final GoogleMapController controller = await googleMapController.future;

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(position.latitude, position.longitude),zoom: 12),
      ),
    );
  }
}
